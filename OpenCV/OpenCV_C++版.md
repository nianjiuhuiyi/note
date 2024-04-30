	注意，因为配置opencv的lib库时没带d，不是debug版本，vs选择debug时，编译不会出错，但是一运行基本就会出错，主要提现在cv::imread()图片后，数据是空的，去cv::imshow()就会报错，可以在属性中去添加这个名字中带d的lib;

​	有的时候在又是在debug模式下是正常的，在release模式下又报错，大抵就是lib库是debug的，注意库的版本要和模式对应起来，(我同时把opencv的debug和release的lib都加进设置里面先后顺序都试过，只有release是ok的。有的时候又是只有Debug才行，主要针对vs中)(==新的解决办法来了==：配置的时在属性中所有配置(左上角)中统一添加环境变量，头文件路径、库文件路径，然后在release中添加不带d的lib,debug中添加带d的lib，就随便用了)

一定注意：在c++版本中读取rtsp摄像头、视频文件时，一定要下面这么写

```c++
cv::VideoCapture cap;
if (argc == 1) {
	cap.open(0);
}
else if (argc == 2) {
	// 一定要使用open这种方式
	cap.open("rtsp://192.168.108.11:554/");  // capo.open(argv[1]);
}
```

尽量用open()这个方法，确保成功，不要写成cv::VideoCapture cap(rtsp地址)，不然vs环境的nmake这种方式就会读取失败，虽然vs的sln里都能正常运行(linux下也是都可以的)。

## 01. 带滑动轨迹横条GUI的参数修改 

```c++
#include <iostream>
#include <string>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

static void on_ContrastAndBright(int, void *);

int g_nContrastValue = 80;  // 对比度
int g_nBrightValue = 80;   // 亮度
const std::string src_name = "【原始图窗口】";
const std::string dst_name = "【效果图窗口】";
cv::Mat g_srcImage, g_dstImage;

int main(int argc, char** argv) {
	cv::Mat img(300, 300, CV_8UC3, cv::Scalar(0, 255, 255));

	g_srcImage = cv::imread("./1.jpg");
	if (!g_srcImage.data) {
		std::cout << "图片读取错误，检查该路径或是否是Release模式~" << std::endl;
		return -1;
	}
	std::cout << g_srcImage.size() << std::endl;   // [700 x 704]
	std::cout << g_srcImage.type() << std::endl;   // 16
	g_dstImage = cv::Mat::zeros(g_srcImage.size(), g_srcImage.type());

	// 创建效果图窗口
	cv::namedWindow(dst_name, 1);

	// 创建轨迹条
	cv::createTrackbar("对比度: ", dst_name, &g_nContrastValue, 300, on_ContrastAndBright);
	cv::createTrackbar("亮  度: ", dst_name, &g_nBrightValue, 200, on_ContrastAndBright);

	// 进行回调函数初始化
	on_ContrastAndBright(g_nContrastValue, 0);
	on_ContrastAndBright(g_nBrightValue, 0);

	// 按下q时，程序退出
	while (char(cv::waitKey(1)) != 'q') {}
	return 0;
}

static void on_ContrastAndBright(int, void *) {
    // 改成0，图像可让拉拽缩放(但可能一开始图像的显示就不那么完全)
	cv::namedWindow(src_name, 1);  
	// 3个for循环，执行运算g_dstImage(i, j) = a*g_srcImage(i,j) + b
	for (int y = 0; y < g_srcImage.rows; ++y) {
		for (int x = 0; x < g_srcImage.cols; ++x) {
			for (int c = 0; c < 3; ++c) {
				g_dstImage.at<cv::Vec3b>(y, x)[c] =
					cv::saturate_cast<uchar> ((g_nContrastValue*0.01) * (g_srcImage.at<cv::Vec3b>(y, x)[c]) + g_nBrightValue);
			// 上面这个函数是用于溢出保护，大致是if(data<0) data=0; else if(data>255) data=255;
			}
		}
	}
	// 显示图像
	cv::imshow(src_name, g_srcImage);
	cv::imshow(dst_name, g_dstImage);
}

// 如果是视频要退出：
// 任意键：if ((cv::waitKey(1) & 0xff) != 255) break； // 注意前面的 & 运算要用括号括起来 
// 指定键：if (char(cv::waitKey(1)) == 'q') break;
```

