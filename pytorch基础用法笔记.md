
## 一、初始化

### 1.和numpy之间的转换



```python
import torch
import numpy as np

a = np.array([1,2,3])
b = torch.from_numpy(a)
print(b,b.shape,b.size(),b.dtype)

c = np.ones([2,3])
d = torch.from_numpy(c)
print(d, d.shape, d.size(),d.dtype)

```

    tensor([1, 2, 3], dtype=torch.int32) torch.Size([3]) torch.Size([3]) torch.int32
    tensor([[1., 1., 1.],
            [1., 1., 1.]], dtype=torch.float64) torch.Size([2, 3]) torch.Size([2, 3]) torch.float64


### 2.Tensor


```python
a = torch.tensor([1,2,3])
b = torch.Tensor(1,2,3)
c = torch.FloatTensor(2,3)

print(a, a.shape)
print(b, b.shape)
print(c, c.shape)
```

    tensor([1, 2, 3]) torch.Size([3])
    tensor([[[0., 0., 0.],
             [0., 0., 0.]]]) torch.Size([1, 2, 3])
    tensor([[0.0000e+00, 0.0000e+00, 1.4013e-45],
            [0.0000e+00, 1.4013e-45, 0.0000e+00]]) torch.Size([2, 3])


### 3.空张量函数 torch.empty()


```python
a = torch.empty(3,4)
b = torch.empty([3,4])
c = torch.empty(1)

print(a, a.shape)
print(b, b.shape)
print(c, c.shape)
```

    tensor([[0., 0., 0., 0.],
            [0., 0., 0., 0.],
            [0., 0., 0., 0.]]) torch.Size([3, 4])
    tensor([[0., 0., 0., 0.],
            [0., 0., 0., 0.],
            [0., 0., 0., 0.]]) torch.Size([3, 4])
    tensor([0.]) torch.Size([1])


### 3.张量类型函数 .type()



```python
a = torch.tensor([1,2,3])
print(a,a.shape, a.type())
```

    tensor([1, 2, 3]) torch.Size([3]) torch.LongTensor


### 4.修改默认类型 torch.set_default_tensor_type()


```python
torch.set_default_tensor_type(torch.DoubleTensor)
```

### 5.是否存在gpu


```python
USE_GPU = torch.cuda.is_available()
print(USE_GPU)
```

    False


### 6.随机初始化函数
    rand:0,1之间均匀分布
    randint 区间内的均匀分布
    randn: 标准正态分布
    normal：正态分布
    arange：等差数列
    linspace:等分函数
    logspace：指数等分函数
    ones:全1张量
    zeros：全0张量
    eye:主对角线1，其他0
    full:填充函数
    rand_like,ones_like等：形状复制函数


