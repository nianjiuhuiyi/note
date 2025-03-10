# Primer c++第5版补充内容



c++的一个api查询[网址](https://cplusplus.com/)。（好像不是那么好用）

Effective Modern C++：[地址](https://github.com/CnTransGroup/EffectiveModernCppChinese)。

传参实例化类对象时，用()、{}都是可以的，[这里](https://zhuanlan.zhihu.com/p/268894227)看区别。(Person是一个自定义类,接受一个string的传参)即

Person p_a(“张三”)；
Person p_a{“张三”}；   这俩都是可以的，最近看到不少类实例化用的这个{}  # 更新，看到一些使用{}这个方式实例化(这是列表初始化)的，很大概率这个类是一个stl的容器类别，或者这个自定义的类继承了一个类(这个类可能是标准容器类，也可能是一个自定义类继承了标准容器类)

	- 出现了，在tensorrt的教程中，`nvinfer1::Weights conWeights {nvinfer1::DataType::kFLOAT, nullptr, size};`只能用花括号初始化，改用大括号()，ide提示报错，没有匹配的构造函数。难道用()是用的构造函数，而{}不是用的构造函数？

- {}是C++11及以后版本的初始化语法，称为统一初始化或列表初始化。它将成员变量按照花括号内的初始化顺序和方式进行初始化。如果没有提供初始值，那么对应的花括号内的成员就会用默认值进行初始化。

理解下面这个，就能明白大致明白这俩区别的，选哪种初始化都OK。

```c++
#include <iostream>
#include <string>
#include <vector>
#include <map>

class Demo {
public:
    Demo() { std::cout << "我是Demo类的无参构造函数" << std::endl; }
    Demo(int x, const std::string &y) : m_Age(x), m_Name(y) {std::cout << "我是Demo类的有参构造函数" << std::endl;}
    // 主要下面这个有参构造函数，用了std::initializer_list，就能接受比较多的参数
    Demo(std::initializer_list<std::pair<int, std::string> > initList) {
        std::cout << "已经在Demo的 std::initializer_list 的另一种有参构造函数中" << std::endl;
        for (std::pair<int, std::string> val : initList) {
            this->m_Age = val.first;
            this->m_Name = val.second;
        }
    }
    // 上面三个都是构造函数，下面这个是赋值运算符的重载
    Demo& operator=(const Demo &d) {std::cout << "我是Demo的=运算符重载" << std::endl;}

    int m_Age;
    std::string m_Name;
};

// 1、大括号初始化
void brace_init() {
    Demo d1(11, "aa");         // 走的简单的有参构造
    Demo d2 = Demo(22, "bb");  // 这依然是走的简单的有参构造
    Demo d3 = d2;              //  这样写，什么都不会打印
    d3 = d2;                   // 这样是运算符重载
    
    // 千万注意：要用无参构造，直接就是
    Demo d5;                   // 走的无参构造
    // 千万别写成了 Demo d5();  别想成python了。
    //  Demo d5() 这不是无参构造，而是一个函数声明 
}

// 2、花括号初始化
void breac_init2() {
    /*  讲一下花括号具体是按照什么规则去初始化（传了值的）
    1、首先查找有参构造函数有没有 std::initializer_list ，如果有，且能匹配上，那么就会优先匹配这个构造函数；
    2、如果条件1不成立，那么查看有没有其它有参构造函数有没有能匹配上的，如果有就选用这个；
    3、如果条件2不成立，看看是不是聚合类（聚合类在1c++基础中有介绍）,如果是的话，{}会触发聚合类初始化，
    	严格按照成员声明的顺序以此初始化。
    */
    
    Demo d1{11, "aa"};         // 简单的有参构造
    Demo d2 = Demo{22, "bb"};  // 依然走的是简单的有参构造函数
    Demo d2{};                 // 无参构造（花括号可以这样写，大括号千万不能，就成了函数声明而不是实例化对象）

    
    // 简单来说，上面的Demo类，把任何构造函数删了，且两个成员变量都是public的（这就是聚合类，跟结构体差不多了），就可以
    Demo d5{55, "cc"};  // 我一般喜欢这么写  Demo d5 = {55, "cc"};
    // 这就是结构体那种初始化，严格按照成员变量的声明顺序的

    // 顺带普及一个“宽窄转换问题”
    int a = 3.14;  
    int b = 1234567890111;
    std::cout << a << std::endl;  // 只会取整数
    std::cout << b << std::endl;  // 编译就会提醒，从 long long int 到int了，值成了1912276159

    int a1(10);
    int a2{10};    // 这都OK

    int a3(3.14);  // 这OK
    int a4{3.14};  // 这会直接报错，编译都过不了
}

int main(int argc, char* argv[]) {
    // {}还常用于值的初始化，下面这两种初始都是可以的，都是得益于 std::initializer_list
    std::vector<int> v1{1, 2, 3};
    std::vector<int> v2 = {1, 2, 3};

    std::map<int, std::string> m1{{0, "car"}, {1, "cpu"}};
    std::map<int, std::string> m2 = {{0, "car"}, {1, "cpu"}};
    return 0;
}
```

## 一、lambda表达式

### 1.1. lambda定义	

​	目前为止：使用过的仅有的良好总可调用对象是函数和函数指针，另外还有其他两种可调用对象：重载了函数调用运算符的类(应该就是仿函数),以及==lambda表达式==。

​	一个lambda表达式表示一个可调用的代码单元，可以将其理解为一个未命名的内联函数，一个lambda具有一个返回类型、一个参数列表和一个函数体，但与函数不同，lambda可能定义在函数内部。一个lambda表达式具有如下形式：

> [capture list]\(parameter list) -> return type {function body;}

- capture list：捕获列表，是一个lambda所在函数中定义的局部变量的列表（即当lambda定义在函数体内，要用函数体内的局部变量，就要把要用的局部变量放进这里，通常为空）；当然==lambda可以直接使用局部static变量和它所在函数之外声明的名字==，而无需使用捕获列表；

- parameter list：参数列表(是不能有默认参数的)；

- return type：返回类型；

- function body：函数体；

- 注意：lambda具体有两种写法，==一种==是单成一行赋值给一个对象，那么这种必须使用尾置返回来指定返回类型

  - ```c++
    auto func = [](int a, int b) {return a + b; };   // 1、2行是一样的，可以不要返回类型，然后通过return推断
    auto func = [](int a, int b) -> int {return a + b; };  // 尾置返回来指定返回类型(可能以后会搜索后置返回类型)
    // int func = [](int a, int b) -> int {return a + b; };  // 这就就是错的
    std::function<int(int, int)> func12 = [](int a, int b) {return a + b; };  // 这种也是OK的
    ```
  ```
    
  - 注意看上面代码，这前面只能写auto,不能写具体的数据类型，如第3行直接就是错的。
    
  - 这种也是定量定义在函数体内(至少在main函数中)，==capture list中的参数不要使用定义在main函数外的全局变量==，会直接报错的。
    
  - ==另外一种==是下面的示例，lambda直接写进std::for_each算法的参数位置当参数,for_each的是一个vector,vector中的元素是pair,那么(参数列表)里，给参数类型就要给pair，然后后面的操作就是对vector中的每一个元素,即pair进行操作。
  
    ```c++
    std::vector<std::pair<std::string, int>> vec = { 
    	{"zhangsan", 13}, {"lis", 14} };
    
    std::for_each(vec.begin(), vec.end(), 
    	[](std::pair<std::string, int> p) {std::cout << p.first << " : " << p.second << std::endl; }
    );
  ```

- 若是单成一行，最后结尾肯定要分号(就相当于日常每行完了有分号一样)，若是直接写在参数位置就不需要分号了。

`下面这个特别重要：` 
    我们==可以忽略参数列表和返回类型==，但==必须永远包含捕获列表和函数体==：
      auto f = [] {return 42;}
以上我们定义了一个可调用对象f，它不接受参数，返回42。
调用：std::cout << f() << std::endl;
在lambda中忽略括号和参数列表等价于指定一个空参数列表，上面的例子f的参数列表是空的，如果忽略返回类型，lambda根据函数体中的代码推断出返回类型。

​	这是书上的Note：如果lambda的函数体包含任何单一return语句之外的内容，且未指定返回类型，则返回void。

下面是一个实例使用(有带参数)：

```c++
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>   // std::find_if需要这个头文件
int main() {
	std::vector<std::string> vec{"over", "fox", "the", "quick", "red", "fox", "the", "turtle"};
	// 给定一个长度阈值
	std::vector<std::string>::size_type sz = 4;  
	// 获取一个迭代器，指向第一个满足size() > sz 的元素
	auto wc = std::find_if(vec.begin(), vec.end(),
         // 捕获列表[]里一定要有sz，lambda函数里才能用的
		//[sz](const std::string &a) -> bool {return a.size() > sz; } // 这两行一个效果
		[sz](const std::string &a) {return a.size() > sz; }   // 不要返回类型也是可以的
		);

	// 结合上面的wc，打印后面的单词，且每个后面接一个空格
	std::for_each(wc, vec.end(), 
		// 核心是这行，它是lambda参数，也是for_each算法的一个参数
		[](const std::string &s) {std::cout << s << " "; }
		);
	system("pause");
	return 0;
}
```

- 核心是13、19行，是直接把lambda函数写在算法传参的位置。

### 1.2. lambda捕获和返回

- ==值捕获==（就就函数的值传递，会进行拷贝，你改变原值也无所谓）

- ==引用捕获==（就是函数的引用传递，改变原值，会影响最终结果）

  ```c++
  int main() {
  	// 1.值捕获
  	int a = 2;
  	auto func1 = [a](int b) {return a + b; };
  	a = 10;
  	std::cout << func1(3) << std::endl;  // 5
  
  	// 2.引用捕获
  	int aa = 2;
      // 主要就是这里，传内部变量时要用引用
  	auto func2 = [&aa](int b) {return aa + b; };
  	aa = 10;
  	std::cout << func2(3) << std::endl;  // 13
  	return 0;
  }
  ```

  - ==[capture list]中的参数不要使用定义在main函数外的全局变量==，会直接报错的。
  - 当使用 ostream这种对象时，因为其是不能拷贝的，就要使用引用捕获(或指向其的指针)。
  - 书上建议：应该尽量减少捕获(值捕获)的数据量(即捕获列表尽量为空)，来避免潜在的捕获导致的问题，而且，如果可能的话，应该避免捕获指针或引用。

- ==隐式捕获== 

  即捕获列表[capture list]除了直接给定外，还可以让编译器根据lambda中的代码来推断使用了哪些变量，为了指示编译器推断捕获列表，应在捕获列表中写一个=====或==&==,其中=代表采用值捕获，&则代表采用引用捕获，那么上面的代码就可以写成：

  ```c++
  int main() {
  	// 1.值捕获
  	int a = 2;
      // 这里指定=(值捕获)，具体使用的参数a让编译器推断，
  	auto func1 = [=](int b) {return a + b; };
  	a = 10;
  	std::cout << func1(3) << std::endl;  // 5
  
  	// 2.引用捕获
  	int aa = 2;
      // 这里指定&(引用捕获)，具体使用的参数aa让编译器推断，
  	auto func2 = [&](int b) {return aa + b; };
  	aa = 10;
  	std::cout << func2(3) << std::endl;  // 13
  	return 0;
  }
  ```

- 对一部分值采用值捕获，对一部分值采用引用捕获，可以混合使用隐式捕获和显示捕获：

  ```c++
  auto wc = std::find_if(vec.begin(), vec.end(),
           // & 必须在前
  		[&, aa](const std::string &a) {return a + aa; }  
  	);
  auto wc = std::find_if(vec.begin(), vec.end(),
           // = 必须在前
  		[=, &aa](const std::string &a) {return a + aa; }  
  	);
  ```

  - 核心代码是第2行和第5行，代码含义不重要，现在是假定以上代码是在一个函数体内，然后aa也是函数体内的一个变量；
  - 当我们混合使用显式捕获和隐式捕获捕获时，==捕获列表的第一个元素必须是=或&==，此符号就指定了默认捕获方式为值或是引用：
    - 当前面默认指定&时，部分想用值捕获的参数就直接写在后面，逗号分隔，前面不用加引号；
    - 当前面默认指定=时，部分想用引用捕获的参数写在后面，且前面必须要有&符号指定。

### 1.3. 可变lambda

​	默认情况下，对于一个值被拷贝的变量(值捕获)，lambda不会改变其值，如果我们希望能改变一个被捕获的变量的值，就必须在参数列表首加上关键字==mutable==，如下：

```c++
int main() {
	// 1.值捕获
	int a = 2;
	// 这里用了关键字 mutable，里面让a进行了+1的操作
	auto func1 = [a](int b) mutable {return ++a + b; };
	a = 10;
	std::cout << func1(3) << std::endl;  // 6
	return 0;
}
```

- 默认lambda是不改变捕获列表里的变量的值，如果不加mutable，编译器会直接在++a报错说表达式必须是可修改的左值，加上mutable就可以修改了。

### 1.4. 指定lambda返回类型

​	lambda只包含单一的return语句时，可以不指定其返回类型，编译器会自动推断，但如果一个lambda体包含return之外的任何语句，则编译器都会假定此lambda返回void，与其它返回void的函数类型，被推断返回void的lambda不能返回值。
例子：使用标准库 transform 算法和一个lambda来讲一个序列中的每个负数替换为其绝对值：

```c++
std::transform(vec1.begin(), vec1.end(), vec2.begin(), [](int num) {return num < 0 ? -num : num;});
```

- 以上这个例子我们就无须指定lambda的返回类型，因为可以根据条件运算符的类型推断出来。

但是如果将程序改写成看起来等价的if语句，就会产生编译错误(下面这是错误的)：

```c++
std::transform(vec1.begin(), vec1.end(), vec2.begin(), [](int num) { if (num < 0) return -num; else return num; });
```

- 分析：编译器推断这个版本的lambda返回类型为void(上面写过原因了)，但它返回了一个int值。

修改：需要为lambda定义返回类型，且==必须使用尾置返回类型==(可能以后会搜索后置返回类型)：

```c++
std::transform(vec1.begin(), vec1.end(), vec2.begin(), [](int num) -> int { if (num < 0) return -num; else return num; });
```

---

一个有意思的例子(主要是看它的写法)：

​	编写一个 `lambda`，捕获一个局部 `int` 变量，并递减变量值，直至它变为0。一旦变量变为0，再调用`lambda`应该不再递减变量。`lambda`应该返回一个`bool`值，指出捕获的变量是否为0。

```c++
int main() {
	int a = 5;
	std::cout << !a << std::endl;  // 0

	auto func = [&a]() -> bool {return a == 0 ? true : !(a--); };
	while (!func()) {
		std::cout << a << std::endl;
	}
	return 0;
}
```

### 1.5. 参数绑定

​	在一些如 std::find_if 算法时，第三个参数一般是一元谓词，但是每个数据作为一个参数默认进到这个一元谓词中，那么一元谓词中的长度(比如长度3)是写死了的，这里就没办法修改大于的长度；然而在用lambda表达式时，因为捕获列表的存在，是可以传进不止一个参数的，可以动态的指定长度sz，但如果函数体比较复杂，会多次复用时，使用lambda表达式就会比较复杂。

​	参数绑定的意义：不使用lambda表达式也能传递给 std::find_if 这样算法的第三个参数(一元谓词)几个参数。

#### 1.5.1 标准库bind函数

​	这就是用来解决上述问题的，它是定义在头文件#include <functional\>中，它接受一个可调用对象，生成一个新的可调用对象来“适应”原对象的参数列表。

调用bind的一般形式如下：
	auto newCallable = std::bind(callable, arg_list);

- 其中，newCallable本身是一个可调用对象，arg_list是一个逗号分隔的参数列表，对应传给定的callable的参数
  即，当调用newCallable时，newCallable会调用callable，并传递给它arg_list中的参数；
- arg_list中的参数可能包含形如 \_n 的名字，其中 n 是一个整数，这些参数是“占位符”，表示newCallable的参数；他们占据了传递给newCallable的参数的“位置”，数值n表示生成的可调用对象中参数的位置：_
  - \_1 为newCallable的第一个参数，\_2为第二个参数，依次类推;
  - _n都是定义在一个名为 placeholders 的命名空间，而这个命名空间本身定义在std命名空间；直接一句 ==using namespace std::placeholders;==，那么这些\_n就可以直接使用了，与std::bind函数一样，placeholders命名空间也定义在#include \<functional> 头文件中。

```c++
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>   
#include <functional>  // std::bind 需要这个头文件
// 这才是一元谓词
bool compar(const std::string &s) {
	return s.size() > 3;
};
// 这里传递2个参数，不能直接用到 std::find_if中了
bool check_size(const std::string &s, int sz) {
	return s.size() > sz;
}
std::vector<std::string> vec{ "over", "fox", "the", "quick", "red", "fox", "the", "turtle" };

int main() {
	// 第一种：lambda表达式中的捕获列表，使得std::find_if的第三个参数位置(接收一元谓词)的地方可以传进两个参数
	int sz = 4;
	auto iter = std::find_if(vec.begin(), vec.end(), [sz](const std::string &a) { return a.size() > sz; });
	std::cout << *iter << std::endl;  // quick

	// 这里使用纯一元谓词，就会把长度sz写死成3
	auto iter_1 = std::find_if(vec.begin(), vec.end(), compar);
	std::cout << *iter_1 << std::endl;  //over

    
	// 第二种：不使用lambda表达式，那么就要使用参数绑定
	auto check_size_6 = std::bind(check_size, std::placeholders::_1, 5);
	/*
	此bind调用只有一个占位符，表示 check_size_6 只接受单一参数，占位符出现在arg_list的第1个位置，
	表示check_size_6的此参数对应 check_size 的第一个参数，此参数是一个const std::string&,
	因此调用 check_size_6会将此参数传递给 check_size 
	*/
	auto iter_2 = std::find_if(vec.begin(), vec.end(), check_size_6);
	std::cout << *iter_2 << std::endl;  // turtle

	auto iter_3= std::find_if(vec.begin(), vec.end(), std::bind(check_size, std::placeholders::_1, 5));
	std::cout << *iter_3 << std::endl;  // turtle

	return 0;
}
```

#### 1.5.2 bind的参数

​	可以用std::bind绑定给定可调用对象中的参数或重新安排其顺序，例如，假定func是一个可调用对象，它有5个参数，则下面对bind的调用：

​	// 假定 g 是一个有两个参数的可调用对象：
​	#include \<functional>    // 别忘了这个头文件
​	using namespace std::placeholders
​	auto g = std::bind(func, a, b, _2, c, _1);

那么我们在对g调用时 g(X, Y),那么它实际调用就会是 func(a, b, Y, c, X);

#### 1.5.3 绑定引用参数（ref函数）

​	默认情况下，std::bind的那些不是占位符的参数被拷贝到bind返回的可调用对象中，但是，与lambda类型，有时对有些绑定的参数我们希望以引用方式传递，或是要绑定的参数的类型是无法拷贝的(如输入输出流)；

例如，为了替换一个引用方式捕获ostream的lambda：

// os是一个局部变量，引用一个输出流；
// c是一个局部变量，类型为char

std::for_each(vec.begin(), vec.end(), [&os, c]\(const std::string &s) { os << s << c; });      // 第三个参数是lambda表达式

然后可以很容易的编写一个函数，完成相同的工作：

std::ostream &print(std::ostream &os, const std::string &s, char c) {
	return os << s << c;
}

但是不能直接用std::bind来代替对os的捕获：

// 下面这行是错的，原因：os是不能拷贝的
std::for_each(vec.begin(), vec.end(), std::bind(print, os, std::placeholders::_1, 'a'));  

- 详解：bind拷贝其参数，然而ostream是不能拷贝的，如果我们希望传递给bind一个对象，而又不拷贝它，就必须使用`标准库ref函数`：

std::for_each(vec.begin(), vec.end(), std::bind(print, std::ref(os), std::placeholders::_1, 'a'));    // 这是对的，核心是 ref(os)

- 函数ref返回一个对象，包含给定的引用，此对象是可以拷贝的，标准库中还有一个`cref函数`,生成一个保存const引用的类，

与bind一样，函数ref和cref也定义在头文件 #include \<functional>中。

---

一个向后兼容的：参数绑定

​	旧版本C++的绑定函数参数的语言特性显示更多，更复杂。标准库定义了两个分别名为bindlst和bind2nd的函数，类似bind，但是这些函数分别只能绑定第一个或第二个参数。
​	所以它们在新标准中已被弃用(deprecated),弃用的特性就是在新版本中不再被支持。

---

最终练习：统计长度小于4的单词的数量

```c++
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>   
#include <functional>  // std::bind  std::placeholders都需要这个头文件

bool little(const std::string &s) {
	return s.size() < 4;  // 4直接写死
}
bool my_bind(int n, const std::string &s) {
	return s.size() < n;
}

std::vector<std::string> vec{ "over", "fox", "the", "quick", "red", "fox", "the", "turtle" };

int main() {
	//  第一种：一元谓词，4直接写死
	auto num1 = std::count_if(vec.begin(), vec.end(), little);
	std::cout << num1 << std::endl;
	
    // 第二种：lambda表达式
	int sz = 4;
	auto num2 = std::count_if(vec.begin(), vec.end(), [sz](const std::string &s) -> bool { return s.size() < sz; });
	std::cout << num2 << std::endl;  // 这里lambda表达式可以不要返回类型(->bool)，编译器会自己推断，
	
    // 第三种：参数绑定
    // 注意这里参数写的顺序，要跟my_bind()函数顺序结合起来。且只用了std::placeholders::_1，当然也可以不另起一个对象名func，把表达式直接写进count_if的参数中
	auto func = std::bind(my_bind, 4, std::placeholders::_1); 
	auto num3 = std::count_if(vec.begin(), vec.end(), func);
	std::cout << num3 << std::endl;

	return 0;
}
```

## 二、动态内存与智能指针

### 2.1. 概念(重要)

- 静态内存：用来保存局部static对象、类static数据成员以及定义在任何函数之外的变量；
- 栈内存：用来保存定义在函数内的非static对象；
- 自由空间/堆：每个程序还有一个内存池，这部分内存被称作自由空间或堆，程序用堆 来存储==动态分配==的对象————即那些在程序运行时分配的对象。动态对象的生存期由自己程序来控制，也就是说，当动态对象不再使用时，我们的diamante必须显示地销魂它们。

注意：分配在静态或栈内存中的对象由编译器自动创建和销毁，对于栈对象，仅在其定义的程序块运行时才存在；static对象在使用之前分配，在程序结束时销毁。

---

有三种==智能指针==，都定义在`#include <memory>`头文件中：

- shared_ptr：允许对个指针指向同一个对象；
- unique_ptr：“独占”所指向的对象；
- weak_ptr：伴随类，它是一种弱引用，指向shared_ptr所管理的对象。

---

注意智能指针陷阱，所以坚持一些基本规范：

- 不使用相同的内置指针值初始化（或reset）多个智能指针；
- 不 delete get()返回的指针；
- 不使用get()初始化或reset另一个智能指针；
- 如果使用get()返回的指针，记住当最后一个对应的智能指针销毁后，你的指针就变为无效了；
- 如果使用指针指针管理的资源不是new分配的内存，记住传递给它一个删除器(不多写，如果有需要，在417页看看)。

---

尽量使用智能指针，使用new和delete管理动态内存常见的三个问题：

1. 忘记delete内存，忘记释放动态内存会导致人们常说的==内存泄露==问题，因为这种内存永远不可能被归还给自由空间了，一般等到真正耗尽内存时，才能检测到这种错误。
2. 使用已经释放掉的对象。
3. 同一块内存释放两次。

故：==坚持只使用智能指针==，就可避免这些问题。对于一块内存，只有在没有任何智能指针指向它的情况下，智能指针才会自动释放它。

---

==引用计数==：一旦一个shared_ptr的计数器变为0，它就会自动释放自己所管理的对象。

auto r = std::make_shared\<int>(42);   // r指向的int只有一个引用者
r = q;  // 给r赋值，令它指向另一个地址；会递增q指向的对象的引用计数；递减r原来指向的对象的引用计数；这里r原来指向的对象已没有引用者，会自动释放。

---

​	一个抛出错误的直接可用的代码：==throw std::out_of_range("this is a error");== 

​	传统的对象构造方式是使用圆括号，新标准下，也可以使用列表初始化(即使用花括号)，sting那里就有写到。

### 2.2. shared_ptr智能指针

shared_ptr和unique_ptr都支持的操作：

- p->成员函数/属性     解引用*p
- p.get()  // 返回p中所保存的指针，要小心使用，若智能指针释放了其对象，返回的指针所指向的对象也就消失了。
  - 书上也有一句，不要使用get来初始化另一个智能指针或是为智能指针赋值
  - 比如 void task(std::queue\<cv::Mat\> *que); 我们的指针是这个类型的智能指针p，那传递的时候就是 task(p.get()), 这主要是针对调用的函数不可修改的情况下，如果可以的话，尽量去改task函数的接收参数类型，将其改为智能指针的类型 
- swap(p,q)   // 交换p和q中的指针，也可以写作p.swap(q)

#### 2.2.1 定义及基本使用

​	定义：`std::shared_ptr<T> a_ptr;` （记得去[其它](#2.2.6 其它(也挺重要))里面看，有相关的也挺重要） // 与vector一样，指定数据类型；默认初始指针中保存着一个空指针，常用：

```c++
// p1不为空，检查它是否指向一个空string,
std::shared_ptr<std::string> p1;   // 这是空指针，一定要去初始化
if (p1 && p1->empty()) {  // 如果p1的类型是int这种，就是没有empty()成员函数的。
	*p1 = "hi";  // 如果解引用指向一个空string,解引用p1，将一个新值赋予string
}
// 学习PCL时学到的，这件去简单初始化一个对象，还是要new关键字，类型后面带了括号当做匿名对象，当然不带()也是可以的，不带括号也是用的默认无参构造函数。
pcl::PointCloud<pcl::PointXYZ>::Ptr cloud_in(new pcl::PointCloud<pcl::PointXYZ>());
// 上面的Ptr是using Ptr = shared_ptr<PointCloud<PointT> >;
```

shared_ptr独有的操作：

- std::make_shared\<T> (args);   // 返回一个shared_ptr，指向一个动态分配的类型为T的对象，并使用args初始化此对象。

  - 比如一个类，args就是实例化类时传递的参数。

  - ```c++
    // 这是Yolov5类的构造函数
    Yolov5::Yolov5(const std::string &weight_path, const std::string &labels_list_path, const std::string &output_dir);
    
    std::shared_ptr<Yolov5> m_Infer = std::make_shared<Yolov5>(./tools.pt, tools.txt, "output");  // ()里对应的就是传的参数
    ```

- std::shared_ptr\<T> p(q);   // p为shared_ptr指针q的拷贝，此操作会递增q中的计数器，q中的指针必须能转换为T* （这个T*在书4.11.2里有提及）

- p = q;  // p和q都是shared_ptr，所保存的指针必须能相互转换。此操作会递减p的引用计数，递增q的引用计数，若p的引用计数变为0，则将其管理的原内存释放。

- p.use_count()  // 返回与p共享对象的智能指针数量，可能很慢，主要用于调试。

- p.unique()   // p.use_count()为1，返回true，否则返回false。

  - 还有一个reset来将一个新的指针赋予一个shared_ptr：

    ```c++
    std::shared_ptr<int> p(new int(42));  // 引用计数为1
    // 重新赋值
    // p = new int(1024);   // 这是错误的，不能隐式转换，下面讲到了的
    p.reset(new int(1024));  // 正确：p指向一个新对象 
    ```

    reset会更新引用计数，reset成员经常与unique一起使用，来控制多了shared_ptr共享的对象。在改变底层对象之前，我们检查自己是否是与当前对象仅有的用户，如果不是，在改变之前要制作一份新的拷贝（这块不是很理解）：

    ```c++
    if (!p.unique())
    	p.reset(new std::string(*p));     // 我们不是唯一用户；分配新的拷贝
    *p += newVal;     // 现在我们知道自己是唯一的用户，可以改变对象的值。
    ```

注意：shared_ptr在引用计数变为0时，会销毁所管理的对象，还会自动释放相关联的内存；但如果将shared_ptr存放于一个容器中，而后不在需要全部元素，应确保使用erase删除那些不再需要的shared_ptr元素，不删没啥影响，就是会浪费内存。

#### 2.2.2 make_shared函数

​	最安全的分配和使用动态内存的方法是调用一个名为`make_shared`的标准库函数，也是定义在头文件`#include <memory>`中：

> - std::shared_ptr\<int> p1 = std::make_shared\<int>(42);
>   特别注意：这里==p1就是一个指针==了
>   std::shared_ptr\<std::queue\<cv::Mat>> que = std::make_shared\<std::queue\<cv::Mat>>();   // 很重要
>        \# 一定要这样去初始化这个指针，不然que只是一个空指针，一定要实例化。 
>   - std::shared_ptr\<std::queue\<cv::Mat>> que;    // 这样是一个空指针，都没实例化，不能直接拿去 que->push()的
>   - std::shared_ptr\<std::queue\<cv::Mat>> que{};  // 这样虽然实例化了，但还是个空指针，也不能直接拿去用的
> - std::shared_ptr\<std::string> p2 = std::make_shared\<std::string>(10, 'a');
> - std::shared_ptr\<int> p3 = std::make_shared\<int>();
>   // p3指向一个值初始化的int，即，值为0
> - auto p4 = std::make_shared\<std::vector\<std::string>>();
>   // p4指向一个动态分配的空vector\<string>

注意：new的动态分配一定要delete去释放，当然还是直接用智能指针方便

```c++
#include <memory>
// 1.普通new一个vector的指针
std::vector<int>* alloc_vector()
{
	return new std::vector<int>();
}
// 2.使用智能指针（注意这个函数的返回类型写法与return写法，两者好好看）
std::shared_ptr<std::vector<int>> delivery() {
	//return std::shared_ptr<std::vector<int>> ();  // 错的
	return std::make_shared<std::vector<int>>();  // 一定要用make_shared来创建
}
int main(int argc, char*argv[]) {
    auto p1 = alloc_vector();
    delete p1;         // 用完后一定手动回收
    /******************************************/
    std::shared_ptr<std::vector<int>> p2 = delivery();
    // 这个用完就不管，当引用计数为0时，会自动销毁对象并回收，就不怕忘记delete.
}
```

#### 2.2.3 内存泄露|定位new

经典内存泄露，如下：

```c++
int *q = new int(42), *r = new int(100);
r = q;
auto q2 = std::make_shared<int>(42), r2 = std::make_shared<int>(100);
r2 = q2;
```

​	解度：`r` 和 `q` 指向 42，==而之前 `r` 指向的 100 的内存空间并没有被释放==，因此会发生内存泄漏。`r2` 和 `q2` 都是智能指针，当对象空间不被引用的时候会自动释放。所以要用智能指针啊。

内存耗尽时的异常：

- int *p1 = new int;  // 如果内存耗尽，则会抛出std::bad_alloc的错误。
- int *p2 = new (std::nothrow) int;  // 如果分配失败，new返回一个空指针。
  称这种形式的new为==`定位new`==，new表达式允许我们向new传递额外的参数，这里是由标准库定义的名为nothrow的对象，将其传递给new，告诉其不能抛出异常

==bad_alloc==、==nothrow==都定义在头文件`#include <new>`中(vs中又是没导入也能用)

#### 2.2.4 delete后重置指针值

​	delete后，指针虽已无效，但在很多机器上指针任然保存着(已经释放了的)动态内存的地址，在delete后，指针就变成了==空悬指针==，即指向一块曾经保存数据对象但现在已经无效的内存的指针

​	未初始化指针的所有缺点(书2.3.2,49页)空悬指针也都有。有一种方法可以避免空悬指针的问题:在指针即将要离开其作用域之前释放掉它所关联的内存。这样，在指针关联的内存被释放掉之后，就没有机会继续使用指针了。如果我们需要保留指针，可以==在delete之后将nullptr赋予指针==，这样就清楚地指出指针不指向任何对象。

​	但这保护也只是有限的（如下，重置p对q没任何作用）：

```
int *p(new int(42));   // p指向动态内存
auto q = p;   // p和q指向相同的内存
delete p;     // p和q均变为无效
p = nullptr;  // 重置，指出p不再绑定到任何对象
```

#### 2.2.5 shared_ptr和new结合使用

如果不初始化一个智能指针，它就会被初始化为一个空指针，还可以用new返回的指针来初始化智能指针：

```c++
std::shared_ptr<double> p1;     // ok的
std::shared_ptr<int> p2(new int(1024));  // 正确：使用了直接初始化形式
std::shared_ptr<int> p3 = new int(1024);  // 错误的（一定注意这是错的）：必须使用直接初始化的形式  
```

解读：这是因为接收指针参数的智能指针构造函数是==explicit==的，因此，==不能将一个内置指针隐式转换成一个智能指针==，所以必须使用直接初始化形式。故：

```c++
std::shared_ptr<int> clone1(int p) { return new int(p); }  
// 错误，这也会隐式转换为std::shared_ptr<int>，然而就像上面讲的这是不被允许的
// 下面才是这个函数的正确方式
std::shared_ptr<int> clone2(int p) { return std::shared_ptr<int>(new int(p)); }
// 虽然这可以，但是还是要尽量用 std::make_shared<int>(p) 去初始化智能指针
```

但是书上讲了，==不要混合使用普通指针和智能指针==，操作会很危险(pdf中直接输入413页查看)；

​	简单来说，==智能指针和内置指针一起使用(应该是指如上内置指针赋予给智能指针)可能出现的问题，在表达式结束后，智能指针会被销毁，它所指向的对象也会释放，而此时内置指针依旧指向该内存空间(应该是因为内置指针始终是需要delete释放的)，那么之后对内置指针的操作可能会引发错误==。

​	下面就是错误的示例：

```c++
auto sp = std::make_shared<int>();
auto p = sp.get();
delete p;
```

​	智能指针 sp 所指向空间已经被释放，再对 sp 进行操作会出现错误。

#### 2.2.6 其它(也挺重要)

定义和改变std::shared_ptr的其它方法：

- std::shared_ptr\<T>p(q);     // p管理内置指针q所指向的对象；q必须指向new分配的内存，且能够转换为T*类型；

- std::shared_ptr\<T>p(u);     // p从unique_str u那里接管了对象的所有权，并将u置为空

- `std::shared_ptr<T>p(q, d);`   // p接管了==内置指针q==所指向的对象的所有权，q必须能转换为T*类型。p将使用可调用对象d(lambda对象或是函数对象这种吧)来代替delete，例如：

  ```c++
  // v是一个int的vector
  std::shared_ptr<int> p(new int[v.size()], [](int *p) {delete[] p; });
  ```

  很多时候使用new创建指针时，若出现异常，那么p指向的内容就不会被释放，就会造成内存泄露，一般常用的两种处理方式就是：一、使用智能指针；二、不使用指针，使用struct对象，将new的构建放到构造函数中，将delete操作放到析构函数中。

- std::shared_ptr\<T>p(p2, d);  // p是std::shared_ptr p2的拷贝(这就是和上一个的差异)，但和传拷贝的差异是这个p将用可调对象d来代替delete

- 若p是唯一指向其对象的 std::shared_ptr，，
  - p.reset();         // reset会释放此对象
  - p.reset(q);        // 若传递了可选的参数内置指针q，会令p指向q，否则会将p置为空
  - p.reset(q, d);     // 若还传递了参数d，将会调用d而不是delete来释放q。（d一般是函数、lambda等可调用对象，且默认会把q这个指针作为参数传递给d这可调用对象）

下面是一个示例，针对std::shared_ptr\<T>p(q, d);这种手动去写的一个可调用对象d,第32行：

```c++
#include <iostream>
#include <string>
#include <memory>
// 1.一个连接类
struct connection {
	std::string ip;
	int port;
	connection(std::string a_ip, int a_port) : ip(a_ip), port(a_port) {}
};
// 2.一个当做目标服务器的类
struct destination {
	std::string ip;
	int port;
	destination(std::string a_ip, int a_port) {
		ip = a_ip;
		port = a_port;
	}
};
// 3.连接函数
connection func_connect(destination *pDest) {
	std::shared_ptr<connection> pConn(new connection(pDest->ip, pDest->port));
	std::cout << "creating connection(" << pConn.use_count() << ")" << std::endl;
	return *pConn;
}
// 4.结束释放函数
void end_connection(connection *pConn) {
	std::cout << "connection close(" << pConn->ip << ":" << pConn->port << ")" << std::endl;
}
// 5.main函数中执行的函数
void f(destination &d) {
	connection conn = func_connect(&d);
	//std::shared_ptr<connection> p(&conn, end_connection);  // 注意这行;或者使用下面的lambda表达式，两行效果一样
	std::shared_ptr<connection> p(&conn, [](connection *a_con) {std::cout << "connection close(" << a_con->ip << ":" << a_con->port << ")" << std::endl; });  
	std::cout << "connecting now(" << p.use_count() << ")" << std::endl;
	// 注意这，当这行执行完了，p要智能释放了，才会去调用end_connection();打印出来就知道顺序了
}

int main(int argc, char*argv[]) {
	destination dest("192.168.108.147", 10086);
	f(dest);
	return 0;
}
```

解释：std::shared_ptr为什么没有==release==成员？

​	答：release成员的作用是放弃控制权并返回指针，因为在某一时刻只能有一个std::unique_ptr指向某个对象，unique_ptr不能被赋值，所以要用release成员将一个unique_ptr的指针的所有权传递给另外一个unique_ptr。而shared_ptr允许有多个shared_ptr指向同一个对象，因此不需要release成员。

### 2.3. unique_ptr智能指针

​	当定义一个unique_ptr时，需要将其绑定到一个new返回的指针上，类似于shared_ptr，初始化unique_ptr必须采用直接初始化形式：

- std::unique_ptr\<double> p1;       // 可以指向一个double的unique_ptr
- std::unique_ptr\<int> p2(new int(42));  // p2指向一个值为42的int
- 它也有前面类似于std::make_shared的创建指针的使用：
  auto sph2 = std::make_unique\<类型>(Vector3f(0.5, -0.5, -8), 1.5);


​    由于一个unqiue_ptr拥有它指向的对象，因此unique_ptr不支持普通拷贝或赋值操作(都是针对同为uniqie_ptr的)：

> std::unique_ptr\<std::string> p1(new std::string("hello"));
> std::unique_ptr\<std::string> p2(p1);   // 错误的，unique_ptr不支持拷贝
> std::unique_ptr\<std::string> p3;
> p3 = p1;  // 错误的，unique_ptr不支持赋值
>
> 像是这种就是ok的：
> int *pi2 = new int(2048);
> std::unique_ptr\<int> p(pi2);   // 但是可能会使得==pi2==成为空悬指针(应该是p释放了，pi2就空悬了)
>
> ---
>
> 虽然不能拷贝或赋值unique_ptr，但可通过调用release或reset将指针的所有权从一个(非const)ubique_ptr转移给另一个unique_ptr:
>
> 如将所有权从p1转移给p2：
> std::unique_ptr\<std::string> p1(new std::string("hello"));
> std::unique_ptr\<std::string> p2(p1.release())；   // release将p1置为空
>
> 将所有权从p3转移给p2：
> std::unique_ptr\<std::string> p3（new std::string("Trex"));
> p2.reset(p3.release());   // reset释放了p2原来指向的内存。
>
> 说明：
>
> - release成员返回unique_ptr当前保存的指针并将其置为空，因此，p2被初始化为p1原来保存的指针，而p1被置为空；
> - reset成员接收一个可选的指针参数，令unique_ptr重新指向给定的指针，如果unique_ptr不为空，它原来指向的对象被释放，因此：对p2调用reset释放了用“hello”初始化的string所使用的的内存，将p3对指针的所有权转移给p2，并将p3置为空。
> - 重要：调用release()会切断unique_ptr和它原来管理的对象间的练习，release返回的指针通常被用来初始化另一个智能指针或给另一个智能指针赋值，所以如果不用另一个智能指针来保存release返回的指针，就要手动负责资源的释放：
>   p2.release();   // 错误的，p2不会释放内存，而且会丢失了指针
>   autp p = p2.release();  // 正确，但必须记得delete(p);

下面是unqiue_ptr特有的操作：

- std::unique_ptr\<T> u1;   // 空unique_ptr，u1会使用delete来释放指针
  std::unique_ptr\<T, D> u2;  // 空unique_ptr，u2会使用一个类型为D的可调用对象来释放指针
- std::unique_ptr\<T, D> u(d);  // 空unique_ptr，用类型为D的对象d代替delete
- u = nullptr;    // 释放u指向的对象，将u置为空
- u.release();    // u放弃对指针的控制权，==返回指针==，并将u置为空(重要)
- u.reset();      // 释放u指向的对象
  u.reset(q);     // 如果提供了内置指针q，令u指向这个对象；否则将u置为空
  u.reset(nullptr);

注意：不能拷贝的unique_ptr的规则有一个例外，可以拷贝或赋值一个将要被销魂的unique_ptr，最常见的是从函数返回一个unique_ptr：

```c++
std::unique_ptr<int> my_clone(int p) {
	return std::unique_ptr<int>(new int(p));
}
```

还可以返回一个局部对象的拷贝：

```c++
std::unique_ptr<int> my_clone(int p) {
	std::unique_ptr<int> ret(new int(p));
	return ret;
}
```

这两段代码，编译器都知道要返回的对象将要被销毁，在此情况下，编译器执行一种特殊的“拷贝”，后续补充

​	还有一个向后兼容： 标准库较早版本包含了一个名为==std::auto_ptr==的类，它具有unique_ptr的部分特性，但不是全部，特别是，既不能在容器中保存auto_ptr，也不能从函数中返回auto_ptr，虽然auto_ptr仍是标准库的一部分，但是编写程序时应该使用unique_ptr。

### 2.4. weak_ptr智能指针

​	std::weak_ptr是一种不控制所指向对象生存周期的智能指针，它指向由一个 shared_ptr 管理的对象，将一个weak_ptr绑定到一个shared_ptr不会改变shared_ptr的引用计数。一旦最后一个指向对象的shared_ptr被销毁，对象就会释放，即便有weak_ptr指向该对象。特性：

> - std::weak_ptr\<T> w;          // 空weak_ptr可以指向类型为T的对象
> - std::weak_ptr\<T> w(sp);      // 与 shared_ptr sp指向相同对象的weak_ptr，T必须能转换为sp指向的类型   
> - w = p;    // p可以是一个shared_ptr或一个weak_ptr，赋值后w与p共享对象
> - w.reset();   // 将w置为空
> - w.use_count();  // 与w共享对象的shared_ptr的数量
> - w.expired();   // 若w.use_count()为0，返回true,否则返回false
> - w.lock();    //如果expire为true,返回一个空shared_ptr，否则返回一个指向w的对象的shared_ptr

当创建一个weak_ptr时，要用一个shared_ptr来初始化它：

```c++
auto p = std::make_shared<int>(42);
std::weak_ptr<int> wp(p);   // wp弱共享p，p的引用计数未改变
```

由于对象可能不存在，我们不能使用weak_ptr直接访问对象，而必须调用lock，此函数检查weak_ptr指向的对象是否仍存在，如果存在，lock返回一个指向共享对象的sahred_ptr，与任何其它shared_ptr类似，只要此shared_ptr存在，它所指向的底层对象也就会一直存在，例如：

```c++
if (std::shared_ptr<int> np = wp.lock()) {  // np不为空条件才成立
	// 在if中，np与p共享对象
}
```

### 2.5. 动态数组

​	了解一下，大多数应用应该使用标准库容器而不是动态分配的数组，使用容器更为简单，更不容易出现内存管理错误并且可能有更好的性能。

初始化动态分配对象的数组：

> - int *pia1 = new int[10];                    // 10个未初始化的int
> - int *pia2 = new int[10]\();                  // 10个初始值为0的int
> - std::string *psa = new std::string[10];      // 10个空string  
> - std::string *psa2 = new std::string[10]\();   // 10个空string  
>
> 新标准中还可以提供一个元素初始化器的花括号列表：
>
> - int *pia3 = new int[6] {0, 1, 2, 3, 4, 5};
> - std::string *p3 = new std::string[10] {"a", "an", "the", std::string(3, 'x')};

​	注意：如果初始化器数目小于元素数目，剩余元素将进行值初始化，如果初始化器数目大雨元素数目，则new表达式失败，不会分配任何内存，应该也会抛出一个类型为==bad_array_new_length==的异常，类似于==bad_alloc==，此类型定义在==头文件new中==。

---

动态数组删除：delete[] p3;

std::unique_ptr\<int[]> p(new int[10]);  // p指向一个包含10个未初始化int的数组
p.release();    // 自动调用delete[]销毁其指针

注意一点：==指向数组的unique_ptr不支持成员访问运算符(点和箭头运算符)，接着上面，访问p中的成员，只能是用p[i]这样的方式==。

与unique_ptr不同，shared_ptr不直接支持管理动态数组，如果要用，就==必须提供自定义的删除器==：
std::shared_ptr\<int> sp(new int[10], \[](int *p) {delete[] p;});
sp.reset();         // 使用自己提供的lambda释放数组，它使用delete[]

且shared_ptr不直接支持动态数组管理这一特性会影响数组中元素的访问：
// shared_ptr未定义下标运算符，并且不支持指针的算术运算
for (size_t i = 0; i != 10; ++i) {
	*(sp.get() + i) = i;      // 使用get获取一个内置指针

}

练习：连接两个字符串字面敞亮，将结果保存到一个动态分配的char数组中，以及重写此程序，连接两个标准库string对象：

```c++
const char *a = "hello ", *b = "world!";
std::cout << a << std::emdl;      // 会直接打印 hello
unsigned len = strlen(a) + strlen(b) + 1;
char *r = new char[len]();
strcat_s(r, len, a);
strcat_s(r, len, b);      // 注意这些个用法吧
std::cout << r << std::endl;

std::string str1 = "hello ", str2 = "nihao!";
strcpy_s(r, len, (str1 + str2).c_str());    // 注意这些个用法吧
std::cout << r << std::endl;

delete[] r;
```

#### allocator类

​	标准库==allocator==类定义在==头文件#include \<memory>==中，它主要将内存分配和对象构造分离开来，类似于vector,allocator是一个模板，为了定义一个allocator对象，必须指明这个allocator可以分配的对象类型，当一个allocator对象分配内存时，它会根据给定的对象类型来确定恰当的内存大小和对其位置：

std::allocator\<std::string> my_alloc;  // 可分配string的allocator对象
auto const p = my_alloc.allocate(5);   // 分配5个未初始化的string

标准库allocator类及其算法：

> - std::allocator\<T> a;   // 定义一个allocator对象
> - a.allocate(n);   // 分配一段原始的、未构造的内存，保存n个类型为T的对象
> - a.deallocate(p, n);   // 释放从T*指针p中地址开始的内存，p必须是一个先前由allocator返回的指针，且n必须是p创建时所要求的大小。在调用deallocate之前，用户必须对每个在这块内存中创建的对象调用destory
> - a.construct(p, args);   // p必须是一个类型为T*的指针，指向一块原始内存；arg被传递给类型为T的构造函数，用来在p指向的内存中构造一个对象
> - a.destory(p);   // p为T*类型的指针，此算法对p指向的对象执行析构函数

这个有些搞不明白了(接上面)：

```c++
auto q = p;
my_alloc.construct(q++);
my_alloc.construct(q++, 10, 'c');
my_alloc.construct(q++, "hi");
```

当用完对象后，必须对每个元素调用destory销毁，

```c++
while (q != p) {
	my_alloc.destory(--q);    // 释放真正构造的string
}
```

一旦元素被销毁后，可以重新使用这部分内存来保存其它string,也可将其归还给系统，释放内存通过调用deallocate来完成：my_alloc.deallocate(p, n); (传递给deallocate的指针不能为空，它必须指向由allocate分配的内存，n也必须与分配内存时提供的大小参数保持一样)。

---

拷贝和填充未初始化内存的算法：
	标准库还为allocator类定义了两个伴随算法，可以在未初始化内存中创建对象，他们也都==定义在头文件memory中==。

> - std::uninitialized_copy(v.begin(), v.end(), b2);  // 把迭代器输入范围内元素拷贝到迭代器b2孩子的那个的未构造的原始内存中
> - std::uninitialized_copy_n(v.begin(), n, b2);   // 从迭代器v开始拷贝n个元素到b2开始的内存中
> - std::uninitialized_fill(v.begin(), v.end(), t);  // 在迭代器v指定原始内存范围中创建对象，对象的值均为t的拷贝
> - std::uninitialized_fill_n(v.begin(), n, t);

​	假定有一个int的vector，希望将其内容拷贝到动态内存中，，那么先分配一块比vector中元素所占用空间大一倍的动态内存，然后将原vector中的元素拷贝到前一半空间，对后一半空间用一个定值进行填充：
auto p = my_alloc.allocate(v.size() * 2);
auto q = std::uninitialized_copy(v.begin(), v.end(), p);  // 通过拷贝v中的元素来构造从p开始的元素
std::uninitialized_fill_n(q, v.size(), 42);  // 将剩余元素初始化为42

## 三、拷贝控制

### 3.1. 更新三/五法则

​	更新三五法则：所有的五个拷贝控制成员应该看作一个整体：一般来说，如果一个类定义了任何一个拷贝操作，它就应该定义所有五个操作(我的理解是拷贝构造函数、拷贝赋值运算符函数(就是重载，operator=)、析构函数、移动构造函数、移动赋值运算符函数)，某些类则是必须定义前三个才能正确工作。

### 3.2. 拷贝、赋值与销毁

#### 3.2.1 拷贝构造函数

​	如果一个构造函数的第一个参数是自身类类型的引用，且==任何额外参数都有默认值==，则此构造函数是==拷贝构造函数==。当使用拷贝初始化时，我们会用到拷贝构造函数。

​	==拷贝构造函数的第一个参数必须是一个引用类型==(为什么必须是引用类型，理解不明白了，书442页)，Person(const int&); //拷贝构造函数，可以定义非const，但几乎总是一个const的引用，拷贝构造函数在几种情况下都会被隐式的使用，因此拷贝构造函数通常不应该是explicit的.

注意一下拷贝构造函数的写法：

```c++
class HasPtr {
	//HasPtr(const HasPtr &hp) : ps(hp.ps), age(hp.age) {}
    //  下面这个相比上面是动态分配一个新的string,注释是`*hp.ps`,要有*号，属性中ps是一个指针类型（拷贝构造函数）
	HasPtr(const HasPtr &hp) : ps(new std::string(*hp.ps)), age(hp.age) {}
   	HasPtr& operator=(const HasPtr &hp) {
		ps = hp.ps; age = hp.age;   // 拷贝赋值运算符
		return *this;
	}
private:
	std::string *ps;
	int age;
};
```

#### 3.2.2 =default

==std::swap可以直接交换两个数据==。

```c++
struct My_print {
	My_print() = default;   // 使用合成的默认构造函数，直接用 My_print(); 好像区别不大
    My_print(const My_print&) = default;  // 拷贝构造函数
    My_print& operator=(const My_print&);  // 拷贝赋值运算符
	~My_print() = default;
};
```

​	在C++11新标准中，如果我们需要默认行为，那么可以通过在参数列表后面写上`= default`来要求编译器生成构造函数，其中 = default 既可以和声明一起出现在类内部，也可以作为定义出现在类的外部。和其它函数一样，如果 = default 在类的内部，则默认构造函数是内联的，如果它在类外部，则该成员默认下不是内联。

​	class 和 struct定义类的唯一区别就是默认的访问权限，struct默认是public，而class默认是private。

#### 3.2.3 =delete

​	阻止拷贝：例如iostream类阻止了拷贝，在新标准下，可以通过将拷贝构造函数和拷贝赋值运算符定义为==删除的函数==来阻止拷贝。删除的函数是这样一种函数：虽然声明了它们，但不能以任何方式使用它们，在函数的参数列表后加上=delete来指出希望这个函数定义为删除的。就是禁用该构造函数

```c++
struct NoCopy {
	NoCopy() = default;   // 使用合成的默认构造函数
	NoCopy(const NoCopy&) = delete;  // 阻止拷贝
	NoCopy& operator=(const NoCopy&) = delete;  // 阻止赋值
    ~NoCopy() = default;   // 使用合成的析构函数   
};
```

​	与=default不同的是，=delete必须出现在函数第一次声明的时候，，=default直到编译器生成代码时才需要；另一点，可以对任何函数指定=delete,但是只能对编译器可以合成的默认构造函数或拷贝控制成员使用=default。

​	本质上，当不可能拷贝、赋值或销毁类的成员时，类的合成拷贝控制成员就会被定义为删除的。在新标准发布前，类是通过将其拷贝构造函数和拷贝赋值运算符声明为private的来组织拷贝，但现在如果想阻止拷贝，则还是应该使用=delete

---

还有一个注意点：==类内静态变量一定要类外实现==：

```c++
class Employee {
public:
	static int unique_id;
	//static int unique_id = 5;   // 这是错的
};
int Employee::unique_id = 5;   // 类内static变量必须类外初始化
```

### 3.3. 对象移动

​	比如自己写数组的扩容，就可以不是把已有元素拷贝到新地址，而是直接移动，就会大幅度提升性能(这种拷贝也是拷贝后会直接销毁原对象)；；还有一个原因：源于IO类或unique_ptr这样的类，都包含了不能被共享的资源(如指针或IO缓冲)，因此这些类型的对象不能拷贝但可以移动。

​	小知识：旧c++标准中，没有直接的方法移动对象，容器保存的类必须是可拷贝的。。但是在新标准中，可以用容器保存不可拷贝的类型，只要他们能被移动即可，标准容器、string和shared_ptr即支持移动也支持拷贝，IO类和unique_ptr类可以移动但不能拷贝。

#### 3.3.1 移动构造函数和std::move

​	如果自己实现类似于vector的扩容，都是会开辟一个新空间，再把数据拷贝进去。新标准库引入了2种机制，可以避免元素的拷贝。

- 一种：有一些标注库类，包括string，都定义了所谓的“移动构造函数”，可以假定string的一定构造函数进行了指针的拷贝，而不是为字符分配内存空间然后拷贝字符。
- 两种：名为std::move的标准库函数，它定义在`#include <utility>`头文件中，需要用std::move来表示希望使用string的移动构造函数，如果漏掉了move的调用，将会使用string的拷贝构造函数
- 在2c++核心编程.md 中的 5.0.3 有关于对std::move的我的理解
- 另外容器中，的\<algorithm>这头文件里也有 std::move，它是对容器的数据进行移动操作，类似于std::copy

#### 3.3.2 右值引用

​	新标准引入的，==通过`&&`来获得`右值引用`==,右值引用的一个重要的性质：只能绑定到一个将要销毁的对象；因此介意自由的将一个右值引用的资源“移动”到另一个对象中。

​	性质(很重要)：常规引用我们可以将其称之为`左值引用`：不能将其绑定到要求转换的表达式、字面常量或是返回右值的表达式；==右值引用==有着完全相反的绑定特性：可以将一个右值引用绑定到这类表达式上，但不能将一个右值引用直接绑定到一个左值上。如下：

> int i = 42; 
>
> - int &r = i;              // 正确：r引用i
> - int &&rr = i;            // 错误：不能将一个右值引用绑定到一个左值上
> - int &r2 = i * 42;        // 错误：i*42是一个右值
> - const int &r3 = i * 42;  // 正确：可以将一个const的引用绑定到一个右值上(注意这)
> - int &&rr2 = i * 42;      // 正确：将rr2绑定到乘法结果上(右值引用)
> - int &&r3 = i;           //  错误：表达式i是左值，不能右值引用

所以，可以将一个const的左值引用或一个右值引用绑定到得到右值的这类表达式上。

故左值持久，右值短暂，右值要么是字面常量，要么是在表达式求职过程中创建的临时对象

> - int &i = 42;     // 错误
> - const &r1 = 42;  // 正确
> - int &&r2 = 42;   // 正确  

由于右值引用智能绑定带临时对象，所以：

- 所引用的对象将要被销毁
- 该对象没有其它用户

这俩特性也意味着：使用右值引用的代码，可以自由的接管所引用的对象的资源。

int &&r3 = i;  //  错误：表达式i是左值，不能右值引用

​	虽然不能将一个右值引用直接绑定到一个左值上，但可以现实地将一个左值转换为对应的右值引用类型，通过调用一个名为`move`的新标准库函数来获得绑定到左值上的右值引用，此函数定义在头文件`#include <utility>`中
那么：int &&r3 = std::move(i);   // ok

​	调用move后就意味着：除对 i 赋值或销毁它外，将不再使用它，且为了避免潜在的名字冲突，尽量使用std::move，而不是move

练习：

```c++
int f();
vector<int> vi(100);
int &&r1 = f();
int &r2 = vi[0];    // 注意这个是左值引用
int &r3 = r1;
int &&r4 = vi[0] * f();
```

---

Tips：

- 在移动操作后，源对象必须保持有效的、可析构的状态，但是用户不能对其值进行任何假设，例如对一个标准库string或容器移动数据时，我们知道移后源对象任然有效，因此可以对它执行诸如empty或size这些操作，但是不知道将会得到什么结果，我们可能期望一个移后源对象是空的，但是这是没有保证的，所以尽量不去操作移后源对象。

- 合成的移动操作(如果自己没写，又用了，那么就叫是==合成==，如合成拷贝/移动构造函数、合成赋值运算符、合成析构函数。)：
      自己的类，即便不声明自己的拷贝构造函数或拷贝赋值运算符，编译器总会为我们合成这些操作(可直接使用)，拷贝操作要么被定义为逐成员拷贝，要么被定义为对象赋值，要么被定义为删除的函数。
      与拷贝操作不同，编译器根本不会为某些类合成移动操作，特别是，如果一个类定义了自己的拷贝构造函数、拷贝赋值运算符或者析构函数，编译器就不会为它合成移动构造函数和移动赋值运算符了。如果一个类没有移动操作，通常正常的函数匹配，类会使用对象的拷贝操作来代替移动操作。

- ==只有当一个类没有定义任何自己版本的拷贝控制成员，且类的每个非static数据成员都可以移动时，编译器才会为它合成移动构造函数或移动赋值运算符==：

  ```c++
  #include <utility>
  struct X {
  	int i;
  	std::string s;
  };
  struct hasX {
  	X men;
  };
  // 编译器会为X和hasX合成移动操作
  X x1, x2 = std::move(x1);
  hasX hx1, hx2 = std::move(hx1);
  ```

  ​	如果显式地要求编译器生成=default的移动操作，且编译器不能移动所有成员(好像有const的就不能移动吧)，则编译器就会将移动操作定义为删除的函数：

  ```c++
  // 假定 Y 是一个类，它定义了自己的拷贝构造函数但未定义自己的移动构造函数：
  struct hasY {
      hasY() = default;
      hasY(hasY &&) = default;
      Y men;   // hasY将有一个删除的移动构造函数
  };
  hasY hy1, hy2 = std::move(hy1);   // 错误：移动构造函数是删除的
  ```

#### 3.3.3 noexcept

移动操作、标准库和异常：

​	由于移动操作“窃取”资源，它通常不分配任何资源，因此移动操作通常不会抛出任何异常，当编写一个不抛出异常的移动操作时，应该将此事通知标准库。除非标准库知道我们的移动构造函数不会抛出异常，否则它会移动我们的类对象时可能会抛出异常，并为了处理这种可能性而做一些额外的工作。

​	一种通知标准库的方法是在构造函数中指明`noexcept`，这是新标准引入的，noexcept使我们承诺一个函数不抛出异常的一种方法，通常在一个函数的参数列表后指定noexcept；在一个构造函数中，noexcept出现在参数列表和初始化列表开始的冒号之间。

```c++
class strVec {
public:
	strVec(strVec&&) noexcept;   // 移动构造函数（这是定义） 
};
如果是类内列表初始化，那就是:  ` &&p) noexcept : age(p.age), name(p.name) {..}`
strVec::strVec(strVec&&) noexcept {   // （这是实现）
	/*实现的内容*/ 
}
strVec &strVec::operator=(strVec &&rhs) noexcept {  // 拷贝赋值运算符
    /*实现的内容*/
}
```

​	tips：不抛出异常的移动构造函数和移动赋值运算符都必须标记为noexcept，且头文件和实现文件中，都要指定noexcept

​	深入理解：首先标准库容器能对异常发生时自身行为提供保障，像vector,如果调用push_back时发生异常，vector自身不会改改变。==vector它就是除非知道元素类型的移动构造函数函数不会抛出异常，否则在重新分配内存的过程中，它就必须使用拷贝构造函数而不是移动构造函数==，使用拷贝即便出现异常，也会把原来的保留。如果希望vector重新分配内存时对我们自定义类型的对象进行移动而不是拷贝，就必须显示地告诉标准库我们的移动构造函数可以安全使用，这就是通过将移动构造函数(及移动赋值运算符)标记为noexcept来做到这一点。

#### 3.3.4 移动构造函数

- 好像只有一个 & 的是拷贝构造函数

- 然后有两个 && 的是移动构造函数

```c++
class strVec {
public:
	strVec(strVec&);     // 拷贝构造函数
	strVec(strVec&&) ;   // 移动构造函数  
};
```

==移动右值，拷贝左值==：
	如果一个类strVec既有移动构造函数，也有拷贝构造函数，编译器就会使用普通的函数匹配规则来确定使用那个构造函数，自己的类 strVec:

```
strVec v1, v2;
v1 = v2;     // v2是左值，使用拷贝赋值
strVec getVec(std::istream &);    // 返回的一个右值
v2 = getVec(std::cin);    // getVec(std::cin)是一个右值，使用移动赋值。
```

​	Tips：如果一个类有一个可用的拷贝构造函数而没有移动构造函数，又强行使移动时，其实是通过拷贝函数来实现“移动”的。拷贝赋值运算符和移动赋值运算符的情况类似。

重要：

​	一个成员函数同时提供拷贝和移动版本，它也能从中受益，例如定义了push_back的标准容器提供两个版本：一个版本是一个const左值引用，另一个版本是右值引用参数：

```
void push_back(const T&);  // 拷贝，
void push_back(T&&);       // 移动
```

​	对于第二个版本，只可以传递给它非const的右值，这样就是精确匹配(也是更好的匹配)的，所以当传递的是一个可修改的右值，编译器就会选择运行这个版本。

---

==移动迭代器==：

​	新标准库中定义了一种移动迭代器，，与其它迭代器不同，移动迭代器的解引用运算符生成一个右值引用，通过调用标准库的==std::make_move_iterator==，可能就是std::uninitialized_copy(std::make_move_iterator(vec.begin(), std::make_move_iterator(vec.end()), another_vec.begin());   // 可是这样

这样就是不是拷贝操作了，而是移动。

​	总之：由于一个移后源对象具有不确定的状态，对其调用std::move是危险的，通过在类代码中小心地使用move可以大幅度提升性能，但也容器出难以查找的错误，只有当进行的移动操作十分安全时，才可以使用std::move，就是要慎用。

#### 3.2.5 引用限定符

​	有时，右值的使用方式使人惊讶： s1 + s2 = "wow!";   // 我们对两个string的连接结果，一个右值进行了赋值，在旧标准中无法阻止这种使用方式，为了维持向后的兼容性，新标准库仍然允许向右值赋值，但我们可能希望在自己的类中阻止这种用法，就可以强制左侧运算对象(即this指向的对象)是一个左值。

​	方法是：在参数列表后放置一个`引用限定符`，==引用限定符可以是&(只能将它用于左值)和&&(只能将它用于右值)==,分别指出this可以指向一个左值或右值，==类似const限定符，引用限定符只能用于(非static)成员函数，且必须同时出现在函数的声明和定义中==。

```
class Foo {
public：
	Foo &operator=(const Foo &rhs) &;   // 只能向可修改的左值赋值
	Foo anotherFunc() const &;   // 若有const，引用限定符&必须在const之后
}；
```

示例:

```
Foo &retFoo();      // 返回一个引用；retFoo调用是一个左值
Foo retVal();       // 返回一个值，retVal调用是一个右值
Foo i, j;           // i和j是左值
i = j;             // 正确：i是左值
retFoo() = j;      // 正确：retFoo返回是一个左值
retVal() = j;      // 错误：retVal返回是一个右值
i = retVal();      // 正确：可以将一个右值作为赋值操作的右侧运算对象。
```

## 四、其它

### 4.1. c++中的可调用对象(函数指针、lambda表达式、bind创建的对象、匿名函数)

这还是比较重要有意义的。

​	c++中有几种可调用的对象：函数、函数指针、lambda表达式、==bind创建的对象==以及重载了函数调用运算符的类(匿名函数吧)（bind创建的对象使用可以看2c++核心编程.md中的4.6.7 标准库定义的函数对象中的最后一个练习）。

c++语言中，==函数表==用于存储指向这些可调用对象的“指针”，当程序需要执行某个特定的操作时，从表中查找该调用的函数。函数表很容易通过map来实现，运算符符号的string对象作为关键字，使用实现运算符的函数作为值：

```c++
int my_add(int i , int j) {return i + j;};  // 普通函数
// 注意下面的value的类型是`函数指针`，接收两个参数
std::map<std::string, int(*) (int, int)> a_map;  // 定义map
// 添加元素
a_map.insert({"+", my_add});    // {"+", add}是一个pair，定要注意
```

然后可以使用一个名为`function`的新的标准库类型，它也是定义在在`#include <functional>`头文件中

| function的操作                          |                                                              |
| --------------------------------------- | ------------------------------------------------------------ |
| std::function\<T> f;                    | f是一个对象，函数类型T(T是retType(args))                     |
| std::function\<T> f(nullptr);           | 显示地构造一个空function                                     |
| std::function\<T> f(obj);               | 在f中存储可调用对象obj的副本                                 |
| f                                       | 将f作为条件:当f中有一个可调用对象时为真，否则为假            |
| f(args);                                | 调用f中的对象，参数是args                                    |
| ==定义为std::function\<T>的成员的类型== |                                                              |
| result_type                             | 该function类型的可调用对象返回的类型                         |
| argument_type                           | 当T有一个或两个实参时定义的类型。如果T只有一个实参，<br />则argument_type是该类型的同义词； |
| first_argument_type                     | 如果T有两个实参，则first_argument_type和                     |
| seconde_argument_type                   | second_argument_type分别代表两个实参的类型                   |

简单使用：

​	简单来说，这种场景是不是比如“my_add”函数不在这个cpp文件里，而是把my_add函数的参数类型、返回类型通过std::function写进这个cpp的参数里，后面调用时，直接传入这个函数，比如[这里](https://github.com/godotengine/godot/blob/11d3768132582d192b8464769f26b493ae822321/core/extension/gdextension.cpp#L49)。

```c++
#include <functional>
int my_add(int i, int j) { return i + j; };  // 普通函数

struct my_divide {
	int operator() (int deno, int divi) {
		return deno / divi;
	}
};
int main(int argc, char** argv) {
    
	std::function<int (int, int)> f1 = my_add;   // 函数指针
	std::function<int (int, int)> f2 = my_divide();  // 函数对象类的对象(匿名函数)
	std::function<int (int, int)> f3 = [](int i, int j) {return i * j; };  // lambda
	std::cout << f1(4, 2) << std::endl;  // 6
	std::cout << f2(6, 2) << std::endl;  // 3
	std::cout << f3(4, 2) << std::endl;  // 8
} 
```

那么使用这个function类型就可以重新定义map：

```c++
#include <map>
#include <functional>

int my_add(int i, int j) { return i + j; };  // 普通函数
struct my_divide {
	int operator() (int deno, int divi) {
		return deno / divi;
	}
};
auto my_mod = [](int deno, int div) {return deno % div; };
int main(int argc, char*argv[]) {
    // 这里有两种写法，使用function包装或是函数指针，前面4.1也写到了
    std::map<std::string, int(*) (int, int)> a_map；  // 跟下面std::function完全一样的
	// 这里面插入的都是pair对组数据类型，还可以有别的写法（尽量用std::function写法，插入对象用lmbda写时可以用引用捕获参数，用纯函数指针就不行）
	std::map<std::string, std::function<int(int, int)>> a_map = {
		{"+", my_add},    // 函数指针
		{"-", std::minus<int>()},    // 标准库函数对象
		{"/", my_divide()},         // 我定义的函数对象(匿名对象)（又叫仿函数）
		{"*", [](int i, int j) {return i * j; }},   // 未命名的lambda
		{"%", my_mod}               // 命名了的lambda对象
	};
	std::cout << a_map["+"](10, 5) << std::endl;  // 15
	std::cout << a_map["%"](10, 5) << std::endl;  // 0
	return 0;
}
```

Tips：新版标准库中的 function 类与旧版本中的unary_function和binary_function没有关联，后两个类已经被更通用的bind函数替代了。

- 注：函数指针跟std::function更细节的对比

  ```c++
  int x = 2;
  int y = 3;
  // 下面函数返回的都是int类型，
  // ok的，比起上面不再传参，
  std::map<std::string, std::function<int()>> a_map = {
  	{"*", [&]() {return x * y; }},
  };
  
  // 错误的，这里用函数指针，想不传参，直接都是编译不通过的
  std::map<std::string, int(*) ()> b_map = {
  	{"*", [&]() {return x * y; }},
  };
  
  std::cout << a_map["*"]() << std::endl;
  ```

  再注：

  ```c++
  // 但，注：如果是返回的智能指针 std::shared_ptr<int>类型，这种引用捕获还是出错，要写成：
  std::map<std::string, std::function<std::shared_ptr<int>(int, int)>> a_map = {
  	{"*", [](int i, int j) {return std::make_shared<int>(i, j); }},    // 这代码是错了，只是为了说明，
  };
  ```

  

### 4.2. 正则表达式

​	C++正则表达式库(RE库)，它是新标准库的一部分，RE库定义在头文件`#include <regex>`中，它包好多个组件库，如下表所示：

| 正则表达式库组件     | （有的是类，有的是function，写到的时候注意看提示）           |
| -------------------- | ------------------------------------------------------------ |
| std::regex           | 表示有一个正则表达式的==类==                                 |
| std::regex_match     | 将一个字符序列与一个正则表达式匹配                           |
| std::regex_search    | 寻找第一个与正则表达式匹配的子序列                           |
| std::regex_replace   | 使用给定格式替换一个正则表达式                               |
| std::sregex_iterator | 迭代器适配器，调用regex_search来遍历一个string中所有匹配的子串 |
| std::smatch          | 容器==类==，保存在string中搜索的结果                         |
| std::ssub_match      | string中匹配的子表达式的结果，==类==                         |

​	例如函数regex_match和regex_search确定一个给定字符序列与一个给定regex是否匹配，如果整个输入序列与表达式匹配，则regex_match函数返回true，如果输入序列中一个子串与表达式匹配，则regex_search函数返回true。

​	下表列出了regex的函数的参数，都是返回bool值，且都被重载了：其中一个版本接收一个类型为==smatch==的附加参数，如果匹配成功，这些函数将成功匹配相关信息保存在给定的smatch对象中。

> regex_search和regex_match的参数：（这些操作会返回bool值，指出是否找到匹配）
>
> (seq, m, r, mft)
>
> (seq, r, mft)        // 相当于两个版本

​	解读：在字符序列seq中查找regex对象r中的正则表达式。seq可以是一个string，表示范围的一对迭代器以及一个指向空字符结尾的字符数组的指针；m是一个==match对象==，用来保存匹配结果的相关细节，m和seq必须具有兼容的类型；mft是一个可选的regex_constants::match_flag_type值，下表描述了这些值，它们会影响匹配过程。

#### 4.2.1 使用正则表达式库

==Demo_1==：查找违反众所周知的拼写规则：“i除非在c之后，否则必须在e之前”的单词：（相当重要）

```c++
#include <regex>       // 注意这个头文件
int main(int argc, char*argv[]) {
	std::string pattern("[^c]ei");  
	pattern = "[[:alpha:]]*" + pattern + "[[:alpha:]]*";  // alpha就一个冒号
	std::regex r(pattern);
	
	std::smatch results;
	std::string test_str = "receipt freind theif receive";

	if (std::regex_search(test_str, results, r)) {
		std::cout << results.str() << std::endl;
	}
	return 0;
}
```

解读：

- 第3行：\[^c]表示匹配任意不是c的字符，这里就是找任意不是c的字符后跟着ei的字符串(共3个字符)；
- 第4行：要匹配整个单词，regex使用的正则表达式语言是==ECMAScript==,在这里，模式==[[::alpha:]]==匹配任意字母，符号==+==和==*==分别表示希望“一个或多个”或“零个或多个”匹配，因此==[[::alpha:]]*==将匹配零个或多个字母；
- 正则表达式存入字符串pattern后，用它来初始化一个名为r的regex对象；
- 再定义了一个名为results的==smatch==对象，它将传递给regex_search，如果找到匹配子串，results将会保存匹配位置的细节信息；
- 定义的test_str中，与模式匹配的单词(“freind”和“ theif”)和不匹配的单词(“receipt”和“receive”)；
- 最后调用==std::regex_search==,找到匹配子串，就返回true，用results的==str()成员==来打印test_str中与模式匹配的部分；且==此函数在输入序列中只要找到一个匹配子串就会停止查找==，故输出的会是freind，后面的就不管了。若要全部打印，就要看下面的[4.2.4小节](#4.2.4 匹配与Regex迭代器类型)。

补充：下面是指定regex对象的选项(参考上面看)：

- std::regex r(re);

- std::regex r(re, f);

- r1 = re;

- r1.assign(re, f);      // 就是各种方式创建regex对象

- r.mark_count()           r中子表达式的数目

- r.flags()         返回r的标志集

  ​						下表是定义regex时指定的标志：

| 定义在regex和regex_constants::syntax_option_type中 |                               |
| -------------------------------------------------- | ----------------------------- |
| icase                                              | 在匹配过程中忽略大小写        |
| nosubs                                             | 不保存匹配的子表达式          |
| optimize                                           | 执行速度优于构造速速          |
| ECMAScript                                         | 使用ECMA-262指定的语法        |
| basic                                              | 使用POSIX基本的正则表达式语法 |
| extended                                           | 使用POSIX扩展的正则表达式语法 |
| awk                                                | 使用POSIX版本的awk语言的语法  |
| grep                                               | 使用POSIX版本的grep的语法     |
| egrep                                              | 使用POSIX版本的egrep的语法    |

​	这最后6个标志指出编写正则表达式所用的语言，必须且只能设置其中一个，默认ECMAScript标志被设置，从而regex会使用ECMA-262规范，这也是很多Web浏览器所使用的正则表达式语言。

==Demo_2==：编写一个正则表达式来识别“==一个或多个字母或数字字符后接一个‘.’再接‘cpp’或‘cxx’或‘cc==’，且==不区分大小写==”：（重要）

```c++
#include <regex>
int main(int argc, char*argv[]) {
    // 下面一定要注意，[[]]不要少了任意半边，不然编译不会出错，运行出错很难找到
	std::regex r("[[:alnum:]]+\\.(cpp|cxx|cc)$", std::regex::icase);
	std::smatch results;
	std::string filename;
	while (std::cin >> filename) {
		if (std::regex_search(filename, results, r)) {
			std::cout << results.str() << std::endl;
		}
	}
	return 0;
}
```

解读：

- 正则表达式中有特殊字符，字符点(.)通常匹配任意字符，与c++一样，在字符前放置一个反斜线来转义，由于反斜线在c++中也是一个特殊字符，所以还需要加一个反斜线，所以想要一个普通的点==.==，如上的写法就是`\\.` 

#### 4.2.2 指定或使用正则表达式时的错误

​	正则表达式是在运行时，当一个regex对象被初始化或赋予一个新模式时，才被“编译”的(这不是由c++编译器解释的)，所以一个正则表达式的语法是否正确是在运行时解析的。

​	如果编写的正则表达式存在错误，则在运行时标准库会抛出一个类型为regex_error的异常。类似于标准异常类型，regex_error有一个==what()成员==操作来描述发生了什么错误。regex_error还有一个名为==code()的成员==，用来返回某个错误类型对应的数值编码，code返回的值是由其具体实现定义的。RE库能抛出的标准错误如下表：

| 正则表达式错误类型 | 定义在regex和regex_constants::error_type中   |
| ------------------ | -------------------------------------------- |
| error_collate      | 无效的元素校对请求                           |
| error_ctype        | 无效的字符类                                 |
| error_escape       | 无效的转义字符或无效的尾置转义               |
| error_backref      | 无效的向后引用                               |
| error_brack        | 不匹配的方括号 [或]                          |
| error_paren        | 不匹配的小括号 (或)                          |
| error_brace        | 不匹配的花括号 {或}                          |
| error_badbrace     | {}中无效的范围                               |
| error_range        | 无效的字符范围 (如[z-a])                     |
| error_space        | 内存不足，无法处理此正则表达式               |
| error_badrepeat    | 重复字符(*、?、+或{)之前没有有效的正则表达式 |
| error_complexity   | 要求的匹配过于复杂                           |
| error_stack        | 栈空间不足，无法处理匹配                     |

​	总之为了减小开销，应避免创建很多不必要的regex，特别是在一个循环中使用正则表达式时，应在循环外创建它，而不是每步迭代时都编译它。

==特别重要==：以后写正则表达式都这样来捕获错误，不然很难发觉哪里写错了：

```c++
#include <regex>
try {   // 下面少了一个]，正确应该是 [[:alnum:]]
	std::regex r("[[:alnum:]+\\.(cpp|cxx|cc)$", std::regex::icase);
}
catch (std::regex_error e) {
	std::cout << e.what() << "\ncode：" << e.code() << std::endl;
}
```

把这段代码放进main函数中运行，就得得到这样的输出：

> regex_error(error_brack): The expression contained mismatched [ and ].
> code：4

这样就比较明确是哪里出错了，就比较方便查找。

#### 4.2.3 正则表达式类和输入序列类型

​	输入可以是普通char数据或wchar_t数据，字符可以保存在标准库string中或是char数组中(或是宽字符版本，wstring或wchar_t数组中)。RE库为这些不同的输入序列都定义了对应的类型。

​	例如：regex类保存类型char的正则表达式。标准库还定义了一个wregex类保存类型wchar_t，其操作与regex完全相同，唯一差别是wregex的初始值必须使用wchar_t而不是char。

​	匹配和迭代器类型(下小节就会写到)更为特殊，这些类型的差异不仅在于字符类型，还在于序列是在标准库string中还是数组中：smatch表示string类型的输入序列；cmatch表示字符数组序列；wsmatch表示宽字符串(wstring)输入；而wcmatch表示宽字符数组。

demo：

```c++
std::regex r("[[:alnum:]+\\.(cpp|cxx|cc)$", std::regex::icase);
std::smatch results;  // 将匹配string输入序列，而不是char*
if (std::regex_search("myfile.cc", results, r))  {/**/}   // 错误的：输入为char* 
```

​	所以以上代码会编译失败，因为match参数的类型与输入序列的类型不匹配，如果我们希望搜索一个字符数组，就必须使用cmatch对象：

```c++
std::cmatch results;           // 注意这里的区别
if (std::regex_search("myfile.cc", results, r))  {/**/}  // 正确的
```

下表为==正则表达式库类==：

| 如果输入序列类型 | 则使用正则表达式类                             |
| ---------------- | ---------------------------------------------- |
| string           | regex、smatch、ssub_match和sregex_iterator     |
| const char*      | regex、cmatch、csub_match和cregex_iterator     |
| wstring          | wregex、wsmatch、wssub_match和wsregex_iterator |
| const wchar_t*   | wregex、wcmatch、wcsub_match和wcregex_iterator |

#### 4.2.4 匹配与Regex迭代器类型

​	上面4.2.1最开始那个例子只能打印出来匹配到的第一个，没办法打印后续，那就需要用到sregex_iterator来获得所有匹配，这些操作也适用于cregex_iterator、wsregex_iterator和wcregex_iterator:

​	std::sregex_iterator it(b, e, r);  // 一个sregex_iterator，编译迭代器b和e表示的string，它调用sregex_search(b, e, r)将it定位到输入中第一个匹配的位置

```c++
#include <regex>       // 注意这个头文件
int main(int argc, char*argv[]) {
	std::string pattern("[^c]ei");
	pattern = "[[:alpha:]]*" + pattern + "[[:alpha:]]*";
    // 以上两行可以换成下面这个通用的那种正则表达式，效果一样的
    // std::string pattern("(\\w*)[^c]ei(\\w*)");  // 里面加小括号只是方便看
    
	std::regex r(pattern);

	std::smatch results;
	std::string test_str = "receipt freind theif receive";
	// 注意核心是下面这行：
	for (std::sregex_iterator it(test_str.begin(), test_str.end(), r), end_it; it != end_it; ++it) {
		std::cout << it->str() << std::endl;
	}
	return 0;
}
```

解读：

- 这里就会打印满足条件的 freind 和 theif；
- for语句中初始值定义了it和end_it，当定义it时，sregex_iterator的构造函数调用regex_search将it定位到test_str中第一个与r匹配的位置；而end_it是一个空sregex_iterator，起到尾后迭代器的作用(就理解为最后一个元素后一个位置，就像一个序列的.end());
- for语句中的递增运算通过regex_search来“推进”迭代器，当解引用迭代器时，会得到一个表示当前匹配结果的smatch对象，调用它的str()成员来打印匹配的单词。

==使用匹配数据==：
	匹配类型有两个名为==prefix()==和==suffix()==的成员，分别返回表示输入序列中当前匹配之前和之后部分的ssub_match对象，一个ssub_match对象有两个名为str和length的成员，分别返回匹配的string和该string的大小。接着上面的代码，就是把里面循环丰富了：

```c++
for (std::sregex_iterator it(test_str.begin(), test_str.end(), r), end_it; it != end_it; ++it) {
	auto pos = it->prefix().length();   // 前缀的大小
	pos = pos > 40 ? pos - 40 : 0;      // 想要最多40个字符
	std::cout << it->prefix().str().substr(pos)   // 前缀的最后一部分
		<< "\n\t\t>>>" << it->str() << " <<<\n"   // 匹配的单词
		<< it->suffix().str().substr(0, 40) << std::endl;  // 后缀的第一部分
}
```

​	下表就是smatch对象操作：(这些操作也适用于cmatch、wsmatch、wcmatch和对应的csub_match、wssub_match、wcsub_match)

| smatch操作           | (下面m就是它的一个对象，自己理解的)                          |
| -------------------- | ------------------------------------------------------------ |
| m.ready()            | 如果已经通过调用regex_search或regex_match设置了m，则返回true。<br/>如果ready()返回false，则对m进行操作是未定义的 |
| m.size()             | 如果匹配失败，则返回0；否则返回最近一次匹配的正则表达式中子表达式的数目 |
| m.empty()            | 若m.size()为0，则返回true                                    |
| m.prefix()           | 一个ssub_match对象，表示当前匹配之前的序列                   |
| m.suffix()           | 一个ssub_match对象，表示当前匹配之后的部分                   |
| m.format(...)        | 下面会讲，看书这部分吧                                       |
| m.length(n)          | 第n个匹配的子表达式的大小                                    |
| m.position(n)        | 第n和子表达式距序列开始的距离                                |
| m.str(n)             | 第n个子表达式的string（如果不匹配，m.str()是会返空的）       |
| m[n]                 | 对应第n个子表达式的ssub_match对象                            |
| m.begin(), m.end()   | 表示m中sub_match元素范围的迭代器                             |
| m.cbegin(), m.cend() |                                                              |

​	根据上面的经验，n似乎不是必须的，一般都不要，除非特别指定第n个时才给这个参数吧（n一定要看子表达式里的demo）。

#### 4.2.5 使用子表达式

正则表达式中国的模式通常包含一个或多个==子表达式==，正则表达式语法通常==用括号表示子表达式==：

// 下面r有两个子表达式：第一个是点之前表示文件名的部分，第二个表示文件扩展名
std::regex r("([[:alnum:]]+)\\\\.(cpp|cxx|cc)$", std::regex::icase);

那么先的模式包含两个括号括起来的子表达式：

- ([[:alnum:]]+)       // 匹配一个或多个字符的序列
- (cpp|cxx|cc)         // 匹配文件扩展名

```c++
#include <regex>
int main(int argc, char*argv[]) {
	// 注意这与上面的区别，这里的  [[:alnum:]]+ 用了一个括号括起来，作为子表达式，+号也一定要被括进去
	std::regex r("([[:alnum:]]+)\\.(cpp|cxx|cc)$", std::regex::icase);
	std::smatch results;
	std::string filename;
	while (std::cin >> filename) {
		// 假定输入一个 foo.cpp
		if (std::regex_search(filename, results, r)) {
			std::cout << results.str() << std::endl;       // foo.cpp
			std::cout << results.str(0) << std::endl;      // foo.cpp
			std::cout << results.str(1) << std::endl;      // foo
			std::cout << results.str(2) << std::endl;      // cpp
		}
	}
	return 0;
}
```

Tips：

- 子表达式一定要用()括起来，没有的话结果就不是所想的；还要注意那个+号的位置，它也特别重要，它位置错了，结果也会变的。
- 位置[0]的元素表示整个匹配；元素[1]...[n]表示每个对应的子表达式。

然后有一个子表达式验证电话号码的demo就不写了，挺复杂的，用到时看书左上角标的654页。

#### 4.2.6 使用regex_replace

直接上例子：

```c++
std::string fmt = "$2.$5.$7";
std::string phone = "(\\()?(\\d{3})(\\))?([-. ])?(\\d{3})([-. ]?)(\\d{4})";
std::regex r(phone);

std::string number = "(908) 555-1800";
std::cout << std::regex_replace(number, r, fmt) << std::endl;  
```

解读：

- 第1行：用一个符号$后跟子表达式的索引号来表示一个特定的子表达式（这里就是希望在替换字符串中使用第2个、第5个、第7个子表达式，而忽略第一个、第三个、第四个、第六个子表达式）；这里就是想将号码改成ddd.ddd.dddd的样式；
  因为结果是想要==.==来连接，所以这里用的点，如果是想要ddd-ddd-dddd，那就是`"$2-$5-$7"` 
- 第2行，phone子表达式的解读：(ECMAScript正则表达式语言特性看书654页)
  - (\\\\()?        // 表示区号部分可选的左括号
  - (\\\\d{3})      // 表示区号
  - (\\\\))?        // 表示区号部分可选的右括号
  - ([-. ])?      // 表示区号部分可选的分隔符
  - (\\\\d{3})      // 表示号码的下三位数字
  - ([-. ])?      // 表示可选的分隔符
  - (\\\\d{4})      // 表示号码的最后四位数字 
- 最后会得到输出结果：908.555.1800

​	用来控制匹配和格式的标志，其类型为match_flag_type,这些值都定义在名为regex_constants的命名空间中，一般的例子：std::regex_constants::format_no_copy  还有一些其它的标志在书上，不写了，用到时去看吧。

### 4.3. 随机数

#### 生成随机数技巧

> 小技巧：c++中生成随机小数的技巧
>
> - float score = std::rand() % 10 + 1;  // 这只会得到 7.0这样的数据，它相当于只是把一个随机整数强转成了float
> - float score = (float)(std::rand() % 41 + 60) / 10.0f;     // 8.6
>   -  // 前面整型生成的是0\~40的整数，+60就是60~100的整数，记得先转成float，再除以浮点型的10.0f得到的就是 6.5、7.6、9.1这样的小数，记得分子分母都得是浮点型，不然精度要丢失
> - float score = (float)(std::rand() % 401 + 600) / 100.0f;     // 8.65
>   - 这就是要两位小数的话，都先放大100倍，再除以100倍，得到的就是6.53、7.62、9.19这样的小数了

```c++
// 设了随时间的随机种子，每次才不一样；(使用随机数时都加上这个)
#include <ctime>  //记得头文件 
std::srand((unsigned int)time(NULL));  // 这对下面c++的方式并不起作用
```

---

​	新标准之前，C和C++都依赖于一个简单的C库函数==rand==来生成随机数，此函数生成均匀分布的伪随机整数，范围在0和一个系统相关的最大值(至少为32767(定义的宏“RAND_MAX”，十六进制为0x7fff))之间。

​	定义在头文件`#include <random>`中的随机数库通过一组协作的类来解决生成随机浮点数、非均匀分布的数的问题：下面是随机数库的组成

- ==随机数引擎类==      类型（==default_random_engine==） ，生成随机unsigned整数序列
- ==随机数分布类==      类型，使用引擎返回服从特定概率分布的随机数

​	Note：C++程序不应该使用库函数rand，而应使用==default_random_engine==类(生成的是==无符号随机整数==，调用这个对象的输出就是类似C库函数rand的输出)和恰当的分布类对象。

```c++
#include <random>        // 注意一定要这个头文件
int main(int argc, char*argv[]) {
     // 然后头文件这种，一定要std::开头
	std::default_random_engine e;       // 默认构造函数，使用该引擎的默认种子
    // std::default_random_engine e(5);    // 也可以给个种子
    e.seed(6);              // 也可以这样重置引擎的状态
	for (size_t i = 0; i < 10; ++i) {
		std::cout << e() << std::endl;    // “调用”对象来生成一个随机数
	}
    std::cout << e.min() << std::endl;      // 0
	std::cout << e.max() << std::endl;     // 此引擎可生成的最大最小值
	system("pause");
	return 0;
}
```

补充：

- 上面的例子非常重要，直接看上面就知道它的使用方式；
- std::default_random_engine::result_type a = 5;    // 此引擎生成的unsigned整数类型
- e.discard(u)           // 将引擎推进u步，u的类型为unsigned long long

==分布类型和引擎==：（重要，有==生成指定范围类的数字==）

​	就上面例子而言，一般随机数引擎的输出是不能直接使用的(上面出来的数字都非常大，通常与我们想要的不符)，所以称之为原始随机数。

为了得到在一个指定范围内的数，使用一个分布类型的对象：下面代码就是==生成0~9(包含)之间均匀分布随机数==

```c++
#include <random>
#include <ctime>  
int main(int argc, char*argv[]) {    
    // 下面是针对整型的随机数
	static std::uniform_int_distribution<unsigned> u(0, 9);   // 要random头文件的（0、9都能取到，是闭区间）
	// static std::default_random_engine e;   // 每次运行得到的结果都是一致的（可能是时间太短）
    // 使用当前时间（秒数）作为随机数引擎的种子,每次结果都不一致
    static std::default_random_engine e(static_cast<unsigned>(std::time(nullptr)));  
	for (size_t i = 0; i < 10; ++i) {
		std::cout << u(e) << std::endl;
	}
	return 0;
}
```

解读：

- 第3行：是一个类模板，要显式地指定类型，构造时要指定范围0,9；
- 第4行：生成无符号随机整数；
- 第6行：将u作为随机数源，每个调用返回在指定范围内并服从均匀分布的值；且注意这里是u(e)意思是传递给分布对象u的是引擎对象本身e，不要写成了u(e())，这就是把e生成的值传递给u，这会导致编译错误。
- ==一定看这==：在linux下，使用这种方式，好像第一次随机的数永远是u.min(),这里也就是0，要注意下这个情况。

这里把==C生成随机数==的方式也写这里，感觉在linux下，这种方式更易用：

```c++
#include <iostream>
#include <string>
#include <ctime>   // 搭配根据时间的随机种子
int main() {
    // srand、time、rand不用加std都是可以的
	srand((unsigned int)time(NULL));   // 固定随机种子写法
    // 方式一：这是生成1-100的随机数
	int num = rand() % 100 + 1;  // （如果不+1,rand() % 100就是成成0-99）
    
    // 方式二：在PCL中，还看到 生成0-1023之间的数，（里面是有小数的，比如：34.22 20.5313 931.5）
    float nun01= 1024.0f * rand() / (RAND_MAX + 1.0f); // RAND_MAX是宏，上面写过
    return 0；
}
```

所以要生成范围(min, max)内的随机数：min + rand()%(max-min + 1);  # 加1是为了包含取到max

最后：当说==随机数发生器==时，是指==分布对象和引擎对象的组合==。

---

==让每次生成的随机数不同==：

​	书上叫“引擎生成一个数值序列”。像上面写的例子的引擎，在一个程序中多次调用，或一个程序多次运行，得到的结果都是一样的，即：

- 一个给定的随机数发生器一直会生成相同的随机数序列；
- 重要：==一个函数如果定义了局部随机数发生器，应将其(包括引擎和分布对象)定义为static的，否则每次调用函数都会生成相同的序列==。（定义为static就只是让其生命周期延长，类似于全局变量了，特别是函数里，应该这样写）

```c++
#include <random>
void my_random() {
	static std::default_random_engine e;      // 注意这两行的static
	static std::uniform_int_distribution<unsigned> u(0, 9);
	for (size_t i = 0; i < 10; ++i)
		std::cout << u(e) << std::endl;
         std::cout << u.max() << std::endl;  // 9  这也有max()、main()
}
int main(int argc, char*argv[]) {
	my_random();
	std::cout << "------------------" << std::endl;
	my_random();
	return 0;
}
```

解读：

- 如果第3、4行没有`static`，程序无论运行多少次,第9、11行的结果永远是一样的；

  - `一定要加static，一定要啊，养成习惯！`
- 现在加了static，所以它们在函数调用之间会保持住状态，第一次调用(9行)会使用u(e)生成的序列的前10个随机数，第二次调用(11行)会获得接下来的10个，以此类推。那么一次程序运行第9行和11行的结果就不一样；
- 但是多次程序运行，每一次的第9行结果永远是一样，每一次的第11行结果也都是一样的。所以就要设置时间的随机种子，
- ==一定看这==：在linux下，使用这种方式，好像第一次随机的数永远是u.min(),这里也就是0，要注意下这个情况。

#### 时间的随机种子

​	想要每次程序运行时给的随机数不一样，那就要设定不一样的随机种子，一般就是调用系统函数time，这个函数定义在头文件`#include <ctime>`中，它返回从一个特定时刻到当前经过了多少秒。函数time接收单个指针参数，它指向用于写入时间的数据结构，如果此指针为空，则函数简单地返回时间：

```c++
#include <random>
#include <ctime>          // 别忘了头文件
std::default_random_engine e(std::time(0));  // 直接构造时指定
e.seed(std::time(0));           // 或是这样来改变
```

Tips：

- 由于time返回以秒计的时间，因此这种方式只适用于生成种子的间隔为秒级或更长的应用。更精细的话就要用std::chrono库来做种子的
- 这里的time()无论在linux还是windows下都是可以直接使用的，不用加std::也是可以的。
- time(0)和time(NULL)应该是一样的，这里的参数好像是一个指针，所以都行。

#### 小数随机数分布

==生成随机实数(主要是浮点数)==：

​	最常用但不正确的从rand函数获得一个随机浮点数的方法是rand()的结果除以RAND_MAX,其随机整数的精度通常低于随机浮点数，这样有一些浮点值就永远不会被生成了。

使用新标准库设施，可轻松获得随机浮点数：
	首先定义一个==uniform_real_distribution==类型的对象(这个的构造函数是explicit的)，并让标准库来处理从随机整数到随机浮点数的映射，其使用与uniform_int_distribution基本类似。

```c++
static std::default_random_engine e;
static std::uniform_real_distribution<double> u(0, 5);   // 类型必须是浮点型
for (size_t i = 0; i < 10; ++i) {
	std::cout << u(e) << std::endl;
    // 这个也有 u.min()  u.max()
    // 还有 u.reset()  重建u的状态，使得随后对d的使用不依赖于d已经生成的值
}
```

Tips：

- 第2行，模板的默认类型就是double，但因为是类模板不可以隐式指定类型，可以像这样写代表使用默认结果类型：std::uniform_real_distribution\<> u(0, 5);   // 给个尖括号放那里代表使用默认类型

---

==std::normal_distribution==类型：

```c++
#include <random>
#include <cmath>
int main(int argc, char*argv[]) {
	static std::default_random_engine e;
	e.seed(5);  // 可以重设随机种子，也可以不要
	static std::normal_distribution<> n(4, 1.5);  // 生成的值以均值4位中心，标准差为1.5
	std::cout << n(e) << std::endl;

	std::cout << std::lround(n(e)) << std::endl;
	return 0;
}
```

解读：

- 别忘了随机数引擎类可以在构建时设定随机种子，也可以用seed来重新指定；
- 第6行，只给了\<>，代表使用默认类型，然后一次就是生成一个数；
- 第9行，==std::lround()就是一个四舍五入的函数==，书上说这是在头文件`<cmath>`中，vs中不要也行，但是还是一定要写这个头文件，不然linux上就会直接报错。

---

==std::bernoulli_distribution==类型：

​	这是一个普通类，而非模板，所以不接受模板参数，此分布总是返回一个bool值，它返回true的概率是一个常数，此概率的默认值是0.5，也可以人为的去改变。

```c++
std::default_random_engine e;       // 随机数引擎类
std::bernoulli_distribution b;      // 随机数分布类
bool result = b(e);                 // 返回true的默认概率就是0.5，即默认50/50的概率
```

Tips：

- 这叫伯努利分布，返回值只有true和false
- std::bernoulli_distribution b(0.9);    // 让返回true的概率更大
  std::bernoulli_distribution b(0.2);    // 让返回true的概率更小



最后：随机数引擎类一般就是用这一个==std::default_random_engine==，但是随机数分布类有很多种，除了上面写到的常用的几种，还有一些在书上右上角标的第781页。

### 4.4. 异常处理

​							<stdexcept\>头文件定义的异常类：

| 异常类型         |                                                |
| ---------------- | ---------------------------------------------- |
| exception        | 最常见的问题                                   |
| runtime_error    | 只有在运行时才能检测出的问题（如除数为0）      |
| range_error      | 运行时错误：生成的结果超出了有意义的值域范围   |
| overflow_error   | 运行时错误：计算上溢                           |
| underflow_error  | 运行时错误：计算下溢                           |
| logic_error      | 程序逻辑错误                                   |
| domain_error     | 逻辑错误：参数对应的结果值不存在               |
| invalid_argument | 逻辑错误：无效参数                             |
| length_error     | 逻辑错误：试图创建一个超出该类型最大长度的对象 |
| out_of_range     | 逻辑错误：使用一个超出有效范围的值             |

以下这张图是==异常类层次==说明，catch字句捕获要从最细的类(下)到上：

![](./c++遇到的坑/illustration/异常类层次.png)

​	C++标准库定义了一组类，用于报告标准库函数遇到的问题。这些异常类也可以在用户编写的程序中使用，它们分别定义在4个头文件中:

- exception头文件定义了最通用的异常类exception。它只报告异常的发生，不提供任何额外信息。
- stdexcept头文件定义了几种常用的异常类，详细信息如上表。
- new头文件定义了bad_alloc异常类型，这种类型将在后面说
- type_info头文件定义了bad_cast 异常类型，这种类型将在后面说。

只能以默认初始化的方式初始化exception、bad_alloc和bad_cast对象，不允许为这些对象提供初始值；

​	其它异常类的要求刚好相反：应该使用string对象或者C风格字符串初始化这些类型的对象，但是不允许使用默认初始化的方式，当创建此类对象时，必须提供初始值(就是字符串的自定义错误提示信息)，（这也就应该解释了上面示例代码的必须要throw表达式，就是用这来初始化吧）

​	==异常类型只定义了一个名为what()的成员函数，返回值是一个指向C风格字符串的const char*==；对于没有初始值的异常类型来说，what返回的内容由编译器决定。

#### 4.4.1 throw | try

(注意：点到这里时，也稍微往上划一下，上面也还有些不错的内容)

==throw==跟int这些一样直接使用，是关键字；throw表达式引发一个异常(直接程序运行不下去，报错的)，throw紧跟的表达式类型就是抛出的异常类型，简单的例子：

```c++
#include <stdexcept>    
if (a == b) {
	throw std::runtime_error("这是一个错误抛出");
}
// 后续还看到过这样的用法，直接throw抛出
if (srcImage.empty()) {
    throw "[ERROR] srcImage empty !";       // 居然可以直接这样抛出
}
```

书上说类型runtime_error是标准异常类型的一种，定义在stdexcept头文件中，但是我在win下和linux下不导入这个头文件都是可用的。

==try==语法：

```c++
try {
	// 这里代码，好像一般都要有一个throw语句把错误抛出
}
catch (一个错误类型) {
	// 错误的处理
}
catch (又一个其它的错误类型) {
	
}
```

示例：

```c++
#include <iostream>
#include <stdexcept>

int main() {
	int i = 2, j = 0;
	try {
		if (j == 0) {
			throw std::runtime_error("除数为0了");
             throw std::invalid_argument("field is not a bool");  // 这行参考
		}
		std::cout << i / j << std::endl;
	}
	catch (const std::runtime_error& err) {
		std::cout << err.what() << ";;这是这一行的提示信息" << std::endl;
	}
	system("pause");
	return 0;
}
```

Tips：

- 上面代码try里的代码，一定要在执行i/j的除法前，做判断把错误通过throw抛出来(但是这不会像上面单独使用throw一样直接报错)；好像一定要有这个不能像python那样，把除法写这里，然后让系统去直接捕获异常；换言之，throw表达式语句，存在于代码块中，将控制权限转移到相关的catch子句。
- 第13行的`err.what()`的返回结果就是字符串，内容就是上throw表达式里写的内容。

一般这么用：

```c++
std::range_error r("error");
throw r;

std::exception *p = &r;
throw *p;
```

vs中给的示例代码片段：

```c++
try {
	// 需要执行的代码
}
catch (const std::exception&) {      // 也可以是 const std::exception& err
	// do something                   // 就可以输出 err.what() 查看错误信息
}
```

#### 4.4.2 catch(...) 

捕获所有异常：`catch (...){ }` 是固定写法，

```c++
try {/*   内容   */
}
catch (...) {       // ... 是固定写法
	// 处理异常的某些特殊操作
	throw; // 执行完当前局部能完成的工作，随后重新抛出异常
	// throw若在其它异常处理代码之外，编译器将调用terminate
}
```

Tips：

- catch(...)能单独出现，也能与其它几个catch语句一起出现，若一起出现，它必须被放在最后。
- catch(const std::exception&) 也算是捕获所有异常。

#### 4.4.3 noexcept

​	在c++新标准中，可以通过提供==noexcept说明==指定某个函数不会抛出异常，其形式是关键字noexcept紧跟在函数的参数列表后面：
void recoupt(int) noexcept;        // 不会抛出异常（这就是做了==不抛出说明==）
void recoupt(int) throw();        // 与上面等价，在早期写法，==c++新版本中已经被取消了== 

void alloc(int);                  // 可能抛出异常

- 对一个函数来说，noexcept 要么出现在该函数的所有声明语句和定义语句中，要么一次也不出现；
- noexcept 应该出现在函数的尾置返回类型之前；
- 在typedef或类型别名中不能不出现noexcept ；
- 在成员函数中，noexcept 说明符需要跟在const及引用限定符之后，而在final、override或虚函数的=0之前。

---

noexcept还可以添加一个异常说明的是实参(该实参必须能转换成bool类型)：
void recoupt(int) noexcept(true);   // recoupt不会抛出异常
void alloc(int) noexcept(false);    // alloc可能抛出异常，相当于不加noexcept说明

​	以上都是为了一个==noexcept运算符==，它常与上面说的实参一起使用，比较普通的形式是 noexcept(e),当e调用的所有函数都做了不抛出说明且e本身不含有throw语句时，这表达式为true，否则返回false。以下一个异常来说明：
​	void f() noexcept(noexcept(g()));   // f和g的异常说明一致

​	如果g承诺了不会抛出异常，则函数f也不会抛出异常；如果g没有异常说明符，或者g虽然有异常说明符但允许抛出异常，则f也可能排除异常。

说明：
	单单就一个noexcept,那它就是一个==noexcept说明==；如果是像上面noexcept(g())用其计算返回bool值，那它就是一个==noexcept运算符==。

#### 4.4.4 自定义异常类型

使用自己的异常类型：通过继承来写自己的异常类，然后拿来使用：(直接是代码demo)

```c++
class isbn_mismatch : public std::logic_error {
public:
    explicit isbn_mismatch(const std::string &s) : std::logic_errors(s) {}
    isbn_mismatch(const std::string &s, const std::string &lhs, const std::string &rhs) : std::logic_error(s), left(lhs), right(rhs) {}
    
    const std::string left, right;
};
```

// 如果参与加法的两个对象并非同一书籍，则抛出一个异常：

```c++
Sales_data& Sales_data::operator+=(const Sales_data& rhs) {
	if (isbn() != rhs.isbin()) 
        // 下面这就是用的上面我们自己写的异常类来抛出，用法跟标准库都是一模一样的
        throw isbn_mismatch("wrong isbns", isbn(), rhs.isbn());   
}
```

类似上面自定义的异常类，也还有简单一点的(是一样的)：

```c++
class out_of_stock : public std::runtime_error {
public:
    explicit out_of_stock(const std::string &s) : std::runtime_error(s) {}
}
```

#### 4.4.5 其它概念

==栈展开==：
	一个try触发时，会检查与该try块关联的catch子句，若没找到且该try语句嵌套在其它try块中，则继续检查与外层try匹配的catch子句，若这样仍没找到，则退出当前这个主调函数，继续在调用了刚刚推出的这个函数的其它函数中寻找，以此类推，这个过程就是==栈展开==。最后都找不到匹配的catch时，程序将调用标准函数库terminate来终止程序的执行过程。

---

==函数try语句块==与构造函数：

​	就是把异常捕获放进构造函数，下面是伪代码，格式大致是：

```c++
template <typename T>
Blod<T>::Blod(std::initializer_list<T> li) try : data(std::make_shared<T> (li)) {
	/*  空函数体   */
} catch(const std::bad_alloc &e) {handle_out_of_memory(e);}
```

​	注意：关键字try出现在表示构造函数初始值列表的冒号以及表示函数体的花括号之前。与这个try关联的catch既能处理构造函数体抛出的异常，也能处理成员初始化列表抛出的异常。

### 4.5. 命名空间

==定义==：以下就定义了一个名为 cplusplus_primer 的命名空间，包含三个成员：两个类和一个重载的+运算符。

```c++
namespace cplusplus_primer {
    class Sales_data { /*...*/};
    Sales_data operator+(const int&, const int&);
    class Query { /*....*/};
}    // 注意结尾是没有分号的
```

Tips：

- 命令空间可以定义在全局作用域内，也可以定义在其他命令空间中，但是不能定义在函数或类的内部；
- ==命名空间可以是不连续的==：比如上面的代码，可能是定义了一个名为 cplusplus_primer 的新命令空间，也可能是为已经存在的命名空间添加一些新成员(那就是打开已经存在的命名空间定义并为其添加一些新成员的声明)；
  所以注意：那么在多个(或单个)文件中的一个同名的命名空间里的数据是共同的，相当于增加，而不是覆盖。如imgui这个库的，在imgui.h头文件中namespace ImGui就出现了几次，且注意这个命令空间中的函数实现，并不都是在imgui.cpp中实现的，它是把头文件中的具体实现，分到了多个.cpp文件中(这些的特点就是都导入了imgui.h)
- 在全局下定义的一个名字，num，可以直接使用，如可能有冲突时，也可写作::num（这其实就是全局命名空间）。

==命名空间的别名==：

比如上面的命名空间 cplusplus_primer 起个别名就是：
namespace primer = cplusplus_primer;        // 以namespace起头

别名还可以指向一个嵌套的命名空间：
namespace n1 = cplusplus_primer::name1;    // name1是cplusplus_primer中的一个嵌套命名空间

---

==嵌套的命名空间 | 内联命名空间==：（内联命名空间能比较方便获取内部其它命名空间的成员）

​	嵌套的命名空间：是指定义在其它命名空间的命名空间，那么使用的时候就要是 cplusplus::QueryLib::Query，嵌套了多少次就要用::这样的方式去指定。

​	C++11新标准引入了一种新的嵌套命名空间，称为==内联命名空间(inline namespace)==,和普通的嵌套命名空间不同，==内联命名空间中的名字可以被外层命名空间直接使用==，也就是说无须在内联命名空间的名字前添加表示该命名空间的前缀，通过外层命名空间的名字就可以直接访问它。如下：定义就是在关键字namespace前添加关键字inline，如下：

```c++
inline namespace name1 {}
// 注意这两行，关键字inline必须出现在命名空间第一次定义的地方，后续打开命名空间时，inline可写也可以不写
namespace name1 {
    class Query_base { /*...*/ };
}
```

再来一个命名空间是非内联的：

```c++
namespace name2 {
    class Item_base { /*...*/ };
}
```

使用内联的好处：假定上面的两个命名空间都定义在同名头文件中，那么可以把命名空间 cplusplus_primer 定义成如下形式：

```c++
namespace cplusplus_primer {
    #include "name1.h" 
    #include "name2.h"
}
```

​	那么：因为name1是内联的，那就可以使用 cplusplus_primer::的代码获取name1的成员，而name2是非内联的，那就需要加上完整的外层命名空间名字，比如 cplusplus_primer::name2::Item_base

---

==未命名的命名空间==：（这也叫“匿名命名空间”）
	是指关键字namespace后紧跟花括号起来的一系列声明语句。未命名的命名空间中定义的变量拥有==静态生命周期：他们在第一次使用前创建，直接程序结束才销毁==。

- 一个未命名的命名空间可以在某个给定的文件内不连续，但是不能跨越多个文件。

定义在未命名的命名空间中的名字可以直接使用，但一定要与全局作用域中的名字有所区别：

```c++
int i;
namespace {
	int i;      
}
i = 10;     // 不对，有二义性了，i不知道是哪一个
```

同样未命名的命名空间可以嵌套在其他命名空间中，然后就可以通过外层命名空间的名字来访问：

```c++
int i;
namespace local {
    namespace {
        int i;
    }
}
local::i = 42;    // 正确,这就有所区分
```

==未命名的命名空间的意义==：
	取代文件中的静态声明。在标准c++引入命名空间的概念之前，需要将名字声明成static的以使得其对于整个文件有效。在文件中进行静态声明的做法是从C语言继承而来的，在C语言中，声明为static的全局实体在其所在的文件外不可见。
	在文件中进行静态声明的做法已经被C++标准取消了，现在的做法就是使用未命名的命名空间。
	也就是说==需要定义一系列静态的变量的时候，==应该使用未命名的命名空间。更多的解释看[这里](https://stackoverflow.com/questions/154469/unnamed-anonymous-namespaces-vs-static-functions)。

---

==using声明==：只对其所在的作用域有用，一次只引进命名空间的一个成员，如`using std::cout;` 

==using指示==：可以在全局作用域、局部作用域和命名空间作用域，但是它是不能出现在类的作用域中的，如`using namespace std;`,这个也是可以放到函数里的，特别是自己写的命名空间，就可以少写很多：

```c++
void func() {
	using namespace cplusplus_primer;
}
```

总之少用using指示吧，但在命名空间本身的实现文件中可以使用using指示，这样会比较方便。

### 4.6. union类

​	==联合(union)==是一种特殊的类：一个union可以有多个数据成员，但是在==任意时刻只有一个数据成员可以有值==，当给union的某个成员赋值后，该union的其它成员就变成了未定义的状态了。(是一种节省空间的类)
​	union可以为其成员指定public、protected和private等保护标记。默认情况下，union的成员都是公有的，这一点与struct相同。

==定义==：
	先关键字union，随后是该union的(可选的)名字以及花括号内的一组成员声明。

```c++
union Token {
	char cval;
	int ival;
	double dval;
};
```

注意：Token类型的对象只有一个成员，该成员的类型可能是以上三种的任意一种。

==使用==：
	默认情况下union是未初始化的，可以像显示地初始化聚合类一样使用一对花括号内的初始值显式地初始化一个union：=

- Token first_token = {'a'};      // 聚合类可以去看1C++基础.md中关于结构体那里

- Token *pt = new Token;  // 指向一个未初始化的Token对象的指针
  pt->ival = 42;       // 成员访问运算符来赋值

要注意：union在任意时都只有一个数据成员可以有值。

==匿名union==： 
	union后不要跟名字，就是一个匿名union。

```c++
union {                  
	char cval;
	int ival;
	double dval;
};
cval = 'c';         // 为刚刚定义的未命名的匿名union对象赋一个新值
ival = 42;          // 该对象当前保存的值是42
```

在匿名union的定义所在的作用域内该union的成员都是可以直接访问的（跟不限定作用域的枚举成员访问有些像）

### 4.7. 固有的不可移植的特性

​	介绍C++从C语言继承而来的另外两种==不可移植的特性==：==位域==和==volatile限定符==。另外还介绍==链接指示==，它是c++新增的一种不可移植的特性。

​	所谓不可移植特性是指因机器而已的特性，当我们将含有不可移植特性的程序从一台机器转移到另一台机器上时，通常需要重新编写该程序。算术类型的大小在不同机器上不一样，这是使用过得不可移植特性的一个典型示例。

#### 4.7.1 位域

​	类可以将其(非静态)数据成员定义成==位域==,在一个位域中含有一定数量的二进制，当一个程序需要向其他程序或硬件设备传递二进制数据时，通常会用到位域。

​	位域的类型必须是整型或枚举类型。因为带符号位域的行为是由具体实现确定的，所以在通常情况下，使用无符号类型保存一个位域。==位域的声明形式在在成员名字之后紧跟一个常量表达式==，该表达式用于指定成员所占的二进制位数：

```c++
typedef unsigned int my_Bit;
class my_File {
	my_Bit mode : 2;         // 占2位
	my_Bit modified : 1;     // 占1位
	my_Bit prot_owner : 3;   // 占3位
	my_Bit prot_group : 3;
	my_Bit prot_world : 3;
	// my_File的操作核数据成员
public:
	// 文件类型以八进制的形式表示（以0开头的整数代表八进制）
	enum modes { READ = 01, WRITE = 02, EXECUTE = 03 };
	my_File &open(modes);
	void close();
	void write();
	bool isRead() const;
	void setWrite();
};
```

使用位域(接着上面的代码)：

```c++
void my_File::write() {
	modified = 1;
	// ....
}
void my_File::close() {
	if (modified) 
		// .... 保存内容        
}

// 通常使用内置的位运算符操作超过1位的位域
my_File &my_File::open(my_File::modes m) {
	mode |= READ;   // 按默认凡是设置READ
	if (m & WRITE)
		// ... 按照读/写方式打开文件
	return *this;
}
```

如果一个类定义了位域成员，则它通常也会定义一组内联的成员函数以检验或设置位域的值：

```c++
inline bool my_File::isRead() const { return mode & READ; }
inline void my_File::setWrite() { mode |= WRITE; }   // 这里用了一个位运算符 |
```

#### 4.7.2 volatile限定符

​	例如，程序可能包含一个由系统时钟定时更新的变量。当对象的值可能再程序的控制或检测之外被改变时，应该将对象声明为volatile,此关键字volatile告诉编译器不应对这样的对象进行优化。

使用：volatile限定符的用法和const很相似，它也是对类型的一个额外修饰：

volatile int i;    // 该int值可能发生改变
volatile int iax[max_size];   // iax的每个元素都是volatile

- 某种类型既可能是const的也能是volatile的；
- 也可以将成员函数定义为volatile的，也只有volatile的成员才能被volatile的对象调用；
- 可以声明volatile指针、指向volatile对象的指针以及指定volatile对象的volatile指针(跟const限定符和指针的相互作用类似)；

合成的拷贝对volatile对象无效：const和volatile的一个重要区别就是不能使用合成的拷贝/移动构造函数及赋值运算符初始化volatile对象或从volatile对象赋值。

#### 4.7.3 链接指示：extern "C"

​	C++使用==链接指示==指出任意非C++函数所用的语言。（想要把C++代码和其它语言(包括C语言)编写的代码放在一起使用，要求我们必须有权访问该语言的编译器，并且这个编译器与当前的C++编译器是兼容的）

- 链接指示可以有两种形式：单个的或复合的；
- 链接指示不能出现在类定义或函数定义的内部；
- 同样的链接指示必须在函数的每个声明中都出现。

```c++
// 可能出现在C++头文件<cstring>中的链接指示
// 单语句链接指示
extern "C" size_t strlen(const char *);

// 复合语句链接指示
extern "C" {
	int strcmp(const char*, const char*);
	char *strcat(char*, const char*);
}
```

​	链接指示的第一种形式包含一个关键字extern，后面是一个字符串字面常量值以及一个“普通的”函数声明。其中的字符串字面值常量指出了编写函数所用的语言。编译器应该支持对C语言的链接指示。此外，编译器也可能会支持其它语言的链接指示，如extern "Ada"、extern "FORTRAN"等。

---

==链接指示与头文件==：
	多重声明的形式可以应用于整个头文件，例如，C++的cstring头文件可能形如：

```c++
// 符合语句链接指示
extern "C" {
    #include <string.h>      // 操作C风格字符串的C函数
}
```

​	当个#include指示被放置在复合链接指示的花括号中，头文件中的所有普通函数声明都被认为是由链接指示的语言编写的。链接指示可以嵌套，因此如果头文件包含带自带链接指示的函数，则该函数的链接不受影响。

---

指向C函数的指针与指向C++函数的指针是不一样的类型：

```c++
void (*pf1) (int);        // 指向一个c++的函数
extern "C" void (*pf2) (int);  // 指向一个C函数
pf1 = pf2;   // 错误：pf1和pf2的类型不同
```

​	extern "C" typedef void FC(int);   // FC是一个指向C函数的指针

​	void f2(FC *);         // f2是一个c++函数，该函数的形参是指向C函数的指针

---

导出C++函数到其它语言：
	通过使用链接指示对函数进行定义，可以令一个C++函数在其它语言编写的程序中可用：

extern "C" double calc(double dparm) {/*...\*/}  // calc函数可以被c程序调用

​	编译器将为该函数生成适合于指定语言的代码。但注意，可被多种语言共享的函数的返回类型或形参类型受到很多限制。例如，不太可能把一个C++类的对象传给C程序，因为C程序根本无法理解构造函数、析构函数以及其它类特有的操作。

---

小操作：对链接带C的预处理器的支持

​	有时需要在C和C++中编译同一个源文件，为了实现这一目的，在编译C++版本的程序时预处理器定义==__cplusplus==(两个下划线)，利用这个变量，可以在编译C++程序的时候有条件的包含进来一些代码：

```c++
#ifdef __cplusplus
extern "C"
#endif
int strcmp(const char*, const char*);
```

---

重载函数与链接指示：
	C语言不支持函数重载，所以C链接指示智能用于寿命一组重载函数中的某一个：
// 以下错误：两个extern "C"函数的名字相同
extern "C" void print(const char*);
extern "C" void print(int);

所以，在一组重载函数中有一个是C函数，则其余的必定都是C++函数

### 4.8. 位运算符

| 运算符    | 功能          | 用法                              |
| --------- | ------------- | --------------------------------- |
| ~         | 位求反        | ~expr                             |
| <<<br/>>> | 左移<br/>右移 | expr1 << expr2<br/>expr1 >> expr2 |
| &         | 位与          | expr & expr                       |
| ^         | 位异或        | expr ^ expr                       |
| \|        | 位或          | expr \| expr                      |

用的比较少，到时候直接看书吧，直接输入136页！

还经常会看到这样的表达式：expr |= expr   这就像是+=，先位或再赋值。
