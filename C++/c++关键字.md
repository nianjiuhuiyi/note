## 01. static

- static ==修饰的局部变量只执行初始化一次==，而且延长了局部变量的生命周期，直到程序运行结束以后才释放；（想一下imgui，它很多控制窗口开关的bool值都是在循环中定义的，用的static，而不是在循环外定义的全局变量）
- static 修饰全局变量的时候，这个全局变量只能在本文件中访问，不能在其它文件中访问，即便是 extern 外部声明也不可以；（即将变量的作用域限定在当前文件中，其它文件无法访问（在写rk3588时，即使访问了，变量在这个文件被修改了，另一个文件读取还是没变，是有问题的)）
  - 写rk3588时，每个client_*.cpp里的 keepRunning 变量，都要加static，不然到了main.cpp里，就是同一个变量被反复定义了。
- static 修饰一个函数，则这个函数的只能在本文件中调用，不能被其他文件调用。static 修饰的变量存放在全局数据区的静态变量区，包括全局静态变量和局部静态变量，都在全局数据区分配内存。==初始化的时候自动初始化为`0`==；  // 这就是想这个函数只为本文件服务，当本文件被其它文件调用时，不要使用此关键字
- 不想被释放的时候，可以使用static修饰。比如修饰函数中存放在栈空间的数组。如果不想让这个数组在函数调用结束释放可以使用 static 修饰；
- 考虑到数据安全性（当程序想要使用全局变量的时候应该先考虑使用 static）；
- 不同函数之间，是可以有同名的静态变量，只是各自的函数有一个各自的副本，[看这](https://g4g-ccpp.apachecn.org/#/docs/c-c-quiz-111-question-2)、[这](https://blog.csdn.net/Max_Cong/article/details/100506606)。 // 还需再思考
- 类中：
  - 被static修饰的变量属于类变量，可以通过**类名.变量名**直接引用
  - 被static修饰的方法属于类方法，可以通过**类名.方法名**直接引用
  - （被 static 修饰的变量、被 static 修饰的方法统一属于类的静态资源，是类实例之间共享的，换言之，一处变、处处变。）

更多特性参考：[这里](https://www.runoob.com/w3cnote/cpp-static-usage.html)。以及自己写的命名空间中的“未命名的命名空间”。

## 02. inline

​	为了解决一些频繁调用的==小函数==大量小韩栈空间（栈内存）的问题，在函数前加了`inline`修饰符，表示为`内联函数`。==内联函数可避免函数调用的开销==，它通常是比较小巧，代码数也不多，它将会在每个调用点上“内联地”展开，大概如下：

```
cout<<shortString(s1, s2)<<endl;   
cout<<(s1.size() < s2.size() ? s1: s2)<<endl;
```

​	说明：第1行这个是个函数，假设它是内联函数，就会在编译过程中把它函数内的内容具体展开，从而消除了这个函数的运行时开销（一次函数调用包含一系列工作：调用前要先保存寄存器，并在返回时恢复；可能需要拷贝实参；程序转向一个新的位置继续执行）。

- inline 只适合涵数体内代码简单的涵数使用，不能包含复杂的结构控制语句例如 while、switch;
- inline 函数仅仅是一个对编译器的建议，所以最后能否真正内联，看编译器的意思，它如果认为函数不复杂，能在调用点展开，就会真正内联，并不是说声明了内联就会内联，声明内联只是一个建议而已;
- 内联是以==代码膨胀（复制）==为代价，仅仅省去了函数调用的开销，从而提高函数的执行效率;
- 一般内联机制用于优化规模较小、流程直接、频繁调用的函数（内联说明只是向编译器发出一个请求，编译器可以选择忽略这个请求）。

​	故：只有当==函数非常短小==的时候它才能得到我们想要的效果；但是，如果函数并不是很短而且在很多地方都被调用的话，那么将会使得可执行体的体积增大，==如果内联函数不能增强性能，就避免使用它！==

更多特性参考：[这里](https://www.runoob.com/w3cnote/cpp-inline-usage.html)。

## 03. typedef

​	官方定义：==任何声明变量的语句前面加上`typedef`之后，原来是变量的都变成一种类型。不管这个声明中的标识符号出现在中间还是后面。==

​	按照c++菜鸟教程的说法，typedef是为一个已有类型取一个新的名字。

​	根据effective modern c++ 建议使用using而非typedef

```c++
typedef int NUM;
NUM a = 10;
NUM(b) = 12;   // 这两种形式都是一样的
```

举例：

```c++
// 定义了一个名为x的int类型
typedef int x;  
// 定义了一个名为s的struct类型
typedef struct {char c;} s;
// 定义了一个名为P的int类型指针
typedef int *p;
// 定义了一个名为A的int数组类型
typedef int A[];
// 定义了一个名为f，参数为空，返回值为int的函数类型
typedef int f();
// 定义了一个名为g，含一个int参数，返回值为int的函数类型
typedef int g(int);
```

​	Ps：可以看看opencv定义的cv::String，它就是用了typedef，具体就是:

```c++
typedef std::string myString;
myString s = "hello world!";
s.append("这也是可以的");  // 可以
std::cout << s ;  // 这就是错的
```

​	解释：前面本应是声明了一个变量，用了`typedef`后，它就变成了数据类型，后面实例化的对象s可以有标准string的所有方法。

==一定要去看1 C++基础.md中5.3数组的打印==，里面有一个例子，很好的使用了typedef,及其进阶使用，遇到这块的使用时，一定要去看。

### 类型别名

方式一：typedef

typedef double my_double;  // my_double跟double就一样

typedef my_double my_double_123;   // 同上

方式二：新标准规定了一种新的方法

using my_calss = double;  // my_class就是double的同义词

注意去看看1 C++基础.md中那个==数组打印==中二维的处理以及==返回数组指针==对这个的用法，很关键。



带指针或const类型的别名：

typedef char *my_char;    // mychar实际是类型char\*的别名

```c++
typedef char *my_char;
const my_char a_str = 0;  // a_str就是一个指针(类型就是上面的char *)，再加了一个const,那它就是一个指向char的常量指针
const my_char *ps;  // ps是一个指针，它的对象是指向char的常量指针
```



## 04. #if  #else  #endif

条件注释,以`#if`开始，`#endif`结束，是成对的，可以不要`#else`

```c++
#if condition            // 注意不要冒号:
	code1
#else
    code2
#endif
```

实例：（这里面是可以加宏常量的定义的）

```c++
#if 1
	int a = 123;
#define AGE 12    
#define FILENAME "workers.txt"  // 定义一个宏常量来做文件名,注意没有分号，
#endif

// 或者
#include <NvInfer.h>

#if NV_TENSORRT_MAJOR >= 8            // 注意看这里用了条件
#define TRT_NOEXCEPT noexcept
#define TRT_CONST_ENQUEUE const
#else
#define TRT_NOEXCEPT
#define TRT_CONST_ENQUEUE
#endif
```

说是里面还可以嵌套#if..#endif，我没试成功。

它还可以是 #if..#elif..#elif..#endif

在yolov5的tensoert的中我改到一个代码：(参考吧)

```c++
#define USE_INT8  // set USE_INT8 or USE_FP16 or USE_FP32

#ifdef USE_INT8
    const static float kConfThresh = 0.1f;
#else
    const static float kConfThresh = 0.5f;
#endif
```

上面这还有等价写法：==我喜欢这个方式，这个方式用来改局部不同代码，不再是注释的方式==。

```c++
#define USE_INT8  // set USE_INT8 or USE_FP16 or USE_FP32

#if defined(USE_INT8)
    const static float kConfThresh = 0.1f;
#elif defined(USE_FP16)
    const static float kConfThresh = 0.5f;
#endif
```



## 05. #ifndef #define #endif

​	这个在.h头文件中是最常见的，是为了防止两次includde同一个头文件。假如有一个头文件是sample.h

```c++
#ifndef __SAMPLE_h_
#define __SAMPLE_h_

// OpenCV includes
#include <opencv2/core/core.hpp>
// For FHOG visualisation
#include <dlib/opencv.h>
// C++ standard stuff
#include <stdio.h>
// For threading and timing
#include <chrono>
#include <ctime>

// Filesystem stuff
// It can either be in std filesystem (C++17), or in experimental/filesystem (partial C++17 support) or in boost
#if __has_include(<boost/filesystem.hpp>)
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
namespace fs = boost::filesystem;
#elif __has_include(<filesystem>)
#include <filesystem>
namespace fs = std::filesystem;
#elif __has_include(<experimental/filesystem>)
#include <experimental/filesystem>
namespace fs = std::filesystem;
#endif        // 这一段就可看做是条件注释

#endif
```

​	第一次includede的时候由于`__SAMPLE_h_`没定义，所以宏里面的内容(也就是头文件的全部内容)会被编译，而第二次include的实时，由于`__SAMPLE_h_`已经被定义，所以里面的内容就不会被编译了。然后一般这个宏的名字也是结合头文件的名字，加一点下划线，使它不跟其它宏冲突就好了。

以及：检查前面如果定义了这个宏，这里就取消这个宏定义，避免后续自己定义这个名字时被认为是对宏的调用。

```c++
#ifdef _S
#undef _S    // 这种取消宏的定义。。可以单成一行，单独使用不做判断
#endif
```

在使用rk3588时，遇到过这两种方式都是OK的，详见“GCC编译器.md”中的4.2.13 add_definitions

```c++
// 方式一： #ifdef BUILD_VIDEO_RTSP    // 也是ok的，应该是两种写法
#if defined(BUILD_VIDEO_RTSP)        // 这就是是那个CMakeLists.txt中的定义，（方式二）
#include "mk_mediakit.h"
#endif
```



## 06. extern

用于声明变量，不要显示的初始化变量。

- extern int i;   // 声明 i 而非定义 i
- int j;   // 声明并定义了j
- extern double pi = 3.14;  // 定义，变量赋初始值，就抵消了extern的作用

注意：这个07.const里也有关于这个extern的在这一块的使用。

extern在c++中还作为链接指示的关键字。

## 07. const

```c++
const int i = gret_size();    // 正确，运行时初始化
const int j =42;            // 正确，编译时初始化
const int k;                // 错误，const对象必须初始化
```

​	const int bufSize = 512;  
​	const说明使用：当以编译初始化的方式定义一个const对象时，编译器会将在编译过程中把用到该变量的地方都替换成相应的值(512)；

​	为了执行上述替换，编译器必须知道变量的初始值，如果程序包含多个文件，则每个用了const对象的文件都必须得能访问到它的初始值，要做到这一点，就必须在每一个用到了变量的文件中都对它定义(然而声明可以有多次，但是定义只能有一次)，为了支持这一用法，又要避免重复定义，默认情况下，const对象被设定为仅在文件内有效，当多个文件中出现了同名的const变量时，其实等同于在不同文件中分别定义了独立的变量。

​	某些时候有这样一种const变量，它的初始值不是一个常量，是一个表达式，但又确实有必要在文件间共享，我们并不希望编译器为每个文件分别生成独立的变量，而是想要让这类const对象像其它对象一样工作————就是在一个文件中定义const，而在其它多个文件中声明并使用它。
​	==解决办法==是：对于const变量不管是声明还是定义都添加`extern`关键字，这样只需定义一次就行了，然后就可以在多个文件之间共享const对象。

```c++
// file_1.cc 定义并初始化了一个常量，该常量能被其它文件访问
extern const int bufSize = my_func();
// file_1.h头文件
extern const int bufSize;    // 与file_1.cc中定义的bufSize是同一个
```

### 顶层/底层const

- 顶层const：表示指针本身就是个常量；
- 底层const：表示所指的对象就是一个常量。

```c++
int i = 0;
int *const p1 = &i;  // 不能改p1的值，这是一个顶层const
const int b1 = 45;   // 这也是顶层const
const int *p2 = &i;   // p2可以修改，它是底层const
const int *const p3 = &i;  // 靠左的是底层const；靠右的是顶层const
const int $ref = b1;     // 用于声明引用的const都是底层const
```

### constexpr和常量表达式

​	==常量表达式==(const expression）：是指值不会改变并且在编译过程就能得到计算结果的表达式(加这个歌就代表让其在编译期就计算)。显然，字面值属于常量表达式，用常量表达式初始化的 const对象也是常量表达式。

​	一个对象(或表达式)是不是常量表达式，由它的数据类型和初始值共同确定，例如：

```c++
const int max_files = 20;   // max_files是常量表达式
const int abc = max_files + 1;   // abc是常量表达式
int staff_szie = 27;     // staff_size就不是常量表达式(就是一个普通int)
const int sz = get_size();     // sz不是常量表达式，它虽有const，但要具体到运算后才有值
```

关键字 ==constexpr==

​	c++11新标准规定，允许将变量声明为constexpr类型，以便编译器来验证变量的值是否是一个常量表达式，声明为constexpr的变量一定是一个常量，而且必须使用常量表达式初始化。

```c++
constexpr int mf = 20;   // 20是常量表达式
constexpr int abc = mf + 1;   // mf + 1 是常量表达式
constexpr int sz = get_size();   // 只有当get_size()是一个constexpr函数时，这才是一条正确的声明语句
```

注：

- 不能使用普通函数作为constexpr变量的初始值，新标准允许定义一种特殊的constexpr函数，这种函数应该足够简单到编译时就可以计算其结果，这样就能用constexpr函数去初始化constexpr变量了。
- 一般来说，==如果认定变量是一个常量表达式，那就把它声明成constexpr类型==。

#### constexpr函数

它与其它函数类似，不过要准时几项预定：

- 函数的返回类型及所有形参的类型都是字面值类型

- 函数体中必须有且只有一条return语句：

  ```c++
  constexpr int new_sz() { return 42; }
  constexpr int foo = new_sz();   // OK,foo是一个常量表达式
  ```

***

### 尽量使用常量引用

```c++
int add(int &a, int &b)
{
	return a + b;
}

int main()
{
	int i = add(1, 2);    // 这里就会报错，因为穿进去的实参1、2是右值，形参不能是引用类型
	return 0;
}
```

所以为了这种函数传参进去的时候不是对象的话，直接传的值，那么就必须是常量引用，就如下这样改：

int add(const int &a, const int &b);

## 08. decltype

​	希望从表达式的类型推断出要定义的变量的类型，但是不想用该表达式的值初始化变量，c++11新标准中引入了第二种类型说明符，它的作用是选择并返回操作数的数据类型，在此过程中，编译器分析表达式并得到它的类型，却不实际计算表达式的值：

​	decltype(f()) number = x;   //number的类型就是函数f的返回类型(编译器并不实际调用函数f，只会是要它的返回值类型)

​	decltype处理顶层const和引用的方式与auto有些不同，如果decltype使用的表达式是一个变量，则decltype返回该变量的类型(包括顶层const和引用在内)：

```c++
const int num = 123, &ref = num;
decltype(num) x = 12;    // x的类型是const int
decltype(ref) y = x;     // y的类型是const int&
decltype(ref) z;   // 错误的，z是一个引用类型，必须初始化
```

注意：使用decltype使用了括号和不用括号有区别

```
int i = 42;
delctype((i)) d;  // 错误：用的(i)，那d就是int&,是引用，必须初始化
decltype(i) e;     // 正确：e是一个未初始化的int
```

​	故：decltype((variable)) 注意是加括号的变量的结果永远是引用，而decltype(variable)结果只有当variable本身就是一个引用时才是引用

示例：

```c++
int a = 3, b = 4;
decltype(a) c = a;   // 3
decltype((b)) d = a;  // 一个引用,4
++c;
++d;  // d是引用，那么a的值也会改，也就成了4
// 所以最后这四个值都是 4
```



​	赋值是会产生引用的一类典型表达式，引用的类型就是左值的类型。也就是说，如果 i 是 int，则表达式 i=x 的类型是 int&。根据这一特点，请指出下面的代码中每一个变量的类型和值。

```cpp
int a = 3, b = 4;
decltype(a) c = a;
decltype(a = b) d = a;
```

解：

- c 是 int 类型，值为 3。d 是 int& 类型，绑定到 a。



​	auto和decltype的不同：decltype 处理顶层const和引用的方式与 auto不同，decltype会将顶层const和引用保留起来（auto的处理方式可参看1C++基础.md）。

```c++
int i = 0, &r = i;
//相同
auto a = i;
decltype(i) b = i;

//不同 
auto c = r;  // c就是int
decltype(r) d = r;  // d是一个 int&，d就是引用的r

std::cout << r << std::endl;  // 0
c++;
std::cout << r << std::endl;  // 0
d++;
std::cout << r << std::endl;  // 1
```

## 09. static_cast 强制类型转换

表达式：`cast-name<type>(expression)` 

- type：转换的目标类型，如果type是引用类型，则结果是左值;
- expression：要转换的值;
- cast-name具体有：static_cast、dynamic_cast、const_cast和reinterpret_cast  (这些好像都是c++关键字，跟int是一样的)

​	static_cast：任何具有明确定义的类型转换，只要不包含底层const，都可以使用static_cast，实例：

```c++
// 进行强制类型转换以便执行浮点数除法
int i = 1, j = 2;
double slope =  static_cast<double>(i) / j;
```

这样就等于是告诉读者和编译器，我们不在乎潜在的精度损失。

const_cast：一种涉及const的强制类型转换将底层const对象转成对应的非常亮类型，或者执行相反的转换，说是常常用于有函数重载的上下文中；

reinterpret_cast：通常为运算对象的位模式提供较低层次上的重新解释，就是把运算对象的内容解释成另外一种类型，本质上依赖于机器且非常危险（遇到一次，要转换指针类型时用的这个）；

dynamic_cast：和继承及运行时类型识别一起使用。

---

旧式的强制类型转换：在早期c++中，显示进行前置类型转换包括两种形式：

- type (expr);       // 函数类型的强制类型转换
- (type) expr;       // C语言风格的强制类型转换
  - char *pc = (char\*) ip;   // 这里ip原来是执行整数的指针（那这的效果就与使用reinterpret_cast一样）

总结：新版的话就建议使用 static_cast ，但是旧式的转换也没问题诶，用起来也比较简单。

## 10. static_assert 静态断言

​	static_assert可让编译器在编译时进行断言检查：这个与 assert()断言(运行时断言)的区别是，这个是在编译时进行断言发现错误，而不是在运行时，不会降低运行效率，还能提前发现问题：

```c++
static_assert( constant-expression, string-literal );  // c++11
static_assert( constant-expression ); // C++17 （后面的文字就是选填了）
// 例：
static_assert(sizeof(void *) == 4, "64-bit code generation is not supported.");
// 该static_assert用来确保编译仅在32位的平台上进行，不支持64位的平台，该语句可以放在文件的开头处，这样可以尽早检查，以节省失败情况下的编译时间
```

