## 余弦相似度

```python
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity, pairwise_distances
# pairwise_distances函数是计算两个矩阵之间的距离，
# cosine_similarity函数是计算多个向量互相之间的余弦相似度，
# 这两的参数是一样的  ps:值可以是列表，但得是二维的

可以是:
m1 = [[1, 2, 3]];  m2 = [[4, 5, 6]]
out = cosine_similarity(m1, m2);   out = pairwise_distances(m1, m2)
结果是类似这样 [[0.458]] 的一个值；

也可以是：
values = [[1, 2, 3, 4, 5], [4, 5, 6, 7, 8], [7, 8, 8, 9, 10]]  # 形状(n, m)
out = cosine_similarity(values);     out = pairwise_distances(values)
得到的结果shape是(n,n)；out[0, 0]是第一行跟第一行的结果，out[0, 1]就是第一行跟第二行的结果，out[1, 0]就是第二行跟第一行的结果

1、首先看这里吧，不懂再去看上面
pairwise_distances(values)   # 默认方式得到的就是欧氏距离的值
pairwise_distances(values, metric="cosine")  # 得到的是余弦距离 = 1-余弦相似度
cosine_similarity(values)   # 得到的就是余弦相似度

2、手写一个
vector_a = np.mat(vector_a)
vector_b = np.mat(vector_b)
num = float(vector_a * vector_b.T)
denom = np.linalg.norm(vector_a) * np.linalg.norm(vector_b)
sim = num / denom  # 这也是余弦相似度
```

## 特征处理

### DictVectorizer

```python
# 对字典类型数据进行特征值化
from sklearn.feature_extraction import DictVectorizer

data = [{"city": "北京", "temperature": 100}, {"city": "上海", "temperature": 60}, {"city": "深圳", "temperature": 30}]
dicvec = DictVectorizer(sparse=False)  # 加了这个得到的就不是sparse矩阵了，默认为True

data = dicvec.fit_transform(data)  # 得到的是默认的sparse矩阵(因为scipy的封装)，节约内存，方便读取处理；；就是有值得地方就给索引和值。0的地方不管
print(dicvec.get_feature_names())  # 各列特征值的名称
print(data)    # 若是spare矩阵，可以data.toarray()

data = dicvec.inverse_transform(data)  # 就是把特征值又转换回去 
```

### CountVectorizer

```python
# 对文本数据进行特征值化
# 统计文本中出现的词，及其在一个元素中出现的个数; ps:单汉子、字母不统计
# 一个元素里，可以是逗号隔开，也可以是空格
from sklearn.feature_extraction.text import CountVectorizer
corpus = ["life,is is short, i like python", "lifess is too long, i dislike python"]

counvec = CountVectorizer(stop_words=)  # 还可以给 stop_words 
# 返回词频矩阵
data = counvec.fit_transform(corpus)
data = counvec.fit_transform(corpus).todense()  # 加个这，data就直接是ndarray了
print(counvec.get_feature_names())
print(data.toarray())  # 结果是二维的，因为列表是2个值
```

### TfidfVectorizer

```python
from sklearn.feature_extraction.text import TfidfVectorizer

tfidf = TfidfVectorizer(stop_words="放需要停用的词")
data = tfidf.fit_transform([c1, c2, c3])   # c1、c2、c3各自代表一篇文章，且已经用jieba分好词；
print(tfidf.get_feature_names())
print(data.toarray())   # 得到的应该就是词频矩阵，数值越大的越有用吧(就是重要性越大)
```

和起来常用的TFIDF算法

```python
# 将文本中的词语转换成词频矩阵,矩阵元素 a[i][j] 表示j词在i类文本下的词频
corpus = ["life,is is short, i like python", "lifess is too long, i dislike python"]
vectorizer = CountVectorizer()
data = vectorizer.fit_transform(corpus)  # 得到词频矩阵

计算tfidf
tfidf = transformer.fit_transform(data)
# 获取词袋模型中的所有词语
word = vectorizer.get_feature_names()
# 将tf-idf矩阵抽取出来，元素w[i][j]表示j词在i类文本中的tf-idf权重
weight = tfidf.toarray()
```



```python
    from sklearn.metrics import classification_report  # 函数   分类报告
    from sklearn.metrics import confusion_matrix  # 函数   混淆矩阵

    print(classification_report(y_test_cls, y_pred_cls, target_names=categories))
    print(confusion_matrix(y_test_cls, y_pred_cls))

    # y_test_cls  数据本来的类别  [0 0 3 2 3 1]
    # y_pred_cls  预测类别        [0 0 2 2 3 1]
    # categories  这个也是一个列表，放着各种类别的名字  ["新闻", "财经", "房产", "教育"]   对应上面4个类别
```



## 数据预处理

### 归一化、标准化

```python
from sklearn.preprocessing import MinMaxScaler, StandardScaler

# 归一化  # 只适合传统精确小数据，离群点影响很大
mm = MinMaxScaler()   # 缩放的范围，可以不给，默认是0~1
data = mm.fit_transform([[90, 2, 10], [60, 4, 15], [75, 3, 13]])
print(data)


# 标准化，把原始数据变换到均值为0，方差为1的范围内；x减去均值再除以方差

ss = StandardScaler()
ss.fit_transform("data")
ss.mean_  # 原始数据每列的均值
ss.std_   # 原始数据每列的方差
```

### 缺失值补全

```python
# numpy自带的fillna只能填补np.nan，而此处则可以指定空值的类型。比如? 或N/A
from sklearn.impute import SimpleImputer
# 比如当空值是?时，使用0填充:(策略里还可以是均值mean这些)
sim_imp = SimpleImputer(missing_values="?", strategy='constant', fill_value=0)  # 注意此处，data是如果是0维，则要先变为一维：
# sim_imp = SimpleImputer(strategy="median")
data = sim_imp.fit_transform(data)
```

## 数值降维

```python
from sklearn.feature_selection import VarianceThreshold

# 删低于给定方差阈值的数据
var = VarianceThreshold(threshold=0.0)  # 默认值是0，即删除相同方差的数据;给的这个值就是方差阈值
data = var.fit_transform([[0, 2, 0, 3], [0, 1, 4, 3], [0, 1, 1, 3]])
print(data)  # 第1列和第4列一样的，方差是0就删了
```

```python
from sklearn.decomposition import PCA

# 主成分分析，降维
pca = PCA(n_components=0.9)  # 这种给小数的就是保留90%的特征，一般就是给0.9~0.95吧;还可以给维度数
data = pca.fit_transform([[2, 8, 4, 5], [6, 3, 0, 8], [5, 4, 9, 1]])
print(data)
```

## 结果评价

`"Precision, Recall and F1-Score..."`

```python
from sklearn.metrics import classification_report
# 生成评价报告
y_label_cls = np.array([0, 0, 2, 1, 3, 3])  # 这是这6个数据的真实标签
y_pred_cls = np.array([0, 0, 2, 1, 3, 0])  # 假设这是测试的6个数据得到的预测结果

"Precision, Recall and F1-Score..."
out = classification_report(y_label_cls, y_pred_cls, target_names=["游戏", "体育", "经济", "民生"])     # 可以不给target_names，也就是每类的名字
```

`混淆矩阵：Confusion Matrix...`

```python
# 接着上面的数据
from sklearn.metrics import confusion_matrix
cm = confusion_matrix(y_label_cls, y_pred_cls)
```

