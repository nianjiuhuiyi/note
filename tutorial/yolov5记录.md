下面都是用服务器的两张2080Ti来说的。

检测到底需要多少数据的一个[说明](https://blog.51cto.com/u_15279692/5755788)，里面有一点总结:==用于训练的最少图像数据量在150-500；==。yolov5中的readme去看看，它里面关于数据的多少也有建议,如下：

> Images per class. ≥ 1500 images per class recommended
> Instances per class. ≥ 10000 instances (labeled objects) per class recommended
> Image variety. Must be representative of deployed environment. For real-world use cases we recommend images from different times of day, different seasons, different weather, different lighting, different angles, different sources (scraped online, collected locally, different cameras) etc.
> Label consistency. All instances of all classes in all images must be labelled. Partial labelling will not work.
> Label accuracy. Labels must closely enclose each object. No space should exist between an object and it's bounding box. No objects should be missing a label.
> Label verification. View train_batch*.jpg on train start to verify your labels appear correct, i.e. see example mosaic.
> Background images. Background images are images with no objects that are added to a dataset to reduce False Positives (FP). We recommend about 0-10% background images to help reduce FPs (COCO has 1000 background images for reference, 1% of the total). No labels are required for background images.

## 一、训练脚本

检测：./train_m6.sh

```shell
#!/usr/bin/env bash
source /root/anaconda3/bin/activate s_yolov5

# 下面都是按照默认的 batch-size = 16 来说的，我没去改


# yolov5l6.pt、yolov5m6.pt 是从官网下载的预训练权重文件
exec python train.py --img 1024 --epochs 300 --data ./data/coco.yaml --weights ./yolov5m6.pt

# 验证：python detect.py --weights ./runs/train/exp/weights/best.pt --data ./data/coco.yaml  --imgsz 1024 --source 00136.jpg
# 注：跑验证时，.pt是不接受./data/coco.yaml的类别的了，它是从一开始训练时就定好的，但 .engine 这些是需要的，不然它的显示类别默认是真正的coo的类别(通过改源码的方式修正了，可看：vim models/common.py +499 )

:<<!
官网中：带6结尾的本身用的pixel就是用的 --img 1280

python train.py --img 640 --epochs 300 --data ./data/coco.yaml --weights ./yolov5l6.pt  可以
python train.py --img 1024 --epochs 300 --data ./data/coco.yaml --weights ./yolov5l6.pt  # 1024 就 out of memory 了

python train.py --img 1024 --epochs 300 --data ./data/coco.yaml --weights ./yolov5m6.pt  # m可以1024
python train.py --img 1280 --epochs 300 --data ./data/coco.yaml --weights ./yolov5m6.pt  # 1280就 out of memory

可以再开一个终端，使用tensorboar:
    1、运行web服务：tensorboard --logdir runs/train/   # 记得先激活这个虚拟环境
    2、访问：127.0.0.1:6006
    
    或者端口转发,win上再: ssh -f -N -L 6006:127.0.0.1:6006 root@192.168.108.218 
    就可以用win上的浏览器查看了

--------------------------------------------------------------------------------------------------------------------
训练好后，做了基准测试，因为环境问题，只有集中格式能行，
命令：
    python benchmarks.py --weights ./runs/train/exp/weights/best.pt --data ./data/coco.yaml --imgsz 1024 --device 1 
最终结果：
Benchmarks complete (965.08s)  # 这里Size指的模型的大小
                   Format  Size (MB)  mAP50-95  Inference time (ms)
0                 PyTorch       68.2    0.9459                20.65
1             TorchScript      135.6    0.9459                19.83
2                    ONNX      135.7    0.9459                29.89
3                OpenVINO        NaN       NaN                  NaN
4                TensorRT      178.5    0.9459                16.08
5                  CoreML        NaN       NaN                  NaN
6   TensorFlow SavedModel        NaN       NaN                  NaN
7     TensorFlow GraphDef        NaN       NaN                  NaN
8         TensorFlow Lite        NaN       NaN                  NaN
9     TensorFlow Edge TPU        NaN       NaN                  NaN
10          TensorFlow.js        NaN       NaN                  NaN
11           PaddlePaddle        NaN       NaN                  NaN

!
```



分割：./train_m_seg.sh

```shell
#!/usr/bin/env bash
source /root/anaconda3/bin/activate s_yolov5

# 下面都是按照默认的 batch-size = 16 来说的，我没去改

# yolov5l6.pt、yolov5m6.pt 是从官网下载的预训练权重文件
exec python segment/train.py --img 960 --epochs 300 --data ./data/coco.yaml --weights ./yolov5m-seg.pt
# 上面加了更强的数据增强参数  --hyp ./data/hyps/hyp.scratch-high.yaml  960的size显存会爆(降低batch_size为8就不会爆显存)，要用640的size

# exp  是 m 模型 size是 960
# exp1 是 l 模型 size是 640
# python segment/train.py --img 640 --epochs 300 --data ./data/coco.yaml --weights ./yolov5l-seg.pt 

:<<!

 m 模型，用 1024 会 out of memory
         用 960 即上面的悬链，基本显存也占满

 l 模型 只能训练 640 的图，然后显存基本沾满了
python segment/train.py --img 640 --epochs 300 --data ./data/coco.yaml --weights ./yolov5l-seg.pt


# detect测试的话：（记得指顶 --data ./data/coco.yaml，不然标签会错）
# 1：train-seg/exp 的权重文件是来自上面训练的 --img 960 --weights ./yolov5m-seg.pt 
python segment/predict.py --weights runs/train-seg/exp/weights/best.pt --data ./data/coco.yaml  --imgsz 960  --source 00136.jpg

# 2：train-seg/exp2 的权重文件是来自于上面训练的 --img 640 --weights ./yolov5l-seg.pt
python segment/predict.py --weights runs/train-seg/exp2/weights/best.pt  --data ./data/coco.yaml --imgsz 640 --source 00136.jpg
!
```

## 二、数据增强

​	yolov5中自带数据增强，且训练检测、分割时会默认启用。源代码中[检测](https://github.com/ultralytics/yolov5/blob/dd9e3382c9af9697fb071d26f1fd1698e9be3e04/utils/augmentations.py#L3C29-L3C29)的数据增强，[分割](https://github.com/ultralytics/yolov5/blob/dd9e3382c9af9697fb071d26f1fd1698e9be3e04/utils/segment/augmentations.py#L3C29-L3C29)的数据增强。（在源码的./utils/augmentations.py）

里面有的增强方式有一些，核心看这两个：copy_paste、mixup

- copy_paste是谷歌提出的思想，介绍[地址](https://mp.weixin.qq.com/s?__biz=MzIwMTE1NjQxMQ==&mid=2247549846&idx=1&sn=baebc308e54d0245458d4e4160d0021f&chksm=96f071c2a187f8d421f229fb15cee56e4a564af582ca0a0acb806c783cd45b647059fa408085&mpshare=1&scene=1&srcid=1216IynQFhVngkSjrPmxtPTG&sharer_sharetime=1608118151619&sharer_shareid=c69c9a4255c32bdac8d66c388b9626a6&key=cdcfdaabe182d9df48cf79efd4e222bea5911b4ad8b76dac1e20c433e11da01610ac2fb21eb688567546b6d429c7c8d8ee355319df05fbb0854c0331ca25e1fe3103aa6e45ab09e8a34cd4323e181c978dda800f5c8545f6f914d9fcd2c6db42c6d647d4706c5f6a786e2aa8bbbef82c3e95050c306886a1a254b492ea6b134c&ascene=1&uin=MTE5NTQ0OTA2MA%3D%3D&devicetype=Windows+10+x64&version=6300002f&lang=zh_CN&exportkey=A5zCUnmoeCdg69P1q32zQls%3D&pass_ticket=u3Bew4qoG%2By%2FR9V7cAYeg3L%2Bw1PBPKrZ%2Fkkr8jyuKDpoHEmyTvkKFXQJqtXpFhyR&wx_header=0) 

- mixup看一下这个介绍[地址](https://zhuanlan.zhihu.com/p/603735244)，里面还有一些其它的方式。

---

​	yolov5的训练(检测、分割)都是默认启用了数据增强，具体增强的一些参数通过配置文件来指定，不给的话默认是“data/hyps/hyp.scratch-low.yaml”，当然也可指定为“--hyp data/hyps/hyp.scratch-high.yaml”。

然后配置文件中，核心关注后面的几个参数：

- 增强比较低hyp.scratch-low.yaml里面的：

  ```
  degrees: 0.0  # image rotation (+/- deg)
  translate: 0.1  # image translation (+/- fraction)
  scale: 0.5  # image scale (+/- gain)
  shear: 0.0  # image shear (+/- deg)
  perspective: 0.0  # image perspective (+/- fraction), range 0-0.001
  flipud: 0.0  # image flip up-down (probability)
  fliplr: 0.5  # image flip left-right (probability)
  mosaic: 1.0  # image mosaic (probability)      # 马赛克，默认都有
  mixup: 0.0  # image mixup (probability)
  copy_paste: 0.0  # segment copy-paste (probability)  # 这就相当于没启用这个增强
  ```

- 增强比较高hyp.scratch-high.yaml里面的：

  ```
  degrees: 0.0  # image rotation (+/- deg)
  translate: 0.1  # image translation (+/- fraction)
  scale: 0.9  # image scale (+/- gain)
  shear: 0.0  # image shear (+/- deg)
  perspective: 0.0  # image perspective (+/- fraction), range 0-0.001
  flipud: 0.0  # image flip up-down (probability)
  fliplr: 0.5  # image flip left-right (probability)
  mosaic: 1.0  # image mosaic (probability)
  mixup: 0.1  # image mixup (probability)
  copy_paste: 0.1  # segment copy-paste (probability)
  ```

注：

- 以上在源代码中，都是以 random.random() < hyp["copy_paste"] 然后进入到这种的数据增强，所以配置文件中数值给的越大，变化越大。
- 数据增强启用越多，占的显存就会越大。

### 三、背景

可以添加一些背景图片，然后对应的表标签文件txt就是空的。