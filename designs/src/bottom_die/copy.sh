#!/bin/bash  
  
# 检查参数数量  
if [ "$#" -ne 1 ]; then  
    echo "Usage: $0 <path_to_file_list.f>"  
    exit 1  
fi  
  
# 读取文件列表文件  
FILE_LIST=$1  
  
# 遍历文件中的每一行  
while IFS= read -r file_path; do  
    # 检查文件是否存在  
    if [ -f "$file_path" ]; then  
        # 复制文件到当前目录  
        cp "$file_path" "./$(basename "$file_path")"  
        echo "Copied $file_path to current directory."  
    else  
        echo "File not found: $file_path"  
    fi  
done < "$FILE_LIST"  
  
echo "All files have been processed."