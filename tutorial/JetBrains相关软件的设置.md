统一设置下：

- 字体：14号；
- 字体默认的：JetBrains Mono；
- 在 Keymap 中搜索：
  -  1、==reformat==将其的快捷键设为ctrl + T 来格式化代码；
  - 2、通过按键ctrl+F4来查找关闭当前编辑的tab，然后添加快捷键 ==ctrl+w==
  -  3、设置debug==调试==的快捷键和vs、vscode一样(默认设置输入F7就能快速找到debug的位置)：
     - F10逐过程(step over)、F11逐语句(进到里面)(step into)、shift+f11跳出(srep out)、F5跳到下个断点(run to cursor)
     - 但是在jetbraibs中，F11相关的快捷键都是给的Bookmarks  （还是挺好用的）
       - F11：Toggle Bookmarks：就是将当前行加入书签标记，
       - shift+F11：Show Bookmarks：将书签一定范围内的代码显示出来
       - ctrl+F11：Toggle Bookmarks Mnemonic：给标签添加快捷键
       - ------以上是原来的快捷键，为了保留功能，加了以下修改-------
         - 将标记书签改为：ctrl+F11   # 原来的这个快捷键的功能就不加了
         - 将展示书签(show Bookmarks)：ctrl+alt+F11  
  -  4、设置F2改文件名：在快捷键中通过按键shift+F6(本来的快捷键)，然后添加一个F2，原来的也不用去掉，暂时没发现冲突。
- 搜索 Smart Keys，然后在里面把这两个选项取消掉（针对自动括号的）
  - insert paired brackets(),[],{},<>
  - insert pair quote
- 原来的 F12 是“jump to last tool window”(及写代码时按一下能去到终端之类的)，现在改成 “go to declaration or usages”（去到代码定义），对应的自带的快捷键还有：
  - ctrl+B、ctrl+鼠标点一下、鼠标中键点一下；  # 前面是默认的，现在还加了F12
- 进入代码后的返回ctrl+alt+左：同时加了vs的快捷键  ctrl + - 
  对应的ctrl+alt+右：ctrl + shift + -

---

统一的一些快捷键：

- 按住ctrl,点击打开的标签页，可以快速在explorer中打开；
- 按住 alt,然后对打开的标签页或是文打开的文件，双击鼠标左键，可以快速分页对比；
- 选中一些行后，按 ctrl+shift+上下 可以移动选中代码；
- 按住shift+alt后，鼠标的选中就成了vim的可视块模式，可垂直选中矩形区域（右键代码编辑区域，选择‘Column Selection Mode’也是一样的效果）
- 出现智能提示后，比如一个函数名，按 ctrl+shift+I 右边就会出来这个函数的实现，就不用点进去就能看到。

## Clion

主要是编译环境的添加：Setting--->Build,Execution,Deployment--->Toolchains

然后添加各种环境即可：
`MinGW`：选择它的安装目录就好了，然后它就会自动侦测它相关的gcc、gcc、gdb地址

`MSVC`：Environment那一栏的地址写到类似这里就行了：==D:\Program Files (x86)\Microsoft Visual Studio\2017\Community==，剩下的它会自动去侦测相关的地址

- architecture这一栏来选择x86还是x64

  - ==32/64==位系统编译在==32==位系统上运行 => ==x86==
  - ==32==系统上编译==64==位系统上运行 => ==x86_amd64==
  - ==64==系统上编译在64位系统上运行 => ==amd64==    (所以里面的amd64就是x64)

  还可以看到这里面的选项还有 amd64_x86 ,所以这应该就是vs中：D:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.16.27023\bin 里面的目录结果

  > bin
  > ├── Hostx64
  > │   ├── x64
  > │   └── x86
  > └── Hostx86
  >     ├── x64
  >     └── x86

这个就不建议使用remote服务器环境了，它会把本地项目的所有文件上传到服务器/tmp的一个临时文件夹下，然后因为本地一些图形化库的缺失，本地图形化显示也有问题，不如就直接用vscode的remote。

==快捷键==：

