import random

def generate_booth_test_data():
    # 定义各种Booth编码模式
    booth_patterns = {
        '+0': ['000', '111'],
        '+1': ['001', '010'],
        '+2': ['011'],
        '-2': ['100'],
        '-1': ['101', '110']
    }
    
    # 确保包含所有模式的模式列表
    required_patterns = [
        '000',  # +0
        '001',  # +1
        '011',  # +2
        '100',  # -2
        '101',  # -1
        '010',  # +1
        '111',  # +0
        '110'   # -1
    ]
    
    # 生成随机模式列表
    patterns = required_patterns.copy()
    
    # 添加随机模式直到达到16组（32位）
    while len(patterns) < 16:
        # 随机选择一个模式
        pattern = random.choice(list(booth_patterns.values()))
        patterns.append(random.choice(pattern))
    
    # 随机打乱模式顺序
    random.shuffle(patterns)
    
    # 将3位模式转换为32位数据
    binary = ''
    for pattern in patterns:
        binary += pattern
    
    # 确保是32位
    binary = binary[:32]
    
    # 转换为十六进制
    hex_value = hex(int(binary, 2))
    
    # 生成Booth编码元组
    booth_values = []
    for i in range(0, 32, 2):
        # 获取3位编码（包括最后一位补0）
        if i + 2 < 32:
            code = binary[i:i+3]
        else:
            code = binary[i:] + '0'
            
        # 根据Booth编码规则转换为数值
        if code in ['000', '111']:
            booth_values.append(0)
        elif code in ['001', '010']:
            booth_values.append(1)
        elif code == '011':
            booth_values.append(2)
        elif code == '100':
            booth_values.append(-2)
        elif code in ['101', '110']:
            booth_values.append(-1)
    
    print(f"生成的32位乘数（二进制）: {binary}")
    print(f"生成的32位乘数（十六进制）: {hex_value}")
    print(f"生成的32位乘数（十进制）: {int(binary, 2)}")
    print(f"Booth编码元组: {booth_values}")
    
    return int(binary, 2)

def generate_multiple_test_data(num_tests=5):
    print(f"\n生成{num_tests}个随机测试数据：")
    print("-" * 50)
    for i in range(num_tests):
        print(f"\n测试数据 {i+1}:")
        generate_booth_test_data()
        print("-" * 50)

if __name__ == "__main__":
    generate_multiple_test_data(16)  # 生成5个随机测试数据