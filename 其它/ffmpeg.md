ffmpeg一个比较[入门的教程](https://github.com/leandromoreira/ffmpeg-libav-tutorial/blob/master/README-cn.md)，很适合来学习。

- [python-ffmpeg](https://github.com/kkroening/ffmpeg-python)：用python来调用ffmpeg。

这些参数，很多如果不给，就是采用原视频里面的。

[这里](https://www.zhihu.com/question/47280477/answer/2301684673)还不错的一些相关的ffmpeg的参数。# 一定先去看，有你需要的

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



开发[官方学习文档](http://ffmpeg.org/doxygen/trunk/examples.html)。推拉流，代码上的一些实现，可以看看这个[博客](https://www.cnblogs.com/gongluck/category/1215138.html)。

注意：

- 当保存的文件已存在时，会询问是否覆盖，如果是在程序中作为外部命令代用则会卡在那里，故可以在每次命令最后面加参数来决定是否覆盖：加`-y`则表示如果输出文件已存在就同意覆盖；加`-n`则不同意覆盖，相当于什么也没做。这样子外部调用命令就会执行完，不会卡在那里。

## ffplay快捷键

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

|                                                  |            |
| ------------------------------------------------ | ---------- |
| 增加播放速度                                     | C          |
| 减慢播放毒素                                     | X          |
| 回到一倍速                                       | Z          |
| 复制当前画面到剪切板                             | Ctrl+Alt+C |
| 旋转画面<br />(注意下次打开会记住这次旋转的情况) | Alt+K      |



## 一、视频拆成图

视频拆成图片：`ffmpeg -i input.flv -r 1 -f image2 image-%4d.jpeg`     # 还可以在 -f image2 加上 -q:v 2  图片的质量会增加

-i : 指定输入文件 

-r : 帧数 1 (好像不是帧数，是秒数)

-f : 指定格式化的格式为image2 

生成的结果 image-%4d.jpeg    %4d是指4位数字



获取封面：`ffmpeg -i a.mp4 -y -f image2 -frames 1 a.jpg`
获取更高质量：`ffmpeg -i a.mp4 -y -f image2 -q:v 2 -frames 1 a.jpg`

---

将多个图转成视频：`ffmpeg -f image2 -r 20 -i  "./images/img_%d.jpg"  ./out.mp4`

- -r 20：代表帧数设置为20，也可以写做 -framerate 20  是一个意思
- 还可以加一个参数：-vcodec libx264  # 代表以264格式编码
- 特别注意，路径里面有空格、几级目录这些，用引号括起来
- 还可在在合成过程中添加音频，参看[这里](https://www.cnblogs.com/lavezhang/p/15359148.html)。
- 注意：opencv把图片存为视频，真有点奇怪啊，它最后保存的是视频总帧数始终只有图片数量的一半，无论保存图片时fps设置为多少，所以时长也只有ffmpeg转的一半。

## 二、视频转gif(片段截取)

视频转gif：`ffmpeg -ss 8 -t 15 -i 11.mp4 -s 600*400 -r 15 res.gif`  

- -ss 8 -t 15：从第8秒开始，往后截取15秒钟  
- -s：设定分辨率   # 可以不要就是原始大小
- -r：设定帧数

### 片段截取：

- 同理视频片段截取（`-t`和`-to`）：
  - `ffmpeg -ss 6 -t 30 -i ./LOL.mp4  temp.mp4`    # 从6秒开始截取30s，存为temp.mp4
  - `ffmpeg -ss 6 -to 30 -i ./LOL.mp4  temp.mp4`  # 这里就是从6秒开始，截取到30s，共24S

注意：这样子会自适应降低视频码率，会较大的压缩视频大小(注重质量还是像下面一样带个 -c copy)

- 时间还可以这么给(从第6秒到第10分25秒)：

`ffmpeg -ss 00:00:06 -to 00:10:25 -i ./sample.mp4 -c copy output.mp4`    // -c copy  代表会个各种格式都按照原视频来

## 三、改变码率。(压缩视频)

视频的原码率是 2.1Mb/s ，压缩为 1.5Mb/s

>ffmpeg -i Desktop/1.mov -b:v 1.5M -r 30 Desktop/1.mp4   # 还可以添加r参数，把原来的帧率改成30(一般是从大减小)
>
>ffmpeg -i .\out.avi -b:v 3.6M 123_1.mp4    # 还可以以此来转换视频格式(opencv只能avi格式写入，且码率很大很大，可以这样把它转换成mp4，减小码率，减小所占空间)

- `-b:v` ：指定视频的码率

- `-b:a` ：指定音频的码率

- 1.5M：码率的值 1.5M 表示 1.5Mb/s

  码率越小，视频清晰度就降低，然后大小也会变小，然后就达到了压缩的目的

avi的码率会很大，用这个做动态壁纸会比较吃资源，然后可以直接.avi转成.mp4，它会自己找一个合适和码率去转，不用降低帧率，占用差不多。

## 四、修改编码格式(H.265)，画面大小

> 比如在转格式时，avi转mp4，其它什么都不指定，选择默认：
>
>ffmpeg -i out.avi   123_264.mp4          # 一般码率会比avi减小(但不会特别多)，占用空间减小
>
>ffmpeg -i out.avi  -c:v libx365  123_465.mp4     # 码率会比avi小很多很多(比上面那个还小)，占用的空间也会小很多倍

- `-c:v  libx265`      代表以265的格式编码, -c:v是指定编码器，编码器列表可以使用ffmpeg -codecs查看

还可以直接修改画面的大小：
ffmpeg -i input.mp4 -c:v libx264 -vf scale=1280:-1 -y out123.mp4

- -vf scale：指定输出视频的宽高，高-1代表按照比例自动适应,也可以直接 =640:480这样指定一个特定的。

## 五、声画分离

- 提取音频：`ffmpeg -i input.mp4 -vn -c:a copy output.aac`   # 注意是.aac
  - -vn：表示no video;
  - -c:a copy：就是codec of audio，copy是直接拷贝视频中的原始的音频，这里不会涉及音频的编解码，速度会很快；也可以指定`-c:a mp3` 导出mp3格式的音频.
  - 对于音频提取，可以使用`-b:a 128k` 指定音频的码率是128kb/s，`-ar 44k` 指定音频的采样频率为44kHz，完整命令如下:ffmpeg -i input.mp4 -vn -b:a 128k -ar 44k -c:a mp3 output.mp3
- 提取视频：`ffmpeg -i input_file -an -vcodec copy output_file_name` # 就是视频消声：
  - -an：表示no audio；
  - 实例：`ffmpeg -i ./LOL.mp4 -an -vcodec copy 1.mp4` # 原视频是LOL.mp4，会创建一个副本1.mp4

## 六、视频合并

把要合并的视频放到一个文件夹里，然后把文件名写到txt，像这样：(假设下面就是`merge.txt`的内容)(只能是视频名称不能给绝对路径)

>file  video_1.mp4
>file  video_2.mp4
>file  video_3.mp4
>file  video_4.mp4
>file  video_5.mp4

`ffmpeg -f concat -i merge.txt output.mp4`  看要不要`-c copy`

## 七、音频格式转换

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

## 八、部分画面截取

ffmpeg -i a.mp4 -vf crop=200:400:0:120 -threads 4 -preset ultrafast -strict -2 b.mp4

- crop的参数，分表代表，宽，高，起始x，起始y. 起点是视频的左上角