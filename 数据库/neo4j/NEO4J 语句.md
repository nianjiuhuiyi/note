# NEO4J 语句

创建标签：LOAD CSV WITH HEADERS  FROM "file:///Affair.csv" AS line  
CREATE (p:Affair{title:line.title,disaster_level:line.disaster_level,emergency_response:line.emergency_response,phases:line.phases,antistop:line.antistop,Disaster_classification:line.Disaster_classification,occurrence_time:line.occurrence_time,Scale_of_the_event:line.Scale_of_the_event,accident_spot:line.accident_spot,casualty:line.casualty,Event_duration:line.Event_duration,financial_loss:line.financial_loss,nationality:line.nationality,immediate_cause:line.immediate_cause,remote_cause:line.remote_cause})
创建索引：CREATE CONSTRAINT ON (c:Affair)
ASSERT c.title IS UNIQUE
创建标签：LOAD CSV WITH HEADERS  FROM "file:///new_node.csv" AS line  
CREATE (p:NewNode{title:line.title})
创建关系：LOAD CSV  WITH HEADERS FROM "file:///Entity.csv" AS line
MATCH(entity1:Affair{stype:line.entity1}) ,(entity2:NewNode{stype:line.entity2})
CREATE (entity1)-[:RELATION { type: line.relation }]->(entity2)
清空数据库：
MATCH (n)-[r]-()
DELETE n,r
LOAD CSV WITH HEADERS  FROM "file:///subject.csv" AS line  
CREATE (p:Subject{subject:line.subject,subject_type:line.subject_type})

LOAD CSV WITH HEADERS  FROM "file:///object.csv" AS line  
CREATE (p:Object{object:line.object,object_type:line.object_type})

LOAD CSV  WITH HEADERS FROM "file:///predicate.csv" AS line
MATCH(entity1:Subject{subject:line.subject}) ,(entity2:Object{object:line.object})
CREATE (entity1)-[:RL { type: line.predicate }]->(entity2)



地址：https://juejin.im/post/6844904040564785165

## 一、增加节点

​    Neo4j使用的是create 命令进行增加，就类似与MySQL中的insert。

###     1.创建一个学生节点（只有节点，没有属性）：

​		create (s:Student)
​    不难看出 create 的语法如下：
​		create (<node-name>:<label-name>)
​		node-name：它是我们要创建的节点名称
​		label-name：它是我们要创建的标签名称

### 2.创建一个学生节点（创建具有属性的节点）

```cypher
创建一个id为10000，名字为张三，年龄为18岁，性别为男的学生节点
	create (s:Student{id:10000, name:"张三",age:18,sex:1}) 
	说明我们创建了一个具有id，name，age，sex四个属性的s节点。
创建带属性的节点语法如下：
create (<node-name>:<label-name> {
	<property1-name>:<property1-Value>,
	<property2-name>:<property2-Value>,
	...,
	<property3-name>:<property3-Value>
	})
property1-name就是属性名称，property1-Value就是属性值。
```
## 二、查询

​	Neo4j使用的是match ... return ... 命令进行查询，就类似与MySQL中的select。

### 1.全部查询学生

​		match (s:Student) return s

### 2.查询全部或者部分字段

​	只需要把要展示的字段以 节点名 + 点号 + 属性 字段 拼接即可，如下：
​		match (s:Student) return s.id,s.name,s.age,s.sex

### 3.查询满足年龄age等于18的学生信息

​	match (s:Student) where s.age=18 return s.id,s.name,s.age,s.sex

### 4.查询出所有的男生(sex=1)并按年龄倒叙排序

​	match (s:Student) where s.sex=1 return s.id,s.name,s.age,s.sex order by s.age desc

### 5.查询出名字不为null，且按性别分组

  这里要注意一点，CQL中的分组和SQL是有所差异的，在CQL中不用显式的写group by分组字段，由解释器自动决定：即未加聚合函数的字段自动决定为分组字段。
	match (s:Student) where s.name is not null return s.sex,count(*)

### 6.union联合查询（查询性别为男或者女的，且年龄为19岁的学生）

