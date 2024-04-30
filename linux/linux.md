---
typora-copy-images-to: illustration
typora-root-url: illustration
---

- 服务器快速关机命令：`init 0`   init 6 重启

- 获取md5值：
  
  - linux：md5sum a_filename  # (在mac上，直接用 md5 命令就行)
  - Windows：certutil -hashfile a_filename MD5
       certutil -hashfile a_filename SHA1
  
- 形化界面和命令行界面切换的方式：

  1. 第一种：
     - 图形 --> 命令：ctrl+alt+F2
     - 命令 --> 图形：startx
  2. 第二种：

  - 图形 --> 命令：init 3
  - 命令 --> 图形：init 5
  
- 当遇到I/O性能问题时，可以使用iostat、iotop、blktrace等工具分析。

- linux下详解shell中>/dev/null 2>&1  [这里](https://www.cnblogs.com/ultranms/p/9353157.html)。

- nmap localhost 可以获取当前有哪些端口正在使用(但可能还是有防火墙，不能访问相关服务)。

  - nmap -sP 192.168.108.0/24  这就是查看局域网内所有联网机器的IP

- 查看端口：netstat -apn | grep 8080    -t是tcp端口，-u是udp端口   
  （win上是用的 netstat -an）

- **关于Mingw和MSYS以及MSYS2的简单介绍，[这](http://c.biancheng.net/view/3868.html)** 

- nvidia-smi命详解：[这](http://blog.chinaunix.net/uid-20329764-id-5852379.html)。

- PVE虚拟机，显卡直通，跟esxi是类似的，ESXI6.7各个版本下载[地址](https://blog.whsir.com/post-5720.html)。

- NixOS 是一个 Linux 发行版，它有一个系统配置文件，记录所安装的软件。只要有这个文件，就能还原出一模一样的系统。安装介绍[地址](https://borretti.me/article/nixos-for-the-impatient)。

## 0.0. 快捷键

可参考[这里](https://www.bilibili.com/video/BV1WX4y1x7Cd?t=9.1)。基本已经写到了下面

1. 输入文件或目录名字的前面的字符，就可以使用tab来自动填充；
   当tab后没有自动填充出来，那就是说有多个都是以这开头的，就需要再tab一次，系统就会把以这开头的列出来。
   
2. 使用上下键可以快速选择前面使用过的命令，若要退出，就使用ctrl+c。
   在服务器使用vim编辑py文件时，缩进一定要用空格来，千万别用tab，看起来是对齐的，但是系统是会报格式错误的，python要得是4个空格的缩进，tab的制表符是不对的（除非去设置）。
   
3. ==双击文件名复制，中键粘贴==.

4. xshell上输入命令后：

   - ctrl+a 快速回到行首，ctrl+e 回到行末；
- ctrl+w 可以删除光标前面的一整个单词；
   - ctrl+r 进入搜搜索模式，输入要查找的命令的部分，反复按ctrl+r它会一直向上查找，如果找到自己要的：直接回车是执行、或者按键盘的向右->，它会把命令放界面，然后就可以做修改。（这个还能查找包含有的命令）
  同理的还有：比如查找包含 vi 的，先在键盘上输入vi，然后按 PgUp 或 PgDn 向上向下查找。（这个只能查找以 vi 开头的，上面的 nvidia-smi 这种包含的都可以）
   - 注：ubuntu默认没开启PgUp、PgDn的使用，打开方法
       sudo vim /etc/inputrc +40   然后去到里面把41行、42行的注释#号去掉，重启终端就可以了。 
- ctrl+u 可以删除光标前所有内容，ctrl+k 删除光标后所有内容；
     ctrl+y 可以把之前删的全部找回来
   - ctrl+l 清屏（同样的还有 clear 命令）


## 01. cp

`cp /home/nianjiuhuiyi/123.txt .`   #注意后面那个点，这就是把前面那个绝对路径下的文件复制到当前文件夹下

`-i`：复制的时候，要是有同名文件会给提示，会安全一些
`-r`：复制目录，`cp -r  abc  test`，如果test路径不存在，就相当于把abc全复制过来，然后改名成了test，里面的东西都不会变，如果路径test存在，就是是直接把abc放进test。

## 02. mv

mv重命令的时候，也加一个  -i  要是有同名文件存在，会提示，这样才不会覆盖，保险一些

参数`-u`：意思就是update，当把文件从一个目录移动另一个目录时，只是移动不存在的文件，或者文件内容新于目标目录相对应文件的内容。

- 移动多个文件到一个地方：`mv a.txt b.txt c.txt  mv_directory`;
- 递归创建文件夹：`mkdir  -p   ./a/b/c `;
- 同时创建几个目录：`mkdir  dir1 dir2 dir 3`;

## 03. 查看文件内容

### 3.1. cat

直接显示全部内容：`cat 123.txt`;一些可加参数：

- -b：可以在每行前面显示行号，==忽略空行==;
  - `nl 123.txt`可达到一样的效果
- -n：也是显示行号，这个是会把==空行也算上==;

#### 查看cuda、cudnnn版本

1. 命令：

> - cuda：nvcc --version 或者 nvcc -V
> - cudnn：cat /usr/local/cuda/include/cudnn_version.h | grep CUDNN_MAJOR -A 2   # 后面的版本信息换了，以前是放在cudnn.h文件中

2. 使用pytorch

> import torch
>
> print(torch.version.cuda)
> print(torch.backends.cudnn.version())

#### 查看cpu核心数

- cpu个数：cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l
  	或者：grep 'model name' /proc/cpuinfo  | wc -l
- (单个cpu)核数：cat /proc/cpuinfo | grep "core id" | sort | uniq | wc -l
- (总)线程：cat /proc/cpuinfo | grep "processor" | sort | uniq | wc -l
- 也可以直接：lscpu 或者 nproc

#### .sh脚本中输出一段文字

比如demo.sh就可以在最前面写上：

```bash
cat <<EOF

=============================
== Triton Inference Server ==
=============================
NVIDIA Release ${NVIDIA_TRITON_SERVER_VERSION} (build ${NVIDIA_BUILD_ID})
其它的内容，全是提示性的东西。写在最前面，脚本运行的时候就会把这段内容输出出来

EOF
```

### 3.2 more

`more 123.txt`：只显示一屏，通过(enter下一行)，也可以(空格，f，来下一页)，(b上一页，q退出)

### 3.3 less

less用于查看比较大的文件：`less filename.txt`;

- 上下换行
- b 向上翻页；空格 向下翻页
- G 最后一行；g第一行(注意Vim是gg第一行)
- /zhangsan   #向前查找指定的字符串，使用`n`来滑动到找到的字符串的下一个
- q 退出

## 04. tree

​	tree直接就会输出当前文件夹下的文件目录结构，也可以tree  其他路径;
​	tree -d就是只到最后一级文件夹。
​	tree -L 1 /data    # 只看一级

## 05. alias

`cd /root/songhui; mkdir abc; cd abc; mv /root/123.txt .  `       linux下是可以把多个命令放在同一行上，命令之间用`;`隔开，然后执行的，但较长的话，每次都输出就很繁琐，所以：

==alias 给一堆命令起别名== 
	比如上面那行的几个命令，我想直接完成，可以将那串命令起一个别名，但是这个别名起之前用`type 别名`，看看系统有没有在使用这个别名，没有的话就是：`alisa  foo='cd /root/songhui; mkdir abc; cd abc; mv /root/123.txt . '`;

​	那么`foo`就是别名，在其他地方就能用了,注意后面那串命令整体是用英文的单引号括起来的
​	删除别名：`unalias foo`;
​	要查看所有定义在系统环境中的别名，使用不带参数的 alias 命令,即直接alias;

Tips：起的别名仅对当前终端有效，退出就没有了，若想一直有效，就可以把这添加到配置文件中去。

## 06. 查看存储情况

- `cd -`：在最近的两次目录间切换;

- `df`：查看磁盘使用情况;    
- `free`：查看内存的使用情况;
- `du`：当前目录层层往下，直到最后一级目录，列出各个文件夹所占的大小;可以加一些参数
  - `-s`：一般是`du -sh /root/home`就会得到这整个文件夹的大小;
  - `--max-depth=1`：获得指定路径下的所有一级目录的大小，不会向下递归;
    这个的同等替代是：`-d  1` 跟上面的--max-depth=1 是一样的用法
    - PS：和这个命令是不会显示文件的，只会得到文件夹;
    - 这不能跟-s联用。
  - 建议直接使用`du -sh  *`这个命令来获取当前目录下各个文件/文件夹的大小

## 07. ls

- `-i`：可以在最前面展示（文件索引节点）的信息，节点信息相同的就是同一文件（哪怕名字不同）;

- `-h`：友好显示文件大小;

- `-a`：显示所有的文件，包括隐藏文件（在linux里，凡是以 . 开头的文件都是隐藏文件）

- `-l`：把文件夹下的文件竖直排列（-h是把文件大小友好的展示出来，必须搭配-l使用）

### 搭配通配符查找

​	搭配通配符`ls -l  *abc*`：这就是列出所有包含abc文件名的文件，*通配任意个(包括0个)任意字符)
​	列出`ls -l  a?c.txt`：这就是列出名为`a  c.txt`的文件，中间的问号通配==1个任意字符==)

Tips：

- 这里后面查找的内容一定==不能加引号==;
- 最好的用法，还是，只是查找==当前路径==下的==文件==，也不会向下去递归查找。

## 08. kill 查看、杀死进程

- ps：只查看当前用户启动的进程
  - -au：建议这样使用，看的是所有用户进程，且较为详细
  - -aux：会看到所有的后台进程，包括一些系统的进程，太多了

`ps  -ef | grep  python`：就会查找得到所有的python的进程



kill  PID：就杀死这个进程，若是杀不掉，就

kill -9 PID：强行杀死这个进程

简单示例一：

kill -9 `ps -ef | grep demo/client_cli_ | awk '{print $2}'`   (这就是杀死所有demo/client_cli_ 的进程)

拆分：

- `ps -ef | grep demo/client_cli_`：得到这些进程的信息；
- `awk '{print $2}' ` 这再只取进程号(这里是英文单引号)；
- 最后再kill(特别注意kill -9  后面那段表达式是加了一对 ``,这里被格式化了，使用的时候注意要有)。

简单示例二：

> - ps -aux | grep python     # 如果此刻只有1个python进程，那这里的结果就会得到2个相关的，第2个是默认就会有的，不用关心
>- ps -aux | grep python | head -n 2   # 这就是代表要前两行
> - ps -aux | grep python | head -n -1 | awk '{print $2}'     # 这里就得到了这个进程的PID(这里是单引号)
>  - 一般常用head -n -1 这就代表除了最后一行，都要  # 现在用  grep -v grep 去掉

总结：所以一般是这样的方式来杀死进程：

```shell
# ps -aux | grep python | head -n -1 | awk '{print $2}' | xargs kill
ps aux | grep "python client_" | grep -v grep | awk '{print $2}' | xargs kill  # 
```

```shell
# kill `ps aux | grep python | head -n -1 | awk '{print $2}'`
kill `ps aux | grep "python client_" | grep -v grep | awk '{print $2}'`
```

## 09. 网络相关

- `ifconfig`：直接就查看或配置网卡配置信息
- `ping ip地址`：查看本机和ip地址的电脑是连接是否正常

通过ping 127.0.0.1测试本机网卡是否正常。，这也叫本地回环地址

​	==top== 实时动态显示进程占用信息，这个时候按1可以查看每个逻辑核的使用情况，b可以高亮；若要退出，就q;

​	端口号查询：`netstat -an`    (端口：0~65535 2的16次方 ，其中知名端口：0~1023)（更多看服务还是用的-nlp）

​	==临时改变IP地址==(假设原来的地址是192.168.125.125)，先找到要修改的网卡名称(假设是ens33)：`ifconfig ens33 192.125.128`那就是把ip地址临时更成了128，重启网卡或是服务器又会还原 

## 10. grep 搜索文本

grep搜索文本中是否包含某指定文本(等同于ctrl+f)，，
`grep nihao 123.txt`：就是在123.txt中搜索有nihao的行

- `-n`：显示行号
- `-i`：不区分大小写
- `-v`：-v取反，即找出不包含nihao的行
- `-r`：grep -r "要查找内容" /root   # 这就是一直向root下递归查找凡是包含了要查找内容的所有文件。

好比`grep -iv nihao 123.txt`;

grep允许对文本进行==模式查找==，又称为正则表达式

- `grep ^a 123.txt`：搜索以a开头的行
- `grep a$ 123.txt`：搜索以a结束的行

Tips:如果是找连续几个单词，且中间有空格，那得是`grep "hello python" 123.txt`  (查找的所有内容必须用引号括起来)

重要：grep -r "hello" /root/dir/   :就是获取指定路径下，凡是含有"hello"的文本

## 11. 重定向

​	比如tree或`ls -lh > log.txt`就是将本应在终端显示的内容写到log.txt中，这个log.txt不一定要存在，后面的文件如果存在，`>`是要覆盖文件内容的，而`>>`则是追加到文件最后面。

echo hello python 会在终端显示后面跟的内容，有点print的意思，通常配合重定向使用。
比如 echo hello > a.txt
或echo hello >> a.txt  
这就是把hello覆盖或追加到a.txt

## 12. 管道 |

​	把前面命令的结果，输出给后面的命令再处理后显示出来，通常后面用的更多的是more和grep，比如：

- `ls -lha ~ | more`：显示家目录下的所有文件，内容太多了，跟个more就分屏显示；
- `ls -lha ~ | grep  Do*`：就是显示在家目录下的所有文件中查找到Do开头的并且显示出来(这个结果还可以搭配重定向使用)

## 13. scp 文件传输

两台linux之间通过scp来传输文件，主要有两个参数：

- `-P`：指定端口号，默认是22，一般可以不指定;
- `-r`：传输文件夹时必须加这个参数。

简单示例：

1. 把远程nianjiuhuiyi用户的家目录下的桌面文件里的01.py复制到这台linux的当前位置(-P可不指定)：
   `scp -P 22 nianjiuhui@192.168.3.14:Desktop/01.py . `  # 有时候又要加端口才行
2. 把当前目录下名为demo的文件夹复制到远程的root目录下：
   `scp -r ./demo/ nianjiuhui@192.168.3.14:/root/` 

Tips:

- `:`后面的路径如果不是绝对路径，则以用户的家目录作为参照路径。
- window和linux之间传输文件还可以使用软件==FileZilla==。

## 14. ssh免密登录

​	linux是自带ssh的，两台linux，或是Mac之间可以直接通过ssh来连接操作，按以下步骤来：

有关SSH配置信息都保存在用户家目录的`.ssh`目录下。(C:\Users\Administrator/.ssh/id_rsa)

1. 免密登录

   - 配置公钥：执行`ssh-keygen`，一路回车即可生成SSH钥匙

   - 上传公钥到服务器：执行`ssh-copy-id -p port user@remote`,让远程服务器记住公钥(可能不用需要指定端口号，后面需要自己具体user的名字，及remote远程IP地址)

2. 配置别名

   ssh远程电脑时，即便不输入密码，每次也都要`ssh -p port user@remote`,比较麻烦，就可以通过==配置别名==来代替这一长串内容,在`~/.ssh/config`里追加以下内容：

   >Host 2080ti
   >	HostName 192.168.108.218
   >	User root
   >	Port 22        # 这项非必须
   >	IdentityFile "C:\\Users\\Administrator\\.ssh\\id_rsa"   # 私钥地址(注意双斜杠被转义了一根)

   保存之后就可以使用`ssh 2080ti`实现远程登录了，且`scp`同样可以使用。

Tips:

- 公钥名字为：`id_rsa.pub`；私钥名字为：`id_rsa`；
- 本地使用私钥对数据进行加密/解密
  服务器使用公钥对数据进行加密/解密
- 非对称加密算法
  使用公钥加密的数据，需要使用私钥解密
  使用私钥加密的数据，需要使用公钥解密

### 端口转发

​	SSH除了远程登录，还可以转发端口，这样就服务器端就可以不开启服务的端口，直接在win本地开一个ssh端口转发就好了，参考[这里](https://mp.weixin.qq.com/s/p6P8--5hiVb8Y_gNX20d2Q)：

简单在win上使用的命令是：ssh -f -N -L 8001:127.0.0.1:8001 root@192.168.108.218

- 前面省掉了本地的127.0.0.1,这就是把本地的端口8001和远程端口8001转发起来；
- 那win本地不能关运行这个命令的窗口。(-f -N 不是必须的)

> 常用参数
>
> - -C：压缩数据
> - -f ：后台认证用户/密码，通常和-N连用，不用登录到远程主机。
> - -N ：不执行脚本或命令，通常与-f连用。
> - -g ：在-L/-R/-D参数中，允许远程主机连接到建立的转发的端口，如果不加这个参数，只允许本地主机建立连接。
> - -L : 本地端口:目标IP:目标端口
> - -D : 动态端口转发
> - -R : 远程端口转发
> - -T ：不分配 TTY 只做代理用
> - -q ：安静模式，不输出 错误/警告 信息

注：除此之外，

- 还可以在服务器端运行转发，将自己的某个端口用ssh转发到某台机器上，相当于上面的反向操作（这就是远程转发(服务器运行命令转发到本地)吧，然后上面示例的命令就是本地转发(本地运行转发到服务器)）；
- 还可以设置跳板机的方式来做远程端口转发，-R，上面的教程里有讲到；
- ssh还可以直接远程在某台机器上进行命令操作，如：ssh root@192.168.13.149 'uname -a'

## 15. tar | unzip

### 15.1. unzip

`unzip image.zip -d unzipped_directory`：

​	后面的`-d`参数就是把文件压缩到后面的目录(没有会自动创建)(不指定压缩路径，默认为当前目录下)

`unzip -v test.zip | more`： 查看压缩文件目录，但不解压。

### 15.2. tar

- 打包：`tar  -zcvf   学习资料.tar.gz  01.py  02.py`  # 把01.py和02.py打包成一个.tar.gz文件;

​	其实tar是只打包，是不压缩的，一般来说是先生成.tar文件，再用gzip(或者bzip)来压缩，但是就比较麻烦了，是可以组合在一起使用的。

- 解压：`tar -zxvf   学习资料.tar.gz  -C  解压目录` 
  - `-C`：指定解压目录，且这个==解压目录一定要存在==，当然是可以不指定解压目录。
- 查看压缩包，但不解压：`tar -ztvf 学习资料.tar.gz | more`,核心参数就是 t

注：以上针对==.gz是用-zxvf==;如果是==.bz2或者.tbz就用-jxvf==;如果是==.xz就是用-Jxvf==(注意是大写的J)(就是把第一个字母z换掉)
    如果没用任何压缩算法，就是.tar包，就不要上面这个参数的第一个字母(代表压缩算法)就好。

以上都是和压缩一起使用，只是单纯打包，不压缩的话：tar -cvf  123.tar ./123/    # v代表显示过程

#### 排除部分文件打包

tar -zcvf 打包后的压缩包名称.tar.gz 文件夹路径&n --exclude=不想打包的文件夹1  --exclude=不想打包的文件
例如：
`tar -zcvf 20190919-bk-ecstore.tar.gz ./project  --exclude=./project/data --exclude=./project/public` 
注意:要排除一个目录是 --exclude=dir1，而不是 --exclude=dir1/     （是没有那个斜线的）

## 16. chmod

​	`chmod  +/-  rwx  文件/目录`：增加或减去文件或目录的可读可写可执行文件，若是文件可执行(在ls -l，文件前面有x就是可执行)，可以用 ./文件名 来执行。

修改文件权限的命令一般是这三个：

| 命令  |    作用    |
| :---: | :--------: |
| chown | 修改拥有者 |
| chgrp |   修改组   |
| chmod |  修改权限  |

- 修改文件|目录拥有者：`chown 用户名 文件名|目录名` 
- 递归修改文件|目录的组：`chgrp -R 组名 文件名|目录名` 
- 递归修改文件的权限：`chmod -R 755 文件名|目录名` 

Tips:

- chmod修改权限时，按照上面的方式并不能精确到 拥有者|组|其它用户，一改全改；

- 故可以使用3个数字来分别对应 拥有者|组|其它用户 的权限：

  `chmod  751 01.py`   (r:4,   w:2,  x:1)这样是改变  本用户权限|本组权限|其他用户权限  # 对文件夹都记得加一个 -R

|      | 拥有者 |      |      |  组  |      |      | 其它 |      |
| ---- | :----: | ---- | ---- | :--: | ---- | ---- | :--: | ---- |
| r    |   w    | x    | r    |  w   | x    | r    |  w   | x    |
| 4    |   2    | 1    | 4    |  2   | 1    | 4    |  2   | 1    |

对应权限的数字加起来的和就是这个拥有的权限，推荐使用吧。

## 17. find

​	平常最直接的用法：`find 路径  -name  "abc*"`，这就是查找指定路径中所有以abc开头的==文件==及==文件夹==，(若是不给路径，那就是默认搜索当前目录下)还有一些其他参数： # 因为find是精准查询，当名字不确定时，就可以在文件名前后都加一个*

- `-iname`：就是忽略大小写;
- 加一个`!`就代表取反，找不是这样的文件,用法：
  - find /hone ! -name "*.txt" 找不是txt结尾的;
- 基于目录深度搜索:
  - `find . -maxdepth 3 -type f` 向下深度限制为3的==文件==;
  - `find . -mindepth 2` 搜索出距离当前至少2个子目录的所有==文件以及文件夹==;

- `-type`：基于文件类型
  - f 普通文件
  - d 目录
  - l 符号连接    # 最常用的可能就是上面这三个
  - c 字符设备
  - b 块设备
  - s 套接字
  - p Fifo

简单示例：

- `find ./ -type f -name "*.txt" | xargs grep "140.206.111.111"`   # 路径一定要紧随find后面
  - 在当前目录搜索所有.txt文件，且其内容文件内容需要包含==140.206.111.111==这一内容;

Tips：

- 若是不给路径，那就是默认搜索当前目录下;
- 搜索的内容一定要加引号(找文件不要引号可以，找的是文件夹就一定要引号了，不然会找不到，故还是都统一给上引号吧)。

### 查找文件并删除

方式一：

- `find .  -type f -name "电力*" -delete`这就是查找当前目录下以==电力==开头的文件并删除(尽量要指定-type f，这个删除文件好用，但是有文件夹，且文件夹非空就无法删除);
- `find . -maxdepth 1 -name "电力*" -delete`   ==-maxdepth==参数可确保find仅在当前目录中有效，并且不会递归到子目录中

方式二：

​	rm -rf `find /usr/ -name *opencv*`：这就是删除所有名字包含opencv的文件 (后面那段表达式是加了一对 ``,这里被格式化了，使用的时候注意要有)。

方式三：

​	find /usr/ -name "gitlab" | xargs rm -rf ：这就是删除所有找到包含gitlab的文件。  # xargs针对多个命令的单行执行很有用，详情可看[这里](https://wangchujiang.com/linux-command/c/xargs.html)。(简单来说它就是把前面得到的结果标准化再传递给后面的命令)

总结：整体来看，只是删除文件使用第一种方法还是比较简单;但是涉及到文件夹的删除，那就用第三种方法，第三种方法中的xargs用来几个命令间的链接还是很有用的。

## 18. ln

### 18.1. 硬链接

​	简单来说，硬链接数目，就是能达到文件或目录有多少种方式，也是一种起别名：`ln 文件绝对路径  别名`；（试了相对路径也行）

​	再执行ls -l时，显示的数字就是2，然后把原文件删除了，这时ls -l的显示数字就是1了，而且硬链接也不会失效，还是能查看，就相当于是记录的文件存储地址，删除一个快捷方式(原文件名也可以看做是一个快捷方式)，还有一个自己创建的硬链接(也相当于是一个快捷方式)。
Tips:

- 一定得是文件，不能链接目录；然后删除硬链接就只是少了一个找到文件的指针；原文件名也可看成一个找到文件的指针；
- 硬链接的样式跟普通文件样式是一样的，无法区分出来，然后可以通过`ls -li`看到文件前面的数字，会是一样的。

### 18.2 软链接

ln -s  被链接的源文件(注意使用绝对路径，只是建议，并非强制，临时文件建议用相对路径)  链接文件名称

`ln  -s  /home/songhui/mmdetection/data   new_data`  : 这是目录之间，也可以是文件之间

​	来解释一下，这就相当于win中的快捷方式，"链接文件名称"就相当于那快捷方式的名称，例如:ln -s /home/Desktop/a/demo/123.txt a_快捷方式,
这就会在当前目录下创建那个绝对路径文件的快捷方式，因为绝对路径，移动也不会有影响。但是原文件要是删除了，软链接就会全部失效

Tips：

- 工作中通常只用软链接;
- 软连接也是可以接目录地址的，那就可以对这个软链接做目录的操作;若链接的是文件，那就可以对它做文件的操作;
- 删除文件的软链接，文件是还在的;软链接的样式就是带箭头的那种，若是目标文件被删除了，不在了，那这个软链接就会==变红==;

==特特特别注意==：

​	软链接的删除，`rm -rf  软链接名称`, 重点：使用tab自动补充时，后面会自动跟上 `/`，这样会删除源文件的，==故一定不能要这个`/`==,所以最好的办法还是就用粘贴复制，不要使用tab自动补充。

出现更好的方法了，直接使用`rm 软连接`,这样添加了/后就会说是目录不让删除，就不会误删了。



==软链接与硬链接的区别==:
	在linux里，文件内容和文件名称是分开存储的，软链接是文件名的快捷方式，当把文件名删了，软链接也就失效了，文件也就删了找不到了;

​	但是硬链接是直接指向文件存储的，跟文件名有着一样的功能，把文件名删了，文件还在，还可以通过刚创建的硬链接访问,只有当文件的硬链接为0时，文件就会被删除。

## 19. watch

​	`watch`常用于检测一个命令运行的结果，比如 tail 一个 log 文件，ls 监测某个文件的大小变化，常用的参数就：

- -n  3        # 就是每隔3秒来运行一下程序

- -d           # 会高亮显示变化的区域(different)

简单示例：

- `watch  -n 3  -d  nvidia-smi`  # 每隔3秒高亮显示显卡信息的变化

也可以`watch -n 1 -d tail -f nohup.out_capture_2`之类的尝试吧；

- `watch -n 1 -d netstat -ant`  # 每隔一秒高亮显示网络链接数的变化情况;

- `watch -n 1 -d 'pstree|grep http'` # 每隔一秒高亮显示http链接数的变化情况

说明：后面接的命令若带有管道符，需要加==单引号==将命令区域归整。

## 20. tail | head

`tail`命令可用于查看文件的内容，有一个常用的参数`-f`常用于查阅正在改变的日志文件。

- `tail -f filname`   # 会把 filename 文件里的最尾部的内容显示在屏幕上，并且不断刷新，只要 filename 更新就可以看到最新的文件内容
- tail -n 2 filename  那就会看到此文件的最后两行
- tail -n +2 filename  那就会从此文件第二行开始往后全部
- head -n 2  filename  这是看到文件的前面两行
- head -n -2 filename   这就是看到文件的倒数第二行往上的全部内容

## 21. 查看文件夹、文件个数

### wc命令

Linux wc 命令可以用来对文件进行统计，包括单词个数、行数、字节数

语法：wc [options] [文件名], options有如下：

- -c：character，统计字节数
- -w：word,统计单词数
- -l：line，统计行数

---

linux查看文件夹、文件个数：（中间的grep后面跟的正则表达式，^代表开头，wc只是统计）

- 查看当前目录下的`文件个数`：`ls -l | grep "^-" | wc -l`; 
- 查看当前目录下所有文件个数：`ls -lR | grep "^-" | wc -l`;  #(包括子文件夹里的文件)
- 查看当前目录下文件夹的个数：`ls -lR | grep "^d" | wc -l`;  # (前面大写的R代表递归)

Tips：可以在ls -l 后跟其它路径。

## 22. ip相关

dhclient    直接执行就是虚拟机获取一个自动IP地址，没有IP地址的时候执行一下这个命令。

相关具体ip修改可参见[这里](../git使用方法/git_bash.md)，在gitlab里面的内容。

## 23. nohup

先把要执行的命令(如python tools/train.py configs/faster_rcnn/faster_rcnn_r101_fpn_2x_coco.py --gpu-ids 1 )写成一个.sh文件，
再 chmod +x  名称.sh   给这个文件加上执行操作的权限

- nohup ./train.sh &           #这就是后台挂起运行，输出的内容都在同级目录下的nohup.out文件中(如果当前目录的 nohup.out 文件不可写，输出重定向到 $HOME/nohup.out 文件中。)

- nohup ./train.sh >> mynohup.out 2>&1 &     #这就是把输出的内容重定向到"mynohup.out"中， 后面的2>&1 &是固定不变的

注：可以用==jobs -l==查看当前终端启动的任务
注：可以通过tail -f nohup.out 来动态查看这个文件的内容的变化

script  train.log    # 这个可能是xshell终端自带的，也或许其它终端需要手动安装。
这个命令开启后，后面的所有终端输入的命令，以及得到的结果都会被记录在train.log

## 24. exec

这常用于shell脚本最后，比如启动python训练或是一个web服务之类的。比如“train.sh”

```sh
#!/usr/bin/env bash
source /root/anaconda3/bin/activate s_yolov5

exec python train.py --img 1024 --epochs 300 --data coco.yaml --weights ./yolov5m6.pt
```

执行：./tran.sh

- 这样加了exec后,执行到这，整个tran.sh进程会直接转到python进程去，此时ps aux | grep train.sh 是没有这个进程的；
- 反之不加 exec 在python进程结束之前，train.sh 进程也是一直存在的。
- 但注意 exec 一定要放最后，比如上面的脚本下面那怕还有很多内容，执行到第4行的exec，后面的都不会再执行的，因为这个脚本进程都没有了。

## 25. ctrl+z后台挂起

linux中巧用ctrl-z后台运行程序，[地址](https://www.cnblogs.com/wq242424/p/10349031.html)。放这吧，我感觉不是很好用。

## 26. ldd

可以使用ldd后跟程序或动态库名去查看一个程序或是.so动态库用了哪些依赖库，这些库的位置等相关信息，特别是在程序启动失败时，可看是那些库的缺失。

## 27. systemctl

这个命令是用于将程序注册成服务，以方便程序的开机自启动和意外中途退出后的自启。

无论是ubuntu还是centos，在"/lib/systemd/system/"这个路径下写一个以 .service 结尾的文件。

示例：sdg.service

```
[Unit]
Description=The AI service of SDG
# 启动顺序
After=basic.target network.target syslog.target
Wants=network.targetd

[Service]
Type=forking

Restart=always
RestartSec=10  # 重启时间
# 下面的运行脚本要给绝对路径，是可以传参数的
ExecStart=/home/sh/project/sdg/run.sh  v01

[Install]
# 被 multi-user.target 依赖
WantedBy=multi-user.target
```

- 添加完这个文件后，重载系统服务：sudo systemctl daemon-reload 
- 启动服务：sudo systemctl start sdg    # 这里写sdg或者sdg.service都是一样的
  启动后，可以用 systemctl status sdg 或是 journalctl -xeu sdg.service 去查看服务状态
- 如果要把这个服务停止：sudo systemctl stop sdg
- 如果要设置这个服务自启动：sudo systemctl enable sdg
             取消自启动： sudo systemctl disable sdg
- 关于systemctl更多的用法和参数，可看[这里](https://blog.csdn.net/qq_42862247/article/details/127260241)。

注意事项：

1. run.sh中，如果是python启动脚本，run.sh中可以写上类似“source /usr/local/anaconda3/bin/activate base”这样的语句来启动一个虚拟环境，但很大可能程序会启动失败，显示的报错原因是找不到第三方库，可以用`journalctl -xeu sdg.service`这个命令去查看详细报错原因。
   然而直接去运行run.sh脚本时又是ok的，那问题就是使用这种服务启动的方式，对应的python只会去加载类似“/usr/local/anaconda3”这个路径下的路径，而不会去加载用户目录下的第三方库的路径，暂时在脚本中不知道怎么解决。参考的这个[教程](https://blog.csdn.net/zkk9527/article/details/111353428)。
   现目前是通过在代码中添加这个路径来实现的：

   ```
   import sys
   sys.path.append("/home/dell/.local/lib/python3.11/site-packages")
   ```

2. 我常用的run.sh都是启python脚本，像受电弓一个shell脚本中启动多个python进程，以一个服务的方式也是能启动的，但是若是其中某个或几个进程意外挂了，那这个服务是不会去自动重启它的，就达不到要求。
   现目前systemctl写服务的方式，还是一个进程对应一个服务来使用。

## rsync 待定去写

## crontab 定时任务待写；

相关定时任务还可以看看这个[airflow](https://github.com/apache/airflow)项目，然后一些[介绍](https://zhuanlan.zhihu.com/p/412490488)。

