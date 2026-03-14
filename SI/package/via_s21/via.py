import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import skrf as rf
from scipy.constants import pi, c

# Set parameters
freq = 6400e6  # Fixed frequency 6400 MHz
num_vias = np.arange(0, 11, 1)  # Number of via transitions: 0 to 10

# ABF substrate parameters
epsilon_r = 3.4  # Relative permittivity for ABF material
loss_tangent = 0.004  # Loss tangent for ABF (lower than FR-4)
dielectric_thickness = 0.015  # mm per layer (typical for ABF build-up)

# Create a frequency object for single frequency
frequency = rf.Frequency.from_f([freq], unit='Hz')

def create_via_model(freq, epsilon_r, thickness_mm, via_diameter=0.2, pad_diameter=0.4):
    """
    Create a via equivalent circuit model based on physical parameters
    
    Parameters:
    freq: frequency in Hz
    epsilon_r: relative permittivity
    thickness_mm: dielectric thickness in mm
    via_diameter: via hole diameter in mm
    pad_diameter: via pad diameter in mm
    
    Returns:
    via_network: RF network representing the via
    """
    
    # Convert to meters
    thickness = thickness_mm / 1000.0
    via_radius = via_diameter / 2000.0
    pad_radius = pad_diameter / 2000.0
    
    # Calculate angular frequency
    omega = 2 * pi * freq
    
    # Via inductance (simplified model)
    # L_via ≈ μ0 * h / (2π) * ln(4h/d) for h >> d
    mu0 = 4e-7 * pi
    L_via = mu0 * thickness / (2 * pi) * np.log(4 * thickness / (2 * via_radius))
    
    # Via capacitance (parallel plate approximation with fringing correction)
    # C_via ≈ ε0 * εr * π * (r_pad^2 - r_via^2) / h
    epsilon0 = 8.854e-12
    C_via = epsilon0 * epsilon_r * pi * (pad_radius**2 - via_radius**2) / thickness
    
    # Add fringing capacitance (empirical correction)
    C_fringe = 0.1 * C_via  # Approximate fringing capacitance
    C_total = C_via + C_fringe
    
    # Via resistance (skin effect and material resistivity)
    # Simplified model: R_via = ρ * h / (π * r_via^2) * skin_effect_factor
    rho_copper = 1.68e-8  # Copper resistivity
    skin_depth = np.sqrt(rho_copper / (pi * freq * mu0))
    R_via = rho_copper * thickness / (pi * via_radius**2) * (1 + thickness/(2*skin_depth))
    
    # Create equivalent circuit components
    # Via model: Series R-L, shunt C to ground
    Z_series = R_via + 1j * omega * L_via
    Y_shunt = 1j * omega * C_total
    
    # Create ABCD matrix for the via
    # For a T-model: series Z, shunt Y
    A = 1 + Z_series * Y_shunt / 2
    B = Z_series * (1 + Z_series * Y_shunt / 4)
    C = Y_shunt
    D = 1 + Z_series * Y_shunt / 2
    
    # Convert ABCD to S-parameters
    Z0 = 50  # Reference impedance
    
    # ABCD to S-parameter conversion
    denom = A + B/Z0 + C*Z0 + D
    S11 = (A + B/Z0 - C*Z0 - D) / denom
    S12 = 2 * (A*D - B*C) / denom
    S21 = 2 / denom
    S22 = (-A + B/Z0 - C*Z0 + D) / denom
    
    # Create a Network object from S-parameters
    s_matrix = np.array([[[S11, S12], [S21, S22]]])
    via_network = rf.Network(s=s_matrix, frequency=frequency, z0=Z0)
    
    return via_network

