如果一些关键字参数搜索不到，去另一个文件试试。

ffmpeg一个比较[入门的教程](https://github.com/leandromoreira/ffmpeg-libav-tutorial/blob/master/README-cn.md)，很适合来学习。

- [python-ffmpeg](https://github.com/kkroening/ffmpeg-python)：用python来调用ffmpeg。

这些参数，很多如果不给，就是采用原视频里面的。

[这里](https://www.zhihu.com/question/47280477/answer/2301684673)还不错的一些相关的ffmpeg的参数。# 一定先去看，有你需要的



开发[官方学习文档](http://ffmpeg.org/doxygen/trunk/examples.html)。推拉流，代码上的一些实现，可以看看这个[博客](https://www.cnblogs.com/gongluck/category/1215138.html)。

注意：

- 当保存的文件已存在时，会询问是否覆盖，如果是在程序中作为外部命令代用则会卡在那里，故可以在每次命令最后面加参数来决定是否覆盖：加`-y`则表示如果输出文件已存在就同意覆盖；加`-n`则不同意覆盖，相当于什么也没做。这样子外部调用命令就会执行完，不会卡在那里。

参数说明：

- -vcodec copy 跟 -c:v copy 是一个意思，代表对视频编码格式的设置；一般用copy跟原来格式保持一致或是用libx264、libx265等格式；
- -acodec copy 跟 -c:a copy 是一个意思，代表对音频编码格式的设置；一般用copy跟原来格式保持一致或是用acc格式；
- -b:v ：指定视频的码率；
- -b:a ：指定音频的码率；

---

## 一、命令行常用的通用选项

`ffmpeg -encoders`:可以查看ffmpeg支持的所有的视频、音频、字幕等编解格式。

一、==主要选项==：

1. -f flv  （input/output）指定输入或者输出文件格式(封装格式，视频容器）。常规可省略而使用依据扩展名（或是文件的前几百K的内容，智能分析）的自动指定，但一些选项需要强制明确设定。
2. -i 01.mp4 （input）指定输入文件。
3. -y （global）默认自动覆盖输出文件，而不再询问确认。
4. -n （global）不覆盖输出文件，如果输出文件已经存在则立即退出。
5. -ss position (input/output)
   - 如果是在-i前(一般也用在-i前)，表示定位输入文件到position指定的位置;
   - 注意可能一些格式是不支持精确定位的，所以ffmpeg,可能是定位到最接近position(在之前）的可定位点。position可以是以秒为单位的数值或者hh:mm:ss[.xxx]格式的时间值(如 12:15:23.314)。
6. -t duration (input/output）限制输入/输出的时间。（注意-to和-t是互斥的，-t有更高优先级）
   - 如果是在-i前面，就是限定从输入中读取多少时间的数据;
   - 如果是在-i后面，用于限定输出文件，则表示写入多少时间数据后就停止;
   - duration可以是以秒为单位的数值或者 hh:mm:ss[.xxx]格式的时间值(如 12:15:23.314)。
7. -to position (output)只写入position时间后就停止
   - position可以是以秒为单位的数值或者hh:mm:ss[.xxx]格式的时间值。
   - 注意-to和-t是互斥的，-t有更高优先级。（-t是截取那么多，-to是截取到那么多）
8. -threads 0   默认值是0，用所有核心，还可以给1、2

---

二、==视频选项==：

1. -vframes 200  (output) 设置输出文件的帧数，跟 -frames:v 是一个意思。

   > ffmpeg -i keypoint_result.mp4 -frames:v 200 out.mp4    # 意思就是输出200帧后就停止，out.mp4多长，取决于输入流的fps

2. -r 25  （input/output,per-stream）设置帧率

3. -vn   （output）禁止输出视频，跟-an禁止音频一样

4. -vcodec libx264  (output)设置视频编码器，这是 -codec:v 的别名，跟上面的-vframes一个意思。

5. -aspect "4:3"  （output）指定视频的纵横比，常用参数值 "4:3"、"16:9"、"1.3333"、"1.7777"。写成小数也是OK的，1280/720=1.777777

6. -s 640×480  （output）指定视频画面的大小，用*代替×也是OK的。

---

三、==音频选项==：

1. -frames:a  200  （output）设置输出文件的帧数，到了200就停，（音频的帧数是人为抽象的概念）

2. -ar 44.1k  （input/output,per-stream）设置音频采样率44.1kHz，默认是输出等同于输入。默认输出会有输入相同的音频通道。对于输入进行设置，仅仅通道是真实的设备或者raw数据分离出并映射的通道才有效。

   - -ar 采样率，每秒采样多少次，一般( 44.1kHz=44100  48kHz  以及 80kHz)

   - 采样率大大于原声波频率的2倍，人耳能听到的最高频率是20kHz，所以为了满足人耳的听觉要求，采样率至少为40kHz，通常为44.1kHz，更高为48kHz，人耳听觉频率范围[20Hz, 20kHz]

3. -aq q (output)设置音频品质(编码指定为VBR)(我暂时不知道q应该给什么参数)，也可以写作 -q:a , 老版本为qscale:a

4. -ac 2  (input/output,per-stream)设置音频通道，默认是输出等同于输入。默认输出会有输入相同的音频通道。对于输入进行设置，仅仅通道是真实的设备或者raw数据分离出并映射的通道才有效。

5. -an  (output)禁止输出音频。

6. -acode aac (intput/output)设置音频解码/编码的编解码器，也可写作 -codec:a  (可用ffmpeg -encoders查看支持哪些格式)

   - 如果是要mp3的格式，要写作 -acode libmp3lame

---

三、==字幕选项==：

字幕不多写了，地址放[这里](https://www.bilibili.com/video/BV1Fw4m1e7Es?t=7.7&p=5)。

## 二、ffplay相关

### 2.1. ffplay快捷键

| 作用                                                   | 按键              |
| ------------------------------------------------------ | ----------------- |
| 退出                                                   | q, ESC            |
| 暂停                                                   | p, 空格           |
| 全屏                                                   | f                 |
| 逐帧显示                                               | s                 |
| 跳转到指定位置<br />（根据鼠标位置相对屏幕的宽度计算） | 鼠标右键点击屏幕  |
| 向后10s/向前10s                                        | 左方向键/右方向键 |
| 向后1min/向前1min                                      | 上方向键/下方向键 |
| 向后10min/向前10min                                    | page down/page up |
| 显示音频波形                                           | w                 |

对应的PotPlayer的一些常用快捷键：

| 作用                                             | 按键       |
| ------------------------------------------------ | ---------- |
| 增加播放速度                                     | C          |
| 减慢播放毒素                                     | X          |
| 回到一倍速                                       | Z          |
| 复制当前画面到剪切板                             | Ctrl+Alt+C |
| 旋转画面<br />(注意下次打开会记住这次旋转的情况) | Alt+K      |

### 2.2. ffplay播放增强参数

播放时也可以参照ffmpeg来添加图片、文字水印。

ffpaly -window_title "hello" 456.mp4   # 默认是用文件名当窗口名，这是自己命名窗口名

其它参数：

- -x 200  强制设置视频显示窗口的宽度

- -y  300   强制设置视频显示窗口的高度

- -s  设置视频显示的宽高(暂时没试成功)

- -fs   强制全屏显示

- -an  屏蔽音频

- -vn  屏蔽视频

- -Sn  屏蔽字幕

- -ss   根据设置的秒进行定位拖动
  -t    设置播放视频/音频长度

- -autorotate   自动旋转视频，加了，但没看到啥效果

  还有其它设置要播放的视频流、音频流之类的，还可以挂载字幕等，就不多写了

---

让视频播放时右上角显示系统当前时间：
`ffplay -i 01.mp4 -vf "drawtext=fontfile=simhei.ttf:x=W-tw:fontcolor=red:fontsize=30:text='%{localtime\:%H\\\:%M\\\:%S}'"` 

- 注意text=后的内容都要用单引号括起来；
- 字体文件要能找到，否在放到当前路径来；
  - 如果路径中有中文盘符，或是中文乱码，解决办法，[地址](https://www.bilibili.com/video/BV1Fw4m1e7Es?t=2.8&p=28)。
- 里面都是大写字母，别错了，然后里面的反斜杠一根不能少，如果用代码来写，每根反斜杠还需要一根反斜杠来转义；
- ffmpeg也可以把这个当前运行的时间当水印加到视频中，把上面的ffplay换成ffmpeg就好了；
  - 使用ffmpeg时，就别加 -c copy了，这势必要重新编解码的。

### 2.3. ffprobe查看详细格式

- -show_format：查看视频的总格式，ffprobe -show_format 456.mp4   # 结果得到的format_name=mov,mp4,m4a,3gp,3g2,mj2的讲解，[地址](https://www.bilibili.com/video/BV1Fw4m1e7Es?t=333.5&p=13)。
- -show_frames：查看视频没一帧的格式，ffprobe -show_frames 456.mp4  # 每一帧的数据都会输出，是不是关键帧之类的（带音频的话，一帧数据就是音视频数据都有）(结果中 key_frame=1 代表是关键帧，具体网上看其它参数含义吧)

- -show_streams：查看视频中各个流的格式信息，ffprobe -show_streams 456.mp4  # 按照每个流，一个流输出一个

都可以加上参数==-print_format xml/json/csv/ini/flat==用更方便的格式查看，ffprobe -show_streams 01.mp4 -print_format json，还可以再加上 > out.json 重定向保存下来。

### 2.4. 列举打开本地摄像头

windows:

- ffmpeg列出当前设备的设备：
      ffmpeg -list_devices true -f dshow -i dummy
- ffplay调用本地摄像头：
      ffplay -f dshow -i video="Logi C270 HD WebCam" 
      或者：ffplay -f vfwcap -i 0
- ffplay调用本地麦克风：（后面的名字是从ffmpeg里列出来的）
      ffplay -f dshow -i audio="麦克风 (USB Audio Device)"  

linux:
    注意：dshow是win上特有的，linux上是不行的，linux上要用“x11grab”(这一般是用来录屏)，可用`ffmpeg -devices`去查看支持的格式，具体输入输出可是可看[这里](https://zhuanlan.zhihu.com/p/629883381)。

- 调用本地usb摄像头：ffplay -f v4l2 -i /dev/video0
  录像：ffmpeg -f v4l2 -framerate 25 -video_size 640x480 -i /dev/video0 output.mkv

## 三、实际操作示例

### 3.1. 一些内置变量、函数

下面是一些内置变量，不同功能可能有些区别，然后也不一定完全对，其它功能也可以来尝试用别的变量，试试先。

添加图片水印时：

- main_w 或 W  主输入(背景窗口)高度
- main_h 或 H   主输入(背景窗口)高度
- overlay_w  或 w    输入(水印)深度
- overlay_h  或 h    输入(水印)高度
- 上面比如放视频中间：`ffmpeg -i 01.mp4 -vf "movie=05.jpg[my_name];[in][my_name]overlay=W/2-w/2:H/2-h/2[out]" out.mp4` 

---

给视频加文字水印时：（下面的一些函数上面应该也能用）

- line_h,lh  时间线，很少用
- main_h,h,H  都是输入视频高度
- main_w,w,W  都是输入视频宽度
- text_w  或 tw  文本宽度(像素)

- text_h  或 th  文本高度(像素)
- n  第几帧
- rand(min,max)  [min,max]中的随机值，
- mod(a,b)     求余，a%b  注意，写到命令行中，要写成 mod(a\,b) 逗号都需要转义
- lt(a,b)    a小于b时为1， a大于等于b时为0  类似于的还有 gt
- t  时间戳，单位：秒

### 3.2. 视频/图相关

#### 3.2.1 视频拆成图

1. 视频拆成图片：`ffmpeg -i input.flv -r 1 -f image2 image-%4d.jpg`     # 还可以在 -f image2 加上 -q:v 2  图片的质量会增加

   - -i : 指定输入文件 

   - -r : 就是1秒r张， -r 3 就是1秒3张

   - -f : 指定格式化的格式为image2 

   生成的结果 image-%4d.jpg    %4d是指4位数字

2. 获取封面：`ffmpeg -i a.mp4 -y -f image2 -frames 1 a.jpg`
   获取更高质量：`ffmpeg -i a.mp4 -y -f image2 -q:v 2 -frames 1 a.jpg` 

3. 反过来图成视频就是： ffmpeg -f image2 -i image-%4d.jpg out.mp4

4. 将多个图转成视频：`ffmpeg -f image2 -r 20 -i  "./images/img_%d.jpg"  ./out.mp4` 

   - -r 20：代表帧数设置为20，也可以写做 -framerate 20  是一个意思
   - 还可以加一个参数：-vcodec libx264  # 代表以264格式编码
   - 特别注意，路径里面有空格、几级目录这些，用引号括起来
   - 还可在在合成过程中添加音频，参看[这里](https://www.cnblogs.com/lavezhang/p/15359148.html)。
   - 注意：opencv把图片存为视频，真有点奇怪啊，它最后保存的是视频总帧数始终只有图片数量的一半，无论保存图片时fps设置为多少，所以时长也只有ffmpeg转的一半。

#### 3.2.2 视频片段截取

视频片段截取（`-t`和`-to`）：

- `ffmpeg -ss 6 -t 30 -i ./LOL.mp4  temp.mp4`    # 从6秒开始截取30s，存为temp.mp4
  - 注：也可以写成 -t 00:00:30  这也是截取30秒，注意-to这么写就是代表的时间点而不是时间长度哦
- `ffmpeg -ss 6 -to 30 -i ./LOL.mp4  temp.mp4`  # 这里就是从6秒开始，截取到30s，共24S

注意：这样子会自适应降低视频码率，会较大的压缩视频大小(注重质量还是像下面一样带个 -c copy)

- 时间还可以这么给(从第6秒到第10分25秒)：

`ffmpeg -ss 00:00:06 -to 00:10:25 -i ./sample.mp4 -c copy output.mp4`    // -c copy  代表会个各种格式都按照原视频来，也不用重新编解码，速度快很多。

---

截取视频的一个注意事项：(如从第10秒截取到第15秒)

- 如果是 -i 01.mp4 -ss 10 -t 15   即-i在-ss之前，有可能会遇到视频第一帧黑屏，就是未播放时的封面是黑色的，原因是未定位到关键帧I帧。
- 如果是 -ss 10 -t 15 -i 01.mp4  即-i在-ss之后，可以解决第一帧黑屏问题，但可能切割的时间落点有一丢丢不准确，为了拿到最近的关键帧嘛。

注：如果截取的原视频很大，尽量把-ss放-i前面，这样它会先去大概定位，就很快；如果是-i在前，上来就打开，一点点去找，就很慢。

#### 3.2.2 获取指定时间的截图

获取视频指定时间的截图：ffmpeg -ss 8 -t 0.001 -i 01.mp4 -f image2 -s 100x100 res11.jpg

- -f image2 不是必须
- -s 100x100 强制指定图片大小也不是必须
- -ss 8 -t 0.001 就是代表第8秒，0.001时间就一毫秒，比一帧时间都短，所以就是那张图，不是非得0.001

#### 3.2.3 视频转gif(片段截取)

视频转gif：`ffmpeg -ss 8 -t 15 -i 11.mp4 -s 600*400 -r 15 res.gif`  # *可以用小写字母x代替

- -ss 8 -t 15：从第8秒开始，往后截取15秒钟  
- -s：设定分辨率   # 可以不要就是原始大小  # 以后使用 -vf "scale=640:-1"  让其自己去算高度，避免图像被拉伸。特别当录的是视频画面很大的时候，一定加上这，不然得到的gif就非常大。
- -r：设定帧数

图片转：ffmpeg -i image-%4d.jpg -r 5 test.gif

#### 3.2.4 部分画面截取

ffmpeg -i 01.mp4 -vf crop=200:400:0:120 -threads 4 -preset ultrafast -strict -2 02.mp4

- -vf crop的参数，分表代表，宽，高，起始x，起始y(后面这值不给就是默认从视频的居中剪切) 起点是视频的左上角；
- -threads 4：代表四个4核心，默认设置0，代表能检测到的所有核心，一般不用加这个参数；
- -preset：来调整编码速度，预设值可以是`ultrafast`、`superfast`、`veryfast`、`faster`、`fast`、`medium`、`slow`、`slower`、`veryslow`或`placebo`。速度越快，CPU使用率越高，但压缩效率可能会降低，也可能会牺牲视频质量。
- 建议使用 -c copy 参数，这样保持原视频质量，也不用重新编解码，速度快很多。

### 3.3. 压缩视频

说明：这里里西安机芯装配视频来说的，原始视频是用小米11pro用1080p，30fps拍摄，假设为“input.mp4”

- 时长：00:52:23
- 总比特率：14684kbps
- 大小：5.37GB

下面用一些方法来压缩视频

#### 3.3.1 改变码率

两种方式：

1. 直接使用：ffmpeg -i input.mp4 output.mp4   

   - 压缩后视频码率：4389kbps
   - 压缩后视频大小：1.60GB

   这就自动降码率了，其它参数还是一样，但可能用压缩后视频去截取骑部分长度的画，截取结果可能会有开头黑屏一两秒的问题。

2. 指定 -crf 参数：ffmpeg -i input.mp4 -crf 20 output.mp4

   - -crf 20：设置CRF值（常量速率因子）。CRF值范围从0（无损）到51（最糟），通常使用18到28的值。较低的CRF值会导致更好的质量，但文件会更大。

---

上面是自动选择的压缩后的码率，下面这是弄动态壁纸的记录：

视频的原码率是 2.1Mb/s ，压缩为 1.5Mb/s

>ffmpeg -i Desktop/1.mov -b:v 1.5M -r 30 Desktop/1.mp4   # 还可以添加r参数，把原来的帧率改成30(一般是从大减小)
>
>ffmpeg -i .\out.avi -b:v 3.6M 123_1.mp4    # 还可以以此来转换视频格式(opencv只能avi格式写入，且码率很大很大，可以这样把它转换成mp4，减小码率，减小所占空间)

- `-b:v` ：指定视频的码率     1.5M 应该也是能写成 1500k 的

- `-b:a` ：指定音频的码率

- 1.5M：码率的值 1.5M 表示 1.5Mb/s

  码率越小，视频清晰度就降低，然后大小也会变小，然后就达到了压缩的目的

avi的码率会很大，用这个做动态壁纸会比较吃资源，然后可以直接.avi转成.mp4，它会自己找一个合适和码率去转，不用降低帧率，占用差不多。

#### 3.3.2 改变画面大小(分辨率)、fps、h265编码

ffmpeg -i input.mp4 -c:v libx265 -crf 20 -r 24 -vf scale=1280:-1 -y output.mp4

- -c:v libx265：代表以265的格式编码, -c:v是指定编码器，编码器列表可以使用ffmpeg -codecs查看；

  - ```
    比如在转格式时（做动态壁纸时），avi转mp4，其它什么都不指定，选择默认：
    ffmpeg -i input.avi  out.mp4    # 一般码率会比avi减小(但不会特别多)，占用空间减小
    ffmpeg -i input.avi  -c:v libx265  out.mp4  # 码率会比avi小很多很多(比上面那个还小)，占用的空间也会小很多倍
    ```

  - 就这小节里，一样的命令，只是把-c:v从libx265改到了libx264，得到的结果大小是原来的1.45倍，发现主要是因为它总的比特率是原来的1.45倍；所以可能libx265是在画质保持差不多的情况下，比libx264压缩得更狠。 

- -crf 20：上面提到过了，主要是改变码率；

- -r 24：指定帧率为24，建议跟原视频保持一致，从30到24后，画面看起来偶尔像是会有卡顿；

- -vf scale：指定输出视频的宽高，高-1代表按照比例自动适应,也可以直接 =640:480这样指定一个特定的。上面命令scale=1280:-1就可以将1080p(1920*1080)的视频转成720p(1280\*720)

### 3.4. 图片、文字水印

ffplay播放时也可加这些，命令参数赋值过去就行。

​	注：在给视频加gif图片水印(别去添加gif水印，问题很大，在gif的-i前设置 -ignore_loop 0 就是让其一直循环，那生成视频的过程会无限下去，因为它要保持最长的一致，不加这个参数，gif循环一次就完了，用别的方式，可能视频又变得跟gif一样短)。

- （1）==静态图片水印==：ffmpeg -i 01.mp4 -i 05.jpg -filter_complex overlay out.mp4  # 这是简单默认叠加在视频左上角
  更详细的：`ffmpeg -i 01.mp4 -vf "movie=05.jpg[my_name];[in][my_name]overlay=50:60[out]" out.mp4`  # 核心区别是 movie 参数
  - 固定写法，05.jpg是要加的水印图，“my_name”可以随便给，后面的[out]不要也行；
  - 另外overlay=50:60:1   # 为0是表示默认参数，输入颜色空间不改变，为1表示将输入的颜色空间设为RGB，一般不给，给了很大概率结果有问题。x:y也可以不给，默认都是0
- （2）==静态文字水印==：`ffmpeg -i 01.mp4 -vf "drawtext=fontfile=simhei.ttf:text='hello world':x=W/2:y=150:fontsize=24:fontcolor=yellow:shadowy=2" res.mp4`
      核心区别是 drawtext 参数
  - 字体文件一定要找得到，不然就放当前路径来，shadowy代表阴影，一些参数不是必须的，它有默认值，顺序也不重要，fontcolor还可以按照rgb给，比如`#3366BB` 
  - 视频播放右上角显示系统当前时间：`ffplay -i sintel_trailer-480p.webm -vf "drawtext=fontfile=simhei.ttf:x=W-tw:fontcolor=white:fontsize=30:text='%{localtime\:%H\\\:%M\\\:%S}'"` 

    - 注意text=后的内容都要用单引号括起来
    - 里面都是大写字母，别错了，然后里面的反斜杠一根不能少，如果用代码来写，每根反斜杠还需要一根反斜杠来转义
    - ffmpeg也可以把这个当前运行的时间当水印加到视频中，把上面的ffplay换成ffmpeg就好了
- （3）==文字跑马灯效果==，类似于视频顶部从左往右，从右往左这些滚动广告的效果：（==本质是随着帧数n的改变去改变水印x值==）
  - ==从左往右==（它会一直在顶部循环）：`ffmpeg -i 01.mp4 -vf "drawtext=fontfile=simhei.ttf:text='hello world':x=(mod(2*n\,w+tw)-tw):y=10:fontcolor=#FF6600:fontsize=30" -f mp4 out.mp4` 
    - x=(mod(2*n\,w+tw)-tw) 这一直在改变x的值，也可以这样去改y的值
      - 2改成5或者更大，滚动的速度就会变快
      - n是帧数，n从左往右越来越大了，这里之所有要求余，就是视频很长的话，n太大了，不减去tw文本宽度，那一开始文字就直接在做左侧
      - \是转义符，固定写法
  - ==从右往左==(这个不会循环，过了一遍就不会再有了)：`ffmpeg -i 01.mp4 -vf "drawtext=fontfile=simhei.ttf:text='hello world':x=W-t*W/10:y=10:fontcolor=#FF6600:fontsize=30" -f mp4 out.mp4` 
    - x=W-t*W/10   这里10就是10秒循环一次，2就是2秒播完一次
  - ==随机移动==：结合上面同时改x、y的值，就能实现从左上角到右下角之类的效果。
- （4）==文字每隔M秒显示N秒==：（增加了水印的 enable 属性）
  - 同一个地方，即保持保持x、y不变，即为==文字闪烁==：`ffmpeg -i 01.mp4 -vf "drawtext=fontfile=simhei.ttf:text='hello world':x=W/2:y=H/2:fontcolor=red:fontsize=60:enable=lt(mod(t\,5)\,2)" -f mp4 out.mp4`
    - enable=0或1  0就是不显示，1就是显示
    - lt(mod(t\,5)\,2)  # t在0秒时，整体计算结果1，就显示，1秒时，计算结果还是1，显示；t为2秒时，计算结果为0,就消失
      这就是5秒显示2秒
  - 结合上面文字跑马灯，即x、y值都变的话，文字就是移动一会消失，再出现移动一会儿，再消失。

### 3.5. 声画分离、合成、改视频音量大小

mp3的编码格式：-acodec libmp3lame

---

- 提取音频：`ffmpeg -i input.mp4 -vn -c:a copy output.aac`   # 注意是.aac
  - -vn：表示no video;
  - -c:a copy：就是codec of audio，copy是直接拷贝视频中的原始的音频，这里不会涉及音频的编解码，速度会很快；也可以指定`-c:a libmp3lame` 导出mp3格式的音频.
  - 对于音频提取，可以使用`-b:a 128k` 指定音频的码率是128kb/s，`-ar 44k` 指定音频的采样频率为44kHz，完整命令如下:ffmpeg -i input.mp4 -vn -b:a 128k -ar 44k -c:a mp3 output.mp3
- 提取视频：`ffmpeg -i input_file -an -vcodec copy output_file_name` # 就是视频消声：
  - -an：表示no audio；
  - 实例：`ffmpeg -i ./LOL.mp4 -an -vcodec copy 1.mp4` # 原视频是LOL.mp4，会创建一个副本1.mp4

---

- （1）==抽取音频==：ffmpeg -i sintel_trailer-480p.webm -vn 01.aac/01.mp3
  - 它会自己根据后缀名去指定编码格式，一般不要用 -acodec copy ，可能存在它原来的音频编码格式与指定的后缀名格式不兼容，视频也是同理
  - 好比 ffmpeg -i sintel_trailer-480p.webm -vn -acodec copy 01.mp3 这就会报错，它原来的编码格式不是mp3的
  - 就要 ffmpeg -i sintel_trailer-480p.webm -vn -acodec libmp3lame 01.mp3  # 注意mp3的编码格式是 “libmp3lame”

- （2）==音频+视频合成==：ffmpeg -i 01.mp4 -i 02.mp3 -vcodec copy -acodec copy audio_copy.mp4   # 使用copy参数，一下子完成
  - 注意：（音视频长度不一致的时候，结果是最长的那个；视频短了的话，最后的画面就是一直停在那里）
  - 如果不带 -vcodec copy -acodec copy ，它大概率会重新编解码，生成视频的音频编码会从mp3变成aac
  - ==如果某个流只要其中一段==，在其 -i 前面可以加 -ss 20- t 5 这样的参数，表示截取其中一段，特别是把长的截取到短的一样长。
    ffmpeg -ss 20 -t 5 -i 456.mp4 -i 02.mp3 -vcodec copy -acodec copy audio_copy.mp4   # 就只截取了视频5秒
- （3）==两个音频合成一个==：ffmpeg -i 02.mp3 -i 02.mp3 -filter_complex amix=inputs=2:duration=shortest out.mp3
  - duration=longest 就是结果以长的为准，上面的shortest就是以短的为准；
  - 如果是三个音频：ffmpeg -i 02.mp3 -i 02.mp3 -i 03.mp3 -filter_complex amix=inputs=3:duration=first  # 以第一个为准，应该还能second。

- （4）==改变视频音量大小==：ffmpeg -i 02.mp3 -af "volume=0.5"  01.mp3  # 注意是双引号
  - 音量变为原来的0.5倍，也可以是2.0倍，输入是一个音频文件应该也OK

#### 音频格式转换

1. MP3、wav之间：
   - mp3转wav：ffmpeg -i 123.mp3 -f wav out.wav   # wav转mp3也是一样
   - wav/mp3文件的切分：ffmpeg -i out.wav -f segment -segment_time 30 -c copy output%03d.wav
   - wav/mp3文件的拼接：`ffmpeg -i 0.wav -i 1.wav -filter_complex "[0:a:0] [1:a:0] concat=n=2:v=0:a=1 [a]" -map "[a]" output0.wav`
   - 音频片段的截取跟视频是一样的：ffmpeg -ss 00:15:05 -to 00:15:35 -i .\20220110.mp3 -c copy out.mp3       # 注意如果是wav格式的切出来就是空的，那就先转成mp3格式
   - mp3 to wav and change rate：ffmpeg -i song.mp3 -acodec pcm_u8 -ar 22050 song.wav
2. wav转amr  （安全帽调试里用到过，amr格式的音频文件会特别小，适合通过网络给终端设备发送）

- ```
  ffmpeg -i input.wav -ar 8000 -ab 12.2k -ac 1 output.amr
  参数解释：
  -i input.wav：指定输入的WAV文件。
  -ar 8000：设置音频的采样率为8000赫兹。
  -ab 12.2k：设置音频的比特率为12.2kbit/s，这是AMR-NB格式的标准比特率。
  -ac 1：设置音频的通道数为1，表示单声道。
  output.amr：输出的AMR文件名。
  ```



wav音频格式转pcm格式的说明：
[这个](https://blog.csdn.net/u011994171/article/details/88668897)、[这个](https://www.jianshu.com/p/fd43c1c82945)，两个搭配起来看，。然后第转的时候，注意参数的值，可以先用ffprobe example.wav的格式再转

### 3.6. 旋转、镜像等

方向旋转、翻转：

- 水平翻转视频：ffmpeg -i 01.mp4 -vf hflip out.mp4
- 顺时针转90°：ffmpeg -i 01.mp4 -vf "transpose=1" out.mp4
- 逆时针转90°：ffmpeg -i 01.mp4 -vf "transpose=2" out.mp4
- 顺时针90°后再水平翻转：ffmpeg -i 01.mp4 -vf "transpose=3" out.mp4
- 逆时针90°后再水平翻转：ffmpeg -i 01.mp4 -vf "transpose=0" out.mp4
- 旋转180°可以：ffmpeg -i 456.mp4 -vf "transpose=2,transpose=2" out.mp4

### 3.7. 音视频的倒放

倒放音视频：

- 视频倒放，无声音：`ffmpeg -i 01.mp4 -filter_complex [0:v]reverse[v] -map [v] -preset superfast out.mp4` 
  - [0:v]输入就一个文件，所以是0，v是视频，
  - reverse后面的[v]是取个名字，跟 -map [v] 这俩对应起来，相当于映射视频流
  - -preset superfast 代表比较快的编码速度，质量可能就会一般
- 视频倒放，音频不变：ffmpeg -i 01.mp4 -vf reverse out.mp4
- 音频倒放，视频不变：ffmpeg -i sintel_trailer-480p.webm -map 0 -c:v copy -af "reverse" out.mp4  # 暂未成功，改了编码格式也没(可能是用的视频的音频流有点问题)
- 音视频同时倒放：ffmpeg -i sintel_trailer-480p.webm -vf reverse -af reverse -preset superfast out.mp4

### 3.8. 倍速播放

加/减速音视频：调整倍数范围[0.24, 4]

- 两倍速：ffmpeg -i 01.mp4 -vf setpts=0.5*PTS -af atempo=2 out.mp4     # 0.5\*PTS，就是让两帧变一帧
- 慢速：ffmpeg -i 01.mp4 -vf setpts=2*PTS -af atempo=0.5 out.mp4

### 3.9. 视频拼接(纵/横/时间轴)

在画面上左右、上下合并视频，要注意两个视频的size，跟array合并是一个意思 

横向合并：ffmpeg -i 01.mp4 -i 02.mp4 -lavfi hstack out.mp4

- 结果只会保留01.mp4中的音频。（也可以分别把两个视频的音频抽出来保存好，再混音成一个文件，然后跟这结果再合并）
- 纵向合并就改成  vstack 

---

时间维度上的拼接：
	把要合并的视频放到一个文件夹里，然后把文件名写到txt，像这样：(假设下面就是`merge.txt`的内容)(只能是视频名称不能给绝对路径)

>file  video_1.mp4
>file  video_2.mp4
>file  video_3.mp4
>file  video_4.mp4
>file  video_5.mp4

`ffmpeg -f concat -i merge.txt output.mp4`  看要不要`-c copy`
或者`ffmpeg -i "concat:1.ts|2.ts|3.ts" -acodec copy -vcodec copy out.mp4`  # 可能会报错，要设置一下编码格式

### 3.10. 镜面倒影，scale尺寸变换

镜面倒影特效：[地址](https://www.bilibili.com/video/BV1Fw4m1e7Es?t=167.4&p=38)，没试了：`ffmpeg -i 01.mp4 -vf "split[up][down];[up]pad=iw:ih*2[up];[down]vflip[down];[up][down]overlay=0:h out.mp4"`
这个效果：
<img src=".\illustration\image-20240808212135489.png" alt="image-20240808212135489" style="zoom:33%;" />

上面教程视频还涉及到：（用到了iw、ih这些变量，是值输入视频的尺寸嘛？）
<img src=".\illustration\image-20240808212305421.png" alt="image-20240808212305421" style="zoom:33%;" />

### 3.11. 画中画，九宫格

画中画overlay：`ffmpeg -i big.mp4 -i little.mp4 -filter_complex overlay=main_w-overlay_w-20:0 out.mp4`

- 注意： -filter_complex 是复杂过滤器，可以用 main_w overlay_w这些变量；-vf 是简单过滤器，可能一些内置变量用不了，要试。
- 快速制作一个小画面的视频：ffmpeg -i big.mp4 -vf scale=214:480/4  little.mp4  # 注意，这里用不了变量，但能用加减乘除，但计算后得到的值一定要是偶数，不然会报错。

---

九宫格拼接视频：结果好像只有一个音频，

```
ffmpeg -re -i 001.mp4 -re -i 002.mp4 -re -i 003.mp4 -re -i 004.mp4
    -filter_complex
    "nullsrc=size=640x480[base];
    [0:v]setpts=PTS-STARTPTS,scale=320x240[uperleft];
    [1:v]setpts=PTS-STARTPTS,scale=320x240[uperight];
    [2:v]setpts=PTS-STARTPTS,scale=320x240[lowerleft];
    [3:v]setpts=PTS-STARTPTS,scale=320x240[lowerright];
    [base][uperleft] overlay=shortest=1[tmp1];                   # 先覆盖一个到base上，得到tmp1，再把tmp1当做base来
    [tmp1][uperight] overlay=shortest=1:x=320[tmp2];
    [tmp2][lowerleft] overlay=shortest=1:y=240[tmp3];
    [tmp3][lowerright] overlay=shortest=1:x=320:y=240"
      -c:v libx264 out.mp4
```

- -re 参数控制读取 AVpacket 的速度，按照帧率速度读取文件 AVpacket。如果有多个流，以最慢的帧率为准。
- 通过 nullsrc 创建一个空的overlay的画布
- setpts=PTS-STARTPTS  中间是个减号，代表用视频本源的PTS
- [2:v] 就是代表第3路流的视频流
- base、uperleft、uperight、lowerleft、lowerright、tmp1、tmp2...这些都是自己起的名字，如果要搞九宫格，就再多起一些，然后按照这个格式去处理就好了。
- 虽然指定了shortest，但还是没用，似乎得到的结果还是视频中最长的，其它的播完后就禁止了

### 3.12. 对视频进行m3u8切片

m3u8切片：ffmpeg -i sintel_trailer-480p.webm -fflags flush_packets -max_delay 2 -flags -global_header -hls_time 5 -hls_list_size 0 -vcodec libx264 -acodec aac -r 30 -g 30 out_.m3u8

- 结果会是 out_.m3u8 索引文件，然后得到的视频片段名字会自动成为 out\_1.ts、out\_2.ts这种。

- -fflags flush_packets：包及时写到本地盘上
- -max_delay 2：最大延迟2秒
- -flags：说是一个通用的标志
- -hls_time 5：5秒一个切片
- -hls_list_size 0：写0就是代表这个所有，也不是很清楚，一般就这
- -g 30: 每30帧一个关键帧，这里跟-r帧率一样，就是一秒一个关键帧（-g (gop)图像组,多少帧有一个关键帧）
  - 如果要求比较好的效果：可能会采用 M1N12，就相当于 IBBP BBP BBP,IBBP  两个I帧之间就隔了12个非关键帧，这就比较耗cpu
  - I帧还涉及到 IDR帧（Immediate Dcoding Refresh）
  - 一般来说：-g  gop 的设置一般是-r帧率的10倍：
    - -r 帧率 一般给 25  30 29.97  50  59.94  60
- 把这个m3u8文件配置进nginx，然后通过http访问，[教程](https://www.bilibili.com/video/BV1Fw4m1e7Es?t=432.8&p=50)（说是浏览器无法直接播放m3u8，访问是会去下载，用vls就可以播放）。虽然hls效果延迟不是最好，但是走的http协议，一般不会被拦截，比较方便。
- 除了本地文件， -i udp://127.0.0.1/123 后面接这个m3u8的切片都是OK的，-i rtsp:// 也是可以的。
- 一般就是：HLS(m3u8)/RTMP/http-flv这些专业流媒体直播

---

用flv.js来播放m3u8：用一个flv.js进行网页的播放，[教程](https://www.bilibili.com/video/BV1Fw4m1e7Es?t=7.7&p=53)，还是很麻烦，要http-flv推流，还要用nginx配置跨域问题。

### 3.13. 存网络流为本地视频

1. 把rtsp流存成ts流：ffmpeg -i "rtsp://192.168.108.136:554/user=admin&password=&channel=1&stream=0.sdp?" -c copy -f mpegts ts.ts
   - 注意这种，.ts 流的封装格式 -f mpegts
2. 网络资源下载：ffmepg -i https://xxx.xxx.xx -c copy -f mp3 out.mp3
3. 或是：ffmpeg -i http://xxx.xx.m3u8 -c copy -movflags+faststart  test.mp4  # m3u8转mp4，说是点播非常有用，[讲解地址](https://www.bilibili.com/video/BV1Fw4m1e7Es?t=388.8&p=22)。

### 3.14 mkv中提取字幕

一般来说，.mkv格式视频中是带有字幕流的，但是用windows自带的播放器是没有字幕的，如果要让它能播，可以把字幕文件直接融到视频中去：（.ass是一种字幕文件）

- ffmpeg -i input.mkv -vf "ass=Friends.S02E01.BDRip.x264-FGT.zh.ass" -c:a copy output.mkv
  - 这样得到的结果在win自带播放器就有字幕了；但用potplayer播放，选择了一个字幕流的话，就会有双重字幕；
  - 而且整个过程还要编码很久，会把cpu拉满，文件大小也增加了很多。不推荐使用。

---

看视频有哪些流，使用ffprobe命令。

推荐使用：`ffmpeg -i input.mkv -map 0:v:0 -map 0:a:0 -map 0:s:1 -c copy output.mkv `  # 一瞬就完成了

- `-map 0:v:0`: 选择第一个视频流（从输入文件的第一个流开始计数）;
- `-map 0:a:0`: 选择第一个音频流（因为音频流一般就一个，那就是0）;
- `-map 0:s:1`: 选择第2个字幕流（老友记的视频一共有7个流，1个视频流，1个音频流，5个字幕流，我们要的是第2个字母流，那它就是1）。
  	这里的索引0都是代表各自流的第一个，不是总流来算的
- -c copy: 使用copy编解码器来复制流，而不是重新编码它们。这可以节省时间和计算资源。如果不加这个参数，就会重新编解码，会花很多时间和算力来转换。

### 3.14. h264流相关

视频转码相关：（但未测试），[视频地址](https://www.bilibili.com/video/BV1Fw4m1e7Es?t=89.5&p=18)，

提取264码流：ffmpeg -i demo.mp4 -vcodec copy -an -bsf: h264_mp4toannexb -f h264 temp.264

说是本地的mp4，就一个头部，而流为了稳定，及随时能打开，就要每隔一段就有一个头，所以 h264_mp4toannexb 就是这样的格式，具体看是看上面教程

- ts视频流转mp4：ffmpeg -i test.ts -acodec copy -vcodec copy -f mp4 out.mp4    # -f mp4
- h264视频转ts视频流：ffmpeg -i temp.h264 -vcodec copy -f mpegts out.ts  # -f mpegts
