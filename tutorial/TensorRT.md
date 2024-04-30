tensorRT这个就叫量化：好像训练默认的精度就是FP32(单精度)(FP64是双精度),tensorRT默认就是将其量化为FP16(单精度),也可以设置，将其量化为int8



官方文档地址：[这里](https://docs.nvidia.com/deeplearning/tensorrt/container-release-notes/index.html)，release记录[官网](https://docs.nvidia.com/deeplearning/tensorrt/release-notes/index.html)。

知乎的一个参考：[这里](https://zhuanlan.zhihu.com/p/371239130)

TensorRT Plguin的一些东西(暂时不是很懂这个)：[这里](https://blog.csdn.net/han2529386161/article/details/102723545) 

版本：GA(general availability)代表正式版；EA(early access)代表测试版

一个tensorrt学习的github的[旧项目](https://github.com/dlunion/tensorRTIntegrate.git)、[新项目](https://github.com/shouxieai/tensorRT_Pro) 

[netron](https://github.com/lutzroeder/netron)：查看网络模型，可以在这[地址](https://zhuanlan.zhihu.com/p/477743341)里搜索一下netron的简单用法，这里还有openlab关于部署、pytorch转onnx模型，onnx修改等。

ONNX查看器，带修改版本，[地址](https://github.com/ZhangGe6/onnx-modifier/blob/master/readme_zh-CN.md)。

英伟达的一个B站[官方教程](https://www.bilibili.com/video/BV15Y4y1W73E/?spm_id_from=333.788&vd_source=2189d09f782381396f1ef53083a0a78b)，还有配套代码。

## 一、安装

安装这部分很久以前写的了，意义不大，看一看就好，也没去改了。

1. 下载：直接[官网](https://developer.nvidia.com/nvidia-tensorrt-7x-download)(7.x版本)去下载好`.tar.gz`版本，比如：`TensorRT-7.2.3.4.CentOS-7.9.x86_64-gnu.cuda-10.2.cudnn8.1.tar.gz`
   （8.x[版本](https://developer.nvidia.com/nvidia-tensorrt-8x-download)）

2. 安装：直接把这个包解压到一个地方，会得到一个名为`TensorRT-7.2.3.4`的文件夹

   1. 添加环境变量：就是把上面这个文件夹的路径，假如是 /user/local/TensorRT-7.2.3.4/，那么就是

      >vim ~/.bashrc  # 可以写进这个配置文件，也可以直接新建一个文件写到里面 
      >vim /etc/profile.d/tensorRT.sh    # 后面的名字是自己起的，内容就是下面
>
      >#(动态库搜索路径)

      export LD_LIBRARY_PATH=/user/local/TensorRT-7.2.3.4/lib:$LD_LIBRARY_PATH
    
      >#(静态库搜索路径)
      export LIBRARY_PATH=/user/local/TensorRT-7.2.3.4/lib::$LIBRARY_PATH
      
      >#c++程序头文件搜索路径
      export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/opt/TensorRT-7.2.3.4/include
    
      完了后，记得`source ~/.bashrc`  不然会说文件找不到，再不行就把ssh断开重新连接。

Ps：尽量根据TensorRT的名字，把cuda和cudnn的版本对应起来。

​	比如构建这个项目：[torch2trt](https://github.com/NVIDIA-AI-IOT/torch2trt)的环境，先安装了python版的tensorrt后，然后按照它的README，在做  python setup.py develop 或 pip install -v -e .  时 可能就会报错(就是因为没有添加tensorrt的环境变量)，然后就有一个错“fatal error: NvInfer.h: No such file or directory”，然后把头文件路径export添加进去后，继续它的README,又会“cannot find -lnvinfer”，然后export动态库路径后还是不行，再export静态库路径就可以了。更多的可以去看看GCC编译器的笔记。

win的版本就是直接把压缩包解压后放那里用头文件和库文件就好了。

## 二、python中使用TensorRT

参考：[这里](https://blog.csdn.net/zong596568821xp/article/details/86077553)

1. 如果要使用 Python 接口的 TensorRT，则需要安装 Pycuda

   > pip install pycuda        

错误解决：

- 前提条件，gcc-4.8的版本是不行的（会看到gcc的error），一直报错，然后我centos安装了gcc-8就可以直接pip安装了，这时候调用pycuda时；
- 可能会报一个错误==ImportError: libnvinfer.so.7: cannot open shared object file: No such file or directory==，那就是还要把tensorrt的动态库路径添加到环境变量中去。
- pycuda因为版本的问题，cuda10.2是支持的比较好的，然后即便服务器是安装了cuda11.1，也是会报一个错no such file==libcudart.so.10.2==,所以可以自己创建一个cuda10.2的容器，把里面的文件libcudart.so.10.2直接复制到/usr/local/cuda-11.1/targets/x86_64-linux/lib中去，就可以使用了。

---

下面是安装：比如它的路径是：/opt/TensorRT-7.2.3.4/，，那就先cd进去

1. 针对python中`import tensorrt`  # 在pypi中找的tensorrt的包不对

   ```shell
   cd ./python
   pip install tensorrt-7.2.3.4-cp37-none-linux_x86_64.whl    # 里面还有一些其它不同python版本
   # 后面使用就是
   import tensorrt as trt
   ```

2. 安装UFF,支持tensorflow模型转化

   ```shell
   cd ./uff
   pip install uff-0.6.9-py2.py3-none-any.whl
   ```

3. 安装graphsurgeon，支持自定义结构

   ```shell
   cd ./graphsurgeon
   pip install graphsurgeon-0.4.5-py2.py3-none-any.whl
   ```

## 三、c++编写tensorrt网络层

看sky_hole的B站[视频](https://www.bilibili.com/video/BV1GM4y1M7GD/?spm_id_from=333.999.0.0&vd_source=2189d09f782381396f1ef53083a0a78b)。

还有它对应的一个[github项目](https://github.com/wdhao/tensorrtCV)，里面的代码，各种层更加完整，完全可以参考。

### 3.1. 网络、环境准备

​	首先网络用的resnet18.pth,再将其导出为resnet18.onnx(方便netron查看)，然后是使用的qt写的(仅c++应用，没要ui)。

​	注：一般网上下载的.pth文件都是用的torch.save(net.state_dict(), "123.pth")，这就只保存了key-value，而没有网络结构，这种model = torch.load(path, map_location=torch.device("cpu"))的model是没办法直接导出成onnx格式的，那要拿到它的网络结构(假设这个网络结构类的实例对象叫mdoel_net)，那就要

model_net.load_state_dict(torch.load(path, map_location=torch.device("cpu"))),这个得到的model_net才能直接像下面这样导成onnx。

1. 获取resnet18网络：（在用pytorch保存得到onnx模型时：一定要加参数 `training=2`）

   ```python
   if __name__ == '__main__':
       model = torchvision.models.resnet18(pretrained=False)
       print(model)  # onnx看起有问题时把这结构打出来看，还是有区别，并不完全一样
   
       torch.save(model.state_dict(), "./resnet18.pth")
       model = model.cuda()
       dummy_input = torch.ones(1, 3, 256, 256, dtype=torch.float32).cuda()
       # onnx格式用netron看起来格式更好，比.pth好很多
       # 一定要加 training=2 这个参数，不然batchnormal会被融合,就看不到这层了，而且每层的名字都是数字 
       torch.onnx.export(model, dummy_input, "./resnet18.onnx", verbose=True, training=2)
   ```

   然后把这resnet18.pth解析出来保存在文件夹中：

   ```python
   import os
   import struct
   
   import torch
   import torchvision
   torch.cuda.set_device(0)
   
   def getWeights(model_path):
       state_dict = torch.load(model_path, map_location=lambda storage, loc:storage)
       keys = [value for key, value in enumerate(state_dict)]
       weights = dict()
       for key in keys:
           weights[key] = state_dict[key]
       return weights, keys
   
   def extract(weights, keys, weights_path):
       if not os.path.exists(weights_path):
           os.mkdir(weights_path)
       for key in keys:
           print(key)
           value = weights[key]
           Shape = value.shape
           allsize = 1
           for idx in range(len(Shape)):
               allsize *= Shape[idx]
   
           Value = value.reshape(allsize)
           with open(weights_path + key + ".wgt", "wb") as fp:
               a = struct.pack("i", allsize)
               fp.write(a)
               for i in range(allsize):
                   a = struct.pack("f", Value[i])
                   fp.write(a)
   
   if __name__ == '__main__':
       weights, keys = getWeights("./resnet18.pth")
       extract(weights, keys, "./trt_weights/")  # 把每层的权重这些保存到了这个文件夹里，后续要用
   ```

2. qt中的.pro文件的编写:
    win32不是必须的，在window上可加，linux上去掉就是。

   ```properties
   TEMPLATE = app
   CONFIG += console c++11
   CONFIG -= app_bundle
   CONFIG -= qt
   
   win32 {
       INCLUDEPATH += \
           'E:\lib\TensorRT-7.2.3.4.Windows10.x86_64.cuda-10.2.cudnn8.1\include' \
           'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.2\include'
   }
   win32 {
       LIBS += \
           -L'E:\lib\TensorRT-7.2.3.4.Windows10.x86_64.cuda-10.2.cudnn8.1\lib' nvinfer.lib \
           -L'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.2\lib\x64' cudart.lib
   }
   
   SOURCES += \
           main.cpp \
       tensorrt.cpp
   
   HEADERS += \
       tensorrt.h
   ```

3. tensorrt的注意点：

   - 1.tensorRT工程生成的.engine文件在不同的显卡上不能通用，这是因为硬件的内部构造不同决定的，所以当有多张不同显卡时，要指定显卡的索引。

   - 2.一个trt工程有且仅有一个Logger，所有的trt日志只会从这个Logger接口输出。例如: error/warning/info等，推荐使用继承的方式自定义logger:在tensorrt.h中

     ```c++
     #include <NvInfer.h>
     class Logger : public nvinfer1::ILogger {
     public:
         void log(nvinfer1::ILogger::Severity severity, const char* msg) override {
             if (severity == Severity::kINFO) return;
     
             switch(severity) {
             case Severity::kINTERNAL_ERROR:
                  std::cerr << "kINTERNAL_ERROR: ";
                 break;
             case Severity::kERROR:
                 std::cerr << "ERROR: ";
                 break;
             case Severity::kWARNING:
                 std::cerr << "kWARNING: ";
                 break;
             case Severity::kINFO:
                 std::cerr << "kINFO: ";
                 break;
             default:
                 std::cerr << "UNKNOWN: ";
                 break;
             }
             std::cerr << msg << std::endl;
         }
     };
     ```

### 3.2. 编写网络层，生成.engine文件

代码里的注释写得非常清晰明了了，3.2文件的这三个文件，结合上面的Logger类是可以成功运行的

#### 3.2.1 tensorrt.h文件

​	里面完善了各种常用层的一个定义，就实现resnet18这网络来说，是没有用完的，不影响。

```c++
#include <NvInfer.h>
// 为了方便写shuffle层而写的结构体
struct shuffle {
    nvinfer1::Dims reshape;
    nvinfer1::Permutation permute;
};
class tensorRT {
public:
    tensorRT();
    void createENG(std::string engPath);  // 这里面实现各层网络的组合

    // 0.加载权重
    std::vector<float> loadWeoghts(const std::string &weightPath);

    // 1.卷积层(每层出来得到的类型肯定都是tensor)
    nvinfer1::ITensor* trt_conv(std::string inputLayerName, std::string weightsName, std::string biasPath, int output_c, int kernel, int stride, int padding);

    // 2.batchnormal层（m_network这里是不带的，用的其scale来改造的）
    nvinfer1::ITensor* trt_batchnormal(std::string inputLayerName, std::string weightsName);

    // 3.激活层(relu、leak_relu、sigmoid....很多的激活)
    nvinfer1::ITensor* trt_activation(std::string inputLayerName, std::string activate_type);

    // 4.池化(这是没有权重文件的)
    nvinfer1::ITensor* trt_pool(std::string inputLayerName, std::string pool_type, int kernel, int stride, int padding);

    // 5.tensoer的add、或者相减、相除这些操作
    nvinfer1::ITensor* trt_calculate(std::string inputLayerName1, std::string inputLayerName2, std::string cal_type);

    // 6.fc层：即全连接层，
    nvinfer1::ITensor* trt_fc(std::string inputLayerName, std::string weightsName, std::string biasName, int out_features); 
    
    /** 以下层是最后一个视频补充的，跑通前面的demo暂时没用到  **/ 
    
    // 7.两个矩阵相乘
    nvinfer1::ITensor* trt_matmul(std::string inputLayerName1, std::string inputLayerName2);
    
    // 8. softmax：这输出是两个，一个是置信度，一个是类别,,但一次只能输出一个，由dim决定（dim只会是o或1）
    nvinfer1::ITensor* trt_softmax(std::string inputLayerName, int dim);
    
    // 9.concate:去到nvinfer1::INetworkDefinition类里面，找到addConcatenation虚函数，会发现它要的输入是一个数组ITensor* const* inputs
    // 我们一般的操作还是先用vector存储好，然后再new一个数组，再把vector中的元素一个个复制进去
    nvinfer1::ITensor* trt_concate(std::vector<std::string> inputLayerNames, int axis);
	
    // 10.slice:这个好像做了比较多的假设，写的比较固定，真要用时，当做一个参考，不一定对;有哪些参数也去看其原虚函数
    nvinfer1::ITensor* trt_slice(std::string inputLayerName, std::vector<int>start, std::vector<int>outputSize, std::vector<int>step);
	
    // 11.shuffle:tensort的shuffle层可以只做rehsape(即view)或permute(即transpose)；也可以都做，都做也就需要指定谁先谁后
    // 为了方便一些本应该设置为参数的值我直接写到函数实现了，自己到时候酌情改参数吧
    shuffle m_shuffle;  // 这是上面的自定义结构体
    nvinfer1::ITensor* trt_shuffle(std::string inputLayerName, std::vector<int> reshapeSize, std::vector<int> permuteSize);

    // 12.添加一个常量层到神经网络，这样来实现一个常量(下面aplha参数)乘以一个tensoer的操作
    nvinfer1::ITensor* trt_constant(std::vector<int> dimensions, float alpha);
    
    
    std::string rootPath = "E:/project/Pycharm_project/trt_study/trt_weights/";

    Logger m_logger;
    // 定义一个个网络结构，一切都是根据这来的
    nvinfer1::INetworkDefinition *m_network;

    /*
        上面的每层函数，第一个参数都是std::string inputLayerName，讲道理每层的输入应该是tensoer，
        所以这里就用了一个map将tensor和名字对应了起来，去取tensor
    */
    std::map<std::string, nvinfer1::ITensor*> Layers;
private:
    void print_tensor_size(std::string layerName, nvinfer1::ITensor *input_tensor);
};
```

#### 3.2.2 tensorrt.cpp实现

```c++
#include <iostream>
#include <fstream>

#include "tensorrt.h"

tensorRT::tensorRT() { }

void tensorRT::print_tensor_size(std::string layerName, nvinfer1::ITensor *input_tensor) {
    std::cout << layerName.c_str() << ": ";
    // 打印维度，基本上这些api就是这些，记住，，因为我们的输入n是1，所以这里只会打印一次。
    for (int i = 0; i < input_tensor->getDimensions().nbDims; i++) {
        std::cout << input_tensor->getDimensions().d[i] << " ";
    }
    std::cout << std::endl;
}

std::vector<float> tensorRT::loadWeoghts(const std::string &weightPath) {
    int size = 0;
    std::ifstream file(weightPath, std::ios::in | std::ios::binary);
    if (!file.is_open()) {
        std::cout << "\nError: " << weightPath.c_str() << " " << "can not open!\n" << std::endl;
        // 实际这里应该直接返回了，因为打开始失败
    }

    file.read((char*)&size, 4 );
    char* floatWeights = new char[size*4];
    float *fp = (float*)floatWeights;
    file.read(floatWeights, size*4);
    std::vector<float> weights(fp, fp+size);
    delete[] floatWeights;
    file.close();
    return weights;
}


void tensorRT::createENG(std::string engPath) {
    int input_c = 3;
    int input_h = 256;
    int input_w = 256;
    // 创建引擎就要这个Builder，下面推理时就要runtime
    nvinfer1::IBuilder *builder = nvinfer1::createInferBuilder(this->m_logger);
    this->m_network = builder->createNetwork();
    // tensor
    // 输入起个名字，装载到网络中去
    nvinfer1::ITensor *input = this->m_network->addInput("data", nvinfer1::DataType::kFLOAT,
                                       nvinfer1::DimsCHW(static_cast<int>(input_c),
                                           				static_cast<int>(input_h),
                                                  		static_cast<int>(input_w)));
	// 网络输入开始写
    this->Layers["input"] = input;
    /*
        当onnx看起来有问题是，用Python，把那个模型打印出来，看
            model = torchvision.models.resnet50(pretrained=False)
            print(model)  # 结构也很清晰,然后某一个比如conv的卷积中，没看到padding，那就是0
        第一行就是：(conv1): Conv2d(3, 64, kernel_size=(7, 7), stride=(2, 2), padding=(3, 3), bias=False)
        因为没有bias，所以这里bias的路径就给的空(第三个参数)，，输出通道是64

        卷积给的权重的路径就是整个权重文件的名字
        batchnormal层，给的权重文件的路径就是其名字的前半截，在其对应函数中还去拼接了，因为它有meanValue、varValue等
    */
    
    this->Layers["conv1"] = this->trt_conv("input", "conv1.weight.wgt", "", 64, 7, 2, 3);
    this->Layers["batchNormal1"] = this->trt_batchnormal("conv1", "bn1");  // 这一层的输入就是上一层的"conv1"
    this->Layers["relu1"] = this->trt_activation("batchNormal1", "relu");
    this->Layers["maxPool1"] = this->trt_pool("relu1", "max", 3, 2, 1);

    // 下面就是残差层
    // layer1
    this->Layers["layer1.0.conv1"] = this->trt_conv("maxPool1", "layer1.0.conv1.weight.wgt", "", 64, 3, 1, 1);
    this->Layers["layer1.0.bn1"] = this->trt_batchnormal("layer1.0.conv1", "layer1.0.bn1");  // batchnormal层因为有几个权重文件，就只给了前面的前缀
    this->Layers["layer1.0.relu1"] = this->trt_activation("layer1.0.bn1", "relu");

    this->Layers["layer1.0.conv2"] = this->trt_conv("layer1.0.relu1", "layer1.0.conv2.weight.wgt", "", 64, 3, 1, 1);
    this->Layers["layer1.0.bn2"] = this->trt_batchnormal("layer1.0.conv2", "layer1.0.bn2");

    /*
        这里面是resnet50的写法
    this->Layers["layer1.0.conv3"] = this->trt_conv("layer1.0.relu2", "layer1.0.conv3.weight.wgt", "", 256, 1, 1, 0);
    this->Layers["layer1.0.bn3"] = this->trt_batchnormal("layer1.0.conv3", "layer1.0.bn3");

        // 这里开始是layer1的downsample，看onnx图，这里的输入是最上面最大池化后的
    this->Layers["layer1.0.downsample.0"] = this->trt_conv("maxPool1", "layer1.0.downsample.0.weight.wgt", "",  256, 1, 1, 0);
    this->Layers["layer1.0.downsample.1"] = this->trt_batchnormal("layer1.0.downsample.0", "layer1.0.downsample.1");

        // 然后两个tensort的add操作(layer1.add名字自己取的)
    this->Layers["layer1.add"] = this->trt_calculate("layer1.0.bn3", "layer1.0.downsample.1", "add");
    this->Layers["layer1.relu1"] = this->trt_activation("layer1.add", "relu");

    */

        // 然后两个tensort的add操作(layer1.add名字自己取的)
    this->Layers["layer1.add"] = this->trt_calculate("maxPool1", "layer1.0.bn2", "add");
    this->Layers["layer1.relu1"] = this->trt_activation("layer1.add", "relu");
    // 以上部分就是pth中layer1中的(0): Bottleneck的部分，，onnx看起来跟直接打印出来的pth结构还是有点不一样

        // layer1.1
    this->Layers["layer1.1.conv1"] = this->trt_conv("layer1.relu1", "layer1.1.conv1.weight.wgt", "", 64, 3, 1, 1);
    this->Layers["layer1.1.bn1"] = this->trt_batchnormal("layer1.1.conv1", "layer1.1.bn1");
    this->Layers["layer1.1.relu1"] = this->trt_activation("layer1.1.bn1", "relu");
    this->Layers["layer1.1.conv2"] = this->trt_conv("layer1.1.relu1", "layer1.1.conv2.weight.wgt", "", 64, 3, 1, 1);
    this->Layers["layer1.1.bn2"] = this->trt_batchnormal("layer1.1.conv2", "layer1.1.bn2");
        // add
    this->Layers["layer1.1.add"] = this->trt_calculate("layer1.relu1", "layer1.1.bn2", "add");
    this->Layers["layer1.1.relu2"] = this->trt_activation("layer1.1.add", "relu");


    // layer2
    this->Layers["layer2.0.conv1"] = this->trt_conv("layer1.1.relu2", "layer2.0.conv1.weight.wgt", "", 128, 3, 2, 1);
    this->Layers["layer2.0.bn1"] = this->trt_batchnormal("layer2.0.conv1", "layer2.0.bn1");
    this->Layers["layer2.0.relu1"] = this->trt_activation("layer2.0.bn1", "relu");
    this->Layers["layer2.0.conv2"] = this->trt_conv("layer2.0.relu1", "layer2.0.conv2.weight.wgt", "", 128, 3, 1, 1);
    this->Layers["layer2.0.bn2"] = this->trt_batchnormal("layer2.0.conv2", "layer2.0.bn2");
        // downsample
    this->Layers["layer2.0.downsample.0"] = this->trt_conv("layer1.1.relu2", "layer2.0.downsample.0.weight.wgt", "", 128, 1, 2, 0);
    this->Layers["layer2.0.downsample.1"] = this->trt_batchnormal("layer2.0.downsample.0", "layer2.0.downsample.1");
        // add
    this->Layers["layer2.add"] = this->trt_calculate("layer2.0.bn2", "layer2.0.downsample.1", "add");
    this->Layers["layer2.relu1"] = this->trt_activation("layer2.add", "relu");

        // layer2.1
    this->Layers["layer2.1.conv1"] = this->trt_conv("layer2.relu1", "layer2.1.conv1.weight.wgt", "", 128, 3, 1, 1);
    this->Layers["layer2.1.bn1"] = this->trt_batchnormal("layer2.1.conv1", "layer2.1.bn1");
    this->Layers["layer2.1.relu1"] = this->trt_activation("layer2.1.bn1", "relu");
    this->Layers["layer2.1.conv2"] = this->trt_conv("layer2.1.relu1", "layer2.1.conv2.weight.wgt", "", 128, 3, 1, 1);
    this->Layers["layer2.1.bn2"] = this->trt_batchnormal("layer2.1.conv2", "layer2.1.bn2");
        // add
    this->Layers["layer2.1.add"] = this->trt_calculate("layer2.relu1", "layer2.1.bn2", "add");
    this->Layers["layer2.1.relu1"] = this->trt_activation("layer2.1.add", "relu");


    // layer3
    this->Layers["layer3.0.conv1"] = this->trt_conv("layer2.1.relu1", "layer3.0.conv1.weight.wgt", "", 256, 3, 2, 1);
    this->Layers["layer3.0.bn1"] = this->trt_batchnormal("layer3.0.conv1", "layer3.0.bn1");
    this->Layers["layer3.0.relu1"] = this->trt_activation("layer3.0.bn1", "relu");
    this->Layers["layer3.0.conv2"] = this->trt_conv("layer3.0.relu1", "layer3.0.conv2.weight.wgt", "", 256, 3, 1, 1);
    this->Layers["layer3.0.bn2"] = this->trt_batchnormal("layer3.0.conv2", "layer3.0.bn2");
        // downsample
    this->Layers["layer3.0.downsample.0"] = this->trt_conv("layer2.1.relu1", "layer3.0.downsample.0.weight.wgt", "", 256, 1, 2, 0);
    this->Layers["layer3.0.downsample.1"] = this->trt_batchnormal("layer3.0.downsample.0", "layer3.0.downsample.1");
        // add
    this->Layers["layer3.0.add"] = this->trt_calculate("layer3.0.bn2", "layer3.0.downsample.1", "add");
    this->Layers["layer3.0.relu1"] = this->trt_activation("layer3.0.add", "relu");

        // layer3.1
    this->Layers["layer3.1.conv1"] = this->trt_conv("layer3.0.relu1", "layer3.1.conv1.weight.wgt", "", 256, 3, 1, 1);
    this->Layers["layer3.1.bn1"] = this->trt_batchnormal("layer3.1.conv1", "layer3.1.bn1");
    this->Layers["layer3.1.relu1"] = this->trt_activation("layer3.1.bn1", "relu");
    this->Layers["layer3.1.conv2"] = this->trt_conv("layer3.1.relu1", "layer3.1.conv2.weight.wgt", "",  256, 3, 1, 1);
    this->Layers["layer3.1.bn2"] = this->trt_batchnormal("layer3.1.conv2", "layer3.1.bn2");
        // add
    this->Layers["layer3.1.add"] = this->trt_calculate("layer3.0.relu1", "layer3.1.bn2", "add");
    this->Layers["layer3.1.relu1"] = this->trt_activation("layer3.1.add", "relu");


    // layer4
    this->Layers["layer4.0.conv1"] = this->trt_conv("layer3.1.relu1", "layer4.0.conv1.weight.wgt", "", 512, 3, 2, 1);
    this->Layers["layer4.0.bn1"] = this->trt_batchnormal("layer4.0.conv1", "layer4.0.bn1");
    this->Layers["layer4.0.relu1"] = this->trt_activation("layer4.0.bn1", "relu");
    this->Layers["layer4.0.conv2"] = this->trt_conv("layer4.0.relu1", "layer4.0.conv2.weight.wgt", "", 512, 3, 1, 1);
    this->Layers["layer4.0.bn2"] = this->trt_batchnormal("layer4.0.conv2", "layer4.0.bn2");
        // downsample
    this->Layers["layer4.0.downsample.0"] = this->trt_conv("layer3.1.relu1", "layer4.0.downsample.0.weight.wgt", "", 512, 1, 2, 0);
    this->Layers["layer4.0.downsample.1"] = this->trt_batchnormal("layer4.0.downsample.0", "layer4.0.downsample.1");
        // add
    this->Layers["layer4.0.add"] = this->trt_calculate("layer4.0.bn2", "layer4.0.downsample.1", "add");
    this->Layers["layer4.0.relu1"] = this->trt_activation("layer4.0.add", "relu");

        // layer4.1
    this->Layers["layer4.1.conv1"] = this->trt_conv("layer4.0.relu1", "layer4.1.conv1.weight.wgt", "", 512, 3, 1, 1);
    this->Layers["layer4.1.bn1"] = this->trt_batchnormal("layer4.1.conv1", "layer4.1.bn1");
    this->Layers["layer4.1.relu1"] = this->trt_activation("layer4.1.bn1", "relu");
    this->Layers["layer4.1.conv2"] = this->trt_conv("layer4.1.relu1", "layer4.1.conv2.weight.wgt", "", 512, 3, 1, 1);
    this->Layers["layer4.1.bn2"] = this->trt_batchnormal("layer4.1.conv2", "layer4.1.bn2");
        // add
    this->Layers["layer4.1.add"] = this->trt_calculate("layer4.0.relu1", "layer4.1.bn2", "add");
    this->Layers["layer4.1.relu1"] = this->trt_activation("layer4.1.add", "relu");   // 这层的形状打印出来看是：(512,8,8)


    // avgpool：在python这层显示 (avgpool): AdaptiveAvgPool2d(output_size=(1, 1))
    // 意思是最终输出的size是(1, 1),那这层的卷积核就是用(8, 8),步长就无所谓了
    this->Layers["globalAvgPool"] = this->trt_pool("layer4.1.relu1", "average", 8, 1, 0);
    // fc:全连接层 (最后的out_features=1000是网络定的)
    this->Layers["fc"] = this->trt_fc("globalAvgPool", "fc.weight.wgt", "fc.bias.wgt", 1000);


    // 让最后一层作为输出层
    this->Layers["fc"]->setName("output");
    this->m_network->markOutput(*this->Layers["fc"]);  // 就这两行

    builder->setMaxBatchSize(20);  // 设置一些属性
    builder->setMaxWorkspaceSize(1<<30);   // 1G

    std::cout << "engine init ..." << std::endl;
    nvinfer1::ICudaEngine *engine = builder->buildCudaEngine(*this->m_network);
    /*
    yolov5的tensorrt用到的是 config传进来的参数，是
    	nvinfer1::ICudaEngine *engine = builder->buildEngineWithConfig(*network, *config);
    	其中config是 nvinfer1::IBuilderConfig *config
    	    // Engine config
    	builder->setMaxBatchSize(maxBatchSize);
    	config->setMaxWorkspaceSize(16 * (1 << 20));  // 16MB   然后用congfig来设置这些属性
    
        #if defined(USE_FP16)
            config->setFlag(nvinfer1::BuilderFlag::kFP16);
        #elif defined(USE_INT8)
            std::cout << "Your platform support int8: " << (builder->platformHasFastInt8() ? "true" : "false") << std::endl;
            assert(builder->platformHasFastInt8());
            config->setFlag(nvinfer1::BuilderFlag::kINT8);  // config来设置标志
            Int8EntropyCalibrator2 *calibrator = new Int8EntropyCalibrator2(1, kInputW, kInputH, "./coco_calib/", "int8calib.table", kInputTensorName);
            config->setInt8Calibrator(calibrator);
        #endif   	
    */
    nvinfer1::IHostMemory *modelStream = engine->serialize();  // Serialize the engine
	
    // 写成 .engine 引擎文件
     // 其实 ofstream 已经表明是输出了，就不需要std::ios::out，除非是std::fstream，就需要这样写
    std::ofstream engFile;
    engFile.open(engPath, std::ios::out | std::ios::binary);
    engFile.write(static_cast<const char*>(modelStream->data()), modelStream->size());

    this->m_network->destroy();
    engine->destroy();
    builder->destroy();
    modelStream->destroy();
}


nvinfer1::ITensor* tensorRT::trt_conv(std::string inputLayerName, std::string weightsName,
                                      std::string biasPath, int output_c, int kernel, int stride, int padding) {
    std::vector<float> weights;
    std::vector<float> bias;
    weights = this->loadWeoghts(this->rootPath + weightsName);
    if (biasPath != "") {      // bias可能没有
        bias = loadWeoghts(biasPath);
    }

    int size = weights.size();
    nvinfer1::Weights conWeights {nvinfer1::DataType::kFLOAT, nullptr, size};  // 这里只能用花括号，不能用()
    nvinfer1::Weights conBias {nvinfer1::DataType::kFLOAT, nullptr, output_c};

    float *val_wt = new float[size];
    for (int i = 0; i < size; i++) {
        val_wt[i] = weights[i];
    }
    conWeights.values = val_wt;

    float *val_bias = new float[output_c];
    for (int i = 0; i < output_c; i++) {  // 为什么这里是 i<output_c 呢，好像是这样的，记不太清楚原理了
        val_bias[i] = 0.0;
        if (bias.size() != 0) {
            val_bias[i] = bias[i];
        }
    }
    conBias.values = val_bias;

    // 构建trt的卷积层，它自带了，所以用addConvolution来生成，后面batchnormal就没有
    nvinfer1::IConvolutionLayer *conv = this->m_network->addConvolution(*this->Layers[inputLayerName], output_c,
                                                                        nvinfer1::DimsHW(kernel, kernel), conWeights, conBias);
    // IConvolutionLayer这个类自带了设置stride和padding
    conv->setStride(nvinfer1::DimsHW(stride, stride));
    conv->setPadding(nvinfer1::DimsHW(padding, padding));
    this->print_tensor_size("conv", conv->getOutput(0));
    return conv->getOutput(0);   // 感觉是数组那种，给0返回的首地址吧
}

nvinfer1::ITensor* tensorRT::trt_batchnormal(std::string inputLayerName, std::string weightsName) {
    /*
    batchnormal中有几个权重文件：weight、bias、mean、var
    tensorrt中因为没有batchnormal这层，所以是用它自带的Scale层来改编的。就是this->m_network->addScale(),
    所有要理解scale、batchnormal的底层公式，才能知道它的转你换，具体公式不写了，视频02的20的左右有
    */
    
     //  ..../bn1.weight.wgt
    std::string weightsPath = this->rootPath + weightsName + ".weight.wgt";  
    std::string biasPath = this->rootPath + weightsName + ".bias.wgt";
    std::string meanPath = this->rootPath + weightsName + ".running_mean.wgt";
    std::string varPath = this->rootPath + weightsName + ".running_var.wgt";

    std::vector<float> weights = this->loadWeoghts(weightsPath);
    std::vector<float> bias = this->loadWeoghts(biasPath);
    std::vector<float> mean = this->loadWeoghts(meanPath);
    std::vector<float> var = this->loadWeoghts(varPath);

    int size = bias.size();   // 4个长度都一样，随便拿一个都一样

    std::vector<float> bn_var;  // 因为要用多次，这就单独写出来了
    for (size_t i = 0; i < size; i++) {
        bn_var.push_back(sqrt(var.at(i) + 1e-5));   // +1e-5是为了防止为0，这要后面要作为分母后
    }

    float *shiftWt = new float[size];   // 这是声明数组，必须数组，后面要赋值给别人的
    for (size_t i = 0; i < size; i++) {
        // 这里公式是：shift = b - (mean*w)/sqrt(var+1e-5);所以bn_var这个vector可以不要的，下面直接写的
        shiftWt[i] = bias[i] - ((mean.at(i) * weights.at(i)) / bn_var.at(i));
    }
    float *scaleWt = new float[size];
    float *powerWt = new float[size];
    for(size_t i = 0; i < size; i++) {
        scaleWt[i] = weights.at(i) / bn_var.at(i);   // 公式，上面写了说明了
        powerWt[i] = 1.0;
    }

    nvinfer1::Weights shift{nvinfer1::DataType::kFLOAT, nullptr, size};
    nvinfer1::Weights scale{nvinfer1::DataType::kFLOAT, nullptr, size};
    nvinfer1::Weights power{nvinfer1::DataType::kFLOAT, nullptr, size};
    shift.values = shiftWt;
    scale.values = scaleWt;
    power.values = powerWt;

    // batchnormal有一个通道的选择，因为我们用的scale的api，只是把它的数据改成了batchnormal的数据
    nvinfer1::ScaleMode scaleMode = nvinfer1::ScaleMode::kCHANNEL;
    nvinfer1::IScaleLayer *batchNormal = this->m_network->addScale(*this->Layers[inputLayerName], scaleMode, shift, scale, power);

    this->print_tensor_size("batchnormal", batchNormal->getOutput(0));
    return batchNormal->getOutput(0);
}

nvinfer1::ITensor* tensorRT::trt_activation(std::string inputLayerName, std::string activate_type) {
    // 很多激活类型，就没写完了
    nvinfer1::ActivationType ActivateType;
    if (activate_type == "relu") 
        ActivateType = nvinfer1::ActivationType::kRELU;   // 点进去这个枚举值，有很多
    else if (activate_type == "sigmoid") 
        ActivateType = nvinfer1::ActivationType::kSIGMOID;
    else if (activate_type == "tanh")
         ActivateType = nvinfer1::ActivationType::kTANH;
    else if (activate_type == "elu")
         ActivateType = nvinfer1::ActivationType::kELU;
    else if (activate_type == "l_relu")
         ActivateType = nvinfer1::ActivationType::kLEAKY_RELU;
    else if (activate_type == "clip")
         ActivateType = nvinfer1::ActivationType::kCLIP;
    
    nvinfer1::IActivationLayer *activate = this->m_network->addActivation(*this->Layers[inputLayerName], ActivateType);
    // 比如leak_relu时，要传入一个alpha参数，这就要设置
    if (activate_type == "l_relu") {
        activate->setAlpha(0.001);    // 可设置成类成员变量，传进来
    }
    if (activate_type == "clip") {
        activate->setAlpha(0.1);
        activate->setBeta(0.9);   // 数值我随便给的，去看说明给
    }
    
    this->print_tensor_size(activate_type, activate->getOutput(0));
    return activate->getOutput(0);
}

nvinfer1::ITensor* tensorRT::trt_pool(std::string inputLayerName, std::string pool_type, int kernel, int stride, int padding) {
    nvinfer1::PoolingType PoolType;
    if (pool_type == "max") {
        PoolType = nvinfer1::PoolingType::kMAX;
    }
    else if (pool_type == "average") {
        PoolType = nvinfer1::PoolingType::kAVERAGE;
    }
    nvinfer1::IPoolingLayer *pool = this->m_network->addPooling(*this->Layers[inputLayerName], PoolType, nvinfer1::DimsHW(kernel, kernel));
    pool->setStride(nvinfer1::DimsHW(stride, stride));
    pool->setPadding(nvinfer1::DimsHW(padding, padding));

    this->print_tensor_size(pool_type + "pool", pool->getOutput(0));
    return pool->getOutput(0);
}

nvinfer1::ITensor* tensorRT::trt_calculate(std::string inputLayerName1, std::string inputLayerName2, std::string cal_type) {
    /*
        两个tensor相加也不仅仅是简单的相加，也是搞一个相加层，跟上面的batchnormal、卷积层是一样的
    */
    nvinfer1::ElementWiseOperation CalType;
    if (cal_type == "add") {
        CalType = nvinfer1::ElementWiseOperation::kSUM;
    }
    else if (cal_type == "divide") {
        CalType = nvinfer1::ElementWiseOperation::kDIV;
    }
    else if (cal_type == "multiply") {
        CalType = nvinfer1::ElementWiseOperation::kPROD;   // 两个矩阵相乘
    }
    // 注意下面这个类型(所有这种layer层的类型，前面开头都是I)
    nvinfer1::IElementWiseLayer *eltiswe = this->m_network->addElementWise(*this->Layers[inputLayerName1], *this->Layers[inputLayerName2], CalType);

    this->print_tensor_size(cal_type, eltiswe->getOutput(0));
    return eltiswe->getOutput(0);
}

// fc：全连接
nvinfer1::ITensor* tensorRT::trt_fc(std::string inputLayerName, std::string weightsName, std::string biasName, int out_features) {
    std::vector<float> weights = this->loadWeoghts(this->rootPath + weightsName);
    std::vector<float> bias;
    if (biasName != "") {
        bias = this->loadWeoghts(this->rootPath + biasName);
    }

    unsigned int size = weights.size();
    float *fc_weights = new float[size];
    for (int i = 0; i < size; i++) {
        fc_weights[i] = weights.at(i);
    }

    float *fc_bias = new float[out_features];  // 注意是output_C
    for (int i = 0; i < out_features; i++) {  // 注意这里是：i < output_C 而不是size
        fc_bias[i] = 0.0;  // 相当于给fc_bias中数据初始化
        if (bias.size() != 0) {
            fc_bias[i] = bias.at(i);
        }
    }

    nvinfer1::Weights fc_wt{nvinfer1::DataType::kFLOAT, nullptr, size};
    nvinfer1::Weights fc_bs{nvinfer1::DataType::kFLOAT, nullptr, out_features};
    fc_wt.values = fc_weights;
    fc_bs.values = fc_bias;

    // fc:全连接层
    nvinfer1::IFullyConnectedLayer *fc = this->m_network->addFullyConnected(*this->Layers[inputLayerName], out_features, fc_wt, fc_bs);
    return fc->getOutput(0);
}

nvinfer1::ITensor* tensorRT::trt_matmul(std::string inputLayerName1, std::string inputLayerName2) {
    nvinfer1::MatrixOperation dtype = nvinfer1::MatrixOperation::kNONE;  // 这代表不转置，一把就是把矩阵处理好了再来相乘
    nvinfer1::IMatrixMultiplyLayer *matmul = this->m_network->addMatrixMultiply(*this->Layers[inputLayerName1], dtype, *Layers[inputLayerName2], dtype);
    return matmul->getOutput(0);
}

nvinfer1::ITensor* tensorRT::trt_softmax(std::string inputLayerName, int dim) {
    nvinfer1::ISoftMaxLayer *softmax = this->m_network->addSoftMax(*this->Layers[inputLayerName]);
    return softmax->getOutput(dim);  // dim去看.h的说明
}

nvinfer1::ITensor* tensorRT::trt_concate(std::vector<std::string> inputLayerNames, int axis) {
    int nbinputs = inputLayerNames.size();
    // new一个数组，把数据拿到
    nvinfer1::ITensor* *inputs = new nvinfer1::ITensor* [nbinputs];
    for (int i = 0; i < nbinputs; ++i) {
        inputs[i] = this->Layers[inputLayerNames.at(i)];
    }
    nvinfer1::IConcatenationLayer *concate = this->m_network->addConcatenation(inputs,nbinputs);  // nbinputs就是前面这个inputs数组的长度
    oncate->setAxis(axis);  // 设置哪个维度concate
    return concate->getOutput(0);
}

nvinfer1::ITensor* tensorRT::trt_slice(std::string inputLayerName, std::vector<int> start, std::vector<int> outputSize, std::vector<int> step) {
    nvinfer1::Dims start_dim = nvinfer1::Dims{start[0], start[1], start[2]};
    nvinfer1::Dims output_dim = nvinfer1::Dims{outputSize[0], outputSize[1], outputSize[2]};  // 不能用圆括号初始化
    nvinfer1::Dims step_dim = nvinfer1::Dims{step[0], step[1], step[2]};  
    nvinfer1::ISliceLayer *slice = this->m_network->addSlice(*this->Layers[inputLayerName], start_dim, output_dim, step_dim);
    return slice->getOutput(0);
}

nvinfer1::ITensor* tensorRT::trt_shuffle(std::string inputLayerName, std::vector<int> reshapeSize, std::vector<int> permuteSize) {
    // reshapereshapeSize的vector一般是 {3, 128, 128}这种代表形状的vector,可能是4维的
    // 这是为了rehsape
    int size = reshapeSize.size();
    this->m_shuffle.reshape.nbDims = size;
    for (int i = 0; i < size; ++i) {
        this->m_shuffle.reshape.d[i] = reshapeSize.at(i);
    }
    
    // 这是为了permute
    size = permuteSize.size();
    for (int i = 0; i < size; ++i) {
        this->m_shuffle.permute.order[i] = permuteSize.at(i);
    }
    
    nvinfer1::IShuffleLayer *shuffle = this->m_network->addShuffle(*Layers[inputLayerName]);
    
    // 这三个值我只是暂时都初始化为true，真实用的时候一般取一种就行，会用就好
    bool only_reshape = true, only_permute = true, both = true;
    if (only_reshape) 
        shuffle->setReshapeDimensions(this->m_shuffle.reshape);
    if (only_permute)
        shuffle->setFirstTranspose(m_shuffle.permute);
    if (both) {
        // 两种操作都做的话，就要决定先reshape还是先transpose
        bool reshape_first = true;
        if (reshape_first) {
            shuffle->setReshapeDimensions(m_shuffle.reshape);
            shuffle->setSecondTranspose(m_shuffle.permute);
        }
        else {
            shuffle->setFirstTranspose(m_shuffle.permute);
            shuffle->setReshapeDimensions(m_shuffle.reshape);
        }
    }
    return shuffle->getOutput(0);
}

nvinfer1::ITensor* tensorRT::trt_constant(std::vector<int> dimensions, float alpha) {
    int all = 1;
    nvinfer1::Dims Dims;
    Dims.nbDims = dimensions.size();
    for (int i = 0; i < dimensions.size(); ++i) {
        all *= i;  // 这写的有点问题吧，一开始i为0，*=不就一直为0了
        Dims.d[i] = dimensions.at(i);
    }

    nvinfer1::Weights weights{nvinfer1::DataType::kFLOAT, nullptr, all};
    float *val = new float[all];
    for (int i = 0; i < all; ++i) {
        val[i] = alpha;
    }
    weights.values = val;
    nvinfer1::IConstantLayer *constant = this->m_network->addConstant(Dims, weights);
    return constant->getOutput(0);
}
```

#### 3.2.3 main.cpp主函数

```c++
#include <iostream>
#include <NvInfer.h>
#include <driver_types.h>  // cudaError_t 需要(似乎只要下面这个)，，还要cudart.lib 
#include <cuda_runtime_api.h>  // cudaGetDeviceCount 需要，，还要 cudart.lib

#include "tensorrt.h"

int main() {
    int cudaNum = 0;
    cudaError_t error = cudaGetDeviceCount(&cudaNum);
    if (cudaSuccess != error) return 0;
    if (cudaNum <= 0) return 0;
    int idx = 0;
    if (cudaNum > 1) {
        std::cout << "please choose the GPU idnex: " << std::endl;
        std::cin >> idx;
        if (idx >= cudaNum)
            idx = cudaNum - 1;
        else if (idx < 0)
            idx = 0;
    }
    cudaSetDevice(idx);
    cudaFree(nullptr);

    // 构建.engine
    tensorRT *trt = new tensorRT();
    trt->createENG("E:/project/Pycharm_project/trt_study/resnet18.engine");

    std::cout << "Hello World!" << std::endl;
    return 0;
}
```

注：根据以上的步骤，是肯定可以构建.engine引擎文件的，是绝对能编译成功，运行出结果的。

### 3.3. 推理阶段

#### 3.3.1 单个输出

1. 首先在tensorrt.h的tensorRT类中将推理相关的函数和成员属性定义一下：

   ```c++
   class tensorRT {
   public:
   	/*.........*/
    // 下面开始推理的代码部分
       void Inference_init(const std::string &engPath, int batchsize);
   
       void doInference(const float *input, int batchsize, float *output);
   
   
       nvinfer1::ICudaEngine *engine;  // 定义在这，方便释放，感觉好像不用释放
   
       int inputSize = 3 * 256 * 256;   // 还没管batchsize，前面定义的图片的大小
       int outputSize = 1000;   // 1000*1*1
       int inputIdx, outputIdx;
       std::vector<void *> m_bindings;  // 说是所有的输入输出都会放这里面
       nvinfer1::IExecutionContext *m_context;   // 一直要用的上下文
       cudaStream_t m_cudaStream;
   };
   ```

2. 上面定义的函数的实现(这里面才是相当重要的)，在tensorrt.cpp:

   ```c++
   void tensorRT::Inference_init(const std::string &engPath, int batchsize) {
       // 就是读二进制文件
       std::ifstream cache(engPath, std::ios::binary);
       cache.seekg(0, std::ifstream::end);   // std::ios::end  把流整到末尾去了(用std::ios::ate | std::ios::binary 的方式打开，指针直接就在流尾部了)
       const int engSize = cache.tellg();   // 移动到末尾，然后tellg()告诉位置就知道大小了
       // std::ifstream::pos_type mark = cache.tellg();  // (int)mark是等于engSize的
   
       // 知道大小后就移动回流开始的位置
       cache.seekg(0, std::ios::beg);  // 也有看到写 cache.beg、cache.end 这种，一个意思
   
       void *modelMem = malloc(engSize);
       cache.read((char *)modelMem, engSize);  // 等下打印看看  engSize 、 mark 、 sizeof()
       cache.close();
   
   
       // 上面创建引擎是是build，要推理就要runtime
       nvinfer1::IRuntime *runtime = nvinfer1::createInferRuntime(this->m_logger);
       // 反序列化出来，因为没有自定义plugin层，所以第三个参数是nullptr
       this->engine = runtime->deserializeCudaEngine(modelMem, engSize, nullptr);
       // 说是以上就把引擎反序列化到GPU里面，然后就可以释放了
       runtime->destroy();
       free(modelMem);
       if (!engine) return;
   
       // 反序列化后，就要 malloc 输出输出空间
       this->m_context = engine->createExecutionContext();
   	
       // 这其实也是在初始化his->m_cudaStream，同时加的判断，没有这个就不行
       if (cudaStreamCreate(&this->m_cudaStream) != 0) return;   
   
       int bindings = engine->getNbBindings();
       this->m_bindings.resize(bindings, nullptr);   // 初始化这个vector
   
       this->inputIdx = engine->getBindingIndex("data");   // 前面创建引擎时标记的“data”
       // cudaMalloc需要头文件 <cuda_runtime_api.h>
       int flag = cudaMalloc(&this->m_bindings.at(inputIdx), batchsize * this->inputSize * sizeof(float));   // 注意这分配空间的大小
       if (flag != 0) {
           std::cout << "malloc error!" <<std::endl;
           return;
       }
       this->outputIdx = engine->getBindingIndex("output");  // 创建.engine文件最后也是标记了输出为output
       flag = cudaMalloc(&this->m_bindings.at(outputIdx), batchsize * this->outputSize * sizeof(float));
       if (flag != 0) {
           std::cout << "malloc error!" <<std::endl;
           return;
       }
   }
   
   void tensorRT::doInference(const float *input, int batchsize, float *output) {
       int flag;
       // 1.0把input拷贝到m_binding指定的位置，cudaMemcpyHostToDevice代表内存到显存，最后一个是固定需要的
       flag = cudaMemcpyAsync(this->m_bindings.at(this->inputIdx), input, batchsize*this->inputSize*sizeof(float), cudaMemcpyHostToDevice,this->m_cudaStream);
       if (flag != 0) {
           std::cout << "input copy to cuda error!" << std::endl;
           return;
       }
   
       // 2.0定义的上下文开始推理，并把结果存到m_binding指定位置
       // a_vector.data() 得到的首地址，等同于 &(*a_vec.begin())
       this->m_context->enqueue(batchsize, this->m_bindings.data(), this->m_cudaStream, nullptr);
   
       // 3.0再把结果从显存拷贝回内存里
       flag = cudaMemcpyAsync(output, this->m_bindings.at(this->outputIdx), batchsize*this->outputSize*sizeof(float), cudaMemcpyDeviceToHost, this->m_cudaStream);
       if (flag != 0) {
           std::cout << "output copy to mem error!" << std::endl;
           return;
       }
   
       cudaStreamSynchronize(this->m_cudaStream);  // 进程跑起来就行了
   }
   
   // 析构函数释放资源
   tensorRT::~tensorRT() {
       if (this->m_context) {
           m_context->destroy();
           m_context = nullptr;
       }
       if (this->engine) {
           engine->destroy();
           engine = nullptr;
       }
       for (auto bindings : this->m_bindings) {
           cudaFree(bindings);
       }
   }
   ```
   
3. 在main.cpp中：(需要opencv的库，记得其.dll文件路径要添加到环境变量，对应的.pro也要去设置头文件、库文件路径)

   ```c++
   /*...*/
   #include <opencv2/core/core.hpp>
   #include <opencv2/dnn/dnn.hpp>
   #include <opencv2/imgcodecs/imgcodecs.hpp>
   #include <opencv2/imgproc/imgproc.hpp>
   
   int main() {
   	/*.....*/
   	tensorRT *trt = new tensorRT();
   	// 生成一次就可以了
       // trt->createENG("E:/project/Pycharm_project/trt_study/resnet18.engine");
   
       trt->Inference_init("E:/project/Pycharm_project/trt_study/resnet18.engine", 10);
   	
   	// 下面是将一张图片
       cv::Mat image = cv::imread("E:/project/Pycharm_project/trt_study/1.jpg");
       cv::Mat blob = cv::dnn::blobFromImage(image, 1.0, cv::Size(256, 256), cv::Scalar(127.0, 127.0, 127.0), true, false);
       float *input = new float[1*3*256*256];   // 输入一张图
       memcpy(input, blob.data, 1*3*256*256*sizeof(float));
   
       float *output = new float[1*1000*1*1];
       trt->doInference(input, 1, output);
       for (int i = 0; i < 1000; i++) {
           std::cout << i << ": " << output[i] << std::endl;
       }
   	/*
   	这个输出效果和Python的网络输出效果来对比，几乎结果是一样的，Python代码
       model = torchvision.models.resnet18(pretrained=False)
       model.load_state_dict(torch.load("./resnet18.pth"))
       model.cuda()
       model.eval()
   
       image = cv2.imread("./1.jpg")
       blob = cv2.dnn.blobFromImage(image, 1.0, (256, 256), (127.0, 127.0, 127.0), True, False)
       input_data = torch.Tensor(blob).cuda()
   
       output = model(input_data)
       print(output)
   	*/
   
       return 0;
   }
   ```

#### 3.3.2 多个输出

​	在3.3.1来说，整个网络就是输出了一个结果，相当于输出了一个类别，但是很多时候还要输出目标的坐标位置，就不止一个，那就要改进,结合3.3.1来看，只在部分函数上做了修改；

1. 在函数 void tensorRT::createENG(std::string engPath) 中添加如下几行，重新生成.engine文件：

   ```c++
       // 新增的一个输出output1(随便写，这里就是把输出层relu了一下作为新的输出)
       this->Layers["relu_eng"] = this->trt_activation("fc", "relu");
       this->Layers["relu_eng"]->setName("output1");  // 注意名字和上面的区分开
       this->m_network->markOutput(*this->Layers["relu_eng"]);
   ```

2. 在tensorrt.h中增加一些属性和函数：

   ```c++
   class tensorRT {
   public:
       /*.......................*/
       // 下面是两个输出
       int outputs[2] = {1000, 1000};  // 输出size不同就改这里
       std::vector<int> outputIndexs;
   
       int alloutputsize = 2000;  // 把所有输出总量1000+1000这里写下，方便整个开辟空间
       void *temp;  // 用来存临时变量的
       // 两个(可拓展为多个)输出
       void doInferences_two(const float *input, int batchsize, float *output);
   };
   ```

3. 推理时，引擎初始化要修改：

   ```c++
   void tensorRT::Inference_init(const std::string &engPath, int batchsize) {
   	/*..................*/
       /*
       这是单个输出的代码：
       this->outputIdx = engine->getBindingIndex("output");  // 创建.engine文件最后也是标记了输出为output
       flag = cudaMalloc(&this->m_bindings.at(outputIdx), batchsize * this->outputSize * sizeof(float));
       if (flag != 0) {
           std::cout << "malloc error!" <<std::endl;
           return;
       }
       */
       // 两输出，那就申请两个空间
       this->outputIndexs.push_back(engine->getBindingIndex("output"));
       this->outputIndexs.push_back(engine->getBindingIndex("output1"));
       for (int i =0; i < this->outputIndexs.size(); i++) {
           cudaMalloc(&this->m_bindings.at(this->outputIndexs.at(i)), batchsize * this->outputSize * sizeof(float));
       }
       // 一定要这行，把整个输出都这样开辟一下空间，上面的也不能省
       cudaMalloc(&this->temp, batchsize*this->alloutputsize*sizeof(float));
   }
   ```

4. void doInferences_two(const float *input, int batchsize, float *output) 函数实现：

   ```c++
   void tensorRT::doInferences_two(const float *input, int batchsize, float *output) {
       int flag;
       // 把input拷贝到m_binding指定的位置，cudaMemcpyHostToDevice代表内存到显存，最后一个是固定需要的
       flag = cudaMemcpyAsync(this->m_bindings.at(this->inputIdx), input, batchsize*this->inputSize*sizeof(float), cudaMemcpyHostToDevice,this->m_cudaStream);
       if (flag != 0) {
           std::cout << "input copy to cuda error!" << std::endl;
           return;
       }
   
       // 定义的上下文开始推理，并把结果存到m_binding指定位置
       // a_vector.data() 得到的首地址，等同于 &(*a_vec.begin())
       this->m_context->enqueue(batchsize, this->m_bindings.data(), this->m_cudaStream, nullptr);
   
       /**** 以上跟单个输出是一样的 *************/
       // 因为有两个输出了不能直接 cudaMemcpyHostToDevice 要搞个临时变量this->temp来存
       int outNum = 0;
       int allNum = this->m_bindings.size();  // 这里面有输入、所有输出
       // 从1开始，是因为[0]是input的data
       for (int i = 1; i < allNum; i++) {
           // 注意，这里还是DeviceToDevice，是在显存里操作，
           cudaMemcpyAsync((float*)this->temp + batchsize*outNum, this->m_bindings.at(this->outputIndexs[i-1]), batchsize*this->outputs[i-1]*sizeof(float), cudaMemcpyDeviceToDevice, this->m_cudaStream);
           outNum += this->outputs[i-1];
       }
       flag = cudaMemcpyAsync(output, this->temp, batchsize*outNum*sizeof (float), cudaMemcpyDeviceToHost, this->m_cudaStream);
   
       if (flag != 0) {
           std::cout << "output copy to mem error!" << std::endl;
           return;
       }
       cudaStreamSynchronize(this->m_cudaStream);
   }
   ```

### 3.4. int8精度校准

有两种方式：

1. 在构建trt网络时，通过最初的神经网络权重计算好校准值，不需要生成校准表（教程说没用过这）
2. 在tensorRT中通过继承重写类nvinfer1::IInt8Calibrator(类名千万别错了)，实现生成int8校准表（用这）

然后原理我就不咋写了，好像代码是比较固定的，可以直接掏出来合着上面用。

- calibrator.h：

  ```c++
  #ifndef CALIBRATOR_H
  #define CALIBRATOR_H
  #include <NvInfer.h>
  #include <string>
  #include <vector>
  
  class Calibrator : public nvinfer1::IInt8EntropyCalibrator {
  public:
      Calibrator(const unsigned int &batchsize,
                 const std::string &caliTxt,
                 const std::string &calibratorPath,
                 const uint64_t &inputSize,
                 const unsigned int &inputH,
                 const unsigned int &inputW,
                 const std::string &inputName);
      int getBatchSize() const override;
      bool getBatch(void* bindings[], const char* names[], int nbBindings) override;
      const void* readCalibrationCache(size_t &length) override;
      void writeCalibrationCache(const void* ptr, std::size_t length) override;
  
  private:
      unsigned int m_batchsize;
      const unsigned int m_inputH;
      const unsigned int m_inputW;
      const uint64_t m_inputSize;
      const uint64_t m_inputCount;
      const char* m_inputName;
      const std::string m_calibratorPath{nullptr};
      std::vector<std::string> m_ImageList;
      void *m_cudaInput{nullptr};
      std::vector<char> m_calibrationCache;
      unsigned int m_ImageIndex;
  };
  #endif // CALIBRATOR_H
  ```

- calibrator.cpp：

  ```c++
  #include "calibrator.h"
  #include <fstream>
  #include <iostream>
  #include <cuda_runtime_api.h>
  #include <opencv2/opencv.hpp>
  
  // 把存有每张图片的txt加载，得到一个vector
  // imgTxt是一个txt文本路径，里面放的校准图片的路径，示例在下面的“注”的第一点
  std::vector<std::string> loadImage(const std::string &imgTxt) {
      std::vector<std::string> imgInfo;
      FILE *f = fopen(imgTxt.c_str(), "r");
      if (!f) {
          perror("Error");
          std::cout << "cant open file" << std::endl;
          return imgInfo;
      }
      char str[512];
      while (fgets(str, 512, f) != NULL) {
          for (int i = 0; str[i] != '\0'; ++i) {
              if (str[i] == '\r') {str[i] = '\0';}
              if (str[i] == '\n') {str[i] = '\0'; break;}
          }
          imgInfo.push_back(str);
      }
      fclose(f);
      return imgInfo;
  }
  
  
  
  Calibrator::Calibrator(const unsigned int &batchsize,
                         const std::string &caliTxt,
                         const std::string &calibratorPath,
                         const uint64_t &inputSize,
                         const unsigned int &inputH,
                         const unsigned int &inputW,
                         const std::string &inputName) : m_batchsize(batchsize),
                                                         m_inputH(inputH),
                                                         m_inputW(inputW),
                                                         m_inputSize(inputSize),
                                                         m_inputCount(batchsize * inputSize),
                                                         m_inputName(inputName.c_str()),
                                                         m_calibratorPath(calibratorPath),
                                                         m_ImageIndex(0) {
      this->m_ImageList = loadImage(caliTxt);
      cudaMalloc(&this->m_cudaInput, this->m_inputCount * sizeof (float));
  }
  
  
  int Calibrator::getBatchSize() const {
      return this->m_batchsize;
  }
  
  bool Calibrator::getBatch(void **bindings, const char **names, int nbBindings) {
      if (this->m_ImageIndex + this->m_batchsize > this->m_ImageList.size()) return false;
      std::cout << this->m_batchsize <<std::endl;
      std::vector<cv::Mat> inputImages;
      for (unsigned int i = this->m_ImageIndex; i < m_ImageIndex+this->m_batchsize; i++) {
          std::string imgPath = this->m_ImageList.at(i);
          std::cout << imgPath << std::endl;
          cv::Mat temp = cv::imread(imgPath);
          if (temp.empty()) {
              std::cout << "img read error!" << std::endl;
          }
          inputImages.push_back(temp);
      }
      this->m_ImageIndex += this->m_batchsize;
      cv::Mat trtInput = cv::dnn::blobFromImages(inputImages, 1.0, cv::Size(m_inputH, m_inputW), cv::Scalar(127.0, 127.0, 127.0), true, false);
  
      cudaMemcpy(m_cudaInput, trtInput.ptr<float>(0), m_inputCount*sizeof (float), cudaMemcpyHostToDevice);
      bindings[0] = m_cudaInput;
      return true;
  }
  
  const void* Calibrator::readCalibrationCache(size_t &length) {
      // 如果有校准表就读取拿到，没有就返回一个空的指针(else中)，后续去创建
      void *output;
      this->m_calibrationCache.clear();
      std::ifstream input(this->m_calibratorPath, std::ios::binary);
      input >> std::noskipws;
      if (input.good()) {
          std::copy(std::istream_iterator<char>(input), std::istream_iterator<char>(), std::back_inserter(this->m_calibrationCache));
      }
      length = this->m_calibrationCache.size();  // 修改了传入的参数
      if (length) {
          std::cout << "using cached calibration table to build the engine" << std::endl;
          output = &this->m_calibrationCache.at(0);
      }
      else {
          std::cout << "New  calibration table will be created to build the engine" << std::endl;
          output = nullptr;
      }
      return output;
  }
  
  void Calibrator::writeCalibrationCache(const void *ptr, std::size_t length) {
      // ptr说是tensorrt中自己会去计算，因为这里有继承嘛
      assert(!this->m_calibratorPath.empty());
      std::cout << "length =  " << length << std::endl;
      std::ofstream output(this->m_calibratorPath, std::ios::binary);
      output.write(reinterpret_cast<const char*>(ptr), length);
      output.close();
  }
  ```

- 在tensorrt.cpp中引入这个头文件，在创建.engine文件是，看是否使用int

  ```c++
  void tensorRT::createENG(std::string engPath) {
      /*.....................................*/
  	// 是否用int8
  	this->isInt8 = true;  // 没在构造函数时初始化了，这里手动初始化下
      if (this->isInt8) {
          const std::string caliTxt = "E:/project/Pycharm_project/trt_study/int8_pic/calibration.txt";
          const std::string int8cali_table = "E:/project/Pycharm_project/trt_study/int8_pic/int8cal.table";
  
          Calibrator *m_calbrator = new Calibrator(1, caliTxt, int8cali_table, 3*256*256, 256, 256, "data");  // 这个"data"是上面写定了的
          builder->setInt8Mode(true);
          builder->setInt8Calibrator(m_calbrator);
      }
  }
  ```

  注：

  - calibration.txt：这是自己写的里面的格式如下：一般校准是用自己的数据集的几千张来做的。

    ```txt
    E:/project/Pycharm_project/trt_study/int8_pic/1.jpg
    E:/project/Pycharm_project/trt_study/int8_pic/4.jpg
    E:/project/Pycharm_project/trt_study/int8_pic/5.jpg
    E:/project/Pycharm_project/trt_study/int8_pic/6.jpg
    ```

  - int8cal.table：这是程序运行生成的校准表，第一次运行生成。（记事本可打开）

- 最后一步，在main函数中执行创造.engine的函数，设成int8的引擎文件。

### 3.5. plugin层实现

这是解决没有的算子，尽量不自己写，自定义层加了速度可能会变慢(因为我们写的不好)，尽量用已有的层去改造变量的方式

- 添加lib：-L'E:\lib\TensorRT-7.2.3.4.Windows10.x86_64.cuda-10.2.cudnn8.1\lib' nvinfer.lib nvifer_plugin.lib   # 主要是需要 nvifer_plugin.lib

只能说放这里吧，代码有问题，跑不起来，主要是m_pluginfactory.h有问题，代码比这视频写的，但是有明显的报错，继承了太多次，我也看不明白了,是以l-relu来作为示例的

放这里吧，以后如果再看这个视频，来这里复制：

1. trt_demo.pro

   ```properties
   TEMPLATE = app
   CONFIG += console c++11
   CONFIG -= app_bundle
   CONFIG -= qt
   
   win32 {
       INCLUDEPATH += \
           'E:\lib\TensorRT-7.2.3.4.Windows10.x86_64.cuda-10.2.cudnn8.1\include' \
           'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.2\include' \
           'E:\lib\opencv\build\include'
   }
   
   win32 {
       LIBS += \
           -L'E:\lib\TensorRT-7.2.3.4.Windows10.x86_64.cuda-10.2.cudnn8.1\lib' nvinfer.lib nvifer_plugin.lib \
           -L'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.2\lib\x64' cudart.lib \
           -L'E:\lib\opencv\build\x64\vc15\lib' opencv_world440d.lib
   }
   
   
   
   SOURCES += \
           main.cpp \
       tensorrt.cpp \
       calibrator.cpp \
       m_lrelu.cpp
   
   HEADERS += \
       tensorrt.h \
       calibrator.h \
       m_lrelu.h \
       m_pluginfactory.h
   
   CUDA_SOURCES += \
       m_lrelu.cu             # 在gpu上的操作写到这个文件里
   
   # qt要写cu文件，需要下面的这些
   
   
   win32 {
       SYSTEM_NAME = x64
       SYSTEM_TYPE = 64
       CUDA_ARCH = compute_35
       CUDA_CODE = sm_35      # 说些根据GPU显卡型号来写
       CUDA_INC = $$join(INCLUDEPATH, '" -I"','-I"','"')
       MSVCRT_LINK_FLAG_DEBUG = "/MDd"
       MSVCRT_LINK_FLAG_RELEASE = "/MD"
       # Configuration of the Cuda compiler
       CONFIG(debug, debug|release) {
           # Debug mode
           cuda.input = CUDA_SOURCES
           cuda.output = $$OBJECTS_DIR/${QMAKE_FILE_BASE}_cuda.obj
           cuda.commands = C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v10.2/bin/nvcc.exe -D_DEBUG -Xcompiler $$MSVCRT_LINK_FLAG_DEBUG -c -Xcompiler $$join(QMAKE_CXXFLAGS,",") $$join(INCLUDEPATH,'" -I "', '-I "', '"') ${QMAKE_FILE_NAME} -o ${QMAKE_FILE_OUT}
       } else {
           # Release mode
           cuda.input = CUDA_SOURCES
           cuda.output = $$OBJECTS_DIR/${QMAKE_FILE_BASE}_cuda.obj
           cuda.commands = C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v10.2/bin/nvcc.exe -Xcompiler $$MSVCRT_LINK_FLAG_RELEASE -c -Xcompiler $$join(QMAKE_CXXFLAGS,",") $$join(INCLUDEPATH,'" -I "', '-I "', '"') ${QMAKE_FILE_NAME} -o ${QMAKE_FILE_OUT}
       }
   
   }
   ```

2. m_lrelu.h 

   ```c++
   #ifndef M_LRELU_H
   #define M_LRELU_H
   
   #include <NvInfer.h>
   #include <cuda_runtime_api.h>
   #include <iostream>
   #include <assert.h>
   
   namespace nvinfer1 {
   // 需要继承这个类来写
   class m_Lrelu : public nvinfer1::IPluginExt {
   public:
       explicit m_Lrelu(const float alpha, const int cudaThread, DataType type);
       m_Lrelu(const void* buffer, size_t size);
       ~m_Lrelu() override;
   
       int getNbOutputs() const override;
       Dims getOutputDimensions(int index, const Dims *inputs, int nbInputDims) override;
       bool supportsFormat(DataType type, PluginFormat format) const override;
       void configureWithFormat(const Dims *inputDims, int nbInputs, const Dims *outputDims, int nbOutputs, DataType type, PluginFormat format, int maxBatchSize) override;
       int initialize() override;
       size_t getWorkspaceSize(int maxBatchSize) const override;
       // 推理的时候主要是自动调用这个函数
       int enqueue(int batchSize, const void* const* inputs, void** outputs, void* workspace, cudaStream_t stream) override;
       size_t getSerializationSize() override;
       void serialize(void* buffer) override;
       void terminate() override;
   
       void lReluForward(const int n, const float *input, float *output, const float alpha);
   
   private:
       float m_alpha;
       int m_ThreadCount;
       nvinfer1::Dims m_CHW;
       int m_C;
       int m_H;
       int m_W;
       int m_inputSize;
       DataType m_dataType;
   };
   
   }
   
   #endif // M_LRELU_H
   ```

3. m_lrelu.cpp

   ```c++
   #include "m_lrelu.h"
   
   namespace nvinfer1 {
   
   template<typename T>
   void read(const char* &buffer, T &val) {
       val = *reinterpret_cast<const T*>(buffer);
       buffer += sizeof(T);
   }
   
   template<typename T>
   void write(char* &buffer, const T &val) {
       *reinterpret_cast<T*>(buffer) = val;
       buffer += sizeof(T);
   }
   
   m_Lrelu::m_Lrelu(const float alpha, const int cudaThread, DataType type)
       : m_alpha(alpha), m_ThreadCount(cudaThread), m_dataType(type) { }
   
   m_Lrelu::m_Lrelu(const void* buffer, size_t size) {
       const char *d = reinterpret_cast<const char*>(buffer), *a = d;
       read(d, m_alpha);
       read(d, m_CHW);
       read(d, m_C);
       read(d, m_H);
       read(d, m_W);
       read(d, m_inputSize);
       read(d, m_dataType);
       read(d, m_ThreadCount);
   
       assert(d == a + size);
   }
   
   m_Lrelu::~m_Lrelu() {}
   
   int m_Lrelu::getNbOutputs() const {
       return 1;
   }
   
   Dims m_Lrelu::getOutputDimensions(int index, const Dims *inputs, int nbInputDims) {
       this->m_CHW = inputs[0];  // 相当于拿的第一个数据，n是1
       this->m_C = m_CHW.d[0];
       this->m_H = m_CHW.d[1];
       this->m_W = m_CHW.d[2];
       this->m_inputSize = m_C * m_H * m_W;
       return Dims3(m_C, m_H, m_W);
   }
   
   bool m_Lrelu::supportsFormat(DataType type, PluginFormat format) const {
       return (type == DataType::kFLOAT || type == DataType::kHALF || type == DataType::kINT8)
               && format == PluginFormat::kNCHW;
   }
   
   
   void m_Lrelu::configureWithFormat(const Dims *inputDims, int nbInputs, const Dims *outputDims, int nbOutputs, DataType type, PluginFormat format, int maxBatchSize) {
       assert((type == DataType::kFLOAT || type == DataType::kHALF || type == DataType::kINT8)
              && format == PluginFormat::kNCHW);
   }
   
   // 继承的虚函数没用到，就把重载写这里，但其实没有任何功能实现
   int m_Lrelu::initialize() {return 0;}  // 在getOutputDimensions函数里已经写了，也可以把那里面的初始化代码放这里
   void m_Lrelu::terminate() {}
   size_t m_Lrelu::getWorkspaceSize(int maxBatchSize) const {return 0;}
   
   size_t m_Lrelu::getSerializationSize() {
       return sizeof(m_alpha) + sizeof(m_CHW) + sizeof(m_C) + sizeof(m_H) + sizeof(m_W) + sizeof(m_inputSize) + sizeof(m_dataType) + sizeof(m_ThreadCount);
   }
   void m_Lrelu::serialize(void *buffer) {
       char *d = static_cast<char*>(buffer), *a = d;
       write(d, m_alpha);
       write(d, m_CHW);
       write(d, m_C);
       write(d, m_H);
       write(d, m_W);
       write(d, m_inputSize);
       write(d, m_dataType);
       write(d, m_ThreadCount);
   
       assert(d == a + this->getSerializationSize());
   }
   
   // 这是要调用GPU的
   int m_Lrelu::enqueue(int batchSize, const void *const *inputs, void **outputs, void *workspace, cudaStream_t stream) {
       const int count = batchSize * m_inputSize;
       const float *input_data = reinterpret_cast<const float*>(inputs[0]);
       float *output_data = reinterpret_cast<float*>(outputs[0]);
       this->lReluForward(count, input_data, output_data, this->m_alpha);  // 这应该是父类中的函数
       return 0;
   }
   ```

4. m_pluginfactory.h  # 报错的意思是说 createPlugin 函数找不到其要重写的版本，这里被编译器当做了声明，说是有override就是错的

   ```c++
   #ifndef M_PLUGINFACTORY_H
   #define M_PLUGINFACTORY_H
   
   #include <NvInfer.h>
   #include <NvInferPlugin.h>
   #include "m_lrelu.h"
   #include <memory>
   #include <vector>
   #include <iostream>
   
   
   using namespace std;
   using nvinfer1::plugin::INvPlugin;
   using nvinfer1::m_Lrelu;
   
   class m_pluginFactory : public nvinfer1::IPluginFactory {
       // 这的nvinfer1这个namespace是自己头文件里定义的
       nvinfer1::m_Lrelu* createPlugin(const char* layerName, const void* serialData, size_t serialLength) ovverride {
           m_Lrelu_Layers.emplace_back(std::unique_ptr<nvinfer1::m_Lrelu>(new nvinfer1::m_Lrelu(serialData, serialLength)));
           return m_Lrelu_Layers.back().get();
       }
   
       void destroyPlugin() {
           for (auto &item: m_Lrelu_Layers) {
               item.reset();
           }
       }
   
       std::vector<std::unique_ptr<nvinfer1::m_Lrelu> > m_Lrelu_Layers{};
   };
   
   #endif // M_PLUGINFACTORY_H
   ```

5. 然后就要在tensorrt.cpp中实现l-relu的层

   ```c++
   #include "m_lrelu.h"
   #include "m_pluginfactory.h"
   /*.....*/
   // leak_relu层的实现
   	nvinfer1::ITensor* tensorRT::trt_Lrelu(std::string inputLayerName, const float alpha) {
       nvinfer1::DataType dtype = nvinfer1::DataType::kFLOAT;  // 说是如果用的int8，它会自己转过去
       nvinfer1::IPluginExt *lrelu = new nvinfer1::m_Lrelu(alpha, 512, dtype);  // 这里的nvinfer1是自己头文件里的命令空间
       // 添加plugin层时，注意这里使用的类型和函数名，注意第一个参数是取地址，和上面解引用有些不同
       nvinfer1::IPluginLayer *m_lrelu = this->m_network->addPluginExt(&this->Layers[inputLayerName], 1, *lrelu);
       return m_lrelu->getOutput(0);
   }
   ```

   然后在 tensorRT::Inference_init 函数中加入：

   ```c++
   	// 反序列化出来，因为没有自定义层，所以第三个参数是nullptr  （这是没加入plugin层的时候）
   	//this->engine = runtime->deserializeCudaEngine(modelMem, engSize, nullptr);
   	// 加入自己的 plugin层
       nvinfer1::IPluginFactory *m_plugin = new m_pluginFactory();
       this->engine = runtime->deserializeCudaEngine(modelMem, engSize, m_plugin);  // 第三个参数就加入plugin层
   ```

6. m_lrelu.cu里的代码

   ```c++
   #include "m_lrelu.h"
   
   #define CUDA_KERNEL_LOOP(i,n) for(size_t i = blockIdx.x*blockDim.x + threadIdx.x; i < (n); i += blockDim.x*gridDim.x)
   
   namespace nvinfer1 {
   
   __global__ void lRelu(const int n, const float *input, float *output, const float alpha) {
       CUDA_KERNEL_LOOP(index, n) {
           // leak_relu 的 算法
           output[index] = input[index] > 0 ? input[index] : input[index] * alpha;
       }
   }
   
   void m_Lrelu::lReluForward(const int n, const float *input, float *output, const float alpha) {
       //  说是带有线程那部分说是让所有线程都不会闲的
       lRelu<<<(n + m_ThreadCount - 1) / m_ThreadCount, m_ThreadCount>>>(n, input, output, alpha);
   }
   }
   ```

7. 最终去main.cpp中编译重新生成.engine和使用。

## 四、总结

​	用到的机会应该也不大，我会去跟着写一下yolov5的tensorrt,然后这次学习的视频和相应的文件，代码，模型都放到阿里云盘上，万一以后用到就作为参考吧。

## 五、yolov5-tensorrt

​	可用pycharm本地加载yolov5的模型(需要yolov5源码中的“models”、“utils”模块)，然后debug“gen_wts.py”这个文件，就能很好的看到它的整个结构，写model.cpp就会清晰很多。

主要是几个API随着版本的更新，我放这里：

主要是model.cpp中：

> /*
>
> 要理解yolov5的一个结构，才能更好的理解网络结构代码，参看这篇博客：
>
> https://blog.csdn.net/wq_0708/article/details/121472274
>
> ---
>
> ==addConvolutionNd 和 addConvolution的区别==, chatGPT的回答: (还有pool带Nd的)
>
>   addConvolutionNd支持任意维度的卷积，而addConvolution只支持二维卷积。
>
>   addConvolutionNd可以设置更丰富的卷积参数，如卷积核大小、步长、填充大小等，而addConvolution只能设置卷积核大小、步长和填充大小。
>
>   addConvolutionNd可以设置更多的卷积选项，如dilation、groups、bias等，而addConvolution只支持bias选项。
>
>   因此，如果需要进行多维卷积或者设置更丰富的卷积参数和选项，就可以使用addConvolutionNd。如果只需要进行二维卷积且不需要设置太多参数和选项，就可以使用addConvolution。
>
> ---
>
> TensorRT中的==createNetwork和createNetworkV2==都是创建网络的函数，区别在于：
>
>   createNetwork是TensorRT 5及之前版本使用的函数，而createNetworkV2是从TensorRT 6开始使用的新函数。
>
>   createNetwork只能创建一个网络，而createNetworkV2可以创建多个网络，这样可以更好地支持多个网络之间的共享层。
>
>   createNetworkV2可以设置更多的网络选项，如设置网络运行的最大批量大小，设置网络是否支持动态批量大小等。
>
>   createNetworkV2在API设计上更加清晰和简洁，方法和参数命名更加一致和简单。
>
>   因此，如果使用TensorRT 5及之前版本，可以使用createNetwork来创建网络。如果使用TensorRT 6及之后版本，推荐使用createNetworkV2来创建网络，因为它支持更多的功能和选项，更加灵活和方便。
>
> */



