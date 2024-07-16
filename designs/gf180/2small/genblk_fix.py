import re
import sys
import os
def replace_gen_pattern(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        file_content = file.read()
    
    #updated_content = re.sub(r'\\genblk(\d+)\[(\d+)\]\.', r'genblk_\1_\2_', file_content)
    updated_content = file_content.replace('\\genblk1[0].sram_u', 'genblk_0_0_sram_u')  
    updated_content = updated_content.replace('\\genblk1[1].sram_u', 'genblk_1_0_sram_u') 

    with open('fixed' + os.path.basename(file_path), 'w', encoding='utf-8') as file:
        file.write(updated_content)

file_path = sys.argv[1]
replace_gen_pattern(file_path)
