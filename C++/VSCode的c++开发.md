当vscode来编辑器，当出现.dll动态库找不到的时候，就搜索一下，然后将其所在的路径添加到环境变量中就好了。

运行python程序时，它的python debug console终端太丑了，在setting.json里加这么一行就行了：
"terminal.integrated.automationShell.windows": "cmd.exe",

- terminal终端要加添加vs、anaconda、qt这些环境时，去菜单栏看这些prompt快捷方式所在的路径，然后再看其属性，就能知道它是怎么启动那些初始化环境的.bat文件的，就可以仿照着写进win新的终端的配置文件中。
- 启动黑屏闪退，需要添加一个参数 code.exe --no-sandbox

.bat文件，最后一行可以加一个 pause 这样终端就是vs的那种停住，按任意键运行。 

## 编译：

- MinGW：
  - cmake -G "MinGW Makefiles" ..     # 必须要有参数-G
  - mingw32-make.exe        # 得到的Makefile可修改，具体看Makefike学习笔记
- MSVC：（命令行的话，定要用vs的终端打开）
  - cmake -G "NMake Makefiles" ..   # 记得加 -G
  - nmake
  - 注意：vscode一打开这带有CMakelists.txt的文件，就会自动生成，生成的东西是不对的，先把里面删除干净，再来执行上面的命令

Tips：如果不加参`-G`,win上会直接生成vs的.sln项目，配置这些还不好搞，这样的话更好的选择就是直接使用cmake-gui。 

namke想要开启多核编译的话：

> set CL=/MP     # 这样设置环境变量，同时编译多个文件
> nmake

## VSCode的C/C++开发 ===> Windows

## 0. 常用习惯设置

