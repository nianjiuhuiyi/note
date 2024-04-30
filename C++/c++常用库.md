注意参考==各类库的编译.md== 

这篇[文章](https://zhuanlan.zhihu.com/p/651936903)对整体的库有一个整理，有需求时可以去参考一下。

## 01. fmt 让输出带格式的库

​	[fmt](https://github.com/fmtlib/fmt)是一个c++格式化的库，挺好用的，也比较简单，源码下载下来，轻松就能编译出来，然后在测试时，直接用cmake中的find_package没搞定，就直接添加的搜索路径：
CMakeLists.txt：

```cmake
cmake_minimum_required(VERSION 3.1)
project(demo)
set(CMAKE_BUILD_TYPE Release)

include_directories(/opt/fmt-9.0.0/include)
link_directories(/opt/fmt-9.0.0/lib64)

add_executable(demo main.cpp)
target_link_libraries(demo fmt)
```

demo.cpp：（这个在它的官网里也是有的）

```c++
#include <string>
#include <vector>
#include <fmt/core.h>
#include <fmt/chrono.h>
#include <fmt/ranges.h>
#include <fmt/color.h>

int main() {
	fmt::print("hello world\n");

	std::string s = fmt::format("The answer is {}.\n", 42);
	fmt::print(s);

	// 1.格式化时间
	using namespace std::literals::chrono_literals;
	fmt::print("Default format: {} {} \n", 42s, 100ms);
	fmt::print("strftime-like format: {:%H:%M:%S}\n", 3h + 15min + 30s);

	// 2.直接打印vector
	std::vector<int> v = { 1, 2, 3 };
	fmt::print("{}\n", v);
    
    // 
    fmt::print("Hello, {}!", "world");  // 类 Python 的语法风格
	fmt::printf("Hello, %s!", "world"); 

	// 3.带颜色、格式的输出
	fmt::print(fg(fmt::color::crimson) | fmt::emphasis::bold,
		"Hello, {}!\n", "world");
	fmt::print(fg(fmt::color::floral_white) | bg(fmt::color::slate_gray) |
		fmt::emphasis::underline, "Hello, {}!\n", "мир");
	fmt::print(fg(fmt::color::steel_blue) | fmt::emphasis::italic,
		"Hello, {}!\n", "世界");

	return 0;
}
```

## 02. Eigen 矩阵运算

gitlab[开源地址](https://gitlab.com/libeigen/eigen)。到这个[页面](https://eigen.tuxfamily.org/index.php?title=Main_Page)去下载一个版本。

使用方式：

- 方式一：它是头文件类型的，添加头文件路径就可以直接使用了。
  windows上，直接把.zip压缩包解压放一个地方，比如为D:\lib\eigen-3.4.0，
  然后直接在C/C++->常规->附加包含目录 把上面的路径添加进去就好了

- 方式二：make && make install 的方式
  
> git clone https://gitlab.com/libeigen/eigen --branch 3.4
  >
  > mkdir eigen_build  && cd eigen_build
  >
  > cmake -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda/ .. 
  >
  > make && make install    # 这是安装在系统默认位置，这个库就默认位置用吧，版本影响不会太大，就用3.4最新的。

  注：cmake时这样指定使用cuda，才比较好，主要是在编译三维重建项目“openMVS”时，没这样指定，make编译出了很多问题，比如这样“no suitable constructor exists to convert from "float" to "Eigen::half"”的错误，像上面指定了cuda路径的才不报错。

常用头文件：它一些矩阵常用性质和方法，[看这](https://zhuanlan.zhihu.com/p/414383770)。

| Module      | Header file                  | Contents                                               |
| ----------- | ---------------------------- | ------------------------------------------------------ |
| Core        | #include <Eigen/Core>        | Matrix和Array类，基础的线性代数运算和数组操作          |
| Geometry    | #include <Eigen/Geometry>    | 旋转、平移、缩放、2维和3维的各种变换                   |
| LU          | #include <Eigen/LU>          | 求逆，行列式，LU分解                                   |
| Cholesky    | #include <Eigen/Cholesky>    | 豪斯霍尔德变换，用于线性代数运算                       |
| SVD         | #include <Eigen/SVD>         | SVD分解                                                |
| QR          | #include <Eigen/QR>          | QR分解                                                 |
| Eigenvalues | #include <Eigen/Eigenvalues> | 特征值，特诊向量分解                                   |
| Sparse      | #include <Eigen/Spare>       | 稀疏矩阵的存储和一些基本的线性运算                     |
| 稠密矩阵    | #include <Eigen/Dense>       | 包含了Core/Geometry/LU/Cholesky/SVDIQR/Eigenvalues模块 |
| 矩阵        | #include <Eigen/Eigen>       | 包含了Dense和Sparse（整合库）                          |

使用demo：

- 初始化一个单位矩阵：Eigen::Matrix4f matrix = Eigen::Matrix4f::Identity();

```c++
#include <iostream>
#include <cmath>
#include <Eigen/Core>
/*
官方的关于vector和matrix的文档：
https://eigen.tuxfamily.org/dox/group__TutorialMatrixArithmetic.html
*/
int main() {
	//std::cout << std::sin(30.0 / 180.0*acos(-1)) << std::endl;
	//Eigen::Vector3f v(1.0f, 2.0f, 3.0f);
	
	//Eigen::Matrix3f i, j;
	//i << 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0;   // 注意只能这种初始化方式
	//j << 2.0, 3.0, 1.0, 4.0, 6.0, 5.0, 9.0, 7.0, 8.0;
	// 或者 MatrixXf a(2,3); a << 1, 2, 3, 4, 5, 6;

	// 题：将点p逆时针旋转45°
	Eigen::Vector3f p(2.0f, 1.0f, 1.0f);  // 默认打印出来形式是列向量，但运算时还是看作1行2列

	// 逆时针旋转45°
	float angle = 45.f / 180.f * std::acos(-1);  // std::acos(-1)为π，这是三角函数必须给弧度制
	// 方式一：原理 https://blog.csdn.net/whocarea/article/details/85706464
	Eigen::Vector2f out;
	out[0] = p[0] * std::cos(angle) - p[1] * std::sin(angle);
	out[1] = p[0] * std::sin(angle) + p[1] * std::cos(angle);
	std::cout << out << std::endl;

	// 方式二：其实是一样的，就是将上面操作弄成了一个矩阵  (这个额外加了一点，使用了齐次坐标)
	Eigen::Matrix3f mat;
	mat << std::cos(angle), -std::sin(angle), 1.f, std::sin(angle), std::cos(angle), 2.f, 0.f, 0.f, 1.f;
	std::cout << mat * p << std::endl;  // 这顺序不能变，就是对上面列向量使用的的进一步说明
}
```

上面是直接按照固定的把旋转矩阵写出来，不好写，按照下面这样来：**平移、缩放、旋转**

```c++
#include <iostream>
#include <Eigen/Core>
#include <Eigen/Geometry>

int main() {
	// 1、定义一个4*4的单位矩阵
	Eigen::Matrix4f matrix = Eigen::Matrix4f::Identity();
	// 2、仿射变换，需要头文件<Eigen/Geometry>
	Eigen::Affine3f trans = Eigen::Affine3f::Identity();   
	// （2.1）在X轴上定义一个2.5米的平移
	trans.translation() << 2.5, 0.0, 0.0;   
    // （2.1）要缩放的话，可以
    trans.scale(0.5);  // 所有轴整体缩放，每个轴不同的值还不知道
	// （2.2）在Z轴上旋转45度；X轴的话就是Eigen::Vector3f::UnitX();
	trans.rotate(Eigen::AngleAxisf(45, Eigen::Vector3f::UnitZ()));
	// （2.3）得到旋转矩阵
	matrix = trans * matrix;

	std::cout << matrix << std::endl;
	system("pause");
	return 0;
}
```

注：2.2中，可以绕几个轴旋转，括号里就这么写:
Eigen::AngleAxisf(45, Eigen::Vector3f::UnitZ()) * Eigen::AngleAxisf(60, Eigen::Vector3f::UnitX())

---

给元素开方：

```c++
#include <iostream>
#include <Eigen/Dense>
int main(int argc, char* argv[]) {
	Eigen::MatrixXd bigMat(1000, 1000);   // 注意这种Xd、Xf这种写法

	Eigen::Matrix3d mat;
	mat << 4, 9, 16, 25, 36, 49, 64, 81, 100;
    // 注意：使用array()函数将matrix对象转换为array对象，以便使用array的sqrt函数。
	Eigen::Matrix3d res_sqrt = mat.array().sqrt();
	std::cout << "Square root of the matrix:\n" << res_sqrt << std::endl;
	return 0;
}
```



## 03. json

c++的json库，有几个，用的时候看情况吧：

- [json](https://github.com/nlohmann/json)：这个star最多，用的比较多，就先用这吧。就一个文件
  	json对象调用 .dump() 函数就可以将其转换成字符串

  - ```
    #include "json.hpp"
    
    using json = nlohmann::json;
    json content = {
    	{"timeStamp", 20230818162957384},
    	{"cameraCode", 5},
    	{"signCode", "5_6_7"}
    };
    json req_json = {
    	{"eventType", 32000},
    	{"content", content.dump()}    // .dump()将其转换成字符串
    };
    ```

- [json11](https://github.com/dropbox/json11)：这个就几个文件，非常简洁；

- [RapidJSON](http://rapidjson.org/zh-cn/)：腾讯开源的，star也不错，有中文文档；

- [jsoncpp](https://github.com/open-source-parsers/jsoncpp)：放这吧。6.9k

- [simdjson](https://github.com/simdjson/simdjson)：这个16.6kstar,每秒可解析千兆字节的高性能 JSON 解析库

## 04. spdlog 日志库

[地址](https://github.com/gabime/spdlog)。（源码练习吧）c++的日志库，非常建议上手，star也非常多；demo在其readme中写得非常明白了。

另外一个c编写的，放这吧：[EasyLogger](https://github.com/armink/EasyLogger)，一款超轻量级(ROM<1.6K, RAM<0.3k)、高性能的 C/C++ 日志库

## 05. indicators 进度条库

[indicators](https://github.com/p-ranav/indicators)：一个c++编写的，用于c++的进度条库，可以是单文件的使用，很方便。直接去看它的README，gif图片样例给的非常生动，以后尽可能都搞一下吧。

![](illustration/demo.gif)

还有其它的例子(github网络不好不一定看得到，下下来就好)，这里在写一个它README的例子吧：

- ![](illustration/time_meter.gif)

  ```c++
  #include <chrono>
  #include <indicators/cursor_control.hpp>  
  #include <indicators/progress_bar.hpp>
  #include <thread>
  
  int main() {
    using namespace indicators;
  
    // Hide cursor
    show_console_cursor(false);
  
    indicators::ProgressBar bar{
      option::BarWidth{50},
      option::Start{" ["},
      option::Fill{"█"},
      option::Lead{"█"},
      option::Remainder{"-"},
      option::End{"]"},
      option::PrefixText{"Training Gaze Network 👀"},
      option::ForegroundColor{Color::yellow},
      option::ShowElapsedTime{true},
      option::ShowRemainingTime{true},
      option::FontStyles{std::vector<FontStyle>{FontStyle::bold}}
    };
  
    // Update bar state
    while (true) {
      bar.tick();
      if (bar.is_completed())
        break;
      std::this_thread::sleep_for(std::chrono::milliseconds(1000));
    }
  
    // Show cursor
    show_console_cursor(true);
  
    return 0;
  }
  ```

## 06. taskflow 高效的并发

[taskflow](https://github.com/taskflow/taskflow)：一个 C++ 头文件库，让你以简单的几行代码就可以实现高效的并发。示例代码如下：

​	The following program (`simple.cpp`) creates four tasks `A`, `B`, `C`, and `D`, where `A` runs before `B` and `C`, and `D` runs after `B` and `C`. When `A` finishes, `B` and `C` can run in parallel.

```c++
#include <taskflow/taskflow.hpp>  // Taskflow is header-only

int main(){
  
  tf::Executor executor;
  tf::Taskflow taskflow;

  auto [A, B, C, D] = taskflow.emplace(  // create four tasks
    [] () { std::cout << "TaskA\n"; },
    [] () { std::cout << "TaskB\n"; },
    [] () { std::cout << "TaskC\n"; },
    [] () { std::cout << "TaskD\n"; } 
  );                                  
                                      
  A.precede(B, C);  // A runs before B and C
  D.succeed(B, C);  // D runs after  B and C
                                      
  executor.run(taskflow).wait(); 

  return 0;
}
```

## 07. dbg-macro 宏debug

[dbg-macro](https://github.com/sharkdp/dbg-macro)：这个项目里就一个头文件，拿来就能用，debug时打日志、变量非常好用，除基本信息外，还输出变量名和类型。以后运行要看某处数据可以试试。

- 不建议vs上使用，因为vs打开的终端无法带颜色的输出，所有看起来很怪，linux上用。

- 直接下载，然后放进 /usr/include   # 那它现在就在  /usr/include/dbg-macro/

  - 然后写一个 vim /usr/include/gdb.h ，里面的内容是：

    ```c++
    #include <dbg-macro/dbg.h>
    
    #define gdb dbg
    ```

  - 这样以后直接导包 #include \<gdb.h>  宏也是用gdb，跟GDB贴和起来，不再去记忆它原本的dbg(当然原来的宏也是生效的)

下面的是官方README中的示例：（注释我是用了上面操作，官方的是dbg）

```c++
#include <gdb.h>

// You can use "gdb(..)" in expressions:
int my_func(int n) {
    if (gdb(n <= 1)) {
        return gdb(1);
    }
    else {
        return gdb(n * my_func(n - 1));
    }
}

int main() {
    // 1、
    const int a = 2;
    const int b = gdb(3 * a) + 1;  // [example.cpp:18 (main)] 3 * a = 6 (int32_t)

    // 2、
    std::vector<int> numbers{ b, 13, 42 };
    gdb(numbers);  // [example.cpp:21 (main)] numbers = {7, 13, 42} (std::vector<int32_t>)

    // 3、在一个表达式中
    my_func(4);  

    // 4、获取当前时间(比较直接简单，获取时间戳和用时还是用笔记里另外的)
    gdb(gdb::time());

    // 5、多个目标（像中间中记得用括号括起来）
    gdb(42, (std::vector<int>{2, 3, 4}), "hello", false);

    return 0;
}
```

进阶：Printing type names

​	`dbg(…)` already prints the type for each value in parenthesis (see screenshot above). But sometimes you just want to print a type (maybe because you don't have a value for that type). In this case, you can use the `dbg::type<T>()` helper to pretty-print a given type `T`. For example:

```c++
template <typename T>
void my_function_template() {
  using MyDependentType = typename std::remove_reference<T>::type&&;
  dbg(dbg::type<MyDependentType>());
}
```



## 08.  ThreadPool 线程池

[ThreadPool](https://github.com/progschj/ThreadPool)：一个简单的 C++11 线程池实现，就两个文件，非常简单易用。

## 09. 读取 CSV 文件库

[fast-cpp-csv-parser](https://github.com/ben-strasser/fast-cpp-csv-parser)：cvs解析的库，就一个头文件非常简单。

## 10. args 参数解析库

[args](https://github.com/Taywee/args)：一个简单的只有头文件(args.hxx)的c++参数解析器库。应该是灵活和强大的，并试图与Python标准argparse库的功能兼容，简单看demo，用法和python那个很相似。

​	就英伟达的instant-ngp项目中就是用的这个库做的参数的处理，可以学习。

## 11. cpp-httplib 

[cpp-httplib](https://github.com/yhirose/cpp-httplib)：一个文件的 C++ HTTP/HTTPS 库。这是一个用 C++11 写的仅头文件、跨平台的 HTTP/HTTPS 服务器端和客户端库，使用时十分方便，只需在代码中引入 `httplib.h` 文件。快速使用还不错，搜狗的[workflow](https://github.com/sogou/workflow)也还可以。

Server (Multi-threaded)：
	注：因为这是多线程，g++编译时要加 -lpthread ,主要这个库不是linux默认里的，所以需要手动指定。

```c++
#define CPPHTTPLIB_OPENSSL_SUPPORT
#include "path/to/httplib.h"

// HTTP
httplib::Server svr;

// HTTPS
httplib::SSLServer svr;

svr.Get("/hi", [](const httplib::Request &, httplib::Response &res) {
  res.set_content("Hello World!", "text/plain");
});
// 监听本机8080端口（别的机器访问记得要开启8080端口）
svr.listen("127.0.0.1", 8080);  
```

client：（进去看它的主页，用这直接进行post请求）

```c++
#define CPPHTTPLIB_OPENSSL_SUPPORT
#include "path/to/httplib.h"

// HTTP
httplib::Client cli("192.168.108.218", 8080);

// HTTPS
httplib::Client cli("192.168.108.218", 8080);

httplib::Client cli("192.168.108.218", 8080);
auto res = cli.Get("/hi");  // 等同访问 http://192.168.108.218:8080/hi
std::cout << "status:" << res->status << std::endl;  // 200
std::cout << "body:" << res->body << std::endl;  // Hello World!
```

然后同样用这发一个post请求：还用了上面的json库

```c++
#include <iostream>
#include "httplib.h"      // 这个项目里下的单独的文件
#include "json.hpp"       // 上面json库的第一个里下的单独的文件

int main(int argc, char** argv) {
	using json = nlohmann::json;
	json content = {
		{"deviceID", 0},
		{"timeStamp", 20230818162957384},
		{"toolsCode", "1_2_5_13"},
	};
	json req_json = {
		{"eventType", 32000},
		{"content", content.dump()}
	};
	// json对象调用 .dump() 函数可以将其转换为字符串。
	std::cout << req_json.dump() << std::endl;

	httplib::Headers headers = {
		{"content-type", "application/json"}
	};

	httplib::Client cli("192.168.108.52", 7714);
	auto res = cli.Post("/iot/http/push", headers, req_json.dump(), "application/json");
    // requests.post("http://192.168.108.52:7714/iot/http/push", headers=headers,data=json.dumps(req_json))  # python
	std::cout << "status:" << res->status << std::endl;
	std::cout << "body:" << res->body << std::endl;
	return 0;
}
```

注：下次用搜狗的试下吧。这个好像有bug。

- auto res = cli.Post("/iot/http/push", headers, req_json.dump(), "application/json"); 这个能成功，但是发送一会后这句就会卡一下，然后下面打印状态就会报“Exception has occurred. Segmentation fault”。然后又能发一会，等下又会卡。后面发现主要原因还是因为后端接收数据的问题，才导致这卡顿，然后这里卡顿后打印状态就会报错，try就包不住。不要去打印后面的 status、body ，应该用起来还是问题不大。

### CppNet

[CppNet](https://github.com/caozhiyi/CppNet)：这个国人学习中写的，感觉还不错，文档很全，中文支持不错，先放这里。

### crow

[crow](https://github.com/ipkn/crow)、[Crow](https://github.com/CrowCpp/Crow)：这是受flask启发开发的库，用起来跟flak比较相近，后面有需要，先试试看看这个库。

## 12. Catch2 用例测试库

测试库还有[googletest](https://github.com/google/googletest),暂时还没用过，或者[doctest](https://github.com/doctest/doctest)这个单文件测试项目。

​	[Catch2](https://github.com/catchorg/Catch2)：这是一个用例测试库，使用起来非常方便，是在学习[inifile-cpp](https://github.com/nianjiuhuiyi/inifile-cpp)这个ini文件解析库时看到的，要使用的话，就按照ini解析库中的用例去使用，也会知道该怎么写catch2的相应的CmakeLists.txt.

下面是inifile-cpp中的简单测试示例：全是用TEST_CASE宏包裹起来的测试case，主函数是另一个文件定义起来的，具体看ini这个项目。

```c++
#include "inicpp.h"
#include <catch2/catch.hpp>
#include <cstring>
#include <sstream>

TEST_CASE("parse ini file", "IniFile") {
    std::istringstream ss(("[Foo]\nbar=hello world\n[Test]"));
    ini::IniFile inif(ss);

    REQUIRE(inif.size() == 2);
    REQUIRE(inif["Foo"]["bar"].as<std::string>() == "hello world");
    REQUIRE(inif["Test"].size() == 0);
}

TEST_CASE("test the error", "the func()") {
	/*
	假设外部有一个函数要测试，里面有throw的代码，就要测试看是否会触发
	#include <stdexcept>
	int func(int a, int b) {
    if (b == 0)
        throw std::logic_error("divided is zero!");  # 需要这个头文件
    return a / b;
	}
	*/    
    REQUIRE_THROWS(func(5, 0));  // 这就会测试通过
    REQUIRE_THROWS(func(5, 1));  // 这不会触发func中的异常，测试就不会通过
}
```

