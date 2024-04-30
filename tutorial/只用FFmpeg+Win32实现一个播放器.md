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

### 第一阶段：只是把第一帧的画面，黑白显示出来

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

### 第二阶段：改成不移动鼠标也能自动播放

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

### 第三阶段：不再是黑白，添加色彩

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

### 第四阶段：本地视频播放过快

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

### 第五阶段：cuda硬解码

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

#### 硬解码的一个思路

这是群里一个问题的求助，放这里，以后可能会有一个参考：

Q：请问有人做过ffmpeg硬解码rtsp，能控制在200 ms以内不，我现在遇到的问题使用h264cuvid解码 延迟有500ms，用h264软解码200ms，都是用opencv显示的，不知道为啥硬解码显示的延迟比软解码还大。

A：一些参考

- 硬件的时间应该主要消耗在数据的输入输出吧，ffmpeg有omx的开源代码可以参考，我们目前用的gstreamer的开源代码，硬解码怎么也要比软解码快；
- 不知道是不是拷贝到cpu 这步骤消耗的时间，看你怎么操作的，包括数据的传递方式，资源的调度方式。
- 硬解码可能延迟要比软解码高。有数据拷贝消耗的。如果你的cpu能实时过来，延迟应该是比较低的。
- 但是500ms就太夸张了，软解码200ms也是合理但不是最快的。应该是协议协商的时候做了缓冲。
- 是的，但是可以配置。可以做到每帧都解码，但是会丢失抗扰动能力。
- 硬解码也可以做丢帧等策略降低延迟





