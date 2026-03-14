import re

def replace_layer_l1(input_file, output_file):
    """
    替换.lef文件中LAYER L1的RECT块为L3_v/L3_h/L5_v/L5_h的RECT块
    
    Args:
        input_file (str): 输入的.lef文件路径
        output_file (str): 输出的新.lef文件路径
    """
    # 正则表达式匹配模式：捕获LAYER L1和对应的RECT坐标
    # 匹配规则：
    # \s+ 匹配任意数量的空格/制表符
    # (\S+) 捕获非空格的坐标值（a,b,c,d）
    pattern = re.compile(
        r'(\s+)LAYER L1 ;\n'          # 匹配 LAYER L1 ; 行，捕获前面的空格
        r'(\s+)RECT\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*;'  # 匹配 RECT 行，捕获空格和a,b,c,d
    )
    
    # 替换模板：保留原有的缩进空格，生成四个层的RECT块
    def replace_match(match):
        # 提取匹配到的内容
        indent1 = match.group(1)  # LAYER行的缩进空格
        indent2 = match.group(2)  # RECT行的缩进空格
        a, b, c, d = match.group(3), match.group(4), match.group(5), match.group(6)
        a = round(float(a), 0)
        b = round(float(b), 0)
        c = round(float(c), 0)
        d = round(float(d), 0)
        
        # 构造替换后的内容
        replacement = (
            f"{indent1}LAYER L1 ;\n"
            f"{indent2}RECT  {a} {b} {c} {d} ;"
            f"{indent1}LAYER L3_v ;\n"
            f"{indent2}RECT  {a} {b} {c} {d} ;"
            f"{indent1}LAYER L3_h ;\n"
            f"{indent2}RECT  {a} {b} {c} {d} ;"
            f"{indent1}LAYER L5_v ;\n"
            f"{indent2}RECT  {a} {b} {c} {d} ;"
            f"{indent1}LAYER L5_h ;\n"
            f"{indent2}RECT  {a} {b} {c} {d} ;"

            # f"{indent1}LAYER L3_v ;\n"
            # f"{indent2}RECT  {a+50} {b+50} {c-50} {d-50} ;"
            # f"{indent1}LAYER L3_h ;\n"
            # f"{indent2}RECT  {a+100} {b+100} {c-100} {d-100} ;"
            # f"{indent1}LAYER L5_v ;\n"
            # f"{indent2}RECT  {a+150} {b+150} {c-150} {d-150} ;"
            # f"{indent1}LAYER L5_h ;\n"
            # f"{indent2}RECT  {a+200} {b+200} {c-200} {d-200} ;"
        )
        return replacement
    
    # 读取并处理文件
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 执行替换
        new_content = pattern.sub(replace_match, content)
        
        # 写入新文件
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"generate via-in-pad new lef: {output_file}")
        
    except FileNotFoundError:
        print(f"cannot find {input_file}")
    except Exception as e:
        print(f"error：{str(e)}")

# ------------------- 配置参数 -------------------
# 请修改这里的文件路径为你实际的文件路径
# INPUT_LEF_FILE = "ddr_origin.lef"    # ddr
# OUTPUT_LEF_FILE = "ddr.lef"  # 处理后的新文件
# INPUT_LEF_FILE = "soc_origin.lef"    # soc
# OUTPUT_LEF_FILE = "soc.lef"  # 处理后的新文件
# ------------------------------------------------

# 执行替换
if __name__ == "__main__":
    replace_layer_l1("soc_origin.lef", "soc.lef")
    replace_layer_l1("ddr_origin.lef", "ddr.lef")