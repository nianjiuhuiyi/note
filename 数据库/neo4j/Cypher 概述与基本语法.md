# Cypher 概述与基本语法

## 1、Cypher概述

Cypher是一种声明式图数据库查询语言，它具有丰富的表现力，能高效地查询和更新图数据。

Cypher借鉴了SQL语言的结构——查询可由各种各样的语句组合。

例如，下面是查找名为'John'的人和他的朋友的朋友。

```cql
MATCH (john {name: 'John'})-[:friend]->()-[:friend]->(fof)
RETURN john.name, fof.name
```

 接下来在语句中添加一些过滤。给定一个用户名列表，找到名字在列表中的所有节点。匹配他们的朋友，仅返回他们朋友的name属性以'S'开头的用户。

```cql
MATCH (user)-[:friend]->(follower)
WHERE user.name IN ['Joe', 'John', 'Sara', 'Maria', 'Steve'] AND follower.name =~ 'S.*'
RETURN user.name, follower.name
```

### 模式(Patterns)

 Neo4j图由节点和关系构成。节点可能还有标签和属性，关系可能还有类型和属性。节点和关系都是简单的低层次的构建块。单个节点或者关系只能编码很少的信息，但模式可以将很多节点和关系编码为任意复杂的想法。

 Cypher查询语言很依赖于模式。只包含一个关系的简单模式连接了一对节点。例如，一个人LIVES_IN在某个城市或者某个城市PART_OF一个国家。使用了多个关系的复杂模式能够表达任意复杂的概念，可以支持各种有趣的使用场景。例如，下面的Cypher代码将两个简单的模式连接在一起：

```cql
(:Person)-[:LIVES_IN]->(:City)-[:PART_OF]->(:Country)  
```

 像关系数据库中的SQL一样，Cypher是一种文本的声明式查询语言。它使用ASCII art的形式来表达基于图的模式。采用类似SQL的语句，如MATCH，WHERE和DELETE，来组合这些模式以表达所预期的操作。

------

### 节点语法

 Cypher采用一对圆括号来表示节点。如：(), (foo)。下面是一些常见的节点表示法：

```cql
()
(matrix)
(:Movie)
(matrix:Movie)
(matrix:Movie {title: "The Matrix"})
(matrix:Movie {title: "The Matrix", released: 1997})
```

```cql
match (matrix:Movie {title: "The Matrix"}) return matrix
```

