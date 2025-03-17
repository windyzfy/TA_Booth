def bin_file_to_dec(input_file, output_file):
    """
    读取二进制文件，将其转换为十进制数值
    参数：
        input_file: 输入的二进制文件路径
        output_file: 输出的文本文件路径
    """
    try:
        # 读取二进制文件
        with open(input_file, 'rb') as f:
            binary_data = f.read()
        
        # 检查文件大小
        file_size = len(binary_data)
        if file_size == 0:
            raise ValueError("输入文件为空")
        
        # 将二进制数据转换为二进制字符串，然后转为十进制
        decimal_values = []
        for byte in binary_data:
            # 将字节转换为8位二进制字符串
            bin_str = format(byte, '08b')
            # 转换为十进制
            decimal_value = int(bin_str, 2)
            decimal_values.append(str(decimal_value))
        
        # 写入输出文件
        with open(output_file, 'w') as f:
            # 每行写入8个数字，用空格分隔
            for i in range(0, len(decimal_values), 8):
                line = ' '.join(decimal_values[i:i+8])
                f.write(line + '\n')
        
        print(f"转换完成！结果已保存到 {output_file}")
        print(f"共转换了 {len(decimal_values)} 个字节")
        print(f"每行包含8个数值，使用空格分隔")
        
    except FileNotFoundError:
        print(f"错误：找不到输入文件 {input_file}")
    except ValueError as ve:
        print(f"错误：{ve}")
    except Exception as e:
        print(f"发生错误：{e}")

if __name__ == "__main__":
    input_file = "Data/Rec250315205020.bin"  # 您的二进制文件路径
    output_file = "output.txt"
    
    print("开始转换二进制文件...")
    print(f"输入文件：{input_file}")
    print(f"输出文件：{output_file}")
    bin_file_to_dec(input_file, output_file)