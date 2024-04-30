- git clone https://github.com/nianjiuhuiyi/html_study.git ./123/456   # 把这个项目的全部内容clone到这个目录下(相当于这个项目clone下来后，改名成后面这个)，目录如果不存在，便会自动创建，如果存在，这个目录一定要为空。
- git LFS：一个插件，对大文件进行管理的，可看这篇[文章](https://zhuanlan.zhihu.com/p/473651876)学习使用。
- 一般来说，多人合作流程是这样的：
  - 是先创建的远程仓库，然后 git clone下来，
  - 创将一个自己本地的分支，git branch a_fenzi 然后切换到这个分支开发
  - 把分支推送上去: git push origin a_fenzi   # 后面这是分支名
  - **将当前分支与远程的分支关联起来**：git branch --set-upstream-to=origin/a_fenzi a_fenzi  # 这样如果本地分支跟远程分支不一样，git status就能看到提示，没设置之前是没有这个的
  - 后续再推送本地分支到远程，直接只要==git push==这俩个单词就行了
- 当git从远程仓库update到本地时，当本地有未被tracked的文件，而此文件又与远程同目录下文件存在同名情况，就会merge失败，就会得到这样的提示“Untracked Files Prevent Merge Move or commit them before merge”
- 项目里有子项目时：
  - git clone --recursive https://项目地址
  - 如果一开始没加 --recursive 就克隆下来后，可以再进到项目里执行如下命令：
    git submodule update --init --recursive

## 一、初级基本命令

### 1.1 配置账号

安装好git，第一次打开要设置这个，打开Git Bash,

​	（在公司不建议这么做，账号可能是有变的，每个新仓库去单独设置，把个人的公司的分开。如果没有全局设置，那从远程clone下来的仓库，直接commit的账户是它原来的账户，如果是别人的仓库，就必须要设置才能commit）
git config --global --list 先查看一下设置了没有。

- 公司：
  git config user.name "宋辉"
  git config user.email "songhui@lingyaoai-mail.com"
- github:
  git config user.name "nianjiuhuiyi"
  git config user.email "nianjiuhuiyi@vip.qq.com"


```shell
git config --global user.name "Your Name"  # 不加--global就是代表对这个仓库设置
git config --global user.email "email@example.com"        
```

​	注意 git config  命令的 --global  参数，用了这个参数，表示你这台机器上所有的Git仓库都会使用这个配置，当然也可以对某个仓库指定不同的用户名和Email地址,它只是为了区分谁是代码的提交者，和后面使用的托管中心的账号没有任何关系,后续也可以随时修改。

​	执行后生成的配置文件是在C:\Users\Administrator\\.gitconfig  #(Administrator是用户名)，然后后续是介意改这个的。

==特别注意==：（这挺重要的）

- 邮箱地址尽量就用自己的一个真的邮箱(不用应该也行)，然后在github上的settings里的Emails中的Add email address，把这个邮箱添加进去，这样以后本地push到github的代码才在个人页面的contributions中有记录，[这里](https://docs.github.com/cn/account-and-profile/setting-up-and-managing-your-github-user-account/managing-email-preferences/setting-your-commit-email-address#about-commit-email-addresses)；还有一些其他可能，导致contributions中没有记录，[这里](https://docs.github.com/cn/account-and-profile/setting-up-and-managing-your-github-profile/managing-contribution-graphs-on-your-profile/why-are-my-contributions-not-showing-up-on-my-profile)。

- 所以自己的不同电脑上的git设置的user.name，user.email可以是完全一样的；当然可以用不同的user.name做个区分，但user.email就尽量还是一个，而且是添加到github中了的；

- 堪比人仓库的提交记录，名字后面总是带一个星号*，具体的详细信息里有"committed by GitHub <noreply@github.com>",这种就是代表使用了github隐藏邮箱的私密性保护，具体可以看[这里](https://docs.github.com/cn/account-and-profile/setting-up-and-managing-your-github-user-account/managing-email-preferences/setting-your-commit-email-address#about-commit-email-addresses)。
  
  - 上面链接提到了，这里也出现了，在fork的代码里做修改是不会在个人页面有贡献的显示，必须要提PR且被merge后才会有显示。
  
- 如果git push时出现错误：

  ```
  """
  error: unable to rewind rpc post data - try increasing http.postBuffer
  error: RPC failed; curl 56 OpenSSL SSL_read: Connection was reset, errno 10054
  send-pack: unexpected disconnect while reading sideband packet
  fatal: the remote end hung up unexpectedly
  """
  是说明发送的数据量超过了预设的缓冲区大小，用下面的命令增加缓冲区大小
  ```

  ```
  git config --global http.postBuffer 524288000  # 设置为500MB
  ```

  

#### 设置代理

建议用一次设置一次，当次用完，当次就取消，避免下次没开vpn就一直用不了。

> - 查看全局配置
>   git config --global --list
>
> - 设置全局代理（https + http）（一般设置这两个就行了，一起设置，代表所有http、https）
>   git config --global http.proxy "http://127.0.0.1:10809"
>   git config --global https.proxy "http://127.0.0.1:10809"
>
> - 设置全局代理（socks5）)(这个一般就不用了，上面两个就够用了，这是指定github这个网址才代理)
>   git config --global http.https://github.com.proxy socks5://127.0.0.1:10808
>   git config --global https.https://github.com.proxy socks5://127.0.0.1:10808
>
> - 取消代理（==每次用完后，来这取消一下==，因为有时候会没开vpn）
>   git config --global --unset http.proxy
>   git config --global --unset https.proxy
>   - 如果要取消socks5这个代理，就 git config --global --unset http.https://github.com.proxy   # 从这里也可以发现是可以指定就某个具体网址使用代理，

### 1.2 创建管理仓库

创建一个文件夹专门用于存放项目文件

`git init` 命令把这个目录变成Git可以管理的仓库

```shell
cd 到这个目录下
git init       # 生成.git/文件夹
Initialized empty Git repository in /地址/.git/  #成功会得到类似这样的提示
```

#### 1.2.1 add添加暂存区

​	在此目录放入一个文件readme.txt，再`git status`就能获取此时仓库状态，(若是有东西被修改过没提交就会提醒；若是没有修改，就会说类似这种 nothing to commit, working tree clean)

​	然后使用`git add readme.txt`把此文件放进`暂存区`(可以同时add多个文件)，一般会得到一个warning: LF will be replaced by CRLF in readme.txt.，这是我们安装的时候勾选了一个，它会根据系统，来将换行符进行相应的替换;

​	暂存区文件是可以删除的，使用`git rm --cached 文件名`。

当需要add的文件过多时，可以直接执行`git add -A`就会把所有文件add。 # 好像 git add . 也是一样的，全部添加

#### 1.2.2 commit提交

`git  commit -m "一些关于提交的说明"` # 这样是会把暂存区的全部提交   # 说明是必须要有的，方便知道版本改动

`git  commit -m "一些关于提交的说明" a_file b_file`  # 可以指定只提交哪些文件

#### 1.2.3 查看版本信息

`git reflog`  # 这可以查看简略的版本信息

`git log`    # 这可以查看各个版本的详细信息，包括是谁提交的，什么时候提交的

`git log --pretty=oneline`   # 也是查看所有版本历史记录，比较简洁的那种，一个版本一行

​	修改文件，提示都会是修改一个文件，新增一行，删除一行(因为是按行维护的，无法表达修改，就是把原来那行删除，再新增一行)

`git checkout -f 9eb4831 `    # 这就是切换到指定版本

#### 1.2.4 查看版本差异

`git diff 一版本号 二版本号 readme.txt`  # 就是版本二相较于版本一的改动

`git diff readme.txt`    # 就会默认最新版和本地进行对比

或者git diff HEAD -- readme.txt   # 这两个是一样的

#### 1.2.5 版本回退

```shell
git reset --hard HEAD^   # 回退到上一个版本
git reset --hard HEAD^^   #回退到上撒谎逆过个版本
git reset --hard HEAD~100  # 回退到往上100个版本
git reset --hard 33b47fd   # 使用版本号回退
```

​	回退到老版本后，`git log` 命令就看不此版本后的版本信息，这个时候就要使用`git reflog`命令(这里记录我的每一次版本变更的记录)；这是已经提交到版本库里，进行版本回退；

​	下面是还未提交到版本库的回退（这下面的操作也会清除掉本地工作目录文件，若只是想删除暂存区的文件，使用上面的方法）：

- 只在本地修改了，还未git add到暂存区时，使用`git checkout -- readme.txt`就可以把改了的东西全部删除，回到改之前的样子;
- 本地修改后，也git add到暂存区了，但是还没git commit到版本区，那就分两步走: 
  - 这时就是`git reset HEAD readme.txt`这时候暂存区就没了;
  - 再执行`git checkout -- readme.txt`，本地的也就恢复到原来的了。
  - 但是：不建议这个使用了吧，按照git的提示，使用`git restore readme.txt`就直接会直接删除暂存区的，也会把工作的修改改回去

#### 1.2.6 删除文件

已经提交到了版本库里了，然后本地本一些不要的文件删除了，想要把版本库里的也删除了：

```shell
git rm test.txt   # 就是本地删除，然后提交就行了
git commit -m "remove test.txt"      # 这两步就是把版本库里的 也删除了
```

​	但是如果是本地误删除了，那就是使用`git checkout -- test.txt`把误删的文件恢复到最新版本(`git checkout`其实是用版本库里的版本替换工作区的版本，无论工作区是修改还是删除，都可以“一键还原”)

### 1.3 分支(branch)

创建分支，就是把当前的代码复制出去一份

查看当前分支：`git branch -v`;   -a 就是获取所有分支

创建分支：`git branch 分支名`;

切换分支：`git checkout 分支名`;

合并分支：`git merge 分支名`;   # 把指定分支合并到当前分支（merge会把所有的都一次合并）
	合并时，如果没有冲突，能快速合并就会是快速合并，相当于把Head指针又指到了master去了(不会产生新的commit)；没有冲突，也可能不能快速合并，就是分支和master都改了东西，但是不冲突，就会直接把分支的新东西拿到master来，那就需要做一次commmit，git界面就会让输入这次commit的备注内容，按ctrl + s 确认保存退出。
	快速提交就看不到分支的信息(分支修改了，master还没改，这时meger分支，默认就直接把Head指到master中去了)，若想保留分支信息，不想快速提交，那就加参数： git merge --no-ff -m "禁用fast-forward合并" fenzi  # 这样就不单单只是移动Head的指向，是会有一次新的提交（这个的主要就是bug分支的使用，修复一个bug分支，merge时没有冲突，禁用快速提交来留存记录，不然分支删了就啥都没了）

删除分支：`git branch -d 分支名`;  # 合并后，就可以把这个分支删了，建议删

- 当没有冲突的时候，一般是分支在master上直接修改一些内容，而master没有修改，就很容易合过来，没有冲突

Tips：

- 当手头工作没完成，先把工作现场保存一下 git stash 然后去做别的，做完后，再 git stash pop 回到之前的工作现场；
- 分支的管理使用，快速提交，这里都写挺好（".\就业班\12 git版本管理(看过了)\02-git分支管理\03_git分支_分支管理策略.flv" 以及04\_git分支\_bug分支.mp4）

##### 1.3.1 分支合并冲突

​	但是有冲突的时候，就会报错`CONFLICT`，master分支后面也会带一个标识`MERGING`,说明融合出现了冲突，正在解决冲突中；这时去git status就会得到` both modified:   冲突文件名`,解决：

- vim readme.txt,会得到类似这样：

  > <<<<<<< HEAD           # 这代表当前分支
  > this add a
  >
  > the same content
  >
  > for confilct aaaaa
  >
  > \==\=====                # 中间是固定的分割符号
  >
  > this  a line           # 显然这行冲突了
  >
  > the same content        # 这行是一样的
  >
  > how to say              # 显然这行冲突了
  >
  > \>>>>>>> fenzhi        # 这是要融合的分支

那就要选择怎么怎么保留，最重要改成这样(记得把无关的去掉)：

> this add a           # 保留了当前分支的第一行
>
> the same content       # 一样的内容留一个就好了
>
> how to say             # 保留了分支的第三行

改好了后，就git add readme.txt,然后再commit，冲突解决后，master后的`MERGING`也就没有了；

Tips:

- 解决冲突时的commit不能带文件名，直接commit，形成一个新的commit；
- 冲突修复commit只会结果只会影响当前分支，对来融合的分支是没有影响的，它结果还是原来的

### 1.4 tag的相关处理

一般来说，某个版本代码想要添加表示版本的信息，就可以给此时的代码版本打一个tag，

- 创建tag标签：`git tag -a v1.0 -m "正式版1.0"` 
  - -a  创建指令，后面是这个tag的名称，一般都是v1.0、v1.1之类的，这默认都是打的最近commit的版本，若要指定其它版本打标签，就就是 -a v1.0 具体的commit的版本号 -m "正式版1.0"
  - -m  备注内容，放提示信息
- 查看tag标签：`git  tag` 
- 标签推送同步到github：`git push origin v1.0`    # pycharm的push界面的左下角可以选择push tag，可看[这](https://www.cnblogs.com/yoyoketang/p/12483465.html)。
  - origin 是远程地址的一个替代，可以是其它你起的名字
  - v1.0 是要推送的tag名，若是要推送全部，则把这v1.0的tag名改成==--tags== 
  - 查看远程服务器标签：git ls-remote --tags
- 删除tag标签：`git tag -d v1.0` 
- 回退到指定tag标签：`git checkout v1.0` 
  - Tips：实际中，一般都是先创建新的分支，再checkout相应的tag代码，再在此基础上进行分开发

说明：

- github上的tag都是推送上去的，github网页上应该是没办法打tag的，然后一般的理解就是一个tag就是一个ok的版本；
- github上就可以创建一个Realease，会让选择一个tag，起一个标题名字，然后在描述这个里的内容，像mmdetection的就会写很多，然后还可以把编译的二进制文件或是库放进去。

### 1.5 .gitignore

​	未被git记录的文件是红色的，add到暂存区后就是绿色的,commit后颜色又回到白色，忽略文件的颜色土黄色,做了修改但未add的是浅蓝色；（在这里面好像不用add，可以直接提交）

​	以后新建项目的话，直接在项目的最顶层，加一个名为==.gitignore==文件，先把".idea"添加进去，不要记录这个文件夹。如果还有其他不想被记录的文件，直接右键文件或文件夹，选择git中的Add to .gitignore (就选择上面的.gitignore,里面还有一个.git/info/exclude，这是将其放在.git路径里面，还是就用.gitignore文件吧)

Tips：

- 一定要在文件未被add添加追踪之前就要在 .gitignore 中写好，如果被add后再添加进来时没用的；
- 还可以在一个文件夹里单独写一个 .gitignore ,让它来控制这个文件夹里哪些文件不被track，如果是写的`*`，代表全部文件就不被track；
- .gitignore文件中添加目录时，如添加当前路径下的aa目录，那就是写作==/aa==,前面有个/

#### ==已经记录文件的删除==

有的时候，我们把一些文件已经添加记录后，后续不想记录它的变化，可以这么操作：

1. git rm -r --cached 删除的文件名   # 如 git rm -r --cached "\*.pt" "\*.pth" 
   这之后，这些文件就会被剔除记录
2. 再在 .gitignore 中把刚才不想要记录的文件添加进去。
3. git commit -m “一些描述”  # 提交

## 二、github远程仓库

先在github上创建一个远程库，名字尽量就填跟本地项目名字一样  (注意，尽量就写个项目名，其它什么也别填，不然总是出问题，搞不定)

### 2.1 创建远程库别名

`git remote -v`：查看当前所有远程地址别名，要删除某个的话，就：`git remote rm a_MyName` 

`git remote add 别名 远程地址`：把远程的https或是ssh地址起别名，方便用,（别名最好就起项目名吧，方便使用）

起了别名后，再查看别名，会看到一个别名有两个结果(一个对应push，一个对应fetch，但一般都是一样的)

### 2.2 push推送本地分支到远程仓库

`git push 别名 分支名`：这执行后，第一次就会让选择怎么连接github，就选择通过browser,然后验证就行了(别名处可以是https的地址，或者ssh地址)(后面一般ssh免密地址弄好后，就用下面的-u吧)

​	使用命令 git push -u origin master  ==第一次==推送master分支的所有内容(git push -u origin <本地分支名>,一般第一次时使用，这是将本地分支与远程同名分支相关联);此后，每次本地提交后，只要有修改，就可以使用命令 git push 别名 master  推送最新修改。



本地回退到上一个commit版本后，简单的git push是推不上去的，要用：==git push origin HEAD --force==可参考[这](https://blog.csdn.net/tengyuxin/article/details/126976064)。(origin是远程的别名。)

### 2.3 pull远程仓库拉取

`git pull 别名 分支名`：别名处也可以是https地址，要指定拉取到本地的分支名，拉取到本地后，工作区的代码会自动对应更新的

### 2.4 clone远程仓库克隆

`git clone 一个https地址`：clone会做如下操作：1、拉去代码，2、本地拉取代码的地方初始化本地仓库(就是.git文件)，3、创建别名（用 git remote -v 在拉取代码下看，会发现这个https地址会有别名，叫做-`origin`）

​	这里也建议直接用ssh地址克隆

### 2.5 队内协作

​	A创建了一个远程仓库，团队内的B是可以拉取代码，但是当B要push代码到远程仓库时，就会有Permission denied,那就需要A去当这个仓库。Settings--->Manage access--->Invite a collaborator--->然后要搜索你要邀请的人--->点击Pending Invite复制这个链接--->这个链接发给要邀请的人--->接受邀请的人打开这个链接同意即可，这样他也能直接往远程库上push了

### 2.6 跨团队协作

​	先fork别人的代码到自己的远程创库，然后就可以进行修改了，改了直接commit到自己的远程仓库，然后就在自己这里 Pull requests--->New pull request(这里就会跳到原来别人仓库那里，也能在界面看到自己的修改)--->Create pull request(就会出现自己commit时添加的信息，可修改（大的那一行就是后面显示的标题，要尽量突出主题，下面的`Write`可以写一说简单说明，别人也能回复这个）)--->Create pull request

​	然后就可以在最原始的仓库里的 Pull requests里看到这个请求了，点击小字体的版本信息，就能看到修改，如果觉得合适的话，就能merge。

### 2.7 ssh免密

​	建议一开始都这么搞一下，然后后面的pull、clone,就好像不受网速的影响了。

==先生成秘钥==

为一个远程仓库添加ssh秘钥：

​	看一下“C:\Users\本机计算机名”这个目录下是否有.ssh文件夹，若是没有，就执行下面

```sh
ssh-keygen -t rsa -C "your_email@example.com"   
```

​	需要把邮件地址换成你自己的邮件地址(就用本地git配置时那个地址吧)，然后一路回车，使用默认值即可。

​	由于这个Key也不是用于军事目的，所以也无需设置密码。如果一切顺利的话，可以在用户主目录里找到 .ssh  目录，里面有`id_rsa` 和`id_rsa.pub`两个文件，这两个就是SSH Key的秘钥对,id_rsa是私钥，不能泄露出去，id_rsa.pub是公钥，可以放心地告诉任何人。

==github添加公钥==

​	登陆GitHub，打开用户头像处Settings--->SSH and GPG keys--->New SSH key；

​	然后Title就任意填，建议填home，worker这些，以及家里和公司电脑区分，在Key文本框里粘贴 id_rsa.pub文件的内容。

​	然后就可以本地区去`git pull ssh地址 分支名`拉去远程库代码;好比：`git pull git@github.com:nianjiuhuiyi/git.git master`。

## 三、pycharm使用

​	在项目中有一个`.gitignore`(Jet系列的这后缀名才管用)或是`.ignore`(这是去全局配置)文件，里面放的是一些固定资源，不做版本控制的（好像网上都是叫.gitignore,教程是.ignore）

1. 添加git.exe：File--->Setting-->Version Control--->Git，把git.exe的路径放进去就好了
2. 项目初始化仓库：（之前先把忽略文件写好吧）顶部VCS--->Create Git Repository，选择在项目地址就行了
   - 若是因为网络问题，无法认证，别直接去添加remote，这时就不建议用自带的share on github了，看前面的第二大点，用命令行来处理。

​	未被git记录的文件是红色的，add到暂存区后就是绿色的,commit后颜色又回到白色，忽略文件的颜色土黄色,做了修改但未add的是浅蓝色；（在这里面好像不用add，可以直接提交）

​	分支合并后会自动提交；

## 四、集成github

### 4.1 登录设置

​	一般使用账号密码登录会很慢，半天加载不出来，就选择使用 `Log in with Token`;然后就会让填Token，如何获取Token：

- 个人头像处：Setting-->Developer settings--->Personal access tokens--->Generate new token;（Note处就填个名字吧）

- 权限的话，自己用就全部勾上吧，（在pycharm中也可以点生成，会自动跳转到这个界面）

- 然后把获取到的token复制进行登录；

当把项目推到远程库上时(远程不用提前建库)：总是说cannot load ....,然后去看账户上也是显示着connection reset，解决办法：

- Settings--->Apperance&Behavior--->System Settings--->HTTP Proxy 选择 Auto-detect proxy settings就行了

Tips(建议直接配置[ssh免密](#2.7 ssh免密))：
	使用https地址时很慢，经常失败，然后SHH的.git地址又会报“Please make sure you have the correct access rights and the repository exists.”，这是由于破解的因素，添加Token一直失败，所以没办法认证，所以就直接配置ssh，这样就能直接使用了。（到这里就算是两种认证方式吧！）

### 4.2 share仓库

​	在分享到远程仓库时，名字默认跟本地一样，下面的origin就是为了写个别名；

​	在本地修改后，要先commit，然后push到远程库的时候，可以看到它是：当前分支名(一般是master)——>一开始建仓库时的别名:远程分支名(一般也是master)；值得注意的是，这是默认就是用的https，是很慢的，那我们就要使用ssh：

- 第一步先复制这个远程的ssh地址，点上面的别名，选择`Define remote`,起个名字，把复制的ssh地址放进去，然后选择使用这个来push

Tips:

- 克隆的时候也尽量选择使用ssh链接

- 动手改本地代码之前，一定先从远程库拉去一下，改了commit再push，就是一定要保证远程库是最新的

## 五、Gitee使用

​	码云的使用跟github几乎一模一样，pycharm需要去下载gitee这个插件，实在有想不起的就看[这里](https://www.bilibili.com/video/BV1vy4y1s7k6?p=39&spm_id_from=pageDriver)。

## 六、GitLab

​	GitLab是由GitLabInc.开发，使用MIT许可证的基于网络的Git仓库管理工具，且具有wiki和 issue跟踪功能。使用Git作为代码管理工具，并在此基础上搭建起来的web服务。
​	GitLab 由乌克兰程序员 DmitriyZaporozhets 和 ValerySizov开发，它使用 Ruby语言写成。后来，一些部分用Go语言重写。

### 6.1 环境准备

#### 关于ip地址修改

​	准备一个centos7以上版本的服务器，关闭防火墙(可以先不关)，并且配置好主机名和IP，保证服务器可以上网

- 修改IP：`vim /etc/sysconfig/network-scripts/ifcfg-ens33`
  - 网卡名可能不是这，最后的`ens33`根据自己的修改
  - 一般`BOOTPROTO="dhcp"`，可以把这个改成`static`,再指定`IPADDR=192.168.*.*`,从动态分配改成固定IP
- 修改主机名：`vim /etc/hostname`,改成自己想要的主机名就行
- 在window上配置一下：修改host文件，地址:`C:\Windows\System32\drivers\etc\hosts`，里面新增一行`192.168.125.135   gitlab-server`.

==Tips==:

- 也可以是dhcp模式里新增固定IPADDR，这样这抬机子就相当于是有了两个ip地址(一个自动分配的，一个给的固定的)，且都可ping通（但是为了后续不出问题，还是就改成静态IP）

- 可以不用给网关地址、域名解析器

- 改完reboot重启以下，只是重启网卡的命名：
  
  - `systemctl restart network` 
  
- window中新增的前面ip地址、gitlab-server都是centos服务器的信息；方便在win下直接使用gitlab-server这一名字就行，相当于一个域名解析

- linux下修改成固定ip的时候，可以设置掩码、网关、DNS(好像不是必须)

  > ONBOOT=yes    # 这一项要开启(好像默认就是yes)
  >
  > IPADDR=192.168.108.125    # 改成自己要的固定ip
  >
  > NETMASK=255.255.255.0     # 固定写法
  >
  > DNS1=119.29.29.29    

### 6.2 安装

​	[这里](https://about.gitlab.com/install/?version=ce#centos-7)是centos7的在线安装，官方教程(记得在下面第5点选择CE版本)。

​	yum在线安装gitlab-ce时(-ce就相当于是社区版免费版，-ee就是企业旗舰版)，要下载几百M的安装文件，可以提前把所需要的RPM包下载到本地，然后使用rpm的方式安装。这是[下载地址](https://docs.gitlab.com/omnibus/manual_install.html)。

​	我还是根据官方文档在线安装的，手动的方式没试。

安装完毕后进行如下操作：

- 初始化GitLab服务：`gitlab-ctl reconfigure`；
- 启动GitLab服务：`gitlab-ctl start`；  # 停止是stop；重启是restart

### 6.3 使用

​	win本地浏览器直接输入192.168.125.135就可以了，第一次使用的时候，视频讲的是默认是给了一个root账户的，上来就让改root的密码，但我的是一上来就让登录或是注册：于是我去到服务器上设置了一下root的密码，具体操作是：

> - cd /opt/gitlab/bin
> - gitlab-rails console     # 进到控制台
> - u=User.all        # 查看所有用户
> - u=User.where(id:1).first  # 查找和切换到root用户
> - u.password='123456cb'     # 设置密码
> - u.password_confirmation='123456cb'   # 确认
> -  u.save!            # 保存设置

​	然后就去网页用root/123456cb登录就行了，要push到服务器时，就要先再服务器上创建一个项目，并获取链接，链接很有可能是'http://gitlab.example.com/root/mmdetection.git'这样，就要把中间的改为'gitlab-server'(win中host加的那个)或是服务器ip地址'192.168.125.135'；

​	pycharm中也要先去下载插件，搜索gitlab，安装'GitLab Projects 2020',拿到刚才的链接直接放到pycharm中去push就可以了。

#### 可能访问失败

​	肯能跟本地路由器一直访问失败，就去`vim /etc/gitlab/gitlab.rb`,把“external_url 'https://gitlab.example.com'”这一行中的https改成http；

​	看了以下，本地访问时是http的，要对应起来，当然本地访问时https就无所谓。







