# Project Overview

This project endeavors to develop a 3D IC (Integrated Circuit) simulation framework leveraging the power of Open EDA (Electronic Design Automation) toolchains. Our goal is to provide a comprehensive solution for researchers and engineers to explore and evaluate the potential of 3D IC designs.

Open3DFlow now supports two-layer 3D IC, sky130A and gf180 processes. Its overall operation mode is shown in the following figure:

![open3dflow infrastructure](doc/open3dflow.png)


# Honorable Mention

This project has the distinction of being recognized in the VLSI24 "code-a-chip" competition (https://github.com/sscs-ose/sscs-ose-code-a-chip.github.io/tree/main/VLSI24). The award-winning entry, a fully functional Jupyter notebook, can be found at /doc/Open3DFlow.ipynb. This notebook serves as a valuable starting point and reference for understanding the capabilities and implementation of our 3D IC simulation approach.

![Honorable Mention](doc/code-a-chip.png)

# Open 3D IC Design Flow
Open3DFlow targets at realizing F2F-stacked 3D processors. It supports the hardening of a 3D CPU configured as the following figure, wherein the top tier functions as a cache die hosting SRAM macros, while the bottom tier incorporates the logical realization of the CPU and other hard macros. The two tiers are stacked F2F, sharing a synchronized clock and maintaining their power grids. Bonding pads and TSVs transmit their signal and power.

![3D CPU stacking configuration, where a top cache tier and a bottom logic tier are stacked F2F](doc/two_tier.png)

Open3DFlow has referenced the operation flow of OpenRoad Flow Scripts (ORFS)\footnote{https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts}. In this work, we abstract certain existing steps within ORFS and augment them with additional modules tailored to our specific needs. The overall workflow of Open3DFlow contains 7 steps:

![the seven-step workflow of Open3DFlow, where AI aids in
deciding bonding pads’ locations](doc/step.png)

# Results Showcases
- Floorplan images of the 3D RISC-V processor in Open3DFlow:

![top](doc/top.png)
![bottom](doc/bottom.png)

- Temperature distribution maps with maximum temperatures
of 25.5°C and 25.38°C for the bottom and top dies respectively:

![top_tem](doc/top_the.png)
![bottom_tem](doc/bottom_the.png)

- Eye diagram of signals with frequency varying from 25MHz to 2GHz:
![SI analysis](doc/eye.jpg)


# Recent Advancements

Around June of this year, building on the success of the award-winning work, I undertook significant enhancements to the design. 

However, a selection of these improvements has been uploaded, providing an updated glimpse into the project's progress. 

I sincerely apologize for not adhering to optimal naming conventions and organizing the code and files effectively during the development of Open3DFlow. I am currently engaged in the task of reorganizing my files, tidying up and categorizing the code, and aim to provide a comprehensive and user-friendly set of instructions and scripts that will facilitate the reproduction of our work. While this may not be an overly complex task, it is indeed quite meticulous and time-consuming. Rest assured, I will continue to update the detailed instructions on the running process as I progress.

# Contribute and Collaborate

We welcome contributions from the community! Whether it's bug reports, feature requests, or even code contributions, your input is invaluable to the growth and success of this project. Feel free to open issues or submit pull requests on GitHub

# Author Information
Yifei Zhu, RIOS Lab, TsingHua University

Feel free to contact me through
 - WeChat: b224hislabcd
 - Mail: b224hisl@yandex.com ; zhuyf20@mails.tsinghua.edu.cn

【20250530】update
This project is part of my doctoral dissertation. It has undergone numerous updates and revisions but has not yet been published, as it contains proprietary data and models developed in collaboration with our manufacturing partner. An anonymized version will be released in the future.

Thank you all so much for your interest! I’ve received many inquiries from other students and researchers, trust me～ and I’m fully committed to delivering this work!

