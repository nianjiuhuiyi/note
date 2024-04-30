nosql介绍：
不支持SQL语法，noql中存储的数据都是KV形式，nosql基本不支持事务
常见的有：Mongodb、Redis、Hbase hadoop、Cassandra hadoop



Redis是C语言编写的，[redis命令大全](http://doc.redisfans.com/)



redis可视化软件：Redis Desktop Manager  ：[csdn](https://blog.csdn.net/csy2005csy/article/details/119914119)的下载安装介绍。[github](https://github.com/uglide/RedisDesktopManager/releases/tag/0.9.3)上的下载地址。（好像以前是免费发行版本，后来要收费了，应该可以自己去编译一个）。还有[这个](https://redis.tinycraft.cc/zh/)。



redis命令参考文档：[这里](http://doc.redisfans.com/)。



redis还可以搭建主从、集群这些，但是就不写了，如果以后遇到，在视频里来看吧

python要和redis集群交互需要pip install redis-py-cluster  # 这些都在视频里



redis数据是存放在内存中的，所以快，下面配置也讲到可以持久化的一种操作

## 一、安装配置

1、可以直接搜索redis的菜鸟教程，跟着走就行了，很简单

2、源码安装 （ubuntu直接命令行安装就好了）

```
1、先从readis下载好源码，然后解压
tar -zxvf redis-6.0.9.tar.gz -C /opt

2、cd /opt/redis-6.0.9
make    # 直接make编译

3、做一下测试（应该不是必须的吧）
make test  
可能会报错 Redis安装报错：“You need tcl 8.5 or newer in order to run the Redis test”
问题解决办法；(可百度)
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/tcl-8.5.13-8.el7.x86_64.rpm
rpm -ivh tcl-8.5.13-8.el7.x86_64.rpm
make && make test         （make test可能需要一些时间）

4、执行  make install
会安装到这个   /usr/local/bin   目录下
ls -rth  就会看到这些安装的东西
- redis服务器：redis-server
- 命令行客户端：redis-cli
- redis性能测试工具：redis-benchmark
- AOF文件修复工具：redis-check-aof
- RDB文件检索工具：redis-check-rdb
```

3、启动：一般都是可以直接`redis-server`启动(默认连接主机及默认端口)，# 这也不会用自带的那个redis.conf
	   也可以指定配置文件，比如：`redis-server   /opt/redis-6.0.9/redis.conf`这种。

- redis-server --help  # 查看帮助
- 进入类似mysql的客户端就是`redis-cli`   # 后面可以跟参数，连接到哪个ip或端口，
  用 redis-cli --help 查看帮助信息，然后默认是连接到0号数据库（如果bind到本机IP地址，而不是127.0.0.1，那就要用-h指定ip地址，默认的是127.0.0.1）
- 如果是命令行安装的那种，就可以用 service redis start  或是 systemctl stop redis 这种来启动

ps：一般来说用户安装可执行文件，就是放在/user/local/bin，好像系统可执行文件就是在 /user/bin

---

redis配置文件redis.conf部分核心参数详解：

- 绑定ip：如果需要远程访问，可将此行注释，或绑定一个真实ip

  > bind 127.0.0.1 -::1  # 这是默认的
  >
  > bind 192.168.125.135  10.0.0.1  # listens on two specific IPv4 addresses
  >
  > bind *       # 应该就是所有的ipv4地址都可以访问

  注意：设置了还访问不了，应该就是防火墙把端口屏蔽了，firewall-cmd --add-port=6379/tcp --permanent，然后再 firewall-cmd --reload

- 端口，默认为 6379

- 是否以守护进程运行（不是守护进程，那会在当前终端进行阻塞，默认no，推荐yes）

  > daemonize no           # 设为yes让其在后台运行

- 数据文件名字（数据持久化时会写到dump.rdb这个文件里）

  > dbfilename dump.rdb   # 默认的

- 数据文件(上面的dump.rdb)存储路径

  > dir ./     # 默认是存在当前文件夹下，可以去改，改成别的目录的话，一定要确保其先被建立了

- 日志文件

  > logfile ""     # 这是默认的，建议放在 logfile "/var/log/redis/redis-server.log"  # 路径需要自己建立

- 数据库，默认有16个(编号0-15，默认是0)

  > databases 16

## 二、数据类型及操作

### 2.1. 通用的 键命令

键命令：对所有的类型都管用。

链接后，可以用`select 5`这样来选中编号为5的数据库(一般是有16个，编号0-15，默认是0)



`keys  正则表达式`
查看所有的键：`keys  * `   , 所有以a开头的键：`keys  "a*"  `

判断键是否存在，存在返回1，不存在返回0：`exists  key1`

查看对应值得类型：`type key1`

删除：`del  key1  key2`

在创建时没设置时间，键会一直存在，可以后面添加过期时间：`expire  "name"  2`  # （这就是把 name 的过期时间设置为2）

查看key有效时间，以秒为单位：`ttl key`

### 2.2. 五种数据类型

#### 2.2.1 String

字符串类型是Redis中最为基础的数据存储类型，它在Redis中是二进制安全的，
这便意味着该类型可以接受任何格式的数据，如JPEG图像数据或Json对象描述信息等。
在Redis中字符串类型的Value最多可以容纳的数据长度是512M。

1、设置键值：`set key value`   (如果key存在就是修改，不存在就是添加)
设置键为name值itcast的数据：set name itcast

2、取值：`get key1` : get name 

3、设置多个值：`mset key1 value1 key2 value2 key3 value3`     # 注意是mset
4、取多个值：`mget key1 key2 key3`       # 注意是mget

5、值追加：`append key value`     # 在已存在的键key，对应的值追加value，结果还是字符串，变长了)

6、设置键值及过期时间，以秒为单位：`setex key time value`  :  setex age 10 23    (10后就不在了，就取不到了)

#### 2.2.2 hash类型

hash用于存储对象，对象的结构为属性、值（值的类型必须是string）

1、设置单个属性：`hset key field value`   # 设置键user1的属性name为zhangsan

2、设置多个属性：`hmset key field1 value` 1 field2 value2 field3 value3

3、获取指定键所有的属性：`hkeys  key`      # hkeys  user2

4、获取一个属性的值：`hget  key  field`      # hget user2 name

5、获取多个属性的值：`hmget key field1 field2`     # hmget user2 name age

6、获取键 user2 所有属性的值：`hvals user2`

7、删除整个hash键及值，使用del命令：`hdel key field1 field2`
删除属性，属性对应的值会被一起删除

#### 2.2.3 list类型

列表的元素类型为string
按照插入顺序排序
1、在左侧插入数据：`lpush key value1 value2 value3`
从键为 'a1' 的列表左侧加入数据a、b、c       lpush a1 a b c     #可以想得通，这是的结果就是c、b、a

2、在右侧插入数据：`rpush  key  value1  value2  value3`

3、在指点元素的前或后插入新元素：`linsert key1 before或after 现有元素 新元素`   # linsert a1 before b 3   (在列表a1的b元素前加入3)

4、查看列表所有数据：`lrange key1 start stop`       # lrange key1 0 -1    就是看全部   （start stop是索引，可以是负数）

5、设定指定索引位置的元素值：`lset key1 index value1`       # 修改键为a1的列表中下标位1的元素值为‘z’：lset a 1 z

6、删除，将列表中前count次出现的值为value的元素移除：`lrem key count value`    # (count>0:从头往尾；count<0:从尾往头；count=0:移除所有)

#### 2.2.4 set|zset(有序)集合

  (1)无序集合，元素为string类型，对于集合没有修改操作
1、添加元素：sadd key1 memeber1 memeber2 member3...      # 向建'a3' 的集合中添加元素"zhangsan"、"lis"、"wangwu"：sadd a3 zhangsan lisi wangwu

2、获取所有的元素：smemebers key1    # smemeber a3

3、删除元素：srem key1 member1 member2...    # srem a3 "zhangsan"

---

  (2)有序集合(zset)
元素为string类型，每一个元素都会关联一个double类型的score，表示权重，通过权重将元素从小到大排序，也没有修改操作
1、添加：`zadd key1 score1 member1 score2 member2...`    # 向键'a4'的集合中添加元素'lisi' 、'wangwu'、 'zhouliu'、 'zhangsan'，权重分别设为4、5、6、3： zadd a4 4 lisi 5 wangwu 6 zhaoliu 3 zhangsan

2、获取键的所有元素：`zrange key1 start stop`      # zrange a4 0 -1  (获取a4所有元素)

3、返回score值在min和max之间的成员：`zrangebyscore key1 min max`      # 获取建'a4'的集合中权重值在5和6之间的成员：zrangebyscore a4 5 6

4、返回成员member的score值：`zscore key1 member1`         # zscore  a6  zhangsan

5、删除指定元素：`zrem key1 member1 member2...`

6、删除权重在指定范围的元素：`zremrangebyscore key1 min max`

## 三、Python的交互

安装：pip install redis

```python
from redis import StrictRedis

sr = StrictRedis(
    host="192.168.125.135",
    port=6379,
    db=5
)
print(sr.get("name"))
# 设置一个键值对
ret = sr.set("hobby", "study")
print(ret)  # bool值，成功会打印True
```

- 还有其它的类型，StrictRedis这是字符串的；
- db是int代表用的几号数据库；
- 然后实例化方法的名字跟前面讲的命令行的命令几乎是一样的。