​	match (s:Student) where s.sex=1 and s.age=19 return s.id,s.name,s.sex,s.age 
​	union 
​	match (s:Student) where s.sex=0 and s.age=19 return s.id,s.name,s.sex,s.age
  	有union，当然也有 union all，这两个的区别和SQL中也是一样的。
 	 union：对两个结果集进行并集操作，不包括重复行；
​	  union all：对两个结果集进行并集操作，包括重复行；

### 7.分页查询（每页4条，查询第3页的数据）

​	match (s:Student) return s.id,s.name,s.sex,s.age skip 8 limit 4
​	上面CQL中的skip表示跳过多少条，limit表示获取多少条。每页4条，查询第三页的数据，也就是跳过前8条，查询4条，或者说从第8条开始，不包括第8条，然后再查询4条。

### 8.in操作（查询id为10001和10005的两个数据）

​	match (s:Student) where s.id in [10001,10005] return s.id,s.name,s.sex,s.age
​	需要注意的是，这里 用的是中括号，和SQL中是有区别的。



## 三、增加关系

​	上面我们介绍了增加单个节点和查询的知识点。这里我们介绍下增加关系。为了存在关系，我们先创建一个老师节点。
​	创建一个教语文的年龄为35岁的男的王老师：
​		create (t:Teacher{id:20001,name:"王老师",age:35,sex:1,teach:"语文"}) return t 
​	1.假设王老师所教的班级有3个学生：张三、李四、王五，这里我们就要创建王老师 和 3个学生的关系，注意，这里是为两个现有节点创建关系。
​		match (t:Teacher),(s:Student) where t.id=20001 and s.id=10000 
​		create (t)-[teach:Teach]->(s)
​		return t,teach,s
​	这样，王老师和张三的关系就创建了。下面，我们再继续创建王老师 和 李四、王五的关系。
​		match (t:Teacher),(s:Student) where t.id=20001 and s.id=10001 
​		create (t)-[teach:Teach]->(s)
​		return t,teach,s
​		match (t:Teacher),(s:Student) where t.id=20001 and s.id=10002 
​		create (t)-[teach:Teach]->(s)
​		return t,teach,s

### 	不难发现，创建关系的语法如下：

​		match (<node1-label-name>:<node1-name>),(<node2-label-name>:<node2-name>) 
​		where <condition>
​		create (<node1-label-name>)-[<relationship-label-name>:<relationship-name>]->(<node2-label-name>) 
​	或者
​		match (<node1-label-name>:<node1-name>),(<node2-label-name>:<node2-name>) 
​		where <condition>
​		create (<node1-label-name>)-[<relationship-label-name>:<relationship-name>{<relationship-properties>}]->(<node2-label-name>)
​		· node1-name表示节点名称，label1-name表示标签名称
​		· relationship-name表示关系节点名称，relationship-label-name表示关系标签名称
​		· node2-name表示节点名称，label2-name表示标签名称
​	2.我们给广东和深圳创建关系，深圳是属于广东省的。但是并没有广东省份节点和深圳市节点，没错，我们就是为两个不存在的节点创建关系。
​		create (c:City{id:30000,name:"深圳市"})-[belongto:BelongTo{type:"属于"}]->(p:Province{id:40000,name:"广东省"})
​		我们查询下我们创建的深圳和广东的关系。
​		match (c:City{id:30000,name:"深圳市"})-[belongto:BelongTo{type:"属于"}]->(p:Province{id:40000,name:"广东省"}) return c,belongto,p

### 	为两个不存在的节点创建关系的语法如下：

​	create (<node1-name>:<label1-name>
​		{<property1-name>:<property1-Value>,
​		<property1-name>:<property1-Value>})-
​	[(<relationship-name>:<relationship-label-name>{<property-name>:<property-Value>})]
​	->(<node2-name>:<label2-name>
​		{<property1-name>:<property1-Value>,
​		<property1-name>:<property1-Value>})
​		当然，属性都非必填的，只是为了更加准确。

### 3.如果我们要查询Neo4j中全部的关系需要怎么写CQL呢，如下：