- 去settings的keymap中，搜索定义跳转(ctrl+B)，然后在里面添加一个快捷键F12；

## Pycharm

- 若是在pycharm中运行py文件时，是在Python Console中运行的，怎么修改呢，看[这里](https://blog.csdn.net/Cinderella___/article/details/84290558)。
- 垂直块选中：
  - 按住 alt shift 就可以让光标以垂直块的方式选中
  - alt shift insert 三个键就是垂直块选中打开/关闭的快捷键，或者右击，选择“Column Selection Mode”
- matplotlib展示的图不要在pycharm中显示，而是弹出来，那就在“Settings | Tools | Python Scientific | Show plots in tool window，去掉”
- ctrl+shift+I  可以快速查看定义而不用新开一个页面
- pycharm可以debug javascript的代码：[这里](https://www.jetbrains.com/help/pycharm/2021.2/debugging-javascript-in-chrome.html#debugging_js_on_local_host_development_mode)。
- 快捷键：
  - 不同文件比较：在文件中选中一个文件，再按 ctrl d 就会让选择另外一个文件，就可以将两个文件进行不同处的对比；
  - ctrl + j 可以显示代码模板
  - ctrl + b 可以查看代码定义(就是ctrl+鼠标左键点进去)
  - 按F2可以快速定位到错误的位置

## WebStrom

在body中写代码，回车换行不缩进：Editor-->Code Style-->HTML中(Other)把==DO not indent children of==中的body删掉就好了。

shift + enter 快速换到下一行

缩进就两个空格的解决：点击右下角的的 2 spaces 然后再点击最下面那行 disable ... 就行了

## Terminal

win新的终端的一个我自己改的json配置：

新加了个配色方案：（改的系统颜色）

- 前景：（直接给 0 255 255似乎更不错，或者255,255,255朴素的，这俩对比度都更强），204,255,255有些淡
- 背景：DarkOliveGreen  85 107 47   

然后给每种终端加了图标颜色，还有一些快捷键的修改，放这里作为一个后续修改的参考

```
{
    "$help": "https://aka.ms/terminal-documentation",
    "$schema": "https://aka.ms/terminal-profiles-schema",
    "actions": 
    [
        {
            "command": 
            {
                "action": "newWindow"
            },
            "keys": "ctrl+n"
        },
        {
            "command": 
            {
                "action": "copy",
                "singleLine": false
            },
            "keys": "ctrl+c"
        },
        {
            "command": "paste",
            "keys": "ctrl+v"
        },
        {
            "command": "find",
            "keys": "ctrl+f"
        },
        {
            "command": 
            {
                "action": "splitPane",
                "split": "auto",
                "splitMode": "duplicate"
            },
            "keys": "alt+shift+d"
        },
        {
            "command": "closePane",
            "keys": "ctrl+w"
        },
        {
            "command": "unbound",
            "keys": "ctrl+shift+f"
        },
        {
            "command": "unbound",
            "keys": "ctrl+shift+n"
        },
        {
            "command": "unbound",
            "keys": "ctrl+shift+w"
        }
    ],
    "copyFormatting": "none",
    "copyOnSelect": false,
    "defaultProfile": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
    "profiles": 
    {
        "defaults": 
        {
            "backgroundImage": null,
            "colorScheme": "Color Scheme 11",
            "font": 
            {
                "face": "Consolas"
            },
            "opacity": 100,
            "useAcrylic": true
        },
        "list": 
        [
            {
                "commandline": "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
                "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
                "hidden": false,
                "name": "Windows PowerShell",
                "tabColor": "#4169E1"   // 这个标签就是自己加的颜色
            },
            {
                "commandline": "%SystemRoot%\\System32\\cmd.exe",
                "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
                "hidden": false,
                "name": "\u547d\u4ee4\u63d0\u793a\u7b26",
                "tabColor": "#008B8B"
            },
            {
                "guid": "{b453ae62-4e3d-5e58-b989-0a998ec441b8}",
                "hidden": true,
                "name": "Azure Cloud Shell",
                "source": "Windows.Terminal.Azure"
            },
            {
                "guid": "{c9ffafc7-3311-5dd1-9c24-aeca61610a99}",
                "hidden": false,
                "name": "Developer Command Prompt for VS 2017",
                "source": "Windows.Terminal.VisualStudio",
                "startingDirectory": null,
                "tabColor": "#FFDAB9"
            },
            // 下面这俩anaconda相关的在配置页面就可以加了，
            {
                "commandline": "%windir%\\System32\\cmd.exe \"/K\" D:\\Anaconda3\\Scripts\\activate.bat D:\\Anaconda3",
                "guid": "{c46e0fa6-1ec9-4a03-a37d-cf2c1b1c63cd}",
                "hidden": false,
                "icon": "D:\\Anaconda3\\Menu\\Iconleak-Atrous-Console.ico",
                "name": "Anaconda Prompt (Anaconda3)",
                "tabColor": "#EEAD0E"
            },
            {
                "commandline": "D:\\Anaconda3\\python.exe D:\\Anaconda3\\cwp.py D:\\Anaconda3 D:\\Anaconda3\\python.exe D:\\Anaconda3\\Scripts\\jupyter-notebook-script.py \"%USERPROFILE%/\"",
                "guid": "{fdb56f01-916e-4183-bec9-978afb9ce6ea}",
                "hidden": false,
                "icon": "D:\\Anaconda3\\Menu\\jupyter.ico",
                "name": "Jupyter Notebook (Anaconda3)",
                "tabColor": "#B22222"
            }
        ]
    },
    "schemes": 
    [	
    	// 这个是系统默认的，还删掉了一些
        {
            "background": "#0C0C0C",
            "black": "#0C0C0C",
            "blue": "#0037DA",
            "brightBlack": "#767676",
            "brightBlue": "#3B78FF",
            "brightCyan": "#61D6D6",
            "brightGreen": "#16C60C",
            "brightPurple": "#B4009E",
            "brightRed": "#E74856",
            "brightWhite": "#F2F2F2",
            "brightYellow": "#F9F1A5",
            "cursorColor": "#FFFFFF",
            "cyan": "#3A96DD",
            "foreground": "#CCCCCC",
            "green": "#13A10E",
            "name": "Campbell",
            "purple": "#881798",
            "red": "#C50F1F",
            "selectionBackground": "#FFFFFF",
            "white": "#CCCCCC",
            "yellow": "#C19C00"
        },
		// 这个就是自己在配色方案里加的，然后在这里生成，
        {
            "background": "#556B2F",
            "black": "#000A00",
            "blue": "#0037DA",
            "brightBlack": "#767676",
            "brightBlue": "#3B78FF",
            "brightCyan": "#61D6D6",
            "brightGreen": "#16C60C",
            "brightPurple": "#B4009E",
            "brightRed": "#E74856",
            "brightWhite": "#F2F2F2",
            "brightYellow": "#F9F1A5",
            "cursorColor": "#FFFFFF",
            "cyan": "#3A96DD",
            "foreground": "#00FFFF",
            "green": "#13A10E",
            "name": "Color Scheme 11",
            "purple": "#881798",
            "red": "#C50F1F",
            "selectionBackground": "#FFFFFF",
            "white": "#CCCCCC",
            "yellow": "#C19C00"
        },
        // 这是微软里面那个毛玻璃啊，暂时也不是很好使
        {
            "background": "#FFFFFF",
            "black": "#3C5712",
            "blue": "#17B2FF",
            "brightBlack": "#749B36",
            "brightBlue": "#27B2F6",
            "brightCyan": "#13A8C0",
            "brightGreen": "#89AF50",
            "brightPurple": "#F2A20A",
            "brightRed": "#F49B36",
            "brightWhite": "#741274",
            "brightYellow": "#991070",
            "cursorColor": "#FFFFFF",
            "cyan": "#3C96A6",
            "foreground": "#000000",
            "green": "#6AAE08",
            "name": "Frost",
            "purple": "#991070",
            "red": "#8D0C0C",
            "selectionBackground": "#FFFFFF",
            "white": "#6E386E",
            "yellow": "#991070"
        }
    ]
}
```

