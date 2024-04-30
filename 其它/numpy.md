`import numpy as np`

弧度和度之间的转换，通过两个点算出直线的斜率slope=1,意味着就是45°，那么

np.arctan(slope) * 180 / np.pi     # np.arctan(slope)先求出来的是弧度，然后要转成弧度



100 个 Numpy 闯关小例子，[这里](https://mp.weixin.qq.com/s/mMQcm7ntXmp4PcYv32Vyug)。

### 0. np.info()

用来获取np中函数的说明及一些简单示例：

```python
np.info(np.stack)
```

### 1.stack()与.concatenate()

==数据拼接==：

"""故可以总结，一般来说，如果每个数据是一维，torch和numpy都用.stack()
如果每个数据都是2维以上，用torch.cat(),和numpy.concatenate();
注意括号里可以是类似于(x,y)的元祖，也可以是每个元素是单个数据组成的列表
即类似于是np.stack(list); np.concatenate(list, axis = 0),"""

```python
a = np.array([1, 2, 3])
b = np.array([4, 5, 6])
c = np.array([7, 8, 9])
ls = [a, b, c]
print(ls)

x = np.arange(6).reshape(2, 3)
y = np.arange(6).reshape(2, 3)
print(np.stack((x, y)))  #这会增加维度，变成3维了
print(np.concatenate((x, y)))  #依旧是2维
```

### 1.切片索引

##### [...,2]的意义

```python
a = np.arange(125).reshape(5, 5, 5)
print(a)
print(a[0:4:2, 0])   #索引的时候是可以给步长的
print(a[[0, 3], 4])  #这代表具体到，第一个维度，我只要第0个和第3个(就是针对不连续的，特定的)，然后他们的第4个数(记得那个括号)
# print(a[[0, 3], [2,8]])  #这跟上面同理，就是为了要获取特定的不连续的数据
```

```
print(a[..., 1])  #这就是前面维度不管，只要最后一个维度的第一个数据;;这会降低一个维度，切片嘛
```

```python
x = np.arange(10, 1, -1)  # 起始比末尾大，给个-1倒着来
```

### 2.重复某个维度（repeaet）

```python
x = np.random.randn(2, 4, 3)
print(x)

y = x.repeat(6, axis = 1)  #可以选定复制扩张的维度，这就代表将1轴上的所有都复制为原来的6倍
# y = x.repeat((6, 6, 6, 6), axis = 1)  #这行的意思跟上一行一模一样
# y = x.repeat((3, 2, 4, 8), axis = 1) #选定复制轴后，也可以给一个元祖，但这个元祖的个数必须和所在轴的元素个数一样(这里1轴就有4个元素)，这里就代表第一个复制3次；第二个复制2次，第三个复制4次，第四个复制8次
print(y)
```

### 2. 广播（tile）

```python
x = np.random.randint(0, 10, size = (3, 4, 5))
print(np.tile(x, (1, 2, 3)).shape)  #(3, 8, 15)  
#要在哪个维度上广播几次就是几，不广播的要写1，形状要一样

"""这跟repeat()重复是不一样的"""
y = np.random.randint(0, 10, size = (2,))
print(y)  #[5 4]
print(np.tile(y, 2))  #[5 4 5 4]
print(np.repeat(y, 2)) #[5 5 4 4]
```

### 3.np.random.permute()

==将一组数据无序打乱==：

```python
a = np.arange(40).reshape(4, 2, 5)
x = np.random.permutation(40)  #生成一个一维数组(40个数)，顺序全被打乱,也可将40改成np.arange(20, 50)
y = np.random.permutation(a)  #也可以是一个多维数组，按照第0维度打乱

np.random.permutation(ndaarray)   # 结果是将这个数组或者列表里的数据打乱
```

### 4.np.maximum(x,y)

==多个值同时做大小比较，并行计算==：

```python
x = [1, 2, 3, 4, 5]
y = [2, 4, 1, 3, 6]
print(np.maximum(y, x)) #这种的话，x,y的长度和形状必须一样,对应位置作比较
print(np.maximum(3, x)) #顺序无所谓，长的那个去和那一个值逐一比较，并返回值
```

torch.max跟np.max有点不一样，torch.max可以直接实现np.maximum

### 4.np.max()

==这个max不简单，不要轻易用==：

```python
a = np.arange(24).reshape(2,3,4)
a[0,1,2] = 66     #修改一个参数,一定要看这66的位置
print(a)
print("=============")
b = np.max(a,axis=1)  #还是把这个几行代码运行看看“0”“1”“2”的区别吧
print(b)
```

### 5.tensor 转 ndarray

```python
boxes = []
x1 = torch.tensor(120)
y1 = torch.tensor(200)
x2 = torch.tensor(301)
y2 = torch.tensor(452)       #这只能是一个值的，若是torch.tensor([12, 56])都是不行的
cls = torch.tensor(0.6)
boxes.append([x1, y1, x2, y2, cls])
boxes.append([x1, y1, x2, y2, cls]) #这样是可行的，只要最低维度的那个数是one element tensors
print(boxes)
print(np.array(boxes))

"""所以极度建议就是np.stack(boxes);一般这boxes是一个列表"""
np.array(list)和np.stack(list)效果一模一样；但是如上所说np.array()是有局限性的。
```

ndarray转成list：==.tolist()== 

```python
c = [[1, 2], [3, 4], [5, 6]]
x = np.array(c)
print(x.tolist())
```

### 6.sort() 与 .argsort()

==可按照指定位置的值从小到大排序，返回相对应的索引==：

```python
""".sort()会直接改变当前值,没有返回值"""
a = np.array([[5,4],[3,2],[1,8],[7,9]])
# print(a)
# a.sort(axis = 1) #0是各列自己比较自上而下，从小到大；1是各行之间比较，自左而右，从小到大，默认值是axis = 1  # 慎用，结果很可能不是你想要的那种
# print(a)

""".argsort()，"""
index =  (a[:, 1]).argsort() #注意加一个“负号”，即(-a[:, 1]).argsort(),就是从大到小;也可以将里面的参数descending设置为True
print(a[:, 1])
print(a)
print(index)
print(a[index]) #这样就是每组数据间，整组在排序，就不会打乱每组数据内部的值
```

### 7.np.divide()和np.true_divide()

上面两个是一样的；另外有一个np.floor_divide()是只保留整数 

### 8.np.where(condition, x, y)

==根据condition，满足条件置为x，不满足条件置为y==：

```
比如得到给一组图片加噪声时，所有的像素值都加上一个值20，那有的就会超过255，这时就是：
data = np.whrer(data>255, 255, data)  # 就是说data里的值大于255就置为255，否则就不变
```

```
"""详解：
condition一般是一个比较运算，前面是一个ndarray，后面一个值，得到的结果的形状就是ndarray，值不是x就是y
若只是np.where(condition),得到的结果跟np.nonzero(condition)一模一样；他们的结果都可以直接当做索引去取值，
例如：x = np.arange(27).reshape(3, 3, 3)，
print(x[np.where((x>5))])
print(x[np.nonzero(a>5)])
print(x[x>5])                这三个得到的结果一模一样，且都是一维的；有时候可以直接用那个简单的代替，但有的情况是不行的"""
```

#### np.where(x>3)

这是获取x中大于3的值的索引，，针对其它二维及以上建议使用==torch.nonzero()==获取索引

```
"""针对(n,1)的形状"""
x = np.array([6, 2, 3, 4, 5, 2, 1, 4]).reshape(-1, 1)
index = np.where(x>3)[0]
print(index)

"""针对一维数据"""
x = np.array([6, 2, 3, 4, 5, 2, 1, 4])
index = np.where(x>3)[0]
print(index)
```

​	Tips：在与opencv结合使用时，==可能在使用了np.where后数据类型是int32,而导致后续操作opencv时报错，可能是imshow时，所以用完后，后面跟个.astype("float32")或uint8==。

#### np.argwhere()

==获取所有非零元素或满足条件的值的索引==：

```python
a = np.array([[1,2,3,4],[5,6,7,8]])
index = np.argwhere(a>3)
print(index)  # 结果就就是array，里面的值共5个，都是满足的索引
或者
print(np.argwhere([0, 1, 2, 0, 5]))  # 这得到的就是1,2,5这些非零值的索引
```

#### np.clip()

跟where差不多，一坑会简洁一些：

> Examples
> --------
> >>> a = np.arange(10)
> >>> np.clip(a, 1, 8)
> >>> array([1, 1, 2, 3, 4, 5, 6, 7, 8, 8])
> >>>
> >>> a
> >>> array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
> >>> np.clip(a, 3, 6, out=a)
> >>> array([3, 3, 3, 3, 4, 5, 6, 6, 6, 6])
> >>>
> >>> a = np.arange(10)
> >>> a
> >>> array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
> >>> np.clip(a, [3, 4, 1, 1, 1, 4, 4, 4, 4, 4], 8)
> >>> array([3, 4, 2, 3, 4, 5, 6, 7, 8, 8])

### 9.astype()

==转数据类型==：

```python
x = x.astype("float32")
x = x.astype("uint8")
x = x.astype(np.int64)
```

### 10. 0、1矩阵

```python
a = np.zeros(shape=[4,10],dtype=np.float32)
print(a)
b = np.ones(shape=[4,10],dtype=np.float32)
print(b)
c = np.empty(shape=[4,10],dtype=np.float32)      #empty()表示：跟最近的内存空间上数据一样，前面没有就是随机生成一个
print(c)

d = np.eye(3)  #生成的是单位矩阵，行列式为1
```

### 11. 矩阵相乘

```python
print(a.dot(b))
print(a@b)    #两个是一个意思
print(a.T)   #就是得到a 的转置矩阵 
```

### 12.transpose() 与 swapaxes()

==交换轴==：

```python
a = np.arange(24).reshape(2, 3, 4)
b = a.transpose((2,0,1))  #要括号，且要写上所有轴的顺序
c = np.swapaxes(a, 2, 0)  #换的轴不要括号，指定两轴之间交换
print(b.shape)  #记不大清时，就np开头
print(c.shape)
```

### 13.随机数|各种分布

随机种子：
	在生成随机数前加上np.random.seed(1);就会将后面生成的随机数全部固定，即无论运行多少次，每次都相同。

```python
a = np.random.randint(0, 10, size = (5,5))  #生成0~10范围内的整数(包括0但不包括10)

b = np.random.randn(3, 3)  #标准正态分布
b = np.random.normal(1, 5, 100)  #生成指定的正态分布(1为对称轴，5为y上最大幅度，共100个数)

c = np.random.raemnd(5,5)    #也可以只放一个数字，唯独这不要括号
c = np.random.random((4,3))
c = np.random.ranf((3,3))     #上面三个都是0~1之间的均匀分布
c = np.random.uniform(-1,1,100)  #指定均为分布
```

### 15.random.sample()

==随机取样==：

```python
rndom.sample(range(12), k =5)    #从第一个参数(列表，元组里)随机取出k个不重复的数
```

```python
np.random.sample(5, size=3, replace=False)  # 从[0, 5)之间取3个数,replace默认是True：有放回取样(就可能会重复); False：不放回取样，没有重复

np.random.sample(['a', 'b', 'c'], 2, replace=False, p=[0.5, 0.3, 0.2]) # p是用来生成一个不均匀的样本，相当于带权重
```

### 16. 打印零元素索引（nonzero）

```python
print(np.nonzero(a))          # 打印a中非零元素的索引
print(np.nonzero(a-1))      # 打印a中零元素的索引
```

### 17.floor()与ceil()

==取整==：

```python
ny.floor()       #向下取整
ny.ceil()      #向上取整

import math
math.floor(1.2)   #向下取整
math.ceil(1.3)  # 结果是2，向上取整
```

###  18.增减轴

.squeeze()减轴

```python
x = np.random.randint(10, size = (5,1,3,1,4))
y = x.squeeze()  #减少对应轴，且该轴值为1，否则不会改变；也可不给轴，那就是默认去掉所有值为1的轴
```

加轴

```python
x = np.random.randint(10, size = (5,1,3,1,4))
z = x[:, np.newaxis, :, np.newaxis, :, np.newaxis]这就是在对应位置加轴加轴;
z = x[:, None, :, None, :, None] #这里的None同np.np.newaxis
print(z.shape)   #(5, 1, 1, 1, 3, 1, 1, 4)
#当所加的轴在最开始或最后时，可以结合[None, ...] [..., None]这去
```

但是都能通过reshape达到想要的效果，结果是一样的，已测试。

新增一个：假设 input_img 的形状是(3, 256, 256)

```python
input_img = np.expand_dims(input_img, 0)  # 现在的shape就是(1, 3, 256, 256)
# input_img = input_img[np.newaxis, ...]   # 这种也是可以的
```

### 19.mean()|std()

a = np.array([1, 2, 3])

==求均值==：numpy和pytorch求均值都是要求那个通道均值，就给哪个维度

```python
x = torch.randn(2, 3, 5, 5)    
# print(x)
print(x.mean(dim = 1).shape)
print(x.mean(dim = (0, 2, 3)))  #做采样时，这样就是除了c全做mean，剩下值的个数就是3了
```

==求标准差==：

- np.std(a)   # 结果是0.816496580927726  因为这个公式中，求完和，是除以n并不是除以n-1
- np.std(a, ddof=1)  # 结果是1.0  这里就是除以的 n-ddof,即n-1， 这严格意义算是标准差的公式，更多的一个解释说明可以看看[这里](https://blog.csdn.net/zbq_tt5/article/details/100054087)。

==求方差==：（标准差就是方差开算术平方根来的）

- np.var(a)   # 结果是 0.6666666666666666 ，开算术平方根就是 0.816496580927726
- np.var(a, ddof=1)  # 这个就是同上了

### 20.np.split()

```python
x = np.random.randn(4, 10, 10, 3)
images = np.split(x, 4, axis = 0)  # 4是分成的份数，后面是在那个轴上分；得到的是list
```

### 21. np.linspace

==生成ndarray==：

```python
a = np.linspace(0, 2, 10)   # 0到2之间平均分成10份的数，能取到2
print(a)
```

### 22.Nan说明

==首先声明任何nan是不等于nan的==。

​	所以假设有一个数组是a，那么可以a != a，统计结果中有多少个True,那就是有多少个nan，np.count_nonzero(a!=a);

​	也可以直接是np.count_nonzero(np.isnan(a))

获取非空的值：values = values[~np.isnan(values)]  # 通过 ~ 来取反

### 23. save && load

numpy.save(file, arr, allow_pickle=True, fix_imports=True)

后面两个参数用默认值即可，allow_pickle:布尔值,允许使用Python pickles保存对象数组，fix_imports:为了方便Pyhton2中读取Python3保存的数据

np.save：保存单个数组为一个文件

```python
a = np.arange(5 * 6 * 7).reshape((5, 6, 7))
np.save("123", a)  # 就会得到 “123.npy” 文件，会自己加后缀名 .npy
# 加载
data = np.load("123.npy")
```

np.savez：保存多个数组为一个文件

```python
x = np.arange(5 * 6 * 7).reshape((5, 6, 7))
y = np.sin(x)
# 一、注意这传参
np.savez("datas", x, y)  # 这会得到 "datas.npz"
datas = np.load("datas.npz")
print(datas["arr_0"])   # 这种就是 arr_0 代表x, arr_1 代表y,key就是系统给的

# 二、推荐使用这（自己指定key的名子，方便后面load时使用）
np.savez("key_datas", x=x, sin_x=y)  # 这会得到 "key_datas.npz"
datas = np.load("key_datas.npz", allow_pickle=True)
print(datas["x"])   # 这种就是 x 就是上面自己指定的x的key
print(datas["sin_x"])   # sin_x就是上面自己指定的y的key
```

Tips：

- 如果加载出来的datas，不知道它的key的话，就把datas当字典来处理：keys = list(datas.keys())  # 这样就能拿到它所有key，或者 for key, value in datas.items():  也是可以用的
- 对于外界打包的.npz，可能要加上参数allow_pickle=True才能够查看数据;
- .npz就是一个压缩文件，它其实是前面save的多个.npy文件压缩而来的，可以通过解压软件打开查看的。

### 24. delete

返回删除指定数据后的数组，==不改变原数组==。有点替代mask的味道

```python
import numpy as np
arr = np.array([[1,2,3,4], [5,6,7,8], [9,10,11,12]])
arr1 = np.delete(arr, 1, axis=0)  # 返回删除第index为1的行的数组
arr2 = np.delete(arr, [0, 3], axis=0) # 返回删除第index为[0,3]行的数组
# axis = 1 就是按列删除

# 其它使用方式
arr3 = np.delete(arr, [1,3,5], axis=None)
# arr3: array([ 1,  3,  5,  7,  8,  9, 10, 11, 12])  # 变一维了
```

