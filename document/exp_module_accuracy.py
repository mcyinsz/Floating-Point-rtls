import numpy as np
import struct
import math

# IEEE754单精度浮点数转换工具
def float_to_bin32(f):
    return bin(struct.unpack('>I', struct.pack('>f', f))[0])[2:].zfill(32)

def bin32_to_float(b):
    return struct.unpack('>f', struct.pack('>I', int(b, 2)))[0]

# 浮点运算模拟（使用IEEE754单精度）
def fp32_mult(a, b):
    a = np.float32(a)
    b = np.float32(b)
    return np.float32(a * b)

def fp32_sub(a, b):
    a = np.float32(a)
    b = np.float32(b)
    return np.float32(a - b)

def fp32_floor(x):
    x = np.float32(x)
    return np.float32(np.floor(x))

# 常量定义（IEEE754格式）
const_zero = 0.0
const_one = 1.0
const_threshold = -87.3365
const_log2e = 1.4426950408889634  # log2(e)

# LUT生成函数（Q0.16格式）
def generate_LUT():
    LUT_base = []
    LUT_slope = []
    for i in range(64):
        # 区间起始点
        x0 = i / 64.0
        y0 = 2.0 ** (-x0)
        
        # 区间结束点
        x1 = (i + 1) / 64.0
        y1 = 2.0 ** (-x1)
        
        # 基值（Q0.16）
        base = int(y0 * (1 << 16))
        LUT_base.append(base)
        
        # 斜率（Q0.16）
        slope = int((y1 - y0) * (1 << 16) * 64)  # 乘以64个区间单位
        LUT_slope.append(slope)
    
    return LUT_base, LUT_slope

# 浮点到Q0.24定点转换
def float_to_q024(f_val):
    if f_val < 0:
        f_val += 1.0  # 处理负小数
    fixed = int(f_val * (1 << 24))
    return fixed & 0xFFFFFF  # 24位掩码

# 主计算函数
def exp_negative_sim(x_val):
    # 特殊值检测
    if x_val == const_zero:
        return const_one
    if x_val <= const_threshold:
        return const_zero
    
    # 计算 t = -x * log2(e)
    neg_x = -x_val
    t = fp32_mult(neg_x, const_log2e)
    
    # 分解 t = n + f
    n_float = fp32_floor(t)
    f_float = fp32_sub(t, n_float)
    
    # 转换f为Q0.24定点数
    f_fixed = float_to_q024(f_float)
    
    # 提取索引和偏移
    index = (f_fixed >> 18) & 0x3F  # 高6位
    offset = f_fixed & 0x3FFFF      # 低18位
    
    # LUT查找
    base = LUT_base[index]       # Q0.16
    slope = LUT_slope[index]     # Q0.16
    
    # 计算 r = base + slope * offset / 2^18
    product = slope * offset     # 34位乘积
    base_24 = base << 8          # 转Q0.24 (16+8=24)
    r = base_24 + (product >> 10)  # 取高24位
    
    # 提取整数n
    n_int = int(np.float32(n_float))
    
    # 构造浮点数结果
    r_val = r / (1 << 24)  # 转回浮点数
    exp_val = 2.0 ** (-n_int) * r_val
    
    return exp_val

# 生成LUT
LUT_base, LUT_slope = generate_LUT()

# 验证函数
def evaluate_precision(start=-10, end=0, num_samples=1000):
    max_error = 0.0
    max_error_x = 0.0
    mae = 0.0
    mse = 0.0
    
    for i in range(num_samples):
        # 在负指数区间采样
        x = start + (end - start) * i / num_samples
        
        # 计算参考值
        ref = math.exp(x)
        
        # 计算模拟值
        sim = exp_negative_sim(x)
        
        # 计算误差
        error = abs(ref - sim)
        rel_error = error / ref if ref != 0 else 0
        
        # 更新统计
        mae += error
        mse += error * error
        if error > max_error:
            max_error = error
            max_error_x = x
    
    mae /= num_samples
    mse /= num_samples
    rmse = math.sqrt(mse)
    
    print(f"最大绝对误差: {max_error:.6e} (x={max_error_x:.4f})")
    print(f"平均绝对误差 (MAE): {mae:.6e}")
    print(f"均方根误差 (RMSE): {rmse:.6e}")

# 执行验证
print("开始精度评估...")
evaluate_precision()
print("评估完成")

# 示例点测试
test_points = [-0.1, -1.0, -2.0, -5.0, -10.0, -20.0, -50.0, -87.0]
print("\n测试点验证:")
print(" x\t\t 参考值\t\t\t 模拟值\t\t\t 绝对误差")
for x in test_points:
    ref = math.exp(x)
    sim = exp_negative_sim(x)
    error = abs(ref - sim)
    print(f"{x:>6.2f}\t{ref:12.8e}\t{sim:12.8e}\t{error:12.3e}")