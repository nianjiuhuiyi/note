这里放一些简单的示例，不少是自己系统学习FFmpeg前写的，不一定完全对，要注意甄别。

### 一、FFmpeg读取流来展示

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

### 1.1. 第一种：ffmpeg读流，转Mat格式，opencv做展示

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

### 1.2. 第二种：Mat格式，opengl加载，imgui做展示

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

### 1.3. 第三种：cuda硬解码

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

### 1.4. 第四种：ffmpeg(opencv)读流+opengl贴图+glfw展示

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

### 1.5. linux用ffmpeg加载有警告，chatgpt回答的解决

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

## 二、只用FFmpeg+Win32实现播放器

这是教程的[博客地址](https://www.cnblogs.com/judgeou/p/14724951.html)。写的非常好，一步步循序渐进，一共有三个，这下面的算是第一个教程跟着写的代码，也还没整完，因为没有GPU硬件加速，走不下去了。  从[这里](https://www.freeaihub.com/post/109842.html)来的。

- 把本地视频地址换成rtsp也是可以直接使用的

- 要去看博客，这个要把链接器->系统->子系统 设置为“窗口” ,不然会说无法解析main; 同理，其它是普通main函数作为入口的，一定要把这个选项设置为“控制台”，不然就是无法解析WinMain。

- 在linux上，关于ffmpeg使用cuda硬件解码、软解码，转到opencv的Mat(需要opencv编译时支持cuda)，还要有英伟达的==h264_cuvid==，放个[代码](https://github.com/chinahbcq/ffmpeg_hw_decode)参考吧(有更进一步实际需求时再去深入吧)。硬解码，也参考[官方文档](http://ffmpeg.org/doxygen/trunk/hw_decode_8c-example.html)(==函数API，定义解释这些也可以在这里面搜索==)和[这](https://www.cnblogs.com/gongluck/p/10827950.html)。

- 打印错误：（把返回的错误数字代表的信息打印出来）

  ```c++
  // 一般头文件里都有包含这个 av_make_error_string
  char av_error[AV_ERROR_MAX_STRING_SIZE] = { 0 };
  #define av_err2str(errnum) av_make_error_string(av_error, AV_ERROR_MAX_STRING_SIZE, errnum)
  
  int ret = {/*  */};
  std::cout << av_err2str(ret) << std::endl;
  ```

- [FFmpeg解封装、解码音频和视频（分别使用OpenGL和OpenAL播放）](https://blog.csdn.net/GrayOnDream/article/details/122158294)（参考吧）

---

准备工作：

- 看下面120行的RegisterClass(&wndClass);  # 要在属性设置中的“配置属性-->常规-->字符集(改成Unicode)”;
- 属性设置中，在属性-->链接器-->系统-->子系统(改为窗口，不能是控制台)  # 最好的方法出现了，子系统的值改成==未设置==，这样，两种都可以直接使用。
  - 设置为“窗口” ,不然会说`无法解析的外部符号main`；      # 注意拿到别人的代码是WinMain作为入口的，直接运行报这个错，怎么去改;
  - 其它是普通main函数作为入口的，一定要把这个选项设置为“控制台”，不然就是无法解析WinMain。

### 2.1. 第一阶段：只是把第一帧的画面，黑白显示出来

```c++
#include <stdio.h>
#include <Windows.h>
#include <string>
#include <vector>

extern "C" {
#include <libavcodec/avcodec.h>
#pragma comment(lib, "avcodec.lib")

#include <libavformat/avformat.h>
#pragma comment(lib, "avformat.lib")

#include <libavutil/imgutils.h>
#pragma comment(lib, "avutil.lib")
}

struct Color_RGB {
	uint8_t r;
	uint8_t g;
	uint8_t b;
};


// 获取第一帧画面
AVFrame* getFirstFrame(const char* filepath) {
	AVFormatContext *fmtCtx = nullptr;
	avformat_open_input(&fmtCtx, filepath, NULL, NULL);
	avformat_find_stream_info(fmtCtx, NULL);

	int VideoStreamIndex;
	AVCodecContext *vcodecCtx = nullptr;
	for (int i = 0; i < fmtCtx->nb_streams; i++) {
		AVStream *stream = fmtCtx->streams[i];
		if (stream->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            // 这是软解码
			const AVCodec *codec = avcodec_find_decoder(stream->codecpar->codec_id);
			VideoStreamIndex = i;
			vcodecCtx = avcodec_alloc_context3(codec);
			avcodec_parameters_to_context(vcodecCtx, fmtCtx->streams[i]->codecpar);
			avcodec_open2(vcodecCtx, codec, NULL);
		}
	}

	while (1) {
		AVPacket *packet = av_packet_alloc();
		int ret = av_read_frame(fmtCtx, packet);
		if (ret == 0 && packet->stream_index == VideoStreamIndex) {
			ret = avcodec_send_packet(vcodecCtx, packet);
			if (ret == 0) {
				AVFrame *frame = av_frame_alloc();
				ret = avcodec_receive_frame(vcodecCtx, frame);
				if (ret == 0) {
					av_packet_unref(packet);
					avcodec_free_context(&vcodecCtx);
					avformat_close_input(&fmtCtx);
					return frame;
				}
				else if (ret == AVERROR(EAGAIN)) {
					av_frame_unref(frame);
					continue;
				}
			}
		}
		av_packet_unref(packet);
	}
}


/*
 YUV420P格式会把Y、U、V三个值分开存储到三个数组，AVFrame::data[0] 就是Y通道数组，我们简单的把亮度值同时放进RGB就可以实现黑白画面了。接下来写一个函数对处理出来的RGB数组进行渲染，我们这里先使用最传统的GDI绘图方式，，但是这种方式太慢了
*/
//void StretchBits(HWND hwnd, const std::vector<Color_RGB> &bits, int width, int height) {
//	auto hdc = GetDC(hwnd);
//	for (int x = 0; x < width; x++) {
//		for (int y = 0; y < height; y++) {
//			auto &pixel = bits[x + y * width];
//			SetPixel(hdc, x, y, RGB(pixel.r, pixel.g, pixel.b));  // 主要是SetPixel这个函数效率太低
//		}
//	}
//	ReleaseDC(hwnd, hdc);
//}

void StretchBits(HWND hwnd, const std::vector<Color_RGB> &bits, int width, int height) {
	auto hdc = GetDC(hwnd);
	BITMAPINFO bitinfo = {};
	auto &bmiHeader = bitinfo.bmiHeader;
	bmiHeader.biSize = sizeof(bitinfo.bmiHeader);
	bmiHeader.biWidth = width;
	bmiHeader.biHeight = -height;  // 注意负号，否则会画面颠倒
	bmiHeader.biPlanes = 1;
	bmiHeader.biBitCount = 24;
	bmiHeader.biCompression = BI_RGB;

	// StretchDIBits 函数就快了很多
	StretchDIBits(hdc, 0, 0, width, height, 0, 0, width, height, &bits[0], &bitinfo, DIB_RGB_COLORS, SRCCOPY);
	ReleaseDC(hwnd, hdc);

}


// 主函数入口
int WINAPI WinMain(
	_In_ HINSTANCE hInstance,
	_In_opt_ HINSTANCE hPrevInstance,
	_In_ LPSTR lpCmdLine,
	_In_ int nShowCmd
) {
	SetProcessDPIAware();

	auto className = L"MyWindow";
	WNDCLASSW wndClass = {};
	wndClass.hInstance = NULL;
	wndClass.lpszClassName = className;
	wndClass.lpfnWndProc = [](HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) -> LRESULT {
		return DefWindowProc(hwnd, msg, wParam, lParam);
	};


	// 下面这个宏函数的定义(可点进去)，要看是否启用了Unicode编译，不然类型不行，这个网址一个介绍：https://blog.csdn.net/huashuolin001/article/details/95620424
	RegisterClass(&wndClass);
	auto window = CreateWindow(className, L"Hello World 标题", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 800, 600, NULL, NULL, NULL, NULL);

	ShowWindow(window, SW_SHOW);


	// 
	std::string file_path = "C:\\Users\\Administrator\\Videos\\keypoint_result.mp4";
	AVFrame *firstframe = getFirstFrame(file_path.c_str());
	int width = firstframe->width;
	int height = firstframe->height;
	std::vector<Color_RGB> pixels(width * height);
	for (int i = 0; i < pixels.size(); i++) {
		uint8_t r = firstframe->data[0][i];
		uint8_t g = r;
		uint8_t b = r;
		pixels[i] = { r, g, b };

	}
	
	StretchBits(window, pixels, width, height);


	MSG msg;
	while (GetMessage(&msg, window, 0, 0) > 0) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	return 0;
}
```

---

### 2.2. 第二阶段：改成不移动鼠标也能自动播放

- 这里面还有一个节点，就是会自动播放，但是需要鼠标放在上面

```c++
#include <stdio.h>
#include <Windows.h>
#include <string>
#include <vector>

extern "C" {
#include <libavcodec/avcodec.h>
#pragma comment(lib, "avcodec.lib")

#include <libavformat/avformat.h>
#pragma comment(lib, "avformat.lib")

#include <libavutil/imgutils.h>
#pragma comment(lib, "avutil.lib")
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
	avformat_open_input(&fmtCtx, filepath, NULL, NULL);
	avformat_find_stream_info(fmtCtx, NULL);

	AVCodecContext *vcodecCtx = nullptr;
	for (int i = 0; i < fmtCtx->nb_streams; i++) {
		const AVCodec *codec = avcodec_find_decoder(fmtCtx->streams[i]->codecpar->codec_id);
		if (codec->type == AVMEDIA_TYPE_VIDEO) {
			param.VideoStreamIndex = i;
			vcodecCtx = avcodec_alloc_context3(codec);
			avcodec_parameters_to_context(vcodecCtx, fmtCtx->streams[i]->codecpar);
			avcodec_open2(vcodecCtx, codec, NULL);
		}
	}
	param.fmtCtx = fmtCtx;
	param.vcodecCtx = vcodecCtx;
	param.width = vcodecCtx->width;
	param.height = vcodecCtx->height;
}

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

void StretchBits(HWND hwnd, const std::vector<Color_RGB> &bits, int width, int height) {
	auto hdc = GetDC(hwnd);
	BITMAPINFO bitinfo = {};
	auto &bmiHeader = bitinfo.bmiHeader;
	bmiHeader.biSize = sizeof(bitinfo.bmiHeader);
	bmiHeader.biWidth = width;
	bmiHeader.biHeight = -height;  // 注意负号，否则会画面颠倒
	bmiHeader.biPlanes = 1;
	bmiHeader.biBitCount = 24;
	bmiHeader.biCompression = BI_RGB;

	// StretchDIBits 函数就快了很多
	StretchDIBits(hdc, 0, 0, width, height, 0, 0, width, height, &bits[0], &bitinfo, DIB_RGB_COLORS, SRCCOPY);
	ReleaseDC(hwnd, hdc);

}

// 主函数入口
int WINAPI WinMain(
	_In_ HINSTANCE hInstance,
	_In_opt_ HINSTANCE hPrevInstance,
	_In_ LPSTR lpCmdLine,
	_In_ int nShowCmd
) {

	SetProcessDPIAware();

	auto className = L"MyWindow";
	WNDCLASSW wndClass = {};
	wndClass.hInstance = NULL;
	wndClass.lpszClassName = className;
	// // 这一个为了自动播放较前面的做了修改
	wndClass.lpfnWndProc = [](HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) -> LRESULT {
		switch (msg) {
		case WM_DESTROY:
			PostQuitMessage(0);
			return 0;
		default:
			return DefWindowProc(hwnd, msg, wParam, lParam);
		}
	};

	std::string file_path = "C:\\Users\\Administrator\\Videos\\keypoint_result.mp4";

	DecoderParam decoderParam;
	InitDecoder(file_path.c_str(), decoderParam);
	int width = decoderParam.width;
	int height = decoderParam.height;
	auto &fmtCtx = decoderParam.fmtCtx;   // 不知道它这都习惯定义变量时用 & 引用
	auto &vcodecCtx = decoderParam.vcodecCtx;


	// 下面这个宏函数的定义(可点进去)，要看是否启用了Unicode编译，不然类型不行，这个网址一个介绍：https://blog.csdn.net/huashuolin001/article/details/95620424
	RegisterClass(&wndClass);
	auto window = CreateWindow(className, L"Hello World 标题", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, width, height, NULL, NULL, NULL, NULL);

	ShowWindow(window, SW_SHOW);


	MSG msg;
	//// GetMessage是收到消息才会执行，就要鼠标就要一直动，不然就会卡在那里，就要改，成下面的
	//while (GetMessage(&msg, window, 0, 0) > 0) {
	//	AVFrame *frame = RequestFrame(decoderParam);
	//	std::vector<Color_RGB> pixels(width * height);
	//	for (int i = 0; i < pixels.size(); i++) {
	//		uint8_t r = frame->data[0][i];
	//		uint8_t g = r;
	//		uint8_t b = r;
	//		pixels[i] = { r, g, b };
	//	}
	//	av_frame_free(&frame);
	//	StretchBits(window, pixels, width, height);
	//	TranslateMessage(&msg);
	//	DispatchMessage(&msg);
	//}

	while (1) {
		BOOL hasMsg = PeekMessage(&msg, NULL, 0, 0, PM_REMOVE);
		if (hasMsg) {
			if (msg.message == WM_QUIT) break;
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		else {
			AVFrame *frame = RequestFrame(decoderParam);
			std::vector<Color_RGB> pixels(width * height);
			for (int i = 0; i < pixels.size(); i++) {
				uint8_t r = frame->data[0][i];
				uint8_t g = r;
				uint8_t b = r;
				pixels[i] = { r, g, b };
			}

			av_frame_free(&frame);
			StretchBits(window, pixels, width, height);
		}
	}
	return 0;
}
```

---

### 2.3. 第三阶段：不再是黑白，添加色彩

- 同时修改优化，在debug下不那么卡（主要是把vector的分配拿到循环之外）;
- 本地视频播放完后的处理需要弄一下，不然内存泄露了，内存直接狂飙占满。

```c++
#include <stdio.h>
#include <Windows.h>
#include <string>
#include <vector>

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
	avformat_open_input(&fmtCtx, filepath, NULL, NULL);
	avformat_find_stream_info(fmtCtx, NULL);

	AVCodecContext *vcodecCtx = nullptr;
	for (int i = 0; i < fmtCtx->nb_streams; i++) {
		const AVCodec *codec = avcodec_find_decoder(fmtCtx->streams[i]->codecpar->codec_id);
		if (codec->type == AVMEDIA_TYPE_VIDEO) {
			param.VideoStreamIndex = i;
			vcodecCtx = avcodec_alloc_context3(codec);
			avcodec_parameters_to_context(vcodecCtx, fmtCtx->streams[i]->codecpar);
			avcodec_open2(vcodecCtx, codec, NULL);
		}
	}
	param.fmtCtx = fmtCtx;
	param.vcodecCtx = vcodecCtx;
	param.width = vcodecCtx->width;
	param.height = vcodecCtx->height;
}

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


void StretchBits(HWND hwnd, const std::vector<Color_RGB> &bits, int width, int height) {
	auto hdc = GetDC(hwnd);
	BITMAPINFO bitinfo = {};
	auto &bmiHeader = bitinfo.bmiHeader;
	bmiHeader.biSize = sizeof(bitinfo.bmiHeader);
	bmiHeader.biWidth = width;
	bmiHeader.biHeight = -height;  // 注意负号，否则会画面颠倒
	bmiHeader.biPlanes = 1;
	bmiHeader.biBitCount = 24;
	bmiHeader.biCompression = BI_RGB;

	// StretchDIBits 函数就快了很多
	StretchDIBits(hdc, 0, 0, width, height, 0, 0, width, height, &bits[0], &bitinfo, DIB_RGB_COLORS, SRCCOPY);
	ReleaseDC(hwnd, hdc);

}

// 写一个转换颜色编码的函数
std::vector<Color_RGB> GetRGBPixels(AVFrame *frame, std::vector<Color_RGB> &buffer) {
	static SwsContext *swsctx = nullptr;
	swsctx = sws_getCachedContext(swsctx,
		frame->width, frame->height, static_cast<AVPixelFormat>(frame->format),
		frame->width, frame->height, AVPixelFormat::AV_PIX_FMT_BGR24, NULL, NULL, NULL, NULL
	);  // 这里原来的类型转换是用的 (AVPixelFormat)frame->format

	// 每次循环调用这个函数，都会重新分配这个vector，debug下就很慢
	//std::vector<Color_RGB> buffer(frame->width * frame->height);
	
	//uint8_t* data[] = {(uint8_t*)&buffer[0]};
	uint8_t* data[] = {reinterpret_cast<uint8_t*>(&buffer[0])};  // c++类型的指针风格转换
	int linesize[] = { frame->width * 3 };
	// sws_scale 函数可以对画面进行缩放，同时还能改变颜色编码，
	sws_scale(swsctx, frame->data, frame->linesize, 0, frame->height, data, linesize);
	return buffer;
}


// 主函数入口
int WINAPI WinMain(
	_In_ HINSTANCE hInstance,
	_In_opt_ HINSTANCE hPrevInstance,
	_In_ LPSTR lpCmdLine,
	_In_ int nShowCmd
) {

	SetProcessDPIAware();

	auto className = L"MyWindow";
	WNDCLASSW wndClass = {};
	wndClass.hInstance = NULL;
	wndClass.lpszClassName = className;
	wndClass.lpfnWndProc = [](HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) -> LRESULT {
		switch (msg) {
		case WM_DESTROY:
			PostQuitMessage(0);
			return 0;
		default:
			return DefWindowProc(hwnd, msg, wParam, lParam);
		}
	};
	
    // 视频地址要对，不然会报错
	// std::string file_path = "C:\\Users\\Administrator\\Videos\\keypoint_result.mp4";
    std::string file_path = "rtsp://192.168.108.11:554/user=admin&password=&channel=1&stream=1.sdp?";

	DecoderParam decoderParam;
	InitDecoder(file_path.c_str(), decoderParam);
	int width = decoderParam.width;
	int height = decoderParam.height;
	auto &fmtCtx = decoderParam.fmtCtx;   // 不知道它这都习惯定义变量时用 & 引用
	auto &vcodecCtx = decoderParam.vcodecCtx;


	// 下面这个宏函数的定义(可点进去)，要看是否启用了Unicode编译，不然类型不行，这个网址一个介绍：https://blog.csdn.net/huashuolin001/article/details/95620424
	RegisterClass(&wndClass);
	auto window = CreateWindow(className, L"Hello World 标题", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, width, height, NULL, NULL, NULL, NULL);

	ShowWindow(window, SW_SHOW);

	MSG msg;

	// 进入循环，debug下，很慢，原来是每次调用 GetRGBPixels 函数，里面就要分配一个很大的vector
	// 所以在循环前创建好，直接传进去，避免每次循环都去重新分配
	std::vector<Color_RGB> buffer(width * height);

	while (1) {
		BOOL hasMsg = PeekMessage(&msg, NULL, 0, 0, PM_REMOVE);
		if (hasMsg) {
			if (msg.message == WM_QUIT) break;
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		else {
			AVFrame *frame = RequestFrame(decoderParam);
            // 原来的格式是AV_PIX_FMT_YUVJ420P，被丢弃，会有一个警告：deprecated pixel format used, make sure you did set range correctly
			frame->format = ConvertDeprecatedFormat(static_cast<AVPixelFormat>(frame->format));
            
			/*
			// 这是原来的写法
			std::vector<Color_RGB> pixels(width * height);
			for (int i = 0; i < pixels.size(); i++) {
				uint8_t r = frame->data[0][i];
				uint8_t g = r;
				uint8_t b = r;
				pixels[i] = { r, g, b };
			}*/
			std::vector<Color_RGB> pixels = GetRGBPixels(frame, buffer);  // 解码调用
			av_frame_free(&frame);
			StretchBits(window, pixels, width, height);
		}
	}

	return 0;
}
```

---

### 2.4. 第四阶段：本地视频播放过快

避免播放过快的一种解题思路： （因为现在视频播放速度是由cpu的计算决定的，可能就会很快）

- 直接Sleep暂停，这种计算、渲染还要时间，速度就慢了
- `std::this_thread::sleep_until` 能够延迟到指定的时间点，利用这个特性，即使解码和渲染占用了时间，也不会影响整体延迟时间，除非你的解码渲染一帧的时间已经超过了每帧间隔时间。(这个需要头文件`thread`)
- 但这些方法都不会是最终方案。

```c++
	auto currentTime = std::chrono::system_clock::now();  // 需要头文件 <chrono>
	MSG msg;
	while (1) {
		BOOL hasMsg = PeekMessage(&msg, NULL, 0, 0, PM_REMOVE);
		if (hasMsg) {
			if (msg.message == WM_QUIT) break;
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		else {
			AVFrame *frame = RequestFrame(decoderParam);
			std::vector<Color_RGB> pixels = GetRGBPixels(frame, buffer);  // 解码调用
			av_frame_free(&frame);

			// 为了正确的播放速度，以上的速度都是取决cpu运算速度
			/*
			AVCodecContext::framerate 可以获取视频的帧率，代表每秒需要呈现多少帧，他是 AVRational 类型，类似于分数，num 是分子，den 是分母。这里我们把他倒过来，再乘以1000得出每帧需要等待的毫秒数。

			double framerate = (double)vcodecCtx->framerate.den / vcodecCtx->framerate.num;
			Sleep(framerate * 1000);
			// 但是纯上面这样做，整个画面就慢了，因为计算渲染还要时间
			*/

			double framerate = (double)vcodecCtx->framerate.den / vcodecCtx->framerate.num;
			std::this_thread::sleep_until(currentTime + std::chrono::milliseconds(
				(int)(framerate * 1000)));
			currentTime = std::chrono::system_clock::now();
			
			StretchBits(window, pixels, width, height);
		}
	}
```

### 2.5. 第五阶段：cuda硬解码

- 获取当前设备环境所有可用的硬件解码器：

  ```c++
  #include <vector>
  #include <libavutil/hwcontext.h>   // 需要这个头文件
  
  std::vector<std::string> get_vdec_support_hwdevices() {
  	std::vector<std::string> hwdevs;
  	hwdevs.clear();
  	enum AVHWDeviceType type = AV_HWDEVICE_TYPE_NONE;
  	while((type = av_hwdevice_iterate_types(type)) != AV_HWDEVICE_TYPE_NONE) {
  		hwdevs.push_back(av_hwdevice_get_type_name(type));
  	}
  	return hwdevs;
  }
  ```

  家里的电脑暂时得到了这些结果：
  cuda
  dxva2
  qsv
  d3d11va
  opencl
  vulkan

硬件解码，改了这三个函数：

- linux上需要添加这个头文件`#include <libavutil/hwcontext.h>`，才能用下面硬件相关的一些函数。

```c++
void InitDecoder(const char* filepath, DecoderParam &param) {
	AVCodecContext *vcodecCtx = nullptr;
    AVFormatContext *fmtCtx = nullptr;

	// 之前是这种解码方式
	avformat_open_input(&fmtCtx, filepath, NULL, NULL);
	avformat_find_stream_info(fmtCtx, NULL);
	
	for (int i = 0; i < fmtCtx->nb_streams; i++) {
		const AVCodec *codec = avcodec_find_decoder(fmtCtx->streams[i]->codecpar->codec_id);
		if (codec->type == AVMEDIA_TYPE_VIDEO) {
			param.VideoStreamIndex = i;
			vcodecCtx = avcodec_alloc_context3(codec);
			avcodec_parameters_to_context(vcodecCtx, fmtCtx->streams[i]->codecpar);
			avcodec_open2(vcodecCtx, codec, NULL);
		}
	}
	
    
    // 启用硬件解码器 （加的是这一段）
	AVBufferRef *hw_device_ctx = nullptr;
    // linux下这个函数要这个头文件，#include <libavutil/hwcontext.h>,vs上不用
	int ret = av_hwdevice_ctx_create(&hw_device_ctx, AVHWDeviceType::AV_HWDEVICE_TYPE_DXVA2, NULL, NULL, NULL);  // linux下，最后一个参数NULL改成0好些
	vcodecCtx->hw_device_ctx = hw_device_ctx;  
	// 我在linux上，上面的类型用的cuda这个AVHWDeviceType::AV_HWDEVICE_TYPE_CUDA,ret得到的是0，成功了，但是上一行代码赋值时，始终错误，跟公司没有gpu的win上报的错好像类似；不知道是不是因为linux是ffmpeg3.4的版本，换4点几的版本可能就好了

	param.fmtCtx = fmtCtx;
	param.vcodecCtx = vcodecCtx;
	param.width = vcodecCtx->width;
	param.height = vcodecCtx->height;
}

std::vector<Color_RGB> GetRGBPixels(AVFrame *frame, std::vector<Color_RGB> &buffer) {
	
	AVFrame *swFrame = av_frame_alloc();
	av_hwframe_transfer_data(swFrame, frame, 0);
	frame = swFrame;  // 这是为了硬件解码加的几行
	
	static SwsContext *swsctx = nullptr;
	swsctx = sws_getCachedContext(swsctx,
		frame->width, frame->height, static_cast<AVPixelFormat>(frame->format),
		frame->width, frame->height, AVPixelFormat::AV_PIX_FMT_BGR24, NULL, NULL, NULL, NULL
	);  

	uint8_t* data[] = {reinterpret_cast<uint8_t*>(&buffer[0])};  // c++类型的指针风格转换
	int linesize[] = { frame->width * 3 };
	// sws_scale 函数可以对画面进行缩放，同时还能改变颜色编码，
	sws_scale(swsctx, frame->data, frame->linesize, 0, frame->height, data, linesize);
	av_frame_free(&swFrame);  // 这样也是
    return buffer;
}
```

- 除了上面这两个函数，StretchBits这个函数也大改了，用的Direct3D 9 渲染，而不是前面的 GDI渲染的古法。（至于相关更细节的原理看博客吧）

下面这个代码是简单先跑得起来的，跟前面的代码也差不多(但不是再用的GetRGBPixels这个函数，而是重新实现的另外的StretchBits)，用的是cuda(AVHWDeviceType::AV_HWDEVICE_TYPE_CUDA),这个代码用AV_HWDEVICE_TYPE_DXVA2或是AV_HWDEVICE_TYPE_D3D11VA都是会报错的，所以博客第一篇教程最后一点进行不下去。

```c++
#include <stdio.h>
#include <Windows.h>
#include <string>
#include <vector>
#include <chrono>  // 这和thread是为了播放速度正常要用到的
#include <thread>

#include <d3d9.h>  // D3D9渲染画面,Direct3D 9 渲染。（有些头文件在这里面暂时是没有用到的）
#pragma comment(lib, "d3d9.lib")

#include <wrl.h>
using Microsoft::WRL::ComPtr;

//using namespace std::chrono;

extern "C" {
#include <libavcodec/avcodec.h>
#pragma comment(lib, "avcodec.lib")

#include <libavformat/avformat.h>
#pragma comment(lib, "avformat.lib")

#include <libavutil/imgutils.h>
#pragma comment(lib, "avutil.lib")

	// 彩色画面要的，以及一些变换都要这个头文件
#include <libswscale/swscale.h>
#pragma comment(lib, "swscale.lib")
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
	AVCodecContext *vcodecCtx = nullptr;
	AVFormatContext *fmtCtx = nullptr;


	avformat_open_input(&fmtCtx, filepath, NULL, NULL);
	avformat_find_stream_info(fmtCtx, NULL);

	for (int i = 0; i < fmtCtx->nb_streams; i++) {
		const AVCodec *codec = avcodec_find_decoder(fmtCtx->streams[i]->codecpar->codec_id);
		if (codec->type == AVMEDIA_TYPE_VIDEO) {
			param.VideoStreamIndex = i;
			vcodecCtx = avcodec_alloc_context3(codec);
			avcodec_parameters_to_context(vcodecCtx, fmtCtx->streams[i]->codecpar);
			avcodec_open2(vcodecCtx, codec, NULL);
		}
	}

	// 启用硬件解码器
	AVBufferRef *hw_device_ctx = nullptr;
	av_hwdevice_ctx_create(&hw_device_ctx, AVHWDeviceType::AV_HWDEVICE_TYPE_CUDA, NULL, NULL, NULL);
	vcodecCtx->hw_device_ctx = hw_device_ctx;  // 没有GPU，这会报错


	param.fmtCtx = fmtCtx;
	param.vcodecCtx = vcodecCtx;
	param.width = vcodecCtx->width;
	param.height = vcodecCtx->height;
}

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
                // 把内存的申请放循环外，这是有问题的，会内存泄露，去看opencv_c++中，做了对应的修改
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

void StretchBits(IDirect3DDevice9 *device, const std::vector<uint8_t> &bits, int width, int height) {
	ComPtr<IDirect3DSurface9> surface;
	device->GetBackBuffer(0, 0, D3DBACKBUFFER_TYPE_MONO, surface.GetAddressOf());

	D3DLOCKED_RECT lockRect;
	surface->LockRect(&lockRect, NULL, D3DLOCK_DISCARD);

	memcpy(lockRect.pBits, &bits[0], bits.size());

	surface->UnlockRect();
	device->Present(NULL, NULL, NULL, NULL);
}
// 这基本丢弃了前面的方法，把StretchBits、GetRGBPixels这俩函数重新别的原理实现了
void GetRGBPixels(AVFrame* frame, std::vector<uint8_t> &buffer, AVPixelFormat pixelFormat, int byteCount) {
	AVFrame* swFrame = av_frame_alloc();
	av_hwframe_transfer_data(swFrame, frame, 0);
	frame = swFrame;

	static SwsContext* swsctx = nullptr;
	swsctx = sws_getCachedContext(
		swsctx,
		frame->width, frame->height, (AVPixelFormat)frame->format,
		frame->width, frame->height, pixelFormat, NULL, NULL, NULL, NULL);

	uint8_t* data[] = { &buffer[0] };
	int linesize[] = { frame->width * byteCount };
	sws_scale(swsctx, frame->data, frame->linesize, 0, frame->height, data, linesize);

	av_frame_free(&swFrame);
}

// 主函数入口
int WINAPI WinMain(
	_In_ HINSTANCE hInstance,
	_In_opt_ HINSTANCE hPrevInstance,
	_In_ LPSTR lpCmdLine,
	_In_ int nShowCmd
) {

	SetProcessDPIAware();

	auto className = L"MyWindow";
	WNDCLASSW wndClass = {};
	wndClass.hInstance = NULL;
	wndClass.lpszClassName = className;
	wndClass.lpfnWndProc = [](HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) -> LRESULT {
		switch (msg) {
		case WM_DESTROY:
			PostQuitMessage(0);
			return 0;
		default:
			return DefWindowProc(hwnd, msg, wParam, lParam);
		}
	};  // 这一个较前面的做了修改


	std::string file_path = "C:\\Users\\Administrator\\Videos\\keypoint_result.mp4";
	//std::string file_path = "rtsp://192.168.108.11:554/user=admin&password=&channel=1&stream=1.sdp?";

	DecoderParam decoderParam;
	InitDecoder(file_path.c_str(), decoderParam);
	int width = decoderParam.width;
	int height = decoderParam.height;
	auto &fmtCtx = decoderParam.fmtCtx;   // 不知道它这都习惯定义变量时用 & 引用
	auto &vcodecCtx = decoderParam.vcodecCtx;


	// D3D9 初始化设备
	ComPtr<IDirect3D9> d3d9 = Direct3DCreate9(D3D_SDK_VERSION);
	ComPtr<IDirect3DDevice9> d3d9Device;

	D3DPRESENT_PARAMETERS d3dParams = {};
	d3dParams.Windowed = TRUE;
	d3dParams.SwapEffect = D3DSWAPEFFECT_DISCARD;
	d3dParams.BackBufferFormat = D3DFORMAT::D3DFMT_X8R8G8B8;
	d3dParams.Flags = D3DPRESENTFLAG_LOCKABLE_BACKBUFFER;
	d3dParams.BackBufferWidth = width;
	d3dParams.BackBufferHeight = height;


	// 下面这个宏函数的定义(可点进去)，要看是否启用了Unicode编译，不然类型不行，这个网址一个介绍：https://blog.csdn.net/huashuolin001/article/details/95620424
	RegisterClass(&wndClass);
	auto window = CreateWindow(className, L"Hello World 标题", WS_OVERLAPPEDWINDOW, 0, 0, width, height, NULL, NULL, hInstance, NULL);

	d3d9->CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, window, D3DCREATE_HARDWARE_VERTEXPROCESSING, &d3dParams, d3d9Device.GetAddressOf());

	ShowWindow(window, SW_SHOW);

	std::vector<uint8_t> buffer(width * height * 4);

	auto currentTime = std::chrono::system_clock::now();
	MSG msg;
	while (1) {
		BOOL hasMsg = PeekMessage(&msg, NULL, 0, 0, PM_REMOVE);
		if (hasMsg) {
			if (msg.message == WM_QUIT) break;
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		else {
			AVFrame *frame = RequestFrame(decoderParam);
			GetRGBPixels(frame, buffer, AVPixelFormat::AV_PIX_FMT_BGRA, 4);
			av_frame_free(&frame);

			// 看要不要和这个延迟的代码
			//double framerate = (double)vcodecCtx->framerate.den / vcodecCtx->framerate.num;
			//std::this_thread::sleep_until(currentTime + std::chrono::milliseconds(
			//	(int)(framerate * 1000)));
			//currentTime = std::chrono::system_clock::now();

			StretchBits(d3d9Device.Get(), buffer, width, height);
		}
	}

	return 0;
}
```

#### 可以改成无边框：

auto window = CreateWindow(className, L"Hello World 标题", WS_POPUP, 100, 100, width, height, NULL, NULL, hInstance, NULL);

- 主要是这行，WS_OVERLAPPEDWINDOW 这个参数改成了 WS_POPUP;
- 然后 100, 100 指窗口左上角的位置坐标。

### 2.6. 硬解码的一个思路

这是群里一个问题的求助，放这里，以后可能会有一个参考：

Q：请问有人做过ffmpeg硬解码rtsp，能控制在200 ms以内不，我现在遇到的问题使用h264cuvid解码 延迟有500ms，用h264软解码200ms，都是用opencv显示的，不知道为啥硬解码显示的延迟比软解码还大。

A：一些参考

- 硬件的时间应该主要消耗在数据的输入输出吧，ffmpeg有omx的开源代码可以参考，我们目前用的gstreamer的开源代码，硬解码怎么也要比软解码快；
- 不知道是不是拷贝到cpu 这步骤消耗的时间，看你怎么操作的，包括数据的传递方式，资源的调度方式。
- 硬解码可能延迟要比软解码高。有数据拷贝消耗的。如果你的cpu能实时过来，延迟应该是比较低的。
- 但是500ms就太夸张了，软解码200ms也是合理但不是最快的。应该是协议协商的时候做了缓冲。
- 是的，但是可以配置。可以做到每帧都解码，但是会丢失抗扰动能力。
- 硬解码也可以做丢帧等策略降低延迟

## 三、用FFmpeg进行推流

实现的代码，暂时是在：SRS推流.md中