​	match (a)-[b]-(c) return a,b,c

## 三、修改

​	Neo4j中的修改也和SQL中的是很相似的，都是用set子句。和es一样，Neo4j CQL set子句也可以向现有节点或关系添加新属性。
​	通过上面的查询，我们已经熟记了学生张三的年龄是18岁，2020年了，张三也长大了一岁，所以我们就需要把张三的年龄改为19。
​		match (s:Student) where s.name="张三" set s.age=19 return s

## 四、删除

​	Neo4j中的删除也和SQL中的是很相似的，都是delete，当然，除了delete删除，还有remove删除。

### 	1.删除单个节点

​		这里以删除学生节点中没有属性的来举例：
​		先查询下学生中没有属性的节点
​		match (s:Student) where s.name is null return s 
​		然后我们再删除这个节点：
​			match (s:Student) where s.name is null delete s 复制代码
​			把上面查询的CQL中的return 改为 delete 就OK了。

### 	2.删除带关系的节点

​	  这里我们以删除广东和深圳的关系来举例：
​		match (c:City{id:30000,name:"深圳市"})-[belongto]->(p:Province{id:40000,name:"广东省"}) return c,belongto,p

### 	3.删除全部节点已经关系

​	  这里这个CQL主要用作测试的，生产环境可不要执行，否则，真的是从删库到跑路了~
​		match (n) detach delete n

### 	4.删除节点或关系的现有属性

​	  可以通过remove来删除节点或关系的现有属性。
​	  例如，我们删除学生李四节点中的sex属性：
​		match (s:Student{id:10001}) remove s.sex

## [五.csv文件导入neo4j](https://www.jianshu.com/p/3acbf66bd0d0)

当需要导入大量的数据时，可以使用neo4j自带的neo4j-admin import工具来进行批量导入，但是该种方式只能用来导入一个全新的数据库，也就是建库的时候来使用。该种导入方式的数据来源是csv文件，下面会具体通过实例来介绍整个的流程，

### 1、首先我们需要准备导入的csv文件

我们知道neo4j中的数据主要分为节点数据和关系数据，那么csv文件中也就分为节点文件和关系文件。

当系统要导入csv文件的时候，读取文件的第一行必需是数据域信息，用来表示该文件中各列的具体意思，当csv文件是节点文件的时候，必要要包含的是ID域（:ID），用来表示节点的id信息，当csv文件是关系文件的时候，必需包含的是(:START_ID),(:END_ID)，(:TYPE)分别用来表示关系的开始节点id，结束节点id和关系类型。

图1是节点csv文件的数据域信息，数据域的定义方式<name>:<ID/type>，这里定义了3个属性，其中movieId是之后用来创建关系的id, :LABEL是可选项，用来对节点来进行标记，当一个节点有多个标签的时候，可以采用;来进行分割，例如：电影;喜剧。