def create_transmission_line_model(freq, length_mm, epsilon_r, loss_tangent):
    """
    Create a transmission line model for the inter-via segments
    
    Parameters:
    freq: frequency in Hz
    length_mm: length of transmission line in mm
    epsilon_r: relative permittivity
    loss_tangent: dielectric loss tangent
    
    Returns:
    line_network: RF network representing the transmission line
    """
    
    # Convert to meters
    length = length_mm / 1000.0
    
    # Calculate propagation parameters
    v_p = c / np.sqrt(epsilon_r)  # Phase velocity
    wavelength = v_p / freq
    
    # Calculate attenuation (dielectric and conductor losses)
    # Dielectric loss
    alpha_d_dB = 27.3 * loss_tangent * freq / (c / np.sqrt(epsilon_r))  # dB/m
    alpha_d_Np = alpha_d_dB / (20 * np.log10(np.e))  # Convert to Np/m
    
    # Conductor loss (approximation for microstrip)
    # For typical PCB traces at 6.4 GHz, conductor loss ~ 1-2 dB/m
    alpha_c_dB = 1.5  # dB/m
    alpha_c_Np = alpha_c_dB / (20 * np.log10(np.e))  # Convert to Np/m
    
    # Total attenuation
    alpha_Np = 6.472
    
    # Calculate propagation constant
    beta = 2 * pi / wavelength  # Phase constant
    gamma = alpha_Np + 1j * beta  # Propagation constant
    
    # Create transmission line media
    media = rf.DefinedGammaZ0(frequency=frequency, gamma=gamma, z0=50)
    
    # Calculate electrical length in degrees
    electrical_length_deg = (length / wavelength) * 360
    
    # Create transmission line
    line_network = media.line(d=electrical_length_deg, unit='deg')
    
    return line_network

# Calculate S21 for different numbers of vias
s21_results = []

for num_via in num_vias:
    if num_via == 0:
        # No vias, just a straight transmission line
        line_length = 10.0  # mm
        line_network = create_transmission_line_model(freq, line_length, epsilon_r, loss_tangent)
        total_network = line_network
    else:
        # Create networks for vias and connecting transmission lines
        networks = []
        
        # Add first transmission line segment
        line_length = 5.0  # mm between vias
        line_network = create_transmission_line_model(freq, line_length, epsilon_r, loss_tangent)
        networks.append(line_network)
        
        # Add vias and connecting transmission lines
        for i in range(num_via):
            # Add via
            via_network = create_via_model(freq, epsilon_r, 0.6)
            networks.append(via_network)
            
            # Add transmission line between vias (except after last via)
            if i < num_via - 1:
                line_network = create_transmission_line_model(freq, line_length, epsilon_r, loss_tangent)
                networks.append(line_network)
        
        # Add final transmission line segment
        line_network = create_transmission_line_model(freq, line_length, epsilon_r, loss_tangent)
        networks.append(line_network)
        
        # Cascade all networks
        total_network = networks[0]
        for network in networks[1:]:
            total_network = total_network ** network
    
    # Extract S21 at our frequency
    s21 = total_network.s[0, 1, 0]  # First frequency, S21
    s21_dB = 20 * np.log10(np.abs(s21))
    s21_results.append(s21_dB)

# Create plot
plt.figure(figsize=(10, 6))
plt.plot(num_vias, s21_results, 'b-o', linewidth=2, markersize=8)
plt.xlabel('Number of Via Transitions', fontsize=12)
plt.ylabel('S21 (dB)', fontsize=12)
plt.title('Signal Attenuation vs Number of Via Transitions for DQ\n' +
          f'Frequency: {freq/1e9} GHz, ABF εr: {epsilon_r}, Loss Tangent: {loss_tangent}', fontsize=14)
plt.grid(True, linestyle='--', alpha=0.7)

# Add annotation
plt.text(0.7, 0.9, f'Dielectric Thickness: {dielectric_thickness} mm/layer', 
         transform=plt.gca().transAxes, fontsize=10,
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# Save image
plt.savefig('via_transitions_s21_new.png', dpi=300, bbox_inches='tight')
print("Image saved as 'via_transitions_s21.png'")

# Print results table
print("\nS21 vs Number of Via Transitions:")
print("Number of Vias\tS21 (dB)")
for i, num in enumerate(num_vias):
    print(f"{num}\t\t{s21_results[i]:.2f}")

# Additional analysis: Calculate insertion loss per via
if len(num_vias) > 1:
    print("\nInsertion Loss per Via Transition:")
    for i in range(1, len(num_vias)):
        loss_per_via = s21_results[i] - s21_results[i-1]
        print(f"Via {i}: {loss_per_via:.3f} dB")
    
    avg_loss_per_via = (s21_results[-1] - s21_results[0]) / (len(num_vias) - 1)
    print(f"\nAverage loss per via: {avg_loss_per_via:.3f} dB")