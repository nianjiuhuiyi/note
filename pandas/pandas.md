注意:data["cate"].values 得到的值是ndarray类型的，
 data["cate"].str  得到的值是字符串，  内容是相同的，但是类型不同，操作也就差别很大

category的一些[坑](https://mp.weixin.qq.com/s/9MU2AKDAzZNhA-Fg4uWN7Q)

简单的一些[API](https://blog.csdn.net/qq_42196922/article/details/90043750) 

把所有的数据都显示出来

```python
import pandas as pd
# 显示所有列
pd.set_option('display.max_columns', None)
# 显示所有行
pd.set_option('display.max_rows', None)
# 设置value的显示长度为300(当一些链接数据比较长时，可给大一些)，默认为50
pd.set_option('max_colwidth', 300)  
```

判断一个dataFrame是不是没有值的方法：`if  dataFrame.empty:`

如果一个dataFrame只有columns的话，是没有任何值的话，以上的判断就是为True



注意：
	有的时候读取excel是会失败，报错：==TypeError: expected <class 'str'>==，这很大概率是因为这个表格是用wps创建的，有差异，需要用office打开，随便点一下再保存，就没问题了。

## Series

```python
import pandas as pd
# 里面也可以给字典
data = pd.Series([4, 7, -5, 3])
data1 = pd.Series([4, 7, -5, 3], index=['a', 'b', 'c', 'd'])
```

## DataFrame

```python
import pandas as pd
data = {'state': ['a', 'ds', 'aw'], 'year': [200, 201, 202], 'pop': [1.5, 1.7, 2.0]}
obj = pd.DataFrame(data, columns=['year', 'pop', 'state'])  # 可以指定顺序，也可以以不给就默认
# 这里的data也可以是 [["aa", 13, 135], ["bb", 14, 173]] 这样的二维列表，然后指定columns

del obj['state']  # 可通过del删除列
# 如果是字典嵌套字典，，那么最外成的键会成为列索引，里面那层字典的键会成为行索引；；结果也可以使用.T 转置这个
```

```python
# 行索引        # 列索引          # 值      # 是没有括号的
obj.index       obj.columns      obj.values     obj.shape 获取行列值  

# 看前几行      # 看后几行
obj.head(2)     obj.tail(3)      # 不给值就是默认为5

# 快速看各列统计值      # 看一些基本信息
obj.describe()         obj.info()
```

### 1. 把DataFrame数据写入CSV、excel文件或读取

也可以用open的方式来写csv文件，每列数据之间用 `,` 号隔开，比如`f.write("{}, {}, ,{}".format(123, 456, 789))` 两个连续的空格中间就会空一列

```python
# 不给的话，就会默认以0、1、2、3作为索引
data = pd.read_csv("123.csv", index_col="name")  # 这就是把指定某一列设为index
data = pd.read_csv("123.csv", index_col=0)  # 针对左上角缺个位置，本来就有index
```



```python
data = pd.read_csv("123.csv")
data.to_csv("another.csv", index=False)  
# 重点是很多时候不要将自动生成的index数字索引写进去了

# 保存成excel
data.to_excel("./results.xlsx", index=False)    # 一定注意后缀是.xlsx，错了不行
# index 代表不要前面的数字index
```

### 2. apply用法

假设data["证券代码"]这一column的值都是"600000.SH"、"600004.SH"这种，然后需要拿到前面的数字代码，就要去掉后面的".SH"，就可以用 apply 这种方法

```python
data["证券代码"] = data["证券代码"].apply(lambda x: x.replace(".SH", ""))
```

### 3. 排序：sort_values

```python
obj = obj.sort_values(by='pop', ascending=False)  # 默认True就是从小到大,现在False就是从大到小
```

Tips：若是多个排序规则，那就是`by=["pop", "age"]`,有多少个就写多少个

### 4. 去重：drop_duplicates

根据某列的重复值，去掉一整行：
	以下这个的意思就是，根据表“comment”这一列，这一列中如果有3个“差评”，5个好评，那么就会保留第一次出现差评和第一次出现好评那两行，其它2行差评和4行好评所在的行会被删除。

> dataFrame.drop_duplicates(subset=[‘comment’], keep=‘first’, inplace=True)   
>
> \# 这一行是把索引重新从小到大排序
> dataFrame.reset_index(drop=True, inplace=True)  # 索引一般是数字，删除行后，这样来一下，使其index连贯顺序  (之前的写法是：dataFrame.index = list(range(dataFrame.shape[0])))

- subset：以列表的形式给要去重的列，可以是多个，默认为None,表示根据所有列进行；
- keep：三个可选参数
  - first：保留第一次出现的重复行，删除后面的重复行（这也是==默认值==）
  - last：删除重复项，保留最后一次出现
  - False：删除所有重复项
- inplace：默认为False,删除重复项后，返回副本，给True，直接在原数据上删除，不用给返回值。（ # 尽量不用inplace，还是用=赋值吧，有些地地方会出现警告）

### 5. 切片索引

```python
obj.loc   # 通过标签索引行数据   # df['a', 'z']  第a行,z列
# loc可以使用切片、名称(index,columns)、也可以切片和名称混合使用
obj.iloc  # 通过位置获取行数据   # df [1, 5]   第1行，第5列  # 只能是数字
```

一定注意：==df.loc[0: 8] ,它是能取到索引为8的那列的，那这里就会有9个值，而不是想象中的8个值==

### 6. 布尔索引

注意：多个条件要用括号括起来

```python
# 使用超过800次的名字
obj[obj["nums"]>800]  
# 若是大于800，小于1000  df[(800<df["nums"]) & (df["nums"]<1000)]   必须用这个，不能是and，或的符号就是  | 
```

#### 6.1 unique

```
# data["info"] 假设就是取的一列，结果一般是一个Serise，假设里面就是很多职业，肯定有重复的，想要拿到所有职业就要去重
career = data["info"].unique()    # 注意结果是一个ndarray类型
		data["info"].nunique()  # 这可以得到去重后的结果的个数
carrer = list(set(data[info].values))   # set也可以，
```

### 7. 数据合并：concat|merge

concat：用法和numpy应该是差不多的，就是两个columns相同的DataFrame上下拼接在一起（一般是纵向）

>results = pd.concat([表1, 表2], ignore_index=True) 
>
>- 默认保留原表索引，ignore_index置为True后，就会重新生成一组从0开始的顺序索引

merge：类似mysql连接查询的合并（一般是横向）

```python
import pandas as pd
# on 就相当于是那个字段
data = pd.DataFrame(
    {'name': ['张三', '孙一', '周七', '李四', '王五', '吴九', '赵六', '王十'],
     'age': [22, 24, 32, 18, 32, 45, 25, 45],
    'gender': [1, 0, 1, 0, 0, 1, 1, 0]}, index = list('abcdefgh'))
data1.merge(data2, how="inner", on="name")   # 交集
data1.merge(data2, how="outer", on="name")   # 并集
data1.merge(data2, how="left", on="name")    # 左连接
data1.merge(data2, how="right", on="name")   # 右连接
```

### 8. 删除指定多行

以下是：当“type”列中的值为“半年报摘要”或是“年报摘要”时，就将其所在列删除

> df = df[~df["type"].isin(["半年报摘要", "年报摘要"])]

- df["type"].isin(["半年报摘要", "年报摘要"]   # 这是找到想要的数据所在行
  - 注意：值是要完全等于给定的，不能是包含，如列中值是“摘要”，就不会被匹配到
- ~ 符号的意思就是取反，那就是选择没有包含这些值得行

删除指定列就是用前面写到的：del df["列名"]

---

以上是通过条件查询，还可以通过索引来删除：

- 删除多行：df.drop(index=["行索引1", "行索引2"], inplace=True)     # 还有两种写法
  		 df.drop(["行索引1", "行索引2"], axis="index", inplace=True)
    		 df.drop(["行索引1", "行索引2"], axis=0, inplace=True)       
- 删除多列：df.drop(columns=["行索引1", "行索引2"], inplace=True)   # 它以下也还有这两种写法

如果是删除单行或者单列，可以直接是 df.drop(index="一个行索引")
或者删除最后几行的话，可以 df = df[:-7]  # 这就是删除最后7行



注意：==删除行后都要去改一下索引==：

```python
# 这一行是把索引重新从小到大排序
df.reset_index(drop=True, inplace=True)  # 索引一般是数字，删除行后，这样来一下，使其index连贯顺序  (之前的写法是：dataFrame.index = list(range(dataFrame.shape[0])))
```

### 9. 分组聚合：groupby

```python
# 单个条件
grouped = data.groupby(by="gender").count()  # 后面跟的函数这就是聚合
#或
grouped = data.groupby(by=df["gender"]).count()

# 多个条件,要用列表括起来
grouped = data.groupby(by=["gender", "class_id"]).count()

# 对某几列数据进行分组
# 这种前面筛选了的话，，后面by的里面一定要是data["gender"]这种
out = data["name"].groupby(by=[data["gender"], data["class_id"]])

# 对于groupby后的结果，类似于字典，可以使用循环取出key,values (这个好用一些)
for key, grouped_df in data.groupby(by="gender"):
for key, grouped_df in data.groupby(by=["gender", "class_id"]):    # 这样也是可以的
    key就是按gender分组后的值
    grouped_df就是对应分组下具体的所有值，还可以grouped_df["age"] 这样去取某一列
    grouped_df 就是一个DataFrame了，建议可以 grouped_df.reset_index(drop=True, inplace=True) # 这样就可以让每个分组的列表各自从0开始索引，方便用 grouped_df.loc[5, 列名] 这样的操作 

很多时候这样取了，就成了Series，有点降维了的意思，要想保持还是DataFrame,就要多包一层[]
grouped = data.groupby(by=df[["gender"]]).count()
```

### 10. 索引和复合索引（reset_index）

```python
# 可以通过赋值的方式改变索引
data.index=list(range(8))  或   data = data.reindex(list(range(8)))
data.reset_index(drop=True, inplace=True)  # 用这样的方式更好（重要）
```

```python
# 指定某一列为index
data = data.set_index("name", drop=False)  # 这就是把设为列的那个还保留下来，drop默认是True,是丢掉的。

# 复合索引
data = data.set_index(["name", "age"], drop=False)  # 就是把两个设为索引

# 可以用这来交换索引的等级
data = data.swaplevel()
```

#### 10.1 改变colunms顺序(reindex)

`reindex`还可以用来更换index、colunms的顺序

```python
data = pd.DataFrame({}, index=["b", "c", "a", "d"], columns=[5, 2, 4, 3, 1])
index = sorted(data.index)  # 当然这里面还可以自己制定排序规则
columns = sorted(list(data))   # list(data)得到的就是data的columns的list格式
data = data.reindex(index=index)
data = data.reindex(columns=columns)  # 这就把顺序变了（这是没有inplace参数的）
```

#### 10.2 修改已有的列名

当列名存在时，可以直接修改的：rename   # 要修改的列名写成字典

```python
df.rename(columns={"地址": "住址", "名字": "名称"}, inplace=True)
```

​	这就是把已有的列名"地址"和"名字"改成"住址"、"名称"。

### 11. 读取006之类数时保留0(converters)

​	比如excel中有一列"code"的值是这样的[002, 003, 004, 005]的话，直接读取，pandas是会舍弃掉前面的零的，如果我们想要保留原数据格式，就加一个参数：converters={"code": str}  # 当然这个字典里还可以增加对其它列的处理，以键值对的形式就行。

```python
dataFrame = pd.read_excel(excel_path, converters={"code": str})
```

Tips：还可做更多的处理：converters={'地理区域名称': lambda x:re.sub('#', '\*', x)}  # 这就是用正则，把'地理区域名称'这列中，值中的#换成* 

### 12. 时间序列

```python
import pandas as pd
# pd.data_range()
time = pd.date_range(start="20150901", end="20190630", freq="10D")  # 这就是10天
time = pd.date_range(start="2015/09/01 10:30:12", periods=10, freq="H")   # 要么是start和end一起用，要么是start和periods一起使用

data = pd.DataFrame({}, index=time, columns=list("edc"))   # 可直接用作索引,且大多会这么用

# 一般使用
idnex = pd.date_range("20170101", periods=10)
data = pd.DataFrame(np.random.rand(10), index=index) 

# pd.to_datetime()  # 就是把那些不大好分出来的时间字符串弄出来
data["time"] = pd.to_datetime(data["time"], format="")    # 假设有time这个字段
# 这就是把time时间那格式化一下，一般都不给format，只有时间字符串不大规范时，用python的时间格式化就行
```

#### 12.1 时间重采样

​	数据还是上面的data

```python
# 就是在时间序列作为index时，可以吧时间序列从一个频率转成另外一个频率
data.resample("M")
data.resample("20D").mean()     # 有点分组的味道，后面还可以跟聚合操作

for i in data.index:   # 这是可以循环的，
    print(i)
    print(i.strftime("%Y-%m-%d"))   # 这就把它转成别的格式了
    print(dir(i))    # 可以这样打出它的所有方法
    
# 注：一般这个时候是要先把pd.set_index把时间字段设成索引，才能用时间重采样
```

```python
period = pd.PeriodIndex(year=data["year"], month=data["month"], day=data["day"], hour=data["hour"], freq="H")
# 假设data里是有字段year month day hour，是分开的，就这么去构造，再
data["datetime"] = period  # 这个字段重新赋值
data = pd.set_index("datetime", inplace=True)  # 再设为索引，就可以重采样或是统计了
```

### ps:pandas.sample

注意一点，本来的data是可以完全取值出来的，可是很有可能data.sample()后得到的值，可能是编码方式就给改变了，就会报`UnicodeEncodeError: 'gbk' codec can't encode character`这样的错

（额：好像不是sample的错，值拿去切片索引了，，就会这种情况）



