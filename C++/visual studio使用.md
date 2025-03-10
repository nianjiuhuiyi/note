一个问题(可能因为第三方库是release版本而不是debug版本)：

​	在vs中，摄像头读取rtsp地址，如果是Release，就可以运行，如果是Debug，就会报错，bad new length、string too long之类的，但如果是调用本地摄像头0，两种模式下都能运行。同样读取一个本地图片时也是，Debug模式会在imshow时直接报错，在Release下就是正常的。（要注意添加的动态库是debug版本还是release版本）

像是vulkan的demo中来看，win上的c++项目，不一定有 int main(),它可能是WinMain，甚至可能是其它的。

- 在“工具”下的第一行，获取工具和功能，就打开vs的下载管理面板



cmake编译vs项目的整个命令行生成：（这种好像生成的库文件大小比nmake的小很多）

以往用cmake-gui把vs的项目配好了后，就用vs打开，然后进行编译，纯命令行的实现就是用的NMakefile来做的，现在其实可以将整个过程用命令实现，就不用打开vs了(比较好的还是用vs自带的命令终端)：
	以protobuf为例：

1. 下载：https://github.com/google/protobuf/archive/v3.11.2.zip

2. > cd \<protobuf-root-dir>
   > mkdir my_build
   > cd my_build
   >
   > - cmake -A x64 -DCMAKE_INSTALL_PREFIX=%cd%/install -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_MSVC_STATIC_RUNTIME=OFF ../cmake       # 这一步就是cmake-gui里的配置，一般简单的就直接 cmake -A x64 ..
   > - cmake --build . --config Release -j 2    # 这一步就是vs打开的编译效果，同nmake （然后这不仅是对vs有用，linux下也是一样的，就代替make，--build build_dir后面跟的就是build要存放的路径(可以不存在),等价于 -B build_dir 就是简写）
   > - cmake --build . --config Release --target install   # 这一步就是安装，同nmake install，安装的目录不需要提前创建，可以 --target help 查看lists all build targets，差不多等同于 make help

解读：

- -A x64  指定x64;
- %cd%    就是window中的当前绝对路径，可以用 echo %cd% 看到;
- 后面的就是一些配置选项，protobuf_BUILD_TESTS就是代表不要弄test，因为咱没googletest的那个源码;
- 最后一个 ../cmake 就是代表用的CmakeLists.txt的路径是在 ../camke 下。

总结：
	我发现基本上用这种方式和用NMake makefiles最后install生成的文件里的内容都是一样的(都是Release模式)。但是用上面这种方式生成的lib文件夹的大小只有nmake这种方式生成的lib文件夹大小的一半，库小很多啊，以后看用上面这种方式吧，可以它自带了优化。

## 一、快捷键

### 1.1. debug

- `F10`的是逐过程，就是main函数里主控流程一句一句执行，不会进入到函数体;
  `F11`是逐语句，会一级一级进到里面去剖析，会进到函数体，想要跳出就是，`Shift+F11`;
  debug的时候，可以通过拖动游标的方式，把游标拖到到已经跳过的行再来debug，而不需要重新开（对意外按错了，想回到上一行就很有用）；

### 1.2. 其它

