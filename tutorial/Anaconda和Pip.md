- 启动jupter的命令：jupyter notebook
- **`shell中激活conda的python环境`**：
  shell脚本里面写上 conda activate my_env_name  是无法激活虚拟环境的，会报错，
  要用`source  /root/anaconda3/bin/activate  a_env_name`,centos7实测可行，更多的其它方式看[这](https://www.zhihu.com/question/322406344/answer/2175114858)。

conda install 和 pip install 的区别，看anaconda的官方怎么说的，[这](https://www.anaconda.com/blog/understanding-conda-and-pip)。简单来说，基本一样，conda install 会更全面的检查依赖关系，以后或许可以试试conda install,特别在pip install失败时。

## Pip

pip show numpy：就会看到它的安装路径和依赖的库

1. pip国内镜像下载，示例：
   pip install spaCy -i https://pypi.tuna.tsinghua.edu.cn/simple/
   pip install opencv-python==4.2.0.32 -i https://mirror.baidu.com/pypi/simple

   其它镜像源：

   - 清华：  -i https://pypi.tuna.tsinghua.edu.cn/simple/
   - 阿里：  -i https://mirrors.aliyun.com/pypi/simple
   - 豆瓣：  -i http://pypi.douban.com/simple/
   - 百度：  -i https://mirror.baidu.com/pypi/simple

2. ==升级包==：pip install -U pandas

3. ==pip包的导出和安装==：

   - 包导出：pip freeze > requirements.txt   # 不要用pip list啊

   - 包安装：pip install -r requirements.txt

     Tips：

     - pip list 是把所有安装的包都列出来，pip freeze 是把安装了包以 requirements format输出（两个结果基本一样）；前者方便直观查看，后者是-r安装需要的格式 
     - 虚拟环境直接pip时，总是有warning，解决：
       python -m pip install --user tqdm 

4. ==在线下载whl格式安装包==：（方便一台有网的机子直接下好离线库，到另外一台机子上安装）

   - pip download numpy -d /home/source      # 把单个包以whl格式保存到本地
   - pip download -r /tmp/requirements.txt -d /tmp/paks/  # 基于列表进行下载

5. ==设置pip的默认镜像源==：

   1. windows：

      1. 方式一：推荐这吧

         - win+r 然后输入 %APPDATA% ，进到用户资料文件夹，看有没有一个 pip 的文件夹，要是没有就创建，然后在里面新建一个 pip.ini 的文件，内容如下：

           > [global]
           > index-url=https://pypi.tuna.tsinghua.edu.cn/simple/
           >
           > [install]
           > trusted-host=tsinghua.edu.cn

      2. 方式二,命令行方式，两步：

      - 第一步：pip install -i https://pypi.tuna.tsinghua.edu.cn/simple  pip -U      (这个好像就是简单升级的命令啊)
      - 第二步：pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple   
        这个执行了，就有一句“Writing to C:\Users\dell\AppData\Roaming\pip\pip.ini”

   2. linux：

      - 直接执行这一句就好：
        pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple 
      - 这就会把这个写进~/.config/pip/pip.conf这个文件内

   3. 注意：（无论是虚拟环境pip还是啥，一个执行，都是写在这里，其它都会用）

pip安装时，有时编译很慢，它就用了一个核，可以看看[这里](https://www.codenong.com/26228136/)用多核：不改make的情况下，加这个参数？暂时还没试过
               pip3 install --install-option="--jobs=6"  pyside  # 主要加后面这个参数（试了安装编辑mmcv-full时会直接报错）

## Anaconda

[这是](https://mp.weixin.qq.com/s/DnLJbvVUhTx87-S24FXd8w)conda的一个比较全的使用。（里面还有更改conda的镜像源地址）

​	以后安装anaconda后不要在添加环境变量，就把 anaconda3/condabin/ 这个路径添加到环境变量，然后一切就使用conda的命令。（安装anaconda时，最后问要不要conda init，选择yes）

\# 虚拟环境还可以用这个包 pipenv ，这跟anaconda无关的 

把anaconda的环境整个复制到别的地方去后，就需要./conda init 一下，再重启一下shell（要到conda命令在的地方）

可以使用conda deactivate把前面的base关掉(临时)，
永久关闭是conda config --set auto_activate_base false  # 这就是在文件 ~/.condarc 中添加了一句配置

常用基础命令：

1. ==查看当前虚拟环境==：conda env list
2. ==创建虚拟环境==：conda create -n my_env_name python=3.7 -y   # 这就创建3.7的虚拟环境
3. ==克隆已有环境==：conda create -n my_env_name --clone base  # 这就是从名叫base环境克隆一个名叫my_env_name的虚拟环境
4. ==删除虚拟环境==：conda remove -n my_env_name --all      # -n亦可写作--name

---

conda通过配置文件创建虚拟环境，

1. 通过yml文件：（推荐使用这种）
   - 导出环境：conda env export -n a_env_name > environment.yml
     - -n参数是也可将指定另一个虚拟环境的名字；可以不要，就代表默认导出当前环境;
     - 后面的文件名可以改,用这个名字方便后续导入时可以不用指定文件名
   - 创建环境：conda env create -f my_another.yml
     - -f这个参数可以不要，前提是当前文件夹下必须要有“environment.yml”这个文件;
   - Tips：
     - 还可以通过 -p  a_Path  来指定虚拟环境的安装地址（不要使用）;
     - environment.yml最后一行是安装地址，建议直接删除不要（安装时如没有用-p指定，最后一行有prefix,如果prefix的地址存在，就会把虚拟环境安装到那，那地址如果本机不存在，就会默认安装到conda的env目录)；
     - 同样指定参数-p后，一定会装那里，这是虚拟环境就不好统一管理，也不好直接conda activate这个虚拟环境，所以不要加-p
2. 还有一种形式，（放这里作为了解吧，暂时没怎么看到用过，试了下这种，创建环境时也总是报错）
   - 导出环境：conda list --export > this_requirements.txt
   - 创建环境：conda create --name a_env_name --file this_requirements.txt

---

看到anaconda的一个安装环境的命令：
conda install pytorch==1.9.0 torchvision cudatoolkit=11.1 -c pytorch -c nvidia