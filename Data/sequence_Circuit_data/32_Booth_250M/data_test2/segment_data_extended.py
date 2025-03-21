import os
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter

# 设置中文字体
plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号

# 读取Booth乘数文件
booth_file_path = 'Data/sequence_Circuit_data/32_Booth_250M/data_test2/original_data/booth_multiplier.txt'  # 替换为实际路径
with open(booth_file_path, 'r') as f:
    booth_data = [line.strip().split() for line in f if line.strip()]

# 读取目录中的所有segment_*.txt文件
segment_dir = 'Data/sequence_Circuit_data/32_Booth_250M/data_test2/original_data/'  # 替换为实际目录
segment_files = sorted([f for f in os.listdir(segment_dir) if f.startswith('segment_') and f.endswith('.txt')])

# 参数设定
init_points = 1000
window_size = 200
segment_half_len = 70
segment_len = 2 * segment_half_len
stable_check_len = 15  # 跳过不稳定区域直到遇到15个连续稳定点

# 处理每个segment文件
all_segments = []
for idx, multiplier in enumerate(booth_data):
    if idx >= len(segment_files):
        break
    segment_file_path = os.path.join(segment_dir, segment_files[idx])
    with open(segment_file_path, 'r') as f:
        raw = np.array([float(line.strip()) for line in f if line.strip()])

    # 计算系统稳定值（近似众数）
    rounded = np.round(raw[:init_points], decimals=3)
    most_common_val = Counter(rounded).most_common(1)[0][0]

    # 提取波形段
    segments = []
    current_index = 0
    first_segment_found = False

    while current_index < len(raw) - window_size:
        if not first_segment_found:
            diff_full = np.abs(raw - most_common_val)
            first_fluct_indices = np.where(diff_full >= 3)[0]
            if len(first_fluct_indices) == 0:
                break
            first_fluct_index = first_fluct_indices[0]

            if first_fluct_index < 30:
                found_stable = False
                for i in range(first_fluct_index + 1, len(raw) - stable_check_len):
                    next_block = raw[i:i + stable_check_len]
                    if np.all(np.abs(next_block - most_common_val) < 1e-3):
                        current_index = i + stable_check_len
                        found_stable = True
                        break
                if not found_stable:
                    break
            else:
                current_index = first_fluct_index - 30
            first_segment_found = True
            continue

        found = False
        for i in range(current_index, len(raw) - window_size):
            window = raw[i:i + window_size]
            diff = np.abs(window - most_common_val)
            fluct_indices = np.where(diff >= 3)[0]

            if len(fluct_indices) >= 1:
                center = i + int(np.mean(fluct_indices))
                if center - segment_half_len >= 0 and center + segment_half_len < len(raw):
                    segment = raw[center - segment_half_len:center + segment_half_len]
                    segments.append(segment)
                    current_index = center + segment_half_len
                    found = True
                    break
        if not found:
            break

    if segments:
        for segment in segments:
            all_segments.append([multiplier[0]] + segment.tolist())

# 保存为CSV
if all_segments:
    np.savetxt("Data/sequence_Circuit_data/32_Booth_250M/data_test2/combined_traces.csv", all_segments, delimiter=',', fmt='%s')
    print(f"数据已保存为 combined_traces.csv，共 {len(all_segments)} 条记录")
else:
    print("没有提取到足够的波形数据") 