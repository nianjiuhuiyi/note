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
     -  如果123.mp4这个视频文件是h.264+aac的，也是可以直接 -c copy的，如果是h.265的需要重新编解码
     -  可以再加参数如 -c:a aac -r 30 -g 15
        -  -r 30限制帧率为30
        -  -g 15，结合上面 -r 30，那就是 1秒2个关键帧。
  3. `ffmpeg -i "rtsp地址" -c:v libx264 -c:a aac -f flv   rtmp://192.168.125.128/live/456`  # 源是rtsp就不要加-re了，会很卡

  说明：

  - 一定要-re,-re是限制ffmpeg的上传帧率，就按照视频本身的帧率来处理，否则ffmpeg会按照自身能力进行最大帧率的上传，就会导致流媒体服务器处理能力受限或者拉流端处理能力有限导致各类问题；

  - 第一种是要flv的格式，-vcodec copy -acodec copy 限于摄像机提供的就为H.264+AAC的码流；

  - 若不是flv(即第二种的mp4这些)，则将`-vcodec copy`改为`-vcodec libx264`，`-acodec copy`改为`-acodec aac`，这样就可以比如h.265的mp4视频了，而不仅仅是flv格式。  

  - rtsp流地址：要看这个rtsp摄像头的编码格式，（以受电弓rtsp摄像头为例（两种编码格式））
    
  - 是==H.265X==(这就是h.264)：
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

#### 2.3.1 rtsp推rtmp(转封装)

这里就是ffmpeg里面的格式转封装，没有涉及到重新编码，所以packet都只用了一个。

要推流成rtmp就是flv的格式。

