import matplotlib.pyplot as plt
import numpy as np

def plot_data(input_file, start_index=None, end_index=None):
    """
    读取数据文件并绘制曲线，忽略值为0的数据点
    参数：
        input_file: 输入文件路径
        start_index: 起始数据点索引（可选）
        end_index: 结束数据点索引（可选）
    """
    try:
        # 读取数据
        with open(input_file, 'r') as f:
            data = [int(line.strip()) for line in f]

        # 检查索引范围的有效性
        if start_index is None:
            start_index = 0
        if end_index is None:
            end_index = len(data)
        
        # 确保索引在有效范围内
        start_index = max(0, min(start_index, len(data)))
        end_index = max(0, min(end_index, len(data)))
        
        if start_index >= end_index:
            raise ValueError("起始索引必须小于结束索引")

        # 截取指定范围的数据
        data = data[start_index:end_index]
        base_index = start_index  # 保存基准索引，用于还原原始位置

        # 创建数据点的索引（x轴）
        indices = list(range(len(data)))

        # 过滤掉值为0的数据点
        filtered_data = []
        filtered_indices = []
        for i, value in enumerate(data):
            if value != 0:
                filtered_data.append(value)
                filtered_indices.append(i + base_index)  # 还原到原始位置的索引

        # 创建图形
        plt.figure(figsize=(15, 8))
        
        # 绘制曲线
        plt.plot(filtered_indices, filtered_data, 'b-', linewidth=1, label='数据曲线')
        plt.scatter(filtered_indices, filtered_data, c='red', s=20, alpha=0.5, label='数据点')

        # 设置图形属性
        title = f'数据曲线（忽略0值）- 数据点范围：{start_index} 到 {end_index}'
        plt.title(title, fontsize=14)
        plt.xlabel('数据点索引', fontsize=12)
        plt.ylabel('数值', fontsize=12)
        plt.grid(True, linestyle='--', alpha=0.7)
        plt.legend()

        # 设置x轴范围，留出一些边距
        margin = (end_index - start_index) * 0.05
        plt.xlim(start_index - margin, end_index + margin)

        # 保存图形
        output_file = f'data_plot_16_{start_index}_{end_index}.png'
        plt.savefig(output_file, dpi=300, bbox_inches='tight')
        print(f"图形已保存为 {output_file}")

        if filtered_data:  # 确保有非零数据点
            print(f"最大值：{max(filtered_data)}")
            print(f"最小值：{min(filtered_data)}")
            print(f"平均值：{np.mean(filtered_data):.2f}")
        else:
            print("所选范围内没有非零数据点")

    except FileNotFoundError:
        print(f"错误：找不到输入文件 {input_file}")
    except ValueError as ve:
        print(f"错误：{ve}")
    except Exception as e:
        print(f"发生错误：{e}")

if __name__ == "__main__":
    input_file = "Data/segment_16.txt"  # 输入文件
    
    
    # 绘制另一个范围的数据（例如：500-700）
    plot_data(input_file, 500, 1100)