视频的学习地址：[这里](https://www.bilibili.com/video/BV13K411M78v?p=2)。	

- vscode设置每次启动时都是打开欢迎界面，而不是上次的工程：设置->window.restoreWindows  把这个值设为none
- 设置快捷键：File-->Preference-->Keyboard Shortcts，
  - 删除：找到 Delete Line 设为ctrl+Y
  - 复制：找到 Duplicate Selection 设为ctrl+D
  - 格式化：原为shift+alt+f，改为ctrl+T,很多全都一起改了  # 可能格式化Python代码有问题，看[这里](https://blog.csdn.net/Dontla/article/details/131741073)。
    鼠标右键文件空白处，能看到Format...的命令，还可以设置用啥来format
- 代码之间快速切换：
  - 进到代码里：ctrl+鼠标点击
  - 进入后回退：ctrl - 这两个组合键(它的命令叫Go Back)
  - 回退的过程又再回去看的话：alt —> 这两个组个建（它的命令叫Go Forward）
    - 这个不好用，跟vs保持一致，添加一个 Ctrl Shift - 
- 只有tab才是接受智能提示，回车就是换行，不是接受建议：（这其实就是改的全局的setting.json）
  - 打开设置，搜索“editor.acceptSuggestionOnEnter”，选择off
- 把 Debug:start debugging 改成 ctrl+F5
  把 Debug:start without debugging 改成 F5   # 相当于对调了，然后F5下一个断点还是不变
- 在setting中搜索“autocomplete”，然后勾选C_CPP:Autocomplete Add Parenthese，这样就可以在tab补全函数名时自动带括号，相关[地址](https://www.zhihu.com/question/396273345/answer/2265355913)。
- 快速隐藏/显示终端窗口的快捷键：Ctrl + j

---



## 1. 开发环境搭建

- 安装==mingw-w64==编译器（GCC for Windows 64 & 32 bits）、==Cmake==工具(选装)
  - mingw-w64下载地址：[这里](https://sourceforge.net/projects/mingw-w64/files/)；下载`x86_64-posix-seh`名称
  - cmake下载地址：[这里](https://cmake.org/files/)。可下载msi文件安装，也可直接下包
  - 下载完毕后，解压到某个地方，然后==bin目录添加环境变量==就行了
    - 一个注意点，比如git的bin目录中也加入了环境变量，它里面的sh.exe就会造成影响，在cmake时就会得到这样的错误：sh.exe was found in your PATH, here:D:/program files/Git/bin/sh.exe；For MinGW make to work correctly sh.exe must NOT be in your path.。现在暂时的解决办法就是去把那bin下的sh.exe改名一下(其它在环境变量中还有的sh.exe也可能会有这个影响)
- vscode的插件安装
  - c/c++  # 相关的三个Microsoft的都装上吧
  - cmake（装吧）（它的作用是方便看，编辑CMakelests.txt）
  - ==cmake tools==（一定装）（它的作用是使用第三方库时，方便进去看源码，如果禁用掉，第三方库在平时编辑时就点不进去，下面还会有红色的波浪线）它里面还有两个参数设置
    
    - Configure On Edit   打开的话，一修改CMakelests.txt，就会自动cmake（搜索这个选项，然后在Cmake Tools中）
    
    - Configure On Open   打开的话，vscode一打开新文件夹，就会自动cmake配置，会自动创建一个build文件夹，然后让你选择使用哪种编译器：
      注意：以下三种都是可以的，自动cmake后，点最下面状态栏的运行符号:triangular_ruler:就会自动编译，接着自动运行或debug(且都不需要写task.json和launch.json文件)：
    
      - 选择mingw的gcc，就会自动生成MinGW Makefiles；
    
      - 选择侦测到的vs，就会生成.sln的项目；
    
      - 若想生成vs的NMake Makefiles文件，就去修改这个json文件“C:\Users\Administrator\AppData\Local\CMakeTools\\==cmake-tools-kits.json==”，仿照mingw的写法添加一个就好了，这里加一个参考示例吧：
    
        ```json
        {
            "name": "cl NMake Makefiles - amd64",
            "compilers": {
              "C": "D:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Community\\VC\\Tools\\MSVC\\14.16.27023\\bin\\Hostx64\\x64\\cl.exe",
              "CXX": "D:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Community\\VC\\Tools\\MSVC\\14.16.27023\\bin\\Hostx64\\x64\\cl.exe"
            },
            "preferredGenerator": {
              "name": "NMake Makefiles"
            },
            "environmentVariables": {
              "CMT_MSVC_PATH": "D:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Community\\VC\\Tools\\MSVC\\14.16.27023\\bin\\Hostx64\\x64"
            }
          },
        ```
    
        Tips:
        	name自己起；C/CXX路径都是给到cl.exe的路径；name值注意；要用x86，就添加一个新的x86的路径。这个"CMT_MSVC_PATH"属性名字乱起的，在那时没发觉其用处（因为只是添加cl.exe所在路径是没有的，只能通过vs自来的cmd进来）。
  - 可选的插件：
    - Code Runner：右键即可编译运行单文件，很方便；但无法Debug（暂时没用）；
    - One Dark Pro：大概是VS Code安装量最高的主题（颜色比较红，暂时没用）；
    - Draw.io Integration：直接用VScode画流程图的，对应文件后缀名是==.drawio==；
    - Doxygen Documentation Generator：快速生成注释文件，比如在cpp函数钱，输入/**，然后回车；
    - clangd：（暂时没用，但提示不太友好时来试试）说这是一个c++语法自动提示的插件，用它来替代微软的c/c++那三个插件，说qtcreater的智能提示就是用的这个，更加友好。
    - vscode-json：做json格式化的，安装后快捷键 “ctrl+alt+b”。或者ctrl+shift+p把命令面板弹出来，输入vscode-json，就能看到其对应的功能了。
    - Git Graph：git的可视化，还是比较好用的。

### vscode远程服务器配置

针对Administrator这个用户免密远程的话：

- 看C:\Users\Administrator\\.ssh 路径下是否有秘钥id_rsa之类的，没有的话就生成一个（参见linux.md中的ssh免密或是git中的ssh免密）

- vscode中安装插件==Remote-SSH==，选择右边的 Remote Explorer ,然后打开Configure ,再选择

  C:\Users\Administrator\\.ssh\config

  然后改成以下内容：

  > Host 2080Ti          # 起的别名
  >
  > ​	HostName 192.168.108.218   # IP地址
  >
  > ​	User root        # 用户名
  >
  > ​	IdentityFile C:\Users\Administrator\.ssh\id_rsa

Tips:如果出错，按这两步去尝试修正一下

- 因为同步的问题，一些设置可能不对，就导致一直连接不上，所以出问题时，一定去把Remote-SSH插件的所有设置都手动重置了（重装不行，一定手动重置配置）；
- 还不行，就可能是win10自带的OpenSSH有点问题，不行的时候重新装一下，这是官方安装办法的[地址](https://docs.microsoft.com/zh-cn/windows-server/administration/openssh/openssh_install_firstuse)。
- 如果需要跳板机，看看[这篇](https://blog.csdn.net/junbaba_/article/details/111590179)文章的最后，还没试过。
- 还可能是服务器的问题(试了很久，解决不了)，换个服务器是可以的，不是vscdoe的问题。其实就是ssh免密的设置。

使用时的一个错误：

- 远程debug时，会说找不到cmake，那是因为打开的终端没有继承~/.bashrc中的环境变量，解决办法：打开设置-->搜索inherit-->点击Terminal，然后把Inherit Env勾选上。重启vscode可能还是不行，可能需要重启电脑就ok了。

### c_cpp_properties.json

​	vscode远程开发时，CMakeLists.txt中已经把添加头文件路径写好了的，编译运行过的项目可能没问题，但是刚开始写时，总是会在找头文件时报红线，这样就没有智能提示，就在“.vscode”文件夹下添加这两个json文件用来配置智能提示：

- c_cpp_properties.json

  ```json
  {
      "configurations": [
          {
              "name": "Linux",
              // 主要就是把那些找不到的头文件的路径手动写进来，方便提示，与CMakeLists.txt没有任何关系。总之写的时候，哪个头文件下报红线，就把它的路径添加进来
              "includePath": [
                  "${workspaceFolder}/**",
                  "/usr/local/cuda/include",
                  "/opt/opencv-4.5.3/install/include/opencv4"
              ],
              "defines": [],
              "compilerPath": "/opt/rh/devtoolset-8/root/usr/bin/gcc",
              "cStandard": "gnu17",
              "cppStandard": "gnu++14",
              "intelliSenseMode": "linux-gcc-x64"
          }
      ],
      "version": 4
  }
  ```

- settings.json：这个就放进去吧，也是为了方便智能提示，具体作用咋生效不是很清楚。

  ```json
  {
      "files.associations": {
          "*.cpp": "cpp",
          "iosfwd": "cpp",
          "unordered_map": "cpp",
          "array": "cpp",
          "atomic": "cpp",
          "hash_map": "cpp",
          "hash_set": "cpp",
          "strstream": "cpp",
          "*.tcc": "cpp",
          "bitset": "cpp",
          "cctype": "cpp",
          "chrono": "cpp",
          "cinttypes": "cpp",
          "clocale": "cpp",
          "cmath": "cpp",
          "codecvt": "cpp",
          "complex": "cpp",
          "condition_variable": "cpp",
          "csignal": "cpp",
          "cstdarg": "cpp",
          "cstddef": "cpp",
          "cstdint": "cpp",
          "cstdio": "cpp",
          "cstdlib": "cpp",
          "cstring": "cpp",
          "ctime": "cpp",
          "cwchar": "cpp",
          "cwctype": "cpp",
          "deque": "cpp",
          "forward_list": "cpp",
          "list": "cpp",
          "unordered_set": "cpp",
          "vector": "cpp",
          "exception": "cpp",
          "algorithm": "cpp",
          "functional": "cpp",
          "iterator": "cpp",
          "map": "cpp",
          "memory": "cpp",
          "memory_resource": "cpp",
          "numeric": "cpp",
          "optional": "cpp",
          "random": "cpp",
          "ratio": "cpp",
          "regex": "cpp",
          "set": "cpp",
          "string": "cpp",
          "string_view": "cpp",
          "system_error": "cpp",
          "tuple": "cpp",
          "type_traits": "cpp",
          "utility": "cpp",
          "fstream": "cpp",
          "future": "cpp",
          "initializer_list": "cpp",
          "iomanip": "cpp",
          "iostream": "cpp",
          "istream": "cpp",
          "limits": "cpp",
          "mutex": "cpp",
          "new": "cpp",
          "ostream": "cpp",
          "sstream": "cpp",
          "stdexcept": "cpp",
          "streambuf": "cpp",
          "thread": "cpp",
          "cfenv": "cpp",
          "typeindex": "cpp",
          "typeinfo": "cpp",
          "valarray": "cpp",
          "variant": "cpp",
          "__nullptr": "cpp"
      }
  }
  ```

## 2. 使用cmake构建项目

​	简单的使用而不是用cmake的话，就是直接打开一个terminal，然后正常的使用g++命令直接编译构建可执行文件、运行就好了。



下面主要讲下cmake的使用：

- 先创建一个`CMakeLists.txt`文件，里面就简单两行
  - project(a_test)       # 名字应该是可以随便起的，是不是尽量项目同名好一些
  - add_executable(my_cmake main.cpp swap.cpp)   # 最终文件名称及依赖
- 快捷键——`Ctrl+Shift+p`，输入`cmake`，一般就是选择第一个的`Configure`,再选自己装的GCC版本就好了(这一步第一次有，后面可能就没了)；
- 然后在终端`cd build`、`cmake ..`、`mingw32-make.exe`   // 跟linux不太相同的是第三步的make，window下是用的这个命令，一定注意
  - 注意第二步：如果电脑上已安装了VS，直接cmake可能会调用微软MSVC编译器，而我们想用的是gcc，那就用`cmake -G "MinGW Makefiles" ..` 代替`cmake ..`  (仅第一次这样，后面就可以cmake了，不行的话就还是用这命令吧)

## 3. vscode下的debug

### 3.1 普通命令编译项目

3.1.1 ==单个==.cpp文件的debug

- 针对单个的.cpp文件，先用g++编译成可执行文件（最好加参数-g 代表生成带调试信息的可执行文件）；
- debug的时候，就点击左边带虫子的按钮，再点击`create a lunsh.json file`,再选择带`GBD`那个，再就是选择`g++.exe`那个(这里有可能不会有这个选择，就生成其它模板再改就好了)，然后系统就会自动生成相关的配置的json文件，在同级`.vscode`；
- 打上断点然后run或者F5就可以debug了。

---

3.1.2 ==多个==.cpp文件的dubug

- 先把多个文件编译成可执行文件：g++ -g .\main.cpp .\swap.cpp -o my_main
- 一样的会先自动生成`launch.json`、`tasks.json`文件，但这是不能成功运行的，因为它是自动生成的，都是按照默认的名字来的，是不对的,接下来就去修改`launch.json`：
  - 主要就是修改`"program"`这一项，它就是指向我们生成的`my_main`执行文件，于是我们改成`"program": "${fileDirname}/my_main.exe"`（其中`${fileDirname}`是当前文件目录，也就是"cwd"对应的值）;还要把最下面那项目`"preLaunchTask"`给注释掉(这是不对的，下面会说到)，因为它是默认生成命令，针对单文件可用。
  - 注释了`preLaunchTask`，对源cpp文件修改后，调试却还是按照上次展示，因为，我们没有使用`"preLaunchTask"`，不会自动编译新的可执行文件，
- 修改源文件就能在重新运行时自动编译就需要开启preLaunchTask，以及拥有`tasks.json`文件，它就是来负责重新编译，而preLaunchTask就是与之沟通的路径
  - 如果没`tasks.json`，就先`Ctrl+Shift+p`，输入`tasks`，选择`Configure Task`，再选择带有`g++`的，就会生成`tasks.json`；
  - 修改`tasks.json`，主要就是`"args"`,把里面的内容改成用终端g++编译时需要的参数，输入的文件名及路径要跟`launch.json`中的`"program"`一致；
  - 再把`launch.json`最后一行的`"preLaunchTask"`放开，且主要这个内容也要跟`tasks.json`的`"label"`里的内容保持一致。

---

3.1.3 示例json文件

​	这里相当于是模仿终端直接使用g++编译的方式，每次debug的时候要是有修改，就会执行tasks.json,它就会自动帮我们编译，就方便直接debug。

- tasks.json

```json
{
	"version": "2.0.0",
	"tasks": [
		{
			"type": "cppbuild",
			"label": "C/C++: g++.exe 生成活动文件123",
			"command": "D:\\program files\\mingw64\\bin\\g++.exe",
			"args": [     // 给的是编译时的参数
				"-g",
				"main.cpp",
				"swap.cpp",
				"-o",
				"${fileDirname}\\my_main.exe"
			],
			"options": {
				"cwd": "${fileDirname}"
			},
			"problemMatcher": [
				"$gcc"
			],
			"group": "build",
			"detail": "编译器: \"D:\\program files\\mingw64\\bin\\g++.exe\""
		}
	]
}
```

- launch.json

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "g++.exe - 生成和调试活动文件",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/my_main.exe",   // 注意这里的路径名
            "args": [],   // 这里是给程序执行时输入的参数
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",  // 项目所在的路径；${fileDirname}是当前文件所在路径
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "D:\\program files\\mingw64\\bin\\gdb.exe",
            "setupCommands": [
                {
                    "description": "为 gdb 启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "C/C++: g++.exe 生成活动文件123"  // 这里跟tasks.json的label保持一致
        }
    ]
}
```

### 3.2 cmake构建项目	

可能要自己写`launch.json`和`tasks.json`，有时候快捷键设置出不来g++的tasks,下面给的例子:

主要针对win下使用mingw的配置示例，主要是launch.json中miDebuggerPath路径的不同，所以特意拿出来，然后tasks.json都是一样的：

launch.json

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "这是随意放的一个",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/my_cmake.exe",
            "args": ["-i", '123.mp4'],     // 这里是给程序执行时输入的参数,多个就用逗号隔开
            "stopAtEntry": false,
            "cwd": "${fileDirname}",       // 这里是fileDirname还是workspaceFolder都无伤大雅
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            // "miDebuggerPath": "D:\\Program Files\\mingw64\bin\\gdb.exe",   // 这是错的；这路径虽然是对的，但是不能有大写，不然就不行
            "miDebuggerPath": "D:\\program files\\mingw64\\bin\\gdb.exe",  
            "setupCommands": [
                {
                    "description": "为 gdb 启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "this_name_should_be_same"   // 注意
        }
    ]
}
```

Tips：

- `miDebuggerPath`的值是`gdb`软件的路径，这个路径里是不能用大写字母的，那怕真实路径里有大写字母，也要手动改成小写的。

#### launch.json

这个主要是把参数的注释写的比较全，用的时候，或者发给别人的时候，用上面的launch.json，一样的

```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {	
            // 配置名称，将会在启动配置的下拉菜单中显示(可随意)
            "name": "g++ - Build and debug active file",  
            // 配置类型，对于C/C++可认为此处只能是cppdbg，由cpptools提供；不同编程语言不同
            "type": "cppdbg",  
            "request": "launch",  // 可以为launch（启动）或attach（附加）
            "program": "${workspaceFolder}/build/yolov5_video", // 可执行文件的绝对路径
            // 可执行文件后跟的参数(文件是相对路径)
            // 如果最后给的rtsp地址，这里 & 符号前要加转义才行，
            // 如："rtsp://192.168.108.132:554/user=admin\\&password=\\&channel=1\\&stream=0.sdp?"
            "args": ["-d", "my_v5l.engine", "../123.mp4"],  
             // 设为true时程序将暂停在程序入口处，相当于在main上打断点
            "stopAtEntry": false, 
            
            "cwd": "${workspaceFolder}/build",  // 为了上面args后面的参数可以使用路径
            "environment": [     // 加环境变量，必须是这种格式
                {"name": "DISPLAY", "value": "192.168.108.147:0.0"}, 
                {"name": "abc", "value": "a_test"}
            ],
            // true：就是使用单独的cmd窗口；false：使用内置终端（有显示不全的可能）
            "externalConsole": false, 
            
            "MIMode": "gdb",  // 指定连接的调试器，可以为gdb或lldb。但我没试过lldb
            "miDebuggerPath": "/usr/bin/gdb",    // gdb的路径
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
    		// 这里的值跟tasks.json的label保持一致
            "preLaunchTask": "C/C++: g++ build active file",
        }
    ]
}
```

#### tasks.json

```json
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "options": {
        "cwd": "${workspaceFolder}/build"   // 注意这里是 workspaceFolder
    },
    "tasks": [
        {
            "label": "cmake",
            "type": "shell",
            "command": "cmake",
            "args": [
                ".."
            ]
        },
        {
            "label": "make",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "command": "make",
            "args": [

            ]
        },
        {
            "label": "C/C++: g++ build active file",  // 这里和laubch.json的`preLaunchTask`值保持一致
            "dependsOn": [
                "cmake",
                "make"
            ]
        }
    ]
}
```

Tips：

- tasks.json的执行的"label"值一定要与launch.json的"preLaunchTask"值一样；
- `workspaceFolder`代表的是这个项目总文件夹的路径，应该所有文件用这个都是一样的;`fileDirname`是当前正在编辑的文件的路径，不同文件之间可能是有出入的；
- 当使用上述操作无法出来对应的.json文件，可把这示例json复制过去进行修改。

### 3.4. 学习过程的代码

​	这个其实意义不大，很简单，完全可以不看，但还是放这里，后续要复现的话，快速复制过去就行。

- swap.h

  ```c++
  void swap(int &, int &);
  ```

- swap.cpp

  ```c++
  #include "swap.h"
  
  void swap(int &a, int &b) {
      int temp = a;
      a = b;
      b = temp;
  }
  ```

- main.cpp

  ```c++
  #include <iostream>
  
  #include "swap.h"
  
  int main(int argc, char **argv) {
      std::cout << "hello world" << std::endl;
      int a = 13, b = 14;
      std::cout << "交换前：" << std::endl;
      std::cout << a << "\n";
      std::cout << b << "\n";
      swap(a, b);
      std::cout << "交换后：" << std::endl;
      std::cout << a << "\n";
      std::cout << b << "\n";
      std::cout << "执行到这里了" << std::endl;
      return 0;
  } 
  ```

## 4. 远程调试

​	点击插件那里，有一个local，下面应该还有SSH:2080Ti-INSTALLED，需要在这里面安装上差不多跟local中一样的python，c++插件才会让debug,可能不好装。我这次也是偶然点出来的就都装上了，主要是点了一个C++的，Add to Workspace Recommendations

​	更新：一定要在远程的ssh上安装上C/C++ Extension Pack，这个插件，就搜索起来，多点多试试。

### 4.1 python

- 建议：以一个远程项目为一个文件地址远程打开，进行调试，不要远程到/home下，再逐步点到项目里去，因为vscode调试时会创建一个`.vscode`文件夹，它会放在你最开始远程的路径下，所以为了避免各项目之间的感染，就还是把.vscode创建在项目各自的目录下。

- 可能出现的问题：远程时，可能断点都打不了，按下F5也都直接报错，那就点这个错误，把python那个Extension卸载了，再重新装，然后再试，一般就可以了。

- 更改环境，anaconda下有很多环境，在vscode远程窗口左下角可以更改选择具体的环境。当然也可以直接在.vscode目录下修改或是直接添加`settings.json`文件，内容如下：

  ```json
  {
      "python.pythonPath": "/root/root/anaconda3/envs/yolact_edge/bin/python"
  }
  ```

  一般来说这会自动生成，然后点击左下角修改环境路径时，这个文件里的路径就会跟着变。

==终端带参数的输入调试==，步骤如下：

Run--->Open Configurations--->Python--->Python File

然后它就会自动生成`launch.json`文件，然后就再手动加入自己终端输入要添加的参数，然后就可以去debug了：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Current File",
            "type": "python",
            "request": "launch",
            "program": "${workspaceFolder}/my_yolov5_trt_video.py",
            "console": "integratedTerminal",
            "justMyCode": true,   // 酌情看要不要这一项
            "args": [
                "--trained_model", "123.pth",
                "--score_threshold", "0.3",
                "--top_k", "10",
                "--display"
            ]
        }
    ]
}
```

### 4.2 c++

和python基本是一样的，也是以一个远程项目为一个文件地址远程打开。

注意点：每一次修改代码后，按F5开始debug时，会重新make编译，但是因为anaconda环境问题，make可能不会成功，即便从\$LD_LIBRARY_PATH中把anaconda相关去掉，自动make还是因为这个失败(这是因为它还在/etc/ld.so.conf.d加入了相关路径，并且这个在\$LD_LIBRARY_PATH是不会现实出来的)，所以改了代码后，还是自己先在bash中make后，再debug。

现在已经可以远程调试了，还看到一个gdb-server，没用过，暂时放[这里](https://cumtchw.blog.csdn.net/article/details/107680346)，[这里](https://blog.csdn.net/lucky_ricky/article/details/104611125)吧。

### 4.3 远程显示图像

去看docker里面，有详细的说明。下面是以前写的，

我这里并没有用网上说的Remote X11，还是依靠的Xmanger来实现的：

- vim ~/.bashrc
- 加入这行：export DISPLAY="localhost:12.0"
- source ~/.bashrc

这样子，无论是在xshell中还是vscode远程，运行都能自动调用xmanger来显示图像。(后面的数字，10、11、12都试过，都可以，但是13就不行，不知道为啥)。

## 5. vscode生成、调试vs的程序

​	除了使用vscode的这种方式debug，windows中还有一个微软出的专门的debug工具，叫做==WinDbg==，了解一下，可看[这里](https://zhuanlan.zhihu.com/p/43972006)。

### 5.1 win下编译

在windows下也是可以直接用命令行编译vs的Makefile,而不是.sln工程的：

1. 环境准备：

   - 首先把vs的编译器==cl.exe==加入到环境变量，一般它的路径如下(注意使用64的)(这也不是必须，因为执行下面的.bat后，环境都会弄好)：

     - `D:\Program Files (x86)\MicrosoftVistualStudio\2017\Community\VC\Tools\MSVC\14.16.27023\bin\Hostx64\x64`；

   - 然后==必须用cmd==,不能是powershell(用它就是不行，试过很多次了)，然后在cmd中，直接输入执行如下.bat文件：

     - `"D:\Program Files (x86)\MicrosoftVistualStudio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"`(记得一定要这对引号),

     完成环境初始化(这其实就是菜单中vs的工具提示符)，然后就可以在这个cmd中进行编译操作了。

   Tips：

    - vscode中，可以配置自己的终端，可以在自定义终端中，不用source来继承一个终端的配置，而是直接使用

      ```json
      // 注意，以下只是其中的一部分
      "my_msvc": {
          // "path": "C:\\Windows\\System32\\cmd.exe",
          "path": "D:\\Program Files (x86)\\MicrosoftVistualStudio\\2017\\Community\\VC\\Auxiliary\\Build\\my_msvc.bat\",
          "args": []
      }
      ```

      - 这个path路径就是上面vcvars64.bat所在路径，我只是在那里面写了一个名为“my_msvc.bat”的文件，里面的内容为:(只是在vcvars64.bat内容后加了一行cmd，不然新打开的终端总是会闪退，先是试着不加。)

        ```bat
        @call "%~dp0vcvarsall.bat" x64 %*
        cmd
        ```
        
        也可以给绝对路径写到bat文件中：@call "D:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"

2. 编译：

   - cmake -G "NMake Makefiles" ..
   - nmake

注意：nmake 命令其实就是 nmake.exe ，它跟cl.exe在一起，所以要加环境变量才用直接使用。

以上是一种原理，了解一下挺好，但是要直接快速使用，还是按照我写的[这个博客](https://blog.csdn.net/nianjiuhuiyi/article/details/121154365)来操作。

### 5.2 debug

​	5.1中的操作就是win下命令行的编译，用的是msvc的编译器和库，这种就可以直接只用windows下opencv已经编译好的MSVC版本(特别注意：这个已经编译好的版本，win下的mingw是不能使用的)，vscode中如下操作：

1. 环境准备：
   - vscode可能会自主选择一个编译器进行自动编译，但是要么是mingw，要么是生成vs的.sln工程，没办法生成NMake的makefile,我们也没法办指定，就只能把让其先生成(主动或是被动)，再删除掉build文件下除了==.cmake==文件夹的所有文件；
   - 新建一个cmd终端(一定要cmd)，然后在里面执行==vcvars64.bat==这个脚本，参照5.1。（或者直接在vs自带的cmd中输入code来运行vscode）
2. 编译：
   - cmake -G "NMake Makefiles" ..
   - nmake
3. debug：
   - 点debug的图标，创建lacun.json文件，选择==C++(Windows)==,再点cl.exe，把生成的launch.json中的program项目改成程序所在位置就可以了；
   - 再手动创建一个tasks.json，内容见下。

​	注意点：一般就这可以开始debug了，但是同样无法在修改代码后自主nmake，原因跟4.3有些类似，这个需要特定的cmd(即执行了那个.bat脚本的)，vscode自主编译时会新建一个powershell就肯定会编译失败，我也尝试把脚本的执行加进tasks.json，验证过了是不行的；
​	所以同理，一般debug时，就是编译好了的程序，如果有改代码，先去到那个一开始已经弄好的cmd中nmake编译好了先，然后再debug，改一下代码，这样子做一次。

这样子做的两个实例json：

- launch.json

  ```json
  {
      "version": "0.2.0",
      "configurations": [
          {
              "name": "cl.exe - 生成和调试活动文件",
              "type": "cppvsdbg",
              "request": "launch",
              "program": "${workspaceFolder}/build/bin/eyeLike.exe",
              "args": [],
              "stopAtEntry": false,
              "cwd": "${fileDirname}",
              "environment": [],
              "console": "externalTerminal",
              "preLaunchTask": "C/C++: cl.exe 生成活动文件"
          }
      ]
  }
  ```

- tasks.json

  ```json
  {
      "version": "2.0.0",
      "options": {
          "cwd": "${workspaceFolder}/build"   // 注意这里是 workspaceFolder
      },
      "tasks": [
          {
              "label": "cmake",
              "type": "shell",
              "command": "cmake",
              "args": [
                  "-G",
                  "NMake Makefiles",
                  ".."
              ]
          },
          {
              "label": "nmake",
              "group": {
                  "kind": "build",
                  "isDefault": true,
              },
              "command": "nmake",
              "args": [
  
              ]
          },
          {
              "label": "C/C++: cl.exe 生成活动文件",  // 这里和laubch.json的`preLaunchTask`值保持一致
              "dependsOn": [
                  "cmake",
                  "nmake"
              ]
          }
      ]
  }
  ```

## 6. 可能遇到的问题

### 不显示局部变量

​	描述：根据群里看到，断点开始debug后，并不显示当前代码里的局部变量。

​	解决办法：在launch.json中添加一行=="justMyCode":false==。  

## 7. 获取变量代表的值task.json

先ctrl+shift+p，然后输入==run task==,一般第一次会让创建一个task.json,然后在里面写上这些验证内容：

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "my_msvc",
            "type": "shell",
            "command": "echo",
            "args": [
                "${workspaceFolder}"
            ],
        }
    ]
}
```

然后在ctrl+shift+p，选择run task来执行就可以获得\${workspaceFolder}变量是什么，也可以直接在command中直接写上=="command": "echo ${workspaceFolder}"==,也可以是其它的要执行的命令。

如果要改task.json中的内容，一般是在第二次往后可能会用到，在输入run task选择后，就会出现第一次配置的task.json的名字，这个例子就是上面的“my_msvc”，然后点击后面的设置图标就能进来修改内容了。

