一个点：要是让这个图不要在pycharm中显示，而是弹出来，那就在“Settings | Tools | Python Scientific | Show Plots in Toolwindow，去掉”

`import matplotlib.pyplot as plt`

x, y的值可以是列表，也可以是numpy和tensor

[常见25个matplotlib图](https://mp.weixin.qq.com/s/JM3BMedF4A3JwhUT98LD4A)

[又来四十个](https://mp.weixin.qq.com/s/csrQkUtr22dTa9b6WvDZ-g)

或者又来50个，[原地址](https://www.machinelearningplus.com/plots/top-50-matplotlib-visualizations-the-master-plots-python/)，翻译成[中文](https://www.heywhale.com/mw/project/5f4b3f146476cf0036f7e51e/content)的地址，项目使用的[数据地址](https://www.heywhale.com/mw/dataset/5f4f6d4e3a0788003c4df2ce/file)，这需要注册登录一个叫和鲸社区。



```python
"matplotlib中的颜色" 
cmap = plt.get_cmap('tab20b')   # 里面可以放其它颜色，就成了渐变，看下面的补充连接
print(cmap, type(cmap))
# 或者一个固定常用的写法
cmap = plt.get_cmap('rainbow')

colors = [cmap(i) for i in np.linspace(0, 1, 20)]
print(colors)

bbox_color = random.sample(colors, 10)
print(type(bbox_color[0]))
print(tuple(map(lambda x: int(x*255), bbox_color[0][:3])))
```

看一下[这里](https://wangyeming.github.io/2018/11/07/matplot-cmap/)做补充。

### 1、散点图（scatter）

```python
plt.scatter(x, y, c = (0, 0, 0.8), s=30, alpha=0.5，edgecolors='none')  
#s设置点的大小; #颜色c可自定义RGB(0~1之间)；alpha是透明度
```

点默认蓝色+黑色的轮廓，这个参数就是不要轮廓，数据点特别多的时候使用，少的时候加上效果好

##### 连续的图(.plot)

```python
plt.plot(x, y, '+', c="red") 
#给color是一样的;这个 ‘.’一定要紧随x,y坐标之后
```

##### 散点图颜色映射

```python
x = list(range(1, 501))
y = [i**2 for i in x]
plt.scatter(x, y, c=y, cmap=plt.cm.Oranges, s=10, edgecolors='none')
```

这是颜色映射，c给的是一堆值，那一堆值最好是从小到大，这样图就是连续渐变的一定要和cmap一起使用，值小的点颜色浅，值大的颜色深。

```python
data = np.array([[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]])
label = [0, 1, 2, 3, 4]
colors = ['#ff0000', '#ffff00', '#00ff00', '#00ffff', '#0000ff']

plt.subplot(1, 2, 1)
for i in range(5):
    plt.plot(data[i], data[i], '.', c=colors[i])   #这是centerloss里的画法
plt.legend(['1', '2', '3', '4', '5'], loc='upper left')

plt.subplot(1, 2, 2)
plt.scatter(data[:, 0], data[:, 1], c=label)  
plt.legend(['1', '2', '3', '4', '5'], loc='upper left')
plt.show()
```

但是也可以不要cmap，但这样一般就是c = target，target一般是(0, 1, 2)这种类别(可以是无序的，数据也是无序的，但是要一一对应起来)，那么数据对对应自己的类别就是一种颜色，**不同类别颜色不同**(不给cmap就是系统默认；可以先写错，看有哪些值，需要注意的是，别用Oranges这类。不然就跟上面颜色映射差不多了)，但是这还是是指一幅图，注意两者的不同：

```Python
from sklearn.cluster import KMeans

data = np.random.randn(1000, 2)
cls = KMeans(n_clusters = 8)
pre = cls.fit_predict(data)
plt.scatter(data[:, 0], data[:, 1], c=pre, cmap='twilight')
print(pre)  #注意这个是无序的，data也是无序的，但两者是一一对应起来的
print(cls.cluster_centers_)  #获取各类的中心点
plt.show()
```



subplot,有意思的地方

```python
import numpy as np
import matplotlib.pyplot as plt

# Generate random data
data = np.random.rand(100)

# Plot in different subplots
fig, (ax1, ax2) = plt.subplots(1, 2)
ax1.plot(data)

ax2.plot(data)

ax1.plot(data+1)

plt.show()
```

### 2、折线图（plot）



```python
plt.plot(x, y, color="red", linewidth=12, linestyle=":", label="经济走势图", marker='o')
# （":""-""--""-."，线型有这4种）(marker='o'，可突出转折点，可选择的值跟plot画散点图是一样的)
plt.legend(loc="upper left")  # （必须有这行，才能显示上面的label，括号里的是显示label的位置）
plt.legend(loc="best")  # 自己找最好的位置
plt.show()
```

##### 关于legend()

```python
plt.scatter(x, y, c='b', s=15, label="data")
# 注意这些 label的内容是显示图例在图上，搭配legend一起的，这里有了legend里面就不用放东西了
plt.plot(x_test, y_1, color='r', label='max_depth=1')
plt.plot(x_test, y_2, color='y', label='max_depth=3')
plt.plot(x_test, y_3, color='black', label='linear_model')
plt.xlabel("data")
plt.ylabel("target")
plt.title("Decision Tree Regression", fontdict={'size': '16', 'color': 'orange'})
# 可以这样来设置字体大小及颜色，上面也是同理

plt.legend()  # 上面有了label，括号里就不用放东西了；且散点图默认在折线图之后；它会自动找最优的位置
# plt.legend(['max_depth=1', 'max_depth=3', 'linear_model', 'data'], loc = 'upper left')
# 上面你两行类似，如果画图时没有给 label ，可以自己后面手动添加(注意顺序)
```

### 3、柱状图(及并列柱状图)

#### bar()     barh()  是横着的那种

并列柱状图就是两组数据放一起对比

tick_label这个参数能改变x轴的显示

```python
name_list = ["A","B","C","D"]
num_list = [10,8,5,9]               #注意两个要一样长

x = list(range(len(name_list)))      #bar里x的位置可以是range(4)或range(len(name_list))或[0,1,2,3]；这里是为了下一个柱状图加宽度时循环好用
plt.bar(x, num_list, width=0.4, color="r", tick_label=name_list)
#可以直接给range(4):横轴; 给值；柱子宽度，默认0.8；颜色：红绿蓝黄，首字母，个数不够就自动循环；横轴标签

num_list1 = [9,2,1,11]
for i in range(4):                     #这里是将第二个柱状图的位置移动一点
    x[i]+=0.4                           #注意这个加的宽度与柱状图一样，不然会重合或有间隙
plt.bar(x, num_list1, width=0.4, color="y", tick_label=name_list)     #注意这句不能放进循环里
plt.legend()        #将两个柱状图放在一起
plt.show()
```

"""给柱状图上加上数字"""   #结合上面的数据看

#### 加文字

```python
plt.rcParams["font.sans-serif"] = ["simHei"] （给个字体，使用汉字才能显示出来）
for x, y in enumerate(num_list):
      plt.text(x, y+5, y, ha="center", va="bottom")             #在柱状图上显示具体数值, ha参数控制水平对齐方式, va控制垂直对齐方式
     #(前面两个值是控制位置+5只是让位置好看，可调，y代表多少数值；记清enumerate的作用)
 
from matplotlib.font_manager import fontManager
for i in fontManager.ttflist:
    print(i.name, i.name)  # 这就获取了所有的字体
plt.rcParams["font . sans-serif"] = ["字体"] # 上面的一些字体放进去就好了
```

#### 显示负号

```python
plt.rcParams["axes.unicode_minus"] = False     # 正常显示负号
```

### 4、饼状图（pie）

饼状图也可以不用给颜色，系统会自动分配

```python
name_list = ["A","B","C","D"]
num = [12,30,50,8]           #尽量加起来等于1，不然就会自动分配，就不是预想值了
ex = [0,0,0.1,0]            #有值得那个，代表那一块脱离出来，表示重点突出
plt.axis(aspet=1)         #画个一等分的圆
plt.pie(x=num, autopct="%.3f%%", explode=ex, labels=name_list, colors="rgby", shadow=True, startangle=15)
# 3代表3位小数；    #注意这里面给颜色的关键词是colors     阴影，有立体感；角度，合适即可  
plt.show()
```

### 5、直方图（hist）

```python
plt.hist(IOUS, bins=20, density=0, facecolor="red", edgecolor="black")
 """绘制直方图
        data: 必选参数，绘图数据
        bins: 直方图的长条形数目，可选项，默认为10
        density: 是否将得到的直方图向量归一化，可选项，默认为0，代表不归一化，显示频数。
        normed = 1，表示归一化，显示频率。
        facecolor: 长条形的颜色
        edgecolor: 长条形边框的颜色
        alpha: 透明度"""
```

### 6、动态变化图

##### 有移轴的方法

```python
x = np.linspace(-30,30,60) # 给出很多数
w = -5
	
plt.ion() #1 打开图形 为了使图形不一闪而过
for i in range(50):
	plt.clf() #3 清除上一条线的轨迹，没有就是每处出现的线都会停留，就有很多线
	y = w*x
	plt.xlim(-20,20) #4(限制x,y的坐标范围)
	plt.ylim(-80,80)
	plt.plot(x,y) # 要注意这要在下面坐标变换之前

	ax = plt.gca()
	ax.spines["right"].set_color("none") # 6这两行是让那里的两条线消失，可以去试试看
	ax.spines["top"].set_color("none") #6 这之前一定要先限制x,y坐标
	
	ax.spines["left"].set_position(("data",0)) # 5这两行是让坐标原点移动到中间(注意这要限制x、y的值是对称的)
	ax.spines["bottom"].set_position(("data",0)) #5
	plt.pause(0.1) #2 暂停0.1秒
	w+=1
plt.ioff() #1 关闭图形
```

##### plt中给汉字字体

```
plt.rcParams["font.sans-serif"] = ["simHei"]
```

```python
import matplotlib.pyplot as plt
from matplotlib.font_manager import fontManager
for i in fontManager.ttflist :
	print(i.name , i.name) # 这就获取了所有的字体
plt.rcParams["font . sans-serif"] = ["字体"] # 上面的一些字体放进去就好了
```

### 7、subplot()

取出MNIST数据集中前25个数，并在一个图上表示

```python
import matplotlib.pyplot as plt
import torchvision as tv
datasets = tv.datasets.MNIST("datasets/", train=True, download=False)

for i in range(25):
	plt.subplot(5, 5, i+1) #(5,5,10)代表分为5行5列，第10个图(从左至右，由上而下数) (用这个时，之前千万不要plt.clf()。)
	plt.imshow(datasets.data[i], cmap="Accent") # plt中imshow,将矩阵数据转换为图像 . # cmap是设置背景颜色，可以先输错，下面会提示有哪些
	plt.title(datasets.targets[i].item()) # 或者						plt.title(int(（datasets.targets[i]）) )
	plt.axis("off") # 关掉轴
	plt.xticks([])
	plt.yticks([]) # 这两行也是关掉轴（与上面二选一即可）
plt.show() # show()放最后循环外
```

```python
# 有时候为了横轴上字体倾斜，不重在一起了
plt.xticks(range(len(x), x), rotation=45)   # 这是角度倾斜，前面是分组距吧，用的时候看
```

##### 改变轴刻度范围

```python
plt.axis([0, 20, 0, 210])  
#四个值，x轴最小/大值；y轴最小/大值
```

##### 改变轴刻度字体大小

```python
plt.tick_params(axis='both', labelsize=14) 
#可以单给x, y
```

##### 给轴标签

```python
plt.xlabel('Value', fontsize=14)  
```

##### 保存图片

```python
plt.savefig('456.png', bbox_inches='tight')  
#保存图片，后面这个参数只是将多余的空白裁剪掉
```

##### 时间长坐标

画图时有时间坐标，且坐标很长有覆盖时

```python
import matplotlib.pyplot as plt
from random import choice
from datetime import datetime  #画图时x有日期这种的时候建议把x中标像这样转化一下，

dates = []
datas = []
for i in range(1, 15):
    date = '2020-03-{}'.format(10+i)
    date = datetime.strptime(date, '%Y-%m-%d')  # 将其变成datetime中的一个时间对象
    """ '%Y-' 让 Python 将字符串中第一个连字符前面的部分视为四位的年份； '%m-' 让 Python 将第二个连字符前面的部分视为表示月份的数字；而 '%d' 让 Python 将字符串
的最后一部分视为月份中的一天（ 1~31 ）"""
    dates.append(date)

    temp = choice(list(range(10, 30)))
    datas.append(temp)

fig = plt.figure(figsize=(10, 6))  #设置一下图大小
plt.plot(dates, datas)

fig.autofmt_xdate()   #这个是关键，让时间坐标斜起来不覆盖

plt.show()
```

重点是fig = plt.figure(）；fig.autofmt_xdate()；以及要把x的时间格式改成datatime 的格式

```python
from datetime import datetime

""" '%Y-' 让 Python 将字符串中第一个连字符前面的部分视为四位的年份； '%m-' 让 Python 将第二个连字符前面的部分视为表示月份的数字；而 '%d' 让 Python 将字符串
的最后一部分视为月份中的一天（ 1~31 ）"""

具体看下        
```

| 实参 | 含义                              |
| ---- | --------------------------------- |
| %A   | 星期的名称，如 Monday             |
| %B   | 月份名，如 January                |
| %m   | 用数字表示的月份（ 01~12 ）       |
| %d   | 用数字表示月份中的一天（ 01~31 ） |
| %Y   | 四位的年份，如 2015               |
| %y   | 两位的年份，如 15                 |
| %H   | 24 小时制的小时数（ 00~23 ）      |
| %I   | 12 小时制的小时数（ 01~12         |
| %p   | am 或 pm                          |
| %M   | 分钟数（ 00~59                    |
| %S   | 秒数（ 00~61 ）                   |

##### 颜色填充

在两条x值一样，但是y值不一样的折线中间填充颜色

plt.fill_between()

```python
plt.plot(x, y_1, c='red', alpha=0.5)
plt.plot(x, y_2, c='blue', alpha=0.5)

plt.fill_between(x, y_1, y_2, facecolor='blue', alpha=0.1)
```

##### 给每条线的标记

```python
plt.legend(['1', '2', '3', '4', '5'], loc='upper left')
```

用在plt.plot上比较多

### 8、聚类画的轮廓系数图

#### 包含了随机生成一个16进制的颜色

```python
import numpy as np
import matplotlib.pyplot as plt

plt.rcParams["font.sans-serif"] = ["simHei"]
plt.rcParams["axes.unicode_minus"] = False


def Draw(silhouette_avg, sample_silhouette_values, y, k):
    # 创建一个 subplot with 1-row 2-column
    fig, ax1 = plt.subplots(1)
    fig.set_size_inches(18, 7)

    # 第一个 subplot 放轮廓系数点
    # 范围是[-1, 1]
    ax1.set_xlim([-0.2, 0.5])

    # 后面的 (k + 1) * 10 是为了能更明确的展现这些点
    ax1.set_ylim([0, len(sample_silhouette_values) + (k + 1) * 10])

    y_lower = 10

    for i in range(k):  # 分别遍历这几个聚类
        ith_cluster_silhouette_values = sample_silhouette_values[y == i]
        ith_cluster_silhouette_values.sort()
        size_cluster_i = ith_cluster_silhouette_values.shape[0]
        y_upper = y_lower + size_cluster_i

        # 每次随机一个颜色，生成的是RGB，然后转乘十六进制
        color = "#"
        color_num = np.random.randint(255, size=(3,))
        for color_ in color_num:
            hex_str = hex(color_)
            if len(hex_str) == 4:
                color += hex_str[2:]
            else:
                color += hex_str[2:] + "0"

        ax1.fill_betweenx(np.arange(y_lower, y_upper),
                          0,
                          ith_cluster_silhouette_values,
                          facecolor=color,
                          edgecolor=color,
                          alpha=0.7)
        # 在轮廓系数点加上聚类的类别号及个数
        ax1.text(-0.05, y_lower + 0.5 * size_cluster_i, "{}类:{}个".format(i, len(ith_cluster_silhouette_values)),
                 fontdict={'size': '10', 'color': color})
        # 计算下一个点的 y_lower y轴位置
        y_lower = y_upper + 10

    # 在图里搞一条垂直的评论轮廓系数虚线
    ax1.axvline(x=silhouette_avg, color='red', linestyle="--")  # x=横坐标上的一点的值
    ax1.text(0.005, 0.95, "总个数:{}".format(len(sample_silhouette_values)),
             transform=ax1.transAxes, fontdict={'size': '14', 'color': 'orange'})
    ax1.text(0.005, 0.90, "平均轮廓系数:{}".format(round(silhouette_avg, 4)),
             transform=ax1.transAxes, fontdict={'size': '14', 'color': 'orange'})
    plt.xlabel("轮廓系数", fontdict={'size': '12'})
    plt.title("聚类图", fontdict={'size': '16', 'color': 'orange'})

    plt.show()


if __name__ == '__main__':
    k = 4
    silhouette_avg = 0.43125298764496467  # 平均轮廓系数
    sample_silhouette_values = np.array([0.91922182, 0.22907922, 0.15196871, 0.20541037, 0.23250248, 0.95771555,
                                         0.94055218, 0.12501744, 0.17844737, -0.16478621, 0.11131155, 0.9489616,
                                         0.19678223, 0.94595924, 0.2104268, 0.13250568, 0.17998956, 0.22572757,
                                         0.95779809, 0.9404685])  # 每个点的轮廓系数
    # 这是每个点的分类
    catrgory = np.array([2, 0, 0, 0, 0, 3, 1, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 3, 1])
    Draw(silhouette_avg, sample_silhouette_values, catrgory, k)
```

#### 文本位置及subplot的一些

```python
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.collections as collections
t = np.arange(0.0, 2, 0.01)
s1 = np.sin(2*np.pi*t)
s2 = 1.2*np.sin(4*np.pi*t)

fig = plt.figure(figsize=(15, 6))
ax = fig.add_subplot(1, 2, 1)

ax.set_title('using span_where')
# 设置曲线
ax.plot(t, s1, color='black')
# 设置横轴
ax.axhline(0, color='black', lw=2)
# 设置文本，目标位置 左上角，距离 Y 轴 0.01 倍距离，距离 X 轴 0.95倍距离
ax.text(0.01, 0.95, "I am here ", transform=ax.transAxes, fontdict={'size': '16', 'color': 'b'})

collection = collections.BrokenBarHCollection.span_where(
    t, ymin=0, ymax=1, where=s1 > 0, facecolor='green', alpha=0.8)
ax.add_collection(collection)

collection = collections.BrokenBarHCollection.span_where(
    t, ymin=-1, ymax=0, where=s1 < 0, facecolor='red', alpha=0.5)
ax.add_collection(collection)
"""
ax2 
"""
ax2 = fig.add_subplot(1, 2, 2)

ax2.set_title('using span_where')
ax2.plot(t, s1, color='black')
ax2.axhline(0, color='black', lw=2)
# 设置文本，目标位置 左上角，距离 Y 轴 1.91 倍距离（这里说明它是以最左边为轴，需要自行调节），距离 X 轴 0.95倍距离
ax2.text(1.91, 0.95, "I am here too", transform=ax.transAxes, fontdict={'size': '16', 'color': 'b'})

collection = collections.BrokenBarHCollection.span_where(
    t, ymin=0, ymax=1, where=s1 > 0, facecolor='green', alpha=0.8)
ax2.add_collection(collection)

collection = collections.BrokenBarHCollection.span_where(
    t, ymin=-1, ymax=0, where=s1 < 0, facecolor='red', alpha=0.5)
ax2.add_collection(collection)
plt.show()
```

