import pandas as pd
import numpy as np

# ====== Step 1: 加载 CSV 文件 ======
csv_path = "Data/sequence_Circuit_data/32_Booth_250M/data_test2/produced_data/combined_traces.csv"  # 你的CSV路径
df = pd.read_csv(csv_path)

# 提取乘数（二进制字符串）和功耗波形数据
multipliers = df.iloc[:, 0].values
X = df.iloc[:, 1:].values.astype(np.float32)

# ====== Step 2: Booth 编码映射函数 ======
def booth_encode_3bit(bits3):
    if bits3 == '000' or bits3 == '111':
        return 0
    elif bits3 == '001' or bits3 == '010':
        return 1
    elif bits3 == '011':
        return 2
    elif bits3 == '100':
        return 3
    elif bits3 == '101' or bits3 == '110':
        return 4
    else:
        return -1  # 异常

def booth_labels_from_multiplier(mult_bin, cycles=16):
    # 正确处理：末尾补 0，从低位往高位编码
    bin_str = mult_bin.replace('0b', '') + '0'  # y[-1] = 0

    labels = []
    for i in range(cycles):
        idx = 2 * i
        if idx + 3 <= len(bin_str):
            bits3 = bin_str[idx:idx + 3]  # 从低位向高位提取
            labels.append(booth_encode_3bit(bits3))
        else:
            labels.append(0)  # 补 0 或忽略

    return labels

# ====== Step 3: 生成标签矩阵 ======
Y = np.array([booth_labels_from_multiplier(m) for m in multipliers], dtype=np.int64)
Y = np.flip(Y, axis=1)  # 将标签从 LSB → MSB 排列

print(f"X shape: {X.shape}")           # (num_samples, 140)
print(f"Y shape: {Y.shape}")           # (num_samples, 16)

# ====== Step 4: 可选保存为 npy 文件 ======
np.save("Data/sequence_Circuit_data/32_Booth_250M/data_test2/produced_data/X_traces.npy", X)
np.save("Data/sequence_Circuit_data/32_Booth_250M/data_test2/produced_data/Y_booth_labels.npy", Y)
print("保存完成：X_traces.npy, Y_booth_labels.npy")
