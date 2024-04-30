`import torch`
torch.cuda.empty_cache()

[这是](https://mp.weixin.qq.com/s/Q9AMwGNV9fLaRZws4oaW4g)pytorch的几十个常用操作代码片段，用到时可以来看看。

## 1.stack()与.cat()  

###  数据拼接

"""故可以总结，一般来说，如果每个数据是一维，torch和numpy都用.stack()如果每个数据都是2维以上，用torch.cat(),numpy.concatenate();注意括号里可以是类似于(x,y)的元祖，也可以是每个元素是单个数据组成的列表即类似于是torch.stack(list);torch.cat(list, dim = 0)"""

```python
a = torch.tensor([1, 2, 3])
b = torch.tensor([4, 5, 6])
c = torch.tensor([7, 8, 9])
ls = [a, b, c]
print(ls)
print(torch.stack(ls)) #堆叠
print(torch.cat(ls, 0)) #续接
#这俩的相反操作是torch.split()和torch.chunk()

x = torch.arange(6).view(2, 3)
y = torch.arange(6).view(2, 3)
ls= [x, y]
print(torch.stack((x, y))) #这会增加维度，变成3维了
print(torch.cat((x, y))) #依旧是2维
print(123)
print(torch.stack(ls))
print(torch.cat(ls))
```

## 2.expand()与.repeat()

### 重复某个维度数据

```python
x = torch.randn(2,1,5)  #若这里是(2, 2, 5),都不能使用extend去扩张复制为(2, 4, 5)
print(x)
y = x.expand(2, 4, 5)  #注意，toech.extend();这里的形状维度必须和原tensor一样，且其只能扩张所在维度为1的tensor；
print(y)
z = x.repeat(1, 2, 1)  #torch.repeat(),里面的形状也要跟原tensor一样，里面的数字代表所在维度复制为原来的几倍
print(z)
```

## 3.eq() lt() gt() le() ge()

### 比较

eq:等于，gt:大于，lt:小于，ge:大于等于，le:小于等于，

```python
x = torch.Tensor([9., 4., 7., 6., 0., 3., 2., 8., 5., 1.]).view(10, 1)
result = torch.lt(x, 5) #结果返回的是所有值和5比较后的布尔值(小于5为True)  
也可以两个对比值都是tensor:
print(torch.lt(torch.Tensor([[1, 2], [3, 4]]), torch.Tensor([[1, 1], [4, 4]])))
```

## 4.masked_select(y, mask)

### 通过掩码选定数据

```python
x = np.random.permutation(40)
x1 = torch.Tensor([9., 4., 7., 6., 0., 3., 2., 8., 5., 1.]).view(10,1)
y = torch.Tensor(x).view(10, 4)
mask = torch.gt(x1, 5)
print(mask)
print(y)
print(torch.masked_select(y, mask)) #前面是被筛选的数据，后面是掩码，一定是这顺序
#注意两个的第一个维度数目必须一样，一般mask都是(n,1)的布尔值，然后前面y可以是(n,m),m不用确定的二维的
#注意：最终结果会被拉成一维的，按顺序每m个为y中第0维度的1组数据
```

### .index_select()

#### 通过指定索引获取数据

可搭配torch.histc()使用；注意这个一定就只是去取东西，也可以作为索引的label比元数据长，但是值不能超过其长度，因为是作为索引去取值，那么就能够按照标签规律去扩长原数据。

```python
""".idnex_select()"""
x = torch.tensor([1, 2, 3, 4, 5])
print(x.index_select(dim = 0, index = torch.tensor([0, 2, 4]))) #[1, 3, 5]

x = torch.tensor([[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]])
print(x.index_select(dim = 0, index = torch.tensor([1]))) #[[6, 7, 8, 9, 10]]
print(x.index_select(1, torch.tensor(1)))  #[[2], [7]]
# index_select通过给的索引index按照给的dim获前面x取值，注意类似于切片，不会降低维度。
# 给的作为索引的tensor的数据一定要.long()一下，类似于.float()

""".histc  统计不重复元素的个数"""
label = torch.tensor([1, 0, 2, 1, 0, 1, 2]).float()
count = torch.histc(label, bins = int(max(label).item() + 1), min = int(min(label).item()), max = int(max(label).item()))
#bins是不重复元素的种类，一般是标签来，因为有0，所以就是其最大值+1；min和max就是最小/大值；注意这的数据类型不能是long,参数都得是int，不一定要item()，只是保险
print(count) #[2., 3., 2.]
#注意得到的结果是按照给的标签的里面从小到大的顺序给的，这里即按照(0,1,2)的个数来给的
#就是因为上面的特性，常与.index_select()一起用，但是标签中的数一定要连续，即类似(0, 1, 2, 3)，不能是(0, 2, 3)这种,
```

## 5.torch.nonzero(a )

### 得到非0值的索引

"""二维及以上推荐使用这，且不是(n, 1)这样的二维"""；一维及(n,1)这样建议使用np.where(a>3)去获取满足条件的索引。

```python
a = torch.tensor([[1,2],[0,3],[1,6]])
print(torch.nonzero(a))  #结果是(5,2)得到a中所有的非0索引。结果维度同a
```

### mask掩码使用

```python
x = torch.randn(2,13,13,3,15)  #假设这的意义是(n, h, w , c, iou+偏移率+分类)，想YOLO
mask = x[..., 0]>0
print(mask.shape)  #（2, 13, 13, 3）,上面是通过最后一个维度的第0个值去看

indexes = torch.nonzero(mask)    #根据最后一个维度来，这种索引的形状一定是前面三个那种
values = x[mask]

print(indexes.shape)   #(m, 4)  m是代表有不定的很多个，后面的4就代表了n,h,w,c所在维度的值
print(values.shape)   #(m, 15)  上下这两个m的值一样大，后面的15就代表了最后那个维度的所有特征
```

## 6.tensor转ndarray

### 把单个tensor组成的一个列表，再把这样的多个列表放进一个列表中，可以直接转成numpy

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
```

```python
print(torch.tensor(c)) 或者c = torch.from_numpy(c)        # c是ndarray转torch的tensor
```

## 7.argsort()

### 可按照指定位置的值从小到大排序，返回相对应的索引

```python
"""还有.argmax()   .argmin()获取最大值，最小值索引"""

a = torch.tensor(([[5,4],[3,2],[1,8],[7,9]]))
index =  (a[:, 1]).argsort() #注意加一个“负号”，即(-a[:, 1]).argsort(),就是从大到小;也可以将里面的参数descending设置为True
print(a[:, 1])
print(index)
print(a)
print(a[index]) #这样就是每组数据间，整组在排序，就不会打乱每组数据内部的值
```

## 8.torch.abs()

###  取所有值的绝对值

```python
x = torch.tensor([1, -1, -2])
print(torch.abs(x))   #[1, 1, 2]
```

## 9.torch.where(condition, x, y)

根据condition,满足条件置为x，不满足条件置为y详解可去参考numpy的,但是注意：torch.nonzero()跟这个不太一样；上面的x,y也要是tensor

## 10.tensor()与Tensor()

```python
x1=torch.tensor(3)   结果是tensor(3)     #数据是整形
x2 = torch.Tensor(3)   结果是tensor([a,b,c])     #a,b,c是三个随机数,且数据是浮点型
```

## 11. one_hot编码

### torch.scatter()

```python
x = torch.zeros(5,5)
print(x)
index = torch.randint(5,(5,1))
print(index)
x = torch.scatter(x,1,index,20)     #(需要修改的tensor；轴；索引(类型为tensor)；重新填入的值)
print(x)
```

```python
torch.nn.functional.one_hot()
```

## 12. unsqueeze 与squee

### 增减轴

```python
a = torch.randint(10,(5,1,1,5))
a = torch.unsqueeze(a,dim =1)    #unsqueeze，对应轴位置增加一个维度

a = torch.squeeze(a,dim =2)      #squeeze,减少对应轴，且该轴值为1，否则不会改变；也可不给轴，那就是默认去掉所有值为1的轴
```

## 13. numel()

### 获取tensor的个数

ndarray就是直接x.size,注意没括号

```python
x = torch.randn(3, 4, 5)
print(x.numel())
```

## 14.随机种子

随机种子打开后，得到的x是一定的，哪怕是后面关掉随机种子运行几次后，再打开随机种子，得到的数据还是第一次打开随机种子得到的数据

```python
torch.manual_seed(0)
x = torch.randn(3, 3)
```

## 15.clamp()

### 将一组值至于一定范围内

​	黑图片加噪点的时候也可以用这个诶，加完噪点后的图片值可能会超，直接就是torch.clamp(data, 0, 255)

```python
y = torch.tensor([1, 2, 3, 4, 5, 6, 7, 8])
print(torch.clamp(y, min = 3, max = 6))
#将tensor压缩到[min, max]范围内，本就在范围内的不变，小于的置为min，大于的置为max;;可以只给min或max
```

- 实现原理：

  ```c++
  float clamp(float value, float min, float max) {
      return std::max(min, std::min(max, value));
  }
  ```

## 16. randperm()

### 返回一组从0到k-1的打乱的tensor

```python
x = torch.randperm(k)  #k只能是一个常数
print(x)
```

## 17.torch.topk()

### 求tensor中某维度的前k大或者前k小的**值**以及对应的索引(就是这顺序，先值后索引)

```python
x = torch.randn(1, 1, 10)
value, index = torch.topk(x, k=5, dim=-1)
"""
k：指明是得到前k个数据以及其index
dim： 指定在哪个维度上排序， 默认是最后一个维度
largest：默认为True，按照大到小排序； 如果为False，按照小到大排序
"""
```

## 18.torch.multinomial()

### 按照权重进行取值，返回索引

所以在一堆概率值里，概率大的被选中的概率也大

```python
weights = torch.Tensor([[0, 10, 3, 0]])
print(torch.multinomial(weights, 2))  # 2就是采样2次
# 对weights这个数组进行n次采样，采样的权重也是weights，所以结果是[2,1]的概率比[1,2]的概率大很多，多试几次
# 这种是有放回的采样，每次采样后放回再采样
```

## 19.torch.gather()

### 通过索引，按照某维度取值

```python
a = torch.Tensor([[1, 2], [3, 4]])
index = torch.tensor([[1, 1], [1, 0]])  # 索引必须是tensor
print(torch.gather(a, dim=1, index))  #[[2., 2.], [4., 3.]]  # 这两个形状一定要统一，可以是一维的
```

