[robomongo](https://github.com/Studio3T/robomongo)：免费、开源的 MongoDB 跨平台桌面管理工具，支持 Windows、Linux、Mac

# MongoDB

## 一、介绍|安装

### 1.1. 使用场景

mysql是关系型数据库，支持事务；mongodb，redis非关系型数据库，不支持事务

mysql、mongodb、redis的使用根据如何方便进行选择：

- 希望速度快的时候，选择mongodb或者是redis
- 数据量过大的时候，选择频繁使用的数据存入redis，其他的存入mongodb

- mongodb不用提前建表建数据库，使用方便，字段数量不确定的时候使用mongodb
- 后续需要用到数据之间的关系，此时考虑mysql

### 1.2. 数据类型

- Object lD:文档ID   每个文档都有一个属性，为**_id**，保证每个文档的唯一性

- Boolean:存储一个布尔值, true或false  (注意是小写)

- Null:存储Null值

- Timestamp:时间戳,表示从1970-1-1到现在的总秒数

- Date:存储当前日期或时间的UNIX时间格式    创建日期语句如下：参数格式为YYYY-MM-DD
  `new Date("2021-01-15")`

  可以自己去设置\_id插入文档，如果没有提供，那么MongoDB为每个文档提供了一个独特的_id，类型为objectlD:objectID是一个12字节的十六进制数︰前4个字节为当前时间戳；接下来3个字节的机器ID；接下来的2个字节中MongoDB的服务进程id；最后3个字节是简单的增量值。

### 1.3. 安装

window下的mongod
mongodb安装完后，就把bin路径添加到环境变量中去；
配置MongoDB服务

1、创建配置文件 mongod.cfg
内容：

>systemLog:
>    destination: file
>    path: E:\MongoDB\log\mongod.log
>storage:
>    dbPath: E:\MongoDB\db         # 注意这是一个目录，根绝自己实际情况改

2、安装MongoDB服务

>mongod --config "E:\MongoDB\mongod.cfg" --install      
>
>启动服务：net start MongoDB
>关闭服务：net stop MongoDB
>移除服务：mongod --remove
>
>链接服务：mongo

## 二、MongoDB简单使用

### 2.1. 基本信息|合集

查看数据集基本信息：

>查看所有数据库: show dbs /show databases
>切换数据库: use db_name     # 当使用一个不存在的数据库，是看不到的，往里面插入数据后，就会出来
>查看当前的数据库: db
>删除当前的数据库: db.dropDatabase()

集合的创建使用：

>创建集合： db.createCollection(name,options)
>例如： db.createCollection("students")    # 创建一个名为students的集合
>Ps:可以不手动创建集合，不存在的集合中第一次加入数据时，集合会被创建出来
>db.createCollection("students", { capped : true, size : 10})    #参数capped:默认值为false表示不设置上限,值为true表示设置上限，10个字节，大于后数据就会像队列那样覆盖掉
>
>查看集合: show collections
>删除集合: db.集合名称.drop()    # db.teachers.drop()

### 2.2. 增删改查

- 插入数据：`db.集合名称.insert(数据字典)`

>db.my_stu.insert({name: "zhangsan", age: 23, gender: "male"})
>db.my_stu.insert({_id: "20210114", name: "lisi", age: 25}) # 这是给了\_id，不给会默认生成
>保存：db.集合名称.save(document)  
>
>#如果文档的\_id已经存在则修改，如果文档的\_id不存在则添加       # 如果是insert插入时指定的_id已经存在，则会报错

***

- 更新(修改)数据：`db.集合名称.update(<query> ,<update>,{multi: <boolean>})`
  - 参数query:查询条件; 参数update:更新操作符
  - 参数multi:可选，默认是false，表示只更新找到的第一条记录，值为true表示把满足条件的文档全部更新 

>db.my_stu.update({name:'zhangsan'},{name:'new_zhangsan'})   #更新一条,注意整个这条数据都只剩下name字段了，其它的就没了，基本不用这
>
>db.my_stu.update({name: "lisi"}, {$set: {name: "a_new_lisi"}})    #更新一条,且值更新这一条的name字段，其它原本的建值都还在
>
>db.my_stu.update({}, {$set: {gender:"male"}}, {multi:true})   # 更新全部，因为前面query那里还没有条件，会把所有数据的gender都改成male,(有的数据没有gender这个字段都会被添加进去)
>
>db.my_stu.update({name: "lisi"}, {$set: {gender:"female"}}, {multi:true})   #跟上同理，这就是把name="lisi"的数据的gender都改成female
>
>db.test01.update({name: "wangwu"}, {$set:{name: "zhaoliu"}}, {multi: true})   #要是是多个name: wangwu, 但是其它键的值不一样，想把每条name:wangwu都更新成name:zhaoliu
>
>Ps: "multi update only works with \$ operators"     # 就是说这个multi必须和$一起使用才有效

***

- 删除数据：`db.集合名称.remove(<query>, {justOne: <boolean>})`
  - 参数query:可选，删除的文档的条件
  - 参数justOne:可选，如果设为true或1，则只删除一条，默认false，表示删除多条

>db.my_stu.remove({age: 10})       # 这会把所有的age=10的数据删除的
>db.test01.remove({age: 10}, {justOne:true})   # 就只删除查询到的第一条

## 三、高级查询

### 3.1. 简单查询

>db.my_stu.find()  #  查询所有数据
>db.my_stu.findOne({age:20})   # 就只是看一条数据
>db.my_stu.find({age:20}).pretty()     # 格式化一下数据，看起来美观

### 3.2. 比较运算符

>- 等于:默认是等于判断，没有运算符
>
>- 小于:$lt (less than)
>
>- 小于等于:$lte (less than equal)
>
>- 大于:$gt (greater than)
>
>- 大于等于: $gte
>
>- 不等于:$ne
>
>  db.my_stu.find({age:{$gte:18}})       # 选择年龄大于等于18的

### 3.3. 范围运算符

>"\$in"，"$nin": 查询是否在某个范围内的值
>查询年龄为18、16的学生：db.my_stu.find({age: {$in:[18, 16]}})

### 3.4. 逻辑运算符

​	相当于就是多个条件

>- and:在json中写多个条件即可
>    查询年龄>=18，并且性别为true的学生：db.my_stu.find({age:{$gte:18},gender:true})   # 多个条件直接往后面加,条件里面还可以再添加条件
>
>- or:使用$or，值为数组，数组中每个元素为json
>    查询年龄大于20，或家乡在桃花岛或是蒙古的：db.my_stu.find({$or:[{age:{$gt: 18}}, {hometown: {$in:["桃花岛", "蒙古"]}}]})

### 3.5. 正则、limit、skip

>- db.my_stu.find({name:/^"郭"/})     # 找以郭开头的学生；  双斜线里是放正则表达式
>- db.my_stu.find({name:{\$regex: "誉\$"}})  \# 找以 誉 结尾的； {$regex: "正则表达式"}
>
>
>
>- db.my_stu.find().limit(2)   # 显示两条
>- db.my_stu.find().skip(2)   # 跳过两条,显示剩下的
>
>两个可以同时使用

### 3.6. 自定义查询、投影

使用==$where==后面写一个函数，返回满足条件的数据：

>查询年龄大于30的学生
>
>db.my_stu.find({\$where: function() {return this.age> 30}})    # 返回满足条件的数据
>db.my_stu.find({​\$where: function() {return this.age> 30}}, {name:1})  # 这就是只返回name字段
>db.my_stu.find({$where: function() {return this.age> 30}}, {_id: 0, name:1, age:1}) 

### 3.7. 排序、count

>db.my_stu.find().sort({age: 1})     # 按照age的升序去排；-1就是降序
>db.my_stu.find({age: {$gt: 18}}).sort({age: -1, name: 1})     # 先选出年龄大于18的，再按照age降序排，相同时再按照name，还可以再跟
>
>
>
>db.my_stu.find({age: {\$gte: 18}}).count()       # age大于等于18的学生的人数
>或者直接来
>db.my_stu.count({age: {$gte: 18}})        # 直接计数就是db.my_stu.count()

### 3.8. 消除重复

>db.my_stu.distinct("hometown")
>db.my_stu.distinct("hometown", {age: {$gt: 20}})    # 还可以跟条件



## 四、聚合|aggregrate

​	聚合(aggregate)是基于数据处理的聚合管道，每个文档通过一个由多个阶段(stage)组成的管道，可以对每个阶段的管道进行分组、过滤等功能，然后经过一系列的处理，输出相应的结果。
​	语法：`db.集合名称.aggregate({管道:{表达式}})`

​	*常用管道*：
​		\$group:将集合中的文档分组，可用于统计结果；
​		​\$match:过滤数据，只输出符合条件的文档；
​		​\$project:修改输入文档的结构，如重命名、增加、删除字段、创建计算结果；
​		​\$sort:将输入文档排序后输出；
​		​\$limit:限制聚合管道返回的文档数；
​		​\$skip:跳过指定数量的文档,并返回余下的文档；
​		\$unwind:将数组类型的字段进行拆分。

​	表达式：处理输入文档并输出
​	语法：表达式:'\$列名'   常用的表达式如下：
​			\$sum:计算总和，​\$sum:1表示以一倍计数；
​			\$avg:计算平均值；
​			\$min:获取最小值；
​			\$max:获取最大值；
​			\$push:在结果文档中插入值到一个数组中；
​			\$first:根据资源文档的排序获取第一个文档数据；
​			$last:根据资源文档的排序获取最后一个文档数据。

### 4.1. $group

将集合中的文档分组，可用于统计结果：

- `_id`表示分组的依据，使用某个字段的格式为`'$字段'`;
- `$group`对应的字典中有几个键，结果中就有几个键，分组依据需要放到`_id`后面;
- 取不同的字段的值需要使用\$, 即 ​\$gender， $age 等。

>#按照性别进行分组
>
>- db.my_stu.aggregate({$group: {_id:"$gender"}})    # 按性别进行分组
>
>- db.my_stu.aggregate({$group: {_id: "$gender", count: {$sum:1}}})   # 分组后统计个数(这个 count 是自己决定的，就是把结果放进这个字段)
>
>- db.my_stu.aggregate({\$group: {_id:"\$gender", count: {\$sum:1}, avg_age: {​\$avg: "​\$age"}}})    # 同样 avg_age是自己写的指定的，后面 $avg 是要求，在后面是求平均值的字段的名称
>
>
>
>#按照hometown分组，获取不通组的平均年龄
>
>- db.my_stu.aggregate({$group: {_id: "$hometown", mean_age: {$avg: "$age"}}})

>group by null  这样就是来统计整个文档的信息；group分组时_id的依赖字段为null
>
>- db.my_stu.aggregate({$group: {_id: null, count: {$sum: 1}, avg_age: {$avg: "$age"}}})    # 注意 null 不要引号，统计整个文档的个数及平均年龄



group还可以按照多个字段分组

​	格式：`{$group: {_id: {自定义名字字段1: "$country", 自定义名字字段2: "$provience", ....}}}`  # 多个字段就一起这样以字典的形式放在 _id 后。

>db.my_stu.aggregrate(
>    {\$group: {\_id: {country: "\$country", provience: "\$provience", userid: "\$userid"}}},
>    {\$group: {\_id: {country: "​\$\_id.country", provience: "​\$\_id.provience"}, count: {​\$sum:1}}},
>    {$project: {country: "$_id.country", provicnce: "$_id.provience", count: 1, _id: 0}}
>)

- 多字段分组时 _id 给上所有的字段，就可以去掉重复数据
- 上面是去重，再输入管道，按照country、provience分组(注意因为是嵌套，所以是_id.country这样去取值)

### 4.2. $project

​	用来把前面group的字段重新命名输出，只要是针对分组的那个字段，其它的字段在分组时就可以自定义。

>db.my_stu.aggregate(
>    {\$group: {_id: null, count: {\$sum: 1}, mean_age: {​\$avg: "​\$age"}}},
>    {​\$project: {gender: "\$\_id", count: "​\$count", mean_age: 1, _id: 0}}
>)
>\# 前面分组基本不变，主要就是后面同样等级的 $project, 把$\_id的键变成了gender，后面的就可以是这样操作，也可以使用0、1的投影操作。

### 4.3. $match

用于过滤数据，只输出符合条件的文档  （match是 管道命令，能将结果交给后一个管道，但是find不可以）

>例1：查询年龄大于20的学生
>
>- db.my_stu.aggregate({$match: {age: {$gte: 20}}})
>
>- db.my_stu.find({age: {$gte: 20}})           # 两个效果是一样的
>
>
>
>例2：查询年龄大于等于18的男生、女生人数
>
>- db.my_stu.aggregate(
>      {\$match: {age: {\$gte: 18}}},
>      {$group: {_id: "$gender", count: {$sum:1}}}      # 每个条件都要单独给大括号的
>  )
>
>- db.my_stu.aggregate(
>      {\$match: {age: {\$gte: 18}}},
>      {​\$group: {\_id: "\$gender", count: {\$sum:1}}},
>      {$project: {gender: "$_id", count: 1, _id: 0}}    # 投影操作，美化操作
>  )
>
>例3： 年龄大于20或是家乡在蒙古或大理，再分组
>
>- db.my_stu.aggregate(
>      {\$match: {\$or: [{age: {\$gt:20}}, {hometown: {​\$in: ["蒙古", "大理"]}}]}},
>      {\$group: {\_id: "​\$gender", count: {\$sum: 1}}},
>      {$project: {gender: "$_id", count: 1, _id: 0}}
>  )
>

​	Tips：一定要注意，这里因为显示的问题，==一些`_id`以及`$`符号前面加了一个转义符号`\`==,直接复制这去运行时一定要删掉才会成功。

### 4.4. \$sort  ​\$limit  $skip

​	$sort：将输入文档排序后输出

>例1：按年龄分组，再根据各组人数降序排列
>
>- db.my_stu.aggregate(
>      {\$group: {\_id: "\$age", count: {\$sum: 1}}},
>      {​\$sort: {count: -1}}, 
>      {$project: {age: "$_id", count: 1, _id: 0}}
>  )
>

Tips：sort排序的时候是要指定排序的字段的，然后==-1是降序，1是升序==。

​	\$limit   $skip

>db.my_stu.aggregate({\$limit: 2})    # 跟前面的limit效果一样，就是只看两个
>db.my_stu.aggregate({$skip: 2})     # 同上，跳过两个，显示剩余的

>例：年龄升序排列，取第3条数据
>
>- db.my_stu.aggregate(
>      {\$sort: {age: 1}},
>      {​\$skip: 2},
>      {$limit: 1}
>  )

### 4.5. $unwind

​	将文档中的某一个数组类型字段拆分成多条，每条包含数组中的一个值
​语法: `db.集合名称.aggregate({$unwind: "$字段名称"})`

>#先插一条数据
>	db.t1.insert({_id:1, item: "t-shirt", size: ["S", "M", "L"]})
>	db.t1.aggregate({\$unwind: "$size"})     # 得到3条数据，就把字段size分开，成为3条数据

>db.t1.insert({user: "Alex", tags: ["c++", "python", "java"]})    # 如何知道这条数据 tags的长度呢
>
>- db.t1.aggregate(
>      {\$match: {user: "Alex"}},
>      {​\$unwind: "​\$tags"},
>      {$group: {_id: null, count: {$sum: 1}}}
>  )
>
>\# 先在数据库里匹配到这条数据，然后用\$unwind拆开，最后再通过上面null分组，求$sum

​	Ps:在使用unwind时，比如使用的字段是tags,而match匹配到的还有其他的Alex数据，然而它们有一些是没有tags这个字段的，那么在使用unwind后，它们会被丢弃，为了保留这些数据，得加一些

>db.t1.ahhregate(
>    	{unwind: {path: "$字段名称"， preserveNullAndEmptyArrays:true}}
>)           # 这是固定写法

## 五、索引

- 先创建一些数据：`for(i=0; i<100000; i++){db.t1.insert({name:"test"+i, age: i})}`

>db.t1.find({name: "test99999"})
>db.t1.find({name: "test99999"}).explain("executionStats")   # 就可以查看到执行时间

- 建立索引：`db.t1.ensureIndex({name: 1})`
  这就是以 name 为索引，按照1升序排列(-1就是降序，这个可能对于sort排序时速度有影响，其它差别不大)
- 获取索引：`db.t1.getIndexes()`
- 删除索引：`db.t1.dropIndex({name:1})`     # 怎么创建的怎么删除
- 建立联合索引：`db.t1.ensureIndex({name:1, age:-1})`    # 多个索引直接放进字段里

***

\# 在默认情况下，索引字段的值可以相同
`db.t1.ensureIndex({name: 1}, {unique: true})`      # 加一个unique约束，那么所有的name的值就必须是唯一的，故可以使用数据库建立关键字段的唯一索引进行去重。

## 六、数据的备份与恢复

备份：

>mongodump  -h  dbhost  -d  dbname  -o  dbdirectory 
>
>-h 服务器地址，也可指定端口号     # 本机时就可以不给
>-d 需要备份的数据库名称
>-o 备份的数据库存放位置，此目录中存放着备份出来的数据
>例：mongodump -h 192.168.196.128:27017 -d test1 -o /home/

恢复：

>mongorestore -h  dbhost  -d  dbname  --dir  dbdirectory 
>
>-h 服务器地址
>-d 需要恢复的数据库实例
>--dir  备份数据所在位置
>例：mongorestore  -h 192.1468.196.128:27017  -d mytest01  --dir  /home/mytest01

## 七、Python交互

更多的使用看[这里](https://www.w3school.com.cn/python/python_mongodb_getstarted.asp)。

```python
from pymongo import MongoClient

client = MongoClient(host="127.0.0.1", port=27017)
collection = client['mytest01']['t1']
datas = collection.find()   
# 得到的是所有的数据，为一个游标对象，可去循环获取

# 插入一条数据
collection.insert({"name": "张三丰", "age": 18})
# 插入多条数据，以一个列表的形式
data = [{"name": "test{}".format(i)} for i in range(10)]
collection.insert_many(data)
# 其它的就还是自己去菜鸟教程看
```

## 这里面出现的有趣的错误

>例2：查询年龄大于等于18的男生、女生人数
>
>- db.my_stu.aggregate(
>  {$match: {age: {$gte: 18}}},
>   {$group: {_id: "$gender", count: {$sum:1}}}             #每个条件都要单独给大括号的
>  )
>
>- db.my_stu.aggregate(
>  {$match: {age: {$gte: 18}}},
>   {$group: {\_id: "$gender", count: {$sum:1}}},
>   {$project: {gender: "$_id", count: 1, _id: 0}}          # 投影操作，美化操作
>  )
>
>例3： 年龄大于20或是家乡在蒙古或大理，再分组
>
>- db.my_stu.aggregate(
>  {$match: {$or: [{age: {$gt:20}}, {hometown: {$in: ["蒙古", "大理"]}}]}},
>   {$group: {\_id: "$gender", count: {$sum: 1}}},
>   {$project: {gender: "$_id", count: 1, _id: 0}}
>  )
>
>Ps:一定要注意，这里为了美观，一些 _id  前面加了一个转义符号 \  ,直接复制这去运行时一定要删掉才会成功。