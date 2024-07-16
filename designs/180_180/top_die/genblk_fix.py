import re
import sys
import os
def replace_gen_pattern(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        file_content = file.read()
    
    #updated_content = re.sub(r'\\genblk(\d+)\[(\d+)\]\.', r'genblk_\1_\2_', file_content)
    updated_content = file_content.replace('\\l2u.genblk2[0].dat_ram', 'data_ram_0')  
    updated_content = updated_content.replace('\\l2u.genblk2[1].dat_ram', 'data_ram_1')
    updated_content = updated_content.replace('\\l2u.genblk2[0].tag_ram', 'tag_ram_0') 
    updated_content = updated_content.replace('\\l2u.genblk2[1].tag_ram', 'tag_ram_1') 

    with open('fixed' + os.path.basename(file_path), 'w', encoding='utf-8') as file:
        file.write(updated_content)

file_path = sys.argv[1]
replace_gen_pattern(file_path)
