import re
from collections import defaultdict

class NetAnalyzer:
    def __init__(self):
        self.soc_pins = {}  # soc_pin_name -> net_name
        self.ddr_pins = []  # 存储4个DDR的引脚信息 [{pin->net}, {pin->net}, {pin->net}, {pin->net}]
        self.ddr_nets = []  # 存储4个DDR的网络集合 [set(), set(), set(), set()]
        
        # 需要忽略的DDR网络前缀
        self.ignore_prefixes = ['VDD_1P1V', 'VDDQ_1P1V', 'VPP_1P8V', 'VSS', 'NC', 'VDD']
        
    def parse_soc_file(self, filename):
        """解析SOC引脚文件"""
        print(f"解析SOC文件: {filename}")
        with open(filename, 'r') as f:
            lines = f.readlines()
        
        # 跳过可能的标题行
        start_idx = 0
        for i, line in enumerate(lines):
            if line.strip().startswith('soc_'):
                start_idx = i
                break
        
        for line in lines[start_idx:]:
            line = line.strip()
            if not line:
                continue
                
            # 解析SOC引脚名和网络名
            parts = line.split()
            if len(parts) >= 2:
                pin_name = parts[0]
                net_name = ' '.join(parts[1:])  # 处理可能包含空格的网络名
                self.soc_pins[pin_name] = net_name
        
        print(f"  解析到 {len(self.soc_pins)} 个SOC引脚")
        return self.soc_pins
    
    def parse_ddr_file(self, filename):
        """解析DDR引脚文件"""
        print(f"解析DDR文件: {filename}")
        with open(filename, 'r') as f:
            lines = f.readlines()
        # 解析表头，确定列数
        entity_line = lines[0].split()
        ddr_count = len(entity_line)
        
        # 初始化数据结构
        self.ddr_pins = [defaultdict(str) for _ in range(ddr_count)]
        
        # 处理数据行
        for i in range(2, len(lines)):  # 跳过表头行
            content = lines[i].split()
            pin_number = content[0]
            for k in range (0, ddr_count):
                net_name = content[1+2*k]
                self.ddr_pins[k][pin_number] = net_name
        print(f"  解析到 {ddr_count} 个DDR，每个DDR引脚数:")
        for i in range(ddr_count):
            print(f"    DDR{i+1}: {len(self.ddr_pins[i])} 个引脚")
        
        return self.ddr_pins
    
    def find_matching_nets(self):
        """查找SOC和DDR之间匹配的网络"""
        print("\n查找匹配网络...")
        
        # 收集所有DDR网络
        all_ddr_nets_initial = set()
        for i in range (0,len(self.ddr_pins)):
            # print ("i=",i)
            all_ddr_nets_initial = all_ddr_nets_initial.union(self.ddr_pins[i].values())
            # print (all_ddr_nets)
        all_ddr_nets = all_ddr_nets_initial - {'VSS'}
        # 收集所有SOC网络
        all_soc_net = set(self.soc_pins.values())
        self.matching_nets = all_ddr_nets & all_soc_net
        # self.soc_non_match_nets = all_soc_net - self. matching_nets
    
        print(f"  找到 {len(self.matching_nets)} 个匹配网络:", self.matching_nets)
        return self.matching_nets
    
    def find_soc_only_nets(self):
        """查找只在SOC中出现的网络"""
        print("\n查找SOC独有网络...")
        values_to_remove = self.matching_nets
        # print ("value_to_remove",values_to_remove,len(values_to_remove))
        # print ("soc_pin_item",len(self.soc_pins.items()))
        soc_spec = {k: v for k, v in self.soc_pins.items() if v not in values_to_remove}
        # print(f"  找到 {len(soc_spec)} 个SOC独有网络")
        # print("soc_spec:",soc_spec)
        return soc_spec
    
    def generate_verilog(self, matching_nets, soc_only_nets, output_file):
        """生成Verilog连接文件"""
        print(f"\n生成Verilog文件: {output_file}")
        
        verilog_code = []
        
        # 文件头
        verilog_code.append("// ============================================================")
        verilog_code.append("// DDR Interface Connection Module")
        verilog_code.append("// Generated from SOC and 4 DDR chips")
        verilog_code.append("// ============================================================")
        verilog_code.append("")
        verilog_code.append("")
        verilog_code.append("module soc_ddr (")
        
        # 生成端口声明
        port_lines = []
        port_type = 'inout'
        top_inout = set()
        # print ("soc_only_nets:",soc_only_nets)
        top_inout = top_inout.union(soc_only_nets.values())
        top_inout = top_inout - {'NC'}
        print ("top_inout=",top_inout)

        bus = []
        for top_inout_i in top_inout:
            if '[' in top_inout_i:
                bus.append(top_inout_i)
                print (top_inout_i)
            else:
                port_lines.append(f"    {port_type} {top_inout_i}")
        prefix_max = {}
        for sig in bus:
            prefix, rest = sig.split('[', 1)
            index_str = rest[:-1]  
            if index_str.isdigit():
                idx = int(index_str)
                if prefix not in prefix_max or idx > prefix_max[prefix]:
                    prefix_max[prefix] = idx
        for prefix in sorted(prefix_max): 
            port_lines.append(f"    {port_type} [{prefix_max[prefix]}:0] {prefix}")
        
        verilog_code.append(",\n".join(port_lines))
        verilog_code.append(");")
        verilog_code.append("")
        
        # SOC模块实例化
        verilog_code.append("    // ============================================================")
        verilog_code.append("    // SOC Module Instance")
        verilog_code.append("    // ============================================================")
        verilog_code.append("    soc u_soc (")
        
        # 生成SOC引脚连接
        soc_connections = []
        for pin_name, net_name in self.soc_pins.items():
            if net_name == 'NC':  # NC - 1'b0
                soc_connections.append(f"        .{pin_name}( )")
            else:
                soc_connections.append(f"        .{pin_name}({net_name})")
        verilog_code.append(",\n".join(soc_connections))
        verilog_code.append("    );")
        verilog_code.append("")
        
        # DDR模块实例化
        for ddr_idx in range(len(self.ddr_pins)):
            verilog_code.append(f"    // ============================================================")
            verilog_code.append(f"    // DDR{ddr_idx+1} Module Instance")
            verilog_code.append(f"    // ============================================================")
            verilog_code.append(f"    ddr DDR{ddr_idx+1} (")
            
            # 生成DDR引脚连接
            ddr_connections = []
            for pin_name, net_name in self.ddr_pins[ddr_idx].items():
                if net_name.startswith('NC') or net_name == 'VSS':  # NC - 1'b0, VSS - 1'b0
                    ddr_connections.append(f"        .{pin_name}( )")
                elif net_name == 'VDDQ_1P1V' or net_name == 'VPP_1P8V' or net_name == 'VDD_1P1V': # power - 1'b1
                    ddr_connections.append(f"        .{pin_name}( )")
                else:
                    ddr_connections.append(f"        .{pin_name}({net_name})")
            
            verilog_code.append(",\n".join(ddr_connections))
            verilog_code.append(f"    );")
            verilog_code.append("")
        
        # 模块结束
        verilog_code.append("endmodule")
        verilog_code.append("")
        
        # 写入文件
        with open(output_file, 'w') as f:
            f.write('\n'.join(verilog_code))
        
        print(f"  Verilog文件已生成，包含:")
        print(f"    - {len(top_inout)} 个顶层端口, 目前是将SOC的全部拉出，DDR的没有")
        print(f"    - 1个SOC实例")
        print(f"    - {len(self.ddr_pins)} 个DDR实例")
        
        return '\n'.join(verilog_code)

def main():
    # 创建分析器
    analyzer = NetAnalyzer()
    
    # 解析文件
    soc_pins = analyzer.parse_soc_file('O3F_SOC.txt')
    ddr_pins = analyzer.parse_ddr_file('O3F_DDR.txt')
    
    # 查找匹配网络
    matching_nets = analyzer.find_matching_nets()
    
    # 查找SOC独有网络
    soc_only_nets = analyzer.find_soc_only_nets()
    
    # 生成Verilog文件
    verilog_code = analyzer.generate_verilog(matching_nets, soc_only_nets, 'soc_ddr.v')
    
    # 显示部分结果
    print("\n" + "="*80)
    print("生成完成!")
    print("="*80)

if __name__ == "__main__":
    main()