```python
torch.manual_seed(1111)

a = torch.rand(2,3)
b = torch.rand_like(a)
c = torch.randint(1, 10, (3,3))
d = torch.randn(2,3)
e = torch.normal(mean=torch.full([10], 0), std=torch.arange(1, 0, -0.1))
f = torch.full([3,5], 3)
g = torch.arange(0, 10, 0.5)
h = torch.arange(0,10) #默认差为1 
i = torch.linspace(0, 10, steps = 10)#分10个数
j = torch.linspace(0, 10, steps = 11)
k = torch.logspace(0, 3, steps = 10)
w = torch.logspace(0, 3, steps = 5)#0-1000分成5个数

x = torch.ones(2,3)
y = torch.zeros(2,3)
z = 4 * torch.eye(3,4)
z1 = torch.eye(4)
print('a:', a, a.shape)
print('b:', b, b.shape)
print('c:', c, c.shape)
print('d:', d, d.shape)
print('e:', e, e.shape)
print('f:', f, f.shape)
print('g:', g, g.shape)
print('h:', h, h.shape)
print('i:', i, i.shape)
print('j:', j, j.shape)
print('k:', k, k.shape)
print('w:', w, w.shape)
print('x:', x, x.shape)
print('y:', y, y.shape)
print('z:', z, z.shape)
print('z1:', z1, z1.shape)
```

    a: tensor([[0.6848, 0.4076, 0.6384],
            [0.8568, 0.1162, 0.4980]]) torch.Size([2, 3])
    b: tensor([[0.9974, 0.1557, 0.7186],
            [0.5031, 0.0849, 0.4178]]) torch.Size([2, 3])
    c: tensor([[3, 8, 8],
            [1, 5, 9],
            [9, 1, 8]]) torch.Size([3, 3])
    d: tensor([[-2.0809, -0.5108,  0.1621],
            [-1.0225, -2.5722, -1.0523]]) torch.Size([2, 3])
    e: tensor([ 0.9259,  0.0640,  0.7742, -1.1569,  0.4221,  0.1038, -0.7610, -0.5172,
             0.0906, -0.1325]) torch.Size([10])
    f: tensor([[3., 3., 3., 3., 3.],
            [3., 3., 3., 3., 3.],
            [3., 3., 3., 3., 3.]]) torch.Size([3, 5])
    g: tensor([0.0000, 0.5000, 1.0000, 1.5000, 2.0000, 2.5000, 3.0000, 3.5000, 4.0000,
            4.5000, 5.0000, 5.5000, 6.0000, 6.5000, 7.0000, 7.5000, 8.0000, 8.5000,
            9.0000, 9.5000]) torch.Size([20])
    h: tensor([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) torch.Size([10])
    i: tensor([ 0.0000,  1.1111,  2.2222,  3.3333,  4.4444,  5.5556,  6.6667,  7.7778,
             8.8889, 10.0000]) torch.Size([10])
    j: tensor([ 0.,  1.,  2.,  3.,  4.,  5.,  6.,  7.,  8.,  9., 10.]) torch.Size([11])
    k: tensor([   1.0000,    2.1544,    4.6416,   10.0000,   21.5443,   46.4159,
             100.0000,  215.4435,  464.1589, 1000.0000]) torch.Size([10])
    w: tensor([   1.0000,    5.6234,   31.6228,  177.8279, 1000.0000]) torch.Size([5])
    x: tensor([[1., 1., 1.],
            [1., 1., 1.]]) torch.Size([2, 3])
    y: tensor([[0., 0., 0.],
            [0., 0., 0.]]) torch.Size([2, 3])
    z: tensor([[4., 0., 0., 0.],
            [0., 4., 0., 0.],
            [0., 0., 4., 0.]]) torch.Size([3, 4])
    z1: tensor([[1., 0., 0., 0.],
            [0., 1., 0., 0.],
            [0., 0., 1., 0.],
            [0., 0., 0., 1.]]) torch.Size([4, 4])


### 7.随机种子函数


```python
import torch
import random
import numpy as np

def set_seed(seed=9699): # seed的数值可以随意设置，本人不清楚有没有推荐数值
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    #根据文档，torch.manual_seed(seed)应该已经为所有设备设置seed
    #但是torch.cuda.manual_seed(seed)在没有gpu时也可调用，这样写没什么坏处
    torch.cuda.manual_seed(seed)
    #cuDNN在使用deterministic模式时（下面两行），可能会造成性能下降（取决于model）
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
```

## 二、切片和索引


```python
import torch
torch.manual_seed(1111)
a = torch.rand(4, 3, 28, 28)
b = a[0]
c = a[0,0]
d = a[0,0,2,4]

e = a[:2]
f = a[:2, :1, :, :]
g = a[:2, :-1, :, :]
h = a[:, :, 0:28:2, 0:28:2]
k = a[:, :, ::2, ::2]

w = a.index_select(0, torch.arange(2))
x = a.index_select(0, torch.arange(3))

i = a[...]
j = a[0, ...]
q = a[:,2,...]

print('a', a.shape)
print('b', b.shape)
print('c', c.shape)
print(d.shape)
print(e.shape)
print(f.shape)
print(g.shape)
print(h.shape)
print(k.shape)
print(w.shape)
print(x.shape)
print(i.shape)
print(j.shape)
print(q.shape)
```

    a torch.Size([4, 3, 28, 28])
    b torch.Size([3, 28, 28])
    c torch.Size([28, 28])
    torch.Size([])
    torch.Size([2, 3, 28, 28])
    torch.Size([2, 1, 28, 28])
    torch.Size([2, 2, 28, 28])
    torch.Size([4, 3, 14, 14])
    torch.Size([4, 3, 14, 14])
    torch.Size([2, 3, 28, 28])
    torch.Size([3, 3, 28, 28])
    torch.Size([4, 3, 28, 28])
    torch.Size([3, 28, 28])
    torch.Size([4, 28, 28])


### 1.mask 函数


```python
torch.manual_seed(1111)
x = torch.randn(3, 4)
print(x)

mask = x.ge(0)

#mask = torch.ByteTensor(x.ge(0))
print(mask,mask.shape)

y = torch.masked_select(x, mask)

print(y,y.shape)
```

    tensor([[-0.4078, -0.9385, -1.2721, -1.5061],
            [ 0.8749,  0.7828,  0.5817, -0.0094],
            [-0.2317, -1.1598,  0.8955,  0.5291]])
    tensor([[False, False, False, False],
            [ True,  True,  True, False],
            [False, False,  True,  True]]) torch.Size([3, 4])
    tensor([0.8749, 0.7828, 0.5817, 0.8955, 0.5291]) torch.Size([5])


### 2.take()函数


```python
a = torch.tensor([[1, 2, 3],[4, 5, 6]])
print(a, a.shape)
b = torch.take(a, torch.tensor([0, 2, 5]))
print(b, b.shape)
c = torch.take(a,torch.tensor([1-5]))
print(c,c.shape)
```

    tensor([[1, 2, 3],
            [4, 5, 6]]) torch.Size([2, 3])
    tensor([1, 3, 6]) torch.Size([3])
    tensor([3]) torch.Size([1])


## 三、维度变换
    view/reshape
    Squeezze/unsqueeze
    Transpose/t/permute
    Expand/repeat

### 1.view/reshape


```python
import torch
a = torch.rand(4, 1, 28, 28)
b = a.view(4, 28*28)
c = a.reshape(4, 28 ,28)
d = a.reshape(4*28, 28)

print(a.shape)
print(b.shape)
print(c.shape)
print(d.shape)
```

    torch.Size([4, 1, 28, 28])
    torch.Size([4, 784])
    torch.Size([4, 28, 28])
    torch.Size([112, 28])


### 2.squeeze/unsqueeze


```python
a = torch.Tensor(4, 1, 28, 28)# 0-4, -1:-5

b = a.unsqueeze(0)
c = a.unsqueeze(-1)
d = a.unsqueeze(4)
e = a.unsqueeze(-4)
f = a.unsqueeze(-5)

print(a.shape)
print(b.shape)
print(c.shape)
print(d.shape)
print(e.shape)
print(f.shape)

x = torch.tensor([1, 2, 3])
y = x.unsqueeze(-1)
z = x.unsqueeze(0)

print(x, x.shape)
print(y, y.shape)
print(z, z.shape)

```

    torch.Size([4, 1, 28, 28])
    torch.Size([1, 4, 1, 28, 28])
    torch.Size([4, 1, 28, 28, 1])
    torch.Size([4, 1, 28, 28, 1])
    torch.Size([4, 1, 1, 28, 28])
    torch.Size([1, 4, 1, 28, 28])
    tensor([1, 2, 3]) torch.Size([3])
    tensor([[1],
            [2],
            [3]]) torch.Size([3, 1])
    tensor([[1, 2, 3]]) torch.Size([1, 3])



```python
w1 = torch.rand(4, 32, 14, 14)
b = torch.rand(32)

b1 = b.unsqueeze(0).unsqueeze(2).unsqueeze(3)

b2 = b1.squeeze()
b3 = b1.squeeze(0)
b4 = b1.squeeze(-1)
b5 = b1.squeeze(1)#不变
b6 = b1.squeeze(-4)

print(w1.shape)
print(b.shape)
print(b1.shape)
print(b2.shape)
print(b3.shape)
print(b4.shape)
print(b5.shape)
print(b6.shape)
```

    torch.Size([4, 32, 14, 14])
    torch.Size([32])
    torch.Size([1, 32, 1, 1])
    torch.Size([32])
    torch.Size([32, 1, 1])
    torch.Size([1, 32, 1])
    torch.Size([1, 32, 1, 1])
    torch.Size([32, 1, 1])


### 3. expand/repeat


```python
a = torch.rand(4, 32, 14, 14)
b = torch.rand(1, 32, 1, 1)

b1 = b.expand(4, 32, 14, 14)
b2 = b.expand(-1, 32, 14, -1)  # -1表示不变
b3 = b.expand(-1, 32, -1, -4)  #-4是不存在的，这里是bug

b4 = b.repeat(4, 32, 1, 1)
b5 = b.repeat(4, 1, 1, 1)
b6 = b.repeat(4, 1, 32, 32)

print(b1.shape)
print(b2.shape)
print(b3.shape)
print('\n')
print(b4.shape)
print(b5.shape)
print(b6.shape) 
```

    torch.Size([4, 32, 14, 14])
    torch.Size([1, 32, 14, 1])
    torch.Size([1, 32, 1, -4])


​    
    torch.Size([4, 1024, 1, 1])
    torch.Size([4, 32, 1, 1])
    torch.Size([4, 32, 32, 32])


### 4.transpose/permute/.t


```python
torch.manual_seed(1111)
a = torch.rand(4, 3, 28, 32)

b = a.transpose(1, 3)
c = a.transpose(1, 3).transpose(1, 2)
d = a.permute(0, 2, 3, 1)

x = torch.randn(3, 4)
y = x.t()

print(a.shape)
print(b.shape)
print(c.shape)
print(d.shape)
print('\n')
print(x.shape)
print(y.shape)
```

    torch.Size([4, 3, 28, 32])
    torch.Size([4, 32, 28, 3])
    torch.Size([4, 28, 32, 3])
    torch.Size([4, 28, 32, 3])


​    
    torch.Size([3, 4])
    torch.Size([4, 3])


## 四、拼接和拆分
    cat :合并  维度不变
    stack：合并 维度增加
    split：拆分 等长拆分
    chunk：拆分 数量拆分

### 1. cat和stack


```python
a1 = torch.rand(4, 3, 32, 32)
a2 = torch.rand(5, 3, 32, 32)
a3 = torch.rand(4, 1, 32, 32)
a4 = torch.rand(4, 3, 32, 32) 

b1 = torch.cat([a1, a2], dim=0)
b2 = torch.cat([a1, a3], dim=1)
b3 = torch.cat([a1, a4], dim=2)
b4 = torch.cat([a1, a4], dim=3)

b5 = torch.stack([a1, a4], dim=0)
b6 = torch.stack([a1, a4], dim=2)
print(b1.shape)
print(b2.shape)
print(b3.shape)
print(b4.shape)
print('\n')
print(b5.shape)
print(b6.shape)
```

    torch.Size([9, 3, 32, 32])
    torch.Size([4, 4, 32, 32])
    torch.Size([4, 3, 64, 32])
    torch.Size([4, 3, 32, 64])


​    
    torch.Size([2, 4, 3, 32, 32])
    torch.Size([4, 3, 2, 32, 32])


### 2. split


```python
a = torch.rand(32, 8)
b = torch.rand(32, 8)

c = torch.stack([a, b], dim=0)

c1, c2 = c.split(1, dim=0)
c3, c4 = c.split([1, 1], dim=0)
c5, c6, c7, c8 = c.split(8, dim=1)
c9, c10 = c.split([20, 12], dim=1)

print(c.shape)
print(c1.shape, c2.shape)
print(c3.shape, c4.shape)
print(c5.shape, c6.shape, c7.shape, c8.shape)
print(c9.shape, c10.shape)
```

    torch.Size([2, 32, 8])
    torch.Size([1, 32, 8]) torch.Size([1, 32, 8])
    torch.Size([1, 32, 8]) torch.Size([1, 32, 8])
    torch.Size([2, 8, 8]) torch.Size([2, 8, 8]) torch.Size([2, 8, 8]) torch.Size([2, 8, 8])
    torch.Size([2, 20, 8]) torch.Size([2, 12, 8])


### 3. chunk


```python
a = torch.rand(32, 8)
b = torch.rand(32, 8)

c = torch.stack([a,b], dim=0)

c1, c2 = c.chunk(2, dim=0)
c3, c4, c5 = c.chunk(3, dim=2) 

print(c.shape)
print(c1.shape, c2.shape)
print(c3.shape, c4.shape, c5.shape)
```

    torch.Size([2, 32, 8])
    torch.Size([1, 32, 8]) torch.Size([1, 32, 8])
    torch.Size([2, 32, 3]) torch.Size([2, 32, 3]) torch.Size([2, 32, 2])


## 五、基本运算
    + - * /  add\sub\mul\div
    matmul\@\mm(2D)
    ** \pow
    sprt\ rsqrt
    floor\ceil\trunc\frac\round

### 1.加减乘除


```python
torch.manual_seed(1111)
a = torch.rand(3, 4)
b = torch.rand(4)

c = a + b
c1 = a.add(b)
c2 = torch.add(a, b)

c4 = torch.all(torch.eq(a-b, torch.sub(a, b)))
c5 = torch.all(torch.eq(a*b, torch.mul(a, b))) 
c6 = torch.all(torch.eq(a/b, a.div(b)))

print(c)
print(c1)
print(c2)
print('\n')
print(c4, c5, c6)
```

    tensor([[1.3353, 0.8036, 1.1954, 0.8062],
            [1.8295, 1.3168, 0.8766, 1.3536],
            [1.3892, 1.5311, 0.7067, 1.3846]])
    tensor([[1.3353, 0.8036, 1.1954, 0.8062],
            [1.8295, 1.3168, 0.8766, 1.3536],
            [1.3892, 1.5311, 0.7067, 1.3846]])
    tensor([[1.3353, 0.8036, 1.1954, 0.8062],
            [1.8295, 1.3168, 0.8766, 1.3536],
            [1.3892, 1.5311, 0.7067, 1.3846]])


​    
    tensor(True) tensor(True) tensor(True)


### 2. 矩阵乘法


```python
torch.manual_seed(1111)
a = 3 * torch.ones(2, 2)
b = torch.ones(2, 2)

c = torch.mm(a, b)
c1 = torch.matmul(a, b)
c2 = a @ b

x = torch.rand(4, 3, 28, 64)
y = torch.rand(4, 3, 64, 128)
y1 = torch.rand(4, 1, 64, 128)

z1 = torch.matmul(x, y)
z2 = torch.matmul(x, y1)

print(c)
print(c1)
print(c2)
print('\n')
print(z1.shape)
print(z2.shape)
```

    tensor([[6., 6.],
            [6., 6.]])
    tensor([[6., 6.],
            [6., 6.]])
    tensor([[6., 6.],
            [6., 6.]])


​    
    torch.Size([4, 3, 28, 128])
    torch.Size([4, 3, 28, 128])


### 3. 指数函数


```python
import torch
torch.manual_seed(1111)
a = torch.full([2, 2], 3)

b = a.pow(2)
c = a.pow(0)
b1 = a**2
b2 = (a**2).sqrt()
b3 = (a**2).rsqrt() # 平方根倒数
b4 = a**2**(0.5) 
print(b, '\n', c, '\n', b1, '\n', b2, '\n', b3, '\n', b4)
```

    tensor([[9., 9.],
            [9., 9.]]) 
     tensor([[1., 1.],
            [1., 1.]]) 
     tensor([[9., 9.],
            [9., 9.]]) 
     tensor([[3., 3.],
            [3., 3.]]) 
     tensor([[0.3333, 0.3333],
            [0.3333, 0.3333]]) 
     tensor([[4.7288, 4.7288],
            [4.7288, 4.7288]])


### 4.对数函数


```python
torch.manual_seed(1111)

a = torch.exp(torch.ones(2, 2))
a1 = 2** (torch.ones(2,2)*8)

b = torch.log(a)
c = torch.log2(a1)
print(a)
print(a1)
print(b)
print(c)
```

    tensor([[2.7183, 2.7183],
            [2.7183, 2.7183]])
    tensor([[256., 256.],
            [256., 256.]])
    tensor([[1., 1.],
            [1., 1.]])
    tensor([[8., 8.],
            [8., 8.]])


### 5.近似解
    floor():向下取整
    ceil():向上取整
    trunc():取整数部分
    frac():取小数部分
    round()：四舍五入（0.5 舍去）


```python
a = torch.tensor(3.14)

b = a.floor()
c = a.ceil()
d = a.trunc()
e = a.frac()

x = torch.tensor(3.499)
y = torch.tensor(4.510)

z1 = x.round()
z2 = y.round()

print(a)
print(b)
print(c)
print(d)
print(e)
print('\n')
print(z1)
print(z2)
```

    tensor(3.1400)
    tensor(3.)
    tensor(4.)
    tensor(3.)
    tensor(0.1400)


​    
    tensor(3.)
    tensor(5.)


### 6.取特殊值
    clamp:范围取值，可构造relu函数
    min:最小值
    max：最大值
    median：中间值


```python
torch.manual_seed(1111)
a = torch.rand(2, 3) * 5
a1 = torch.tensor([-1, 2, 3, -4])

b = a.max()
c = a.median()

d = a1.clamp(0) #relu
d1 = a.clamp(10)
d2 = a.clamp(0, 10)

print(a)
print(b)
print(c)
print(d)   
print(d1)
print(d2)
```

    tensor([[2.3030, 0.4249, 4.0047],
            [1.9859, 4.7740, 2.9909]])
    tensor(4.7740)
    tensor(2.3030)
    tensor([0, 2, 3, 0])
    tensor([[10., 10., 10.],
            [10., 10., 10.]])
    tensor([[2.3030, 0.4249, 4.0047],
            [1.9859, 4.7740, 2.9909]])


## 六、统计数据
    norm:范数 1，2
    mean：均值、sum:累加、prod:累乘
    max;最大、min：最小、argmax:最大值对应索引、argmin:最小值对应索引
    topk:较大的几个 kthvalue:较小的几个

### 1.范数


```python
a = torch.full([8], 1)

b = a.view(2, 4)
c = a.reshape(2, 2, 2)

d1, d2, d3 = a.norm(1), b.norm(1), c.norm(1)
e1, e2, e3 = a.norm(2), b.norm(2), c.norm(2)

f1 = b.norm(1, dim=1)
f2 = b.norm(2, dim=1)

h1 = c.norm(1, dim=0)
h2 = c.norm(2, dim=0)

print(a, '\n', b, '\n', c)
print(d1, d2, d3)
print(e1, e2, e3)
print(f1, f2)
print(h1, '\n', h2)
```

    tensor([1., 1., 1., 1., 1., 1., 1., 1.]) 
     tensor([[1., 1., 1., 1.],
            [1., 1., 1., 1.]]) 
     tensor([[[1., 1.],
             [1., 1.]],
    
            [[1., 1.],
             [1., 1.]]])
    tensor(8.) tensor(8.) tensor(8.)
    tensor(2.8284) tensor(2.8284) tensor(2.8284)
    tensor([4., 4.]) tensor([2., 2.])
    tensor([[2., 2.],
            [2., 2.]]) 
     tensor([[1.4142, 1.4142],
            [1.4142, 1.4142]])


### 2.常见取特殊值函数


```python
torch.manual_seed(1111)

a = torch.arange(8).reshape(2, 4).float()

b1, b2, b3, b4, b5, b6, b7 = a.mean(), a.sum(), a.prod(), a.max(), a.min(), a.argmax(), a.argmin()

print(a, '\n', b1,b2,b3,b4,b5,b6,b7)
```

    tensor([[0., 1., 2., 3.],
            [4., 5., 6., 7.]]) 
     tensor(3.5000) tensor(28.) tensor(0.) tensor(7.) tensor(0.) tensor(7) tensor(0)



```python
torch.manual_seed(1111)
a = torch.randn(4, 10)

c1 = a.argmax()
c2 = a.argmax(dim=1)
c3 = a.argmin(dim=0)

d1 = a.max(dim = 1)
d2 = a.argmax(dim=1)
d3 = a.max(dim=1, keepdim=True)
d4 = a.argmax(dim=1, keepdim=True)

e1 = a.topk(3)
e2 = a.topk(3, dim=1)
e3 = a.topk(3, dim=1, largest=False)

f1 = a.kthvalue(3)
f2 = a.kthvalue(3, dim=1)
f3 = a.kthvalue(8, dim=1)

print(a)
print(c1,c2,c3,'\n')
print(d1,'\n',d2,'\n',d3,'\n',d4)
print('\n', e1,'\n', e2,'\n', e3)
print('\n', f1, '\n', f2, '\n', f3)
```

    tensor([[-1.1065,  0.1614, -0.6850,  0.9943,  1.7562, -0.2647, -0.9040, -2.0230,
             -0.1012, -0.3893],
            [ 1.6611, -0.1536, -1.7632, -1.3242,  0.7061,  1.3013, -0.8899, -0.0195,
             -0.5017, -0.0746],
            [-0.8013, -0.0597, -0.6181,  0.0434,  1.3775,  0.2325,  0.5974,  1.6458,
              0.6398, -1.4972],
            [ 0.0246,  0.1690,  0.2091, -0.3026, -0.1032, -0.2076, -0.7478,  1.3935,
              0.4201,  0.2469]])
    tensor(4) tensor([4, 0, 7, 7]) tensor([0, 1, 1, 1, 3, 0, 0, 0, 1, 2]) 
    
    torch.return_types.max(
    values=tensor([1.7562, 1.6611, 1.6458, 1.3935]),
    indices=tensor([4, 0, 7, 7])) 
     tensor([4, 0, 7, 7]) 
     torch.return_types.max(
    values=tensor([[1.7562],
            [1.6611],
            [1.6458],
            [1.3935]]),
    indices=tensor([[4],
            [0],
            [7],
            [7]])) 
     tensor([[4],
            [0],
            [7],
            [7]])
    
     torch.return_types.topk(
    values=tensor([[1.7562, 0.9943, 0.1614],
            [1.6611, 1.3013, 0.7061],
            [1.6458, 1.3775, 0.6398],
            [1.3935, 0.4201, 0.2469]]),
    indices=tensor([[4, 3, 1],
            [0, 5, 4],
            [7, 4, 8],
            [7, 8, 9]])) 
     torch.return_types.topk(
    values=tensor([[1.7562, 0.9943, 0.1614],
            [1.6611, 1.3013, 0.7061],
            [1.6458, 1.3775, 0.6398],
            [1.3935, 0.4201, 0.2469]]),
    indices=tensor([[4, 3, 1],
            [0, 5, 4],
            [7, 4, 8],
            [7, 8, 9]])) 
     torch.return_types.topk(
    values=tensor([[-2.0230, -1.1065, -0.9040],
            [-1.7632, -1.3242, -0.8899],
            [-1.4972, -0.8013, -0.6181],
            [-0.7478, -0.3026, -0.2076]]),
    indices=tensor([[7, 0, 6],
            [2, 3, 6],
            [9, 0, 2],
            [6, 3, 5]]))
    
     torch.return_types.kthvalue(
    values=tensor([-0.9040, -0.8899, -0.6181, -0.2076]),
    indices=tensor([6, 6, 2, 5])) 
     torch.return_types.kthvalue(
    values=tensor([-0.9040, -0.8899, -0.6181, -0.2076]),
    indices=tensor([6, 6, 2, 5])) 
     torch.return_types.kthvalue(
    values=tensor([0.1614, 0.7061, 0.6398, 0.2469]),
    indices=tensor([1, 4, 8, 9]))



```python

```
