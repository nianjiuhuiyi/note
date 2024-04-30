## 一、g++基础使用

1. ==GCC 编译器==支持编译 Go、Objective-C，Objective-C ++，Fortran，Ada，D 和 BRIG（HSAIL）等程序；

实际使用中：

- 使用 gcc 指令编译 C 代码
- 使用 g++指令编译 C++ 代码

当执行完程序`./main`,在控制台再输入`echo $?`可获取返回状态

- 得到0就是标志成功
- 将代码main函数中改成return -1;(返回-1通常被当做程序错误的标识)，编译执行这个程序，并不会有异常，但再`echo $?`得到的状态值255

### 1.1 编译过程

1. ### 预处理-Pre-Processing       // .i文件

   >g++ -E test.cpp -o test.i  //.i文件
   >
   >\# -E 选项指示编译器仅对输入文件进行预处理;更多的是对程序中的宏定义等相关的内容先进行前期的处理

2. ### 编译-Compling         // .s文件

   >g++ -S test.i -o test.s
   >
   >\# -S 编译选项告诉 g++ 在为 C++ 代码产生了汇编语言文件后停止编译
   >\#  g++ 产生的汇编语言文件的缺省扩展名是 .s 

3. ### 汇编-Assembling   // .o文件

   >g++ -c test.s -o test.o
   >
   >\# -c 选项告诉 g++ 仅把源代码编译为机器语言的目标代码
   >\# 缺省时 g++ 建立的目标代码文件有一个 .o 的扩展名。

4. ### 链接-Lingking   // bin文件

   >g++ test.o -o test
   >
   >\# -o 编译选项来为将产生的可执行文件用指定的文件名g++

### 1.2 g++重要编译参数

#### 1.2.1 -g

- -g  编译带调试信息的可执行文件

  > g++ -g main.cpp
  >
  > // -g 选项告诉 GCC 产生能被 GNU 调试器GDB使用的调试信息，以调试程序。

#### 1.2.2 -O

- -O~n~  优化源代码       // n常为0~3

  > g++ -O2 main.cpp          // 这是大写的字母O
  >
  > - -O 同时减小代码的长度和执行时间，其效果等价于-O1;
  >
  > - -O0 表示不做优化;
  > - -O1 为默认优化;
  > - -O2 除了完成-O1的优化之外，还进行一些额外的调整工作，如指令调整等 ;
  > - -O3 则包括循环展开和其他一些与处理特性相关的优化工作。

  ​	-O 选项告诉 g++ 对源代码进行基本优化。这些优化在大多数情况下都会使程序执行的更快;所谓优化，例如省略掉代码中从未使用过的变量、直接将常量表达式用结果值代替等等，这些操作会缩减目标文件所包含的代码量，提高最终生成的可执行文件的运行效率。

  ​	-O选项的使用将使整个编译过程花费的时间更多，但通常产生的代码执行速度会更快。

  简单的例子：

  ```c++
  #include <iostream>
  int main() {
      unsigned long int counter;
      unsigned long int result;
      unsigned long int temp;
      unsigned  int five;
      for (counter = 0; counter < 2009 * 2009 *100 / 4 + 2010; counter += (10 -6) / 4) {
          temp = counter / 1979;
          for (int i = 0; i < 20; ++i) {
              five = 200 * 200 / 8000;
              result = counter;
          }   
      }   
      std::cout << result << std::endl;
      return 0;
  }
  ```

  以上代码是非常低效的，每次循环都要去计算那固定的值，可以以此测试，

  `g++ main.cpp -o out1`       `time ./out1`

  `g++ main.cpp -o out2 -O2 `    `time ./out2`  

  `time` 后面跟命令可以测试命令花费的时间，可以发现加了-O2参数的out2执行时间短很多。

#### 1.2.3 -l 和 -L (重要必看)

- -l 和 -L    指定`库文件` | 指定`库文件路径`

  > \# 链接一个名为`glog`的库：
  >
  > g++ -lglog main.cpp       //  -l后直接跟上库名，多个库的话就写多个 -l
  >
  > \# 链接名为`mytest`的库， libmytest.so在/opt/software/test/目录下
  >
  > g++ -L/opt/software/tes1/ -L/opt/software/test2/ -lmytest main.cpp

  注意：

  - -l和-L参数紧跟就是库名和地址，中间是`没有空格`的；(动态库有两个路径就给两个-L，空格隔开)
  - 在`/lib`、`/usr/lib`和`/usr/local/lib`里的库直接用-l参数就能链接，如果库文件没放在这三个目录里就需要用-L参数指定库文件所在目录。
  
- 重要：以写那个俄罗斯方块来说，需要一个库==ncurses==，一开始直接 g++ main.cpp -o main，

  - 直接执行，一般会得到这个错误：“fatal error: ncurses.h: No such file or directory”，这是缺少库ncurses,centos是需要yum安装ncurses-devel.x86_64;
  - 安装完后，直接再执行上面的编译命令g++ main.cpp -o main，会得到一堆“`undefined reference to`”的错误，这是因为并没有指定库。
  - 最终解决：g++ main.cpp -l ncurses -o main    // 一定要指定-l ncurses，或写一起-lncurses
    - 故：很多时候我们库安装好了，使用命令行编译，不会报找不到头文件的错了，但是会得到第二个错误 ，就是没有指定库，急着这个原因，出现好多次了。

#### 1.2.4 -I

- -I   指定`头文件`搜索目录

  > g++ -I/opt/home/myinclude main.cpp        // 也是-I后紧跟路径

  ​	说明：`/usr/include`目录一般是不用指定的,gcc知道去那里找，但是如果头文件不在此目录里我们就要用-I参数指定了，比如头文件放在/opt/home/myinclude目录里，那编译命令行就要加上-I/opt/home/myinclude参数了;

  ​	如果不加,应该就会得到一个"xxxx.h: No such file or directory"的错误。`-I参数可以用相对路径`，比如头文件在当前目录，可以用-I.来指定。上面我们提到的-cflags参数就是用来生成-I参数的。

#### 1.2.5 -D

- -D   定义宏     // 这很重要

  实例demo：

  ```c++
  #include <iostream>
  
  int main() {
      #ifdef MYDEBUG          // 名字自己随便起
          printf("debug log is on\n");       // 主要看这行是否执行
      #endif
          printf("it is off\n");        // 这行怎样都会执行的
      return 0; 
  }
  ```

  `g++ main.cpp`: 执行程序时，第5行代码并不会执行

  `g++ -DMYDEBUG main.cpp`: 第5行会执行，`-DMYDEBUG`就是在定义宏`MYDEBUG`，不给值，默认定义内容为字符串“1”；所以应该是可以定义为其它的，比如`-DMYDEBUG=aabbcc`,这肯定也是为真，所以第5行也是会执行。

#### 1.2.6 其它

- -Wall   打印警告信息
- -w      关闭警告信息
- -std=c++11    设置编译标准
- -o    指定输出文件名，不给就默认是a.out

### 1.3 实战命令

#### cpp文件、头文件不在一个文件夹

​	最初的目录结构：2个dierctories、共3个files，具体如下：

>.
>├── main.cpp
>├── myinclude
>│   └── swap.h
>└── src
>	└── swap.cpp

​	直接编译`g++ main.cpp src/swap.cpp`,会报错，说是找不到`swap.h`头文件，那就需要用-I参数来指定了，且可以是相对路径，于是`g++ main.cpp src/swap.cpp -Imyinclude`  (注意是大写的字母I紧跟着的头文件的相对路径)

### 1.4 生成库文件并编译

>.
>├── main.cpp
>├── myinclude
>│   └── swap.h
>└── src
>	└── swap.cpp          # 依然以这个路径说

说明：

- linux(它的库都是以`lib`作为开头的)：
  - 静态库以`.a`结尾；
  - 动态库以`.so`结尾，
  - ldd a.exe     # 这样就可以查看可执行文件依赖的共享库.so(即动态链接库)
    ldd b.so  # 也可以查看动态库依赖了哪些
