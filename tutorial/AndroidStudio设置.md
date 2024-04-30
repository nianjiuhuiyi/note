pycharm激活看到的一个方法：
1.先选择：License server
2.输入：http://idea.imsxm.com
3.点击：Activate完成了；

使用前JAVA环境配置：[这](https://www.jdkdownload.com/)。

## 一、安装

​	以下前3步操作尽量就在安装软件前就先修改好，安装完后做了第4步再去打开软件，避免后续麻烦：

1、修改配置模拟器(就是AVD Manger，模拟安卓手机的)生成的，也是最占空间的一个:

添加一个系统变量

>变量名(N): ANDROID_SDK_HOME          # 名字是固定写法 
>
>变量值(V): D:\Cache\Android\AVD       # 建议这么写，可以自定义

***

2、.gradle缓存文件夹的修改(后期加载android项目时，这会占用挺大空间)

添加一个系统变量

>变量名(N): GRADLE_USER_HOME      # 固定写法
>
>变量值(V): D:\Cache\Android\\.gradle    # 注意这里.前面有个转义符

Ps：这是[官方文档](https://developer.android.com/studio/intro/studio-config?utm_source=android-studio#antivirus-impact)建议的做法，还可以打开软件去修改。(就像上面这么做)

***

3、这应该是修改sdk存放的位置：

添加一个系统变量（好像没啥用，但去弄一个嘛，==建议安装的时候选择自定义安装==，这样可以选择Sdk位置，占用内存这些）

> 变量名(N): ANDROID_HOME
>
> 变量值(V): D:\Cache\Android\Sdk

​	不搞第3步的sdk的话，可能会说找不到sdk.dir，然后也可以在项目的顶级目录下，编写一个名为`local.properties`的文件，然后里面的内容就一行`sdk.dir=D\:\\Cache\\Android\\Sdk` 

4、然后去安装路径的bin目录下修改`idea.properties`文件（jetbrains系列）：

​	这就是把一些工程文件的缓存路径改一下，==JrtBrains的所有软件也都改一下==。类似于：

- ```
  #---------------------------------------------------------------------
  # Uncomment this option if you want to customize a path to the settings directory.
  #---------------------------------------------------------------------
  # idea.config.path=${user.home}/.PyCharm/config
  idea.config.path=E:/Cache/JeaBrains/Pycharm_profession/.PyCharm/config
  
  #---------------------------------------------------------------------
  # Uncomment this option if you want to customize a path to the caches directory.
  #---------------------------------------------------------------------
  # idea.system.path=${user.home}/.PyCharm/system
  idea.system.path=E:/Cache/JeaBrains/Pycharm_profession/.PyCharm/system
  
  #---------------------------------------------------------------------
  # Uncomment this option if you want to customize a path to the user-installed plugins directory.
  #---------------------------------------------------------------------
  # idea.plugins.path=${idea.config.path}/plugins
  idea.plugins.path=E:/Cache/JeaBrains/Pycharm_profession/plugins
  
  #---------------------------------------------------------------------
  # Uncomment this option if you want to customize a path to the logs directory.
  #---------------------------------------------------------------------
  # idea.log.path=${idea.system.path}/log
  idea.log.path=E:/Cache/JeaBrains/Pycharm_profession/log
  ```

-----------------------------------------

-------------------------------------------------------------------------

​	以上操作完成后，打开软件，当有一个提示时选择cancle，如果是默认安装，它就会自己把andriod sdk下到类似于这样的路径：`C:\Users\Administrator\AppData\Local\Android\Sdk`,等它下好后，把这个Sdk文件夹整个复制到你想要放的地方（避免后续二次下载），然后进入软件设置，搜索一下`SDK`，然后把那个路径改成你想要放的地方。再去把C盘里的删除就好了。

​	所以为了避免麻烦，一点要选择==custom安装==，这样就能选择andriod sdk的下载路径。

## 二、Hello-World

1. 新建项目时，选择中间的==Empty Activity==,如果是选择No Activity，里面的res是没有layout层的；接着语言是选择JAVA(选择kotlin也能使用)
2. 然后点开lauout里的activity_main.xml==可能是看不到代码的，要点右上角的Code==;

Tips：

- AVD的机子，尽量先选用==Nexus 6==这个机子，（用Pixel 2这机子那个半天安装install不上）
- 让虚拟手机==使用电脑的摄像头==：AVD Manger找到要设置的手机，点击倒三角中的Edit-->Show Advanced Setting，然后就能修改Camera

## 三、问题解决

问题：	

​	CMake '3.10.2' was not found in PATH or by cmake.dir property.

解决:

​	进到SDKmanger 然后SDK tools，选择Cmake安装，然后重启一下，不行，就再把==Show Package Details==打开，把那些都勾上，再重启。

---

问题:

​	No toolchains found in the NDK toolchains folder for ABI with prefix: arm-linux-androideabi

解决：

​	重启软件，弹出提示gradle升级时，记得去升级，升级了就好了

---

问题：

​	运行时，一直卡在waiting for target device to come online

解决：

​	先把所有的模拟手机关掉，然后在AVD Manger中找到自己要运行的机子，点击最右边的倒三角，选择==cold boot now==就可以了。

---

问题：

​	Device supports x86, but APK only supports armeabi-v7a, arm64-v8a ondevice New Device API 29

解决(可能会有其他问题)：

​	在app文件夹里找到build.grade文件，找到==defaultConfig==，里面ndk下有abiFilters的后面添加上==x86==,再重新build && run。（因为用的虚拟设备，可以看到其ABI就是x86）