def segment_data(input_file):
    """
    读取数据文件，当遇到连续32个0时进行分段
    参数：
        input_file: 输入文件路径（每行一个数）
    """
    try:
        # 读取所有数据
        with open(input_file, 'r') as f:
            numbers = [int(line.strip()) for line in f]

        # 初始化变量
        zero_count = 0  # 连续0的计数器
        segment_count = 0  # 分段计数器
        current_segment = []  # 当前段的数据
        
        # 处理每个数字
        for num in numbers:
            current_segment.append(num)
            
            if num == 0:
                zero_count += 1
            else:
                # 如果之前有32个或更多连续的0
                if zero_count >= 32:
                    # 保存当前段（不包括连续0）
                    segment_count += 1
                    save_segment(current_segment[:-zero_count], segment_count)
                    # 开始新的段（从连续0开始）
                    current_segment = current_segment[-zero_count:]
                zero_count = 0

        # 保存最后一段
        if current_segment:
            segment_count += 1
            save_segment(current_segment, segment_count)

        print(f"\n数据分段完成！")
        print(f"总共生成了 {segment_count} 个分段文件")
        print(f"总数据量：{len(numbers)} 个数字")

    except FileNotFoundError:
        print(f"错误：找不到输入文件 {input_file}")
    except Exception as e:
        print(f"发生错误：{e}")

def save_segment(data, segment_number):
    """
    保存数据段到文件
    """
    if not data:  # 如果数据段为空，直接返回
        return
        
    output_file = f"Data/segment_{segment_number}.txt"
    with open(output_file, 'w') as f:
        for num in data:
            f.write(f"{num}\n")
    
    print(f"段 {segment_number} 已保存到 {output_file}")
    print(f"该段包含 {len(data)} 个数值")

if __name__ == "__main__":
    input_file = "D:/Program Files/Verilogdemo/TA_Booth/Data/output_single.txt"  # 输入文件（每行一个数的格式）
    
    print("开始进行数据分段...")
    print(f"输入文件：{input_file}")
    segment_data(input_file) 