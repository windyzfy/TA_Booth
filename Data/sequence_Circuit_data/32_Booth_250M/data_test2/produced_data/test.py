import numpy as np

# 查看X_traces.npy的形状
X = np.load('Data/sequence_Circuit_data/32_Booth_250M/data_test2/produced_data/X_traces.npy')
print(f"X_traces形状: {X.shape}")

# 查看Y_labels_16cycles.npy的形状
Y = np.load('Data/sequence_Circuit_data/32_Booth_250M/data_test2/produced_data/Y_booth_labels.npy')
print(f"Y_labels形状: {Y.shape}")