- windows:
  - 静态库以`.lib`结尾；
  - 动态库以`.dll`结尾，
  - Windows不适用.so共享库文件，要查看可执行文件的依赖库，需要用微软自家的==Dependency Walker==工具，更多介绍看[这里](http://c.biancheng.net/view/3868.html)（这里还有MinGW、MSYS、MSYS2之间的区别使用，及安装下载）。

#### 1.4.1 静态库

链接`静态库`生成可执行文件：

```shell
cd src       # 进到src下，去把swap.h编译成静态库

# 汇编，生成swap.o
g++ swap.cpp -c -I../myinclude     # 头文件的位置，相对路径，会得到swap.o
# 生成静态库libswap.a       # 约定库文件以`lib`开头吧
ar rs libswap.a swap.o        # 就会得到 libswap.a 静态库文件

# 回到上级目录
cd ..
# 链接，生成可执行文件：static_main
g++ main.cpp -lswap -Lsrc -Imyinclude -o static_main
```

#### 1.4.2 动态库

链接`动态库`生成可执行文件：

```shell
cd src       # 进到src下，去把swap.h编译成动态库

# 生成动态库：libswap.so           # 约定库文件都是lib开头
g++ swap.cpp -I../myinclude -fPIC -shared -o libswap.so
# 以上命令可以拆分成以下两条命令
gcc swap.cpp -I../myinclude -c -fPIC
gcc -shared swap.o -o libswap.so

# 回到上级目录，链接生成可执行文件：dynamic_main
cd ..
g++ main.cpp -lswap -Lsrc -Imyinclude -o dynamic_main
```

- -fPIC：代表说与路径无关(不是很懂)
- -shared：说明是要生成动态库文件

#### 1.4.3.总结

1. 最后一步链接参数解读：需要链接库文件，所以直接`-lswap`,库文件的路径`-Lsrc`,它的头文件在`-Imyinclude`，一定要结合上面的g++编译参数来看；

2. 静态库、动态库最后的链接命令是一样的，当同一目录下，有静态库也有动态库时，`默认优先选用的动态库`;

3. 静态库是在链接时会会把汇编的.o文件打包进去，而动态库则是在使用时再去链接，所以文件`static_main`会比`dynamic_main`大一些；

4. 静态库生成对的`static_main`是可以直接就执行的，然而执行`dynamic_main`时，就会报找不到`libswap.so`动态库的错误，这是因为这个动态库不在那系统三个路径下，找不到，就需要我们手动添加一下,那运行就是：

   - 静态库：`./static_main`

   - 动态库：`LD_LIBRARY_PATH=src ./dynamic_main` 
     - 注意这是一条命令

##  二、GDB调试

### 2.1 简单介绍

​	==GDB(GNU Debugger)==是一个用来==调试C/C++程序==的功能强大的==调试器==，是Linux系统开发C/C++最常用的调试器

GDB主要功能：

- 设置==断点==(断点可以是条件表达式);

- 使程序在指定的代码行上暂停执行，便于观察;
- ==单步==执行程序，便于调试;
- 查看程序中变量值的变化;
- 动态改变程序的执行环境;
- 分析崩溃程序产生的core文件。

### 2.2 常用调试命令参数

​	调试开始：执行`gdb [exefilename]`,进入gdb调试程序，其中exefilename为要调试的可执行文件名。

​	下面是进到gdb后调试命令，以下命令括号内为命令的简化使用，比如run(r),直接输入r就代表命令run。

> - help(h) run    # 代表查看run命令的帮助
> - run(r)         # 重新开始运行文件，没有断点就会直接把程序执行完(run-text：加载文本文件；run-bin：加载二进制文件)（建议进来先打断点，然后直接run）
> - start          # 单步执行，运行程序，停在第一行执行语句（没有断点的话，系统会自己加一个断点，就是main函数下有效的第一句,执行这个会让调试从开始）
> - list(s)        # 在此界面查看源码，默认断点处的上下5行（list 9：从第9行开始查看上下各5行代码；list 函数名：查看具体函数）
> - set            # 设置变量的值
> - next(n)        # 逐过程，函数直接执行得结果
> - step(s)        # 逐语句，会跳入自定义函数内部执行
> - info(i)        # 查看函数内部局部变量的数值
> - finish         # 结束当前函数，返回函数调用点（就是IDE里面的跳出过程）
> - until 行号      # 一般用于跳出循环，把行号设置在循环体外(好像也可用于直接条跳转到其他行位置，有点c跳转到下一个断点的感觉) 
> - continue(c)    # 作用跟visual studio中的F5一样，会主程序中一行行执行下去，要是有多个断点，就会切到下一个断点
> - print(p)       # 打印值及地址 （只会打印一次，后面跟变量名就好了）
> - quit(q)        # 退出gdb
> - break(b) num   # 在第num行设置断点
>   - 这样是在main函数中打断点
>   - 给其它源文件打断点则是：`b yolo.cpp:123`
> - info breakpoints            # 查看当前设置的所有断点
> - delete(d) breakpoints-num    # 删除第num个断点（首先要info breakpoints，就会得到所有断点的编号，然后直接delete 2）
> - display                     # 追踪查看具体变量值（后续任意命令的执行，都会展示）（也是后面直接跟变量名）
> - undisplay                   # 取消追踪观察变量（后面跟的是要取消的观察变量的编号，先info display获取到编号，在display 3这样的方式删掉）
> - watch         # 被设置观察点的变量发生变量修改时，打印显示
>   - i watch    # 显示观察点(这个i就是上面的info)
> - enable breakpoints     #  启用断点
> - disable breakpoints    # 禁用断点
> - x        # 查看内存x/20xw 显示20个单元，16进制，4字节每单元
> - run argv[1] argv[2]          # 调试时命令行传参
> - set follow-fork-mode child    # Makefile项目管理：选择跟踪父子进程（fork()）

> - (gdb) shell     # 这会进到shell环境中去，然后输入 exit 回到gdb界面
> - wi     # 可视化调试，不知是不是就是打开tui模式

Tips：

- 编译程序时需要加上-g，之后才能用gdb调试（不带-g参数，gdb [exefilename一般就会得到`no debugging symbols found`这样的提示信息）;
- **回车键：重复上一命令**;
- gdb打开后，使用`ctrl+x+a`，可以打开tui模式，就可以比较直观的看调试过程，也可再次按这个退出。
- break test.cpp:6 if num>0  //这就是设置带条件的断点；或者 b 函数名 就可以在函数开始行设置断点；一般跳转到断点所在行，这行都是还没执行。
- 若是执行程序时需要传递参数,就在 gdb 二进制文件 进入到gdb调试界面，紧接着就输入`set args 参数1 参数2 ...`,然后再start就可以了。
  或者最开始run的时候直接加上参数：run argv[1] argv[2]       # 调试时命令行传参

### 2.3 快速使用

​	一般针对就地一个新项目，调试界面进去后，建议直接先执行`start`，它会从main函数的第一行开始逐步debug,等找到main函数中报错的那一行(假如是55行)，就打个断点`b 50`,再按`s`，就进到里面去debug，想要重新开始就直接输入`run`，就会自动执行到50行断点位置停住，就再进去调试就好；

​	等找到报错来自其它的源文件，就可以把上面50行处的断点删除，再在更深一步报错的.cpp源文件打断点，打断点的方式也不太一样，为：`b yolo.cpp:123`,然后直接`run`就会来到这个断点，就可以继续后续调试了。

Tips:

- 按照上面快速给其它.cpp源文件打断点就好了，但如果这个源文件和主函数源文件不在一个目录里，就会提示  "No source file",让在加载的依赖库文件里打断点，按个y同意就好（源文件在不同文件夹也行，库文件生成时指定了）。
- 不同文件夹中的文件，可以在gdb调试界面使用`directory`命令，好比`(gdb)  directory ../test1/`，但是这个我没成功过就用上面的方法就好了。
- 当然也别忘了快速去到下一个断点的命令`c`。

### 2.4 python同理调试

​	python在linux下的快速调试：在python文件中不引用pdb库，可以在执行python文件的时候，加上参数：

方式一、

`python -m pdb demo.py`，来到pdb调试交互界面，debug模式将会停止在的第一行程序代码行，接下里的操作跟gdb就是一样的(暂时还不知道怎么调出源代码)

- 设置断点：b（or break）：设置断点；设置函数：b demo.func；设置行数：b demo:14(行数)  # 还没试过
- r(return):就是把当前函数执行完

方式二、

直接在代码中加入，执行程序时，就会直接到这行停住。

```python
import pdb
pdb.set_trace()    # 直接把这行放在想要调试的代码前
```

[这](https://www.cnblogs.com/xiaohai2003ly/p/8529472.html)是参考链接。

方式三、

这是终端输入参数的调试方法：[VSCode的c++开发.md](./VSCode的c++开发.md)中的最底部位置。

## 三、make

### 3.1 make简介

利用make工具可以自动完成编译工作，这些工作包括：

- 如果修改了某几个源文件，则只重新编译这几个源文件
- 如果某个头文件被修改了，则重新编译所有包含该头文件的源文件        

Ps：判断的依据是最近修改时间和上次是否一致，只要时间不一致，哪怕只是加了一个空行也会重新编译，

​	利用这种自动编译可以大大简化开发工作，避免不必要的重新编译（只编译修改了的）。make工具通过一个称为Makefile的文件来完成并自动维护编译工作，Makefile文件描述了整个工程的编译、连接规则。

### 3.2 Makefile文件

- 参考这个[教程](https://www.cnblogs.com/wang_yb/p/3990952.html)。还有这个[英文教程](https://makefiletutorial.com/#getting-started)，也挺好。

Makefile的基本规则是：

> TARGET... :  DEPENDENCIES...    
> 	COMMAND1
> 	COMMAND2    
> 	...

- TARGER：目标程序产生的文件，如可执行文件和目标文件，目标也可以是要执行的动作，如clean，也称为伪目标。
- DEPENDENCIES:依赖是用来产生目标的输入文件列表，一个目标通常依赖与多个文件。
- COMMAND:命令是make执行的动作（命令是shell命令或是可在shell下执行的程序），注意每个命令行的起始字符必须为TAB字符。
- 如果DEPENDENCIES中有一个或多个文件更新的话，COMMAND就要执行，这就是Makefile最核心的内容。

#### 3.2.1 简单示例

​	假如有`calute.h`、`calute.cpp`、`input.h`、`input.cpp`、`main.cpp`，其中main.cpp是主程序入口，导入了其它两个头文件。有3中处理方式：

1. 最直接的方式：`g++ -o my_out calute.cpp input.cpp main.cpp`  或是直接 g++ -o my_out *.cpp ,这样凡是有一点修改就把整个编译所有文件，多了就很不方便

2. 先编译再链接：

   - 编译得到.o文件：`g++ -c calute.cpp`  g++ -c calute.cpp  g++ -c main.cpp  就会得到这三个的.o文件，

   - 链接：`g++ input.o calute.o main.o -o my_out`  就会得到执行文件`my_out`了（这里面可以一部分是.o文件，一部分是.cpp文件）

3. 写成Makefile的形式：

   ​	每一行顶格写的都是目标，冒号后面紧跟着的就是依赖；然后每个命令行是需要用tab去空一段出来；make命令会为Makefile中的每一个以TAB开始的命令创建一个shell进程去执行。

   ```makefile
   # 第一行就是要实现的主目标，(main也可以是其它任意词)，后面的*.o就是需要的依赖
   
   main: main.o input.o calute.o input.o
   	g++ -o my_out main.o input.o calute.o   # 主目标实现的命令
   main.o: main.cpp   # 若是上面没有main.o依赖就在这里生成，它又依赖于main.cpp
   	g++ -c main.cpp
   input.o: input.cpp
   	g++ -c input.cpp      # 这个命令一定要tab空出来
   calute.o: calute.cpp
   	g++ -c calute.cpp    # 上面就是缺哪个来下面找哪个
   
   clean:       # 这个目标就没有依赖，那输入这，就一定会执行下面的命令
   	rm -f *.o
   	rm my_out
   ```

   Tips:

   - 这个就是哪个文件改了，就只会重新编译改了的或是引用了它的文件;
   - 着重注意：`每个命令必须是以tab出来的空格，不能是4个空格`，那就是错的。

### 3.3 Makefile中的变量

​	Makefile中的变量都是字符串，它的使用方法是先定义一个变量，使用的时候就是`$(变量名)`,接着上面的Makefile写到：

```makefile
name = zhangsan
curname1 = $(name)

curname2 := $(name)

curname3 ?= $(name)

name = lisi 
print:
    @echo "curname1:$(curname1)"    # 此时curname1的结果是liis

​	@echo "curname2:$(curname2)"    # zhangsan   # 不知道这点怎么来的

​	@echo "curname3:$(curname3)"    # lisi
```

- `=`赋值变量

  ​	然后执行`make print`就会得到`curname1:lisi`,也就是说，`=`获取的变量是它最后一次的有效值；

- `:=`赋值变量

  ​	这就是看上面的例子，它在做`curname2:=$(name)`时，就是用前面`name`已经定义好的,无论这后面怎么变，它始终都不会变，上面的例子结果也会是`curname2:zhangsan`

- `?=`赋值变量

  ​	这是一个很有用的赋值符，比如`curname3 ?= zhangsan`意思就是==如果变量curname前面没有赋值，那么curname就等于zhangsan，如果前面已经赋值了，那curname就用前面赋的值==。

- `+=`变量追加

  就是字符串的拼接

Tips:

- 上面`@`的作用就是不让执行的命令打印出来，如果没有@，执行`make print`就会得到两行结果。一行是`echo "now_name:lisi"`,另一行是`now_name:lisi`

### 3.4 Makefile模式规则

​	接着上面的例子，main目标后，接下来的三条规则命令都是把.cpp文件编译成.o文件，基本算是重复的，那就可以使用一条规则来讲所有的.cpp文件编译为对应的.o文件。

​	模式规则中，至少在规则的目标中(TARGET)中要包含`%`，否则就是一般规则，目标中的`%`表示对文件名的匹配，它表示`任意长度的非空字符串`，比如`%.cpp`就是所有以`.cpp`结尾的文件，类似于通配符，`a%.cpp`就表示以`a`开头，且以`.cpp`结束的所有文件；

​	当`%`出现再目标中(TARGET)的时候，目标中`%`所代表的值也决定了依赖中(DEPENDENCIES)的`%值`，上面的例子就成了： 

```makefile
object = main.o calute.o input.o
main: $(object)
    g++ -o main $(object)   # 这两行就是用变量名取代了
%.o: %.cpp       # 这里就是`%`的模式匹配
    g++ -c $<     # 后面这个写法就是所有依赖，不能写成`g++ -c %.cpp`
```

#### 3.4.1 自动化变量

​	第5行这个又叫==Makefile自动化变量==：上面说的模式规则中，目标和依赖都是一系列的文件，每一次对模式规则进行解析的时候都会是不同的目标和依赖文件，而命令只有一行，如何通过一行命令来从不同的依赖文件中生成对应的目标?自动化变量就是完成这个功能的!

​	所谓自动化变量就是这种变量会把模式中所定义的一系列的文件自动的挨个取出，直至所有的符合模式的文件都取完，==自动化变量只应该出现在规则的命令中==，常用的自动化变量如下表：

| 自动化变量 |                             描述                             |
| :--------: | :----------------------------------------------------------: |
|     $@     | 规则中的目标集合，在模式规则中，如果有多个目标的话，“S@”表示匹配模式中定义的目标集合。 |
|     $%     | 当目标是函数库的时候表示规则中的目标成员名，如果目标不是函数库文件，那么其值为空。 |
|     $<     | 依赖文件集合中的第一个文件，如果依赖文件是以模式(即“%”)定义的，那么“S<”就是符合模式的一系列的文件集合。 |
|     $?     |           所有比目标新的依赖目标集合，以空格分开。           |
|     $^     | 所有依赖文件的集合，使用空格分开，如果在依赖文件中有多个重复的文件，“$^”会去除重复的依赖文件，值保留一份。 |
|     $+     | 和“$个”类似，但是当依赖文件存在重复的话不会去除重复的依赖文件。 |
|     $*     | 这个变量表示目标模式中"%"及其之前的部分，如果目标是test/a.test.c，目标模式为a.%.c，那么“$*”就是test/a.test。 |

常用的三种：`$@`、`$<`、`$^`

### 3.5 Makefile伪目标

​	Makefile有一种特殊的目标——伪目标，主要是为了避免Makefile中定义的只执行命令的目标和工作目录下的时机文件出现名字冲突，有时候我们需要编写一个规则用来执行一些命令，但是这个规则不是用来创建文件的，比如前面用到的`clean`

```makefile
clean:     # 我们并不想得到clean这样的一个文件目标
	rm *.o
	rm main
```

​	上述规则中并没有创建文件clean的命令，因此工作目录下永远都不会存在文件clean，当输入`make clean`以后，后面的两条命令总是会执行；可当工作目录下有一个名为`clean`的文件，当执行`make clean`的时候，规则因为没有依赖文件，所以目标被认为是最新的，因此后面的rm命令也就不会执行，那设想的清理工作就无法完成，故为了避免这个问题，可以将clean声明为为目标，声明方式如下：

```makefile
.PHONY: clean
```

这一行只要在clean之前定义了就行，不一定非得靠在一起。

### 3.6 修改Makefile(重要)

​	一般来说，使用cmake ..这样的命令在build中创建了Makefile，还是已经执行完了make命令后的Makefile,都是还可以修改Makefile的，经常用于修改CMAKE_INSTALL_PREFIX的值来改变安装的地址，操作比较简单(有些)：

- make help   # 查看下有哪些可以执行的命令
- make edit_cache   # 这就会进到一个界面，看着操作就好了
- 改完后，按c进行保存一下,退出，然后再执行make && make install   

Tips：

- 这里面改东西是没有回退操作的，写错了或是要改原本的内容，Enter之后直接输入覆盖；
- make install的地址可以不存在的，它会自己创建
- 不同的Makefile是有操作命令的，具体以make help为主；
- 很多自己写的都是没有写install的规则的(下面有说明，还是尽量写上完善吧)，所以也就不会有make install的；
- 这还可以对某个单独的文件进行编译。

### 3.7 通用模板

这里有一些通用模板，[地址](https://mp.weixin.qq.com/s/1nXoEcdURd5EUWo4fb_Umg)。

## 四、cmake

[这里](./modern-cmake.pdf)是cmake的一个PDF。

- EXECUTE_PROCESS  ： 这个命令可以在里面运行shell脚本，举例(更多网上看)：

  ```cmake
  execute_process(COMMAND <一句shell命令> WORKING_DIRECTORY <这句shell命令执行的工作目录>)
  execute_process(COMMAND sh test.sh WORKING_DIRECTORY <test.sh所在目录>)
  ```

### 4.1 常用变量

这种变量是cmake自己就定义好了的，说明：

- 引用变量内容需要使用`${变量名}`格式;

- 可以使用message命令查看变量具体内容:

  - message用法：message([STATUS|WARNING|FATAL_ERROR] "some messafe")   // 还有一些其它可选参数，但不重要了

    ```cmake
    message("The CMAKE_SOURCE_DIR is ${CMAKE_SOURCE_DIR}")
    message(STATUS "The CMAKE_VERSION is ${CMAKE_VERSION}")
    message(WARNING "this is a warning!")
    message(FATAL_ERROR  "this is a fatal warning!")
    ```

    > 1. 不加任何参数，会把内容直接打印出来(算重要消息);
    > 2. STATUS,会在打印的信息前加上`-- ` (算非重要提示信息);
    > 3. WARNING，一般会有红色的警告提示信息（算警告，会继续执行);
    > 4. FATAL_ERROR，直接就会报错，在这里停住，生成也会失败。

- 可以在CMakeLists.txt中使用set命令改变某些变量值:`set(CMAKE_BUILD_TYPE Debug)`

  - 可以通过cmake命令行参数设置变量值：如`cmake -DCMAKE_BUILD_TYPE=Release`，但是注意这种方式会被CMakeLists.txt中的set命令设置的变量值覆盖

常用变量：

|          变量名           |                             含义                             |
| :-----------------------: | :----------------------------------------------------------: |
|       PROJECT_NAME        |                  `project`命令中写的项目名                   |
|       CMAKE_VERSION       |                     当前使用cmake的版本                      |
|     CMAKE_SOURCE_DIR      |        工程顶层目录，即入口CMakeLists.txt文件所在路径        |
|    PROJECT_SOURCE_DIR     |                    同==CMAKE_SOURCE_DIR==                    |
| \<projectname>_SOURCE_DIR |                    同==CMAKE_SOURCE_DIR==                    |
|     CMAKE_BINARY_DIR      | 工程编译发生的目录，即执行cmake命令所在的目录，一般是在新建build目录下，使用`外部构建`，==建议使用这个== |
|    PROJECT_BINARY_DIR     |              同==CMAKE_BINARY_DIR==，也建议使用              |
| \<projectname>_BINARY_DIR |                    同==CMAKE_BINARY_DIR==                    |
| CMAKE_CURRENT_SOURCE_DIR  |              当前处理的CMakeLists.txt所在的路径              |
| CMAKE_CURRENT_BINARY_DIR  |      当前处理的CMakeLists.txt中生成目标文件所在编译目录      |
|  CMAKE_CURRENT_LIST_FILE  |        输出调用这个变量的CMakeList.txt文件的完整路径         |
|  CMAKE_CURRENT_LIST_DIR   |          当前处理的CMakeList.txt文件所在目录的路径           |
|   CMAKE_INSTALL_PREFIX    |            指定`make install`命令执行时包安装路径            |
|     CMAKE_MODULE_PATH     |          `find_package`命令搜索包路径之一，默认为空          |

编译配置相关变量，一般都需要set去显示指定：

|         变量名         |                             含义                             |
| :--------------------: | :----------------------------------------------------------: |
|    CMAKE_BUILD_TYPE    | 编译类型，`Release`或`Debug`,如`set(CMAKE_BUILD_TYPE Release)` |
|    CMAKE_CXX_FLAGS     | `set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -std=c++11")`编译标志，设置C++11编译,有点原来的变量名基础上追加了内容，再覆盖这个变量名。 |
|   CMAKE_CXX_STANDARD   | 也可以设置C++11编译，`set(CMAKE_CXX_STANDARD 11)` （用上面的方式） |
|    CMAKE_CXX_FLAGS     | `set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -std=c++11")`，g++编译选项，在后面追加-std=c++1再覆盖 |
|     CMAKE_C_FLAGS      |           gcc编译选项，也是一样在后面追加编译选项            |
|    CMAKE_C_COMPILER    |                         指定C编译器                          |
|   CMAKE_CXX_COMPILER   |                        指定C++编译器                         |
| EXECUTABLE_OUTPUT_PATH |                   可执行文件输出的存放路径                   |
|  LIBRARY_OUTPUT_PATH   |                     库文件输出的存放路径                     |

判断操作系统

```cmake
IF (CMAKE_SYSTEM_NAME MATCHES "Linux")
	
ELSEIF (CMAKE_SYSTEM_NAME MATCHES "Windows")
	
ELSEIF (CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
	
ELSE ()
	MESSAGE(STATUS "other platform: ${CMAKE_SYSTEM_NAME}")
ENDIF (CMAKE_SYSTEM_NAME MATCHES "Linux")
```

判断编译器

```cmake
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
# using Clang
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
# using GCC
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
# using Intel C++
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
# using Visual Studio C++
endif()
```

### 4.2 重要指令

简单说明：

- 基本语法格式：指令(参数1 参数2...)

  - 参数使用括弧括起来
  - 参数之间使用==空格==或==分号==分开（一般选用空格）

- 指令是大小写无关的，参数和变量是大小写相关的

  ```cmake
  set(HELLO hello.cpp)   # 指定变量名 HELLO 它代替hello.cpp
  add_executable(hello main.cpp hello.cpp)   # 下面这两行就是一样的
  ADD_EXECUTABLE(hello main.cpp ${HELLO})    # 注意变量名是区分大小写的
  ```

- 变量使用`${}`方式取值，但是在`IF`控制语句中是直接使用变量名

  - 比如上面的e`HELLO`是变量名，那么就应该是`if(HELLO)`，而不是if(${HELLO})，这就是错的。

==全局说明==：

​	==下面笔记中`[]`中的指令代表是可选的，可以不要==。

​	==如果CMakeLists.txt中设定了一个参数，CMake命令执行时再给这个参数来修改其值是没用的==。

#### 4.2.1 cmake_minimun_required()

含义：指定CMake的最小版本要求

- 语法：cmake_minimum_required(VERSION versionNumber [FATAL_ERROR])

  ```cmake
  # CMake最小版本要求为2.8.3   # 版本不对，后面系统自己就会报这个错误
  cmake_minimum_required(VERSION 2.8.2)  
  ```

#### 4.2.2 project()

含义：定义工程名称，并可指定工程支持的语言

- 语法：project(projectName [CXX]\[C]\[Java])

  ```cmake
  project(hello_cmake)  # 指定工程名hello_cmake
  ```
  
  project()函数将创建一个值为hello_cmake的变量${PROJECT_NAME}

#### 4.2.3 set() | file()

含义：显示地定义变量,创建的变量名可以方便后续直接使用

- 语法：set(VAR [VALUE]\[CACHE TYPE DOCSTRING [FORCE]])


```cmake
# 定义一个名为`SOURCE`的变量
# 方式1：
set(SOURCE src/Hello.cpp src/main.cpp)   # 顺序是没有关系的

# 方式2，用GLOB+通配符
file(GLOB SOURCE "src/*.cpp")

# 语法：add_executable(exename source1 source2...) ---> add_executable(my_main 1.cpp 2.cpp...)这是是要所有的cpp源文件
add_executable(${PROJECT_NAME} ${SOURCE})

# 因为有头文件，要让编译器知道，就就是为目标执行文件，链接头文件
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_SOURCE_DIR}/include)
# 不知道中间为什么要这个`PRIVATE`，不要就会报错
```

Tips:

- 对于现代CMake，不建议为源代码使用变量；通常是在add_xxx函数中直接声明源文件。这对于glob命令尤其重要，因为如果添加新的源文件，glob命令可能并不总是显示正确的结果;

- 前面执行make的时候，输出只显示构建的状态，要查看用于调试的完成输出，可以在运行make的时候添加`VERBOSE=1`的标志，即：`make VERBOSE=1` ,这个输入可以详细去看看，可以在输出里明显看到include目录添加到c++编译器命令中的。

##### aux_source_directory()

​	发现一个目录下所有的源代码文件并将列表存储在一个变量中，这个指令临时被用来自动构建源文件列表

- 语法：aux_source_directory(dir VARIABLE)

  ```cmake
  # 定义一个SRC变量，其值为当前目录下所有的源代码文件
  aux_source_directory(. SRC)
  # 编译SRC变量所代表的源代码文件，生成main可执行文件
  add_executable(main ${SRC})
  ```

#### 4.2.4 include_directories()

含义：向工程添加多个特定的头文件搜索路径 --->相当于指定g++的`-I`参数(这是大写的I)

- 语法：include_directories([AFTER|BEFORE] [SYSTEM] dir1 dir2...)  # 前面有一些可选参数，暂时不知道干嘛的

  ```cmake
  #将绝对路径和相对CMakeLists.txt的相对路径./myinclude添加到头文件搜索路径
  include_directories(/opt/opencv/include/ myinclude)
  ```

#### 4.2.5 add_libaray()   | target_include_directories() | target_link_libraries

- ==add_libaray()== -生成库文件（包括==动态和静态==）
  
  - 语法：add_libaray(libname [SHARE|STATIC|MODULE] [EXCLUDE_FROM_ALL] source1 source2... sourceN)   # 这里的可选参数一般都要跟，动态或静态
  
  - >target_link_libraries(demo LINK_PRIVATE ${OpenCV_LIBS} avcodec.so avformat avutil swscale.so)   # avformat avformat.so是一个意思，要不要后缀都行
- ==target_include_directories()== -为生成库文件指定使用到的头文件路径，一般是自己写的头文件
- ==target_link_libaries()==-为target(执行程序)添加需要链接的共享库(动态库) --->相当于g++的`-l`参数(小写的l) 
  
  - 语法：target_link_libaraies(target library1\<debug|optimized> library2...)
  - 比如opencv，要加了这个后，include的时候头文件才不会报错

##### (1)静态库

目录结构如下：

> .
> ├── CMakeLists.txt
> ├── include
> │   └── static
> │       └── Hello.h
> └── src
>  ├── Hello.cpp
>  └── main.cpp

```cmake
project(hello_library)
# 通过源文件生成静态库，我们这里指定的是`hello_library`,最后目录里的是`libhello_library.a`
add_library(hello_library STATIC src/Hello.cpp)
# 生成静态库时也要告诉它头文件在哪里啊（这说是把范围设成public，然后会使得这个头文件的会在以下地方使用：- 当编译这个库文件时； - 当编译任何链接了这个库的目标时）(Populating Including Directories)

target_include_directories(hello_library PUBLIC ${PROJECT_SOURCE_DIR}/include)
# 注意去看这里的源码，它main.cpp、Hello.cpp中导包都是用的 #include "static/Hello.h" 都省去了上一级include目录，(这里的static也是文件夹的名字)

# 生成可执行文件，需要链接这个静态库（Linking a Library）
add_executable(hello_binary src/main.cpp)
target_link_libraries(hello_binary PRIVATE hello_library)   # 为target添加需要链接的共享库(动态库) --->相当于g++的`-l`参数(小写的l)
```

这个命令就像是：

```shell
/usr/bin/c++ CMakeFiles/hello_binary.dir/src/main.cpp.o -o hello_binary -rdynamic libhello_library.a
```

##### 参数范围(scopes)的意义：

- PRIVATE：the directory is added to this target’s include directories
- INTERFACE：the directory is added to the include directories for any targets that link this library.
- PUBLIC：As above, it is included in this library and also any targets that link this library.

##### (2)动态库

目录结构：

> .
> ├── CMakeLists.txt
> ├── include
> │   └── shared
> │       └── Hello.h
> └── src
>  ├── Hello.cpp
>  └── main.cpp

```cmake
project(share_project)
# 生成一个动态库 
add_library(hello_library SHARED src/Hello.cpp)
# 一样也要告诉它头文件的位置
target_include_directories(hello_library PUBLIC ${PROJECT_SOURCE_DIR}/include)
# 这是一个`Alias Target`，在项目中给这库起个别名，但实际名还是在的
add_library(hello::library ALIAS hello_library)

add_executable(hello_main src/main.cpp)
target_link_libraries(hello_main PRIVATE hello::library)
# 一样注意下main.cpp中的导入写法
```

这个命令就像是：

```shell
/usr/bin/c++ CMakeFiles/hello_binary.dir/src/main.cpp.o -o hello_binary -rdynamic libhello_library.so -Wl,-rpath,/home/matrim/workspace/cmake-examples/01-basic/D-shared-library/build
```

#### 4.2.6 install() | -DCMAKE_INSTALL_PREFIX

​	CMake是可以控制这些生成的头文件、二进制文件、库文件被安装在哪里，命令是`make install`，是由`install()`函数控制的:

这是基于上一个例子,目录结构：

> .
> ├── cmake-examples.conf
> ├── CMakeLists.txt
> ├── include
> │   └── installing
> │       └── Hello.h
> ├── README.adoc
> └── src
>  ├── Hello.cpp
>  └── main.cpp

```cmake
project(cmake_examples_install)

# 生成一个动态库
add_library(install_library SHARED src/Hello.cpp)
target_include_directories(install_library PUBLIC ${PROJECT_SOURCE_DIR}/include)     # 动态库要链接头文件

# 生成可执行文件
add_executable(install_main src/main.cpp)
# 把前面生成的动态库链接到执行文件
target_link_libraries(install_main PRIVATE install_library)
#**********************************************#
# Install  (这其实就是复制文件，也可以是复制其它的源文件)
# (1)Binaries(二进制可执行文件)
install(TARGETS install_main DESTINATION bin)
# TARGETS是固定写法；install_main是可执行文件名；DESTINATION也是固定写法；bin就是代表放在指定路径的bin目录下

# (2)Library(库文件)   （有需要才写）
install(TARGETS ${install_library} DESTINATION lib)  # 库可能很多个，起了别明后。要${}这样引用了才行

# (3)Header files(头文件)  （有需要才写）
install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/ DESTINATION include)
# DIRECTORY也是固定写法；结合上面tree结果看，这回把include目录下的installing目录都放进去

# (4)Config (要有这文件才写)
install(FILES cmake-examples.conf DESTINATION etc)
# FILES也是固定写法；会生成名为cmake-examples.conf的文件在目标路径的etc下
```

在window上可能有点不一样，是要用：

```cmake
install (TARGETS install_library
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin)
```

再注意：install安装可是当复制文件用的，可是是复制可执行文件、复制文件、文件夹、库这些是有不同的区别的，具体看[这里](https://blog.csdn.net/qq_38410730/article/details/102837401)，写的很详细。

​	就按照自己写learnOpenGL的实战demo来看，有install(TARGETS|PROGRAMS|FILE|DIRECTORY)

```cmake
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    message(STATUS "Setting default CMAKE_INSTALL_PREFIX path to ${CMAKE_BINARY_DIR}/install")
    set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install CACHE STRING "The path to use for make install" FORCE)
endif()

install(TARGETS ${NAME} DESTINATION .)  # 1.1 执行文件(用的TARGETS)
 
 # 1.2 也可以写为  "${CMAKE_SOURCE_DIR}/dlls/*.dll"
file(GLOB DLLS "dlls/*.dll") 
install(PROGRAMS ${DLLS} DESTINATION .) # PROGRAMS指的是非目标文件的可执行程序
# 1.3 文件夹 就要用 DIRECTORY ，前面 resources 目录加不加引号都一样
install(DIRECTORY "resources" DESTINATION .)   

# 不能下面这样写，是错的，不同的文件用不一样的 TARGETS、PROGRAMS、FILE、DIRECTORY 
# install(TARGETS "${CMAKE_SOURCE_DIR}/dlls/*.dll" .) 
# install(TARGETS "resources" DESTINATION .) 
```

Tips:

==-DCMAKE_INSTALL_PREFIX== 

- `DESTINATION`就是代表`${CMAKE_INSTALL_PREFIX}`,这个路径是可以被ccmake指定，或者是使用`cmake -DCMAKE_INSTALL_PREFIX=/home/mypath ..`指定,==可以使用相较于执行cmake命令时的相对路径==；

  - 如果没有指定路径，那install的默认地址就是`/usr/local`;

  - 这是在在没有设置`-DCMAKE_INSTALL_PREFIX`参数时，设定把安装路径设置在构建build路径下的install目录（==一定要提前创建这个install目录==），放在顶级的CMakeLists.txt，且要在生成二进制文件或是库文件之前，最好就放在一开始：

    ```cmake
    if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
      message(STATUS "Setting default CMAKE_INSTALL_PREFIX path to ${CMAKE_BINARY_DIR}/install")
      set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE STRING "The path to use for make install" FORCE)
    endif()
    ```

  - 当然还可以再设置路径的前缀-`DESTDIR`,即`${DESTDIR}/${CMAKE_INSTALL_PREFIX}`

    - make install DESTDIR=/home/temp，如果没设置CMAKE_INSTALL_PREFIX，那结果就是`/home/temp/usr/local`,设置了就按设置的来。

- 一般的执行就是mkdir build; cd build; cmake ..; make; make install  # 当然最后两步是可以直接就一句make install完成；

  - make install运行完后，就会得到一个名为`install_manifest.txt`的文件，里面记录了安装的文件所在路径的详细内容;
  - make [-j4/-j8]  # make后面这个参数是选填的，代表使用几个cpu去编译，提高效率。 

- 执行生成的二进制文件：它在/usr/local/bin下，这是在PATH路径中，名为install_main，直接执行install_main,可能就会报找不到我们程序要链接的`libinstall_library.so`动态库文件，这是因为存放这的动态库文件的路径`/usr/local/lib`没有添加到环境变量中，故：

  - `LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib  install_main`  
    - \# 这是一个命令(如果是指定了安装路径，后面的lib路径可以跟相对地址的);
  - `export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib`;`install_main` 
    - \# 第二个方法就是添加了临时变量，然后再执行。

- CMake没提供卸载的类似`make uninstall`的方法，但是可以使用`xargs rm < install_manifest.txt`。

#### 4.2.7 -DCMAKE_BUILD_TYPE

BUILD_TYPE,构建选项：

- Release：会添加`-O3`、`-DNDEBUG`的标识给编译器 （包括优化但没有调试信息）
- Debug：会添加`-g`的标识给编译器  （禁用优化并包含调试信息）
- MinSizeRel：会添加`-Os`、`-DNDEBUG`给编译器  （优化大小，没有调试信息）
- RelWithDebInfo：会添加`-O2`、`-g`、`-DNDEBUG`的标识给编译器  （优化速度并包含调试信息）

通常使用的话可以：`cmake -DCMAKE_BUILD_TYPE=Release`  # cmake命令行编译时用

一般来说，很简单的一个使用的话就是在顶级CMakeLists.txt中设置这个变量：
		==set(CMAKE_BUILD_TYPE Debug)==   # 这是写到CMakeLists.txt中

或者官方按照下面设置默认的编译类型(也是放在顶级CMakeLists.txt)：

```cmake
# 如果没有指定编译类型，就默认设置为`RelWithDebInfo`
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message("Setting build type to 'RelWithDebInfo' as none was specified.")
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Choose the type of build." FORCE)
  # 这是为了cmake-gui界面可以选择编译类型
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
    "MinSizeRel" "RelWithDebInfo")
endif()
```

#### 4.2.8 添加宏

​	说明：3.12版本之前是用的add_options(-Wall -std==c++11 -O2 -g)、add_options(-D一个宏)，放这里作为一个了解，及3.12版本及以后用下面的版本。

==add_compile_options==-添加编译参数，感觉是图像化界面的一个选择参数，用的不多，放这里作为一个了解吧

- 语法：add_compile_options(\<option>...)  (基本不用这了，看下面添加宏的定义)

  ```cmake
  add_compile_options(-Wall -std==c++11 -O2 -g)
  # 由于不同的编译器支持不同的选项，该命令的典型用法是在特定于编译器的条件子句中:
  if (MSVC)
      # warning level 4 and all warnings as errors
      add_compile_options(/W4 /WX)
  else()
      # lots of warnings and all warnings as errors
      add_compile_options(-Wall -Wextra -pedantic -Werror)
  endif()
  ```

---

接下来就是类似于g++中的-D宏开关这样的做法了：`add_compile_definitions()` 是用来全局定义宏
（注：_CRT_SECURE_NO_WARNINGS 是vs关闭f_open不安全的错误的预定义宏），有以下做法

- 无参宏(相当于代码中的一个宏开关)：
  - 命令行：cmake /D_CRT_SECURE_NO_WARNINGS ..  # 注意是 /D宏名称
  - CMakeLists.txt中：==add_compile_definitions==(_CRT_SECURE_NO_WARNINGS)
- 有参宏：(假设要定义一个有具体值的宏,如 \#define VALUE_MACRO 0x10000000)
  - 命令行：cmake -DVALUE_MACRO=0x10000000 ..   # 注意是 -D宏名称=宏的值
  - CMakeLists.txt中：==add_compile_definitions==(VALUE_MACRO=0x10000000)

---

除了上面这种，还可以是针对单个可执行文件编译时添加参数，就是：`target_compile_definitions()`

​	像上面添加vs的预处理宏也可以这样写：target_compile_definitions(demo.exe PRIVATE _CRT_SECURE_NO_WARNINGS)

下面是在cmake-example中的学习

Compile Flags,一共有两种方式：

- 使用`target_compile_definitions()`函数;
- 使用`CMAKE_C_FLAGS`和`CMAKE_CXX_FLAGS `变量;

main.cpp的代码是：

```c++
#include <iostream>
int main(int argc, char *argv[])
{
   std::cout << "Hello Compile Flags!" << std::endl;

   // only print if compile flag set
#ifdef EX2
  std::cout << "Hello Compile Flag EX2!" << std::endl;
#endif

#ifdef EX3
  std::cout << "Hello Compile Flag EX3!" << std::endl;
#endif

   return 0;
}
```

set这种会设置每个目标的c++标志：

```cmake
# Set a default C++ compile flag
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DEX2" CACHE STRING "Set C++ Compiler Flags" FORCE)   
# `CACHE STRING "Set C++ Compiler Flags" FORCE`是强制在CMakeCache.txt中使用这个变量；一旦设置CMAKE_CXX_FLAGS或是CMAKE_C_FLAGS变量，就会为这个目录或任何子目录的的所有目标设定此标志

project (compile_flags)
add_executable(compile_flags_main main.cpp)

target_compile_definitions(compile_flags_main PRIVATE EX3) 
# 上面那相当于是全局都设置，这是给指定目标单独设置；这就是当编译器编译时会给这个目标add这个定义-DEX3;
# 如果目标是一个library库，作用域选择`PUBLIC`或`INTERFACE `,那么这个选项也会包含在该目标的任何可执行文件
```

除了这样set全局设置外，还有一个其它全局设置的办法：
	`cmake -DCMAKE_CXX_FLAGS="-DEX3" ..` 

这个结果就会把main.cpp那几行都打出来，`target_compile_definitions`是对这个函数里的目标做add动作,相当于加了`EX3`，没这个函数就只会打印`#ifdef EX2`那一段了。

#### 4.2.9 find_package()

这有一个相关的变量`CMAKE_MODULE_PATH`，上面有讲到，可以通过这去添加*.cmake文件的路径，例如：

>set(CMAKE_MODULE_PATH "\${CMAKE_SOURCE_DIR}/cmake/Modules/;​\${CMAKE_MODULE_PATH};${CMAKE_SOURCE_DIR}")

​	自己编译的包，没添加到环境变量，要使用的菜单话，上来就在编译的路径下找`XXXConfig.cmake`，然后把这个路径去set。

用于发现第三方库，有两种模式：

- 优先使用Module模式，会查找类似于`FindXXX.cmake`,查找失败就会进入到Config模式，查找类似`XXXConfig.cmake`;
- 当然也可以会直接进入到Config模式，在此函数中使用关键字`CONFIG`或`NO_MODULE`，就会直接进入到Config模式。
  - 特别注意：好比`Z3`库，自定义安装后得到的就是`Z3Config.cmake`，然后在编写的CMakeLists.txt时，使用find_package(Z3 CONFIG REQUIRED),这里就一定是要加`CONFIG`的(因为其它地方有MODULE的方式可能会先去找这个库，就么就没有使用这个文件，就一定要指定)

> set(Boost_DIR /opt/boost_1_76_0/install/lib/cmake/Boost-1.76.0)
>
> find_package(Boost 1.16.1 REQUIRED COMPONENTS filesystem system)
>
> - Boost - 库的名字，大小写参看它的`BoostConfig.cmake`文件
> - 1.46.1 - 最小的版本要求，可以不设置
> - REQUIRED - 代表是需要要有这个包，没有找到就会报错
> - COMPONENTS - 后面就是跟需要的库(不一定用到所有的库，把需要的库列处理,如果有任何一个找不到就会导致cmake停止执行)
> - OPTIONAL_COMPONENTS - 可选的模块，找不到也不会让cmake停止执行

​	大多数的找到包后就会设置一个类似`XXX_FOUND`的变量，这里的话就是`Boost_FOUND`，然后也会设置一些变量，大致如下(其他的也可以去看看其)：

```cmake
if(Boost_FOUND)
    include_directories(${Boost_INCLUDE_DIRS})
    MESSAGE(STATUS "这里***************")    
    MESSAGE( STATUS "Boost_INCLUDE_DIRS = ${Boost_INCLUDE_DIRS}.")
    MESSAGE( STATUS "Boost_LIBRARIES = ${Boost_LIBRARIES}.")
    MESSAGE( STATUS "Boost_LIB_VERSION = ${Boost_LIB_VERSION}.")
else()
	message (FATAL_ERROR "Cannot find Boost")
endif()
```

Tips（==这里很重要==）：

(1):

​	如果系统环境变量中有这个包，一般直接find_package就可以了，但想要用自己安装的指定版本或是系统里没有的话，就要这样指定路径：

​	`set(Boost_DIR /opt/boost_1_76_0/install/lib/cmake/Boost-1.76.0)`   # 这个很重要

- 前面的`Boost`大小写是有第三方库本身决定且是固定写法； 
  - \# 可于`XXXConfid.cmake`的顶部获取其写法
- `_DIR`也是固定写法；（有些可能是`_ROOT`，比如PCL库在win下，PLC_ROOT=D:/program files/PCL 1.13.0; PCL_DIR=D:/program files/PCL 1.13.0/cmake 两个效果一样，这个cmake文件夹下有PCLConfig.cmake）（之所有用前者,是因为其同级下有3rdParty的路径，就方便使用 ${PLC_ROOT}/3rdParty/具体三方库 ）
- 后面的路径是自己安装的路径，到最后的这级目录里，一定有`BoostConfig.cmake`和`BoostConfigVersion.cmake`这两个文件，其它的第三方库类推；

​	在找到第三方库后会得到一些变量，这些变量可以告诉用户在哪里可以找到库、头文件或可执行文件。与XXX_FOUND变量类似，这些变量是特定于包的，==通常在FindXXX或是XXXConfid.cmake的顶部==有文档记录。

***

(2):

​	保留一下，看要不要把没有这配置文件的库的方法写在这里

##### 别名方式导入

别名方式导入目标：从3.5版本开始就支持别名方式导入：

- `Boost::boost` for header only libraries

- `Boost::system` for the boost system library.
- `Boost::filesystem` for filesystem library.

这些目标包括它们的依赖项，因此针对Boost::filesystem进行链接将自动添加Boost:: Boost和Boost::system依赖项。

所以就可以这样使用：

```cmake
target_link_libraries( third_party_include PRIVATE Boost::filesystem)
```

不用别名方式导入的话：但一些老的库不支持的时候，就可以：

- xxx_INCLUDE_DIRS - A variable pointing to the include directory for the library.
- xxx_LIBRARY - A variable pointing to the library path.

然后添加：

```cmake
# Include the boost headers
target_include_directories( third_party_include
    PRIVATE ${Boost_INCLUDE_DIRS}
)

# link against the boost libraries
target_link_libraries( third_party_include
    PRIVATE
    ${Boost_SYSTEM_LIBRARY}
    ${Boost_FILESYSTEM_LIBRARY}
)
```

##### 第三方库示例

​	注意：以下库在使用的时，都编译好了，如果cmd命令执行报什么.dll库文件没有，powershell或是clion运行直接没任何结果也没报错的话，那就是缺.dll，搜索它，并将其所在路径添加到环境变量中就好了。

(1)、如果换做是opencv，那这里就是：

```cmake
set(OpenCV_DIR /opt/opencv-3.4.13/install/share/OpenCV)
find_package(OpenCV REQUIRED)
target_link_libraries(main  ${OpenCV_LIBS})  # 注意发现这里个libtorch的不同，在各自文件里去找这个变量
set_property(TARGET main PROPERTY CXX_STANDARD 11)
```

这个share目录里也一定有`OpenCVConfig.cmake`和`OpenCVConfig-version.cmake`。

***

(2）、如果换做是libtorch，那这里就是：

```cmake
#set(CMAKE_PREFIX_PATH /opt/libtorch/share/cmake/Torch)   # 这样写它也是可以的，不是很清楚为什么
set(Torch_DIR /opt/libtorch/share/cmake/Torch)   # 还是用下面这种吧，统一起来
find_package(Torch REQUIRED)
add_executable(main main.cpp)
target_link_libraries(main ${TORCH_LIBRARIES})  # 注意发现这里个OpenCV的不同，在各自***config.cmake文件里去找这个变量
set_property(TARGET main PROPERTY CXX_STANDARD 14)
```

这个/opt/libtorch/share/cmake/Torch目录下，也一定有`TorchConfig.cmake`和`TorchConfigVersion.cmake`。

libtorch的更多参照看[这里](https://pytorch.apachecn.org/#/docs/1.7/39)。

##### 库路径添加进环境变量而不用set来指定

除了在CMakeLists.txt中用set来指定 库名_DIR 外，还可以直接添加进系统环境变量：以opencv为例

windows：（两种方式）

- 直接在`Path`中添加`D:/lib/opencv/build/x64/vc15/lib`  （值即为set OpenCV_DIR时给的值）
- `系统变量(s)`中新建一个变量名为`OpenCV_DIR`，值为`D:/lib/opencv/build/`,只到build那级别

linux：如下写进到~/.bashrc中即可

- export OpenCV_DIR=/opt/opencv-4.5.3/install/lib64/cmake/opencv4

#### 4.2.10 target_compile_features() | CMAKE_CXX_FLAGS

```c++
# 这就是在 try conditional compilation
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
```

- include行就是告诉CMake包含这个函数以使其可用;
- 这将尝试编译一个带有`-std=c++11`的程序，并把结果储存进变量`COMPILER_SUPPORTS_CXX11`；
- 第三行同理。

​	一旦确定编译器是否支持一个标志(就是某个版本的c++)，就可以使用标准的cmake方法将这个标志添加到项目中，下面就是用`CMAKE_CXX_FLAGS`将该标志传播到所有地方

```cmake
# 结合上面的一起看
if(COMPILER_SUPPORTS_CXX11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
elseif(COMPILER_SUPPORTS_CXX0X)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
else()
    message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()
```

***

下面这个是CMake v3.1开始可用

```cmake
# set the C++ standard to C++ 11
set(CMAKE_CXX_STANDARD 11)
```

​	Tips:当指定标准失败时，CMAKE_CXX_STANDARD会返回带最接近的适当标准，比如当你指定`-std=gnu11 `,最终可能得到的是`-std=gnu0x`。所以这可能在编译的时候出现意外的失败。

***

下面这个是CMake v3.1开始可用

使用`target_compile_features`函数来指定c++版本

```cmake
add_executable(hello_cpp11 main.cpp)

# set the C++ standard to the appropriate standard for using auto
target_compile_features(hello_cpp11 PUBLIC cxx_auto_type)

# Print the list of known compile features for this version of CMake
message("List of compile features: ${CMAKE_CXX_COMPILE_FEATURES}")
```

Tisp:

- 跟其它 target_* 函数一样，可以为选定目标指定作用域(这里是PUBLIC),这将填充目标的`INTERFACE_COMPILE_FEATURES`属性;
- 可用的版本都在变量`CMAKE_CXX_COMPILE_FEATURES`，可以通过上面的代码获取这些可用版本。

#### 4.2.11 add_subdirectory()

==add_subdirectory== -向当前工程添加存放源文件的子目录，并可以指定中间二进制和目标二进制存放的位置

- 语法：add_subdirectory(source_dir [binary_dir] [EXCLUDE_FROM_ALL])


​	顶级的CMakeLists.txt调用子目录中的CMakeLists.txt来创建内容,目录结构是：

> .
> ├── CMakeLists.txt    # Top level CMakeLists.txt
> ├── subbinary
> │   ├── CMakeLists.txt  # to make the executable
> │   └── main.cpp   # source for the executable
> ├── sublibrary1 
> │   ├── CMakeLists.txt   # to make a static library
> │   ├── include
> │   │   └── sublib1
> │   │       └── sublib1.h
> │   └── src
> │       └── sublib1.cpp
> └── sublibrary2
>  ├── CMakeLists.txt   # to setup header only library
>  └── include
>      └── sublib2
>          └── sublib2.h

- subbinary - 是执行程序的文件
- sublibrary1 - 一个static libaray
- sublibrary2 - A header only library   (暂时理解为只有头文件，这个头文件里是有源码实现的)

开始：

(1)、顶级CMakeLists.txt

```cmake
cmake_minimum_required (VERSION 3.5)
project(subprojects)
# 子文件夹里都要有一个CMakeLists.txt文件；哪怕子文件夹sublibrary1它是空的
add_subdirectory(sublibrary1)
add_subdirectory(sublibrary2)
add_subdirectory(subbinary)  
```

（2）、sublibrary2中的CMakeLists.txt：

```cmake
# 子目录里也是可以设置项目名的
project (sublibrary2)

add_library(${PROJECT_NAME} INTERFACE)      # INTERFACE这是固定写法
add_library(sub::lib2 ALIAS ${PROJECT_NAME})  # 上面一行是生成库名，这行是在取别名

target_include_directories(${PROJECT_NAME}
    INTERFACE
        ${PROJECT_SOURCE_DIR}/include
)
```

​	Tips:当创建的库文件时只由一个头文件创建时，cmake支持`INTERFACE`目标来允许创建目标而不需要任何构建输出,也就是上面的`add_library(${PROJECT_NAME} INTERFACE)`;就当只有一个头文件，来构建时就按这上面的写法。

（3）、sublibrary1中的CMakeLists.txt：

```cmake
project (sublibrary1)

# 源文件和头文件都有的写法就是这样
add_library(${PROJECT_NAME} src/sublib1.cpp)   # 把源文件生成库文件
add_library(sub::lib1 ALIAS ${PROJECT_NAME})   # 同样也给取了一个别名

target_include_directories( ${PROJECT_NAME}
    PUBLIC ${PROJECT_SOURCE_DIR}/include
)
```

（4）、执行文件subbinary中的CMakeLists.txt：

```cmake
project(subbinary)
add_executable(${PROJECT_NAME} main.cpp)

# 从subproject1链接静态库，使用的是这个库的别名`sub::lib1`
# 从subproject2只是头文件构建的库文件(the header only library)链接，使用它的别名`sub::lib2`
# 下面这步会使为了生成这个target的include directories都被添加进这个项目（从子文件夹链接库文件）
target_link_libraries(${PROJECT_NAME}
    sub::lib1    # 这里就是用到了上面的别名
    sub::lib2
)
```

Tips：

- 从cmake-v3开始，生成二进制文件，链接库文件时，不需要再添加项目的include directories，这是在创建库文件时，这由target_include_directories()命令范围控制，在这里subbinary可执行文件链接了sublibrary1和sublibrary2库，它会自动包含\${sublibrary1_SOURCE_DIR}/inc和${sublibrary2_SOURCE_DIR}/inc文件夹，因为它们是和库的PUBLIC和INTERFACE作用域一起导出的；

- 如果库文件创建了一个库，那其它项目可以通过`target_link_libraries()`命令中的项目名称来引用，意味着不必引用新库的完整路径，它是作为依赖添加的，像这样：

  ```cmake
  target_link_libraries(subbinary     # 这里是执行文件的名称
      PUBLIC                 # 我好像不要这PUBLIC也行啊
          sublibrary1         # 这是sublibrary1这个子文件夹中生成库文件的名称
          sublibrary2
  )   # 当然是可以像上面用提前定义好的别名的
  ```

#### 4.2.12 option()

CMakeLists.txt中有这么一句：

> option(TNN_DEMO_WITH_WEBCAM "with webcam" OFF)
>
> if (TNN_DEMO_WITH_WEBCAM)
>   	set(OpenCV_DIR /opt/opencv-3.4.13/install/share/OpenCV)
>   	find_package(OpenCV 3 REQUIRED)    # opencv最小的版本要求是3，版本4可能不行，就需要安装版本3，且指定路径
>   	include_directories(${OpenCV_INCLUDE_DIRS})
> endif()

然后若是需要启用opencv，就在cmake时加上参数：cmake -DTNN_DEMO_WITH_WEBCAM=ON

### 4.3 进阶其它

​	配置文件生成，使用configure_file函数注入CMake变量。简单来说，就是它本来可能是path.h.in这样一个头文件，它其实就是头文件，只是里面有些变量是用的CMake的写法，比如这样`const char* path = "@CMAKE_SOURCE_DIR@";`(两个@是固定写法)，然后就可以在cmake时把变量传进去，可能的写法就是：

`configure_file(path.h.in ${PROJECT_BINARY_DIR}/path.h @ONLY)`  # 这样就会在二进制文件处生成一个path.h，且里面的CMake变量也变成了对应的，那么path.h里的内容const char* path =CMakeLists.txt所在的路径  这个@ONLY代表path.h.in中只能用@@的语法

CMAKE_SOURCE_DIR就是cmake的变量



还有一个类似

var.h.in的内容可能是`const char* ver = "${cf_example_VERSION}";` 那么就是

configure_file(var.h.in ${PROJECT_BINARY_DIR}/var.h)  也会生成一个var.h里面的内容也被替换了

cmake是没有这个cf_example_VERSION这个变量的，是可以自己指定的；

> set(cf_example_VERSION_MAJOR 0)
> set (cf_example_VERSION_MINOR 2)
> set (cf_example_VERSION_PATCH 1)
>
> set (cf_example_VERSION "\${cf_example_VERSION_MAJOR}.​\${cf_example_VERSION_MINOR}.${cf_example_VERSION_PATCH}")

那最后得到的.h文件里就是const char* ver = "0.2.1"；

### 4.3 常用模板

#### 4.3.1 ==不同库添加它的.cmake路径==

​	总结：先看这个库的.cmake文件的名字，比如OpenCVConfig.cmake，那前缀就一定是OpenCV；在弄glfw库是，提示是not found GLFW3，它的文件是glfw3Config.cmake，那前缀就一定是glfw3，后面可接_ROOT或是\_DIR。

- OpenCVConfig.cmake：export OpenCV_DIR=/opt/opencv-4.5.3/install/lib64/cmake/opencv4
- glfw3Config.cmake：export glfw3_ROOT=/opt/glfw-3.3.8/my_install/lib/cmake/glfw3
- 

#### 4.3.2 OpenCV模板

​	有的时候也不必直接去CMakeLists.txt中直接set (OpenCV_DIR)的值，linux可以export这个环境变量，windows可以set(shell中有详细的讲)或者，直接在cmake时指定，比如：
​	cmake -DOpenCV_DIR=D:/lib/opencv_4.5.3/build/x64/vc15/lib  ..  # 这就很明了了

这是opencv官方sample里的CMakeLists.txt

```cmake
# cmake needs this line
cmake_minimum_required(VERSION 3.1)

# Enable C++11
set(CMAKE_CXX_STANDARD 11)   # 有的只要了这一句
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)  # 尽量都要，不然有时会因为这出问题

# Define project name
project(opencv_example_project)

# Find OpenCV, you may need to set OpenCV_DIR variable to the absolute path to the directory containing OpenCVConfig.cmake file
# via the command line or GUI
# set(OpenCV_DIR D:/lib/opencv/build/)   # 两个效果是一样的
# set(OpenCV_DIR D:/lib/opencv/build/x64/vc15/lib)  # 这俩行是针对window（还是建议用这个，clion上面那个不行）
# 若果是linux下要手动设置它的环境，详见`环境问题`中opencv的安装
set(OpenCV_DIR /opt/opencv-3.4.13/install/share/OpenCV) # 指定你的版本路径一定是到有`OpenCVConfig.cmake`这些有.cmake的路径
# 可能新版的成了 /opt/opencv-4.3.0/install/lib64/cmake/opencv4 这种

find_package(OpenCV REQUIRED)   # 在linux下，这是配置了OpenCV的环境，直接使用这一句就够了
include_directories(${OpenCV_INCLUDE_DIRS})  # 保险起见，有些找到了后要把路径再添加一下

# If the package has been found, several variables will be set, you can find the full list with descriptions in the OpenCVConfig.cmake file.
# Print some message showing some of them
if(OPENCV_FOUND)
	message(STATUS "OpenCV library status:")
	message(STATUS "    config: ${OpenCV_DIR}")
	message(STATUS "    version: ${OpenCV_VERSION}")
	message(STATUS "    libraries: ${OpenCV_LIBS}")
	message(STATUS "    include path: ${OpenCV_INCLUDE_DIRS}")
endif()

# Declare the executable target built from your sources
add_executable(opencv_example example.cpp)

# Link your application with OpenCV libraries
# 比如opencv一定要加了下面这行include的时候头文件才不会报错
target_link_libraries(opencv_example LINK_PRIVATE ${OpenCV_LIBS})
#TARGET_LINK_LIBRARIES( eyeLike ${OpenCV_LIBS} )  # 有些代码里也会这么写，就是改成了大写

target_link_libraries(main ncurses)  # 还有这种，ncurses是一个三方库，直接写进来(写俄罗斯方块遇到过的三方库，且不用find_package这种形式)
```

#### 4.3.3 cuda-tensorrt模板

大致的文件结构：

> ├── CMakeLists.txt
> ├── main.cpp
> ├── plugin
> │   ├── yololayer.cu
> │   └── yololayer.h
> ├── src
> │   ├── calibrator.cpp
> │   ├── calibrator.h
> │   ├── macros.h
> │   ├── model.cpp
> │   ├── model.h
> │   ├── ......省略了一些

这个是yolov5-tensorrt的CMakeLists.txt，主要涉及到.cu文件的一起的编译

```
cmake_minimum_required(VERSION 3.12)
project(cuda_demo)

# 1.这两行要不要都能编译通过
# add_definitions(-DAPI_EXPORTS)
# option(CUDA_USE_STATIC_CUDA_RUNTIME OFF)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_BUILD_TYPE Debug)

# 2.这两行是必须的，不然.cu文件编译不了，# nvcc的路径，whichis nvcc获取
set(CMAKE_CUDA_COMPILER /usr/local/cuda/bin/nvcc)
enable_language(CUDA)

# 3.OpenCV
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})  # 方便写的时候找到头文件

# 4.CUDA
# find_package(CUDA REQUIRED)
include_directories(/usr/local/cuda/include)
link_directories(/usr/local/cuda/lib64)

# 5.TensortRT
include_directories(/home/nvidia/TensorRT-8.2.5.1/include/)
link_directories(/home/nvidia/TensorRT-8.2.5.1/lib/)

include_directories(${CMAKE_SOURCE_DIR}/src/)
include_directories(${CMAKE_SOURCE_DIR}/plugin/)

file(GLOB_RECURSE SRCS ${PROJECT_SOURCE_DIR}/src/*.cpp ${PROJECT_SOURCE_DIR}/src/*.cu)
file(GLOB_RECURSE PLUGIN_SRCS ${PROJECT_SOURCE_DIR}/plugin/*.cu)

add_library(myplugins SHARED ${PLUGIN_SRCS})
target_link_libraries(myplugins nvinfer cudart) # nvinfer是tensoert库中的动态库，cudart是cuda的lib64中的动态库

add_executable(main main.cpp ${SRCS})
target_link_libraries(main myplugins ${OpenCV_LIBS})
```



### 4.4 添加第三方库总结(必看)

一个总结性的东西，常见找不到文件报错及第三方库的设置。

工作中的总结：

- 一般一个第三方库，在github上找到源码放在/opt下，然后直接在源码里去走cmake那一套(也许官方有其它教程步骤，先这样弄，不行再去试官方的)；
- 然后在make install把库文件、头文件安装在源码的install目录下，定要注意看，要是有生成`*.cmake`文件，就可以直接添加路径使用了；
- 要是没有*.cmake文件，我已经用capstone这个库试了，按照4.4.1添加头文件路径和库文件路径，cmake通过了，但是在make时会出一些问题（当然还是先这样做，试一试先），像4.4.1操作了还是不行，就不要指定cmake的自定安装路径，就make install到系统的默认地方，就不会出错了。

Tips：有的项目，坐着都会提供一个Dockerfile文件，里面可能会又比较详细的步骤，可以参考这个文件其构建环境。

#### 4.4.1 关于找不到第三方库的报错的解决

- 本地已经解压了TensorRT了，CMakeLists.txt中完全没有提及到tensort，但项目中的确有（很有可能是直接把头文件，库文件直接全部复制到cuda中去了，像cudnn那样）；但是我们没有复制过去，make编译的时候就会报错类似于没有`NvInfer.h`这样的文件，那就要==加头文件路径==：
  	`include_directories(/opt/TensorRT-7.2.3.4/include/)` 

- 之后再执行可能又会是(没有指定其库文件路径)：
  > cannot find -lnvifer
  > cannot find -lnvifer_plugin
  > cannot find -lnvparsers
  >
  > collet2：error：ld return ed 1 exit status

  这就是找不到库文件，然后也是全局搜索`*nvifer.so`，也可能是`*nvifer.a`,找到它的路径然后：

- 下面这是添加库文件路径的函数：
    `link_directories(/opt/TensorRT-7.2.3.4/lib)` 

  到此问题就解决了。

同时看到一个衍生问题：直接添加库的对应函数是link_libraries(),把所有库添加进去就好了，注意，这不需要我们手动添加.lib后缀了（这个还没试验过）

#### 4.4.2 第三方库路径设置

一般要用的一个第三方库，如果它有XXXConfig.cmake

- 那就两步走：

  > set(XXX_DIR 对应.cmake的路径)
  >
  > find_package(XXX REQUIRED)

- 若是一般的库，没这个配置文件，那就直接加两句：

  - 当路径里有空格时，一定要加引号“”
  
  > include_directories(/opt/TensorRT-7.2.3.4/include/)
  >
  > link_directories(/opt/TensorRT-7.2.3.4/lib/)
  >
  > \# 一般来说就是对应的头文件和库文件路径，当然为了保险起见，很多的还有bin路径，也写进cmake，添加一个临时环境变量，如下：
  >
  > export PATH=/opt/TensorRT-7.2.3.4/bin:$PATH

总结：

- 一般来说，第三方库的头文件、库文件的路径(只是路径)在最开始就用`include_directories()`、`link_directories()`指定;
- 自己的工程文件，要生成库文件，就需要自己的头文件，那就是用`target_include_directories()`链接库名和其使用的自己写的头文件路径;
- 最终再把库文件链接到执行文件上就是用`target_link_libraries()`。

***

​	除了在CMakeLists.txt中使用如上函数添加，还可以把这个加进环境变量进行配置,下面一protobuf作为一个参考,不一定是要把所有的都做添加，一般就是添加库文件路径和头文件路径：

> ####### add protobuf lib path ########
>
> #(动态库搜索路径) 程序加载运行期间查找动态链接库时指定除了系统默认路径之外的其他路径
>
> export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/protobuf-3.17.3/install/lib/
>
> #(静态库搜索路径) 程序编译期间查找动态链接库时指定查找共享库的路径
>
> export LIBRARY_PATH=$LIBRARY_PATH:/opt/protobuf-3.17.3/install/lib/
>
> #执行程序搜索路径
>
> export PATH=$PATH:/opt/protobuf-3.17.3/install/bin/
>
> #c程序头文件搜索路径
>
> export C_INCLUDE_PATH=$C_INCLUDE_PATH:/opt/protobuf-3.17.3/install/include/
>
> #c++程序头文件搜索路径
>
> export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/opt/protobuf-3.17.3/install/include/
>
> #pkg-config 路径
>
> export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/protobuf-3.17.3/install/lib/pkgconfig/
>
> ######################################
>
> 
>
> #(动态库搜索路径) 程序加载运行期间查找动态链接库时指定除了系统默认路径之外的其他路径
> export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/TensorRT-7.2.3.4/lib
>
> #(静态库搜索路径) 程序编译期间查找动态链接库时指定查找共享库的路径
> export LIBRARY_PATH=$LIBRARY_PATH:/opt/TensorRT-7.2.3.4/lib
>
> #执行程序搜索路径
> export PATH=$PATH:/opt/TensorRT-7.2.3.4/bin
>
> #c++程序头文件搜索路径
> export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/opt/TensorRT-7.2.3.4/include

#### 4.4.3 设置库文件路径

​	除了export LD_LIBRARY_PATH外，还有一种方式：在 /etc/ld.so.conf.d/ 目录中编辑添加第三方库文件的XXX.conf文件，里面写上这个三方库的库文件路径，大致如下：

> 1. vim /etc/ld.so.conf.d/opencv4.conf          // 可能是一个空文件，写入步骤2的内容
> 2. `/usr/local/lib64`
> 3. ldconfig

### ==4.5 动态库搜索先后顺序==

动态库的搜索路径搜索的先后顺序是：

1. 编译目标代码时指定的动态库搜索路径,-L；

2. 环境变量LD_LIBRARY_PATH指定的动态库搜索路径；

3. 配置文件/etc/ld.so.conf中指定的动态库搜索路径； # 一般弄完后 ldconfig 更新一下

   - /etc/ld.so.conf中的写法一般是

     ```
     include ld.so.conf.d/*.conf
     /usr/local/ffmpeg/lib/
     /usr/local/lib
     ```

     第一行是自带的，这样会把ld.so.conf.d/*.conf这所有配置文件读进来，可以把自己的一个动态库文件写一个放这ld.so.conf.d/路径里面。

     后面两行就是自己加的动态库路径

4. 默认的动态库搜索路径/lib；

5. 默认的动态库搜索路径/usr/lib。

​	在上述1、2、3指定动态库搜索路径时，都可指定多个动态库搜索路径，其搜索的先后顺序是按指定路径的先后顺序搜索的。

### 4.6 cmake中使用pkg-config

pkg-config简单介绍：

pkg-config默认会在以下路径中查找指定的包（库）对应的.pc文件：

- `/usr/lib/pkgconfig`目录
- `/usr/share/pkgconfig`目录
- `/usr/local/lib/pkgconfig`目录
- `/usr/local/share/pkgconfig`目录
- `PKG_CONFIG_PATH`环境变量里的目录（可通过`export PKG_CONFIG_PATH=XXX`来修改）
- 给pkg-config传入的.pc文件绝对路径

而比较常用的选项是：

- --cflags：表示C/C++编译选项，例如指定头文件搜索目录；
- libs：表示链接选项，例如库的绝对目录，链接库按书序列出等。

例如：pkg-config --cflags --libs gstreamer-1.0 就是列出gstreamer-1.0的相关路径。

安装使用：

Ubuntu：apt-get install pkg-config

在windows：首先下载[pkg-config-lite](https://sourceforge.net/projects/pkgconfiglite/files/0.28-1/pkg-config-lite-0.28-1_bin-win32.zip/download)。注意Anaconda/Miniconda中也带了pkg-config，但在cmake中无法使用，所以把它的可执行文件放进Path系统环境变量，但更好的是在cmake中单独配置。

- set(PKG_CONFIG_EXECUTABLE "D:/pkg-config-lite-0.28-1/bin/pkg-config.exe")

下面是一MSVC中的gstreamer的设置的一个例子：

```cmake
cmake_minimum_required(VERSION 2.8.2)
project(hello_gstreamer)

# 1.设置pkg-config的可执行文件路径
set(PKG_CONFIG_EXECUTABLE "D:\\pkg-config-lite-0.28-1\\bin\\pkg-config.exe")

# 2.把gstreamer-1.0.pc所在的路径放进来
set(ENV{PKG_CONFIG_PATH} "D:\\gstreamer\\1.0\\msvc_x86_64\\lib\\pkgconfig")

# 3.永远是找PkgConfig这个包
find_package(PkgConfig)
# 4.这个ABC是我随便起的，gstreamer-1.0就是gstreamer-1.0.pc的名字
pkg_search_module(ABC REQUIRED gstreamer-1.0)

# 这个还是OK的，有头文件的绝对路径，注意是ABC_LIBRARIES
message(STATUS "=== ABC_INCLUDE_DIRS: ${ABC_INCLUDE_DIRS}")
# 这里只列处了库的名字
message(STATUS "=== ABC_LIBRARIES: ${ABC_LIBRARIES}")

# 5.这两行也是必须的，下面手动把库文件路径放进去
include_directories(${ABC_INCLUDE_DIRS})
link_directories(D:\\gstreamer\\1.0\\msvc_x86_64\\lib)

add_executable(hello_gstreamer basic-tutorial-1.c)
# 6.必须要22行，不然下面这找不到库文件
target_link_libraries(hello_gstreamer LINK_PRIVATE ${ABC_LIBRARIES})
```

### 4.7 编写自己库的.cmake

可以编写自己库的.cmake文件，然后用find_package()来找到我们自己的库，写的方式：
参考[这里](https://github.com/BrightXiaoHan/CMakeTutorial/blob/master/FindPackage/README.md)，很简单的。

### 4.8 find_library | list

​	我的理解是先通过find_package找到库的头文件、库，但是可能库不一定都会用到，就可以使用find_library来查找自己想要的库，方便后续 target_link_libraries 进行链接；

​	然后list这个命令则是有很多的功能，通过不同的参数来指定，比较常用的就是APPEND,就是把一些变量添加到已有变量后面，这样就让所有要链接的库成了一个变量名，直接就链接了。具体参数说明[看这](https://www.pudn.com/news/62b322f6a11cf7345fc8e2dd.html)。

例子就是如下：

- 先看这个项目README中的[编译开关](https://github.com/DeepVAC/libdeepvac#%E7%BC%96%E8%AF%91%E5%BC%80%E5%85%B3)，看有些参数，比如==USE_CUDA==；
- 然后打开其[CmakeLists.txt](https://github.com/DeepVAC/libdeepvac/blob/master/CMakeLists.txt),搜索这个参数，就会看到find_library的使用
- 然后里面136行就有list的使用，以及172行对应的变量，然后274行就target_link_libraries这些库的变量，[这里](https://blog.csdn.net/hankern/article/details/117617179)也做个参考吧。

### 4.9 MACRO 宏定义

​	在[learnOpencv](https://github.com/spmallick/learnopencv/blob/master/stereo-camera/CMakeLists.txt)中看到的MACRO宏定义的使用，比如要编译多个目标时，就可以用这，有点实现了在cmake中循环的味道：

```cmake
cmake_minimum_required(VERSION 2.8.12)
set(CMAKE_CXX_STANDARD 14)

PROJECT(cameracalib)
find_package( OpenCV REQUIRED )
include_directories( ${OpenCV_INCLUDE_DIRS})

# 核心是下面这几行代码
MACRO(add_example name)    # 这里面还可以给几个参数
  add_executable(${name} ${name}.cpp)
  target_link_libraries(${name} ${OpenCV_LIBS})
ENDMACRO()

add_example(capture_images)   # 就是把capture_images.cpp编译成可执行文件
add_example(calibrate)   # 这样子，要编译的可执行文件多的时候，就简单了，就不是每个都去
add_example(movie3d)
```

### 4.10 非常好的多行注释

cpp-httplib这个项目的[cmake](https://github.com/yhirose/cpp-httplib/blob/master/CMakeLists.txt)多行注释写的非常好，用于写示例、一些开关选项非常好。

把它的头部放这看看：

```cmake
#[[
	Build options:
	* BUILD_SHARED_LIBS (default off) builds as a shared library (if HTTPLIB_COMPILE is ON)
	* HTTPLIB_USE_OPENSSL_IF_AVAILABLE (default on)
	* HTTPLIB_USE_ZLIB_IF_AVAILABLE (default on)
	* HTTPLIB_REQUIRE_OPENSSL (default off)
	* HTTPLIB_REQUIRE_ZLIB (default off)
	* HTTPLIB_USE_BROTLI_IF_AVAILABLE (default on)
	* HTTPLIB_USE_CERTS_FROM_MACOSX_KEYCHAIN (default on)
	* HTTPLIB_REQUIRE_BROTLI (default off)
	* HTTPLIB_COMPILE (default off)
	* HTTPLIB_INSTALL (default on)
	* HTTPLIB_TEST (default off)
	* BROTLI_USE_STATIC_LIBS - tells Cmake to use the static Brotli libs (only works if you have them installed).
	* OPENSSL_USE_STATIC_LIBS - tells Cmake to use the static OpenSSL libs (only works if you have them installed).

	-------------------------------------------------------------------------------

	After installation with Cmake, a find_package(httplib COMPONENTS OpenSSL ZLIB Brotli) is available.
	This creates a httplib::httplib target (if found and if listed components are supported).
	It can be linked like so:

	target_link_libraries(your_exe httplib::httplib)

	The following will build & install for later use.

	Linux/macOS:

	mkdir -p build
	cd build
	cmake -DCMAKE_BUILD_TYPE=Release ..
	sudo cmake --build . --target install

	Windows:

	mkdir build
	cd build
	cmake ..
	runas /user:Administrator "cmake --build . --config Release --target install"

	-------------------------------------------------------------------------------

	These variables are available after you run find_package(httplib)
	* HTTPLIB_HEADER_PATH - this is the full path to the installed header (e.g. /usr/include/httplib.h).
	* HTTPLIB_IS_USING_OPENSSL - a bool for if OpenSSL support is enabled.
	* HTTPLIB_IS_USING_ZLIB - a bool for if ZLIB support is enabled.
	* HTTPLIB_IS_USING_BROTLI - a bool for if Brotli support is enabled.
	* HTTPLIB_IS_USING_CERTS_FROM_MACOSX_KEYCHAIN - a bool for if support of loading system certs from the Apple Keychain is enabled.
	* HTTPLIB_IS_COMPILED - a bool for if the library is compiled, or otherwise header-only.
	* HTTPLIB_INCLUDE_DIR - the root path to httplib's header (e.g. /usr/include).
	* HTTPLIB_LIBRARY - the full path to the library if compiled (e.g. /usr/lib/libhttplib.so).
	* httplib_VERSION or HTTPLIB_VERSION - the project's version string.
	* HTTPLIB_FOUND - a bool for if the target was found.

	Want to use precompiled headers (Cmake feature since v3.16)?
	It's as simple as doing the following (before linking):

	target_precompile_headers(httplib::httplib INTERFACE "${HTTPLIB_HEADER_PATH}")

	-------------------------------------------------------------------------------

	FindPython3 requires Cmake v3.12
	ARCH_INDEPENDENT option of write_basic_package_version_file() requires Cmake v3.14
]]
cmake_minimum_required(VERSION 3.14.0 FATAL_ERROR)
```

