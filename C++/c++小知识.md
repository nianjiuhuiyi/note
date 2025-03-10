 C/C++ 技术面试基础知识总结，包括语言、程序库、数据结构、算法、系统、网络、链接装载库等知识及面试经验、招聘、内推等信息。写很全，可看。[地址](https://github.com/huihut/interview)。

```c++
int res = std::max(1, 3);
int res = (std::max)(1, 3);  // 这两种写法都是一样的
```

```c++
std::string num = "3.14";  // 下面这两种string转C的字符串是一样的
std::cout << (num.data() == num.c_str()) << std::endl;  // 结果为true，
```



## 0.0. 参数传入

一般关于参数的写法，`int main(int argc, char **argv) {}`

- argc的值为整数，值=传入的参数个数+1;
- argv可以理解为一个数组名，包含了执行文件名及传入的参数;
  - 可以通过argv[i]去获取到参数：argv[0]执行的程序的名字路，径如果是./main，那它就是这个；如果输入是./bin/main ，那它就是这；
  - 会发现`*argv`解引用出来就是argv[0]的值;然后`*(++argv)`解引用出来的值就是argv[1]的值。

一般的处理方法：假定执行`./main -device 1 -out_dir outpu`，

```c++
#include <iostream>
#include <string>
#include <vector>
#include <sstream>   // 字符串数字转整数一点要的

// 把参数一个个拿出来放到一个vector中
std::vector<std::string> get_arguments(int argc, char **argv) {
	std::vector<std::string> arguments;
	for (int i = 0; i < argc; ++i) {
		arguments.push_back(argv[i]);
	}
	return arguments;
}

int main(int argc, char **argv) {
	std::cout << argc << std::endl;   // 得到整数 5
	// *argv、argv[0] 的结果都是 ./main

	std::vector<std::string> arguments = get_arguments(argc, argv);

	// 这里就去遍历参数，把对应功能做了
	int device = -1;
	std::string output_dir = "";
	for (int i = 0; i < arguments.size(); ++i) {
		if (arguments[i].compare("-device") == 0) {
			// 难道下一个参数 0，并把它转成整数
			std::stringstream data(arguments[i + 1]);  
			// 注意这一定要头文件 <sstream>
			data >> device;
			i++;   // 0已经去了，就跳过到下一个参数
		}
		else if (arguments[i].compare("-out_dir") == 0) {
			output_dir = arguments[i + 1];
			i++; // 跟上面一样
			// 这里就可以根据自己情况写
		}
	}

	if (!output_dir.empty()) {
		std::cout << "输出目录：" << output_dir << std::endl; 
        // 这里还可以根据自己实际其概况做一些操作
	}
	if (device != -1) {
		std::cout << "设备编号：" << device << std::endl;
	}
}
```

​	当然还可以是`./songhui/main -device 1 -f 123.mp4`这样-f不会管，然后没有-out_dir，也会不会去做对应操作。

***

- int main(int argc, char *argv[]) {}
  argv是一个数组，它的元素是指向C风格字符串的指针，

因为第二个形参是数组，所以main函数也可以被定义为：

- int main(int argc, char **argv) {}
  其中argv指向char\*;

一般argv[0]都是可执行程序的名字，后面是用户输入的参数

补充：

- 有一个名词叫`省略符形参`，是为了便于c++程序访问某些特殊的C代码而设置的，这些代码使用了名为varargs的C标准库功能

- c++中还有一个`initializer_list`类型的形参，它的用法跟vector差不多，但它的数据都是常量，是不可修改的，这个类型是定义在同名的头文件中`#include<initializer_list>`，如 `std::initializer_list<int> lst {1, 3, 5, 6};`

***

主函数main的返回值

​	main函数可以没有return语句，编译器会隐式的插入一条返回0的return语句，一般返回0表示执行成功，非0值得具体含义依及其而定

若是为了使返回值与机器无关，`cstdlib头文件`定义了两个==预处理变量==，可以用其表示成功或是失败：

```c++
#include <iostream>
#include <cstdlib>
int main() {	
	if (1) {
		return EXIT_SUCCESS;
	}
	else{
		return EXIT_FAILURE;
	}
}
```

​	注：因为==EXIT_SUCCESS==与==EXIT_FAILURE==是==预处理变量==，所以既不能在前面加std::，也不能在using声明中出现。这个程序执行后，用echo $?看到状态码，成功那个就是0，失败那个就是1。

## 01.保留几位小数

更多的，关于c++的格式化输出，去看[1 c++基础.md](./1 c++基础.md)中的"9.4 书后补充：IO库再探",里面有各种格式化输出。

一个更快，更便捷的保留两位小数

```c++
double fps = 3.1415926;
sprintf(fps, "%.2f", fps);     // sprintf()是stdio.h中的，好像可以不用导包
std::string fpsString("fps: ");
fpsString += string;     // 然后这就是可以用到opencv中了
```

更多的一些格式化输出，可以去看1c++基础.md中9.4.1的格式化输出，很详细了。

```c++
/*下面是c++固定格式化输出保留小数的方法*/
#include <iostream>
#include <iomanip>      // 好像只要这行就行了
#include "stdlib.h"   // 这两行都是为了保留小数导入

// using namespace std;
int main() {
	float a = 3.1465926f;
	float b = 3.0000123f;
	std::cout << round(a * 100) / 100 << std::endl;   // 简单的保留两位小数的写法
	//  round，有点像内置函数，只能四舍五入得到整数，就可以通过先扩大，round后，再除以那么多
	std::cout << round(b * 100) / 100 << std::endl;  // 3；这样就保留不了2位小数，就要用下面的固定写法
	// 注意，这里的2是2位有效数字，3.1也是2位小数，0.31也是两位小数
	std::cout << std::setiosflags(std::ios::fixed) << std::setprecision(2);    // 保留2位小数(会自动四舍五入)固定写法(要搭配上面导入的俩文件,应该只要iomanip这个头文件)   // 上面这个是可以自成一行的，只要在上面设定了，下面所有的cout都会这样输出
	std::cout << a << " nihao " << b << std::endl;
	/*
	std::setprecision(2) 就可以直接进行小数的位数保留了；但对于这种 float a = 100;  用这输出还是100，无法得到100.00
	这时就要加上前面的 std::setiosflags(std::ios::fixed)
	还有一种方式，用操纵符，std::cout << std::showpoint; 打印小数点，就会把后面打印出来
	*/
	system("pause");
	return 0;
}
```

​	格式化输出(特别是时间)：当输出时间格式的时候需要这样的输出`01:08:31`作为结果，然而一般输出的是`1:8:31`,少了那个0，就需要c++的格式化输出了;

```c++
// 导入的和上面一样
int main() {
	int hour = 5;
	int min = 5;
	int second = 35;
	std::cout << hour << ':' << min << ':' << second << std::endl;

	std::cout.setf(std::ios::right);
	std::cout.fill('0');
	std::cout.width(2);
	std::cout << hour << ':' << min << ':' << second << std::endl;  // 暂时还是不太对，只有hour前面补了'0'
	system("pause");
	return 0;
}
```

##  02. 带空格的输入

std::cin >>  这样输入在碰到空格时就不管了；然后`mystr.size()`可以获取这个字符串的字符个数

方式一：

```c++
// 控制台只能输入一个信息，直接就会打印两条相同的信息 a、b
char a[20];
std::cin.get(a, 20);
std::cout << a << std::endl;

char b[20];      // 这俩函数基本一样，可以接收空格；cin>> 是不能接收空格的
std::cin.getline(b, 20);
std::cout << b << std::endl;
```

方式二：string

```c++
std::string cd;          
std::getline(cin, cd);     // string类型字符串用这种去获取带空格的输入 
std::cout << cd << endl;
std::cout << cd.size() << std::endl;      // 获取字符串个数
```

方式三(最简单的)：

```c++
std::string a, b, c;
std::cin >> a >> b >> c;        // 这种会自动根据输入的空格或是换行符进行切分

// 或者以这样的方式,可以一次取一个值，处理一个值后，在cin，再处理
std::string temp；
while (1) {
    std::cin >> temp;
    std::cout << temp.size() << std::endl;
}
```

#### 书上经典写法

​	练习：以读模式打开一个文件，将其内容读入到一个`string`的`vector`中，将每一行作为一个独立的元素存于`vector`中;

- std::getline(ifs, temp_str, ' '); 还可以跟第三个参数(char类型)，不给默认应该就是换行符;除了ifs这种文件输入流，还可以是std::istream &os = std::cin; 这样的标准输入流

  - ```c++
    std::string name;
    // 这样就把分割符改成了`,`
    while (std::getline(std::cin, name, ',')) {
    	std::cout << name << std::endl;
    }
    "hello world,this is, a test,"  这样会得到三个字符串
    "hello world,this is, a test"  最后没有逗号的话，只会得到前面的两个字符串
    
    或者写为：
    std::istream &os = std::cin;
    while (!is.eof() && !is.fail()) {
        std::getline(is, name, ',');
    }
    ```

```c++
#include <iostream>
#include <string>
#include <fstream>
#include <vector>

std::string path("C:\\Users\\Administrator\\Desktop\\789\\123.txt");
int main() {
	std::vector<std::string> vec;
	std::ifstream ifs(path);
    std::string temp_str;
	if (ifs.is_open()) {
        // 核心就是这，把每一行放进去
		while (std::getline(ifs, temp_str)) {
            vec.push_back(temp_str);
        }
        ifs.close();  // 读完后，应该要加一个关闭吧，咋后面的diam都没写关闭了呢
	}
	system("pause");
	return 0;
}
```

重写上面的程序，将每个单词作为一个独立的元素进行存储。

```c++
#include <iostream>
#include <string>
#include <fstream>
#include <vector>

std::string path("C:\\Users\\Administrator\\Desktop\\789\\123.txt");
int main() {
	std::vector<std::string> vec;
	std::ifstream ifs(path);
    // 这里也可以写成 if (ifs.is_open())
	if (ifs) {
		std::string buf;
        // 这是一种写法，还有一种写法
		while (ifs >> buf) {
			vec.push_back(buf);
		}
	}
	system("pause");
	return 0;
}
// 下面这就是另外一种写法
#include <stream>      // 需要这个头文件
int main() { 
	std::vector<std::string> vec;
	std::ifstream ifs(path);
	std::string temp_str;
	if (ifs.is_open()) {
		while (std::getline(ifs, temp_str)) {
            // 核心精髓就是这
			std::istringstream iss(temp_str);
			std::string out;
			while (iss >> out) {
				vec.push_back(out);
			}
		}
	}
}
```

***

==总结==：如果读取的文本有多行，且每个单词间是空格分开的，那么就可以是

```c++
std::ifstream ifs(path);   // 1.读取文件
if (ifs) {
	std::string buf;
	while (ifs >> buf) {      // 2. 然后直接这里就单个单个拿到了
		vec.push_back(buf);
	}
}
```

或者使用 sstream io库

```c++
#include <sstream>
std::ifstream ifs(path);   // 1.读取文件
std::string line;  // 读取一行的内容存放在这里

std::string temp_str;  // 每行拆分的单个词汇存放在这里
// int temp_int;   // 如果文件里全是数字，可以在这定义为整型，那下面11行得到的就是整型，12行的vec的定义类型也要是int，这样就做到了文件里数字整型的读取

if (ifs.is_open()) {     // if (ifs) 这种写法也是可以的
	while (std::getline(ifs, line)) {    // 2.分别拿到每行作为一个string
		std::istringstream iss(line);   // 3.核心是这里，又将其转化成流
		while (iss >> temp_str) {
			vec.push_back(temp_str);
		}
	}
}
```

也就是  

```c++
std::istringstream iss("this is a test!");
std::string buf;
while(iss >> buf) {
    std::cout << buf << std::endl;      // 这就会一个单词一行的输出
}
```

## 03. 数字和符号一起的输入格式化(scanf)

```c++
// 1、利用scanf处理`11;25` 这样的数据
// 这个就可以应变处理`11::25`这种数据，下面跟着变就好了
void func1() {
	int a, b;
    // 注意这个`scanf_s`在vs下可以，在其他地方编译出错，要改成`scanf`
	scanf_s("%d:%d", &a, &b);  // 这里的`:`可以根据输入进行修改
	cout << a << endl << b << endl;  // a、b就得到了数字
}

// 2、直接使用cin处理`11;25`,(中间只能有一个字符)
void func2() {
	int a, b;
	char c;       // 一定得是char，一个字符，不能用string
	cin >> a >> c >> b;
	cout << a << endl << b << endl;
}
```

scanf 和 scanf_s的区别

> - 介绍
>
>   - scanf()函数是标准C中提供的标准输入函数，用以用户输入数据
>   - scanf_s()函数是[Microsoft](https://www.baidu.com/s?wd=Microsoft&tn=SE_PcZhidaonwhc_ngpagmjz&rsv_dl=gh_pc_zhidao)公司[VS](https://www.baidu.com/s?wd=VS&tn=SE_PcZhidaonwhc_ngpagmjz&rsv_dl=gh_pc_zhidao)开发工具提供的一个功能相同的安全标准输入函数，从vc++2005开始，[VS](https://www.baidu.com/s?wd=VS&tn=SE_PcZhidaonwhc_ngpagmjz&rsv_dl=gh_pc_zhidao)系统提供了scanf_s()。
>
> - 原因和区别
>
>   - scanf()在读取数据时不检查边界，所以可能会造成内存访问越界：
>
>     - ```
>       //例如：分配了5字节的空间但是用户输入了10字节，就会导致scanf()读到10个字节
>       
>       char buf[5]={'\0'};
>       
>       scanf("%s", buf);
>       
>       //如果输入1234567890，则5以后的部分会被写到别的变量所在的空间上去，从而可能会导致程序运行异常。
>       ```
>
>   - 以上代码如果用scanf_s（）则可避免此问题：
>
>     - ```c++
>       char buf[5]={'\0'};
>       
>       scanf_s("%s",buf,5); //最多读取4个字符，因为buf[4]要放'\0' 
>       
>       //如果输入1234567890，则buf只会接受前4个字符
>       ```

>注： scanf_s最后一个参数n是接收缓冲区的大小（即buf的容量），表示最多读取n-1个字符.
>
>PS: 很多带“_s”后缀的函数是为了让原版函数更安全，传入一个和参数有关的大小值，避免引用到不存在的元素，防止hacker利用原版的不安全性（漏洞）黑掉系统。

## 04. string类型的数字转int类型

里面还有字符串切片、查找：

```c++
#include <iostream>
#include <string>
#include <typeinfo>  // 导入这个头文件后，可用  cout << typeid(变量名).name()  来获取变量类型
#include <sstream>

int main() {
	std::string receive;       // 这个例子输入的数据是  ` 78 * 2`或`-78 + 3`
	std::getline(cin, receive);  // string类型字符串用这种去获取带空格的输入 
	
	int max = receive.size();  // 获取字符串个数（这个size(),是只有C++风格string类型可以直接用的）
	
	int a = receive.find_first_of(' ');  // 顺序找到第一个空格的索引
	int b = receive.find_last_of(' ');   // 倒叙找到第一个空格的索引  （因为就2个空格）
	// 注意：第一个参数为起始字符数（0为第一个字符），第二个参数指定子串长（若省略则表明子串到字符串结尾）
	std::string num1 = receive.substr(0, a);   // 自带的字符串去切片
	std::string num2 = receive.substr(b+1, max);
	char symb = receive[a + 1];
    // 想取最后一个，就是
    std::string num3 = receive.substr(receive.size() - 1)

	int x, y;
	// 这感觉不是很爽，应该还是用别的
    // 字符串型数字转int数字核心是下满几行
	// 这个还必须这么用  （必须导入上面的 <sstream> ）
	std::stringstream ss;  // 实例化对象 //这里还可以用 istringstream 这个类
	ss << num1;    // ss.str(); 打印的就是 num1的值   （还是c++的容器字符串，ss.str().c_str()就是const char* 了）
	ss >> x;    // 还可以这么写  stringstream ss(num1); ss >> x;
    // 还可以重置这个ss对象，方便后面继续使用
    ss.str("");   // 这样之后ss就回到最初空的状态，无论前面ss里是啥值(就把上面的num1的值清除了)。同样的ss.str("hello"),那么此刻ss中的内容就是hello了，
    ss << "hello" << 123;   // ss.str();  打印的结果就是 hello123

	std::stringstream aa;  // 再实例化一个对象
	aa << num2;
	aa >> y;

	std::string symbles = "+ - * / %";  
	// 找得到就返回找到的第一个索引，找不到就是返回-1
	int temp = symbles.find(symb);  // find
}
```

==数字转字符串==：

```c++
	 // 数字转字符串,，需要导入#include <sstream>   （其实也就是下面的stringstream）(同样的就可以字符串数字转成数值型)
	float a = 15.56f;
	std::string res;
	std::stringstream ss;   // 这个 ss 是自己起的别名
	ss << a;
	ss >> res;  // 或者 res = myss.str();
	std::cout << res << std::endl;
	std::cout << typeid(res).name() << std::endl;
```

另外一种方法，不用导入别的包

```c++
	int a = 10;
	std::string res = std::to_string(a);   // 这也是数字转字符串，用to_string
	cout << typeid(res).name() << endl;   
```

==建议使用这个==：（多看看，很好的例子）

```c++
#include <sstream>   // 导包 sstream肯定是必要的
#include <iostream>
#include <string>
int main() {
	// (1):实例化一个输出对象，类似于cout(但是是暂存起来)
	std::ostringstream os;

	std::string name;
	int score1, score2, total;
	// 方法一：
	std::string contence1 = "John 20 50";
	std::istringstream istr1(contence1);    // 实例化对象（记得这样的初始化，这样就把本来的string转成了输入流，就可以用std::getline(istr1, a_string)这样去做处理；同理std::ifstream ifs(一个文件路径) 也是类似，ifs成了一个输入流，两者后续用法就一样了）
	istr1 >> name >> score1 >> score2;
	total = score1 + score2;
	std::cout << name << " 的总分是：" << total << "\n";
	// (这行同上行)os这个输出流跟std::cout有一样的功能
	os << name << " 的总分是：" << total << "\n";

	// 方法二(C风格)：
	const char *contence2 = "Amy 30 42";  // 跟二进制文件读写那有些相似
	std::istringstream istr2;  // 实例化对象  // 这里还可以用 stringstream 这个类
	istr2.str(contence2);
	istr2 >> name >> score1 >> score2;
	total = score1 + score2;
	std::cout << name << " 的总分是：" << total << std::endl;;
	std::cout << "*********************************" << std::endl;

	// (1):
	os << name << " 的总分是：" << total << std::endl;;
	// (1):最后把ostr中的东西打到控制台显示
	std::cout << os.str();
    
    // 这种使用 (直接就把string和int组合成了string)
    std::stringstream ss; int lineNo = 5;
    ss << "1." << lineNo << ": ini parsing failed, section not closed";
    throw std::logic_error(ss.str());

	return 0;
}
```

#### 书上补充的类似方法

```c++
int i = 42;
std::string s = std::to_string(i);  // 整形转字符串
double num = std::stod(s);  //40

std::string s1("3.14aa");
double num = std::stod(s1);  // 3.14  // 字符串转浮点型
```

- int转成string用的是std::to_string();
- 数字型的string转成浮点型用的std::stod()，且它第处理字符的第一个字必须是==+-.0123456789==这些字符中的一个，然后一直处理，直到其它字符(即不在这里面的)。

一个可能会用到的操作（把==一组数字从一个字符串中提取出来==）：

```c++
std::string s2 = "pi != -3.14 a?";
double d = std::stod(s2.substr(s2.find_first_of("+-.0123456789")));
// s2.substr(s2.find_first_of("+-.0123456789"));  得到的结果是：-3.14 a?
cout << d << endl;  // 3.14
```

- 通过find_first_of来获得s2中第一个可能是数值的一部分的字符的位置(注意与find的区别，find是整个查找的字符串要在这里面才行)，
- 然后将从此位置往后的子串传递给std::stod()，然后其处理知道遇到不可能是数值的一部分的字符，然后再将这部分转成符合的双精度浮点值。

Tips:

- ==如果string不能转换为一个数值，这些函数抛出一个invalid_argument异常==。
- 如果转换得到的数值无法用任何类型来表示，则抛出一个out_of_range异常。

string和数值之间的转换(下面str是一个带数字的字符串)（要头文件\<string>）

- std::stof(str, p)         // float
- std::stod(str, p)         // double
- std::stold(str, p)        // long double
- std::stoi(str, p, b)      // int,常用以上这四个就行了
- std::stol(str, p, b)      // long
- std::stoul(str, p, b)     // unsigned long
- std::stoll(str, p, b)     // long long
- std::stoull(str, p, b)    // unsigned long long

其中

- ==p==是size_t指针，用来保存str中第一个非数值字符的下标，p默认为0(即函数不保存下标);
- ==b==表示转化所用的基数，默认值为10(代表十进制)。

建议，不要管p,b参数，就让其使用默认值，然后都只给参数str就好了，然后尽量就只使用i、f、d、ld这四个就好了，其它的结果可能是不对的。

以下函数是c中的实现，c++虽然也可以用，还是用上面的，保持统一：(但我上面笔记说了c++版本尽量只用i、f、d、ld，这里是l(long)，c++版本可能有问题， 所以就用的c版本std::strtol)，c版本还有对应的std::strtoi、std::strtod等

```c++
inline bool strToLong(const std::string &value, long &result) {
	char *endptr;
	// check if decimal
	result = std::strtol(value.c_str(), &endptr, 10);
	if (*endptr == '\0') 
		return true;
	// check if octal
	result = std::strtol(value.c_str(), &endptr, 8);
	if (*endptr == '\0')
		return true;
	// check if hex
	result = std::strtol(value.c_str(), &endptr, 16);
	if (*endptr == '\0')
		return true;

	return false;

	// c++的写法,,应该也是一个意思
	size_t *end;
	result = std::stol(value, end, 8);  
	if (*end == 0) { return true; }
}
```

#### 传入的参数从string到bool

有时候，传参进来时 --use true 或是 --use flase

```c++
bool USE = false;   // 可以先初始化一下
// 要把传进来的 --use 的值赋值给变量 USE, 假设传进来的参数都已经存到 std::map<std::string, std::string> arguments; 中了，然后，arg就是我们要的这对键值对， 那么处理就是
# include <sstream>       // std::boolalpha 在1 c++基础.md中详细说明
std::istringstream(arg.second) >> std::boolalpha >> USE;
```

## 05. 类似 time.sleep

```c++
chrono#include <Windows.h>
Sleep(1); // 直接使用就好（单位应该是毫秒）
// 上面是windows，一般用更更通用的方式
#include <thread>   // 这里面应该就包括了导入 <chrono>
std::this_thread::sleep_for(std::chrono::milliseconds(1000));   // 除了milliseconds还有hour、纳秒等，或者1秒就直接就 std::chrono::seconds(1)
还有 std::this_thread::sleep_until();  的使用
    
// 或者偏C，更简单一小点的写法（自己写的话，还是用上面c++的）
#include <unistd.h>
 	sleep(5);       // 导入上面的头文件，直接调用这个函数就好了，这是5秒
	usleep(1000000);  // 代表微妙，这也是1秒
```

### 统计计时|时间戳

```c++
#include <chrono>    // 需要这个头文件
// 0.0 统计用时（1）
auto start = std::chrono::high_resolution_clock::now();
Sleep(1000);   // 这是window上才能用的，需要上面的#include <Windows.h>头文件
auto end = std::chrono::high_resolution_clock::now();
std::cout << "用时：" << std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count() << "ms" << std::endl;
// 统计时间(2),在“SegmentAnything-OnnxRunner”这个项目还看到这样写
std::chrono::duration<double> diff = end - start;
std::cout << "Cost time: " << diff.count() << "s" << std::endl;  // cost time: 2.45163s

// *****************************************************************************

// 1.0 获取unix毫秒级时间戳（ms的格式是  std::chrono::milliseconds  ）
auto ms = std::chrono::duration_cast<std::chrono::milliseconds>			  (std::chrono::system_clock::now().time_since_epoch());
std::cout << ms.count()  << std::endl;
// 其中，std::chrono::system_clock::now()函数获取当前时间，返回一个std::chrono::time_point类型的对象。

// ***************************************************************************

// 注：在vs中会说localtime函数不安全
// 2.0 时间戳格式化到现在（接着1.0）
#include <ctime>
std::time_t time = ms.count();  // 这里一般给到秒级而不是ms的毫秒级
char str[100];
std::strftime(str, sizeof(str), "%Y-%m-%d %H:%M:%S", std::localtime(&time));
std::cout << "Current time: " << str << '\n';  // 2023-03-08 03:24:39
// 所以改进用 localtime_s 函数
std::tm time_info{};  // 注：使用 localtime_s 函数时，需要将 tm 结构体初始化为零
std::time_t timestamp = std::time(nullptr);
// localtime_s只在vs上才有
errno_t err = localtime_s(&time_info, &timestamp);     // errno_t是win才有的，linux没有
if (err) {  // 如果转换失败，该函数会返回一个非零的错误码
    std::cout << "Failed to convert timestamp to time\n";
    return 1;
}
char str[100]{};
std::strftime(str, sizeof(str), "%Y-%m-%d %H:%M:%S", &time_info);

// 2.1 也可全程用ctime，这是tensorrt中yolov5中看到的代码
#include <iomanip>    // 也要 <ctime>
// prepend timestamp
std::time_t timestamp = std::time(nullptr);
tm *tm_local = std::localtime(&timestamp);
std::cout << "[";
std::cout << std::setw(2) << std::setfill('0') << 1 + tm_local->tm_mon << "/";
std::cout << std::setw(2) << std::setfill('0') << tm_local->tm_mday << "/";
std::cout << std::setw(4) << std::setfill('0') << 1900 + tm_local->tm_year << "-";
std::cout << std::setw(2) << std::setfill('0') << tm_local->tm_hour << ":";
std::cout << std::setw(2) << std::setfill('0') << tm_local->tm_min << ":";
std::cout << std::setw(2) << std::setfill('0') << tm_local->tm_sec << "] ";
// 最终：[03/08/2023-03:41:04] 
```

- 上面的结果是ms，还可以化成小时、分钟、秒这些：
  - `std::chrono::duration_cast<std::chrono::hours>(end - start).count()`;
  - std::chrono::minutes
  - std::chrono::seconds       // 秒
  - std::chrono::milliseconds  // 毫秒
  - std::chrono::microseconds  // 微秒
  - std::chrono::nanoseconds   // 纳秒

chatGPT的一个回答：high_resolution_clock与system_clock的区别：

> std::chrono::high_resolution_clock::now() 返回系统时钟的当前时间，其分辨率高于 std::chrono::system_clock::now() 的分辨率。即 std::chrono::high_resolution_clock::now() 能够提供高精度计时器，而 std::chrono::system_clock::now() 则提供了系统级别的时钟，其精度较低。
>
> 在使用计时器计算时间间隔的时候，应该使用 std::chrono::high_resolution_clock::now() 来获取时间戳(也有不少用std::chrono::steady_clock::now()，这俩差不多)，以尽可能提高计时器的精度。而如果只是想获取当前时间，则可以使用 std::chrono::system_clock::now()。此外system_clock是不稳定的时钟；它类似Windows系统右下角那个时钟，是系统时间。这个时钟是可以自己设置的。system_clock除了now()函数外，还提供了to_time_t()静态成员函数。用于将系统时间转换成熟悉的std::time_t类型，得到了std::time_t类型的值

---

以上是c++的写法，看到一个类似C的常用写法：（还是用c++的，这可能会因为超了范围出现负数）

```c++
#ifdef _WIN32       
#	include <windows.h>
#else
#	include <sys/time.h>
#endif

void printTime() {
	struct timeval t1, t2;
    gettimeofday(&t1,NULL);
    Sleep(1000);  // 要测试时间的代码放这里
    gettimeofday(&t2,NULL);
    double timeuse = (t2.tv_sec - t1.tv_sec) + (double)(t2.tv_usec - t1.tv_usec)/1000.0;
    std::cout << "time: " << timeuse << "ms" << std::endl;
}
```

---

当前本地时间戳的格式化：（上面有讲的比较细，这里总结一下）

- linux

  ```c++
  #include <iostream>
  #include <ctime>
  
  int main() {
      std::tm time_info{};
      std::time_t timestamp = std::time(nullptr);
      
      char time_str[20]{};
      // 其它格式化样式 "%Y-%m-%d %H:%M:%S"
      strftime(time_str, sizeof(time_str),"%Y%m%d_%H.%M", std::localtime(&timestamp));
      std::cout << time_str << std::endl;
      return 0;
  }
  ```

  注：win下，用 localtime_s 替换掉 std::localtime 即可。

## 06. exit(0)

​	c++程序在执行到这里的时候就会退出，exit(int_Code);里面必须要给一个int状态码，一般给0，然后程序结束后`echo $?`得到的就是0，代表正常；若是exit(-1)，程序结束后得到的就是255,代表异常，自己拿捏

## 07. 头文件导入区别

C/C++中 ==#include<>== 和 ==#include ""== 的区别

总结，其实就是关于是否搜索当前目录的问题。

首先明确，预处理器搜索的顺序永远都是：

> （当前文件所在目录）--> 编译选项-I指定的目录 --> 默认的标准库目录

只是括号里的目录不一定或搜。

- #include "" 按照上面的顺序依次去搜索头文件，一旦搜到就不继续往下搜了，意味着如果用户目录下和标准库目录下有同名文件，会使用用户目录下的文件(这也是为什么自己写的头文件最好用这种方式导入)
- #include <> 不搜索第一个部分，即它不会搜当前文件所在目录，后面两个的搜索顺序是不变的。

### 头文件说明

说明：

​	C++标准库中除了定义C++语言特有的功能外，也兼容了C语言的标准库。C语言的头文件形如name.h,C+则将这些文件命名为cname。也就是去掉了.h后缀，而在文件名name之前添加了字母c,这里的c表示这是一个属于C语言标准库的头文件。
​	因此,cctype头文件和 ctype.h头文件的内容是一样的,只不过从命名规范上来讲更符合C++语言的要求。特别的,在名为cname的头文件中定义的名字从属于命名空间std，而定义在名为.h的头文件中的则不然。
​	一般来说，C+程序应该使用名为cname的头文件而不使用name.h的形式，标准库中的名字总能在命名空间std中找到。如果使用.h形式的头文件，程序员就不得不时刻牢记哪些是从C语言那儿继承过来的,哪些又是C++语言所独有的。

cctype头文件中的函数：

```c++
std::string s1 = "hello 123 world!!!";

decltype(s1.size()) count = 0;
for (auto &c : s1) {   // 注意这里是引用就会修改
	std::cout << typeid(c).name() << std::endl;   // 类型是char，所以如果要修改，一定是：
    c = 'X';   // 注意必须是单引号，
    
	if (std::ispunct(c)) {   // 上面一定有导入了<cctype> ，才能有std::ispunct()这些
		++count;
	}
	c = std::toupper(c);   // 好像不要<cctype>，也行，前面不加std::就行
}
std::cout << count << std::endl;  // 3 个标点符号
std::cout << s1 << std::endl;  // 把字母都变成大写了
```

> ​				表3.3:cctype头文件中的函数（c只能是字符）
>
> - std::isalnum(c)    // 当c是字母或数字时为真
>
> - std::isalpha(c)    // 当c是字母时为真
>
> - std::iscntrl(c)     // 当c是控制字符时为真
>
> - std::isdigit(c)    // 当c是数字时为真
>
> - std::isgraph(c)    // 当c不是空格但可打印时为真
>
> - std::islower(c)    // 当c是小写字母时为真
>
> - std::isprint(c)    // 当c是可打印字符时为真（即c是空格或c具有可视形式)
>
> - std::ispunct(c)   // 当c是标点符号时为真(即c不是控制字符、数字、字母、可打印空白中的一种)
>
> - ==std::isspace(c)==     // 当c是空白时为真（即c是空格、横向制表符、纵向制表符、回车符、换行符、进纸符中的一种)（用来去除空格）
>
>   - ```c++
>     std::vector<std::string> classNames;
>     // 一行一个类的名字，有些类万一中间有空格，就会有问题，这里把空格去掉
>     std::ifstream ifs("C:\\Users\\Administrator\\Downloads\\toolsTable.txt");
>     if (ifs.is_open()) {
>     	std::string line;
>     	while (std::getline(ifs, line)) {
>     		std::string temp;
>     		std::copy_if(line.cbegin(), line.cend(), std::back_inserter(temp),
>     			[](const char c) { return !std::isspace(c);  });
>
>     		classNames.push_back(temp);
>     	}
>     	ifs.close();
>     }
>     ```
>
> - std::isupper(c)     // 当c是大写字母时为真
>
> - std::isxdigit(c)    // 当c是十六进制数字时为真
>
> - std::tolower(c)    // 如果c是大写字母，输出对应的小写字母:否则原样输出c
>
> - std::toupper(c)    // 如果c是小写字母，输出对应的大写字母;否则原样输出c
>
> - std::isblank(c)    // 字符c是空格(好像跟上面isspace一样的)

## 08. sizeof()跟strlen()的区别

​	为了兼容linux,若是要使用strlen()函数，必须导入头文件`<cstring>`(vs中不导不会报错，但是linux会)，这是c版本`<string.h>`的c++版(注意不是c++的`<string>`);

​	sizeof()跟strlen()的区别(对c风格的字符串)：==sizeof是会把字符串后面的空字符-`\0`(是零)算进去，所以值会比strlen得到的值大1==。

```c++
#include <iostream>
#include <ctring>     // 注意这个头文件
int main() {
    // 还可以这样定义c风格字符串
    const char *efg = "world";   // 必须要有const
	std::cout << efg << std::endl;  // world
    
	char abc[] = "hello";
	// sizeof 会包含后面的 \0 所以就是6个值
	std::cout << sizeof(abc) << std::endl;  // 6
	std::cout << std::strlen(abc) << std::endl;  // 5
	std::cout << strlen(abc) << std::endl;  // 5
    // 这两行都是，但是照顾前面头文件的约定，还是使用std::strlen
    
    char ca[] = {'c', '+', '+', '\0'};
	std::cout << sizeof(ca) << std::endl;  // 4
	std::cout << strlen(ca) << std::endl;  // 3
}
```

对c++而言，是会把c++风格的字符串看做容器那种，所以：

```c++
std::string xyz = "hello";
std::cout << sizeof(xyz) << std::endl;  // 32 (不知道值为什么32)
// 下面这两行都是错的，
//std::cout << std::strlen(xyz) << std::endl; 
//std::cout << strlen(xyz) << std::endl;  // c++的string，不能用c的方法——strlen
```

总结：primer c++书推荐尽量不要用c的字符串，会有很多潜在危险

***

c风格的字符串一定是需要空字符串`\0`，不然就会出现意料之外，如下：

```c++
const char ca[] = { 'h', 'e', 'l', 'l', 'e' };
const char *cp = ca;
while (*cp) {
    std::cout << *cp << std::endl;
    ++cp;
}
```

这是一般是不会退出循环的，如果没遇到`\0`是会一直打印下去的，，所以这样写的，一定要在数组最后加上`\0`，加上它，它是不会被打印出来的

​	有时候有一些历史遗留问题，是的代码里就是用的c风格的字符串，那如何把==c++的string对象转成c风格的字符串==呢，用的就是string的`c_str()`函数：

```c++
std::string s = "hello";
// const char *abc = s;  // 这是错的，不能这直接去
const char *abc = s.c_str();  // 返回的对象就是一个指针，指针的类型是 const char*

std::cout << abc << std::endl;  // hello
std::cout << *abc << std::endl; // h
std::cout << typeid(abc).name() << std::endl;

const char *ca = abc;
while (*ca) {  // 解引用到最后的空字符串0就是false,就会退出
	std::cout << *ca << std::endl;
	++ca;
}
```

## 09. 前置、后置递增/减的区别

### 左值和右值

- **左值**（l-value）**可以**出现在赋值语句的左边或者右边，比如变量；
- **右值**（r-value）**只能**出现在赋值语句的右边，比如常量。

---

前置、后置这两种运算符必须作用于左值运算对象:

- 前置版本将对象作为==左值返回==，
- 后置版本则将对象原始值的==副本作为右值返回==。

​	前置版本的递增运算符避免了不必要的工作，它把值加1后直接返回改变了的运算对象。与之相比,后置版本需要将原始值存储下来以便于返回这个未修改的内容。如果我们不需要修改前的值,那么后置版本的操作就是一种浪费。

​	在运算符重载那也是，只能重载前置，无法重载后置。

---

表达式计算的一个顺序问题：

假设vec的类型是vector<int\>, ival的类型是int，下面表达式：

- ival++ && ival   : 就是说 ival的值为真并且 ival+1 的值也为真    （这个就是有顺序的）

- vec[ival++] <= vec[ival]   // 这个表达式就是错的，因为c++并没有规定`<=`运算符两边的求值顺序，应该改为 vec[ival] <= vec[inval+1] 才能达到想要的比较效果

## 10. 一种判断输入是否结束的方法

​	案例：编写一段程序，从标准输入中读取`string`对象的序列直到连续出现两个相同的单词或者所有的单词都读完为止。
​	使用`while`循环一次读取一个单词，当一个单词连续出现两次时使用`break`语句终止循环。输出连续重复出现的单词，或者输出一个消息说明没有任何单词是连续重复出现的。

```c++
int main(int argc, char **argv) {
	std::string str1, str2;
	bool flag = true;
	std::cin >> str1;
	while (std::cin >> str2) {
		if (str1 == str2) {
			std::cout << "重复的单词是：" << str1 << std::endl;
			flag = false;
			break;
		}
		else {
			str1 = str2;
		}
	}
	if (flag) {   // 这个flag就是我创建的变量
		std::cout << "没有任何单词是连续出现的" << std::endl;
	}
	system("pause");
	return 0;
}
```

如上，我会创建一个变量来判断是否到最后输入完，但是有另外一种方法的：

```c++
if (std::cin.eof()) {
	std::cout << "没有任何单词是连续出现的" << std::endl;
}
```

注释：eof(end of file)判断输入是否结束，或者文件结束符，等同于ctrl+z

==在win下使用vs的while(std::cin >> a_str)，要让它结束控制台的输入，按下ctrl+z再回车就行==。

## 11. system() getchar()

system(): 此函数不仅仅是在vs中可以用，在linux下也是可用的，它代表直接调用给的shell命令，好比：（这会把那个shell了命令执行的结果打印到控制套）

```c++
#include <iostream>       // 这个是需要这个头文件的
int main() {
    const char *str = "df -h | awk '{print $2}'";
    system(str);
    return 0;
}
```

所以在linux下system("clear");也是可用的。

---

getchar(): 这个是头文件#include \<stdio.h> 中的一个函数，当程序执行到这里时会卡住，然后按回车就可以进到下一步了，所以可以用来替代system("pause");

```c++
#include <stdio.h>
int main() {
	getchar();   // 程序到这里就会卡住，按回车就会到下一步
	std::cout << "hello world" << std::endl;
	return 0;
}
```

它也是有返回值的，接收用户一个字符的输入，然后回车确认，即：

```c++
int signal = getchar();
if ((cahr) singal == 'q') {/* do something*/}
else if ((char) signal == 'c') {/* do something */} 
```

## 12. 数组引用的问题

int *arr1[10];       // 10个指针构成的数组

int (*arr1) [10];    // 指向含有10个整数的数组的指针（好像就是二维数组）

下面函数存在一个问题，

```c++
void print(const int ia[10])
{
	for (size_t i = 0; i != 10; ++i)
		cout << ia[i] << endl;
}
```

​	解答：当数组作为实参的时候，会被自动转换为指向首元素的指针，因此函数形参接受的是一个指针，如果要让这个代码成功运行(不更改也可以运行)，可以将形参改为数组的引用：

```c++
void print(const int (&ia)[10])   // 改成引用，注意加这个括号
{
	for (size_t i = 0; i != 10; ++i)
		cout << ia[i] << endl;
}
```

## 13. 递归函数的编写

编写一个递归函数，输出`vector`对象的内容

```c++
#include <iostream>
#include <vector>
using Iter = std::vector<int>::const_iterator;

void rec(Iter first, Iter end) {
	if (first != end) {
		std::cout << *first << std::endl;
		rec(++first, end);
	}
}
int main() {
	std::vector<int> v{1, 3, 5, 9, 7};
	rec(v.cbegin(), v.cend());
	system("pause");
	return 0;
}
```

注意点：

- 使用递归函数，不一定要有return语句这样来做(有return的，算阶乘的递归是最有代表性的);
- 注意上面`using`的用法，极大的简化了rec函数参数的写法;
- main函数进行调用时，13行用的cend()这些，这默认得到的就是const_iterator，只读的;
- 特别注意rec()函数定义参数传递是==值传递==，而不是引用传递，如果是`Iter &first`，那13行的写法就会报错，会说==非常量引用的初始值必须为左值==。

## 14. 预处理器

​	预处理器：确保头文件多次包含仍能安全工作，它由C++从C继承而来，预处理器是在编译之前执行的一段程序，可以部分地改变我们所写的程序，

​	之前用到了一项预处理功能`#include`，当预处理器看到#include标记时就会用制定的头文件的内容代替#include。

​	c++程序还会用到一项预处理功能的==头文件保护符==，头文件保护符依赖于==预处理变量==(过去程序还会用到一个名为NULL的预处理变量来给指针赋值，这个变量定义在cstdlib头文件中，它的值就是0)。预处理变量有两种状态：已定义和未定义。
​	`#define`指令把一个名字设定为预处理变量，另外两个指令则分别检查某个指定的预处理变量是否已经定义：`#ifdef`当且仅当变量已定义时为真，`#ifndef`当且仅当变量未定义时为真。一旦检查结果为真，则执行后续操作直至遇到`#endif`指令为止。

​	使用这些功能就能有效的防止重复包含的发生（假设a.h头文件内容如下）：

```c++
#ifndef SALES_DATA_H
#define SALES_DATA_H
#include <string>
struct Sales_data {
	int mun;
	std::string bookNO;	
};
#endif
```

​	解读（重要）:第一次包含a.h时，#ifndef的检测结果为真，那么预处理器将顺序执行后面的操作直至遇到#endif为止，那么此时预处理变量==SALES_DATA_H==(自己起的)的值将变量已定义，而且a.h也会被拷贝到我们的程序中，后面如果再一次包含a.h时，则#idndef的检查结果将为假，那么编译器将忽略#ifndef到#endif之间的部分。

​	整个程序的预处理变量包括头文件保护符必须唯一，通常的做法是基于头文件中类的名字来构建保护符的名字，以确保其唯一性，且为了避免名字冲突，一般把预处理变量名的名字全部大写。

注意：==预处理变量无视C++语言中关于作用域的规则==。

## 15. assert预处理宏、NDEBUG预处理变量

​	当应用程序编写完成准备发布时，要先屏蔽掉调式代码，就会用到两项预处理功能：==assert==和==NDEBUG==。

- assert预处理宏:
  - 所谓预处理宏就是一个预处理变量，assert宏使用一个表达式作为它的条件：==assert(expr);==,当表达式为假，assert输出信息并终止程序的执行，如果为真，assert什么也不做。
  - ==assert宏定义在#include \<cassert> 头文件==中，预处理名字由预处理器而非编译器管理，因为可以直接使用预处理名字，无需使用using声明，也不需要std::
- NDEBUG预处理变量:
  - assert的行为依赖于一个名为==NDEBUG==的预处理变量的状态，如果定义了NDEBUG，则assert什么也不做，==默认状态下没有定义NDEBUG,此时assert将执行运行时检查==。
  - 可以使用一个 #define 语句定义 NDEBUG 从而关闭调试状态，同时，很多编译器提供了一个命令行选项使我们可以定义预处理变量：
            CC -D NDEBUG main.c    # 说好像是微软的编译器
    这条命令的作用等价于在main.c文件的一开始写 #define NDEBUG  （定义了这个之后，assert就不会去执行检查了，就相当于停用了 assert）

​	通常也可以使用NDEBUG编写自己的条件调试代码，如果NDEBUG未定义，将执行#ifndef和#endif之间的代码，如果定义了NDEBUG，这些代码将忽略掉：

```c++
#define NDEBUG   // 如果有这一行，下面print函数中的代码怎么都不会执行的，没有这个才会进去执行

void print(const int a) {
#ifndef NDEBUG
	if (1 != 2) {
		std::cerr << "Error：" << __FILE__
			<< " ： in function  " << __func__
			<< "  at line" << __LINE__ << std::endl
			<< "       Complied on " << __DATE__
			<< " at " << __TIME__ << std::endl;
	}
#endif
}
int main() {
	print(3);
	return 0;
}
```

说明：编译器为每个函数都定义了`__func__`它是const char的一个静态数组，（它是用来存放函数的名字），除了c++编译器定义的`__func__`之外，预处理器还定义了一些：(这是常用的，还有别的)

> - `__FILE__`    当前文件名(绝对路径)的字符串（一般用const char* 吧）
> - `__LINE__`    当前行号（int整型）
> - `__TIME__`    文件编译时间的字符串字面值
> - `__DATE__`    文件编译日期的字符串字面值
> - `__func__` 或 `__FUNCTION__` 获取函数名

再举例OpenGL里的一个写法：

```c++
GLenum glCheckError_(const char *file, int line) {
    GLenum errorCode;
    while ((errorCode = glGetError()) != GL_NO_ERROR) {
        std::string error;
        switch (errorCode) {
            case GL_INVALID_ENUM:         error = "INVALID_ENUM"; break;
            case GL_INVALID_VALUE:        error = "INVALID_VALUE"; break;
            case GL_INVALID_OPERATION:  error = "INVALID_OPERATION"; break;
            case GL_STACK_OVERFLOW:     error = "STACK_OVERFLOW"; break;
            case GL_STACK_UNDERFLOW:    error = "STACK_UNDERFLOW"; break;
            case GL_OUT_OF_MEMORY:      error = "OUT_OF_MEMORY"; break;
            case GL_INVALID_FRAMEBUFFER_OPERATION: error = "INVALID_FRAMEBUFFER_OPERATION"; break;
        }
        std::cout << error << " | " << file << " (" << line << ")" << std::endl;
    }
    return errorCode;
}
#define glCheckError() glCheckError_(__FILE__, __LINE__)   
```

​	注：18行这种写法，这种宏很有意义。

## 16. 一种信息输出的方式

感觉就是用的宏定义，跟宏常量定义是一样的。

```c++
#define INFO_STREAM( stream ) std::cout << stream << std::endl
// 一定注意这个()括号是紧跟宏名称的，左括号左边不能有空格，还可以给多个参数
#define WARN_STREAM( stream, erroeCode ) \
	std::cout << __FILE__ << " (" << __LINE__ << " line): " << \
		stream << erroeCode <<std::endl   // 记得这结束是没有分号的（是可以用斜杠分行，还可以加上文件名、行号的提醒）

int main() {	
	INFO_STREAM("这是一条普通的提示信息");
	WARN_STREAM("这是一个警告信息", 404);
	return 0;
}
```

## 17. 一个函数提示返回类型的写法

```c++
template<typename Sequence>
auto println(Sequence const& seq) -> std::ostream& {
    for (auto const& elem : seq) 
        std::cout << elem << " ";
    return std::cout << std::endl;
}

auto myprint() -> std::string {
	return "123";
}
```

注意这个写法，auto 函数名(参数) -> 类型 {函数的实现}

就是在提示函数的返回类型

## 18. 获取文件夹里的文件

windows(vs):

- 这个遇到文件夹会回归调用，所以如果不想让其进入，就在找到文件夹时直接continue;
- 保存的仅仅是文件名，也可以保存绝对路径，在下面的else中改一下就好了;
- 当然可以加个format格式参数，就只保留想要的后缀的文件，就自己去改了。

```c++
#include <iostream>
#include <vector>
#include <string>
#include <io.h>

void getAllFiles(const std::string path, std::vector<std::string> &files) {
	// 用来存储文件信息的结构体，在头文件 <io.h>
	struct _finddata_t fileinfo;  // _finddata_t 这是一个struct类，可以不要前面的struct的

	// 网上代码用的 long hFile = 0; 在_findnext那里会报错，去看它要的参数的类型，
	intptr_t hFile = 0;  // _int64 hFile = 0;  long long hFile = 0; 三个都一样的，
	
	std::string p;  // 不能在这p(path)初始化，结果不对
	// 第一次查找
	if ((hFile = _findfirst(p.assign(path).append("\\*").c_str(), &fileinfo)) != -1) {
		do {
			// 如果找到的是文件夹
			if ((fileinfo.attrib & _A_SUBDIR)) {
				
				if (std::strcmp(fileinfo.name, ".") != 0 && std::strcmp(fileinfo.name, "..") != 0) {
					// 进入查找
					files.push_back(p.assign(path).append("\\").append(fileinfo.name));
					// 回归调用？
					GetAllFiles(p.assign(path).append("\\").append(fileinfo.name), files);
				}
			}
			// 如果找到的不是文件夹
			else {
				files.push_back(p.assign(fileinfo.name));  // 可以是保存文件名
				// 也可以是保存绝对路径
				// files.push_back(p.assign(path).append("\\").append(fileinfo.name));  
			}
		} while (_findnext(hFile, &fileinfo) == 0);
		// 结束查找
		_findclose(hFile);
	}

}

int main(int argc, char* argv[]) {
	std::string file_path = "E:\\PycharmProject\\wrench\\screwLine_demo";  
	std::vector<std::string> files_name;

	GetAllFiles(file_path, files_name);
	for (auto k : files_name) {
		std::cout << k << std::endl;
	}
	system("pause");
	return 0;
}
```

linux：

- io.h 头文件可能不兼容跨平台操作。在windows下这个头文件运行稳定，但是在linux下这个头文件不能正常运行;
- linux需要头文件\<dirent.h>;
- 这个代码不会进到所给文件夹里面，只会把给定文件夹下的文件夹名、文件名列出来，像python的os.listdir()。

```c++
#include <iostream>
// #include <string>
#include <vector>
#include <sys/types.h>
#include <dirent.h>  // linux独有的吧
#include <cstring>

void getFileName(std::string path, std::vector<std::string> &files) {
    DIR *pDir;   //  是头文件<dirent.h>的类型
    struct dirent *ptr;  // opendir、readdir这些都是头文件dirent.h
    if (!(pDir = opendir(path.c_str()))) return;   // 当路径不存在时，这里就会返回
            
    while ((ptr = readdir(pDir)) != 0) {
        // strcmp是C语言里的，只导入string,然后std::strcmp都是没有的，要<cstring>
        // 功能是比较这两个字符串是否相同，相同就会返回0，不同就是非0
        if (strcmp(ptr->d_name, ".") != 0 && strcmp(ptr->d_name, "..") != 0) {
            files.push_back(path + "/" + ptr->d_name);  // 可以只保留名字
        }
    }
    closedir(pDir);
}

int main(int argc, char* argv[]) {
    std::string file_path = "/home/songhui/1_video";
    std::vector<std::string> files_name;

    getFileName(file_path, files_name);

    for (auto iter = files_name.cbegin(); iter != files_name.cend(); ++iter) {
        std::cout << *iter << std::endl;
    }
    return 0;
}
```

下面使用openai写的，遇到文件夹要递归，且打印的是绝对路径：

```c++
#include <iostream>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>

using namespace std;

void getFiles(const char *path, char **&files, int &num){
    DIR *dir;
    struct dirent *ptr;
    if ((dir = opendir(path)) == NULL){
        perror("Open dir error...");
        exit(1);
    }
    while ((ptr = readdir(dir)) != NULL){
        if (strcmp(ptr->d_name, ".") == 0 || strcmp(ptr->d_name, "..") == 0){    //current dir OR parrent dir
            continue;
        } else if (ptr->d_type == 8){    //file
            files[num] = (char*)malloc(256);
            strcpy(files[num], path);
            strcat(files[num], ptr->d_name);
            num++;
        } else if (ptr->d_type == 4) {    //dir
            char *newPath = (char*)malloc(256);
            strcpy(newPath, path);
            strcat(newPath, ptr->d_name);
            strcat(newPath, "/");
            getFiles(newPath, files, num);
        }
    }
    closedir(dir);
}

int main(){
    const char *path = "/home/songhui/1_video/";
    char **files;
    int num = 0;
    files = (char**)malloc(256 * sizeof(char*));
    getFiles(path, files, num);
    for (int i = 0; i < num; i++){
        cout<<files[i]<<endl;
    }
    return 0;
}
```

接着上面，让它不准用using namespace std; 于是它又改了一个版本

```c++
#include <iostream>
#include <string>
#include <vector>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>

std::vector<std::string> get_filenames_in_path(const std::string &path) {
    std::vector<std::string> filenames;
    DIR *dir;
    struct dirent *ent;
    if ((dir = opendir(path.c_str())) != NULL) {
        while ((ent = readdir(dir)) != NULL) {
            std::string file_name = ent->d_name;
            if (file_name == "." || file_name == "..") {
                continue;
            }   
            std::string complete_path = path + "/" + file_name;
            if (ent->d_type == DT_DIR) {
                std::vector<std::string> sub_filenames = get_filenames_in_path(complete_path);
                filenames.insert(filenames.end(), sub_filenames.begin(), sub_filenames.end());
            } else {
                filenames.push_back(complete_path);
            }   
        }   
        closedir(dir);
    }   
    return filenames;
}

int main() {
    std::string path = "/home/songhui/1_video";
    std::vector<std::string> filenames = get_filenames_in_path(path);
    for (auto filename : filenames) {
        std::cout << filename << std::endl;
    }   
    return 0;
}
```

## 19. 格式化接收的参数&&验证文件是否存在，建文件夹

现在这种参数格式化，现在看到比较好的有三种处理方式：

- 在[c++常用库.md](./C++常用库.md)的“10. args 参数解析库”中， 还有一个类似于python的args库，也是header-only。
- 练习onnxrunner时，用map容器来处理传入参数，[代码](https://github.com/nianjiuhuiyi/Study/blob/master/onnx/main.cpp#L37)；
- 下面这里是用的opencv里的类来实现的，之前还在点云PCL库学习时，看到里面有过这种类似的。

```c++
#include <opencv2/opencv.hpp>
#include <sys/stat.h>  // 结构体stat、函数stat、mkdir、S_IRWXU 这些需要； vs有这头文件，但好像没有mkdir这函数
#include <unistd.h>   //  access、 F_OK 这些需要；这在 vs中是没有的

/*
使用实例：
a.out  --input=../datasets/test_images --bmodel=../BM1684/yolov5m6.bmodel --dev_id=0 --conf_thresh=0.5 --nms_thresh=0.5 --classnames=../datasets/coco.names

a.out --help  // 就能把对应参数使用说明打印出来
*/

int main(int argc, char** argv) {
    // 设置浮点数就正常显示，而不是以科学计数法来表示。（1c++基础.md中有更多的使用）
    std::cout.setf(std::ios::fixed);
    
	const char *keys = "{bmodel | ../../models/BM1684/yolov5s_v6.1_3output_fp32_1b.bmodel | bmodel file path}"
		"{dev_id | 0 | TPU device id}"
		"{conf_thresh | 0.001 | confidence threshold for filter boxes}"
		"{nms_thresh | 0.6 | iou threshold for nms}"
		"{help | 0 | print help information.}"
		"{input | ../../datasets/test | input path, images direction or video file path}"
		"{classnames | ../../datasets/coco.names | class names file path}"
		"{use_cpu_opt | false | accelerate cpu postprocess}";   // 这里直接换行，不需要特殊的符号（中间的默认值非必须）
    
    // 1、这样就拿到了传进来的参数（它不会检验传递的key对不对，如果传递的key不对，这里就会用默认值）
    cv::CommandLineParser parser(argc, argv, keys);
	if (parser.get<bool>("help")) {
		parser.printMessage();
		return 0;
	}
    std::string bmodel_file = parser.get<std::string>("bmodel");
	std::string input = parser.get<std::string>("input");
	int dev_id = parser.get<int>("dev_id");
	bool use_cpu_opt = parser.get<bool>("use_cpu_opt");
    
    // 2、check params （检查传的文件、文件夹路径是否存在，在1c++基础.md中，用的是文件读写，然后调用 .good()或是.is_open()来判断的，不是特别好。）
    struct stat info;    // struct stat, 以及下面的，需要头文件 #include <sys/stat.h>
	if (stat(bmodel_file.c_str(), &info) != 0) {
    	std::cout << "Cannot find valid model file." << std::endl;
    	exit(1);
  	}
    if (stat(input.c_str(), &info) != 0){     // input参数给的是一个文件夹路径（这也是检查文件夹是否存在）
    	std::cout << "Cannot find input path." << std::endl;
    	exit(1);
  	}
    // 在拿去input这个文件夹里的图片时，可以先判断一下这个文件夹(不是必须，就是把这种放这里)
    if (info.st_mode & S_IFDIR) {
    	// 然后这里用 18.获取文件夹里的文件来拿到所有图片的路径。
        // 或者用 OpenCV_C++版.md中用 cv::glob 来拿取所有图片的路径
    }
    
    // 3、检查文件夹路径是否存在，不存在去创建 
    // 3.1 这在linux下OK，vs中不行，注意它需要的头文件（不能递归创建文件夹，得一个个来）
    if (access("results", 0) != F_OK)
    	mkdir("results", S_IRWXU);
  	if (access("results/images", 0) != F_OK)
   	 	mkdir("results/images", S_IRWXU);
    // 3.2 使用c++17的新特性（vs、linux都可以用, -std=c++17） // 要头文件  #include<filesystem>
    // （centos用可能就会莫名其妙的出现 Segmentation fault，可能g++版本低了），vs2022、ubunut22.04都是OK的
    std::string save_dir = "./output/V02";   // 多级路径，单级路径都能创建
    try {
    	if (!std::filesystem::exists(save_dir)) {
        	std::filesystem::create_directories(save_dir);
        }
    }
    catch (const std::filesystem::filesystem_error &e) {
    	std::cout << "[ERROR] Error creating or checking folder: " << e.what() << std::endl;
    }
}
```

关于cv::CommandLineParser,下面是它自带的文档:

- 通过 @来指定位置参数；位置参数可以用 parser.get\<String\>(0)传索引的方式, 或get\<String\>("@image1")这种方式都可以
- "{help h usage ? |      | print this message   }"，传参 -h --help --? -? -usage 都是可以的，然后if (parser.get\<bool\>("usage")),代码里无论是写的help还是usage都是可以的。

```c++
/*
### Keys syntax

The keys parameter is a string containing several blocks, each one is enclosed in curly braces and
describes one argument. Each argument contains three parts separated by the `|` symbol:

-# argument names is a space-separated list of option synonyms (to mark argument as positional, prefix it with the `@` symbol)
-# default value will be used if the argument was not provided (can be empty)
-# help message (can be empty)

For example:

@code{.cpp}
    const String keys =
        "{help h usage ? |      | print this message   }"
        "{@image1        |      | image1 for compare   }"
        "{@image2        |<none>| image2 for compare   }"
        "{@repeat        |1     | number               }"
        "{path           |.     | path to file         }"
        "{fps            | -1.0 | fps for output video }"
        "{N count        |100   | count of objects     }"
        "{ts timestamp   |      | use time stamp       }"
        ;
}
@endcode

Note that there are no default values for `help` and `timestamp` so we can check their presence using the `has()` method.
Arguments with default values are considered to be always present. Use the `get()` method in these cases to check their
actual value instead.

String keys like `get<String>("@image1")` return the empty string `""` by default - even with an empty default value.
Use the special `<none>` default value to enforce that the returned string must not be empty. (like in `get<String>("@image2")`)

### Usage

For the described keys:

@code{.sh}
    # Good call (3 positional parameters: image1, image2 and repeat; N is 200, ts is true)
    $ ./app -N=200 1.png 2.jpg 19 -ts

    # Bad call
    $ ./app -fps=aaa
    ERRORS:
    Parameter 'fps': can not convert: [aaa] to [double]
@endcode
 */
// 不知道咋回事，我乱传参数，还是无法进到这个判断里，即始终认为是正确的
if (!parser.check()) {
    parser.printErrors();
    return 0;
}
```

## 20. 多线程demo

opencv的一个多线程demo去看[OpenCV_C++版.md](../opencv/OpenCV_C++版.md)。

### 2、海康相机的示例

​	它这就是通过按enter来结束进程，然后也是在主线程中用while循环来卡住主线程。（应该是C的多线程）

```c++
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <pthread.h>   // 应该是C的多线程
#include "MvCameraControl.h"

#include <iostream>
#include <chrono>
#include <thread>

bool g_bExit = false;

// 等待用户输入enter键来结束取流或结束程序
void PressEnterToExit(void) {
    int c;
    while ( (c = getchar()) != '\n' && c != EOF );
    fprintf( stderr, "\nPress enter to exit.\n");
    while( getchar() != '\n');
    g_bExit = true;
    sleep(1);
}

bool PrintDeviceInfo(MV_CC_DEVICE_INFO* pstMVDevInfo) {
    if (NULL == pstMVDevInfo) {
        printf("The Pointer of pstMVDevInfo is NULL!\n");
        return false;
    }
    if (pstMVDevInfo->nTLayerType == MV_GIGE_DEVICE) {
        int nIp1 = ((pstMVDevInfo->SpecialInfo.stGigEInfo.nCurrentIp & 0xff000000) >> 24);
        int nIp2 = ((pstMVDevInfo->SpecialInfo.stGigEInfo.nCurrentIp & 0x00ff0000) >> 16);
        int nIp3 = ((pstMVDevInfo->SpecialInfo.stGigEInfo.nCurrentIp & 0x0000ff00) >> 8);
        int nIp4 = (pstMVDevInfo->SpecialInfo.stGigEInfo.nCurrentIp & 0x000000ff);

        // ch:打印当前相机ip和用户自定义名字
        printf("Device Model Name: %s\n", pstMVDevInfo->SpecialInfo.stGigEInfo.chModelName);
        printf("CurrentIp: %d.%d.%d.%d\n" , nIp1, nIp2, nIp3, nIp4);
        printf("UserDefinedName: %s\n\n" , pstMVDevInfo->SpecialInfo.stGigEInfo.chUserDefinedName);
    }
    else if (pstMVDevInfo->nTLayerType == MV_USB_DEVICE) {
        printf("Device Model Name: %s\n", pstMVDevInfo->SpecialInfo.stUsb3VInfo.chModelName);
        printf("UserDefinedName: %s\n\n", pstMVDevInfo->SpecialInfo.stUsb3VInfo.chUserDefinedName);
    }
    else {
        printf("Not support.\n");
    }
    return true;
}

static void* WorkThread(void* pUser) {
    int nRet = MV_OK;

    // ch:获取数据包大小
    MVCC_INTVALUE stParam;
    memset(&stParam, 0, sizeof(MVCC_INTVALUE));
    nRet = MV_CC_GetIntValue(pUser, "PayloadSize", &stParam);
    if (MV_OK != nRet) {
        printf("Get PayloadSize fail! nRet [0x%x]\n", nRet);
        return NULL;
    }

    MV_FRAME_OUT_INFO_EX stImageInfo = {0};
    memset(&stImageInfo, 0, sizeof(MV_FRAME_OUT_INFO_EX));
    unsigned char * pData = (unsigned char *)malloc(sizeof(unsigned char) * stParam.nCurValue);
    if (NULL == pData) return NULL;

    unsigned int nDataSize = stParam.nCurValue;

    while(1) {
        auto begin = std::chrono::high_resolution_clock::now();
        nRet = MV_CC_GetOneFrameTimeout(pUser, pData, nDataSize, &stImageInfo, 1000);
        auto end = std::chrono::high_resolution_clock::now();
        std::cout << "用时: " << std::chrono::duration_cast<std::chrono::milliseconds>(end - begin).count() << "ms" << std::endl;
        /* 其它地方看的写法，放这吧（这就只能得到s，耗时很长的才用这吧）
        	std::chrono::duration<double> diff = end - start;
        	std::cout << "Cost time : " << diff.count() << "s" << std::endl;
        */

        if (nRet == MV_OK) {
            // printf("GetOneFrame, Width[%d], Height[%d], nFrameNum[%d]\n", 
            //     stImageInfo.nWidth, stImageInfo.nHeight, stImageInfo.nFrameNum);
            std::this_thread::sleep_for(std::chrono::milliseconds(150));
            printf("OK le\n");
        }
        else {
            printf("No data[%x]\n", nRet);
        }
        if (g_bExit) break;
    }

    free(pData);
    return 0;
}

int main() {
    int nRet = MV_OK;
    void* handle = NULL;

    do 
    {
        MV_CC_DEVICE_INFO_LIST stDeviceList;
        memset(&stDeviceList, 0, sizeof(MV_CC_DEVICE_INFO_LIST));

        // 枚举设备
        nRet = MV_CC_EnumDevices(MV_GIGE_DEVICE | MV_USB_DEVICE, &stDeviceList);
        if (MV_OK != nRet) {
            printf("MV_CC_EnumDevices fail! nRet [%x]\n", nRet);
            break;
        }

        if (stDeviceList.nDeviceNum > 0) {
            for (int i = 0; i < stDeviceList.nDeviceNum; i++) {
                printf("[device %d]:\n", i);
                MV_CC_DEVICE_INFO* pDeviceInfo = stDeviceList.pDeviceInfo[i];
                if (NULL == pDeviceInfo) break;
                PrintDeviceInfo(pDeviceInfo);            
            }  
        } 
        else {
            printf("Find No Devices!\n");
            break;
        }

        printf("Please Intput camera index: ");
        unsigned int nIndex = 0;
        scanf("%d", &nIndex);

        if (nIndex >= stDeviceList.nDeviceNum) {
            printf("Intput error!\n");
            break;
        }

        // 选择设备并创建句柄
        nRet = MV_CC_CreateHandle(&handle, stDeviceList.pDeviceInfo[nIndex]);
        if (MV_OK != nRet) {
            printf("MV_CC_CreateHandle fail! nRet [%x]\n", nRet);
            break;
        }

        // 打开设备
        nRet = MV_CC_OpenDevice(handle);
        if (MV_OK != nRet) {
            printf("MV_CC_OpenDevice fail! nRet [%x]\n", nRet);
            break;
        }
		
        // ch:探测网络最佳包大小(只对GigE相机有效) 
        if (stDeviceList.pDeviceInfo[nIndex]->nTLayerType == MV_GIGE_DEVICE) {
            int nPacketSize = MV_CC_GetOptimalPacketSize(handle);
            if (nPacketSize > 0) {
                nRet = MV_CC_SetIntValue(handle,"GevSCPSPacketSize",nPacketSize);
                if(nRet != MV_OK) {
                    printf("Warning: Set Packet Size fail nRet [0x%x]!\n", nRet);
                }
            }
            else {
                printf("Warning: Get Packet Size fail nRet [0x%x]!\n", nPacketSize);
            }
        }
		
        // 设置触发模式为off
        nRet = MV_CC_SetEnumValue(handle, "TriggerMode", 0);
        if (MV_OK != nRet) {
            printf("MV_CC_SetTriggerMode fail! nRet [%x]\n", nRet);
            break;
        }

        // 开始取流
        nRet = MV_CC_StartGrabbing(handle);
        if (MV_OK != nRet) {
            printf("MV_CC_StartGrabbing fail! nRet [%x]\n", nRet);
            break;
        }

        pthread_t nThreadID;
        nRet = pthread_create(&nThreadID, NULL ,WorkThread , handle);
        if (nRet != 0) {
            printf("thread create failed.ret = %d\n",nRet);
            break;
        }

        PressEnterToExit();

        // 停止取流
        nRet = MV_CC_StopGrabbing(handle);
        if (MV_OK != nRet) {
            printf("MV_CC_StopGrabbing fail! nRet [%x]\n", nRet);
            break;
        }

        // 关闭设备
        nRet = MV_CC_CloseDevice(handle);
        if (MV_OK != nRet) {
            printf("MV_CC_CloseDevice fail! nRet [%x]\n", nRet);
            break;
        }

        // 销毁句柄
        nRet = MV_CC_DestroyHandle(handle);
        if (MV_OK != nRet) {
            printf("MV_CC_DestroyHandle fail! nRet [%x]\n", nRet);
            break;
        }
    } while (0);

    if (nRet != MV_OK) {
        if (handle != NULL) {
            MV_CC_DestroyHandle(handle);
            handle = NULL;
        }
    }

    printf("exit\n");
    return 0;
}
```

## 21. memset|以及花括号初始化

​	memset一般用来初始化，海康的相机就用到比较多，可看这[教程](https://zhuanlan.zhihu.com/p/551171844)、[这](https://cloud.tencent.com/developer/article/1693530?from=15425)。比如初始化数组（上面第20点的demo代码里就可以看到memset的多处使用）：

​	memset()函数，称为按字节赋值函数，使用时需要加头文件 #include\<cstring>或者#include<string.h>。通常有两个用法：

（1）用来给整形数组整体赋值为0或者-1；

（2）给字符数组整体赋值

```c++
#include <cstring>

int a[100];
mmset(a, 0, sizeof(a));   // 前面传入的是指针，海康的sdk，就用的比较多，它主要是用来初始化它的一些自定义struct
// 还有更简易的写法：
int a[10]={0};   // 其本质是将 0赋值给a[0],其余元素自动填充为0 
// （接着上面：所以 int a[10] = {5}; 除了第一个a[0]是5，其它的都是0而不是5）
// 还有这种列表初始化写法 int a[10]{};  但还是用上面那种初始化吧。
```

```
// std::tm在 <ctime> 或 <chrono> 库中；std::tm是标准库中定义的时间结构体
// 在使用时一定要将这个结构体初始化，如下，而不仅仅是 std::tm time_info;
std::tm time_info{};
```

- {}是C++11及以后版本的初始化语法，称为统一初始化或列表初始化。它将成员变量按照花括号内的初始化顺序和方式进行初始化。如果没有提供初始值，那么对应的花括号内的成员就会用默认值进行初始化。
- 会将 `time_info` 的所有成员变量初始化为0或false（如果成员是布尔类型）

## 22. 实现 "_".join()

具体去看[3c++提高编程.md](./3 c++提高编程.md)中“5.5.1 accumulate”中实现。

然后要实现python中的map()函数对列表了每个函数做一系列操作，可以去看“5.1.2 transform”

## 23. 格式化代码clang-format

ubuntu安装：sudo apt install clang-format  # 作为命令行使用

参考：每个参数说明，怎么生成，[教程1](https://blog.csdn.net/Lucy_stone/article/details/135184576)。[这个](https://www.cnblogs.com/baiweituyou/p/17582013.html)也放这里参考吧。

基本使用：

- clang-format --version
- clang-format -i main.cp

格式化指定路径下所有c++代码的脚本，"format.sh"：

```shell
#!/usr/bin/env bash

# 指定文件夹路径
DIR="./src"

# 这里还可以添加其它类型的文件
find $DIR -name '*.cpp' -o -name '*.h' -o -name "*.hpp" | while read -r file
do
    clang-format -i "$file"
done
```

这个脚本的执行路径里一般要有一个说明自己要格式化的说明文件，“.clang-format” ： # 非必须，下面是我现在在用的，然后带有“# my”的是我自己在默认上修改了的，每个设置的说明，在[教程1](https://blog.csdn.net/Lucy_stone/article/details/135184576)都是有说明。

```
---
Language:        Cpp
BasedOnStyle:  LLVM

AccessModifierOffset: -4
AlignAfterOpenBracket: BlockIndent
AlignArrayOfStructures: Left
AlignConsecutiveMacros: None
AlignConsecutiveAssignments: None
AlignConsecutiveBitFields: None
AlignConsecutiveDeclarations: None
AlignEscapedNewlines: Right
AlignOperands:   Align
AlignTrailingComments: true
AllowAllArgumentsOnNextLine: true
AllowAllParametersOfDeclarationOnNextLine: true
AllowShortEnumsOnASingleLine: true
AllowShortBlocksOnASingleLine: Never
AllowShortCaseLabelsOnASingleLine: false
AllowShortFunctionsOnASingleLine: All
AllowShortLambdasOnASingleLine: All
AllowShortIfStatementsOnASingleLine: Never
AllowShortLoopsOnASingleLine: false
AlwaysBreakAfterDefinitionReturnType: None
AlwaysBreakAfterReturnType: None
AlwaysBreakBeforeMultilineStrings: false
AlwaysBreakTemplateDeclarations: MultiLine
AttributeMacros:
  - __capability
BinPackArguments: true
BinPackParameters: true
BraceWrapping:
  AfterCaseLabel:  false
  AfterClass:      false
  AfterControlStatement: Never
  AfterEnum:       false
  AfterFunction:   false
  AfterNamespace:  false
  AfterObjCDeclaration: false
  AfterStruct:     false
  AfterUnion:      false
  AfterExternBlock: false
  BeforeCatch:     true         # my
  BeforeElse:      true        # my  让 else if 另起一行
  BeforeLambdaBody: false
  BeforeWhile:     false
  IndentBraces:    false
  SplitEmptyFunction: true
  SplitEmptyRecord: true
  SplitEmptyNamespace: true
BreakBeforeBinaryOperators: None
BreakBeforeConceptDeclarations: true
# BreakBeforeBraces: Attach
BreakBeforeBraces: Custom  # 这样BraceWrapping里面才会生效
BreakBeforeInheritanceComma: false
BreakInheritanceList: BeforeColon
BreakBeforeTernaryOperators: true
BreakConstructorInitializersBeforeComma: false
BreakConstructorInitializers: BeforeColon
BreakAfterJavaFieldAnnotations: false
BreakStringLiterals: true
ColumnLimit:     0    # my
CommentPragmas:  '^ IWYU pragma:'
QualifierAlignment: Leave
CompactNamespaces: false
ConstructorInitializerIndentWidth: 4
ContinuationIndentWidth: 4
Cpp11BracedListStyle: true
DeriveLineEnding: true
DerivePointerAlignment: false
DisableFormat:   false
EmptyLineAfterAccessModifier: Never
EmptyLineBeforeAccessModifier: LogicalBlock
ExperimentalAutoDetectBinPacking: false
PackConstructorInitializers: BinPack
BasedOnStyle:    ''
ConstructorInitializerAllOnOneLineOrOnePerLine: false
AllowAllConstructorInitializersOnNextLine: true
FixNamespaceComments: true
ForEachMacros:
  - foreach
  - Q_FOREACH
  - BOOST_FOREACH
IfMacros:
  - KJ_IF_MAYBE
IncludeBlocks:   Preserve
IncludeCategories:
  - Regex:           '^"(llvm|llvm-c|clang|clang-c)/'
    Priority:        2
    SortPriority:    0
    CaseSensitive:   false
  - Regex:           '^(<|"(gtest|gmock|isl|json)/)'
    Priority:        3
    SortPriority:    0
    CaseSensitive:   false
  - Regex:           '.*'
    Priority:        1
    SortPriority:    0
    CaseSensitive:   false
IncludeIsMainRegex: '(Test)?$'
IncludeIsMainSourceRegex: ''
IndentAccessModifiers: false
IndentCaseLabels: false
IndentCaseBlocks: false
IndentGotoLabels: true
IndentPPDirectives: None
IndentExternBlock: AfterExternBlock
IndentRequires:  false
IndentWidth:     4   # 缩进宽度
IndentWrappedFunctionNames: false
InsertTrailingCommas: None
JavaScriptQuotes: Leave
JavaScriptWrapImports: true
KeepEmptyLinesAtTheStartOfBlocks: true
LambdaBodyIndentation: Signature
MacroBlockBegin: ''
MacroBlockEnd:   ''
MaxEmptyLinesToKeep: 1
NamespaceIndentation: None
ObjCBinPackProtocolList: Auto
ObjCBlockIndentWidth: 2
ObjCBreakBeforeNestedBlockParam: true
ObjCSpaceAfterProperty: false
ObjCSpaceBeforeProtocolList: true
PenaltyBreakAssignment: 2
PenaltyBreakBeforeFirstCallParameter: 19
PenaltyBreakComment: 300
PenaltyBreakFirstLessLess: 120
PenaltyBreakOpenParenthesis: 0
PenaltyBreakString: 1000
PenaltyBreakTemplateDeclaration: 10
PenaltyExcessCharacter: 1000000
PenaltyReturnTypeOnItsOwnLine: 60
PenaltyIndentedWhitespace: 0
PointerAlignment: Right
PPIndentWidth:   -1
ReferenceAlignment: Pointer
ReflowComments:  true
RemoveBracesLLVM: false
SeparateDefinitionBlocks: Leave
ShortNamespaceLines: 1
SortIncludes:    Never   # my 不去改变头文件的排序
SortJavaStaticImport: Before
SortUsingDeclarations: true
SpaceAfterCStyleCast: false
SpaceAfterLogicalNot: false
SpaceAfterTemplateKeyword: true
SpaceBeforeAssignmentOperators: true
SpaceBeforeCaseColon: false
SpaceBeforeCpp11BracedList: false
SpaceBeforeCtorInitializerColon: true
SpaceBeforeInheritanceColon: true
SpaceBeforeParens: ControlStatements
SpaceBeforeParensOptions:
  AfterControlStatements: true
  AfterForeachMacros: true
  AfterFunctionDefinitionName: false
  AfterFunctionDeclarationName: false
  AfterIfMacros:   true
  AfterOverloadedOperator: false
  BeforeNonEmptyParentheses: false
SpaceAroundPointerQualifiers: Default
SpaceBeforeRangeBasedForLoopColon: true
SpaceInEmptyBlock: false
SpaceInEmptyParentheses: false
SpacesBeforeTrailingComments: 1
SpacesInAngles:  Never
SpacesInConditionalStatement: false
SpacesInContainerLiterals: true
SpacesInCStyleCastParentheses: false
SpacesInLineCommentPrefix:
  Minimum:         1
  Maximum:         -1
SpacesInParentheses: false
SpacesInSquareBrackets: false
SpaceBeforeSquareBrackets: false
BitFieldColonSpacing: Both
Standard:        Latest
StatementAttributeLikeMacros:
  - Q_EMIT
StatementMacros:
  - Q_UNUSED
  - QT_REQUIRE_VERSION
TabWidth:        8
UseCRLF:         false
UseTab:          Never
WhitespaceSensitiveMacros:
  - STRINGIZE
  - PP_STRINGIZE
  - BOOST_PP_STRINGIZE
  - NS_SWIFT_NAME
  - CF_SWIFT_NAME
...


```

## 24. 处理中断信号

每次直接ctrl+c或者kill程序时，特别是服务，或是一直跑的程序，程序是无法安全退出的，就要用上信号机制。

这在rk3588上写受电弓代码、写语音识别代码都用到了，这里简单再写一下。（cpp-httplib库的demo里也写到了）

```c++
#include <iostream>
#include <thread>
#include <atomic>
#include <csignal>   // 要这个头文件

static std::atomic<bool> keepRuning(true);

static void signalHandler(int signum) {
    std::cout << "Interrupt signal ({" << signum << "}) received.") << std::endl;
    keepRuning.exchange(false);
    // 这里可以添加更多清理代码，比如等待线程结束等
}


void run_server() {
    while (keepRuning) {
    	std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
}

int main() {
	// 注册信号处理程序 （ std::signal 也是一个意思 ）(这样就能让程序完全正常退出)
    signal(SIGINT, signalHandler);  // ctrl + c
    signal(SIGTERM, signalHandler);  // kill PID
    
	// 模拟的服务线程一直在运行
	std::thread server_thread(run_server);
	
	// 用这种方式来保证主线程一直在运行
	while (keepRuning) {
    	std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    
    if (server_thread.joinable()) {
        server_thread.join();
    }
	std::cout << "已经正常退出." << std::endl;
	return 0;
}
```

