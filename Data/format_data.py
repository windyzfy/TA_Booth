def reformat_data(input_file, output_file):
    """
    将输入文件中的数据重新格式化，从每行8个数改为每行1个数
    参数：
        input_file: 输入文件路径
        output_file: 输出文件路径
    """
    try:
        # 读取输入文件
        with open(input_file, 'r') as f:
            lines = f.readlines()

        # 打开输出文件
        with open(output_file, 'w') as f:
            # 处理每一行
            for line in lines:
                # 移除行号（如果有）和空白字符，分割数字
                if '|' in line:
                    numbers = line.split('|')[1].strip().split()
                else:
                    numbers = line.strip().split()
                
                # 每个数字单独写入一行
                for num in numbers:
                    f.write(f"{num}\n")

        print(f"转换完成！")
        print(f"输入文件：{input_file}")
        print(f"输出文件：{output_file}")
        
        # 统计数字总数
        with open(output_file, 'r') as f:
            count = sum(1 for line in f)
        print(f"共处理了 {count} 个数字")

    except FileNotFoundError:
        print(f"错误：找不到输入文件 {input_file}")
    except Exception as e:
        print(f"发生错误：{e}")

if __name__ == "__main__":
    input_file = "Data/output.txt"  # 输入文件
    output_file = "Data/output_single.txt"  # 输出文件
    
    print("开始重新格式化数据文件...")
    reformat_data(input_file, output_file) 