![img](https:////upload-images.jianshu.io/upload_images/2106676-7983042549ab0ed9.png?imageMogr2/auto-orient/strip|imageView2/2/w/537/format/webp)

图2是节点csv文件的具体数据信息，这里需要注意的就是数据域和数据的对应关系，并且ID域中的信息必需是全局唯一的，这个全局唯一后面会进一步讲解。这样我们就准备好了电影节点csv文件。



![img](https:////upload-images.jianshu.io/upload_images/2106676-f0f9db476817dacb.png?imageMogr2/auto-orient/strip|imageView2/2/w/503/format/webp)

类似，图3是演员节点csv文件的数据域和数据。



![img](https:////upload-images.jianshu.io/upload_images/2106676-e16c7195da283bbe.png?imageMogr2/auto-orient/strip|imageView2/2/w/490/format/webp)

图5是关系csv文件的数据域，数据域必需包含(:START_ID),(:END_ID)，(:TYPE)这三个，分别用来表示开始节点、结束节点和类型。



![img](https:////upload-images.jianshu.io/upload_images/2106676-95774f077d9fee6d.png?imageMogr2/auto-orient/strip|imageView2/2/w/490/format/webp)

图6是关系csv文件的具体数据信息。



![img](https:////upload-images.jianshu.io/upload_images/2106676-51fa09066b66398e.png?imageMogr2/auto-orient/strip|imageView2/2/w/490/format/webp)

这里需要注意，数据的头和内容可以分别写在两个不同的csv文件中，也可以写在一个文件中，当一个头信息只是对应一个内容信息的时候，可以考虑写在一个文件，当一个头信息对应多个内容信息文件的时候，可以考虑将头文件放在一个单独的文件中。我这里是将头文件和内容文件分开来表示。

### 2、将数据导入到数据库中

导入数据的具体命令如下：

  neo4j-admin import [--mode=csv] [--database=<name>]

​              [--additional-config=<config-file-path>]

​              [--report-file=<filename>]

​              [--nodes[:Label1:Label2]=<"file1,file2,...">]

​              [--relationships[:RELATIONSHIP_TYPE]=<"file1,file2,...">]

​              [--id-type=<STRING|INTEGER|ACTUAL>]

​              [--input-encoding=<character-set>]

​              [--ignore-extra-columns[=<true|false>]]

​              [--ignore-duplicate-nodes[=<true|false>]]

​              [--ignore-missing-nodes[=<true|false>]]

​              [--multiline-fields[=<true|false>]]

​              [--delimiter=<delimiter-character>]

​              [--array-delimiter=<array-delimiter-character>]

​              [--quote=<quotation-character>]

​              [--max-memory=<max-memory-that-importer-can-use>]

​              [--f=<File containing all arguments to this import>]

​              [--high-io=<true/false>]



这里我还是通过例子来讲解：

目前我手头的文件包括：

---movieNode_header.csv电影节点头文件

---movieNode.csv电影节点内容文件

---personNode_header.csv演员节点头文件

---personNode.csv演员节点内容文件

---relationshipPM_header.csv关系头文件

---relationshipPM.csv关系文件

所有的文件我放在import目录中，采用命令：

```neo4j
`neo4j-admin import --database=graph01.db --nodes="import/movieNode_header.csv,import/movieNode.csv" --nodes="import/personNode_header.csv,import/personNode.csv" --relationships="import/relationshipPM_header.csv,import/relationshipPM.csv"  --multiline-fields=true`
```

其中：

--database=graph01.db代表我要建立的数据库的名字为graph01.db，这里需要注意，graph01.db必需为全新的，如果该库已经存在的情况下，会无法导入。

--nodes代表要导入的文件为节点文件，当有多个导入文件的时候，使用,来进行隔开，当如果头文件是单独文件的时候，必需将其放在内容文件的前面，否则会无法导入。

---relationships代表要导入的文件为关系文件，当有多个关系文件导入的时候，使用,来进行隔开，当如果头文件是单独文件的时候，必需将其放在内容文件的前面，否则会无法导入。

--multiline-fields=true代表如果某属性中的数据内容有多行时，可以成功导入。

![img](https:////upload-images.jianshu.io/upload_images/2106676-ad8457d767157894.png?imageMogr2/auto-orient/strip|imageView2/2/w/1131/format/webp)

![img](https:////upload-images.jianshu.io/upload_images/2106676-759318b711d9ae40.png?imageMogr2/auto-orient/strip|imageView2/2/w/1131/format/webp)

如图提示，导入成功。

### 3、通过浏览器查看导入的数据

启动数据库，通过浏览器查看导入的数据情况，可以看出，数据已经全部导入成功了。

![img](https:////upload-images.jianshu.io/upload_images/2106676-88ac3c13d05fbc41.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

### 4、注意事项：

4.1、:ID字段的内容在全部导入文件中不能有任何的重复。

4.2、该导入方式适合大规模数据的初始化建库，如果是要增量数据导入或者数据规模不大，可以考虑其他的导入方式。可以看到，对于1000多万个节点，导入也就2分钟不到的时间。



![img](https:////upload-images.jianshu.io/upload_images/2106676-54d17484c5dd9a9d.png?imageMogr2/auto-orient/strip|imageView2/2/w/1113/format/webp)



