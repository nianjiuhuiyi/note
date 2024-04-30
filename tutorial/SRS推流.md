科普一下：

- rtsp的默认端口是554;rtmp的默认端口是1935
- rtsp://192.168.108.147    # 前面的rtsp就决定用:554端口，后面加不加:554都无所谓
- rtmp://192.168.108.147    # 前面的rtmp就决定用:1935端口，后面加不加:1935都无所谓

---

还有的别一个流媒体服务器：[EasyDarwin](https://blog.csdn.net/highoooo/article/details/121267251)（win上方便快捷），好想看到别的推rtsp的流用这个比较多（这官网里面ffmpeg推流时还加了一个参数 -rtsp_transport tcp(udp) 看后续能不能用的上）。

[这里](https://www.zhihu.com/question/47280477/answer/2301684673)有比较多的关于ffmpeg的rtsp、rtmp参数，以及一些常用的视频流转化、处理命令。

[ZLMediaKit](https://github.com/ZLMediaKit/ZLMediaKit)这个是一个项目，支持rtsp、rtmp推流，类似于easydarwin、srs这种，这个页面有ffmpeg的各种推流命令。

srs、easydarwin、srs的对比，[地址](https://www.cnblogs.com/lihw-study/p/17025664.html)。

推拉流延迟的一些问题相关的博客：[地址1](https://www.5axxw.com/questions/simple/b6fnp0)、[地址2](https://www.cnblogs.com/xi-jie/p/14101069.html)。

---

## 一、SRS流媒体服务器

​	SRS是一个简单高效的实时视频服务器，支持RTMP/WebRTC/HLS/HTTP-FLV/SRT/GB28181。 # 所以好像不能推rtsp，一般的实现使用obs读取rtsp流，再用obs推rtmp

### 1.1. 安装

安装使用的两种方式：

1. 直接使用官方提供的docker镜像，直接一键开启，方便快捷：

   docker run --rm -it -p 1935:1935 -p 1985:1985 -p 8080:8080 \
       registry.cn-hangzhou.aliyuncs.com/ossrs/srs:4 ./objs/srs -c conf/srs.conf

2. 使用源码安装：

   - 如果使用源码安装，直接看它[github](https://github.com/ossrs/srs/wiki/v4_CN_Home#getting-started)，非常便捷；
   - 这次是安装在centos_harbor上的，每次开机需要进到里面：
     - cd /opt/srs/trunk 
     - 启动服务：./objs/srs -c conf/srs.conf
     - 查看状态：./etc/init.d/srs status
     - 查看日志：tail -n 30 -f ./objs/srs.log
- 然后我只是只执行了make，没有执行make install ，intall会将其安装在/usr/loacl/srs这个目录里面。
   - 然后看这[官方文档](https://github.com/ossrs/srs/wiki/v3_CN_LinuxService)，将其设置为开机自启的方法。
   - 这个运行后，**会启动8080端口**，是一个网页端的管理界面，但是进去后，啥推流的信息都看不到。

### 1.2. 推流

推流，一共三种方式：

- **ffmpeg推流**：示例

  1. `ffmpeg -re -i ./doc/source.flv -c copy -f flv -y rtmp://localhost/live/123`   # flv格式
  2. `ffmpeg -re -i 123.mp4  -c:v libx264 -c:a aac -f flv -y rtmp://192.168.125.128/live/456`  # mp4格式
  3. `ffmpeg -i "rtsp地址" -c:v libx264 -c:a aac -f flv   rtmp://192.168.125.128/live/456`  # 源是rtsp就不要加-re了，会很卡

  说明：

  - 一定要-re,-re是限制ffmpeg的上传帧率，否则ffmpeg会按照自身能力进行最大帧率的上传，就会导致流媒体服务器处理能力受限或者拉流端处理能力有限导致各类问题；

  - 第一种是要flv的格式，-vcodec copy -acodec copy 限于摄像机提供的就为H.264+AAC的码流；

  - 若不是flv(即第二种的mp4这些)，则将`-vcodec copy`改为`-vcodec libx264`，`-acodec copy`改为`-acodec aac`，这样就可以传普通的mp4视频了，而不仅仅是flv格式，直接推rtsp流就需要。  

  - rtsp流地址：要看这个rtsp摄像头的编码格式，（以受电弓rtsp摄像头为例（两种编码格式））
    
  - 是==H.265X==：
            ffmpeg -i "rtsp地址" -c copy -f flv "rtmp://192.168.125.128/live/123"
            
            - 这里的H.265X其实就是h264了，效果是一样的，所以可以直接推流。
       
       - 是==H.265==(也是HEVC)编码，而FLV格式不支持HEVC编码，就可能会得到相关编码错误：
            “[flv @ 000002ca5d2a2f80] Video codec hevc not compatible with flv Could not write header for output file #0 (incorrect codec parameters ?): Function not implemented Error initializing output stream 0:1 --”
       
            ​     所以就要将视频流转码为H.264编码再推流到RTMP服务器上，用“-c:v libx264 -c:a aac”(用这吧，好记一些)或是“-vcodec libx264 -acodec aac”这种写法是一个意思。
       
       所以可以去VMS这个软件里修改这个rtsp的编码格式，是可以改成H265X，就可以直接推流。

  ---

- **OBS推流**：示例
     (这个要推流成功，就一定要先打开1935的rtmp端口)：
  
  - 服务：自定义
  - 服务器：rtmp://192.168.125.128/live/    # 应该就是固定写法
  - 串流秘钥：123        # 自己起，也可以是 livestream/123/456
    - 这个给的不同，就可以区分推到同一台srs服务器上不同给的流了，拉取也就用这作为区分
  
  推多路流：
  
  ​	推流（tee协议**输出多路流**）：==ffmpeg -re -i myvideo.mp4 -vcodec libx264 -acodec aac -map 0 -f flv "tee:rtmp://127.0.0.1/live/123|rtmp://127.0.0.1/live/456"== 
  
  ---

- **srs的配置文件**：示例

     用srs自带的配置文件推流好像速度更快，看[这](http://ossrs.net/lts/zh-cn/docs/v4/doc/sample-ingest)官方文档里面配置的写法。


### 1.3. 拉流及注意事项

拉流：

- RTMP: ffplay rtmp://192.168.125.128/live/123
  - 注意：这个画面一般都是有5秒延迟。是因为ffplay做了缓冲，可以禁止缓冲，但画面就有不连续或是跳帧，画面看起来很卡
  - ffplay -i rtmp://192.168.125.128/live/123 -fflags nobuffer  # 这样画面延迟大概在2秒，就很卡
  - VLC延迟更大，除了因为客户端有缓冲策略，服务端也有低延时策略的，双方一起导致的延迟。
- H5(HTTP-FLV)：ffplay http://192.168.125.128:8080/live/123.flv
- H5(HLS)：ffplay http://192.168.125.128:8080/live/123.m3u8

---

Tips：

- web上播放是不支持rtsp的，所以要转成rtmp

- 推流时，推流地址一般都是rtmp://localhost/live/my_name  
  - localhost看自己情况设置成srs服务器地址
  - live是一定要的，固定写法，后面的就自己随意起，比如 “livestream_123/456/789”
  - 如果一个视频文件，要让其==循环推流==，加一个参数：`-stream_loop -1`，stream_loop设置的值代表循环的次数，其中-1代表无限次。（加在 -i 前面）
- 一般都是开启了防火墙的，所以当外机访问:8080窗口时，肯定会失败，所以服务器上要使用firewall-cmd开启8080端口；
- 因为防火墙，rtmp地址还是不能使用，rtmp的默认端口是1935/tcp，可以用==nmap localhost==在服务器上看到，所以还需要使用firewall-cmd把1935端口打开（如果是vscode远程的，然后用vscode的terminal执行的运行srs服务的命令，它就会自动转发1935端口，然后就可以直接在windows上直接使用rtmp://localhost/live/123这样的路径就好了，就不需要服务器开启1935端口，但好像还是一定要开启8080端口才行，且访问8080端口还必须是服务的ip地址）。
- 使用docker容器的话，一般会-p映射宿主机的8080端口，这时只要开启宿主机的8080端口，RTMP、H5这些地址都能直接使用了。
- 如果是vscode远程的话，然后在vscode中启动，去开启端口转发。

---

ffmpeg转封装格式说明：

- 需要知道 源容器 和 目标容器 的可容纳的编码格式，编码格式如果相互兼容，可以用`-c copy`拷贝原有的stream，如“ffmpeg -i input.mp4 -c copy -f flv output.flv”，编码格式如果不兼容，需要转化成目标文件支持的编码，如“ffmpeg -i input_ac3.mp4 -vcodec copy -acodec aac -f flv output.flv”，与上面的对应起来。

- 常规的从文件转换HLS直播时：

  ```
  ffmpeg -re -i input.mp4 -c copy -f hls -bsf:v h264_mp4toannexb output.m3u8
  # -bsf:v h264_mp4toannexb 作用是将MP4中的H.264数据转换成H.264 AnnexB标准编码，AnnexB标准的编码常见于实时传输流中。如果源文件为FLV、TS等可以作为直播传输流的视频，则不需要这个参数。
  ```

  - ffmpeg推流上传HLS相关的M3U8以及TS文件
    Nginx配置webdav模块

    ```
    ffmpeg -re -i input.mp4 -c copy -f hls -hls_time 3 -hls_list_size 0 -method PUT -t 30 http://127.0.0.1/test/output.m3u8
    ```


---

最后关于推流，chatgpt还推荐了一些参数，没试过，放这里作为一个灵感吧：

- `-preset veryfast`：这个参数表示使用非常快的编码速度，但是可能会牺牲一些编码质量。如果需要更高的编码质量可以尝试使用`slow`或者`medium`等更慢的preset。
- `-tune zerolatency`：这个参数表示使用零延迟的编码模式，可以减少编码延迟，但是可能会牺牲一些编码质量。如果需要更高的编码质量可以尝试不使用这个参数。
- `-b:v 2500k`：这个参数表示视频流的比特率为2500k，即视频流的平均码率为2500k。码率越高，视频的质量也就越高，但是同时也会占用更多的带宽。
- `-bufsize 2500k`：这个参数表示视频流的缓冲区大小为2500k。缓冲区越大，可以减少视频丢帧的可能性，但同时也会增加编码延迟。如果推流过程中出现了丢帧的情况可以适当增加缓冲区大小。
- `-s 1280x720`：应该是设置分辨率。
- `-rtsp_transport tcp`：好像默认是用的udp，可改成tcp

## 二、代码推流

### 2.1. 推本地摄像头

本地摄像头推流的一个参考：以下 Logi C270 HD WebCam 是通过查看列表的命令行获得的名称

- 查看本机USB摄像头列表：
  ffmpeg -list_devices true -f dshow -i dummy

- 播放本机USB播放摄像头，
  ffplay -f dshow -i video="Logi C270 HD WebCam" 

- 本机USB摄像头+转码+推流到RTSP服务器（rtp over tcp）
  ffmpeg -f dshow -i video="Logi C270 HD WebCam" -fflags nobuffer -max_delay 1 -threads 5  -profile:v high  -preset superfast -tune zerolatency  -an -c:v h264 -crf 25 -s 1280*720   -f rtsp -bf 0  -g 5  -f rtsp rtsp://127.0.0.1/live/test

我自己本地摄像头推流成功是用这个命令：==ffmpeg -f dshow -i video="Logi C270 HD WebCam" -r 20  -f flv -y rtmp://192.168.125.128/live/123==    # -r 是这是帧率，如果推流不成功，尝试设置音视频推流格式

### 2.2. python推流

​	python里面的一个推流，记录一下吧，感觉不是很好，最后都是调用ffmpeg，那不如直接ffmpeg命令行操作：（里面也算有==python调用外部程序==，其它用到的时候做个参考）

```python
import cv2
import subprocess

# RTMP服务器地址
rtmp = r'rtmp://192.168.125.128/live/123'   # 后面的123自己随意起的，可改成其它的，如123321/456等等
# 读取视频并获取属性
cap = cv2.VideoCapture(0)
size = (int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)), int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)))
sizeStr = str(size[0]) + 'x' + str(size[1])

# 以后为了方便写，这样写列表太麻烦，可以这样（下面是列出本地所有设备）
command_list = "ffmpeg -list_devices true -f dshow -i dummy".split()

command = ['ffmpeg',
           '-y', '-an',
           '-f', 'rawvideo',
           '-vcodec', 'rawvideo',
           '-pix_fmt', 'bgr24',
           '-s', sizeStr,
           '-r', '25',
           '-i', '-',
           '-c:v', 'libx264',
           '-pix_fmt', 'yuv420p',
           '-preset', 'ultrafast',
           '-f', 'flv',
           rtmp]
pipe = subprocess.Popen(command, shell=False, stdin=subprocess.PIPE)
while cap.isOpened():
    success, frame = cap.read()
    if success:
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
        pipe.stdin.write(frame.tostring())
cap.release()
pipe.terminate()
```

拉取流：ffplay rtmp:192.168.125.128/live/123

### 2.3. c++推流

#### 2.3.1 rtsp推rtmp

要推流成rtmp就是flv的格式。

​	c++用代码拉取rtsp的流然后推成rtmp的(win下4.几的版本是ok的，ffmpeg version N-107626-g1368b5a725-20220801)：这个[博客](https://www.cnblogs.com/gongluck/category/1215138.html)里还有很多ffmpeg采集声音、画面的相关代码。
​	以下代码肯定能运行，前提条件是rtsp的编码格式为h.264(或是受电弓的摄像头的H.265X格式，可用VMS软件进行修改)，因为以下代码的推流编码格式是直接copy源流的，推成rtmp的要libx264，所若是rtsp原流是h2654的，这代码就会出错，提示HEVC的错误。

```c++
#include <iostream>
extern "C" {
#include "libavformat/avformat.h"
#include "libavutil/time.h"
}
#pragma comment(lib, "avformat.lib")
#pragma comment(lib, "avutil.lib")
#pragma comment(lib, "avcodec.lib")

char av_error[AV_ERROR_MAX_STRING_SIZE] = { 0 };
#define av_err2str(errnum) \
    av_make_error_string(av_error, AV_ERROR_MAX_STRING_SIZE, errnum)

// 这个推视频也是ok的
const char* INFILE = "C:\\Users\\Administrator\\Videos\\source.200kbps.768x320.flv";
const char* RTMP = "rtmp://192.168.125.128/live/66";
const char* RTSP = "rtsp://192.168.108.134:554/user=admin&password=&channel=1&stream=1.sdp?";

int rtsp2rtmp() {
	int ret = 0;
	//封装上下文
	AVFormatContext* ictx = nullptr;
	AVFormatContext* octx = nullptr;
	const char* input_url = RTSP;   // INFILE
	const char* output_url = RTMP;
	int64_t starttime;

	ret = avformat_network_init();
	if (ret != 0) {
		std::cout << av_err2str(ret) << std::endl;
		goto END;
	}

	//打开文件，解封文件头
	ret = avformat_open_input(&ictx, input_url, nullptr, nullptr);
	if (ret != 0) {
		std::cout << av_err2str(ret) << std::endl;
		goto END;
	}
	std::cerr << "open file " << input_url << " success." << std::endl;

	//获取音视频流信息,h264 flv
	ret = avformat_find_stream_info(ictx, nullptr);
	if (ret != 0) {
		std::cout << av_err2str(ret) << std::endl;
		goto END;
	}

	//打印媒体信息
	av_dump_format(ictx, 0, input_url, 0);

	//////////////////////////////

	//输出流
	ret = avformat_alloc_output_context2(&octx, av_guess_format(nullptr, "123.flv", nullptr), nullptr, output_url);
    /*
    	注意上面这行，123.flv只是随便给的名字，重要的是后缀(所以给.flv就行)，让ffmpeg去推断我们要得格式是哪种的，有需要还可以放 456.mp4 之类的。
    */
	if (ret != 0) {
		std::cout << av_err2str(ret) << std::endl;
		goto END;
	}
	std::cerr << "octx create success." << std::endl;

	//配置输出流
	for (int i = 0; i < ictx->nb_streams; ++i) {
		//创建流
		AVStream* ostream = avformat_new_stream(octx, avcodec_find_encoder(ictx->streams[i]->codecpar->codec_id));
		if (ostream == nullptr)
			return -1;
		//复制配置信息
		ret = avcodec_parameters_copy(ostream->codecpar, ictx->streams[i]->codecpar);
		if (ret != 0) {
			std::cout << av_err2str(ret) << std::endl;
			goto END;
		}
		ostream->codecpar->codec_tag = 0;//标记不需要重新编解码
	}
	av_dump_format(octx, 0, output_url, 1);

	//////////////////////////////

	//推流
	if (ret != 0) {
		std::cout << av_err2str(ret) << std::endl;
		goto END;
	}
	ret = avio_open(&octx->pb, output_url, AVIO_FLAG_WRITE);
	if (ret < 0) {
		std::cout << av_err2str(ret) << std::endl;
		goto END;
	}

	//写入头信息
	ret = avformat_write_header(octx, nullptr);
	if (ret < 0) {
		std::cout << av_err2str(ret) << std::endl;
		goto END;
	}

	//推流每一帧数据
	AVPacket pkt;
	starttime = av_gettime();
	while (av_read_frame(ictx, &pkt) == 0) {
		//计算转换pts dts
		AVRational itime = ictx->streams[pkt.stream_index]->time_base;
		AVRational otime = octx->streams[pkt.stream_index]->time_base;
		pkt.pts = av_rescale_q_rnd(pkt.pts, itime, otime, (AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));
		pkt.dts = av_rescale_q_rnd(pkt.dts, itime, otime, (AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));
		pkt.duration = av_rescale_q_rnd(pkt.duration, itime, otime, (AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));
		pkt.pos = -1;

		ret = av_interleaved_write_frame(octx, &pkt);
		av_packet_unref(&pkt);
		if (ret < 0)
			std::cout << av_err2str(ret) << std::endl;  //不用退出
	}

END:
	if (ictx != nullptr)
		avformat_close_input(&ictx);
	if (octx != nullptr) {
		avio_close(octx->pb);
		avformat_free_context(octx);
	}
	ret = avformat_network_deinit();
	if (ret != 0)
		std::cout << av_err2str(ret) << std::endl;
	return 0;
}

int main() {
	rtsp2rtmp();
	system("pause");
	return 0;
}
```

说明：

- 以上代码运行时，有两个警告：“Timestamps are unset in a packet for stream 0. This is deprecated and will stop working in the future. Fix your code to set the timestamps properly”
  “Encoder did not produce proper pts, making some up.”

- 用flv视频肯定没啥问题，但是用rtsp作为数据源，或者一些mp4格式的视频，可能会遇到这个错误：

  > [flv @ 000002562679e9c0] Video codec hevc not compatible with flv

  这是因为==有rtsp的编码格式是h265(要注意用VMS去查看)==，要用成 -c:v libx264 -c:a aac 这种(哪怕rtsp没声音，也要这这样指定aac的)，所以就要去改代码中的格式（待做，以上代码的容错也还有所欠缺，后续真正用到时再去完善）

#### 2.3.2 rtsp推rtsp/rtmp详细

​	下面代码基本通用推流到rtsp、rtmp服务器。==一切延迟对比的画面是按python的画面为标准==(python画面本来就有点延迟，比ffmpeg直接读取展示慢一点，但也还是比较实时)（因为代码中指定推流的编码格式为libx264，所以rtsp源为h264、h265的都可以）（这个当源为视频时会报错，暂时只能拉流媒体的源）

- ==rtsp==服务器用的“EasyDarwin”：两种方式

  1. ffmpeg -i "rtsp地址" -rtsp_transport tcp -vcodec h264 -f rtsp rtsp://localhost/test  # 命令行推流有5-6s延迟，且一定要跟-vcodec h264参数，不然画面是糊的
  2. 代码效果：非常好，画面延迟在1秒以内（当rtsp源编码格式为h265时延迟会比h264大一点）

  ---

- ==rtmp==服务器用的“srs”：三种方式

  1. ffmpeg -i "rtsp(h264编码的)" -c copy -f flc rtmp://localhost/live/456  # 命令行推流画面延迟了2秒左右
  2. ffmpeg -i "rtsp(h265的)" -c:v libx264 -c:a aac -f flv rtmp://localhost/live/456    # 画面延迟了5-6秒 
  3. 代码效果：画面延迟了5秒左右，不管是rtsp源是h.264还是h.265，这俩都差不多，注意这是针对源是视频流，用视频文件可能要去改代码，有声音的话，可能要加一个声音的编码格式的指定。

- 推流还可以尝试就用srs自带的.conf配置文件来实现(1.2中有)，看一看延迟(以后用到再测吧)。

---

​	这个是关注的B站北小蔡的代码，讲的是延迟很低，它主要也是针对推流到rtsp服务器，代码也写的比较完善，里面有很多关于ffmpeg的推拉流的代码可以参考。（原始代码里可能因为ffmpeg版本问题，有细微的修改）。（真的投入使用时要再审核一下内存泄露问题，注意内存释放，要多测试）

1. Log.h：==这里的写法、用法很值得借鉴使用== 

   ```c++
   #ifndef Log_H
   #define LOG_H
   //  __FILE__ 获取源文件的相对路径和名字
   //  __LINE__ 获取该行代码在文件中的行号
   //  __func__ 或 __FUNCTION__ 获取函数名
   #define LOGI(format, ...) fprintf(stderr, "[INFO]%s [%s:%d %s()] " format "\n", "_",__FILE__,__LINE__,__func__ ,##__VA_ARGS__)
   #define LOGE(format, ...)  fprintf(stderr,"[ERROR]%s [%s:%d %s()] " format "\n","_",__FILE__,__LINE__,__func__ ,##__VA_ARGS__)
   
   #endif // !Log_H
   ```

2. StreamPusher.h （vs中的Study项目中，ffmpegStreamPusher中就是这个代码）

   ```c++
   #ifndef STREAMPUSHER_H
   #define STREAMPUSHER_H
   
   #include <stdio.h>
   #include <string>
   extern "C" {
   #include <libavcodec/avcodec.h>
   #include <libavformat/avformat.h>
   }
   
   class StreamPusher {
   public:
   	explicit StreamPusher(const char* srcUrl, const char* dstUrl, int dstVideoWidth, int dstVideoHeight, int dstVideoFps);
   	StreamPusher() = delete;
   	~StreamPusher();
   public:
   	void start();
   private:
   	bool connectSrc();
   	void closeConnectSrc();
   	bool connectDst();
   	void closeConnectDst();
   
   private:
   	std::string mSrcUrl;
   	std::string mDstUrl;
   
   	// 源头
   	AVFormatContext *mSrcFmtCtx = nullptr;
   	AVCodecContext  *mSrcVideoCodecCtx = nullptr;
   	AVStream        *mSrcVideoStream = nullptr;
   	int              mSrcVideoIndex = -1;
   	// 以下拉流时更新
   	int       mSrcVideoFps = 25;
   	int       mSrcVideoWidth = 1920;
   	int       mSrcVideoHeight = 1080;
   	int       mSrcVideoChannel = 3;
   
   	//目的
   	AVFormatContext *mDstFmtCtx = nullptr;
   	AVCodecContext  *mDstVideoCodecCtx = nullptr;
   	AVStream        *mDstVideoStream = nullptr;
   	int              mDstVideoIndex = -1;
   	int       mDstVideoFps = 25;//转码后默认fps
   	int       mDstVideoWidth = 1920;//转码后默认分辨率宽
   	int       mDstVideoHeight = 1080;//转码后默认分辨率高
   	int       mDstVideoChannel = 3;
   };
   #endif // !STREAMPUSHER_H
   ```

3. StreamPusher.cpp  （里面有很多ffmpeg的api函数，以后做相关的可以来参考着看）

   ```c++
   #include <iostream>
   #include "StreamPusher.h"
   #include "Log.h"
   #include <thread>
   extern "C" {
   #include <libavutil/pixfmt.h>
   #include <libswscale/swscale.h>
   #include <libavutil/imgutils.h>
   #include <libavutil/opt.h>
   #include <libavutil/time.h>
   }
   
   #pragma comment(lib, "avcodec.lib")
   #pragma comment(lib, "avformat.lib")
   #pragma comment(lib, "avutil.lib")
   #pragma comment(lib, "swscale.lib")
   
   
   StreamPusher::StreamPusher(const char* srcUrl, const char* dstUrl, int dstVideoWidth, int dstVideoHeight, int dstVideoFps) :
   	mSrcUrl(srcUrl), mDstUrl(dstUrl), mDstVideoWidth(dstVideoWidth), mDstVideoHeight(dstVideoHeight), mDstVideoFps(dstVideoFps) {
   	LOGI("StreamPusher::StreamPusher");
   }
   StreamPusher::~StreamPusher() {
   	LOGI("StreamPusher::~StreamPusher");
   }
   
   void StreamPusher::start() {
   	LOGI("StreamPusher::start begin");
   
   	bool conn = this->connectSrc();
       // 下面这里用 do{...} while(0) 来代替，代码看起来好一点，这嵌套太多层了
   	if (conn) {
   		conn = this->connectDst();
   		if (conn) {
   			// 初始化参数
   			AVFrame* srcFrame = av_frame_alloc();// pkt->解码->frame
   			AVFrame* dstFrame = av_frame_alloc();
   
   			dstFrame->width = mDstVideoWidth;
   			dstFrame->height = mDstVideoHeight;
   			dstFrame->format = mDstVideoCodecCtx->pix_fmt;
   			int dstFrame_buff_size = av_image_get_buffer_size(mDstVideoCodecCtx->pix_fmt, mDstVideoWidth, mDstVideoHeight, 1);
   			uint8_t* dstFrame_buff = (uint8_t*)av_malloc(dstFrame_buff_size);
   			av_image_fill_arrays(dstFrame->data, dstFrame->linesize, dstFrame_buff,
   				mDstVideoCodecCtx->pix_fmt, mDstVideoWidth, mDstVideoHeight, 1);
   
   			SwsContext* sws_ctx_src2dst = sws_getContext(mSrcVideoWidth, mSrcVideoHeight,
   				mSrcVideoCodecCtx->pix_fmt,
   				mDstVideoWidth, mDstVideoHeight,
   				mDstVideoCodecCtx->pix_fmt,
   				SWS_BICUBIC, nullptr, nullptr, nullptr);
   
   			AVPacket srcPkt;//拉流时获取的未解码帧
   			AVPacket* dstPkt = av_packet_alloc();// 推流时编码后的帧
   			int continuity_read_error_count = 0;// 连续读错误数量
   			int continuity_write_error_count = 0;// 连续写错误数量
   			int ret = -1;
   			int64_t frameCount = 0;
   			while (true) {//不中断会继续执行
   				if (av_read_frame(mSrcFmtCtx, &srcPkt) >= 0) {
   					continuity_read_error_count = 0;
   					if (srcPkt.stream_index == mSrcVideoIndex) {
   						// 读取pkt->解码->编码->推流
   						ret = avcodec_send_packet(mSrcVideoCodecCtx, &srcPkt);
   						if (ret == 0) {
   							ret = avcodec_receive_frame(mSrcVideoCodecCtx, srcFrame);
   							if (ret == 0) {
   								frameCount++;
   								//解码成功->修改分辨率->修改编码
   
   								// frame（yuv420p） 转 frame_bgr
   								sws_scale(sws_ctx_src2dst,
   									srcFrame->data, srcFrame->linesize, 0, mSrcVideoHeight,
   									dstFrame->data, dstFrame->linesize);
   
   								//开始编码 start
   								dstFrame->pts = dstFrame->pkt_dts = av_rescale_q_rnd(frameCount, mDstVideoCodecCtx->time_base, mDstVideoStream->time_base, (AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));
   								
   								/*
   								原来代码中使用的是 dstFrame->pkt_duration =
   								报错：'AVFrame::pkt_duration': 被声明已否决。 chatgpt解答：表示使用了已经被弃用的 AVFrame::pkt_duration 字段。在新的 FFmpeg 版本中，推荐使用 AVFrame::pkt_duration2 或者 AVFrame::best_effort_timestamp 字段
   								*/
   								dstFrame->best_effort_timestamp = av_rescale_q_rnd(1, mDstVideoCodecCtx->time_base, mDstVideoStream->time_base, (AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));
   
   								dstFrame->pkt_pos = frameCount;
   
   								ret = avcodec_send_frame(mDstVideoCodecCtx, dstFrame);
   								if (ret >= 0) {
   									ret = avcodec_receive_packet(mDstVideoCodecCtx, dstPkt);
   									if (ret >= 0) {
   										// 推流 start
   										dstPkt->stream_index = mDstVideoIndex;
   										ret = av_interleaved_write_frame(mDstFmtCtx, dstPkt);
   										if (ret < 0) {//推流失败
   											LOGI("av_interleaved_write_frame error: ret=%d", ret);
   											++continuity_write_error_count;
   											if (continuity_write_error_count > 5) {//连续5次推流失败，则断开连接
   												LOGI("av_interleaved_write_frame error: continuity_write_error_count=%d,dstUrl=%s", continuity_write_error_count, mDstUrl.data());
   												break;
   											}
   										}
   										else {
   											continuity_write_error_count = 0;
   										}
   										// 推流 end
   									}
   									else {
   										LOGI("avcodec_receive_packet error: ret=%d", ret);
   									}
   								}
   								else {
   									LOGI("avcodec_send_frame error: ret=%d", ret);
   								}
   								//开始编码 end
   							}
   							else {
   								LOGI("avcodec_receive_frame error: ret=%d", ret);
   							}
   						}
   						else {
   							LOGI("avcodec_send_packet error: ret=%d", ret);
   						}
   
   						//                          std::this_thread::sleep_for(std::chrono::milliseconds(1));
   					}
   					else {
   						//av_free_packet(&pkt);//过时
   						av_packet_unref(&srcPkt);
   					}
   				}
   				else {
   					//av_free_packet(&pkt);//过时
   					av_packet_unref(&srcPkt);
   					++continuity_read_error_count;
   					if (continuity_read_error_count > 5) {//连续5次拉流失败，则断开连接
   						LOGI("av_read_frame error: continuity_read_error_count=%d,srcUrl=%s", continuity_read_error_count, mSrcUrl.data());
   						break;
   					}
   					else {
   						std::this_thread::sleep_for(std::chrono::milliseconds(100));
   					}
   				}
   			}
   
   			// 销毁
   			av_frame_free(&srcFrame);
   			//av_frame_unref(srcFrame);
   			srcFrame = NULL;
   
   			av_frame_free(&dstFrame);
   			//av_frame_unref(dstFrame);
   			dstFrame = NULL;
   
   			av_free(dstFrame_buff);
   			dstFrame_buff = NULL;
   
   			sws_freeContext(sws_ctx_src2dst);
   			sws_ctx_src2dst = NULL;
   		}
   	}
   	this->closeConnectDst();
   	this->closeConnectSrc();
   
   	LOGI("StreamPusher::start end");
   }
   
   bool StreamPusher::connectSrc() {
   
   	mSrcFmtCtx = avformat_alloc_context();
   
   	AVDictionary* fmt_options = NULL;
   	av_dict_set(&fmt_options, "rtsp_transport", "tcp", 0); //设置rtsp底层网络协议 tcp or udp
   	av_dict_set(&fmt_options, "stimeout", "3000000", 0);   //设置rtsp连接超时（单位 us）
   	av_dict_set(&fmt_options, "rw_timeout", "3000000", 0); //设置rtmp/http-flv连接超时（单位 us）
   	av_dict_set(&fmt_options, "fflags", "discardcorrupt", 0);
   	//av_dict_set(&fmt_options, "timeout", "3000000", 0);//设置udp/http超时（单位 us）
   
   	int ret = avformat_open_input(&mSrcFmtCtx, mSrcUrl.data(), NULL, &fmt_options);
   
   	if (ret != 0) {
   		LOGI("avformat_open_input error: srcUrl=%s", mSrcUrl.data());
   		return false;
   	}
   
   	if (avformat_find_stream_info(mSrcFmtCtx, NULL) < 0) {
   		LOGI("avformat_find_stream_info error: srcUrl=%s", mSrcUrl.data());
   		return false;
   	}
   
   	// video start
   	for (int i = 0; i < mSrcFmtCtx->nb_streams; i++) {
   		if (mSrcFmtCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
   			mSrcVideoIndex = i;
   			break;
   		}
   	}
   	//mSrcVideoIndex = av_find_best_stream(mFmtCtx, AVMEDIA_TYPE_VIDEO, -1, -1, nullptr, 0);
   
   	if (mSrcVideoIndex > -1) {
   		AVCodecParameters* videoCodecPar = mSrcFmtCtx->streams[mSrcVideoIndex]->codecpar;
   		const AVCodec* videoCodec = avcodec_find_decoder(videoCodecPar->codec_id);
   		if (!videoCodec) {
   			LOGI("avcodec_find_decoder error: srcUrl=%s", mSrcUrl.data());
   			return false;
   		}
   
   		mSrcVideoCodecCtx = avcodec_alloc_context3(videoCodec);
   		if (avcodec_parameters_to_context(mSrcVideoCodecCtx, videoCodecPar) != 0) {
   			LOGI("avcodec_parameters_to_context error: srcUrl=%s", mSrcUrl.data());
   			return false;
   		}
   		if (avcodec_open2(mSrcVideoCodecCtx, videoCodec, nullptr) < 0) {
   			LOGI("avcodec_open2 error: srcUrl=%s", mSrcUrl.data());
   			return false;
   		}
   
   		mSrcVideoCodecCtx->thread_count = 1;
   		mSrcVideoStream = mSrcFmtCtx->streams[mSrcVideoIndex];
   
   		if (0 == mSrcVideoStream->avg_frame_rate.den) {
   			LOGI("avg_frame_rate.den = 0 error: srcUrl=%s", mSrcUrl.data());
   			mSrcVideoFps = 25;
   		}
   		else {
   			mSrcVideoFps = mSrcVideoStream->avg_frame_rate.num / mSrcVideoStream->avg_frame_rate.den;
   		}
   
   		mSrcVideoWidth = mSrcVideoCodecCtx->width;
   		mSrcVideoHeight = mSrcVideoCodecCtx->height;
   
   	}
   	else {
   		LOGI("There is no video stream in the video: srcUrl=%s", mSrcUrl.data());
   		return false;
   	}
   	// video end;
   	return true;
   }
   void StreamPusher::closeConnectSrc() {
   	std::this_thread::sleep_for(std::chrono::milliseconds(1));
   
   	if (mSrcVideoCodecCtx) {
   		avcodec_close(mSrcVideoCodecCtx);
   		avcodec_free_context(&mSrcVideoCodecCtx);
   		mSrcVideoCodecCtx = nullptr;
   	}
   
   	if (mSrcFmtCtx) {
   		// 拉流不需要释放start
   		//if (mFmtCtx && !(mFmtCtx->oformat->flags & AVFMT_NOFILE)) {
   		//    avio_close(mFmtCtx->pb);
   		//}
   		// 拉流不需要释放end
   		avformat_close_input(&mSrcFmtCtx);
   		avformat_free_context(mSrcFmtCtx);
   		mSrcFmtCtx = nullptr;
   	}
   }
   bool StreamPusher::connectDst() {
   	// 这里直接给 rtsp 是可以的，跟命令行推流时给 -f rtsp 应该是一个意思，rtmp放这里会报错，然后推流到rtmp服务器时是用的 -f flv，所以推理到rtmp时把这“rtsp”改成“flv”即可。具体参数解释可以看 "2.4 ffmpeg中的一些API"
   	if (avformat_alloc_output_context2(&mDstFmtCtx, NULL, "rtsp", mDstUrl.data()) < 0) {
   		LOGI("avformat_alloc_output_context2 error: dstUrl=%s", mDstUrl.data());
   		return false;
   	}
   
   	// init video start
   	const AVCodec* videoCodec = avcodec_find_encoder(AV_CODEC_ID_H264);
   	if (!videoCodec) {
   		LOGI("avcodec_find_encoder error: dstUrl=%s", mDstUrl.data());
   		return false;
   	}
   	mDstVideoCodecCtx = avcodec_alloc_context3(videoCodec);
   	if (!mDstVideoCodecCtx) {
   		LOGI("avcodec_alloc_context3 error: dstUrl=%s", mDstUrl.data());
   		return false;
   	}
   	//int bit_rate = 300 * 1024 * 8;  //压缩后每秒视频的bit位大小 300kB
   	int bit_rate = 4096000;
   	// CBR：Constant BitRate - 固定比特率
   	mDstVideoCodecCtx->flags |= AV_CODEC_FLAG_QSCALE;
   	mDstVideoCodecCtx->bit_rate = bit_rate;
   	mDstVideoCodecCtx->rc_min_rate = bit_rate;
   	mDstVideoCodecCtx->rc_max_rate = bit_rate;
   	mDstVideoCodecCtx->bit_rate_tolerance = bit_rate;
   
   	//VBR
       //  mDstVideoCodecCtx->flags |= AV_CODEC_FLAG_QSCALE;
       //  mDstVideoCodecCtx->rc_min_rate = bit_rate / 2;
       //  mDstVideoCodecCtx->rc_max_rate = bit_rate / 2 + bit_rate;
       //  mDstVideoCodecCtx->bit_rate = bit_rate;
   
   	//ABR：Average Bitrate - 平均码率
       // mDstVideoCodecCtx->bit_rate = bit_rate;
   
   	mDstVideoCodecCtx->codec_id = videoCodec->id;
   	mDstVideoCodecCtx->pix_fmt = AV_PIX_FMT_YUV420P;// 不支持AV_PIX_FMT_BGR24直接进行编码
   	mDstVideoCodecCtx->codec_type = AVMEDIA_TYPE_VIDEO;
   	mDstVideoCodecCtx->width = mDstVideoWidth;
   	mDstVideoCodecCtx->height = mDstVideoHeight;
   	mDstVideoCodecCtx->time_base = { 1,mDstVideoFps };
   	//  mDstVideoCodecCtx->framerate = { mDstVideoFps, 1 };
   	mDstVideoCodecCtx->gop_size = 5;
   	mDstVideoCodecCtx->max_b_frames = 0;
   	mDstVideoCodecCtx->thread_count = 1;
   	mDstVideoCodecCtx->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;   //添加PPS、SPS
   	AVDictionary* video_codec_options = NULL;
   
   	//H.264
   	if (mDstVideoCodecCtx->codec_id == AV_CODEC_ID_H264) {
   		//            av_dict_set(&video_codec_options, "profile", "main", 0);
   		av_dict_set(&video_codec_options, "preset", "superfast", 0);
   		av_dict_set(&video_codec_options, "tune", "zerolatency", 0);
   	}
   	//H.265
   	if (mDstVideoCodecCtx->codec_id == AV_CODEC_ID_H265) {
   		av_dict_set(&video_codec_options, "preset", "ultrafast", 0);
   		av_dict_set(&video_codec_options, "tune", "zero-latency", 0);
   	}
   	if (avcodec_open2(mDstVideoCodecCtx, videoCodec, &video_codec_options) < 0) {
   		LOGI("avcodec_open2 error: dstUrl=%s", mDstUrl.data());
   		return false;
   	}
   	mDstVideoStream = avformat_new_stream(mDstFmtCtx, videoCodec);
   	if (!mDstVideoStream) {
   		LOGI("avformat_new_stream error: dstUrl=%s", mDstUrl.data());
   		return false;
   	}
   	mDstVideoStream->id = mDstFmtCtx->nb_streams - 1;
   	// stream的time_base参数非常重要，它表示将现实中的一秒钟分为多少个时间基, 在下面调用avformat_write_header时自动完成
   	avcodec_parameters_from_context(mDstVideoStream->codecpar, mDstVideoCodecCtx);
   	mDstVideoIndex = mDstVideoStream->id;
   	// init video end
   
   	av_dump_format(mDstFmtCtx, 0, mDstUrl.data(), 1);
   
   	// open output url
   	if (!(mDstFmtCtx->oformat->flags & AVFMT_NOFILE)) {
   		if (avio_open(&mDstFmtCtx->pb, mDstUrl.data(), AVIO_FLAG_WRITE) < 0) {
   			LOGI("avio_open error: dstUrl=%s", mDstUrl.data());
   			return false;
   		}
   	}
   
   	AVDictionary* fmt_options = NULL;
   	//av_dict_set(&fmt_options, "bufsize", "1024", 0);
   	av_dict_set(&fmt_options, "rw_timeout", "30000000", 0); //设置rtmp/http-flv连接超时（单位 us）
   	av_dict_set(&fmt_options, "stimeout", "30000000", 0);   //设置rtsp连接超时（单位 us）
   	av_dict_set(&fmt_options, "rtsp_transport", "tcp", 0);
   	//        av_dict_set(&fmt_options, "fflags", "discardcorrupt", 0);
   
   		//av_dict_set(&fmt_options, "muxdelay", "0.1", 0);
   		//av_dict_set(&fmt_options, "tune", "zerolatency", 0);
   
   	mDstFmtCtx->video_codec_id = mDstFmtCtx->oformat->video_codec;
   
   	if (avformat_write_header(mDstFmtCtx, &fmt_options) < 0) { // 调用该函数会将所有stream的time_base，自动设置一个值，通常是1/90000或1/1000，这表示一秒钟表示的时间基长度
   		LOGI("avformat_write_header error: dstUrl=%s", mDstUrl.data());
   		return false;
   	}
   	return true;
   }
   void StreamPusher::closeConnectDst() {
   	std::this_thread::sleep_for(std::chrono::milliseconds(1));
   	if (mDstFmtCtx) {
   		// 推流需要释放start
   		if (mDstFmtCtx && !(mDstFmtCtx->oformat->flags & AVFMT_NOFILE)) {
   			avio_close(mDstFmtCtx->pb);
   		}
   		// 推流需要释放end
   		avformat_free_context(mDstFmtCtx);
   		mDstFmtCtx = nullptr;
   	}
   
   	if (mDstVideoCodecCtx) {
   		if (mDstVideoCodecCtx->extradata) {
   			av_free(mDstVideoCodecCtx->extradata);
   			mDstVideoCodecCtx->extradata = NULL;
   		}
   
   		avcodec_close(mDstVideoCodecCtx);
   		avcodec_free_context(&mDstVideoCodecCtx);
   		mDstVideoCodecCtx = nullptr;
   	}
   }
   ```

4. main.cpp

   ​	//ffmpeg RTSP推流 https://www.jianshu.com/p/a9c7b08be46e 	

   ​	//ffmpeg 推流参数  https://blog.csdn.net/qq_173     # 参考吧，内容好像一般

   ```c++
   #include <iostream>
   #include "StreamPusher.h"
   int main(int argc, char* argv[]) {
   	srand((int)time(NULL));
   	const char* srcUrl = "rtsp://192.168.108.134:554/user=admin&password=&channel=1&stream=1.sdp?";
   	
       // 推到rtsp服务器：bool StreamPusher::connectDst(){}此函数第一行里给“rtsp”
       const char* dstUrl = "rtsp://localhost/test";
       // 推到rtmp服务器：connectDst() 函数第一行里改成“flv”
       const char* dstUrl = "rtmp://192.168.125.128/live/456";
       
   	int dstVideoFps = 20;
   	int dstVideoWidth = 800;
   	int dstVideoHeight = 448;
   	StreamPusher pusher(srcUrl, dstUrl, dstVideoWidth, dstVideoHeight, dstVideoFps);
   	pusher.start();
   	return 0;
   }
   ```

CmakeLists.txt的一个示例：原来自带的，自己还没试过

```cmake
cmake_minimum_required(VERSION 3.1.3)

project(BXC_StreamPusher LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 11)

if("${CMAKE_BUILD_TYPE}" STREQUAL "")
  set(CMAKE_BUILD_TYPE "Debug")
endif()

message(STATUS "编译类型: ${CMAKE_BUILD_TYPE}")
message(STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")

set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g2 -ggdb")
set(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O3 -Wall")

set(INCLUDE_DIR /usr/local/include)
set(LIB_DIR /usr/local/lib)

#set(INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/linux/include)
#set(LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/linux/lib)

include_directories(${INCLUDE_DIR})
link_directories(${LIB_DIR})

add_executable(BXC_StreamPusher
        StreamPusher/StreamPusher.cpp
        StreamPusher/main.cpp
        )

target_link_libraries(BXC_StreamPusher avformat avcodec avutil swscale swresample pthread)
```

---

​	对于上面“StreamPusher.cpp”中的 “if (conn)”用了太多的if else嵌套了，我用do whie(0)进行了改写，尽量用一个层级，有if失败的地方就是尽早continue，但是代码我还没测过，不知道有没有问题，先放这里吧：

```cpp
do 
{	
	if (!conn) {
		std::cerr << "源流媒体链接失败..." << std::endl;
		break;
	}
	conn = this->connectDst();
	if (!conn) {
		std::cerr << "推流服务器链接失败..." << std::endl;
		break;
	}

	// 初始化参数
	AVFrame* srcFrame = av_frame_alloc(); // pkt->解码->frame
	AVFrame* dstFrame = av_frame_alloc();

	dstFrame->width = mDstVideoWidth;
	dstFrame->height = mDstVideoHeight;
	dstFrame->format = mDstVideoCodecCtx->pix_fmt;  // AV_PIX_FMT_YUV420P;
	int dstFrame_buff_size = av_image_get_buffer_size(mDstVideoCodecCtx->pix_fmt, mDstVideoWidth, mDstVideoHeight, 1);
	uint8_t* dstFrame_buff = (uint8_t*)av_malloc(dstFrame_buff_size);
	av_image_fill_arrays(dstFrame->data, dstFrame->linesize, dstFrame_buff,
		mDstVideoCodecCtx->pix_fmt, mDstVideoWidth, mDstVideoHeight, 1);

	SwsContext* sws_ctx_src2dst = sws_getContext(mSrcVideoWidth, mSrcVideoHeight,
		mSrcVideoCodecCtx->pix_fmt,
		mDstVideoWidth, mDstVideoHeight,
		mDstVideoCodecCtx->pix_fmt,
		SWS_BICUBIC, nullptr, nullptr, nullptr);

	AVPacket srcPkt; // 拉流时获取的未解码帧
	AVPacket* dstPkt = av_packet_alloc(); // 推流时编码后的帧
	int continuity_read_error_count = 0; // 连续读错误数量
	int continuity_write_error_count = 0; // 连续写错误数量
	int ret = -1;
	int64_t frameCount = 0;

	while (true) {
		if (av_read_frame(mSrcFmtCtx, &srcPkt) >= 0) {
			continuity_read_error_count = 0;

			if (srcPkt.stream_index != mSrcVideoIndex) {
				//av_free_packet(&pkt);//过时
				av_packet_unref(&srcPkt);
				continue;
			}
			// 读取pkt->解码->编码->推流
			ret = avcodec_send_packet(mSrcVideoCodecCtx, &srcPkt);
			if (ret != 0) { 
				LOGI("avcodec_send_packet error: ret=%d", ret); 
				continue;
			}
			ret = avcodec_receive_frame(mSrcVideoCodecCtx, srcFrame);
			if (ret != 0) {
				LOGI("avcodec_receive_frame error: ret=%d", ret);
				continue;
			}

			frameCount++;
			// 解码成功->修改分辨率->修改编码

			// frame（yuv420p） 转 frame_bgr
			sws_scale(sws_ctx_src2dst,
				srcFrame->data, srcFrame->linesize, 0, mSrcVideoHeight,
				dstFrame->data, dstFrame->linesize);

			//开始编码 start
			dstFrame->pts = dstFrame->pkt_dts = av_rescale_q_rnd(frameCount, mDstVideoCodecCtx->time_base, mDstVideoStream->time_base, (AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));

			
			// 原来代码中使用的是 dstFrame->pkt_duration =
			// 报错：'AVFrame::pkt_duration': 被声明已否决。 chatgpt解答：表示使用了已经被弃用的 AVFrame::pkt_duration 字段。在新的 FFmpeg 版本中，推荐使用 AVFrame::pkt_duration2 或者 AVFrame::best_effort_timestamp 字段
			dstFrame->best_effort_timestamp = av_rescale_q_rnd(1, mDstVideoCodecCtx->time_base, mDstVideoStream->time_base, (AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));

			dstFrame->pkt_pos = frameCount;
			ret = avcodec_send_frame(mDstVideoCodecCtx, dstFrame);
			if (ret < 0) {
				LOGI("avcodec_send_frame error: ret=%d", ret);
				continue;
			}

			ret = avcodec_receive_packet(mDstVideoCodecCtx, dstPkt);
			if (ret < 0) {
				LOGI("avcodec_receive_packet error: ret=%d", ret);
				continue;
			}

			// 推流 start
			dstPkt->stream_index = mDstVideoIndex;
			ret = av_interleaved_write_frame(mDstFmtCtx, dstPkt);
			if (ret >= 0) {   // 推流成功
				continuity_write_error_count = 0;
				continue;
			}
			// 下面就是推流失败
			LOGI("av_interleaved_write_frame error: ret=%d", ret);
			++continuity_write_error_count;
			if (continuity_write_error_count > 5) {// 连续5次推流失败，则断开连接
				LOGI("av_interleaved_write_frame error: continuity_write_error_count=%d,dstUrl=%s", continuity_write_error_count, mDstUrl.data());
				break;
			}

		}
		else {
			// av_free_packet(&pkt);//过时
			av_packet_unref(&srcPkt);
			++continuity_read_error_count;
			if (continuity_read_error_count > 5) {// 连续5次拉流失败，则断开连接
				LOGI("av_read_frame error: continuity_read_error_count=%d,srcUrl=%s", continuity_read_error_count, mSrcUrl.data());
				break;
			}
			else {
				std::this_thread::sleep_for(std::chrono::milliseconds(100));
			}
		}
	}

	// 销毁
	av_frame_free(&srcFrame);
	//av_frame_unref(srcFrame);
	srcFrame = NULL;

	av_frame_free(&dstFrame);
	//av_frame_unref(dstFrame);
	dstFrame = NULL;

	av_free(dstFrame_buff);
	dstFrame_buff = NULL;

	sws_freeContext(sws_ctx_src2dst);
	sws_ctx_src2dst = NULL;
} while (0);
```

### 2.4. ffmpeg中一些API

1. 报错：'AVFrame::pkt_duration': 被声明已否决：
   	chatgpt解答：表示使用了已经被弃用的 AVFrame::pkt_duration 字段。在新的 FFmpeg 版本中，推荐使用 AVFrame::pkt_duration2 或者 AVFrame::best_effort_timestamp 字段，2.3.2中的代码也是将 “dstFrame->pkt_duration =” 改成了 “dstFrame->best_effort_timestamp”就OK了。
2. avformat_alloc_output_context2()参数解释：(来自chatgpt)
   用于创建一个输出格式上下文，并分配所需的内存空间。示例：avformat_alloc_output_context2(&mDstFmtCtx, NULL, "rtsp", "rtsp://localhost/123")
   - AVFormatContext **ctx：输出格式上下文指针的指针。如果成功，将会分配内存，并将指针赋值给这个参数。
   - AVOutputFormat *oformat：要使用的输出格式。如果为 NULL，则自动选择合适的输出格式。
   - const char *format_name：要使用的输出格式名称。（==主要就是这个参数==，就是上面示例的"rtsp"位置，直接给“rtmp”就是错的，rtmp的要给flv），这个参数让FFmpeg 将尝试创建一个特定格式的输出文件，常见格式如下：
     - ==mp4==：MPEG-4 格式 (.mp4 文件扩展名)
       ==avi==：AVI 格式 (.avi 文件扩展名)
       ==flv==：Flash 视频格式 (.flv 文件扩展名)
       ==mov==：QuickTime 格式 (.mov 文件扩展名)
       ==mpeg==：MPEG-1 和 MPEG-2 格式 (.mpg 文件扩展名)
       ==matroska==：Matroska 格式 (.mkv 文件扩展名)
       ==webm==：WebM 格式 (.webm 文件扩展名)
       ==rtsp==:  这是我加的，也是ok的，但“rtmp”不行，要用"flv"替代
       
     - 如果为 NULL，则自动选择合适的输出格式。
     
     - 如果指定了特定的 format_name，但是 FFmpeg 库中没有对应的输出格式，则此函数将返回错误，并且无法创建输出文件。所以不确定要使用哪种输出格式，可以使用 FFmpeg 提供的 av_guess_format 函数猜测文件格式。例如
       AVOutputFormat *output_format = ==av_guess_format(NULL, "output_file.mp4", NULL)==;  # 这将根据文件扩展名猜测文件格式，或许就可以直接给 .flv (注意av_guess_format这里一定要带点.，而上面avformat_alloc_output_context2给的话一定不要带点.)
       - 如果是guess的.flv格式，得到的结果：都是枚举值
         output_format->audio_codec    # 86017  代表 AV_CODEC_ID_MP3
         output_format->video_codec    # 21     代表 AV_CODEC_ID_FLV1
       
     
   - const char *filename：要推送的文件名或 URL。如果为 NULL，则不会创建输出文件。
   - int buffer_size：内部缓冲区大小。如果为 0，则使用默认值。
   - AVIOContext *opaque：自定义 IO 上下文。如果为 NULL，则使用默认的 IO 上下文。
   - int flags：一组标志位，用于控制输出格式上下文的行为。可以使用 AVFMT_NOFILE 表示不创建输出文件，AVFMT_GLOBALHEADER 表示在文件头部包含全局参数等。
3. 11111
4. 22222

### 2.5. 按Q停止程序

ffmpeg在命令行推流时，按Q是可以停止的，下面这是问的chatgpt的回答，还没测试过，先放这里吧。

```c++
#include <stdio.h>
#include <signal.h>
#include <libavformat/avformat.h>

static int received_sigterm = 0;
static int show_help = 0;

static void sigterm_handler(int sig)
{
    if (sig == SIGINT || sig == SIGTERM)
        received_sigterm = sig;
}

static void siginfo_handler(int sig)
{
    if (sig == SIGINFO) {
        show_help = 1;
    }
}

static void show_help_options(void)
{
    printf("FFmpeg push stream demo\n"
           "Usage: ./push_stream input_file stream_url\n"
           "Press \'q\' to stop pushing stream\n"
           "Press \'?\' to show help options\n");
}

int main(int argc, char *argv[])
{
    if (argc < 3) {
        printf("Missing arguments\n");
        show_help_options();
        return 1;
    }

    signal(SIGINT, sigterm_handler);
    signal(SIGTERM, sigterm_handler);
    signal(SIGINFO, siginfo_handler);

    av_register_all();

    AVFormatContext *input_ctx = NULL;
    AVInputFormat *input_fmt = NULL;
    int ret = avformat_open_input(&input_ctx, argv[1], input_fmt, NULL);
    if (ret < 0) {
        printf("Failed to open input file '%s'\n", argv[1]);
        return 1;
    }

    AVFormatContext *output_ctx = NULL;
    AVOutputFormat *output_fmt = av_guess_format("flv", argv[2], NULL);
    ret = avformat_alloc_output_context2(&output_ctx, output_fmt, NULL, argv[2]);
    if (ret < 0) {
        printf("Failed to allocate output context\n");
        return 1;
    }

    ret = avio_open(&output_ctx->pb, argv[2], AVIO_FLAG_WRITE);
    if (ret < 0) {
        printf("Failed to open output file '%s'\n", argv[2]);
        return 1;
    }

    ret = avformat_write_header(output_ctx, NULL);
    if (ret < 0) {
        printf("Failed to write header\n");
        return 1;

}

AVPacket pkt;
av_init_packet(&pkt);
pkt.data = NULL;
pkt.size = 0;

while (!received_sigterm) {
    ret = av_read_frame(input_ctx, &pkt);
    if (ret < 0)
        break;

    pkt.stream_index = 0;  // assuming only one stream

    ret = av_interleaved_write_frame(output_ctx, &pkt);
    if (ret < 0) {
        printf("Error writing packet to output stream\n");
        break;
    }

    av_packet_unref(&pkt);

    if (show_help) {
        show_help = 0;
        show_help_options();
    }
}

av_write_trailer(output_ctx);

avio_close(output_ctx->pb);
avformat_free_context(output_ctx);

avformat_close_input(&input_ctx);
avformat_free_context(input_ctx);

return 0;
}
```



## 三、virtual camera

​	一个真实设备video0，一个虚拟设备video1。将video0的数据读出写入到video1，然后应用去读取video1的数据，看到这个操作，突然浮想联翩。手机上如果装了这个设备，是不是可以在和别人视频的时候，播放本地文件。是不是可以抖音上传假视频。还想去了之前看过的一个私活，摄像头读取本地文件显示。

- [pyvirtualcam](https://github.com/letmaik/pyvirtualcam): python的虚拟摄像头库(pip安装)，windows上搭配obs的vitrual cream来使用。

  - 简单来说，就是用opencv读取真实摄像头或者视频文件，然后用这个库传递给obs的virtual cream，然后进行显示出来

  - ```python
    import pyvirtualcam
    import numpy as np
    
    # 点进去看，这里一个参数默认是PixelFormat.RGB
    with pyvirtualcam.Camera(width=1280, height=720, fps=20) as cam:
        print(f'Using virtual camera: {cam.device}')
        frame = np.zeros((cam.height, cam.width, 3), np.uint8)  # RGB
        while True:
            # frame[:] = cam.frames_sent % 255  # grayscale animation
            frame[:, :, 0] = cam.frames_sent % 255  # 红色渐变（所以0是red）
            cam.send(frame)
            cam.sleep_until_next_frame()
    # 这是pyvirtualcam中的代码,它里面包含了很多example，直接拿来改
    ```
```
    
- pyvirtualcam.Camera创建时还有两个比较重要的参数：
  
    ```python
    from pyvirtualcam import PixelFormat
    import platform
    device_val = None
    os = platform.system()
    if os == "Linux":
        device_val = "/dev/video2"
        
    with pyvirtualcam.Camera(width=1280, height=720, fps=20, 			 	   fmt=PixelFormat.BGR, device=device_val, print_fps=20) as cam:
```

    	- fmt=PixelFormat.BGR  # 这就把RGB格式改成BGR了;
    	- device=device_val    # 一般就linux系统才加这个参数，一般就默认为None吧。

然后linux上就不是用obs的vitual cream，而是用这个项目[v4l2loopback](https://github.com/umlaeute/v4l2loopback)。

然后在pyvirtualcam推荐了一个相似的项目：[UnityCapture](https://github.com/schellingb/UnityCapture)。

---

以上是用的obs自带的虚拟摄像头，看教程很多说，比较QQ这些用不了，就要下载额外的虚拟摄像头（一般注册四个），看这个[教程](https://zhuanlan.zhihu.com/p/157806785)吧，但是我跟着走了，QQ设置起，虚拟摄像头能开启，但还是没有画面，不知道为啥。



## 四、window下SRS的编译

现在已经有了编译好的二进制文件了，可以直接安装使用，下面时从源码编译：

- 具体过程不详细写了，要注意系统中的环境变量，是会影响到cygwin中的。
- 这是window版本的[项目](https://github.com/ossrs/srs-windows)，跟着步骤来，然后./configure可能遇到的错误：（顺序不一定）
  - 缺少头文件：fatal error: sys/socket.h，，解决，命令==apt-cyg install cygwin-devel==，具体可看cygwin中关于笔记的东西。
  - 然后它会编译ffmepeg，会用到opus库，而且这个库要用pkg-config来找，虽然我这里自己编译了opus，还配置了pkg-config的环境变量，还是会报错，所以处理办法是编译ffmepg时直接不要这个库，它对应的功能也暂时用不到，那就在 auto/depends.sh 大搞711、712行处，把有关于opus的指令的enable都改成disable。（用自己编译的ffmpeg在make时会报错，应该是编译的命令太简单了，有些配置没给到）
  - 还会报错说找不到头文件 srtp2/srtp.h ，解决办法是：到[这里](https://github.com/cisco/libsrtp)下载源码，然后./configure --prefix=一个路径  && make && make install  就会得到它的头文件和库文件，然后将路径 trunk/objs 下创建一个名为==srtp2==的文件夹，然后将其刚刚得到的includ、lib两个文件夹复制到里面就行了。

## 五、ffmpeg读取流来展示

这个跟推流没关系，但主要也涉及到拉流解码展示，算是比较吻合。

---

下载最前面的环境问题：

首先这次我用了ffmpeg的两个版本：

- ffmpeg-n4.4-latest-linux64-gpl-shared-4.4.tar.xz  （这是别人编译好的）（在ubuntu和windows上都能直接跑起来）

  - 这个版本在centos上跑不起来，make就会报错，是因为缺乏libmvec.so.1这个库，而这个库是因为glibc版本的问题(centos的glibc是2.17的，版本太低，yum暂时最高就是这；手动去升级到2.25的话，是有可能会把系统弄崩的，所以要慎重，虚拟机可以先拍快照)；
  - 然后我在一个centos虚拟机上把glibc升级到2.25，就能成功运行；

- FFmpeg-n3.4.9  （这个是自己源码编译的）

  - 这个版本在ubuntu上运行说缺少libswresample.so.2;

  - 这个在glibc为2.17的centos上能make能成功，但是运行时，avformat_open_input()函数返回的是-1330794744，报的错是“Segmentation fault (core dumped)”，解决办法，在main()函数开头加这样两行：

    > av_register_all();
    >
    > avformat_network_init();

    一定注意：这俩API在4版本中是没有用了的，下面的代码里就没加，如果是3的版本，一定要加这两行，不然就只会得到-1330794744。

---

​	ffmpeg的avformat_open_input此函数，一般给视频地址、rtsp地址，linux下的摄像头名字，windows的摄像头还不知道怎么搞(这有一个[博客](https://blog.csdn.net/iamqianrenzhan/article/details/84830277)，暂时没用，放这里看以后有没有可能做一个参考),

rtsp摄像头读取时，直接使用opencv解流，画面会存在明显的延迟，现在使用ffmpeg来读取流，然后用opencv的cv::imshow()来展示；或者再转换成opengl的格式，用imgui的界面来展示

---

\* AV_PIX_FMT_BGRA  对应opencv中的CV_8UC4, 

\* AV_PIX_FMT_BGR24 对应opencv中的CV_8UC3。

#### 第一种：ffmpeg读流，转Mat格式，opencv做展示

- ffmpeg读取流，转成用opencv的Mat格式，然后opencv来imshow;

- 使用的是cpu，然后主要是参考的是写播放器那个教程的代码，ffmpeg3、4基本都可以，在linux、windows都可以。

- 当执行程序直接出现“Segmentation fault (core dumped)”，一定去看main函数开头的两行：

  - ==**一定注意区分ffmpeg的3、4版本的区别**==。

  ```
  // ffmpeg3.4这种3的版本一定要这两行，4的大版本一定不要，注意版本
      av_register_all();
  	avformat_network_init();
  ```

- 注意：在使用vs执行这个代码时，内存的使用在慢慢的增加，发现是vs的ServiceHub.DataWarehouseHost.exe这个程序在持续慢慢泄露内存，要使用的话，要解决这个问题，或者说linux上看会不会出现这个问题。

- 增加一个打印错误信息的宏定义：

  ```c++
  char av_error[AV_ERROR_MAX_STRING_SIZE] = { 0 };
  #define av_err2str(errnum) \
      av_make_error_string(av_error, AV_ERROR_MAX_STRING_SIZE, errnum)
  
  //获取音视频流信息,h264 flv  （下面这个函数是ffmpeg带的）
  ret = avformat_find_stream_info("视频流地址，文件地址这些", nullptr);
  if (ret != 0) {
      std::cout << av_err2str(ret) << std::endl;
      goto END;
  }
  ```

  主代码：

  ```c++
  #include <vector>
  #include <opencv2/opencv.hpp>
  
  extern "C" {
  #include <libavcodec/avcodec.h>
  #pragma comment(lib, "avcodec.lib")
  
  #include <libavformat/avformat.h>
  #pragma comment(lib, "avformat.lib")
  
  #include <libavutil/imgutils.h>
  #pragma comment(lib, "avutil.lib")
  // 彩色画面要的
  #include <libswscale/swscale.h>
  #pragma comment(lib, "swscale.lib")
  }
  
  
  /*
  	yuvj×××这个格式被丢弃了，然后转化为yuv格式，
  	不然有一个警告 deprecated pixel format used, make sure you did set range correctly，
  	这个问题在前面和win32写api时可用，但是不知道其它地方会不会报错，就改过了
  */
  AVPixelFormat ConvertDeprecatedFormat(enum AVPixelFormat format)
  {
  	switch (format) {
  	case AV_PIX_FMT_YUVJ420P:
  		return AV_PIX_FMT_YUV420P;
  		break;
  	case AV_PIX_FMT_YUVJ422P:
  		return AV_PIX_FMT_YUV422P;
  		break;
  	case AV_PIX_FMT_YUVJ444P:
  		return AV_PIX_FMT_YUV444P;
  		break;
  	case AV_PIX_FMT_YUVJ440P:
  		return AV_PIX_FMT_YUV440P;
  		break;
  	default:
  		return format;
  		break;
  	}
  }
  
  struct Color_RGB {
  	uint8_t r;
  	uint8_t g;
  	uint8_t b;
  };
  
  
  // 把获取第一帧那个函数拆分了一下
  struct DecoderParam {
  	AVFormatContext *fmtCtx;
  	AVCodecContext *vcodecCtx;
  	int width;
  	int height;
  	int VideoStreamIndex;
  };
  
  void InitDecoder(const char* filepath, DecoderParam &param) {
  	AVFormatContext *fmtCtx = nullptr;
      AVCodecContext *vcodecCtx = nullptr;
  
  	// linux上这里一直报错，返回的是 -1330794744，网上搜索一圈了，ffmpeg也重新编译了，还是不行
      // ret：0表示成功，-2代表文件不存在，
  	int ret = avformat_open_input(&fmtCtx, filepath, NULL, NULL);
  	avformat_find_stream_info(fmtCtx, NULL);
  
  	for (int i = 0; i < fmtCtx->nb_streams; i++) {
  		const AVCodec *codec = avcodec_find_decoder(fmtCtx->streams[i]->codecpar->codec_id);
  		if (codec->type == AVMEDIA_TYPE_VIDEO) {
  			param.VideoStreamIndex = i;
  			vcodecCtx = avcodec_alloc_context3(codec);
  			avcodec_parameters_to_context(vcodecCtx, fmtCtx->streams[i]->codecpar);
  			avcodec_open2(vcodecCtx, codec, NULL);
               break;  // 我加的，应该找到后就可以break了，有问题再删掉。
  		}
  	}
  	param.fmtCtx = fmtCtx;
  	param.vcodecCtx = vcodecCtx;
  	param.width = vcodecCtx->width;
  	param.height = vcodecCtx->height;
  }
  
  /* 这种写法不能要，会内存泄漏 */
  //AVFrame* RequestFrame(DecoderParam &param) {
  //	auto &fmtCtx = param.fmtCtx;
  //	auto &vcodecCtx = param.vcodecCtx;
  //	auto &VideoStreamIndex = param.VideoStreamIndex;
  //
  //	while (1) {
  //		AVPacket *packet = av_packet_alloc();  // 主要是这里一直没释放
  //		int ret = av_read_frame(fmtCtx, packet);
  //		if (ret == 0 && packet->stream_index == param.VideoStreamIndex) {
  //			ret = avcodec_send_packet(vcodecCtx, packet);
  //			if (ret == 0) {
  //				AVFrame *frame = av_frame_alloc();
  //				ret = avcodec_receive_frame(vcodecCtx, frame);
  //				if (ret == 0) {
  //					av_packet_unref(packet);
  //					return frame;
  //				}
  //				else if (ret == AVERROR(EAGAIN)) {
  //					av_frame_unref(frame);
  //				}
  //			}
  //		}
  //
  //		av_packet_unref(packet);
  //	}
  //	return nullptr;
  //}
  // ******改成传指针的方式（解决读取内存泄露）
  int RequestFrame(DecoderParam &param, AVFrame *frame, AVPacket *packet) {
  	auto &fmtCtx = param.fmtCtx;
  	auto &vcodecCtx = param.vcodecCtx;
  	auto &VideoStreamIndex = param.VideoStreamIndex;
  	while (1) {
  		// AVPacket *packet = av_packet_alloc();  // 分配空间的都不要写这
  		int ret = av_read_frame(fmtCtx, packet);
  		if (ret == 0 && packet->stream_index == param.VideoStreamIndex) {
  			ret = avcodec_send_packet(vcodecCtx, packet);
  			if (ret == 0) {
  				ret = avcodec_receive_frame(vcodecCtx, frame);
  				if (ret == 0) {
  					av_packet_unref(packet);
  					return 0;  // 代表读取成功
  				}
  				else if (ret == AVERROR(EAGAIN)) {
  					av_frame_unref(frame);
  				}
  			}
  		}
  		av_packet_unref(packet);
  	}
  	return -1;
  }
  
  // 写一个转换颜色编码的函数（也不用这种，直接传指针进来）
  //std::vector<Color_RGB> GetRGBPixels(AVFrame *frame, std::vector<Color_RGB> &buffer) {
  //	static SwsContext *swsctx = nullptr;
  //	swsctx = sws_getCachedContext(swsctx,
  //		frame->width, frame->height, static_cast<AVPixelFormat>(frame->format),
  //		frame->width, frame->height, AVPixelFormat::AV_PIX_FMT_BGR24, NULL, NULL, NULL, NULL
  //	);  // 这里原来的类型转换是用的 (AVPixelFormat)frame->format
  //
  //	// 每次循环调用这个函数，都会重新分配这个vector，debug下就很慢
  //	//std::vector<Color_RGB> buffer(frame->width * frame->height);
  //
  //	//uint8_t* data[] = {(uint8_t*)&buffer[0]};
  //	uint8_t* data[] = { reinterpret_cast<uint8_t*>(&buffer[0]) };  // c++类型的指针风格转换
  //	int linesize[] = { frame->width * 3 };
  //	// sws_scale 函数可以对画面进行缩放，同时还能改变颜色编码，
  //	sws_scale(swsctx, frame->data, frame->linesize, 0, frame->height, data, linesize);
  //	return buffer;
  //}
  // 写一个转换颜色编码的函数
  void GetRGBPixels(AVFrame *frame, std::vector<Color_RGB> &buffer) {
  	// 这里一定要用static，即初始化一次，
      static SwsContext *swsctx = nullptr;
  	swsctx = sws_getCachedContext(swsctx,
  		frame->width, frame->height, static_cast<AVPixelFormat>(frame->format),
  		frame->width, frame->height, AVPixelFormat::AV_PIX_FMT_BGR24, NULL, NULL, NULL, NULL
  	);  // 这里原来的类型转换是用的 (AVPixelFormat)frame->format
  	// 每次循环调用这个函数，都会重新分配这个vector，debug下就很慢
  	//std::vector<Color_RGB> buffer(frame->width * frame->height);
  
  	//uint8_t* data[] = {(uint8_t*)&buffer[0]};
  	uint8_t* data[] = { reinterpret_cast<uint8_t*>(&buffer[0]) };  // c++类型的指针风格转换
  	int linesize[] = { frame->width * 3 };
  	// sws_scale 函数可以对画面进行缩放，同时还能改变颜色编码，frame（yuv420p） 转 frame_bgr
  	sws_scale(swsctx, frame->data, frame->linesize, 0, frame->height, data, linesize);
  	// return buffer;  // 不返回了，直接用buffer
  }
  
  
  int main() {
      // ffmpeg3.4这种3的版本一定要这两行，4的大版本一定不要
      av_register_all();
  	avformat_network_init();
      
  	const char* file_path = "rtsp://192.168.108.11:554/user=admin&password=&channel=1&stream=1.sdp?";
  	DecoderParam decoderParam;
  	InitDecoder(file_path, decoderParam);  // 如果file_path.c_str()是，std::string，就写成file_path.c_str()
  	int width = decoderParam.width;
  	int height = decoderParam.height;
  	auto &fmtCtx = decoderParam.fmtCtx;   // 不知道它这都习惯定义变量时用 & 引用
  	auto &vcodecCtx = decoderParam.vcodecCtx;
  
  	cv::Mat img(cv::Size(width, height), CV_8UC3);
  	std::vector<Color_RGB> buffer(width * height);
      AVFrame *frame = av_frame_alloc();  // 先申请内存
      AVPacket *packet = av_packet_alloc();
  	while (1) {
  		// AVFrame *frame = RequestFrame(decoderParam);
          RequestFrame(decoderParam, frame, packet);
  		// 原来的格式是AV_PIX_FMT_YUVJ420P，被丢弃，会有一个警告：deprecated pixel format used, make sure you did set range correctly  (主要是针对rtsp，本地视频好像不用)
  		frame->format = ConvertDeprecatedFormat(static_cast<AVPixelFormat>(frame->format));
  
  		// std::vector<Color_RGB> pixels = GetRGBPixels(frame, buffer); 
          GetRGBPixels(frame, buffer);  // 解码调用
          // 下面这把流的数据转成opencv的图像的数据
          // uint8_t* data[] = { reinterpret_cast<uint8_t*>(&pixels[0]) };
  		//uint8_t *data =  reinterpret_cast<uint8_t*>(&pixels[0]);  // 上面那行也是一个意思，一般写作unsigned char* data，OpenGL都是这样的
  		//img.data = data;
          img.data = reinterpret_cast<uint8_t*>(&buffer[0]);
          
  		/*  不用下面这种循环写法，直接上面指针传递，在图片很大时就会很慢 */
          //int time = 0;
  		//for (int i = 0; i < img.rows; ++i) {
  		//	for (int j = 0; j < img.cols; ++j) {
  		//		img.at<cv::Vec3b>(i, j) = { pixels[time].r, pixels[time].g, pixels[time].b };
  		//		time++;
  		//	}
  		//}
  		cv::imshow("1", img);
  		if ((cv::waitKey(1) & 0xff) != 255) break;
  	}
      // av_frame_unref(frame);  // 这似乎不是释放
  	av_frame_free(&frame);  // 来释放内存
      av_packet_free(&packet);  // 释放内存
      avcodec_free_context(&decoderParam.vcodecCtx);  // 释放avcodec_alloc_context3() 这个函数
      
      // 在别的教程里看到了还要释放 SwsContext * 这个参数
      sws_freeContext(swsctx);
      
  	cv::destroyAllWindows();
  	return 0;
  }
  ```

#### 第二种：第一种的Mat格式，opengl加载，imgui做展示

- ffmpeg读取流视频，转成opencv的Mat格式，再用opengl加载，用imgui显示，一张图是50ms左右，imgui的fps差不多在20。
  以上为什么要把ffmpeg读取的数据转成Mat格式呢，是因为研究了半天，不会直接把ffmpeg读取的数据转成opengl想要的，所以有这么一个中间过渡。
     然后下面只放了关键代码，imgui用的glfw+opengl这个demo的代码，

  - my_ffmpeg.hpp

    ```c++
    extern "C" {
    #include <libavcodec/avcodec.h>
    #pragma comment(lib, "avcodec.lib")
    
    #include <libavformat/avformat.h>
    #pragma comment(lib, "avformat.lib")
    
    #include <libavutil/imgutils.h>
    #pragma comment(lib, "avutil.lib")
    
    	// 彩色画面要的
    #include <libswscale/swscale.h>
    #pragma comment(lib, "swscale.lib")
    }
    
    
    struct Color_RGB {
    	uint8_t r;
    	uint8_t g;
    	uint8_t b;
    };
    
    
    /*
    	yuvj×××这个格式被丢弃了，然后转化为yuv格式，
    	不然有一个警告 deprecated pixel format used, make sure you did set range correctly，
    	这个问题在前面和win32写api时可用，但是不知道其它地方会不会报错，就改过了
    */
    AVPixelFormat ConvertDeprecatedFormat(enum AVPixelFormat format)
    {
    	switch (format) {
    	case AV_PIX_FMT_YUVJ420P:
    		return AV_PIX_FMT_YUV420P;
    		break;
    	case AV_PIX_FMT_YUVJ422P:
    		return AV_PIX_FMT_YUV422P;
    		break;
    	case AV_PIX_FMT_YUVJ444P:
    		return AV_PIX_FMT_YUV444P;
    		break;
    	case AV_PIX_FMT_YUVJ440P:
    		return AV_PIX_FMT_YUV440P;
    		break;
    	default:
    		return format;
    		break;
    	}
    }
    
    
    // 把获取第一帧那个函数拆分了一下
    struct DecoderParam {
    	AVFormatContext *fmtCtx;
    	AVCodecContext *vcodecCtx;
    	int width;
    	int height;
    	int VideoStreamIndex;
    };
    
    void InitDecoder(const char* filepath, DecoderParam &param) {
    	AVFormatContext *fmtCtx = nullptr;
        // ret：0表示成功，-2代表文件不存在，
    	int ret = avformat_open_input(&fmtCtx, filepath, NULL, NULL);
    	avformat_find_stream_info(fmtCtx, NULL);
    
    	AVCodecContext *vcodecCtx = nullptr;
    	for (int i = 0; i < fmtCtx->nb_streams; i++) {
    		const AVCodec *codec = avcodec_find_decoder(fmtCtx->streams[i]->codecpar->codec_id);
    		if (codec->type == AVMEDIA_TYPE_VIDEO) {
    			param.VideoStreamIndex = i;
    			vcodecCtx = avcodec_alloc_context3(codec);
    			avcodec_parameters_to_context(vcodecCtx, fmtCtx->streams[i]->codecpar);
    			avcodec_open2(vcodecCtx, codec, NULL);
                 break;  // 我加的，应该找到后就可以break了，有问题再删掉。
    		}
    	}
    	param.fmtCtx = fmtCtx;
    	param.vcodecCtx = vcodecCtx;
    	param.width = vcodecCtx->width;
    	param.height = vcodecCtx->height;
    }
    
    // 下面函数 AVPacket *packet = av_packet_alloc(); AVFrame *frame = av_frame_alloc();没有释放，会内存泄露，这里不改了，去看上面“第一种”，那里做了修改，搜索“解决读取内存泄露”
    AVFrame* RequestFrame(DecoderParam &param) {
    	auto &fmtCtx = param.fmtCtx;
    	auto &vcodecCtx = param.vcodecCtx;
    	auto &VideoStreamIndex = param.VideoStreamIndex;
    
    	while (1) {
    		AVPacket *packet = av_packet_alloc();
    		int ret = av_read_frame(fmtCtx, packet);
    		if (ret == 0 && packet->stream_index == param.VideoStreamIndex) {
    			ret = avcodec_send_packet(vcodecCtx, packet);
    			if (ret == 0) {
    				AVFrame *frame = av_frame_alloc();
    				ret = avcodec_receive_frame(vcodecCtx, frame);
    				if (ret == 0) {
    					av_packet_unref(packet);
    					return frame;
    				}
    				else if (ret == AVERROR(EAGAIN)) {
    					av_frame_unref(frame);
    				}
    			}
    		}
    
    		av_packet_unref(packet);
    	}
    	return nullptr;
    }
    ```

- main.cpp（这里也就有把AVFrame转cv::Mat函数）

  ```c++
  #include "imgui.h"
  #include "imgui_impl_glfw.h"
  #include "imgui_impl_opengl3.h"
  #include <stdio.h>
  #include <iostream>
  #include <vector>
  #if defined(IMGUI_IMPL_OPENGL_ES2)
  #include <GLES2/gl2.h>
  #endif
  #include <GLFW/glfw3.h> // Will drag system OpenGL headers
  
  #include <opencv2/opencv.hpp>
  
  #include "my_ffmpeg.hpp"
  
  
  #if defined(_MSC_VER) && (_MSC_VER >= 1900) && !defined(IMGUI_DISABLE_WIN32_FUNCTIONS)
  #pragma comment(lib, "legacy_stdio_definitions")
  #endif
  
  
  static void glfw_error_callback(int error, const char* description) {
  	fprintf(stderr, "Glfw Error %d: %s\n", error, description);
  }
  
  
  /*
  	用ffmpeg读数视频流，然后将其处理一下，转成opencv的mat，然后在使用opengl渲染，在imgui里展示出来
  */
  void ffmpeg_opengl(AVFrame *frame, std::vector<Color_RGB> &buffer, cv::Mat &img, GLuint &video_texture) {
  	static SwsContext *swsctx = nullptr;
  	swsctx = sws_getCachedContext(swsctx,
  		frame->width, frame->height, static_cast<AVPixelFormat>(frame->format),
  		frame->width, frame->height, AVPixelFormat::AV_PIX_FMT_BGR24, NULL, NULL, NULL, NULL
  	); /*AVPixelFormat::AV_PIX_FMT_RGB24*/
  	uint8_t* data[] = { reinterpret_cast<uint8_t*>(&buffer[0]) };
  	int linesize[] = { frame->width * 3 };
  	sws_scale(swsctx, frame->data, frame->linesize, 0, frame->height, data, linesize);
  	
      // 不要用下面这种循环了，图像大了，会很慢，在这里搜索img.data = data
  	int time = 0;
  	for (int i = 0; i < img.rows; ++i) {
  		for (int j = 0; j < img.cols; ++j) {
  			img.at<cv::Vec3b>(i, j) = { buffer[time].b, buffer[time].g, buffer[time].r };
  			time++;
  		}
  	}
  
  	////generate texture using GL commands
  	glBindTexture(GL_TEXTURE_2D, video_texture);
  	// Setup filtering parameters for display
  	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, frame->width, frame->height, 0, GL_RGB, GL_UNSIGNED_BYTE, img.data);
  }
  
  
  int main(int argc, char** argv) {
  	// Setup window
  	glfwSetErrorCallback(glfw_error_callback);
  	if (!glfwInit())
  		return 1;
  
  	// Decide GL+GLSL versions
  #if defined(IMGUI_IMPL_OPENGL_ES2)
  	// GL ES 2.0 + GLSL 100
  	const char* glsl_version = "#version 100";
  	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
  	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
  	glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API);
  #elif defined(__APPLE__)
  	// GL 3.2 + GLSL 150
  	const char* glsl_version = "#version 150";
  	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
  	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);  // 3.2+ only
  	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);            // Required on Mac
  #else
  	// GL 3.0 + GLSL 130
  	const char* glsl_version = "#version 130";
  	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
  	//glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);  // 3.2+ only
  	//glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);            // 3.0+ only
  #endif
  
  	// Create window with graphics context
  	GLFWwindow* window = glfwCreateWindow(1280, 720, "Dear ImGui GLFW+OpenGL3 example", NULL, NULL);
  	if (window == NULL)
  		return 1;
  	glfwMakeContextCurrent(window);
  	glfwSwapInterval(1); // Enable vsync
  
  	// Setup Dear ImGui context
  	IMGUI_CHECKVERSION();
  	ImGui::CreateContext();
  	ImGuiIO& io = ImGui::GetIO(); (void)io;
  	//io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls
  	//io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls
  
  	// Setup Dear ImGui style
  	//ImGui::StyleColorsDark();
  	//ImGui::StyleColorsLight();
  	ImGui::StyleColorsClassic();
  
  	// Setup Platform/Renderer backends
  	ImGui_ImplGlfw_InitForOpenGL(window, true);
  	ImGui_ImplOpenGL3_Init(glsl_version);
  
  	// Load Fonts  // 加载其它字体，其demo它文件里也有
  	// 注意执行路径时，和这相对路径对不对应，可以添加几种字体，进到style中可以修改
  	io.Fonts->AddFontFromFileTTF("JetBrainsMono-Bold.ttf", 16.0f);  
  	// 字体要支持汉字才行
  	io.Fonts->AddFontFromFileTTF("c:/windows/fonts/simhei.ttf", 13.0f, NULL, io.Fonts->GetGlyphRangesChineseSimplifiedCommon());  
  
  	// Our state
  	bool show_demo_window = false;
  	bool show_videoCapture_window = true;  // my
  	
  	ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
  
  	const char* videoStreamAddress = "rtsp://192.168.108.11:554/user=admin&password=&channel=1&stream=1.sdp?";
  	//const char* videoStreamAddress = "C:\\Users\\Administrator\\Videos\\keypoint_result.mp4";
  
  	// ffmpeg视频读取的初始化
  	DecoderParam decoderParam;
  	InitDecoder(videoStreamAddress, decoderParam);
  	int width = decoderParam.width;
  	int height = decoderParam.height;
  	auto &fmtCtx = decoderParam.fmtCtx;   // 不知道它这都习惯定义变量时用 & 引用
  	auto &vcodecCtx = decoderParam.vcodecCtx;
  
  	// 存放数据，循环外初始化（static也是一样效果）
  	static std::vector<Color_RGB> buffer(width * height);  
  	static cv::Mat img(cv::Size(width, height), CV_8UC3);   // uint8_t *data
  	
  
  	// Main loop
  	while (!glfwWindowShouldClose(window)) {
  		// 我把它的一些注释删了，，去它的demo里看就好
  		glfwPollEvents();
  
  		// Start the Dear ImGui frame
  		ImGui_ImplOpenGL3_NewFrame();
  		ImGui_ImplGlfw_NewFrame();
  		ImGui::NewFrame();
  
  		// 1. Show the big demo window (Most of the sample code is in ImGui::ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
  		if (show_demo_window)
  			ImGui::ShowDemoWindow(&show_demo_window);
  
  		// 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
  		{
  			static float f = 0.0f;
  			static int counter = 0;
  
  			ImGui::Begin("Hello, world!");                          // Create a window called "Hello, world!" and append into it.
  
  			ImGui::Text("This is some useful text.");               // Display some text (you can use a format strings too)
  			ImGui::Checkbox("Demo Window", &show_demo_window);      // Edit bools storing our window open/close state
  			
  			// my function of videoCapture
  			ImGui::Checkbox("VideoCapture Window", &show_videoCapture_window);
  
  			ImGui::SliderFloat("float", &f, 0.0f, 1.0f);            // Edit 1 float using a slider from 0.0f to 1.0f
  			ImGui::ColorEdit3("clear color", (float*)&clear_color); // Edit 3 floats representing a color
  
  			if (ImGui::Button("Button"))                            // Buttons return true when clicked (most widgets return true when edited/activated)
  				counter++;
  			ImGui::SameLine();
  			ImGui::Text("counter = %d", counter);
  
  			ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
  			ImGui::End();
  		}
  
  		// my video and detect
  		{
  			if (show_videoCapture_window) {
  				static bool if_detect = false;
  				static bool show_style_editor = false;
  				static GLuint video_texture = 0;
  
  				if (show_style_editor) {
  					ImGui::Begin("Dear ImGui Style Editor", &show_style_editor);
  					ImGui::ShowStyleEditor();
  					ImGui::End();
  				}
  				ImGui::Begin(u8"OpenGL Texture video，汉字可以嘛");  // 主要前面要有u8才能支持汉字
  				ImGui::Text("size = %d x %d", width, height);
  
  				AVFrame *frame = RequestFrame(decoderParam);
  				// 原来的格式是AV_PIX_FMT_YUVJ420P，被丢弃，会有一个警告：deprecated pixel format used, make sure you did set range correctly
  				frame->format = ConvertDeprecatedFormat(static_cast<AVPixelFormat>(frame->format));
  
  				// 转换的核心
  				ffmpeg_opengl(frame, buffer,img, video_texture);
  		
  				ImGui::Image((void*)(intptr_t)video_texture, ImVec2(frame->width, frame->height));
  
  				ImGui::Checkbox("Detect", &if_detect);
  				ImGui::SameLine();  // 这个可以把两个button放在一行里
  				ImGui::Checkbox("Style Editor", &show_style_editor);
  				ImGui::End();
  
  				av_frame_free(&frame);
  			}
  		}
  
  		// Rendering
  		ImGui::Render();
  		int display_w, display_h;
  		glfwGetFramebufferSize(window, &display_w, &display_h);
  		glViewport(0, 0, display_w, display_h);
  		glClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w);
  		glClear(GL_COLOR_BUFFER_BIT);
  		ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
  
  		glfwSwapBuffers(window);
  	}
  
  	// Cleanup
  	ImGui_ImplOpenGL3_Shutdown();
  	ImGui_ImplGlfw_Shutdown();
  	ImGui::DestroyContext();
  
  	glfwDestroyWindow(window);
  	glfwTerminate();
  
  	return 0;
  }
  
  /*
  	现在用的debug模式，opencv的lib库也是带d的，就很慢很多，
  	如果要release，要去把opencv库对应改成不带d的才能运行
  */
  
  
  /*
  	不用opencv，可以直接加载图片，现在仅会图片
  
  // 这是为了显示图像,这是加加载图片要用，如果用opencv，就可以不要这个了
  #define STB_IMAGE_IMPLEMENTATION   // 下面这个头文件要用的
  #include "stb_image.h"     // 这个头文件是到处通用的，用opengl来加载图像
  // 直接OPENGL加载图片 （或许可以考虑opencv来处理吧）
  bool LoadTextureFromFile(const char* filename, GLuint* out_texture, int* out_width, int* out_height)
  {
  	// Load from file
  	int image_width = 0;
  	int image_height = 0;
  	unsigned char* image_data = stbi_load(filename, &image_width, &image_height, NULL, 4);
  	if (image_data == NULL)
  		return false;
  
  	// Create a OpenGL texture identifier  //generate texture using GL commands
  	GLuint image_texture;
  	glGenTextures(1, &image_texture);
  	glBindTexture(GL_TEXTURE_2D, image_texture);
  
  	// Setup filtering parameters for display
  	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  
  	// Upload pixels into texture
  #if defined(GL_UNPACK_ROW_LENGTH) && !defined(__EMSCRIPTEN__)
  	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
  #endif
  	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image_width, image_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image_data);
  	stbi_image_free(image_data);
  
  	*out_texture = image_texture;
  	*out_width = image_width;
  	*out_height = image_height;
  
  	return true;
  }
  
  	// 加载图像(tag:123)
  	int my_image_width = 0;
  	int my_image_height = 0;
  	GLuint my_image_texture = 0;
  	bool ret = LoadTextureFromFile("C:\\Users\\Administrator\\Pictures\\dog.jpg", &my_image_texture, &my_image_width, &my_image_height);
  	IM_ASSERT(ret);
  
  			//// 加载图像(tag:123)
  		//ImGui::Begin("OpenGL Texture Text");
  		//ImGui::Text("pointer = %p", my_image_texture);
  		//ImGui::Text("size = %d x %d", my_image_width, my_image_height);
  		//printf("地址：？%p", my_image_texture);
  		//ImGui::Image((void*)(intptr_t)my_image_texture, ImVec2(my_image_width, my_image_height));
  		//ImGui::End();
  */
  ```

---

然后把直接opencv读取的流数据（上面是ffmpeg读取的数据流），转成opengl需要的格式,用imgui展示的主要代码也写一下吧：

```c++
//视频的处理，cv的mat转成opengl要得格式
void Mat2Texture(cv::Mat &image, GLuint &imagetexture) {
	if (image.empty()) return;

	//generate texture using gl commands
	glBindTexture(GL_TEXTURE_2D, imagetexture);

	// setup filtering parameters for display
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image.cols, image.rows, 0, GL_RGB, GL_UNSIGNED_BYTE, image.data);
}


int main() {
	cv::VideoCapture cap(0);
	cv::mat frame;
	
	GLuint video_texture = 0;
	while (1) {
		cap >> frame;
		cv::cvtColor(frame, frame, cv::COLOR_BGR2RGB);
		Mat2Texture(frame, video_texture);
		ImGui::Image((void*)(intptr_t)video_texture, ImVec2(frame.cols, frame.rows));
	}
}
```

总结：1最流畅、（2、3似乎差不多）

1. 以上用ffmpeg读取rtsp摄像头(换成opengl格式在imgui里展示，或使用opencv来展示)、画面是最流畅的；
2. 用opencv读取rtsp摄像头(换成opengl的格式在imgui里展示)，画面也算流畅，看起来有一些延迟；
3. 但是用opencv直接读取rtsp摄像头，opencv直接来展示画面，无论python、c++的方式，画面都是有相当明显明显的延迟。（c++中release和python画面看起来差不多，c++中的Debug下会更卡顿）

（注：ffmpeg读取、opencv读取，两种方式在imgui中显示，imgui中都显示大概都是50ms，fps在20）（以上为什么要把ffmpeg读取的数据转成Mat格式呢，是因为搞了半天，不会直接把ffmpeg读取的数据转成opengl想要的，
所以有这么一个中间过渡）

#### 第三种：使用cuda硬解码

这是家里的电脑，使用cuda，然后是根据官方的这个硬件的[demo](http://ffmpeg.org/doxygen/trunk/hwcontext_8c.html#afb2b99a15f3fdde25a2fd19353ac5a67)改的，先说版本：

- vs2017，cuda10.2;
- ffmpeg是网上下的人家编译好的，大版本是4，好像是4,4;然后里面有几个API是版本3里面没有的。
- 然后改了一些代码，把它保存结果写文件的代码内容注释掉了，里面有两个函数的api还是值得参考的。
- 以下代码只能在vs上运行成功，没试过linux的4.4版本；但试过linux的3.4版本，运行有错误，不知道是不是版本的问题。
- 运行：./main cuda 123.mp4

注意：以下的方式，跟这个博客的教程的做法有一些不同(把官方代码，按照博客那样去改了，运行始终有问题，第一帧画面可以出来，但是后面就不行了，如果暂时用不到就不去深究了，就先按照官方改的这个来把，也==注意当有av_frame_alloc()、av_packet_alloc()申请内存时，一定要去释放，会内存泄露的==，下面代码没改了，可以参见“第一种”的代码去改这两次的内存泄漏，搜索“解决读取内存泄露”)：

```c++
#include <stdio.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/pixdesc.h>
#include <libavutil/hwcontext.h>
#include <libavutil/opt.h>
#include <libavutil/avassert.h>
#include <libavutil/imgutils.h>

#include <libavutil/hwcontext.h>
#include <libswscale/swscale.h>
}

#include <vector>
#include <opencv2/opencv.hpp>

#pragma comment(lib, "avcodec.lib")
#pragma comment(lib, "avformat.lib")
#pragma comment(lib, "avutil.lib")
#pragma comment(lib, "swscale.lib")


struct Color_RGB {
	uint8_t r;
	uint8_t g;
	uint8_t b;
};


static AVBufferRef *hw_device_ctx = NULL;
static enum AVPixelFormat hw_pix_fmt;
//static FILE *output_file = NULL;

static int hw_decoder_init(AVCodecContext *ctx, const enum AVHWDeviceType type)
{
	int err = 0;

	if ((err = av_hwdevice_ctx_create(&hw_device_ctx, type,
		NULL, NULL, 0)) < 0) {
		fprintf(stderr, "Failed to create specified HW device.\n");
		return err;
	}
	ctx->hw_device_ctx = av_buffer_ref(hw_device_ctx);

	return err;
}

static enum AVPixelFormat get_hw_format(AVCodecContext *ctx,
	const enum AVPixelFormat *pix_fmts)
{
	const enum AVPixelFormat *p;

	for (p = pix_fmts; *p != -1; p++) {
		if (*p == hw_pix_fmt)
			return *p;
	}

	fprintf(stderr, "Failed to get HW surface format.\n");
	return AV_PIX_FMT_NONE;
}

static int decode_write(AVCodecContext *avctx, AVPacket *packet, std::vector<Color_RGB> &my_buffer)
{
	AVFrame *frame = NULL, *sw_frame = NULL;
	AVFrame *tmp_frame = NULL;
	uint8_t *buffer = NULL;
	int size;
	int ret = 0;

	ret = avcodec_send_packet(avctx, packet);
	if (ret < 0) {
		fprintf(stderr, "Error during decoding\n");
		return ret;
	}

	while (1) {
		if (!(frame = av_frame_alloc()) || !(sw_frame = av_frame_alloc())) {
			fprintf(stderr, "Can not alloc frame\n");
			ret = AVERROR(ENOMEM);
			goto fail;
		}

		ret = avcodec_receive_frame(avctx, frame);
		if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
			av_frame_free(&frame);
			av_frame_free(&sw_frame);
			return 0;
		}
		else if (ret < 0) {
			fprintf(stderr, "Error while decoding\n");
			goto fail;
		}

		if (frame->format == hw_pix_fmt) {
			/* retrieve data from GPU to CPU */
			if ((ret = av_hwframe_transfer_data(sw_frame, frame, 0)) < 0) {
				fprintf(stderr, "Error transferring the data to system memory\n");
				goto fail;
			}
			tmp_frame = sw_frame;

			// 这是我加的，方便opencv 这展示
			static SwsContext *swsctx = nullptr;
			swsctx = sws_getCachedContext(swsctx,
				tmp_frame->width, tmp_frame->height, static_cast<AVPixelFormat>(tmp_frame->format),
				tmp_frame->width, tmp_frame->height, AVPixelFormat::AV_PIX_FMT_BGR24, NULL, NULL, NULL, NULL
			);


			uint8_t* data[] = { reinterpret_cast<uint8_t*>(&my_buffer[0]) };
            // 可等价写成，.begin()得到的类型是iter，只是类似指针，所以要*解引用，得到第一个，在&取地址
            // uint8_t* data[] = { reinterpret_cast<uint8_t*>(&*my_buffer.begin()) };
			int linesize[] = { tmp_frame->width * 3 };
			sws_scale(swsctx, tmp_frame->data, tmp_frame->linesize, 0, tmp_frame->height, data, linesize);
			
            // tmp_frame->format对应的pixel的值是 enum AVPixelFormat::AV_PIX_FMT_NV12 ,那篇教程里提到过的，以后可以参考吧，教程里就是用的sws_scale来处理的
            // 到这，上

		}
		else
			tmp_frame = frame;

		// 这是写到文件的代码，暂时不要，写出来的视频也打不开
		//size = av_image_get_buffer_size(static_cast<AVPixelFormat>(tmp_frame->format), tmp_frame->width,
		//	tmp_frame->height, 1);
		 // 下面这行原来的代码是buffer=av_malloc(size)，在c++中不能隐式的类型转换，参考：https://m.656463.com/wenda/Cmalloccwcvoidwxzhwuint8_t_371
		//buffer = static_cast<uint8_t *>(av_malloc(size));
		//if (!buffer) {
		//	fprintf(stderr, "Can not alloc buffer\n");
		//	ret = AVERROR(ENOMEM);
		//	goto fail;
		//}
		//ret = av_image_copy_to_buffer(buffer, size,
		//	(const uint8_t * const *)tmp_frame->data,
		//	(const int *)tmp_frame->linesize, static_cast<AVPixelFormat>(tmp_frame->format),
		//	tmp_frame->width, tmp_frame->height, 1);
		//if (ret < 0) {
		//	fprintf(stderr, "Can not copy image to buffer\n");
		//	goto fail;
		//}

		//if ((ret = fwrite(buffer, 1, size, output_file)) < 0) {
		//	fprintf(stderr, "Failed to dump raw data.\n");
		//	goto fail;
		//}


	fail:
		av_frame_free(&frame);
		av_frame_free(&sw_frame);
		av_freep(&buffer);
		if (ret < 0)
			return ret;
	}
}

int main(int argc, char *argv[])
{

	// cuda "C:\\Users\\Administrator\\Videos\\keypoint_result.mp4"  
	// cuda "rtsp://192.168.108.11:554/user=admin&password=&channel=1&stream=1.sdp?" 

	AVFormatContext *input_ctx = NULL;
	int video_stream, ret;
	AVStream *video = NULL;
	AVCodecContext *decoder_ctx = NULL;
	const AVCodec *decoder = NULL;
	AVPacket *packet = NULL;
	enum AVHWDeviceType type;
	int i;

	if (argc < 3) {
		fprintf(stderr, "Usage: %s <device type> <input file>\n", argv[0]);
		return -1;
	}

	type = av_hwdevice_find_type_by_name(argv[1]);
	if (type == AV_HWDEVICE_TYPE_NONE) {
		fprintf(stderr, "Device type %s is not supported.\n", argv[1]);
		fprintf(stderr, "Available device types:");
		while ((type = av_hwdevice_iterate_types(type)) != AV_HWDEVICE_TYPE_NONE)
			fprintf(stderr, " %s", av_hwdevice_get_type_name(type));
		fprintf(stderr, "\n");
		return -1;
	}

	packet = av_packet_alloc();
	if (!packet) {
		fprintf(stderr, "Failed to allocate AVPacket\n");
		return -1;
	}

	/* open the input file */
	if (avformat_open_input(&input_ctx, argv[2], NULL, NULL) != 0) {
		fprintf(stderr, "Cannot open input file '%s'\n", argv[2]);
		return -1;
	}

	if (avformat_find_stream_info(input_ctx, NULL) < 0) {
		fprintf(stderr, "Cannot find input stream information.\n");
		return -1;
	}

	/* find the video stream information */
	ret = av_find_best_stream(input_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, &decoder, 0);
	if (ret < 0) {
		fprintf(stderr, "Cannot find a video stream in the input file\n");
		return -1;
	}
	video_stream = ret;

	for (i = 0;; i++) {
		const AVCodecHWConfig *config = avcodec_get_hw_config(decoder, i);
		if (!config) {
			fprintf(stderr, "Decoder %s does not support device type %s.\n",
				decoder->name, av_hwdevice_get_type_name(type));
			return -1;
		}
		if (config->methods & AV_CODEC_HW_CONFIG_METHOD_HW_DEVICE_CTX &&
			config->device_type == type) {
			// reelase下，这行报错的话，尝试把hw_pix_fmt定义前面的static去掉
			hw_pix_fmt = config->pix_fmt;   // 117 enum AVPixelFormat::AV_PIX_FMT_CUDA
			break;
		}
	}

	if (!(decoder_ctx = avcodec_alloc_context3(decoder)))
		return AVERROR(ENOMEM);

	video = input_ctx->streams[video_stream];
	if (avcodec_parameters_to_context(decoder_ctx, video->codecpar) < 0)
		return -1;

	decoder_ctx->get_format = get_hw_format;

	if (hw_decoder_init(decoder_ctx, type) < 0)
		return -1;

	if ((ret = avcodec_open2(decoder_ctx, decoder, NULL)) < 0) {
		fprintf(stderr, "Failed to open codec for stream #%u\n", video_stream);
		return -1;
	}

	/* open the file to dump raw data */
	//output_file = fopen(argv[3], "w+b");


	std::vector<Color_RGB> my_buffer(decoder_ctx->width * decoder_ctx->height);
	cv::Mat img(cv::Size(decoder_ctx->width, decoder_ctx->height), CV_8UC3);


	/* actual decoding and dump the raw data */
	while (ret >= 0) {
		if ((ret = av_read_frame(input_ctx, packet)) < 0)
			break;

		if (video_stream == packet->stream_index) {
			ret = decode_write(decoder_ctx, packet, my_buffer);
			// 不要用下面这种循环了，图像大了，会很慢，在这里搜索img.data = data
             int time = 0;
			for (int i = 0; i < img.rows; ++i) {
				for (int j = 0; j < img.cols; ++j) {
					img.at<cv::Vec3b>(i, j) = { my_buffer[time].r, my_buffer[time].g, my_buffer[time].b };
					time++;
				}
			}
			cv::imshow("1", img);
			if ((cv::waitKey(1) & 0xff) != 255) break;
		}


		av_packet_unref(packet);
	}

	/* flush the decoder */
	ret = decode_write(decoder_ctx, NULL, my_buffer);

	//if (output_file)
	//	fclose(output_file);

	av_packet_free(&packet);
	avcodec_free_context(&decoder_ctx);
	avformat_close_input(&input_ctx);
	av_buffer_unref(&hw_device_ctx);

	cv::destroyAllWindows();

	return 0;
}
```

#### 第四种：ffmpeg(opencv)读流+opengl贴图+glfw做展示

肯定要准备ffmpeg、opencv、opengl、glfw、glad这些的环境，这里不赘述了。

​	过程中发现了一个问题：用ffmpeg读取，opengl+glfw做展示，因为av_frame_alloc()、av_packet_alloc()出现了内存泄露的问题，这个算是解决了，但随着时间的推移，内存使用还是在缓慢增加，发现是vs的ServiceHub.DataWarehouseHost.exe这个程序在持续慢慢泄露内存，要使用的话，要解决这个问题，或者说linux上看会不会出现这个问题。

1. 首先是opengl的shader，以及处理shader的类：

   - 顶点着色器：shader.vs

     ```glsl
     // 调整顶点着色器使其能够接受顶点坐标为一个顶点属性，并把坐标传给片段着色器
     #version 330 core
     layout(location = 0) in vec3 aPos;
     layout(location = 1) in vec3 aColor;
     layout(location = 2) in vec2 aTexCoord;  // 这个0、1、2和代码中设置顶点属性是对应的
     
     out vec3 ourColor;
     out vec2 TexCoord;
     
     void main() {
     	gl_Position = vec4(aPos, 1.0);
     	ourColor = aColor;
     	TexCoord = aTexCoord;
     }
     ```

   - 片段着色器：shader.fs

     ```c++
     #version 330 core     // opengl版本决定的
     out vec4 FragColor;
     
     in vec3 ourColor;
     in vec2 TexCoord;
     
     // GLSL有一个供纹理对象使用的内建数据类型，叫做采样器(Sampler)，它以纹理类型作为后缀，比如sampler1D、sampler3D
     uniform sampler2D ourTexture;  // 记得一定要声明为uniform
     
     void main() {
     	// GLSL内建的texture函数来采样纹理的颜色，它第一个参数是纹理采样器，第二个参数是对应的纹理坐标
          FragColor = texture(ourTexture, TexCoord) * vec4(ourColor, 1.0f);
         // FragColor = texture(ourTexture, TexCoord);
     }
     ```

   - shader的类：shader_s.h

     ```c++
     #pragma once
     #ifndef SHADER_H
     #define SHADER_H
     
     #include <glad/glad.h>
     #include <string>
     #include <fstream>
     #include <sstream>
     #include <iostream>
     
     class Shader {
     public:
     	unsigned int ID;
     	// constructor generates the shader on the fly
     	Shader(const char* vertexPath, const char* fragmentPath) {
     		// 1. retrieve the vertex/fragment source code from filePath
     		std::string vertexCode;
     		std::string fragmentCode;
     		std::ifstream vShaderFile;
     		std::ifstream fShaderFile;
     		// ensure ifstream objects can throw exceptions:
     		vShaderFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);
     		fShaderFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);
     		try {
     			// open files
     			vShaderFile.open(vertexPath);
     			fShaderFile.open(fragmentPath);
     			std::stringstream vShaderStream, fShaderStream;
     			// read file's buffer contents into streams
     			vShaderStream << vShaderFile.rdbuf();
     			fShaderStream << fShaderFile.rdbuf();
     			// close file handlers
     			vShaderFile.close();
     			fShaderFile.close();
     			// convert stream into string
     			vertexCode = vShaderStream.str();
     			fragmentCode = fShaderStream.str();
     		}
     		catch (std::ifstream::failure& e) {
     			std::cout << "ERROR::SHADER::FILE_NOT_SUCCESSFULLY_READ: " << e.what() << std::endl;
     		}
     		const char* vShaderCode = vertexCode.c_str();
     		const char * fShaderCode = fragmentCode.c_str();
     		// 2. compile shaders
     		unsigned int vertex, fragment;
     		// vertex shader
     		vertex = glCreateShader(GL_VERTEX_SHADER);
     		glShaderSource(vertex, 1, &vShaderCode, NULL);
     		glCompileShader(vertex);
     		checkCompileErrors(vertex, "VERTEX");
     		// fragment Shader
     		fragment = glCreateShader(GL_FRAGMENT_SHADER);
     		glShaderSource(fragment, 1, &fShaderCode, NULL);
     		glCompileShader(fragment);
     		checkCompileErrors(fragment, "FRAGMENT");
     		// shader Program
     		ID = glCreateProgram();
     		glAttachShader(ID, vertex);
     		glAttachShader(ID, fragment);
     		glLinkProgram(ID);
     		checkCompileErrors(ID, "PROGRAM");
     		// delete the shaders as they're linked into our program now and no longer necessary
     		glDeleteShader(vertex);
     		glDeleteShader(fragment);
     	}
     	// activate the shader
     	void use() {
     		glUseProgram(ID);
     	}
     	// utility uniform functions
     	void setBool(const std::string &name, bool value) const {
     		glUniform1i(glGetUniformLocation(ID, name.c_str()), (int)value);
     	}
     	void setInt(const std::string &name, int value) const {
     		glUniform1i(glGetUniformLocation(ID, name.c_str()), value);
     	}
     	void setFloat(const std::string &name, float value) const {
     		glUniform1f(glGetUniformLocation(ID, name.c_str()), value);
     	}
     
     private:
     	// utility function for checking shader compilation/linking errors.
     	void checkCompileErrors(unsigned int shader, std::string type) {
     		int success;
     		char infoLog[1024];
     		if (type != "PROGRAM") {
     			glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
     			if (!success) {
     				glGetShaderInfoLog(shader, 1024, NULL, infoLog);
     				std::cout << "ERROR::SHADER_COMPILATION_ERROR of type: " << type << "\n" << infoLog << "\n -- --------------------------------------------------- -- " << std::endl;
     			}
     		}
     		else {
     			glGetProgramiv(shader, GL_LINK_STATUS, &success);
     			if (!success) {
     				glGetProgramInfoLog(shader, 1024, NULL, infoLog);
     				std::cout << "ERROR::PROGRAM_LINKING_ERROR of type: " << type << "\n" << infoLog << "\n -- --------------------------------------------------- -- " << std::endl;
     			}
     		}
     	}
     };
     
     #endif
     ```

2. 使用opencv、ffmpeg读流，然后opengl做贴图，glfw展示：

   注：把下面“#define ffmpeg”  这行注释掉就会使用opencv读取视频流，默认是用ffmpeg

   ```c++
   #include <iostream>
   #include <glad/glad.h>  // 特别注意：在包含GLFW的头文件之前包含了GLAD的头文件。GLAD的头文件包含了正确的OpenGL头文件（例如GL/gl.h），所以需要在其它依赖于OpenGL的头文件之前包含GLAD。
   #include <GLFW/glfw3.h>
   #include <opencv2/opencv.hpp>
   
   #include "shader_s.h"
   
   extern "C" {
   #include <libavcodec/avcodec.h>
   #pragma comment(lib, "avcodec.lib")
   
   #include <libavformat/avformat.h>
   #pragma comment(lib, "avformat.lib")
   
   #include <libavutil/imgutils.h>
   #pragma comment(lib, "avutil.lib")
   
   	// 彩色画面要的
   #include <libswscale/swscale.h>
   #pragma comment(lib, "swscale.lib")
   }
   
   /*  下面是ffmpeg的读取  */
   /*
   	yuvj×××这个格式被丢弃了，然后转化为yuv格式，
   	不然有一个警告 deprecated pixel format used, make sure you did set range correctly，
   	这个问题在前面和win32写api时可用，但是不知道其它地方会不会报错，就改过了
   */
   AVPixelFormat ConvertDeprecatedFormat(enum AVPixelFormat format) {
   	switch (format) {
   	case AV_PIX_FMT_YUVJ420P:
   		return AV_PIX_FMT_YUV420P;
   		break;
   	case AV_PIX_FMT_YUVJ422P:
   		return AV_PIX_FMT_YUV422P;
   		break;
   	case AV_PIX_FMT_YUVJ444P:
   		return AV_PIX_FMT_YUV444P;
   		break;
   	case AV_PIX_FMT_YUVJ440P:
   		return AV_PIX_FMT_YUV440P;
   		break;
   	default:
   		return format;
   		break;
   	}
   }
   struct Color_RGB {
   	uint8_t r;
   	uint8_t g;
   	uint8_t b;
   };
   // 把获取第一帧那个函数拆分了一下
   struct DecoderParam {
   	AVFormatContext *fmtCtx;
   	AVCodecContext *vcodecCtx;
   	int width;
   	int height;
   	int VideoStreamIndex;
   };
   void InitDecoder(const char* filepath, DecoderParam &param) {
   	AVFormatContext *fmtCtx = nullptr;
   
   	// linux上这里一直报错，返回的是 -1330794744，网上搜索一圈了，ffmpeg也重新编译了，还是不行
   	int ret = avformat_open_input(&fmtCtx, filepath, NULL, NULL);
   
   	avformat_find_stream_info(fmtCtx, NULL);
   
   	AVCodecContext *vcodecCtx = nullptr;
   	for (int i = 0; i < fmtCtx->nb_streams; i++) {
   		const AVCodec *codec = avcodec_find_decoder(fmtCtx->streams[i]->codecpar->codec_id);
   		if (codec->type == AVMEDIA_TYPE_VIDEO) {
   			param.VideoStreamIndex = i;
   			vcodecCtx = avcodec_alloc_context3(codec);
   			avcodec_parameters_to_context(vcodecCtx, fmtCtx->streams[i]->codecpar);
   			avcodec_open2(vcodecCtx, codec, NULL);
                break;  // 我加的，应该找到后就可以break了，有问题再删掉。
   		}
   	}
   	param.fmtCtx = fmtCtx;
   	param.vcodecCtx = vcodecCtx;
   	param.width = vcodecCtx->width;
   	param.height = vcodecCtx->height;
   }
   int RequestFrame(DecoderParam &param, AVFrame *frame, AVPacket *packet) {
   	auto &fmtCtx = param.fmtCtx;
   	auto &vcodecCtx = param.vcodecCtx;
   	auto &VideoStreamIndex = param.VideoStreamIndex;
   
   	while (1) {
   		// AVPacket *packet = av_packet_alloc();
   		int ret = av_read_frame(fmtCtx, packet);
   		if (ret == 0 && packet->stream_index == param.VideoStreamIndex) {
   			ret = avcodec_send_packet(vcodecCtx, packet);
   			if (ret == 0) {
   				ret = avcodec_receive_frame(vcodecCtx, frame);
   				if (ret == 0) {
   					av_packet_unref(packet);
   					return 0;  // 代表读取成功
   				}
   				else if (ret == AVERROR(EAGAIN)) {
   					av_frame_unref(frame);
   				}
   			}
   		}
   		av_packet_unref(packet);
   	}
   	return -1;
   }
   // 写一个转换颜色编码的函数
   void GetRGBPixels(AVFrame *frame, std::vector<Color_RGB> &buffer) {
   	static SwsContext *swsctx = nullptr;
   	swsctx = sws_getCachedContext(swsctx,
   		frame->width, frame->height, static_cast<AVPixelFormat>(frame->format),
   		frame->width, frame->height, AVPixelFormat::AV_PIX_FMT_BGR24, NULL, NULL, NULL, NULL
   	);  // 这里原来的类型转换是用的 (AVPixelFormat)frame->format
   
   	// 每次循环调用这个函数，都会重新分配这个vector，debug下就很慢
   	//std::vector<Color_RGB> buffer(frame->width * frame->height);
   
   	//uint8_t* data[] = {(uint8_t*)&buffer[0]};
   	uint8_t* data[] = { reinterpret_cast<uint8_t*>(&buffer[0]) }; 
   	int linesize[] = { frame->width * 3 };
   	// sws_scale 函数可以对画面进行缩放，同时还能改变颜色编码，
   	sws_scale(swsctx, frame->data, frame->linesize, 0, frame->height, data, linesize);
   	// return buffer;  // 不返回了，直接用buffer
   }
   
   
   void framebuffer_size_callback(GLFWwindow* window, int width, int height);
   void processInput(GLFWwindow* window);
   
   // settings
   #define ffmpeg   // 这行注释掉就用opencv读取视频流
   unsigned int SCR_WIDTH = 800;
   unsigned int SCR_HEIGHT = 600;
   const char* rtsp_path = "rtsp://192.168.108.146:554/user=admin&password=&channel=1&stream=0.sdp?";
   
   int main() {
   
   #ifdef ffmpeg
   	DecoderParam decoderParam;
   	InitDecoder(rtsp_path, decoderParam);  // 如果file_path.c_str()是，std::string，就写成file_path.c_str()
   	SCR_WIDTH = decoderParam.width;
   	SCR_HEIGHT = decoderParam.height;
   	auto &fmtCtx = decoderParam.fmtCtx;   // 这是引用，取一个别名
   	auto &vcodecCtx = decoderParam.vcodecCtx;
   
   	cv::Mat img(cv::Size(SCR_WIDTH, SCR_HEIGHT), CV_8UC3);
   	std::vector<Color_RGB> buffer(SCR_WIDTH * SCR_HEIGHT);
   	AVFrame *frame = av_frame_alloc();  // 提前分配
       AVPacket *packet = av_packet_alloc();
   
   #else
   	cv::VideoCapture cap;
   	cap.open(rtsp_path);
   	cv::Mat img;
   	if (cap.read(img)) {
   		SCR_WIDTH = img.cols;
   		SCR_HEIGHT = img.rows;
   	}
   
   #endif // ffmpeg
   
   	// 1、实例化GLFW窗口
   	glfwInit();
   	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);  // 说明opengl版本，方便glfw做调整
   	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
   	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);  //告诉GLFW我们使用的是核心模式(Core-profile)；明确告诉GLFW我们需要使用核心模式意味着我们只能使用OpenGL功能的一个子集（没有我们已不再需要的向后兼容特性）
   #ifdef __APPLE__
   	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);  // 针对苹果，上一行core-profile才生效
   #endif
   
   	// 2、创建一个窗口对象
   	GLFWwindow* window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", NULL, NULL);
   	if (window == NULL) {
   		std::cout << "Failed to create GLFW window" << std::endl;
   		glfwTerminate();
   		return -1;
   	}
   	// 通知GLFW将我们窗口的上下文设置为当前线程的主上下文了
   	glfwMakeContextCurrent(window);
   
   	glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
   
   	// 3、初始化glad，GLAD是用来管理OpenGL的函数指针的，所以在调用任何OpenGL的函数之前我们需要初始化GLAD
   	if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
   		std::cout << "Failed to initialize GLAD" << std::endl;
   		return -1;
   	}  // 给GLAD传入了用来加载系统相关的OpenGL函数指针地址的函数
   
   	// 创建编译shader pragram
   	Shader ourShader("E:\\VS_project\\Study\\OpenGL_demo\\shader.vs", "E:\\VS_project\\Study\\OpenGL_demo\\shader.fs");
   
   	//float vertices[] = {   // 3个顶点属性  // 带一些颜色
   	//	// ---- 位置 ----       ---- 颜色 ----     - 纹理坐标 -
   	//	0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
   	//	0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下
   	//	-0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下
   	//	-0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f    // 左上
   	//};
   
   	//float vertices[] = {   // 3个顶点属性    //纯白，就是原图案
   	//	// ---- 位置 ----       ---- 颜色 ----     - 纹理坐标 -
   	//	0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 1.0f,   1.0f, 1.0f,   // 右上
   	//	0.5f, -0.5f, 0.0f,   1.0f, 1.0f, 1.0f,   1.0f, 0.0f,   // 右下
   	//	-0.5f, -0.5f, 0.0f,   1.0f, 1.0f, 1.0f,   0.0f, 0.0f,   // 左下
   	//	-0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 1.0f,   0.0f, 1.0f    // 左上
   	//  0.5相当于就占了窗口的一半
   	//};
   
   	float vertices[] = {   // 3个顶点属性   // 改了位置坐标，让它把图形填满
   		// ---- 位置 ----       ---- 颜色(纯白)--  -- 纹理坐标 -
   		1.0f,  1.0f, 0.0f,   1.0f, 1.0f, 1.0f,   1.0f, 1.0f,   // 右上
   		1.0f, -1.0f, 0.0f,   1.0f, 1.0f, 1.0f,   1.0f, 0.0f,   // 右下
   		-1.0f, -1.0f, 0.0f,   1.0f, 1.0f, 1.0f,   0.0f, 0.0f,   // 左下
   		-1.0f,  1.0f, 0.0f,   1.0f, 1.0f, 1.0f,   0.0f, 1.0f    // 左上
   	};
   
   
   	unsigned int indices[] = {
   		0, 1, 3,   // first triangle
   		1, 2, 3    // second triangle
   	};
   
   
   	unsigned int VBO, VAO, EBO;
   	glGenVertexArrays(1, &VAO);
   	glGenBuffers(1, &VBO);
   	glGenBuffers(1, &EBO);
   
   	glBindVertexArray(VAO);
   
   	glBindBuffer(GL_ARRAY_BUFFER, VBO);
   	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
   
   	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
   	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
   
   	// position attribute
   	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)0);
   	glEnableVertexAttribArray(0);
   	// texture coord attribute
   	glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(3 * sizeof(float)));
   	glEnableVertexAttribArray(1);
   	//// texture coord attribute
   	glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(6 * sizeof(float)));
   	glEnableVertexAttribArray(2);
   
   
   	// 1、load and create a texture
   	unsigned int texture;
   	glGenTextures(1, &texture);
   	glBindTexture(GL_TEXTURE_2D, texture);
   	// 2、为当前绑定的纹理对象设置环绕、过滤方式
   	// set the texture wrapping parameters
   	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
   	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
   	// set texture filtering parameters
   	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
   	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
   
   	//// 3、加载图片并生成纹理
   	//int width, height, nrChannels;
   	//cv::Mat img = cv::imread(R"(C:\Users\Administrator\Downloads\container.jpg)");
   	//cv::cvtColor(img, img, cv::COLOR_BGR2RGB);
   	//unsigned char* data = img.data;
   	//if (data) {
   	//	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, img.cols, img.rows, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
   	//	glGenerateMipmap(GL_TEXTURE_2D);
   	//}
   	//else {
   	//	std::cout << "Failed to load texture!" << std::endl;
   	//}
   
   	// 哪怕就一张纹理，也记得设置（下一小节，纹理单位有详说）
   	ourShader.use();  // 在设置uniform变量之一定激活着色器程序
   	glUniform1i(glGetUniformLocation(ourShader.ID, "texture1"), 0);
   
   	// while 中绘制就是 glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
   	// 但是在这之前要记得激活绑定(下一小节有讲)
   	glActiveTexture(GL_TEXTURE0); // 在绑定纹理之前先激活纹理单元
   	glBindTexture(GL_TEXTURE_2D, texture);
   
   
   	// render loop
   	while (!glfwWindowShouldClose(window)) {
   		// input
   		processInput(window);
   
   		// render
   		glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
   		glClear(GL_COLOR_BUFFER_BIT);
   
   #ifdef ffmpeg
   		RequestFrame(decoderParam, frame, packet);
   		// 原来的格式是AV_PIX_FMT_YUVJ420P，被丢弃，会有一个警告：deprecated pixel format used, make sure you did set range correctly  (主要是针对rtsp，本地视频好像不用)
   		frame->format = ConvertDeprecatedFormat(static_cast<AVPixelFormat>(frame->format));
   		GetRGBPixels(frame, buffer);  // 解码调用
   		//uint8_t* data[] = { reinterpret_cast<uint8_t*>(&pixels[0]) };
   		// uint8_t *data = reinterpret_cast<uint8_t*>(&buffer[0]);  // 上面那行也是一个意思，一般写作unsigned char* data，OpenGL都是这样的
   		img.data = reinterpret_cast<uint8_t*>(&buffer[0]);
   #else
   		cap >> img;
   		
   #endif // ffmpeg
   		cv::cvtColor(img, img, cv::COLOR_BGR2RGB);
   		cv::flip(img, img, 0);  // opengl学习时也说了，它默认是上下颠倒的，所以这里要翻转一下
   		// 必须要转成RGB才行，前面给GL_BGR,虽然有，但是显示是有问题的
   		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, img.cols, img.rows, 0, GL_RGB, GL_UNSIGNED_BYTE, img.data);
   		glGenerateMipmap(GL_TEXTURE_2D);
   
   		// render the triangle
   		ourShader.use();
   		glBindVertexArray(VAO);
   		glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
   
   		// glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
   		glfwSwapBuffers(window);
   		glfwPollEvents();
   	}
   
   	// optional: de-allocate all resources once they've outlived their purpose:
   	glDeleteVertexArrays(1, &VAO);
   	glDeleteBuffers(1, &VBO);
   
   #ifdef ffmpeg
   	// av_frame_unref(frame);  // 这似乎不是释放
   	av_frame_free(&frame);  // 来释放内存
       av_packet_free(&packet);
   	avcodec_free_context(&decoderParam.vcodecCtx);  // alloc的都要去free
   #else
   	cap.release();
   #endif // !ffmpeg
   
   	// glfw: terminate, clearing all previously allocated GLFW resources.
   	glfwTerminate();
   	return 0;
   }
   
   void framebuffer_size_callback(GLFWwindow* window, int width, int height) {
   	// 4、glViewport函数前两个参数控制窗口左下角的位置。第三个和第四个参数控制渲染窗口的宽度和高度（像素）（有更深含义的技术，看这些代码的链接解释）
   	glViewport(0, 0, width, height);
   }
   void processInput(GLFWwindow* window) {
   	// 按esc关闭窗口
   	if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
   		glfwSetWindowShouldClose(window, true);
   }
   ```

#### linux用ffmpeg加载有警告，chatgpt回答的解决

在linux上，ffmpeg代码视频流读取时，总会出现以下的提示：

> [rtsp @ 0x260d500] max delay reached. need to consume packet 
> [rtsp @ 0x260d500] RTP: missed 24 packets

问了chatgpt，解决办法：

这是原来回答：

​	该提示表示FFmpeg在解码rtsp视频流时存在某些问题，其中最大延迟已达到，需要消耗数据包以进行下一步操作。同时，由于丢失了24个数据包，因此还显示了RTP：missed 24 packets的警告。

以下是一些可能的解决方案：

1. 增加缓冲区大小

在FFmpeg命令行中，您可以增加rtsp协议的缓冲区大小：

```bash
ffmpeg -rtsp_flags initial_pause -max_delay 5000000 -i rtsp://192.168.1.1:554/stream_1 -vcodec copy -f rawvideo -y /dev/null
```

其中，`-max_delay`的值可以适当增加，以增加缓冲区大小。如果缓冲区过小，会导致最大延迟达到，从而导致数据包丢失。

1. 调整FFmpeg缓冲区大小

您可以尝试通过调整FFmpeg缓冲区大小来解决此问题。您可以使用以下命令行：

```bash
ffmpeg -buffersize 1024k -i rtsp://192.168.1.1:554/stream_1 -vcodec copy -f rawvideo -y /dev/null
```

这将使FFmpeg在处理RTSP流时使用1MB的缓冲区，以便防止数据包丢失。

1. 降低视频分辨率和帧率

如果您的RTSP视频流分辨率和帧率过高，在FFmpeg解码时可能会遇到问题。您可以尝试降低分辨率和/或帧率来解决此问题。

```bash
ffmpeg -i rtsp://192.168.1.1:554/stream_1 -filter:v scale=1280:-1 -r 30 -vcodec copy -f rawvideo -y /dev/null
```

该命令将视频分辨率降低为1280x720（如果原始分辨率更高）并将帧率降低为30帧/秒。

1. 更改rtsp_flags

您可以尝试更改rtsp_flags以绕过此问题。

```bash
ffmpeg -rtsp_flags listen -i rtsp://192.168.1.1:554/stream_1 -vcodec copy -f rawvideo -y /dev/null
```

使用`-rtsp_flags listen`会在启动时暂停FFmpeg的流程，直到播放器可以接收RTSP数据包。

1. 使用播放器的缓存

您可以尝试使用播放器的缓存，例如VLC或MPlayer，以防止出现数据包丢失的问题。这将使播放器自动解决RTSP数据包的缓冲问题，从而避免数据包丢失。

这些解决方案中的任何一种都可以帮助您解决FFmpeg解码RTSP视频流时遇到的“max delay reached”和“RTP：missed xx packets”问题。

---

下面是FFmpeg增加缓冲区的示例代码。（这也是chatgpt回答的，==试过了基本没啥变化。==）

​	在这个示例中，我们使用`avformat_open_input`函数打开一个RTSP视频流，并使用`avformat_find_stream_info`函数获取视频流信息。在获取视频流信息之后，我们对`AVStream`对象进行迭代，并设置它们的缓冲区大小为2MB。

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libavformat/avformat.h>

int main(int argc, char *argv[]) {
    AVFormatContext *formatCtx = NULL;
    int videoStream = -1;
    AVStream *video = NULL;

    av_register_all();

    if (argc < 2) {
        printf("Usage: %s <input>\n", argv[0]);
        return EXIT_FAILURE;
    }

    if (avformat_open_input(&formatCtx, argv[1], NULL, NULL) != 0) {
        printf("Error: could not open input file '%s'\n", argv[1]);
        return EXIT_FAILURE;
    }

    if (avformat_find_stream_info(formatCtx, NULL) < 0) {
        printf("Error: could not find stream info\n");
        return EXIT_FAILURE;
    }

    for (int i = 0; i < formatCtx->nb_streams; i++) {
        if (formatCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoStream = i;
            video = formatCtx->streams[i];
            break;
        }
    }

    if (videoStream == -1) {
        printf("Error: could not find video stream\n");
        return EXIT_FAILURE;
    }

    // Set buffer size
    formatCtx->max_delay = (int64_t)(2 * AV_TIME_BASE);  // 2M
    formatCtx->flags |= AVFMT_FLAG_CUSTOM_IO;

    // Print video stream information
    av_dump_format(formatCtx, videoStream, argv[1], 0);

    avformat_close_input(&formatCtx);

    return EXIT_SUCCESS;
}
```

在`AVStream`对象上设置`max_delay`属性为2秒（2 * `AV_TIME_BASE`）将设置2MB的缓冲区大小。注意，为了使新的缓冲区设置生效，我们还需要设置`flags`属性为`AVFMT_FLAG_CUSTOM_IO`。

在示例代码中，我们还使用了`av_dump_format`函数来打印视频流信息。您可以在运行示例代码时，使用以下命令来编译并运行：

```bash
gcc -o increase_bufsize increase_bufsize.c -lavformat
./increase_bufsize rtsp://example.com/stream
```

这样，FFmpeg将使用2MB的缓冲区来打开RTSP视频流。