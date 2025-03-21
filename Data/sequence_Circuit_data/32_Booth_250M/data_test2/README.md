################### data_test_2目录文件说明 ####################
original_data 存放原始能迹数据--->分段能迹数据 + 对应乘数
produced_data 存放波形提取数据  以及  转化后的功耗+标签数据
Visualization_data  存放模型可视化结果曲线
NN_SCA  存放用于执行nnsca的不同模型源码

数据预处理：
0.Plot_data.py              绘制原始数据曲线，观察测量结果
1.segment_data_extended.py  读取分段原始数据，生成.csv文件  包含乘数（二进制）+ 功耗数据
2.Booth_code_extract.py     读取csv文件，生成功耗和标签.npy数据，用于pytorch