![节点.png](https://upload-images.jianshu.io/upload_images/16503917-c69b25f22a4a115c.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

------

### 关系语法

 Cypher使用一对短横线(即“--”)表示：一个无方向关系。有方向的关系在其中一端加上一个箭头(即“<--”或“-->”)。方括号表达式[…]可用于添加关系信息。里面可以包含变量、属性和或者类型信息。关系的常见表达方式如下：

```cql
--
-->
-[role]->
-[:ACTED_IN]->
-[role:ACTED_IN]->
-[role:ACTED_IN {roles: ["Neo"]}]->
```

```cql
# 找出"Hugo Weaving"参演的电影
match (n:Person{name:"Hugo Weaving"})-[r:ACTED_IN]->(m) return n,r,m
```

![关系.png](https://upload-images.jianshu.io/upload_images/16503917-378992a495a67e4b.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

### 模式语法

将节点和关系的语法组合在一起可以表达模式。

```cql
(keanu:Person {name: "Keanu Reeves"})-[role:ACTED_IN {roles: ["Neo"]}]->(matrix:Movie {title: "The Matrix"})
```

------

### 事务

 任何更新图的查询都运行在一个事务中。一个更新查询要么全部成功，要么全部失败。Cypher或者创建一个新的事务，或者运行在一个已有的事务中：

- 如果运行上下文中没有事务，Cypher将创建一个，一旦查询完成就提交该事务。
  - 如果运行上下文中已有事务，查询就会运行在该事务中。直到该事务成功地提交之后，数据才会持久化到磁盘中去

------

### 兼容性

 Cypher不是一成不变的语言。新版本引入了很多新的功能，一些旧的功能可能会被移除。如果需要，旧版本依然可以访问到。这里有两种方式在查询中选择使用哪个版本：

- 为所有查询设置版本：可以通过neo4j.conf中cypher.default_language_version参数来配置Neo4j数据库使用哪个版本的Cypher语言。
- 在查询中指定版本：简单地在查询开始的时候写上版本，如Cypher 2.3。

## 2、cypher基本语法

### 1、类型

Cypher处理的所有值都有一个特定的类型，它支持如下类型：

- 数值型
- 字符串
- 布尔型
- 节点
- 关系
- 路径
- 映射(Map)
- 列表(List)

### 2、表达式

- Cypher中的表达式如下：
- 十进制（整型和双精度型）的字面值：13, -4000, 3.14, 6.022E23
- 十六进制整型字面值（以0x开头）：0x13zf, 0xFC3A9, -0x66eff
- 八进制整型字面值（以0开头）：01372, 02127, -05671
- 字符串字面值：'Hello', "World"
- 布尔字面值：true, false, TRUE, FALSE
- 变量：n, x, rel, myFancyVariable
- 属性：n.prop, x.prop, rel.thisProperty
- 动态属性：n["prop"], rel[n.city + n.zip], map[coll[0]]
- 参数：![param,](https://math.jianshu.com/math?formula=param%2C)0
- 表达式列表：['a', 'b'], [1, 2, 3], ['a', 2, n.property, $param], [ ]
- 函数调用：length(p), max(p)
- 聚合函数：avg(x.prop), count(*)*
- 路径-模式：(a)-->()<--(b)
- 算式：1 + 2 >3 and 3 < 4.
- 返回true或者false的断言表达式：a.prop = 'Hello', length(p) >10, exists(a.name)
- 正则表达式：a.name =~ 'Tob.*'
- 大小写敏感的字符串匹配表达式：a.surname STARTS WITH 'Sven', a.surname ENDS WITH 'son'
- CASE表达式

### 3、转义字符

Cypher中的字符串可以包含如下转义字符:

| 字符       | 含义                                                     |
| ---------- | -------------------------------------------------------- |
| \t         | 制表符                                                   |
| \b         | 退格                                                     |
| \n         | 换行                                                     |
| \r         | 回车                                                     |
| \f         | 换页                                                     |
| '          | 单引号                                                   |
| "          | 双引号                                                   |
| \          | 反斜杠                                                   |
| \uxxxx     | Unicode UTF-16编码点（4位的十六进制数字必须跟在\u后面）  |
| \Uxxxxxxxx | Unicode UTF-32 编码点（8位的十六进制数字必须跟在\U后面） |

### 4、Case表达式

 计算表达式的值，然后依次与WHEN语句中的表达式进行比较，直到匹配上为止。如果未匹配上，则ELSE中的表达式将作为结果。如果ELSE语句不存在，那么将返回null。

语法：

```cql
CASE test.value
WHEN value1 THEN result1
WHEN value2 THEN result2
[WHEN ...]
[ELSE default]
END AS result
```

例子：

```cql
MATCH (p:Person)
return
CASE p.born
WHEN 1997 THEN 1
WHEN '1942' THEN 2
ELSE 3 END AS result
```

### 5、变量

 当需要引用模式(pattern)或者查询的某一部分的时候，可以对其进行命名。针对不同部分的这些命名被称为变量。例如：

```cql
# 这里的n和b和r就是变量。
MATCH (n)-[r]->(b)
RETURN b 
```

### 6、参数

 Cypher支持带参数的查询。这意味着开发人员不是必须用字符串来构建查询。此外，这也让执行计划的缓存更容易。

 参数能够用于WHERE语句中的字面值和表达式，START语句中的索引值，索引查询以及节点和关系的id。参数不能用于属性名、关系类型和标签，因为这些模式(pattern)将作为查询结构的一部分被编译进查询计划。

 合法的参数名是字母，数字以及两者的组合。下面是一个使用参数的完整例子。参数以JSON格式提供。具体如何提交它们取决于所使用驱动程序。

```cql
{
"name" : "Johan"
}
match (n:Person) where n.name=$name return n
```

### 7、运算符

#### 数学运算符

包括+，-，*，/ 和%，^。

#### 比较运算符

包括=，<>，<，>，<=，>=，IS NULL和IS NOT NULL。

#### 布尔运算符

包括AND，OR，XOR和NOT。

#### 字符串运算符

连接字符串的运算符为+。

正则表达式的匹配运算符为=~。

#### 列表运算符

列表的连接也可以通过+运算符。

可以用IN来检查列表中是否存在某个元素。

#### 值的相等与比较

Cypher支持使用=和<>来比较两个值的相等/不相等关系。同类型的值只有它们是同一个值的时候才相等，如3 = 3和"x" <> "xy"。

#### 值的排序与比较

比较运算符<=，<（升序）和>=，>（降序）可以用于值排序的比较。如下所示：

- 数字型值的排序比较采用数字顺序
- java.lang.Double.NaN大于所有值
- 字符串排序的比较采用字典顺序。如"x" < "xy"
- 布尔值的排序遵循false < true
- 当有个参数为null的时候，比较结果为null。如null < 3的结果为null
- 将其他类型的值相互比较进行排序将报错

#### 链式比较运算

比较运算可以被任意地链在一起。如x < y <= z等价于x < y AND y <= z。如：

```cql
MATCH (n) WHERE 21 < n.age <= 30 RETURN n
```

等价于：

```cql
MATCH (n) WHERE 21 < n.age AND n.age <= 30 RETURN n
```

#### 注释

Cypher语言的注释类似其他语言，用双斜线//来注释行。例如：

```cql
MATCH (n) RETURN n //这是行末尾注释
MATCH (n)
//这是整行注释
RETURN n
MATCH (n) WHERE n.property = '//这不是注释' RETURN n 
```

### 8、模式(Patterns)

 使用模式可以描述你期望看到的数据的形状。例如，在MATCH、CREATE、DELETE等语句中，当用模式描述一个形状的时候，Cypher将按照模式来获取相应的数据。

 模式描述数据的形式很类似在白板上画出图的形状。通常用圆圈来表达节点，使用箭头来表达关系。节点模式

 模式能表达的最简单的形状就是节点。节点使用一对圆括号表示，然后中间含一个名字。例如：

```cql
(a)
//这个模式描述了一个节点，其名称使用变量a表示。
```

#### 关联节点的模式

模式可以描述多个节点及其之间的关系。Cypher使用箭头来表达两个节点之间的关系。例如：

```cql
(a)-->(b)
(a)-->(b)<--(c)
(a)-->()<--(c)
```

#### 标签

模式除了可以描述节点之外，还可以用来描述标签。例如：

```cql
(a:User)-->(b)
(a:User:Admin)-->(b)
```

#### 指定属性

属性在模式中使用键值对的映射结构来表达，然后用大括号包起来。例如，一个有两个属性的节点如下所示：

```cql
(a {name: 'Andres', sport: 'Brazilian Ju-Jitsu'}) 
// 关系中的属性
(a)-[{blocked: false}]->(b)
```

#### 描述关系

 如前面的例子所示，可以用箭头简单地描述两个节点之间的关系。它描述了关系的存在性和方向性。但如果不关心关系的方向，则箭头的头部可以省略。例如：

```cql
(a)--(b)
```

 与节点类似，如果后续需要引用到该关系，则可以给关系赋一个变量名。 

```cql
(a)-[r]->(b)
```

就像节点有标签一样，关系可以有类型(type)。给关系指定类型，如下所示：

```cql
(a)-[r:REL_TYPE]->(b)
```

 不像节点可以有多个标签，关系只能有一个类型。但如果所描述的关系可以是一个类型集中的任意一种类型，可以将这些类型都列入到模式中，它们之间以竖线“|”分割。如：

```cql
(a)-[r:TYPE1|TYPE2]->(b)
```

 注意：这种模式仅适用于描述已经存在的数据（如在MATCH语句中），而在CREATE或者MERGE语句中是不允许的，因为一个关系不能创建多个类型。

 与使用一串节点和关系来描述一个长路径的模式不同，很多关系（以及中间的节点）可以采用指定关系的长度的模式来描述。例如：

```cql
(a)-[*2]->(b)
```

 它描述了一张三个节点和两个关系的图。这些节点和关系都在同一条路径中（路径的长度为2）。它等同于：

```cql
(a)-->()-->(b)
```

 关系的长度也可以指定一个范围，这被称为可变长度的关系。例如：

```cql
(a)-[*3..5]->(b)
```

 长度的边界也是可以省略的，如描述一个路径长度大于等于3的路径：

```cql
(a)-[*3..]->(b) 
```

 路径长度小于等于5的路径，如：

```cql
(a)-[*..5]->(b) 
```

 两个边界都可以省略，这允许任意长度的路径，如：

```cql
(a)-[*]->(b)
```

#### 列表

Cypher对列表(list)有很好的支持。可以使用方括号和一组以逗号分割的元素来创建一个列表。如：

```cql
RETURN [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] AS list 
```



# Cypher语法关键字(一)

# MATCH、OPTIONAL MATCH、WHERE、RETURN

## cypher关键字

cypher关键字可分为三类。

- 读关键字：MATCH、OPTIONAL MATCH、WHERE、START、Aggregation和LOAD CSV
- 写关键字：CREATE、MERGE、SET、DELETE、REMOVE、FOREACH和CREATE UNIQUE
- 通用关键字：RETURN、ORDER BY、LIMIT、SKIP、WITH、UNWIND、UNION和CALL

### 1，MATCH

MATCH关键字用于指定的模式检索数据库的数据。

#### 查找节点



```java
//查询数据库里所有节点
MATCH (n) RETURN n 

//查询带有某个标签的所有节点
MATCH (movie:Movie) RETURN movie

//查询关联节点
MATCH (:Person{ name: 'Lilly Wachowski'})--(movie) RETURN movie.title 
```

#### 查找关系



```java
//关系的方向通过-->或者<--来表示
MATCH (:Person { name: 'Lilly Wachowski' })-->(movie) RETURN movie.title 

//有向关系和变量
MATCH (:Person { name: 'Lilly Wachowski' })-[r]->(movie) RETURN type(r)

//匹配关系类型
MATCH (wallstreet:Movie { title: 'The Matrix' })<-[:ACTED_IN]-(actor) RETURN actor.name

//匹配多种关系类型:当需要匹配多种关系中的一种时，可以通过竖线|将多个关系连接在一起
MATCH (wallstreet { title: 'The Matrix' })<-[:ACTED_IN|:DIRECTED]-(person) 
RETURN person.name 

//多个关系:关系可以多语句以 ()--()的形式来表达，或者它们相互连接在一起。
MATCH (tom:Person{ name: 'Tom Hanks' })-[:ACTED_IN]->(movie)<-[:DIRECTED]-(director)
RETURN tom, movie, director 

/**
可变长关系
可变长关系和节点的语法如下：
   -[:TYPE*minHops..maxHops]->
minHops和maxHops都是可选的，默认值分别为1和无穷大。
当没有边界值的时候，点也可以省略。
当只设置了一个边界的时候，如果点省略了就意味着是一个固定长度的模式。
*/
//返回与'Tom Hanks'关系为1跳(hop)到3跳的所有电影。
MATCH (martin:Person { name: 'Tom Hanks' })-[:ACTED_IN*1..3]-(movie:Movie)
RETURN movie.title 

//变长关系的关系变量:当连接两个节点之间的长度是变长的，那么关系变量返回的将可能是一个关系列表。
MATCH (actor { name: 'Tom Hanks' })-[r:ACTED_IN*2]-(co_actor) RETURN r 

//匹配一簇关系:当模式包含一簇关系时，关系模式不会指定方向，Cypher将尝试匹配两个方向的关系。
MATCH (a)-[r]-(b) WHERE id(r)= 0 RETURN a,b 
```

#### 查询路径



```java
//如果想返回或者需要对路径进行过滤，可以将路径赋值给一个变量。
MATCH p =(tom { name: 'Tom Hanks' })-->() RETURN p 

//单条最短路径: 通过使用shortestPath函数很容易找到两个节点之间的最短路径
MATCH  p=shortestPath((tom { name: 'Tom Hanks' })-[*..15]-( Steve {name:'Steve Zahn'}))
RETURN p 
//上面查询的含义为：找到两个节点之间的最短路径，路径最大长度为15。在搜索最短路径的时候，还可以使用关系类型、最大跳数和方向等约束条件。如果用到了WHERE语句，相关的断言会被包含到shortestPath中去。如果路径的关系元素中用到了none()或者all()断言，那么这些将用于在检索时提高性能。
```

#### 通过id查询节点或关系



```java
//通过id查询节点:可以在断言中使用id()函数来根据id查询节点。
MATCH (n) WHERE id(n)= 0 RETURN n

//通过id查询多个节点:通过id查询多个节点的时候，可以将id放到IN语句中。
MATCH (n) WHERE id(n) IN [0, 3, 5] RETURN n

//通过id查询关系:通过id查询关系与节点类似。
MATCH ()-[r]->() WHERE id(r)= 0 RETURN r 
```

### 2,OPTIONAL MATCH

OPTINAL MATCH语句用于搜索模式中描述的匹配项，对于找不到的项用null代替。

#### 关系

 如果某个关系是可选的，可使用OPTINAL MATCH。这很类似SQL中outer join的工作方式。如果关系存在就返回，否则在相应的地方返回null。



```java
MATCH (a:Movie { title: 'The Matrix' })
OPTIONAL MATCH (a)-->(x)
RETURN x 
```

返回了null，因为这个节点没有外向关系。

#### 可选元素的属性

如果可选的元素为null，那么该元素的属性也返回null。



```java
MATCH (a:Movie { title: 'The Matrix' })
OPTIONAL MATCH (a)-->(x)
RETURN x, x.name
```

返回了x元素(查询中为null)，它的name属性也为null。

#### 可选关系类型

可在查询中指定可选的关系类型。



```java
MATCH (a:Movie { title: 'The Matrix' })
OPTIONAL MATCH (a)<-[r: ACTED_IN]-()
RETURN r 
```

### 3，WHERE

 WHERE在 MATCH或者OPTINAL MATCH语句中添加约束，或者与WITH一起使用来过滤结果。

#### 基本使用



```java
//布尔运算:可以在WHERE中使用布尔运算符，如AND和OR，以及布尔函数NOT。
//查找1990年到2000年发行的电影的名称
MATCH (nineties:Movie) 
WHERE nineties.released > 1990 AND nineties.released < 2000 
RETURN nineties.title

//节点标签的过滤:可以在WHERE中类似使用WHERE n:foo写入标签断言来过滤节点。
MATCH (n) WHERE n:Movie RETURN n 

//节点属性的过滤。
MATCH (n) WHERE n.released > 1990 RETURN n 

//关系属性的过滤
MATCH (n)-[:ACTED_IN]->(m) WHERE m.released > 1990 RETURN n

//属性存在性检查:使用exists()只能检查节点或者关系的某个属性是否存在。
MATCH (n) WHERE exists(n.title) RETURN n 
```

#### 字符串匹配



```java
//匹配字符串的开始:STARTS WITH用于以大小写敏感的方式匹配字符串的开始。
MATCH (n) WHERE n.name STARTS WITH 'Tom' RETURN n 

//匹配字符串的结尾:ENDS WITH用于以大小写敏感的方式匹配字符串的结尾。
MATCH (n) WHERE n.name ENDS WITH 'Hanks' RETURN n 

//字符串包含:CONTAINS用于检查字符串中是否包含某个字符串，它是大小写敏感的，且不关心匹配部分在字符串中的位置。
MATCH (n) WHERE n.name CONTAINS 'bin' RETURN n 

//字符串反向匹配:使用NOT关键词可以返回不满足给定字符串匹配要求的结果。
MATCH (n) WHERE NOT n.name ENDS WITH 's' RETURN n 
```

#### 正则表达式

 Cypher支持正则表达式过滤。正则表达式的语法继承来自Java正则表达式。



```java
//正则表达式:可以使用=~ 'regexp'来进行正则表达式的匹配。
MATCH (n) WHERE n.name =~ 'Tom.*' RETURN n 

//正则表达式中的转义字符:如果需要在正则表达式中插入斜杠，需使用转义字符。注意：字符串中的反斜杠也需要转义。
MATCH (n) WHERE n.title =~ 'sun\\/rise' RETURN n 

//正则表达式的非大小写敏感:在正则表达式前面加入(?i)之后，整个正则表达式将变成非大小写敏感。
MATCH (n) WHERE n.name =~ '(?i)TOM.*' RETURN n 
```

#### 在WHERE中使用路径模式



```java
//模式过滤
MATCH (n { name:'Kevin Bacon'}),(m) WHERE (n)-[:ACTED_IN]-(m) RETURN n,m

//模式中的NOT过滤:NOT功能可用于排除某个模式。
MATCH (n { name:'Kevin Bacon'}),(m:Movie) WHERE NOT (n)-[:ACTED_IN]-(m) RETURN m

//模式中的属性过滤:可以在模式中添加属性来过滤结果。
MATCH (n) WHERE (n)-[: ACTED_IN]-({ title: 'Apollo' }) RETURN n
```

#### 关系类型过滤

 可以在MATCH模式中添加关系类型，但有时候希望在类型过滤上具有丰富的功能。这时，可以将类型与其他进行比较。例如，下面的例子将关系类型与一个正在表达式进行比较。



```java
MATCH (n)-[r]->()
WHERE type(r)=~ 'DIRE.*'
RETURN n 
```

#### IN运算符

检查列表中是否存在某个元素，可以使用IN运算符。



```java
MATCH (a)
WHERE a.name IN ['Keanu Reeves', 'Lana Wachowski','Hugo Weaving']
RETURN a
```

#### 空值过滤

 有时候需要测试某个值或变量是否为null。在Cypher中与SQL类似，可以使用IS NULL。相反，“不为空”使用IS NOT NULL，尽管NOT (IS NULL x)也可以。



```java
MATCH (m)
WHERE m.title IS NULL 
RETURN m
```

### 4，RETURN

 RETURN语句定义了查询结果集中返回的内容。



```java
//返回节点
MATCH (n { name: 'Steve Zahn' }) RETURN n

//返回关系
MATCH (n { name: 'Steve Zahn' })-[r:KNOWS]->(c) RETURN r

//返回属性
MATCH (n { name: 'Steve Zahn' }) RETURN n.name

//返回所有元素:当希望返回查询中找到的所有节点，关系和路径时，可以使用星号*表示
MATCH p =(a { name: 'Steve Zahn' })-[r]->(b) RETURN *

//变量中的特殊字符:如果想使用空格等特殊字符，可以用反引号`将其括起来。
MATCH (`This is a common variable`)
WHERE `This is a common variable`.name = 'Steve Zahn'
RETURN `This is a common variable`.happy

//列别名:如果希望列名不同于表达式中使用的名字，可以使用AS<new name>对其重命名。
MATCH (a { name: 'Steve Zahn' }) RETURN a.born AS bornYear
     
//可选属性:如果某个属性可能存在，也可能不存在。这时，依然可以正常地去查询，对于不存在的属性，Cypher返回null。
MATCH (n) RETURN n.title

//其他表达式:任何表达式都可以作为返回项。如字面值，断言，属性，函数和任何其他表达式。
MATCH (a { name: 'Steve Zahn' })
RETURN a.born > 1960, "I a literal",(a)-->()

//唯一性结果:DISTINCT用于仅仅获取结果集中所依赖列的唯一行。
MATCH (a) RETURN DISTINCT a.name
```

# Cypher语法关键字(二)

# CREATE、MERGE、CREATE UNIQUE、SET

cypher关键字

cypher关键字可分为三类。

- 读关键字：MATCH、OPTIONAL MATCH、WHERE、START、Aggregation和LOAD CSV
- 写关键字：CREATE、MERGE、SET、DELETE、REMOVE、FOREACH和CREATE UNIQUE
- 通用关键字：RETURN、ORDER BY、LIMIT、SKIP、WITH、UNWIND、UNION和CALL

### 1，CREATE

CREATE语句用于创建图元素：节点和关系、索引。

#### 创建节点



```java
//创建单个节点
CREATE (n)

//创建多个节点
CREATE (n),(m)

//创建带有标签的节点
CREATE (p:Person)

//创建同时带有标签和属性的节点
CREATE (p:Person { name: 'Andres', title: 'Developer' })
```

#### 创建关系

```java
//创建两个节点之间的关系:关系必须有箭头指向
MATCH (a:Person),(b:Person)
WHERE a.name = 'NodeA' AND b.name = 'NodeB'
CREATE (a)-[r:RELTYPE]->(b)
RETURN r
    
//创建关系并设置属性
MATCH (a:Person),(b:Person)
WHERE a.name = 'NodeA' AND b.name = 'NodeB'
CREATE (a)-[r:RELTYPE{ name: 'abc' }]->(b)
RETURN r

//创建一个完整路径:当使用CREATE和模式时，模式中所有还不存在的部分都会被创建
CREATE p =(andres { name:'Andres' })-[:WORKS_AT]->(neo)<-[:WORKS_AT]-(michael { name: 'Michael' })
RETURN p
```

#### 创建索引

```java
CREATE INDEX ON :Person(name)
```

### 2，MERGE

​       MERGE可以确保图数据库中存在某个特定的模式(pattern)。如果该模式不存在，那就创建它。

#### MERGE 节点

```scala
//合并带标签的节点:如果没有包含Ctritic标签的节点，就会创建一个新节点。
MERGE (robert:Critic)
RETURN robert, labels(robert)

//合并带多个属性的单个节点
MERGE (charlie { name: 'Charlie Sheen', age: 10 })
RETURN charlie

//合并同时指定标签和属性的节点
MERGE (michael:Person { name: 'Michael Douglas' bornIn:'newyork'})
RETURN michael.name, michael.bornIn

//合并属性来自已存在节点的单个节点
MATCH (person:Person{ bornIn:'newyork'})
MERGE (city:City { name: person.bornIn })
RETURN person.name, person.bornIn, city    
```

#### MERGE在CREATE和MATCH中的使用

```scala
//MERGE与CREATE搭配:检查节点是否存在，如果不存在则创建它并设置属性
MERGE (keanu:Person { name: 'Keanu Reeves' })
ON CREATE SET keanu.created = timestamp()
RETURN keanu.name, keanu.created

//MERGE与MATCH搭配:匹配节点，并在找到的节点上设置属性。
MERGE (person:Person { name: 'Keanu Reeves2' })
ON MATCH SET person.found = TRUE 
RETURN person.name, person.found

//MERGE与CREATE和MATCH同时使用:检查节点是否存在，如果不存在则创建它并设置created属性,如果存在就修改lastSeen属性。
MERGE (keanu:Person { name: 'Keanu Reeves' })
ON CREATE SET keanu.created = timestamp()
ON MATCH SET keanu.lastSeen = timestamp()
RETURN keanu.name, keanu.created, keanu.lastSeen
```

#### MERGE关系

```scala
//匹配或者创建关系:使用MERGE去匹配或者创建关系时，必须至少指定一个绑定的节点。
MATCH (p:Person { name: 'Charlie Sheen' }),(m:Movie { title: 'The Matrix' }) 
MERGE (p)-[r:ACTED_IN]->(m)
RETURN p.name, type(r), m.title

//合并多个关系:当MERGE应用于整个模式时，要么全部匹配上，要么全部新创建。
MATCH (oliver:Person { name: 'Lilly Wachowski' }),(reiner:Person { name: 'Rob Reiner' })
MERGE (oliver)-[:DIRECTED]->(movie:Movie)<-[:ACTED_IN]-(reiner)
RETURN movie

//合并无方向关系:MERGE也可以用于合并无方向的关系。当需要创建一个关系的时候，它将选择一个任意的方向。
MATCH (p1:Person { name: 'Charlie Sheen' }),(p2:Person { name: 'Lilly Wachowski' })
MERGE (p1)-[r:KNOWS]-(p2)
RETURN r

//合并已存在两节点之间的关系:MERGE可用于连接前面的MATCH和MERGE语句。
MATCH (person:Person { name: 'riky' })
MERGE (city:City { name: person.bornIn })
MERGE (person)-[r:BORN_IN]->(city)
RETURN person.name, person.bornIn, city

//同时合并\创建一个新节点和关系
MATCH (person:Person{name: 'Demi Moore'})
MERGE (person)-[r:HAS_CHAUFFEUR]->(chauffeur:Chauffeur { name: person.name })
RETURN person.name, person.chauffeurName, chauffeur
```

#### MERGE的唯一性约束

​       当使用的模式涉及唯一性约束时，Cypher可以通过MERGE来防止获取相冲突的结果。

​       下面的例子在Person的name属性上创建一个唯一性约束。

```scala
CREATE CONSTRAINT ON (p:Person) ASSERT p.name IS UNIQUE;
```

```scala
//如果节点未找到，使用唯一性约束创建该节点
MERGE (laurence:Person { name: 'Laurence Fishburne' })
RETURN laurence.name

//唯一性约束与部分匹配:当只有部分匹配时，使用唯一性约束合并将失败。
CREATE CONSTRAINT ON (n:Person) ASSERT n.role IS UNIQUE;
CREATE (alisanda:Person { name: 'alisanda', role: 'Gordon Gekko' })

MERGE (michael:Person { name: 'Michael Douglas', role: 'Gordon Gekko' })
RETURN michael
//错误消息:Node(1578733) already exists with label `Person` and property `role` = 'Gordon Gekko'
```

### 3，CREATE UNIQUE

​      CREATE UNIQUE语句相当于MATCH和CREATE的混合体—尽可能地匹配，然后创建未匹配到的。

​      可能会想到用MERGE来代替CREATE UNIQUE，然而MERGE并不能很强地保证关系的唯一性。

#### 创建唯一节点

```scala
//创建未匹配到的节点:root节点没有任何LOVES关系。因此，创建了一个节点及其与root节点的LOVES关系。注意这里可以不指定关系方向
MATCH (root { name: 'root' })
CREATE UNIQUE (root)-[:LOVES]-(someone)
RETURN someone

//用含值的模式创建节点:没有与root节点相连的name为D的节点，所以创建一个新的节点来匹配该模式。
MATCH (root { name: 'A' })
CREATE UNIQUE (root)-[:X]-(leaf { name: 'D' })
RETURN leaf

//创建未匹配到带标签的节点
MATCH (a { name: 'Node A' })
CREATE UNIQUE (a)-[:KNOWS]-(c:blue)
RETURN c
```

#### 创建唯一关系

```scala
//创建未匹配到的关系:匹配一个左节点和两个右节点之间的关系。其中一个关系已存在，因此能匹配到。然后创建了不存在的关系。
MATCH (lft { name: 'A' }),(rgt)
WHERE rgt.name IN ['B', 'C']
CREATE UNIQUE (lft)-[r:KNOWS]->(rgt)
RETURN lft, rgt

//用含值的模式创建关系
MATCH (root { name: 'root' })
CREATE UNIQUE (root)-[r:X { since: 'forever' }]-()
RETURN r

//描述复杂模式
MATCH (root { name: 'root' })
CREATE UNIQUE (root)-[:FOO]->(x),(root)-[:BAR]->(x)
RETURN x
```

### 4，SET

​      SET语句用于更新节点的标签以及节点和关系的属性。

```scala
//设置属性
MATCH (n { name: ' Taylor Hackford' })
SET n.surname = 'Taylor'
RETURN n

//删除属性
MATCH (n { name: 'Taylor Hackford' })
SET n. surname = NULL 
RETURN n

//在节点和关系间拷贝属性
MATCH (at { name: 'Andres' }),(pn { name: 'Peter' })
SET at = pn
RETURN at, pn

//从map中添加属性:当用map来设置属性时，可以使用+=形式的SET来只添加属性，而不删除图元素中已存在的属性。
MATCH (peter { name: 'Peter' })
SET peter += { hungry: TRUE , position: 'Entrepreneur' }

//使用一个SET语句设置多个属性
MATCH (n { name: 'Andres' })
SET n.position = 'Developer', n.surname = 'Taylor'

//设置节点的标签
MATCH (n { name: 'Stefan' })
SET n :German
RETURN n

//给一个节点设置多个标签
MATCH (n { name: 'Emil' })
SET n :Swedish:Bossman
RETURN n
```

# Cypher语法关键字(三)

# DELETE,REMOVE,ORDER BY,LIMIT,SKIP

### 1，DELETE

 DELETE语句用于删除图元素--节点，关系或路径。

```scala
// 删除单个节点
MATCH (n:Useless) DELETE n

// 删除关系
MATCH (root { name: 'root' })-[r]-(A { name: 'A' }) DELETE r

// 删除路径
match p=(d { name: 'Node D' })--(e { name: 'Node e' }) delete p

// 删除一个节点及其所有的关系
MATCH (n { name: 'root' }) DETACH DELETE n

// 删除所有节点和关系
MATCH (n) DETACH DELETE n
```

### 2，REMOVE

 REMOVE语句用于删除图元素的属性和标签。对于删除节点和关系，参见DELETE小节.

```scala
// 删除一个属性:Neo4j不允许属性存储空值null。如果属性的值不存在，那么节点或者关系中的属性将被删除。这也可以通过REMOVE来删除。
MATCH (p {name: 'Michael Douglas'}) REMOVE p.bornIn RETURN p

// 删除标签
MATCH (n:German { name: 'Peter' }) REMOVE n:German RETURN n

// 删除节点的多个标签 
MATCH (n { name: 'Peter' }) REMOVE n:German:Swedish RETURN n
```

### 3，ORDER BY

 ORDER BY是紧跟RETURN或者WITH的子句，它指定了输出的结果应该如何排序。

```scala
// 根据属性对节点进行排序
MATCH (n) RETURN n.name ORDER BY n.name

// 根据多个属性对节点进行排序
MATCH (n) RETURN n.born, n.name ORDER BY n.born, n.name

// 节点降序排序:在排序的变量后面添加DESC，Cypher将以逆序（即降序）对输出进行排序。
MATCH (n) RETURN n ORDER BY n.name DESC

// 空值的排序:当结果集中包含null值时，对于升序排列，null总是在结果集的末尾。而对于降序排序，null值总是排在最前面。
MATCH (n) RETURN n.title, n ORDER BY n.title
```

### 4，LIMIT

 LIMIT限制输出的行数。

```scala
// 返回开始部分
MATCH (n) RETURN n ORDER BY n.name LIMIT 3
```

### 5，SKIP

 SKIP定义了从哪行开始返回结果。

```scala
// 跳过前三
MATCH (n) RETURN n ORDER BY n.name SKIP 3

// 返回中间两个
MATCH (n) RETURN n ORDER BY n.name SKIP 1 LIMIT 2

// 跳过表达式的值加1
MATCH (n) RETURN n ORDER BY n.name SKIP toInt(3*rand())+ 1
```