- `Ctrl+Shift+空格`：强迫显示参数信息，一般也可以通过输入逗号来获取。 # 自己加了ctrl + p
  - 修改自定义键盘的方法，看[这里](http://t.zoukankan.com/albert1017-p-3359470.html)（简单说，在上面“显示命名包含”中找到自己要的功能，再下面按下想设置的快捷键，然后分配）。  工具—>选项—>环境—>键盘
- `Ctrl+k+x`：来快速插入常用的代码段。
- `ctrl+Tab`：可以在打开的标签里快速切换。
- `F12`进去看了定义，要回来就是`Ctrl + -`(视图.向后导航),要再回去看就是`Ctrl+ Shilt + -`(视图.向前导航)
- “窗口.关闭文档窗口”：默认快捷键是Ctrl+F4,额外增加了一个Ctrl+W， （好像要把原来的ctrl+w去掉）
- 指针符号靠近变量名还是靠近类型的[显示设置](https://www.freeaihub.com/post/106049.html)。
- ==类似python的r==:最前面写一个大写`R`,再复制文件的绝对路径，再选中绝对路径且不包括引号，然后输入左括号(,它就会把绝对路径地址自动填充右括号)，然后就可以了。 // 这可能需要进到vs中去设置。
- “ctrl+u”是把大写变小写，“ctrl+shift+u”是把小写变大写，但是因为注释也会用到u这个字母，很多时候全选注释，就容易将其代码的大写变小写，就很烦，所以务必去设置->键盘中，将这俩快捷键删了。
- 格式化代码：Ctrl+K+F(格式化选中部分的代码，“编辑.设置选定内容的格式”)、Ctrl+K+D(格式化当前整个文件的代码，“编辑.设置文档的格式”)、Ctrl+T(跳转到别的文件，它的搜索名叫“编辑.转到所有”)
  前面的是原来的快捷键，现在把格式化当前整个文件Ctrl+K+D的快捷键再增加了Ctrl+T，原来的Ctrl+T功能就没了
- 复制当前行：ctrl+E+V(“编辑.复制”)，这是它原来的，然后新增了 ctrl+D

## 二、vs2017添加lib文件

### 1.1. 项目属性中添加

直接三步走：

- A、添加工程的头文件目录：工程---属性---配置属性---c/c++---常规---附加包含目录：加上头文件存放目录。
- B、添加文件引用的lib静态库路径：工程---属性---配置属性---链接器---常规---附加库目录：加上lib文件存放目录。
- C、然后添加工程引用的lib文件名：工程---属性---配置属性---链接器---输入---附加依赖项：加上lib文件名(一定要.lib的后缀)    （这个尽量就是把B添加路径下的所有.lib的名字都添加进去,每个.lib之间是用`;`隔开的）
  
  - 添加lib文件还有一种方式：在源码中添加语句(最后好像不要分号)： #pragma comment(lib,"文件路径/文件名")
    如引用ffmpeg的第三库：指定头文件和导入对应的库名
  
    ```c++
    extern "C" {
    #include <libavcodec/avcodec.h>
    #pragma comment(lib, "avcodec.lib")
    
    #include <libavformat/avformat.h>
    #pragma comment(lib, "avformat.lib")
    
    #include <libavutil/imgutils.h>
    #pragma comment(lib, "avutils.lib")
    }
    ```

Tips:

- 一定要注意设置属性时，模式是Debug还是Release,是x86还是x64；调试的时候上面选择的模式也一定要对应起来。
- 然后是.c的文件，后缀名一定要是.c，不然就可能会直接编译报错。



.dll动态库的设置(必须的，opencv也需要，一般是这样的路径D:\lib\opencv\build\x64\vc15\bin)：

​	有的时候有的第三方库库还要添加.dll动态库文件，一般会默认从C:\Windows\System32中找相应的.dll文件，当然不同的库还有自己独特的.dll文件，当报.dll找不到时，就在第三方库的路径下找到它，并==把其所在目录路径放进PATH系统环境变量中==，这是无论cmd命令行还是vs编译所必须要准备的。

- vs添加环境变量的一种方式：
  工程---属性---配置属性---调试---环境，这里写下：
  	PATH=.dll所在路径;     (分号结束，不要有空格,这样写完了就行了，后面不用跟其它的东西)

---

注意：出了以上方式，还有简单的做法，可以直接在 项目---配置属性---VC++目录 里添加头文件、库文件路径，可参看[这里](https://www.cnblogs.com/judgeou/p/14724951.html)。

以及使用opencv时，如果是debug模式时就要使用 opencv_world453d.lib 带d的这个lib，如果是release模式的话，就要使用 opencv_world453.lib 不带d这个，不然编译是不通过的。

如果要加载外部文件的话，把文件放在跟main.cpp一起，然后加载的时候就只用写文件位置就行了，不用管执行文件生成在哪里。

### 1.2. CMakeLists.txt添加

​	在CMakeLists.txt中`set(OpenCV_DIR D:/lib/opencv/build/)`(一般说是到有这`OpenCVConfig.cmake`就好了)或者`set(OpenCV_DIR D:/lib/opencv/build/x64/vc15/lib)`两者效果是一样；这样在visual studio中必须这样set指定路径，添加进环境变量就不行。



相反在window上是直接使用cmake软件的话，可以添加进环境变量(两种方式)，在CMakeLists.txt中就不用set制定路径了

- 直接在`Path`中添加`D:/lib/opencv/build/x64/vc15/lib`
- `系统变量(s)`中新建一个变量名为`OpenCV_DIR`，值为`D:/lib/opencv/build/`,只到build那级别
  - 注意：变量名一定这样的，大小写要严格遵守

建议都是搞起来嘛，然后就随便用都行。



## 三、插件功能

### 3.1. 添加参数的调试

第一种：

在解决方案选择要调试的，右键选择项目属性，然后：

配置属性--->调试--->命令参数（这里面填要传的参数，以`空格`分隔各个参数）

主程序中，带参数的Main函数来接收这些参数

Tips:好像只有.sln的，有解决方案的才行，直接是Cmake项目的不行，曲线救国就是先用cmake编译出.sln再用visual studio打开。

---

第二种(注意，使用了这种，第一种就会失效用不了了)：

使用插件，OneDrive中有，这里是在线[下载地址](https://marketplace.visualstudio.com/items?itemName=MBulli.SmartCommandlineArguments)，文件名大概是SmartCmdArgs-v2.2.0.vsix，这种.vsix的插件安装：

- 首先先关闭vs软件，找到VSIXInstaller.exe所在路径，一般为==D:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE==，然后用cmd(尽量cmd)进到这个路径;

- 然后把插件拖入到这个cmd中，然后回车安装就行了。

接下来是插件的==使用==：

- 视图--->其他窗口--->Commandline Arguments

对参数进行添加就好了，这里的配置一次会对release、debug、x86、x64这些都生效。

[这里](https://marketplace.visualstudio.com/items?itemName=MBulli.SmartCommandlineArguments)(其实就是在下载地址里)有对cmake项目添加参数支持的说明。

### 3.2. 生成函数说明模板

使用的是 Doxygen Comments 插件，具体安装可看“一些软件和一些设置”中的vs插件的安装，在里面vs2017文件夹的README。

使用： 

- 输入 `/**` 后直接回车。  // 这就是doxygen的风格（使用这个,多行注释）
- 输入 /// 后自己会生成注释，  // 这是vs自带的风格，默认是生成xml格式的，按下面改成doxygen的格式(会是单行注释)

它的默认格式是使用的 \param ，但是我看很多注释都是用的 @param ，所以修改方式：

- 工具->选项->搜索“doxygen”，

  - doxygen风格：然后在“Function”中设置改成：（可随意修改样式）

    ```
    /**
     * $BRIEF@brief $END.
     * 
     * @param $PARAMS
     * @return $RETURN
     */
    ```

  - vs中自己的风格：文本编辑器->C/C++->代码样式->常规   // 上一级的doxygen搜索也会将这个搜出来

    - 去“生成的文档批注样式”的下拉框，选择Doxygen(///)
      - 注意：它会用doxygen的样式，但它是单行注释，没行就是"//"开头，所以还是使用 /** 回车吧。

## 四、界面相关

### 4.1. 右边出来代码的略缩图

工具--->选项--->文本编辑器---> c/c++ --->滚动条--->使用垂直滚动条的缩略图模式(默认的是上面那个)

在这个里面的格式设置，还可以修改左括号是否另起一行

### 4.2. 将新打开的文件放到最右边

工具--->选项--->环境--->选项卡和窗口--->选项卡并--->将新选项卡插入现有选项卡的右侧

### 4.3. 文件列表按实际文件夹显示

项目--->显示所有文件

### 4.4 控制各类括号是否新占一行

工具--->选项--->文本编辑器---> c/c++ --->格式设置--->新行

## 五、其它

### 5.1. 获取软件所需.dll名单

方式一：使用dumpbin.exe

​	安装vs后，用初始化了vs环境的终端，使用命令：`dumpbin  /DEPENDENTS  my_software.exe`

方式二： Dependencies（开源）

​	[Dependencies](https://github.com/lucasg/Dependencies)是对遗留软件Dependency Walker的重写，支持命令行和GUI界面两种方式，下载好后，用命令行的话：`Dependencies --modules  my_software.exe > depend.txt`  # 其中[NOT_FOUND]表示缺少的动态库.（简单试了下，有点不得劲，就用方式一吧）

---

网上看到的参考：(还未做过测试)

> 如果查看.dll库中包含哪些函数，可以使用:dumpbin /exports xxx.dll >1.txt
> 如果查看.exe中加载了哪些动态库，可以使用: dumpbin /imports xxx.exe > 2.txt
> 如果查看.lib中包含哪些函数，可以使用:dumpbin /all/rawdata.none xxx.lib >3.txt
> 如果查看.obj中包含哪些函数，可以使用: dumpbin /all/rawdata.none xxx.obj >4.txt

### 5.2. 终端显示utf-8乱码

ASR请求服务后，服务器返回的是utf-8的字符串，vs的终端直接展示是乱码的，因为它用的是GB2312，所以：

```c++
#include <string>
#include <iostream>

#include <windows.h>  // 尽可能把这个windows的头文件放到最后，不然可能会影响一些头文件的编译

std::string UTF8ToGB2312(const std::string &utf8Str) {
    // Step 1: Convert UTF-8 to UTF-16 (wide char)
    int wideCharLen = MultiByteToWideChar(CP_UTF8, 0, utf8Str.c_str(), -1, nullptr, 0);
    if (wideCharLen == 0) {
        throw std::runtime_error("Failed to convert UTF-8 to UTF-16");
    }
    std::wstring wideStr(wideCharLen, L'\0');
    MultiByteToWideChar(CP_UTF8, 0, utf8Str.c_str(), -1, &wideStr[0], wideCharLen);

    // Step 2: Convert UTF-16 to GB2312
    int gb2312Len = WideCharToMultiByte(CP_ACP, 0, wideStr.c_str(), -1, nullptr, 0, nullptr, nullptr);
    if (gb2312Len == 0) {
        throw std::runtime_error("Failed to convert UTF-16 to GB2312");
    }
    std::string gb2312Str(gb2312Len, '\0');
    WideCharToMultiByte(CP_ACP, 0, wideStr.c_str(), -1, &gb2312Str[0], gb2312Len, nullptr, nullptr);

    return gb2312Str;
}

int main() {
    std::string utf8Str = u8"你好，世界！"; // UTF-8 字符串
    try {
        std::string gb2312Str = UTF8ToGB2312(utf8Str);
        std::cout << "GB2312 String: " << gb2312Str << std::endl;

    }
    catch (const std::exception &e) {
        std::cerr << "Error: " << e.what() << std::endl;
    }
    system("pause");
    return 0;
}
```

## 六、使用git

先去插件里面把git管理软件下载好。



​	首先：用vs创建一个新的项目时，如果勾选了了“Git仓库”，会自动生成对应的“.gitattributes”、“.gitignore”文件，并会自动提交。（建议这么来）
​	（当然旧的项目，没有git，可以直接在项目的路径里用git init初始化，然后会发现进到vs中此目录中的所有文件都被add了，提交的话，会commit所有）

​	且vs与JetBrain最大的不同就是，一旦初始化好了仓库后，在仓库文件夹里添加、修改或是删除文件都会被自动记录(==新文件自动就会被Add==)，不会再有手动新文件的Add，所以要注意。所以哪些不想被添加，先去“.gitignore”写好了后再加入吧。

​	然后可以用命令行与远程仓库添加联系。



注意：

- 新的文件一添加进去，就会被自动ADD。
- commit提交时，默认会把所有的修改、新增、删除全部提交，如果只是想要提交部分修改数据，那：
  - 把想要提交的文件选中，然后右键选择：“暂存”，那么就会出现“已暂存的更改数”(然后这时去提交，就会只提交这里面的文件)。