一个简单的python版本：（相关鼠标事件cv2.setMouseCallback()、滑动条的demo，这个[网址](https://www.cnblogs.com/Undo-self-blog/p/8424056.html)点进去下滑到第7点）（pdf书，opencv-python中文教程似乎更不错，关于这个）

```python
name = "image"
image = cv2.imread("35.jpg")
cv2.namedWindow(name, 0)
# 初始阈值给到10，最大到100，后面这个函数我感觉只是占位置的
cv2.createTrackbar("thresh", name, 10, 100, lambda x: None)
while True:
    # 主要是这两个函数
    num = cv2.getTrackbarPos("thresh", name)
    ret, img = cv2.threshold(image, num, 255, cv2.THRESH_BINARY)
    cv2.imshow(name, img)
    if cv2.waitKey(1) & 0xFF != 255:
        break
```

---

均值滤波带滑动条

```c++
#include <iostream>
#include <string>
#include <opencv2/opencv.hpp>

#define KERNEL_THRESHOLD	200

void blurCallBack(int, void *);

int gKernelSize = 20;
cv::Mat gImgOri, gImgOut;
int main() {
	gImgOri = cv::imread("E:\\PycharmProject\\kit_check\\35.jpg");
	cv::namedWindow("imgOri", 0);
	cv::imshow("imgOri", gImgOri);

	blur(gImgOri, gImgOut, cv::Size(gKernelSize, gKernelSize));
	cv::namedWindow("imgOut", 0);
	cv::imshow("imgOut", gImgOut);

	cv::createTrackbar("Kernel Size", "imgOut", &gKernelSize, KERNEL_THRESHOLD, blurCallBack);

	cv::waitKey(0);
	return true;
}

void blurCallBack(int, void *) {
	if (gKernelSize <= 0)
		return;
	blur(gImgOri, gImgOut, cv::Size(gKernelSize, gKernelSize));
	imshow("imgOut", gImgOut);
	std::cout << gKernelSize << std::endl;
}
```

## 02. 提取螺母防松动标记

这个vs下，只有Debug才能运行，release又不行，费解。

```c++
#include <iostream>
#include <opencv2/opencv.hpp>
#include <vector>
#include <cmath>

#define M_PI 3.14159265358979323846

cv::Mat extract_read_area(cv::Mat &src_img) {
	// 提取红色区域部分的二值图
	int h = src_img.rows;
	int w = src_img.cols;

	cv::Mat img_hsv;
	cv::cvtColor(src_img, img_hsv, cv::COLOR_BGR2HSV);

	cv::Mat out_img = cv::Mat::zeros(h, w, CV_8UC1);   // CV_8UC1这个格式，不知为啥一定这
	for (int x = 0; x < h; ++x) {
		for (int y = 0; y < w; ++y) {
			cv::Vec3b pixel = img_hsv.at<cv::Vec3b>(x, y);  // [11, 13, 52]  这种格式的

			size_t point_h = pixel[0];
			size_t point_s = pixel[1];
			size_t point_v = pixel[2];
			// hsv 红色范围
			if ((point_h > 156 && point_h < 180) && (point_s > 43 && point_s < 255) && (point_v > 46 && point_v < 255)) {
				// 在clion中下面必须有一个空行或者这阿行后面加一个分号，不然就没结果，我不理解
				out_img.at<uchar>(x, y) = 255;  // 这里必须得是 uchar类型
			}
		}
	}
	return out_img;
}


void find_filter_contours(cv::Mat threshold_img, std::vector<std::vector<cv::Point>> &out_contours) {
	std::vector<std::vector<cv::Point>> contours;
	std::vector<cv::Vec4i> hierarchy;
	// 下面这个函数有两个重载版本，一个版本可以不要hierarchy这个参数
	cv::findContours(threshold_img, contours, hierarchy,cv::RETR_TREE, cv::CHAIN_APPROX_SIMPLE);

	// 过滤轮廓
	std::vector<std::vector<cv::Point>>::iterator iter = contours.begin();
	for (; iter != contours.end(); ++iter) {
		cv::Rect rect = cv::boundingRect(*iter);
		int width = rect.width;
		int height = rect.height;
		if (width < 10 || height < 10) continue;
		out_contours.push_back(*iter);
	}
}

void draw_obtain(cv::Mat &out_img ,std::vector<std::vector<cv::Point>> &contours, std::vector<cv::Point2i> &centers, std::vector<float> &angles) {
	
	for (auto vec : contours) {
		// 把中心点获取
		cv::RotatedRect rect = cv::minAreaRect(vec);
		cv::Point2f center = rect.center;
		int center_x = (int)center.x;
		int center_y = (int)center.y;
		centers.push_back(cv::Point2i(center_x, center_y));

		// 把对应角度获取
		float rect_w = rect.size.width;
		float rect_h = rect.size.height;
		float angle;
		if (rect_w > rect_h) {
			angle = rect.angle;
		}
		else {
			angle = -(90.0f - rect.angle);
		}
		angles.push_back(angle);
		printf("\ncenter_position: %d  %d\n", center_x, center_y);
		printf("rect_h_w: %f %f   angle: %f°\n", rect_h, rect_w, angle);


		// 画出来中心点
		cv::circle(out_img, cv::Point2i(center_x, center_y), 5, cv::Scalar(0, 255, 255), -1);
		// 画出最小外接矩形
		cv::Point2f box[4];  // 最小外接矩形的四个点
		rect.points(box);
		std::vector<cv::Point> box_int;
		for (int i = 0; i < (sizeof(box) / sizeof(box[i])); ++i) {
			// 要把坐标从float转成int，同时把它从box数组[]转换成vector
			box_int.push_back(cv::Point(std::round(box[i].x), std::round(box[i].y)));
		
		}
		// 是画的contours,可能有多个，所以最外层要用vector包一下
		cv::drawContours(out_img, std::vector<std::vector<cv::Point>>{box_int}, 0, cv::Scalar(0, 255, 0), 2);
	}
}


int main(int argc, char **argv) {
	cv::Mat img = cv::imread(R"(51.jpg)");   // 文件夹此笔记所在目录文件夹中
	// （1）抽取红色范围的二值图
	cv::Mat img_read = extract_read_area(img);
	//std::cout << typeid(img_read).name() << std::endl;  // class cv::Mat
	//std::cout << typeid(img_read.at<cv::Vec2b>(0, 0)[1]).name() << std::endl;  // unsigned char
	
	// （2）获取轮廓并进行初步筛选
	std::vector<std::vector<cv::Point>> contours;
	find_filter_contours(img_read, contours);

	// （3）将筛选后的轮廓画出来，并获取到这些轮廓的中心点和其对应的角度
	cv::Mat result_img;
	std::vector<cv::Point2i> centers;  // 图目标们的中心点
	std::vector<float> angles;   // 对应的角度
	img.copyTo(result_img);
	draw_obtain(result_img, contours, centers, angles);

	// （4）如果是一条完整的连续的线，也就一条；没错位但中间断开了，或者是错位了，就是两个轮廓；还有误判会可能不值2个框
	if (centers.size() > 1) {
		cv::Point center_1= centers[0], center_2 = centers[1];
		float slope = (float)(center_1.y - center_2.y) / (float)(center_1.x - center_2.x);
		// slope为正，方向就是对的，因为原点在左上角，slope为负，
		float center_angle = 0.0f;
		if (slope >= 0) {
			center_angle = std::atan(slope) * 180.f / M_PI;
		}
		else {
			center_angle = -1.0f * std::atan(std::abs<float>(slope)) * 180.f / M_PI;
		}
		std::cout << "两个中心点之间连线形成的角度：" << center_angle << "°" <<std::endl;
		
		if (std::abs(angles[0] - angles[1]) > 5.f ||
			std::abs((angles[0] + angles[1]) / 2.f - center_angle) > 10.f) {
			std::cout << "防松动标记位置已经改变，请及时检查！\n" << std::endl;
			cv::putText(result_img, "Error!", cv::Point(10, 30), cv::FONT_HERSHEY_SIMPLEX, 1.0, cv::Scalar(0, 0, 255), 2);
		}
		else {
			std::cout << "防松动标记位置正常！\n" << std::endl;
			cv::putText(result_img, "Normal", cv::Point(10, 30), cv::FONT_HERSHEY_SIMPLEX, 1.0, cv::Scalar(0, 255, 0), 2);
		}	
	}

	cv::imshow("1", img);
	cv::imshow("2", result_img);
	cv::waitKey(0);
	cv::destroyAllWindows();    // 摄像头的话：cap.release();
	return 0;
}
```

## 03. 互动获取像素值及分割

interactiveColorDetect.cpp  # 放这里做个参考吧，里面sprintf函数会报错，还没去解决

- ```c++
  #include "opencv2/opencv.hpp"
  #include <iostream>
  using namespace cv;
  using namespace std;
  
  //Global Variables
  Mat img, placeholder;
  
  // Callback function for any event on he mouse
  void onMouse( int event, int x, int y, int flags, void* userdata ) {   
      if( event == EVENT_MOUSEMOVE ) {
       	Vec3b bgrPixel(img.at<Vec3b>(y, x));
          Mat3b hsv,ycb,lab;
          // Create Mat object from vector since cvtColor accepts a Mat object
          Mat3b bgr (bgrPixel);
          
          //Convert the single pixel BGR Mat to other formats
          cvtColor(bgr, ycb, COLOR_BGR2YCrCb);
          cvtColor(bgr, hsv, COLOR_BGR2HSV);
          cvtColor(bgr, lab, COLOR_BGR2Lab);
          
          //Get back the vector from Mat
          Vec3b hsvPixel(hsv.at<Vec3b>(0,0));
          Vec3b ycbPixel(ycb.at<Vec3b>(0,0));
          Vec3b labPixel(lab.at<Vec3b>(0,0));
         
          // Create an empty placeholder for displaying the values
          placeholder = Mat::zeros(img.rows,400,CV_8UC3);
  
          //fill the placeholder with the values of color spaces
          putText(placeholder, format("BGR [%d, %d, %d]",bgrPixel[0],bgrPixel[1],bgrPixel[2]), Point(20, 70), FONT_HERSHEY_COMPLEX, .9, Scalar(255,255,255), 1);
          putText(placeholder, format("HSV [%d, %d, %d]",hsvPixel[0],hsvPixel[1],hsvPixel[2]), Point(20, 140), FONT_HERSHEY_COMPLEX, .9, Scalar(255,255,255), 1);
          putText(placeholder, format("YCrCb [%d, %d, %d]",ycbPixel[0],ycbPixel[1],ycbPixel[2]), Point(20, 210), FONT_HERSHEY_COMPLEX, .9, Scalar(255,255,255), 1);
          putText(placeholder, format("LAB [%d, %d, %d]",labPixel[0],labPixel[1],labPixel[2]), Point(20, 280), FONT_HERSHEY_COMPLEX, .9, Scalar(255,255,255), 1);
  
  	    Size sz1 = img.size();
  	    Size sz2 = placeholder.size();
  	    
          //Combine the two results to show side by side in a single image
          Mat combinedResult(sz1.height, sz1.width+sz2.width, CV_8UC3);
  	    Mat left(combinedResult, Rect(0, 0, sz1.width, sz1.height));
  	    img.copyTo(left);
  	    Mat right(combinedResult, Rect(sz1.width, 0, sz2.width, sz2.height));
  	    placeholder.copyTo(right);
  	    imshow("PRESS P for Previous, N for Next Image", combinedResult);
      }
  }
  
  int main( int argc, const char** argv ) {
      // filename
      // Read the input image
      int image_number = 0;
      int nImages = 10;
  
      if(argc > 1)
          nImages = atoi(argv[1]);
      
      char filename[20];
      sprintf(filename,"images/rub%02d.jpg",image_number%nImages);
      img = imread(filename);
      // Resize the image to 400x400
      Size rsize(400,400);
      resize(img,img,rsize);
  
      if(img.empty()) {
          return -1;
      }
      
      // Create an empty window
      namedWindow("PRESS P for Previous, N for Next Image", WINDOW_AUTOSIZE);   
      // Create a callback function for any event on the mouse
      setMouseCallback( "PRESS P for Previous, N for Next Image", onMouse );
      
      imshow( "PRESS P for Previous, N for Next Image", img );
      while(1) {
          char k = waitKey(1) & 0xFF;
          if (k == 27)
              break;
          //Check next image in the folder
          if (k =='n') {
              image_number++;
              sprintf(filename,"images/rub%02d.jpg",image_number%nImages);
              img = imread(filename);
              resize(img,img,rsize); 
          }
          //Check previous image in he folder
          else if (k =='p') {
              image_number--;
              sprintf(filename,"images/rub%02d.jpg",image_number%nImages);
              img = imread(filename);
              resize(img,img,rsize);
          }
      }
      return 0;
  }
  ```

interactiveColorSegment.cpp

- ```c++
  #include "opencv2/opencv.hpp"
  #include <iostream>
  #include <cstring>
  
  using namespace cv;
  using namespace std;
  // global variable to keep track of
  bool show = false;
  
  // Create a callback for event on trackbars
  void onTrackbarActivity(int pos, void* userdata){
  	// Just uodate the global variable that there is an event 
  	show = true;
  	return;
  }
  
  int main(int argc, char **argv) {
  	int image_number = 0;
      int nImages = 10;
      if(argc > 1)
          nImages = atoi(argv[1]);
      char filename[20];
      sprintf(filename,"images/rub%02d.jpg",image_number%nImages);
  
      Mat original = imread(filename);
  
  	// image resize width and height 
  	int resizeHeight = 250;
  	int resizeWidth = 250;
  	Size rsize(resizeHeight,resizeWidth);
  	resize(original, original, rsize);
  
  	// position on the screen where the windows start 
  	int initialX = 50;
  	int	initialY = 50;
  	
  	// creating windows to display images 
  	namedWindow("P-> Previous, N-> Next", WINDOW_AUTOSIZE);
  	namedWindow("SelectBGR", WINDOW_AUTOSIZE);
  	namedWindow("SelectHSV", WINDOW_AUTOSIZE);
  	namedWindow("SelectYCB", WINDOW_AUTOSIZE);
  	namedWindow("SelectLAB", WINDOW_AUTOSIZE);
  	
  	// moving the windows to stack them horizontally 
  	moveWindow("P-> Previous, N-> Next", initialX, initialY);
  	moveWindow("SelectBGR", initialX + 1 * (resizeWidth + 5), initialY);
  	moveWindow("SelectHSV", initialX + 2 * (resizeWidth + 5), initialY);
  	moveWindow("SelectYCB", initialX + 3 * (resizeWidth + 5), initialY);
  	moveWindow("SelectLAB", initialX + 4 * (resizeWidth + 5), initialY);
  	
  	// creating trackbars to get values for YCrCb 
  	createTrackbar("CrMin", "SelectYCB", 0, 255, onTrackbarActivity);
  	createTrackbar("CrMax", "SelectYCB", 0, 255, onTrackbarActivity);
  	createTrackbar("CbMin", "SelectYCB", 0, 255, onTrackbarActivity);
  	createTrackbar("CbMax", "SelectYCB", 0, 255, onTrackbarActivity);
  	createTrackbar("YMin", "SelectYCB", 0, 255, onTrackbarActivity);
  	createTrackbar("YMax", "SelectYCB", 0, 255, onTrackbarActivity);
  
  	// creating trackbars to get values for HSV 
  	createTrackbar("HMin", "SelectHSV", 0, 180, onTrackbarActivity);
  	createTrackbar("HMax", "SelectHSV", 0, 180, onTrackbarActivity);
  	createTrackbar("SMin", "SelectHSV", 0, 255, onTrackbarActivity);
  	createTrackbar("SMax", "SelectHSV", 0, 255, onTrackbarActivity);
  	createTrackbar("VMin", "SelectHSV", 0, 255, onTrackbarActivity);
  	createTrackbar("VMax", "SelectHSV", 0, 255, onTrackbarActivity);
  
  	// creating trackbars to get values for BGR 
  	createTrackbar("BMin", "SelectBGR", 0, 255, onTrackbarActivity);
  	createTrackbar("BMax", "SelectBGR", 0, 255, onTrackbarActivity);
  	createTrackbar("GMin", "SelectBGR", 0, 255, onTrackbarActivity);
  	createTrackbar("GMax", "SelectBGR", 0, 255, onTrackbarActivity);
  	createTrackbar("RMin", "SelectBGR", 0, 255, onTrackbarActivity);
  	createTrackbar("RMax", "SelectBGR", 0, 255, onTrackbarActivity);
  
  	// creating trackbars to get values for LAB 
  	createTrackbar("LMin", "SelectLAB", 0, 255, onTrackbarActivity);
  	createTrackbar("LMax", "SelectLAB", 0, 255, onTrackbarActivity);
  	createTrackbar("AMin", "SelectLAB", 0, 255, onTrackbarActivity);
  	createTrackbar("AMax", "SelectLAB", 0, 255, onTrackbarActivity);
  	createTrackbar("BMin", "SelectLAB", 0, 255, onTrackbarActivity);
  	createTrackbar("BMax", "SelectLAB", 0, 255, onTrackbarActivity);
  
  	// show all images initially 
  	imshow("SelectHSV", original);
  	imshow("SelectYCB", original);
  	imshow("SelectLAB", original);
  	imshow("SelectBGR", original);
  	
  	// declare local variables
  	int BMin, GMin, RMin;
  	int BMax, GMax, RMax;
  	Scalar minBGR, maxBGR;
  
  	int HMin, SMin, VMin;
  	int HMax, SMax, VMax;
  	Scalar minHSV, maxHSV;
  
  	int LMin, aMin, bMin;
  	int LMax, aMax, bMax;
  	Scalar minLab, maxLab;
  
  	int YMin, CrMin, CbMin;
  	int YMax, CrMax, CbMax;
  	Scalar minYCrCb, maxYCrCb;
  
  	Mat imageBGR, imageHSV, imageLab, imageYCrCb;
  	Mat maskBGR, maskHSV, maskLab, maskYCrCb;
  	Mat resultBGR, resultHSV, resultLab, resultYCrCb;
  
  	char k;
  	while (1) {
  		imshow("P-> Previous, N-> Next", original);
  		k = waitKey(1) & 0xFF;
  		//Check next image in the folder
          if (k =='n') {
              image_number++;
              sprintf(filename,"images/rub%02d.jpg",image_number%nImages);
              original = imread(filename);
              resize(original,original,rsize); 
              show = true;
          }
          //Check previous image in he folder
          else if (k =='p') {
              image_number--;
              sprintf(filename,"images/rub%02d.jpg",image_number%nImages);
              original = imread(filename);
              resize(original,original,rsize);
              show = true;
          }
  
          // Close all windows when 'esc' key is pressed		
  		if (k == 27) {
  			break;
  		}
  		
  		if (show) { //If there is any event on the trackbar
  			show = false;
  
              // Get values from the BGR trackbar
  			BMin = getTrackbarPos("BMin", "SelectBGR");
  			GMin = getTrackbarPos("GMin", "SelectBGR");
  			RMin = getTrackbarPos("RMin", "SelectBGR");
  
  			BMax = getTrackbarPos("BMax", "SelectBGR");
  			GMax = getTrackbarPos("GMax", "SelectBGR");
  			RMax = getTrackbarPos("RMax", "SelectBGR");
  
  			minBGR = Scalar(BMin, GMin, RMin);
  			maxBGR = Scalar(BMax, GMax, RMax);
  
              // Get values from the HSV trackbar
  			HMin = getTrackbarPos("HMin", "SelectHSV");
  			SMin = getTrackbarPos("SMin", "SelectHSV");
  			VMin = getTrackbarPos("VMin", "SelectHSV");
  
  			HMax = getTrackbarPos("HMax", "SelectHSV");
  			SMax = getTrackbarPos("SMax", "SelectHSV");
  			VMax = getTrackbarPos("VMax", "SelectHSV");
  
  			minHSV = Scalar(HMin, SMin, VMin);
  			maxHSV = Scalar(HMax, SMax, VMax);
  
              // Get values from the LAB trackbar
  			LMin = getTrackbarPos("LMin", "SelectLAB");
  			aMin = getTrackbarPos("AMin", "SelectLAB");
  			bMin = getTrackbarPos("BMin", "SelectLAB");
  
  			LMax = getTrackbarPos("LMax", "SelectLAB");
  			aMax = getTrackbarPos("AMax", "SelectLAB");
  			bMax = getTrackbarPos("BMax", "SelectLAB");
  
  			minLab = Scalar(LMin, aMin, bMin);
  			maxLab = Scalar(LMax, aMax, bMax);
  
              // Get values from the YCrCb trackbar
  			YMin = getTrackbarPos("YMin", "SelectYCB");
  			CrMin = getTrackbarPos("CrMin", "SelectYCB");
  			CbMin = getTrackbarPos("CbMin", "SelectYCB");
  
  			YMax = getTrackbarPos("YMax", "SelectYCB");
  			CrMax = getTrackbarPos("CrMax", "SelectYCB");
  			CbMax = getTrackbarPos("CbMax", "SelectYCB");
  
  			minYCrCb = Scalar(YMin, CrMin, CbMin);
  			maxYCrCb = Scalar(YMax, CrMax, CbMax);
  
  			// Convert the BGR image to other color spaces
  			original.copyTo(imageBGR);
  			cvtColor(original, imageHSV, COLOR_BGR2HSV);
  			cvtColor(original, imageYCrCb, COLOR_BGR2YCrCb);
  			cvtColor(original, imageLab, COLOR_BGR2Lab);
  
  			// Create the mask using the min and max values obtained from trackbar and apply bitwise and operation to get the results
  			inRange(imageBGR, minBGR, maxBGR, maskBGR);
  			resultBGR = Mat::zeros(original.rows, original.cols, CV_8UC3);
  			bitwise_and(original, original, resultBGR, maskBGR);
  
  			inRange(imageHSV, minHSV, maxHSV, maskHSV);
  			resultHSV = Mat::zeros(original.rows, original.cols, CV_8UC3);
  			bitwise_and(original, original, resultHSV, maskHSV);
  
  			inRange(imageYCrCb, minYCrCb, maxYCrCb, maskYCrCb);
  			resultYCrCb = Mat::zeros(original.rows, original.cols, CV_8UC3);
  			bitwise_and(original, original, resultYCrCb, maskYCrCb);
  
  			inRange(imageLab, minLab, maxLab, maskLab);
  			resultLab = Mat::zeros(original.rows, original.cols, CV_8UC3);
  			bitwise_and(original, original, resultLab, maskLab);
  
  			// Show the results
  			imshow("SelectBGR", resultBGR);
  			imshow("SelectYCB", resultYCrCb);
  			imshow("SelectLAB", resultLab);
  			imshow("SelectHSV", resultHSV);
  		}
  	}
  	destroyAllWindows();
  	return 0;
  }
  ```

## 04. 获取fps

说明：getTickCount：

​	它返回从操作系统启动到当前所经过的毫秒数，常常用来判断某个方法执行的时间，其函数原型是DWORD GetTickCount(void)，返回值以32位的双字类型DWORD存储，因此可以存储的最大值是2^32 ms约为49.71天，因此若系统运行时间超过49.71天时，这个数就会归0，MSDN中也明确的提到了:"Retrieves the number of milliseconds that have elapsed since the system was started, up to 49.7 days."。因此，如果是编写服务器端程序，此处一定要万分注意，避免引起意外的状况。

特别注意：这个函数并非实时发送，而是由系统每18ms发送一次，因此其最小精度为18ms。当需要有小于18ms的精度计算时，应使用StopWatch方法进行。

* 连续触发200次，实测下来，最小间隔在15ms。

```c++
#include <stdio.h>  // sprintf 函数需要
// 有的视频可以直接获取fps:
int video_fps = (int)capture.get(cv::CAP_PROP_FPS);

double t = 0.0, fps = 0.0;
char fps_string[10];  // 用于存放帧率的字符串 
while (cap.isOpened()) {
    // 计算fps，从头到尾
    t = (double)cv::getTickCount(); // getTickcount函数：返回从操作系统启动到当前所经过的毫秒数
    
    // cap>>frame;  读取视频要放在 t 后面

  	// 中间是一系列的计算

    t = ((double)cv::getTickCount() - t) / cv::getTickFrequency();
    fps = 1.0 / t;
    // getTickFrequency函数：返回每秒的计时周期数
    // t为该处代码执行所耗的时间,单位为秒,fps为其倒数
    
    sprintf(fps_string, "%.2f", fps);  // 帧率保留两位小数
    std::string fpsString("fps: ");
    fpsString += fps_string;
    
    cv::putText(image, fpsString, cv::Point(10, 30), cv::FONT_HERSHEY_PLAIN, 2, cv::Scalar(0, 0, 255), 2, cv::LINE_AA);

    cv::imshow(window_name, image);
    int c = cv::waitKey(1);
    if ((char)c == 'q') break;
}
```

## 05. 鼠标事件的demo

这是图形学中的作业四，画贝塞尔曲线，关于鼠标事件这个作用里用的比较简单明了，可以参考看看。白塞尔曲线实现的来源是看的[这里](https://blog.csdn.net/qq_48626761/article/details/126101177)。

```c++
#include <chrono>
#include <iostream>
#include <opencv2/opencv.hpp>

std::vector<cv::Point2f> control_points;

void mouse_handler(int event, int x, int y, int flags, void *userdata) {
    if (event == cv::EVENT_LBUTTONDOWN && control_points.size() < 4) {
        std::cout << "Left button of the mouse is clicked - position (" << x << ", "
        << y << ")" << '\n';
        control_points.emplace_back(x, y);
    }     
}

void naive_bezier(const std::vector<cv::Point2f> &points, cv::Mat &window) {
    auto &p_0 = points[0];
    auto &p_1 = points[1];
    auto &p_2 = points[2];
    auto &p_3 = points[3];

    for (double t = 0.0; t <= 1.0; t += 0.001) {
        auto point = std::pow(1 - t, 3) * p_0 + 3 * t * std::pow(1 - t, 2) * p_1 +
                 3 * std::pow(t, 2) * (1 - t) * p_2 + std::pow(t, 3) * p_3;

        window.at<cv::Vec3b>(point.y, point.x)[2] = 255;
    }
}

cv::Point2f recursive_bezier(const std::vector<cv::Point2f> &control_points, float t) {
	if (control_points.size() == 2)
		return control_points[0] + t * (control_points[1] - control_points[0]);
	std::vector<cv::Point2f> control_points_temp;
	for (int i = 0; i < control_points.size() - 1; i++)
		control_points_temp.push_back(control_points[i] + t * (control_points[i + 1] - control_points[i]));
	// TODO: Implement de Casteljau's algor
	return recursive_bezier(control_points_temp, t);
}


void bezier(const std::vector<cv::Point2f> &control_points, cv::Mat &window) {
	// TODO: Iterate through all t = 0 to t = 1 with small steps, and call de Casteljau's 
	// recursive Bezier algorithm.
	for (double t = 0; t <= 1; t += 0.001) {
		auto point = recursive_bezier(control_points, t);
		window.at<cv::Vec3b>(point.y, point.x)[1] = 255;
	}
}

int main() {
    cv::Mat window = cv::Mat(700, 700, CV_8UC3, cv::Scalar(0));
    cv::cvtColor(window, window, cv::COLOR_BGR2RGB);
    cv::namedWindow("Bezier Curve", cv::WINDOW_AUTOSIZE);

    cv::setMouseCallback("Bezier Curve", mouse_handler, nullptr);

    int key = -1;
    while (key != 27) {
        for (auto &point : control_points) {
            cv::circle(window, point, 3, {255, 255, 255}, 3);
        }

        if (control_points.size() == 4) {
        	// 主要是这两行是画曲线，可以只执行其中一个
            naive_bezier(control_points, window);
            bezier(control_points, window);

            cv::imshow("Bezier Curve", window);
            cv::imwrite("my_bezier_curve.png", window);
            key = cv::waitKey(0);

            return 0;
        }
        cv::imshow("Bezier Curve", window);
        key = cv::waitKey(20);
    }
	return 0;
}
```

## 06. cvui 界面

​	“cvui.hpp”(这个文件在此文档所在路径)：是用opencv自己写的带ui界面的操作，It is a C++, header-only and cross-platform。来自于[LearnOpenCV](https://github.com/spmallick/learnopencv/tree/master/UI-cvui)，可以根据它里面的教程去看它demo一步步的实现，后面一些简单的交互界面就考虑它了。

- demo1: 鼠标点击，界面有计数

  ```c++
  #include <opencv2/opencv.hpp>
  #include "cvui.hpp"
  
  #define WINDOW_NAME "CVUI Hello World!"
  
  int main(int argc, const char *argv[]) {
  	cv::Mat frame = cv::Mat(200, 500, CV_8UC3);
  	int count = 0;
  
  	// Init a OpenCV window and tell cvui to use it.
  	// If cv::namedWindow() is not used, mouse events will
  	// not be captured by cvui.
  	cv::namedWindow(WINDOW_NAME);
  	cvui::init(WINDOW_NAME);
  
  	while (true) {
  		// Fill the frame with a nice color
  		frame = cv::Scalar(49, 52, 49);
  
  		// Buttons will return true if they were clicked, which makes
  		// handling clicks a breeze.
  		if (cvui::button(frame, 110, 80, "Hello, world!")) {
  			// The button was clicked, so let's increment our counter.
  			count++;
  		}
  
  		// Sometimes you want to show text that is not that simple, e.g. strings + numbers.
  		// You can use cvui::printf for that. It accepts a variable number of parameter, pretty
  		// much like printf does.
  		// Let's show how many times the button has been clicked.
  		cvui::printf(frame, 250, 90, 0.4, 0xff0000, "Button click count: %d", count);
  
  		// This function must be called *AFTER* all UI components. It does
  		// all the behind the scenes magic to handle mouse clicks, etc.
  		cvui::update();
  
  		// Show everything on the screen
  		cv::imshow(WINDOW_NAME, frame);
  
  		// Check if ESC key was pressed
  		if (cv::waitKey(20) == 27) {
  			break;
  		}
  	}
  	cv::destroyAllWindows();
  	return 0;
  }
  ```

- demo2: 勾选框启用canny边缘检测

  ```c++
  #include <opencv2/opencv.hpp>
  #include "cvui.hpp"
  
  #define WINDOW_NAME	"CVUI Canny Edge"
  
  int main(int argc, const char *argv[]) {
  	cv::Mat lena = cv::imread("lena.jpg");
  	cv::Mat frame = lena.clone();
  	int low_threshold = 50, high_threshold = 150;
  	bool use_canny = false;
  
  	// Init a OpenCV window and tell cvui to use it.
  	// If cv::namedWindow() is not used, mouse events will
  	// not be captured by cvui.
  	cv::namedWindow(WINDOW_NAME);
  	cvui::init(WINDOW_NAME);
  
  	while (true) {
  		// Should we apply Canny edge?
  		if (use_canny) {
  			// Yes, we should apply it.
  			cv::cvtColor(lena, frame, cv::COLOR_BGR2GRAY);
  			cv::Canny(frame, frame, low_threshold, high_threshold, 3);
  		}
  		else {
  			// No, so just copy the original image to the displaying frame.
  			lena.copyTo(frame);
  		}
  
  		// Render the settings window to house the checkbox
  		// and the trackbars below.
  		cvui::window(frame, 10, 50, 180, 180, "Settings");
  
  		// Checkbox to enable/disable the use of Canny edge
  		cvui::checkbox(frame, 15, 80, "Use Canny Edge", &use_canny);
  
  		// Two trackbars to control the low and high threshold values
  		// for the Canny edge algorithm.
  		cvui::trackbar(frame, 15, 110, 165, &low_threshold, 5, 150);
  		cvui::trackbar(frame, 15, 180, 165, &high_threshold, 80, 300);
  
  		// This function must be called *AFTER* all UI components. It does
  		// all the behind the scenes magic to handle mouse clicks, etc.
  		cvui::update();
  
  		// Show everything on the screen
  		cv::imshow(WINDOW_NAME, frame);
  
  		// Check if ESC was pressed
  		if (cv::waitKey(30) == 27) {
  			break;
  		}
  	}
  	cv::destroyAllWindows();
  	return 0;
  }
  ```

## 07. 多线程读相机

按键退出时还是有点问题，解决不了。

```c++
#include <queue>
#include <thread>
#include <chrono>
#include <iostream>
#include <string>
#include <memory>
#include <mutex>
#include <opencv2/opencv.hpp>

void func() {
	cv::Mat image = cv::imread(R"(C:\Users\Administrator\Pictures\01.png)");

	cv::Mat res;
	cv::Rect rect(10, 10, 400, 400);
	cv::resize(image(rect), res, cv::Size(400, 400));

	cv::imshow("1", res);
	cv::waitKey(0);
	cv::destroyAllWindows();
}



std::mutex mtx;   // 加锁保证线程安全
bool gExit = false;

std::string get_timestamp() {
	/*std::chrono::milliseconds ms = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
	std::time_t time = ms.count();
	char str[100];
	std::strftime(str, sizeof(str), "%Y-%m-%d %H:%M:%S", std::localtime(&time));*/

	std::tm time_info{};
	std::time_t timestamp = std::time(nullptr);
	errno_t err = localtime_s(&time_info, &timestamp);
	if (err) {
		std::cout << "Failed to convert timestamp to time\n";
		return std::string("error");
	}
	char str[100]{};
	std::strftime(str, sizeof(str), "%Y-%m-%d %H:%M:%S", &time_info);
	return std::string(str);
}

// 如果传进来的是智能指针，这里的参数也要给智能指针，不能是 std::queue<cv::Mat>* que
void get_image(const char* rtsp_path, std::shared_ptr<std::queue<cv::Mat>> que, int video_stride=15) {
	cv::VideoCapture cap;
	cap.open(rtsp_path);
	while (1) {
		if (cap.isOpened()) break;
		else {
			std::cerr << rtsp_path << " 打开失败，正在重试..." << std::endl;
			cap.open(rtsp_path);
		}
	}

	long long int n = 0;
	while (1) {
		n += 1;
		bool success = cap.grab();     // .read() = .grab() followed by .retrieve()
		if (!success) {
			while (1) {
				bool ret = cap.open(rtsp_path);
				if (ret) break;
				else {
					std::cerr << get_timestamp() <<": 摄像头读取失败，30秒后再次尝试..." << std::endl;
					std::this_thread::sleep_for(std::chrono::seconds(30));
				}
			}
			continue;
		}

		if (n % video_stride != 0) continue;

		cv::Mat frame;
		success = cap.retrieve(frame);
		if (!success) {
			while (1) {
				bool ret = cap.open(rtsp_path);
				if (ret) break;
				else {
					std::cerr << get_timestamp() << ": 摄像头读取失败，30秒后再次尝试..." << std::endl;
					std::this_thread::sleep_for(std::chrono::seconds(30));
				}
			}
			continue;
		}

		// 必须加锁保证线程安全
		std::unique_lock<std::mutex> lock(mtx);
		if (que->size() >= 2)
			que->pop();
		que->push(frame);
		lock.unlock();

		std::cout << "现在的size: " << que->size() << std::endl;
		if (gExit) break;
	}
	cap.release();
	std::cout << "子线程退出" << std::endl;
}


int main(int argc, char** argv) {
	const char* video_path = "rtsp://192.168.108.131:554/user=admin&password=&channel=1&stream=0.sdp?";
	cv::namedWindow("hello");

	// 图像队列
	std::shared_ptr<std::queue<cv::Mat>> que = std::make_shared<std::queue<cv::Mat>>();
	// 下面不管哪种方式，函数哪怕有默认参数，也一定要给默认参数的值，不然是找不到对应函数的。
	/*方式一：使用 bind 绑定
	auto f = std::bind(get_image, video_path, que, 15);
	std::thread img_thread(f);
	*/
	/*方式二：使用lambda
	std::thread img_thread([video_path, que]() {get_image(video_path, que, 1); });  // 值捕获
	std::thread img_thread([&video_path, &que]() {get_image(video_path, que, 1); });  // 引用捕获，
	*/
	std::thread img_thread([&]() {get_image(video_path, que, 1); });  // 这也是引用捕获
	// 这里创建线程就会直接执行了。

	while (true) {

		if (que && !que->empty()) {
			std::cout << "123" << std::endl;
			cv::Mat frame;

			// 必须加锁保证线程安全
			std::unique_lock<std::mutex> lock(mtx);
			frame = que->front();
			que->pop();
			lock.unlock();

			// 模拟检测用时
			std::this_thread::sleep_for(std::chrono::milliseconds(200));

			cv::imshow("hello", frame);
			if ((cv::waitKey(1) & 0xFF) != 255) {
				gExit = true;
				break;
			}
		}
		else {
			std::cout << get_timestamp() << "pause" << std::endl;
			std::this_thread::sleep_for(std::chrono::milliseconds(100));
		}

	}
	std::this_thread::sleep_for(std::chrono::seconds(1));

	cv::destroyAllWindows();
	return 0;
}
```

注意：

- 使用智能指针，那函数的参数对应的类型也要是智能指针的类型。
- 为了保证线程安全，操作共享数据时一定要加锁，不然跑一会儿后就会错。
- c++的多线程在创建后就会直接执行，不需要像python那样去.start()。若是用了 .join() 主线程会直接卡在join那一句，直到子线程运行结束。
- 创建c++子线程时，是不能传递参数的，所有得将其包装成可调用对象，如std::bind、lambda。且一定记得函数哪怕有了默认参数，都一定要给。

## opencv的一些api

### 1. cv::resize

```c++
int h = 480, w = 640;
cv::Mat picture(h, w, CV_8UC3);
cv::resize(img, picture, picture.size(), 0, 0, cv::INTER_LINEAR);
// 其他不重要的，主要是第三个参数，用的 ".size()"  这样才不会报错
// 480 x 640  struct cv::MatSize   这是打印结果。
std::cout << frame.size << typeid(frame.size).name() << std::endl;

// [640 x 480]class cv::Size_<int>
std::cout << frame.size() << typeid(frame.size()).name() << "\n" << std::endl;
```

同样可以：

```
cv::resize(img, img, cv::Size(kInputW, kInputH));   // 这样就是直接改变的本身
```

还可以用它来获得一个图片的部分信息，这样就不用一个个去循环赋值了：

```c++
// 这是 yolov5的tensorrt的图片后处理代码中的一个函数
cv::Mat scale_mask(cv::Mat mask, cv::Mat img) {
    int x, y, w, h;
    float r_w = kInputW / (img.cols * 1.0);
    float r_h = kInputH / (img.rows * 1.0);
    if (r_h > r_w) {
        w = kInputW;
        h = r_w * img.rows;
        x = 0;
        y = (kInputH - h) / 2;
    }
    else {
        w = r_h * img.cols;
        h = kInputH;
        x = (kInputW - w) / 2;
        y = 0;
    }
    //  主要就是注意下面这几行代码,,resize把整个src初始化成了 dst
    cv::Rect rect(x, y, w, h);
    cv::Mat res;
    // 注意这 mask(rect),源码是重载了 ()，这样就是截取了这个区域
    cv::resize(mask(rect), res, img.size());
    return res;
}
// 截取某个区域额更简单的写法
cv::Mat image = cv::imread(R"(C:\Users\Administrator\Pictures\01.png)");
cv::Rect rect(10, 10, 400, 400);
cv::imshow("1", image(rect));  // 注意这种写法

cv::Mat res;
cv::resize(image(rect), res, cv::Size(400, 400));  // 这样给到 res
// 或者直接
cv::Mat res = image(rect);
```

### 2. 检测点是否在轮廓内

函数应该是：cv::pointPolygonTest 

​	看到群友发言，说是搞成二值图，然后把轮廓内的像素都置为0，这样还有像素为1的点就在轮廓外，是个思路。另外学习opengl的时候，可以用向量的乘积的正负来判断这个问题。

OpenCV是自带这个api的，可看这篇[文章](https://blog.csdn.net/kakiebu/article/details/81983714)。

### 3. cv::glob

​	类似于python(import glob; img_path = glob.glob("./*.png"))

```c++
#include <string>
#include <opencv2/opencv.hpp>
#include <vector>

int main() {
	std::vector< std::string> images_path;
	// 这images_path是引用传入，得到的就是前面路径下的所有文件绝对路径
	cv::glob("./under/images", images_path);  
	// 第一张图
	cv::Mat img = cv::imread(images_path.at(0));
}
```

### 4. cv::fillPoly

填充指定区域：

```c++
#include <vector>
#include <opencv2/opencv.hpp>

int main() {
    // 注意：一般opencv中的array，这里都用vector去实现
	std::vector<cv::Point> points = { {60, 60}, {40, 10}, {100, 100}, {200, 60}, {300, 50} };
    cv::Mat img = cv::Mat::ones(cv::Size(640, 640), CV_8UC3);
    cv::rectangle(img, cv::Point(10, 10), cv::Point(60, 60), cv::Scalar(0, 0, 255), 2);
    cv::fillPoly(img, points, cv::Scalar(0, 0, 255));
    cv::imshow("123", img);
    cv::waitKey(0);
}
```





简单的读取摄像头

```
#include <iostream>
#include <string>
#include <opencv2/opencv.hpp>

int main(int argc, char** argv) {
	const char* video_path = "rtsp://192.168.108.134:554/user=admin&password=&channel=1&stream=1.sdp?";

	cv::namedWindow("hello");
	cv::VideoCapture cap;
	cap.open(video_path);

	cv::Mat frame;
	while (cap.isOpened()) {
		bool ret = cap.read(frame);
		if (!ret) break;
		cap >> frame;
		std::cout << frame.size << typeid(frame.size).name() << std::endl;
		std::cout << frame.size() << typeid(frame.size()).name() << "\n" << std::endl;

		cv::imshow("hello", frame);
		if ((cv::waitKey(1) & 0xFF) != 255) break;
	}
	cv::destroyAllWindows();
	cap.release();
	return 0;
}
```