​	c++用代码拉取rtsp的流然后推成rtmp的(win下4.几的版本是ok的，ffmpeg version N-107626-g1368b5a725-20220801)：这个[博客](https://www.cnblogs.com/gongluck/category/1215138.html)里还有很多ffmpeg采集声音、画面的相关代码。
​	以下代码肯定能运行，前提条件是rtsp的编码格式为h.264(或是受电弓的摄像头的H.265X格式，可用VMS软件进行修改)，因为以下代码的推流编码格式是直接copy源流的，推成rtmp的要libx264，所若是rtsp原流是h265的，这代码就会出错，提示HEVC的错误。

```c++
#include <iostream>
#include <thread>

extern "C" {
#include <libavformat/avformat.h>
#pragma comment(lib, "avformat.lib")

#include <libavcodec/avcodec.h>
#pragma comment(lib, "avcodec.lib")

#include <libavutil/avutil.h>
#pragma comment(lib, "avutil.lib")
}

#define my_av_gettime() \
	std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now().time_since_epoch()).count()

char av_error[AV_ERROR_MAX_STRING_SIZE] = { 0 };
#define av_err2str(errnum) \
    av_make_error_string(av_error, AV_ERROR_MAX_STRING_SIZE, errnum)

// 这个推视频也是ok的
const char* INFILE = "C:\\Users\\Administrator\\Videos\\source.200kbps.768x320.flv";
const char* RTMP = "rtmp://192.168.125.128/live/66";
const char* RTSP = "rtsp://192.168.108.134:554/user=admin&password=&channel=1&stream=1.sdp?";

//const char* in_filename = "C:\\Users\\Administrator\\Desktop\\05\\h264_aac.mp4";
const char* in_filename = "rtsp://192.168.108.135:554/user=admin&password=&channel=1&stream=1.sdp?";
const char* out_filename = "rtmp://192.168.108.218/live/11";

int rtsp2rtmp() {	
    // 输入输出各对应一个AVFormatContext，以后自己用还是写 avformat_alloc_context 函数去分配吧
	AVFormatContext *ifmt_ctx = nullptr;
	AVFormatContext *ofmt_ctx = nullptr;
    
    const AVOutputFormat *ofmt = nullptr;
	// 注意这里：AVPacket *pkt = nullptr; 到了下面av_read_frame函数一定会运行报错，
	// 要么下面这样去使用指针，要么用 AVPacket pkt; 这中实例化对象去写。
	AVPacket *pkt = av_packet_alloc();
    
    int ret = 0;
	int video_index = -1;
	int frame_index = 0;
	int64_t start_time = 0;
	// 这个参数是为了另一种写法
	int64_t Last_pts = AV_NOPTS_VALUE;

	ret = avformat_network_init();  // 初始化网络组件
	if (ret != 0) {
		std::cout << av_err2str(ret) << std::endl;
		goto END;
	}

	// 输入(写NULL、nullptr、0都是一个意思)
	if ((ret = avformat_open_input(&ifmt_ctx, in_filename, nullptr, 0)) < 0) {
		av_log(NULL, AV_LOG_ERROR, "Could not open input file.\n");
		goto end;
	}
	if ((ret = avformat_find_stream_info(ifmt_ctx, nullptr)) < 0) {
		av_log(nullptr, AV_LOG_ERROR, "Failed to retrive input stream information");
		goto end;
	}

	/* 旧版本一般这样去找视频流，新版本也是兼容的，但可能一些代码参数有区别，下面是新版等价的
	for (int i = 0; i < ifmt_ctx->nb_streams; ++i) {
		// 旧的版本里可能是 ->codec->codec_type
		if (ifmt_ctx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
			video_index = i;
			break;
		}
	}
	*/
    ret = av_find_best_stream(ifmt_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, nullptr, 0);
	if (ret < 0) {
		av_log(NULL, AV_LOG_ERROR, "av_find_best_stream error.");
		goto end;
	}
	video_index = ret;

	// 打印一下输入信息
	av_dump_format(ifmt_ctx, 0, in_filename, 0);

	// 开始输出（"flv"参数可以用这替代：av_guess_format(nullptr, "123.flv", nullptr)，重要的是后缀(所以给flv就行)，让ffmpeg去推断我们要得格式是哪种的，有需要还可以放 456.mp4 之类的。）
	avformat_alloc_output_context2(&ofmt_ctx, nullptr, "flv", out_filename);   // RTMP
	// avformat_alloc_output_context2(&ofmt_ctx, nullptr, "mpegts", out_filename);   // UDP
	if (!ofmt_ctx) {
		ret = AVERROR_UNKNOWN;
		av_log(NULL, AV_LOG_ERROR, "Could not create output context\n");
		goto end;
	}
	ofmt = ofmt_ctx->oformat;

	// 根据输入流创建输出流 (这就把所有codec参数都存进了 ofmt_ctx )
	for (int i = 0; i < ifmt_ctx->nb_streams; ++i) {
		AVStream *in_stream = ifmt_ctx->streams[i];
		AVStream *out_stream = avformat_new_stream(ofmt_ctx, nullptr);
		if (!out_stream) {
			av_log(NULL, AV_LOG_ERROR, "Failed allocating output stream\n");
			goto end;
		}
		// 复制 AVCodecContext 的设置(老版本的API可能是 avcodec_copy_context )
		ret = avcodec_parameters_copy(out_stream->codecpar, in_stream->codecpar);
		if (ret < 0) {
			av_log(NULL, AV_LOG_ERROR, "Failed to copy context from input to output stream codec");
			goto end;
		}
		// 标记不需要重新编解码 
		out_stream->codecpar->codec_tag = 0;
	}

	// 打印一下输出流的格式 (读里面参数就会懂，最后一个参数：是输出流就给1，不是就给0)
	av_dump_format(ofmt_ctx, 0, out_filename, 1);
    
    
   // 打开输出URL
	if (!(ofmt->flags & AVFMT_NOFILE)) {
		ret = avio_open(&ofmt_ctx->pb, out_filename, AVIO_FLAG_WRITE);
		if (ret < 0) {
			av_log(NULL, AV_LOG_ERROR, "Could not open output URL");
			goto end;
		}
	}
	// 写文件头
	ret = avformat_write_header(ofmt_ctx, nullptr);
	if (ret < 0) {
		av_log(NULL, AV_LOG_ERROR, "Error occurred when opening output URL\n");
		goto end;
	}
	
    // 下面仅做了输入、输出时间的处理代码，相当于只是做封装转换，未设计到编解码。
	// start_time = av_gettime() 返回从 Unix 纪元（1970 年 1 月 1 日 00:00:00 UTC）以来的时间（以微秒为单位）,已被弃用
	start_time = my_av_gettime();
	while (1) {
		AVStream *in_stream, *out_stream;
		// 获取一个AVPacket
		ret = av_read_frame(ifmt_ctx, pkt);
		if (ret < 0) break;

		//FIX：No PTS (Example: Raw H.264)
		//Simple Write PTS, 本来没有pts的话，就自己去写，这样后面代码使用就有了
		if (pkt->pts == AV_NOPTS_VALUE) {
			// write PTS  (注意：时间基 ->time_base 与帧率 ->r_frame_rate 应该是互为倒数)
			AVRational time_base1 = ifmt_ctx->streams[video_index]->time_base;
			// duration between 2 frames(us) 两帧之间的时间间隔，微妙
			// AV_TIME_BASE为宏1000000的定义，这么多微妙刚好为1s,以前常是用1000ms,来除以帧率，得到每两帧的时间间隔
			// r_frame_rate结果是 AVRational 对象，所以再用 av_q2d 函数来算出帧率
			int64_t calc_duration = (double)AV_TIME_BASE / av_q2d(ifmt_ctx->streams[video_index]->r_frame_rate);
			pkt->pts = (double)(frame_index * calc_duration) / (double)(av_q2d(time_base1) * AV_TIME_BASE);
			pkt->dts = pkt->pts;
			pkt->duration = (double)calc_duration / (double)(av_q2d(time_base1) * AV_TIME_BASE);
		}

		// 很重要的：Delay（根据帧率去算的，不然本地视频一下就很快完了）
		if (pkt->stream_index == video_index) {
			// 方式一：(还是就用这吧)
			AVRational time_base = ifmt_ctx->streams[video_index]->time_base;
			AVRational time_base_q = { 1, AV_TIME_BASE };  // AV_TIME_BASE_Q
			int64_t pts_time = av_rescale_q(pkt->dts, time_base, time_base_q);
			int64_t now_time = my_av_gettime() - start_time;
			if (pts_time > now_time) {
				std::this_thread::sleep_for(std::chrono::microseconds(pts_time - now_time));
			}

			// 方式二：（思路是来自上一小节的 视频filter，但好像是有点问题，那里是用的 frame->pts）
			// 我这用 pkt->pts 还是 pkt->dts 都能跑，但画面总感觉有些不对，放这里作为了解吧
			/*
			if (Last_pts != AV_NOPTS_VALUE) {
				AVRational time_base = ifmt_ctx->streams[video_index]->time_base;
				int64_t delay = av_rescale_q(pkt->pts - Last_pts, time_base, AVRational{ 1, AV_TIME_BASE });
				if (delay > 0 && delay < 1000000)    // 1000000 us 也就是1s
					std::this_thread::sleep_for(std::chrono::microseconds(delay));
			}
			Last_pts = pkt->pts;
			*/
		}

		in_stream = ifmt_ctx->streams[pkt->stream_index];
		out_stream = ofmt_ctx->streams[pkt->stream_index];
		/* copy packet：这里是没用重新编解码的 */
		// Convert PTS/DTS
		// av_rescale_q_rnd：是将时间戳从前者时间基转换到后者时间基，可看：https://zhuanlan.zhihu.com/p/468346396
		enum AVRounding rnd = static_cast<AVRounding>(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX);
		pkt->pts = av_rescale_q_rnd(pkt->pts, in_stream->time_base, out_stream->time_base, rnd);
		pkt->dts = av_rescale_q_rnd(pkt->dts, in_stream->time_base, out_stream->time_base, rnd);
		pkt->duration = av_rescale_q(pkt->duration, in_stream->time_base, out_stream->time_base);
		pkt->pos = -1;

		if (pkt->stream_index == video_index) {
			std::cout << "Send " << frame_index++ << "video frames to output URL\n";
		}

		// 音视频交织写入，如果只写视频，可能就是 av_write_frame(ofmt_ctx, pkt);
		ret = av_interleaved_write_frame(ofmt_ctx, pkt);
		if (ret < 0) {
			av_log(NULL, AV_LOG_ERROR, "Error muxing packet\n");
			break;
		}

		// 一帧用完后一定要 unref
		av_packet_unref(pkt);

	}

	// 写文件尾
	av_write_trailer(ofmt_ctx);
end:
	// 这里没用 avformat_alloc_context 去创建 ifmt_ctx，就可以不去释放，前面那种写法也并非是唯一
	if (!ifmt_ctx) {
		avformat_close_input(&ifmt_ctx);
	}

	if (!pkt) {
		av_packet_free(&pkt);
	}

	// 关闭输出
	if (ofmt_ctx && ofmt && !(ofmt->flags & AVFMT_NOFILE)) {
		avio_close(ofmt_ctx->pb);
		avformat_free_context(ofmt_ctx);
	}

	avformat_network_deinit();

	// 这种goto end的写法，这里是必要的，中途遇错来到这里，就好提示并退出
	if (ret < 0 && ret != AVERROR_EOF) {
		std::cerr << "Error occurred: " << av_err2str(ret) << std::endl;
		ret = -1;
	}
    
    return ret;
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

  这是因为==有rtsp的编码格式是h.265(要注意用VMS去查看)==，要用成 -c:v libx264 -c:a aac 这种(哪怕rtsp没声音，也要这这样指定aac的)，具体就可以看下面这个2.3.2。

#### 2.3.2 rtsp推rtsp/rtmp(重编码)

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

### 2.5. 按Q停止推流

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
