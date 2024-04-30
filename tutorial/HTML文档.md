注释一行是：ctrl + /

在当前位置注释：ctrl + shift + /

Emmet 语法 [速查表](https://www.jianshu.com/p/9352a0411fcb) 

有一个盒子模型和margin和overflow属性，还挺有用的，如果以后用得上，在这里（“.\就业班\07 HTML和CSS\08-margin和overflow属性”）(好像overflow可以把ul列表搞成一行)

通过css来做动画效果，也挺有意义的（“.\就业班\首页布局案例和CSS3动画及移动端布局\02-CSS3动画”）

这个网址是[免费图标](https://phosphoricons.com/)的各种类型下载。

这个网址是前端各种在线环境，vue等各种三方库，[在线环境](https://pcljs.org/zh-cn/docs/tutorials/getting-started/playground)。（这个网址还能调用PCL的库在浏览器中运行）

## 一、HTML

### 1.1. HTML文档结构

W3C中规定：所有属性值用双引号括起来(虽然单引号和不要引号都行，但是更加统一规范)

- 这里包括了html基本组成，引用外部css样式，把网页前面加一个图标

```html
<!DOCTYPE html>  <!-- ! 表声明的意思，这一行的代码意思：下面的文档标签以html5规范去解析-->

<!--以成对的html作为开头-->
<html>
	<!--1、头部：以成对的head内的内容作为网页标题-->
	<head>
    	<title>我的第一个网页</title>  <!--这是标题-->
    	<!--meta:元，主要用来完成对应设置-->
    	<meta charset="utf-8">         <!--不设置编码格式就会乱码-->
    	<meta name="keywords" content="123">   <!--设置一个网站的搜索关键字，都是为了调高被搜索到-->
    	<meta name="description" content="456">   <!--网站的描述内容，填到content中，提高被搜索概率-->

    	<!--设置网页小图标：快捷写法就是输入 link:favicon 然后tab就行了,然后再把图片的链接放进去-->
    	<link rel="shortcut icon" href="//img.alicdn.com/tps/i3/T1OjaVFl4dXXa.JOZB-114-114.png" type="image/png">
    	<!--type的值，就是后面/png改成图片对应的后缀，原本可能是/x-icon，不改也不影响-->

    	<!--设置样式，看到style就明显知道这是设置样式的-->
    	<style>
        	/*书写样式的地方；；或者下面添加外部css文件*/
    	</style>
    	<link rel="stylesheet" href="style.css">  <!--这是使用外部css文件-->
    	<!--一样先输入 link:css 再tab，然后把css路径放到href里就行了-->
	</head>

	<!--2、主体部分-->
	<body>
    	<p>这是一个段落</p>    <!--里面放p这种大量的标签来丰富页面里的内容-->
	</body>
	<!-- 看到script就明显知道这是弄脚本文件的 -->
	<script language="JavaScript" type="text/javascript">  <!-- 这里还可以改成其它的属性 -->
    // 放脚本代码的地方，可以没有
	</script>
</html>
```

### 1.2. 常用标签

webstorm中快速打出固定的东西(在一个空白的html文件中)：

1. 先输入`!`再按Tab就行;
   - 标签*10再按tab就可以快速打出10个标签，比如 p\*10,再tab就能获得10个p标签。
1. 或者输入`html:5`再按Tab就行。

#### 1.2.1 几个基本标签

一般在body中使用各种标签，head中的内容都是安装上面的方法生成的：

- div：用来布局的，没有具体含义，可以看做层;
- h1：用于控制标题级别的，数字只能是1~6,1级标题最大，6最小，会自动加粗，有默认字号;
- p：表示一个段落，相当于一个回车,里面一般放一段文字;
- br：换行，一段文字想在某些地方换行就加这，==单标签==;
- hr：生成一条水平线，主要起装饰作用，==单标签==;
- a：实现超链接跳转,包括网址和文件;
- img：加载外部图片，==单标签==;这个尽量要给alt属性，以免在加载不出图片时，更友好的显示；加上title属性，鼠标放上面会有title内容的文字提示
- span：作用与div一样，都是用来布局，不同的是div会单独占一行，而span不会，span用于行内布局;
- ul/ol：前者是无序列表，后者是有序列表，他们的内容都用的是li标签。

```html
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <!--移动端开发设置-->
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">   <!--代表ie打开就是edge打开-->
    <title>Document</title>
</head>
    
<body>
    <!--1、div:用来布局的，没有具体含义，可以看做层-->
    <div>
        abc_hello_world
        <div>这里面是可以嵌套的</div>
    </div>

    <!--2、hx:用于控制标题级别的，x只能是1~6,1级标题最大，6最小，会自动加粗，有默认字号-->
    <h1>一、前端的学习</h1>
    <h2>1.1、html入门</h2>
    <h6>最后一级标题</h6>

    <!--3、p:表示一个段落，相当于一个回车,里面一般放一段文字-->
    <p>这里面放一大段文字，然后最后结尾p标签就相当于来了一个回车,进行分段</p>

    <!--4、br:换行，一段文字想在某些地方换行就加这-->
    <p>这里面放一大段文字，<br />然后最后结尾p标签就相当于来了一个回车</p>
    <!--由于是单个的br，为了统一，建议写成<br /> 代表br开始及结束，虽然也可以是<br> -->
    <!--标签属性：
        1.通常由属性名="属性值"组成 （引号可以不要，但一般都是加上）
        2.起附加信息的作用
        3.不是所有标签都有属性，比如br标签-->
    <p title="段落" class="content" id=可以是一样的>这是标签属性的测试</p>

    <!--5、hr:生成一条水平线，主要起装饰作用，也是单标签-->
    <hr />  <!--这就是一条单纯的线，可以在下面加属性-->
    <hr width="20%" color="red" align="center" height="2px" />

    <!--6、a:实现超链接跳转-->
    <p>请点击<a href="https://baidu.com/" title="这里放提示文字，这会新开一页" target="_blank">百度</a>这里</p>     <!--放www.baidu.com不行；一般是这样用，包裹在其它标签，就可以加文字的-->
    <!--下面这就是把超链接的文字"白底"变成了一张图，中间是可以嵌套的-->
	<a href="https://baidu.com/" title="百度，这不会新开一页"><img src="https://www.baidu.com/img/PCtm_d9c8750bed0b3c7d089fa7d55720d6cf.png"></a>   
    <!--下面是文件的跳转，注意绝对路径和相对路径-->  <!--target中还有_parent和_top暂时用不到-->
    <a href="01HTML文档结构.html" target="_blank">01文档001</a>  <!--这是新开一个网页-->
    <a href="01HTML文档结构.html" target="_self">01文档002</a>   <!--这是在自身网页上打开-->
    <!--不给target,默认就是用的_self，本身打开-->

    <!--7、img:加载外部图片，参数：src:所需加载图像的路径；alt:图像加载不成功或是图像不存在时就是显示这个内容，否则不显示；title:鼠标放在图标上时的提示内容-->
    <img src="https://img.alicdn.com/imgextra/i2/113880495/O1CN01qcg7wt1FWkiH6KxKj_!!0-saturn_solar.jpg_468x468q75.jpg_.webp" alt="图片" title="提示内容" />
    <!--img也是单标签，记得用<img /> 这样来补全-->

    <!--8、span:作用与div一样，都是用来布局，不同的是div会单独占一行，而span不会，span用于行内布局-->
    <div>div1</div>
    <div>div2</div>     <!--这俩就会有两行-->
    <span>span1</span>
    <span>span2</span>  <!--这俩就只有一行-->

    <!--9、ul/ol:列表，前者是无序列表，后者是有序列表，他们的内容都用的是li标签
       快捷写法是：先输入 ul>li{这里是内容$}*3  然后Tab，$会自动生成1、2、3，3代表3条内容
	   如果是$$$，就会自动生成 001、002、003
    -->
    <ul>
        <li>这是内容1</li>
        <li>这是内容2</li>
        <li>这是内容3</li>
    </ul>

    <ol>
        <li>这是有序列表1</li>
        <li>这是有序列表2</li>
    </ol>
    
    <!--10、q: 会自动把文本加上引号-->
    <q>这会自动加引号</q>
    <!--11、address: 专门用来写地址联系人这些，会有一些自己的格式-->
  	<address>
    	<p>电话：123456789</p>
    	<p>住址：XXXXXXXXXX</p>
 	 </address>
    
</body>
    
</html>
```

补充一个单标签(都还是加上`/`闭合)：

- 换行符：<br/>
- 水平线：<hr/>
- 图片标签：<img/>
- 文本标签：<input/>
- link标签：<link/>
- 元信息标签：<meta/>

#### 1.2.2  加强文本样式标签

文本格式化标签：

- b 和 strong：都是对文本进行==加粗==，且都是==行级标签==；
  - 但strong除了加粗还有强调作用，注：强调主要用于SEO时，便于提取对应的关键字。

- i 和 em：使文字倾斜，且都是==行内标签==，如果是简单的倾斜效果，使用==i==标签就行；
  - em同样具有强调效果。

- pre：可定义预格式化的文本，这里面的文本通常会保留空格和换行符，而文本也会呈现为等宽字体，文字的字号也会小一号；
  - pre是==块级标签==；
  - 反观p标签中的空格都是不会被认可的，多少空格都没用
- small 和 big：均为==行内标签==，让字体缩小或放大一号；
  - 浏览器支持的最小字号为12px，需要更小的就要做处理了；
  - big在HTML5中被淘汰了，但并没有删除(在ide中，big显示时也会被加一条删除线)，能用，但不建议使用。
- sub 和 sup：将其内的文本设为下标和上标。

```html
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>文本格式化标签</title>
</head>
<body>
    <b>第一种加粗方式</b>
    <strong>第二种加粗方式，并强调</strong>

    <i>文字倾斜</i>
    <em>文字倾斜，并强调</em>

    <pre>这里的文本   会保留空格
    以及换行，  保持现状的样子</pre>

    <p>这是正常字体</p>
    <small>这是小一号的字体</small>
    <big>这是大一号的字体</big>

    <p>X1 + X1 = Y</p>
    <p>下标：X<sub>1</sub>+Y<sub>1</sub> = Y</p>
    <p>上标： X<sup>2</sup> + Y<sup>2</sup> = Y<sup>2</sup></p>
    <!-- 以上两行在空格上都是一样的，p标签里不识别空格   -->
    上标： X<sup>1</sup> + Y<sup>1</sup> = Y  <!-- 好像不让p标签包裹起来也行 -->
</body>
</html>
```

#### 1.2.3 \&nbsp;等实体转义

​	现象：在HTML中，内容编辑时，如果通过空格键编辑的多个空格，==网页会显示仅且只显示一个空格==，而小于(<)和大于号(>)，网站则会认为是标签而无法直接显示在页面中，这都可以通过实体字符来解决。

| 实体字符   | 代表的字符 |
| ---------- | ---------- |
| `&lt;`     | <          |
| `&gt;`     | >          |
| `&amp;`    | &          |
| `&nbsp;`   | 一个空格   |
| `&copy;`   | 版权(©)    |
| `&times;`  | 乘号(×)    |
| `&divide;` | 除号(÷)    |
| `&#39`     | 英文单引号 |
| `&quot`    | 英文双引号 |

Tips：

- 一定是以&开头，以`;`结束；

- 一个`&nbsp;`只代表一个空格，想要多个空格就多次输入

  ```html
  <p> aa    bb</p>   <!-- 这里显示还是只有一个空格 -->
  <p> aa &nbsp;&nbsp;&nbsp;bb</p>  <!-- 空格就增加了 -->
  <p>aa &divide; bb</p>  <!-- aa ÷ bb -->
  ```

然后一般点击左右那个箭头，就是通过大于小于符号做的,然后给它设置样式：

> ```
> .sym {
>  color: hotpink;
>  font-weight: bolder;
>  font-size: larger;
> }
> <div class="sym">&lt;</div>
> ```

#### 1.2.4 块级/行内元素

W3C中的嵌套规范：

- 块级元素介意包含行内元素或块级元素，但行内元素只能包含行内元素；
- p，h1~H6，dt标签中只能包含行内标签，不能再包含块级标签；
- 块级元素与块级元素并列，行内元素与行内元素并列，不要混合并列。

​	==块级元素==(相当执行了  display:block;  的操作)：块级元素会独占一行，其宽度自动填满其父级元素宽度，一般情况下，块级元素可以设置 width，height属性，一般用来搭建网站架构、布局、承载内容...，它包括以下这些标签：（若设置 display:none 样式就会不可见）

> address、dir、div、dl、dt、dd、fieldset、from、h1~h6、hr、menu、noframes、ol、p、pre、table、ul等。

- 独占一行;

- 宽度和高度是可控的，如果没有设置其宽度，将默认铺满整行;

  ```html
  <div style="width:300px;height:50px;background:orange">this is div</div>
  ```

  <div style="width:300px;height:50px;background:orange">this is div</div>

- 其内可以包含块级和行内元素。

---

​	==行内元素==(相当于执行了 display:inline;  的操作)：行内元素不会独占一行，相邻的行内元素会排列在同一行内，直到一行排不下才会换行，其宽度随元素的内容而变化，行内元素设置width和height无效，一般用在网站内容之中的某些细节或部位，用以“强调、区分样式、上标、下标、锚点”等等。下面这些标签都属于行内元素：

> a、b、bdo、big、small、br、cite、em、font、i、img、input、kbd、label、select、span、strong、sub、sup、textarea等。

- 不会独占一行，与相邻的行级元素占同一行，直到行占满，才会自动掉到下一行；

- 宽度和高度是不可控的；

  ```html
  <b>这里放点文字</b>
  <span style="width:300px;height:50px;background:#2ecaff">this is span</span>
  ```

  <b>这里放点文字</b>
  <span style="width:300px;height:50px;background:#2ecaff">this is span</span>      <!-- 实际网页中这不会换行，这俩是在一行 -->

- 其内只有包含行内元素。

注：以上两个例子都设置了宽高，也看到效果，只有块级元素可以，行内元素设置宽高是不起作用的。

---

<b>块级元素和行内元素之间的转换：</b> 

块转行：在属性中加入==display:inline;== 

行转块：在属性中加入==display:block;== 

```html
<div style="width:300px;height:50px;background:orange;display:inline;">块级元素转行内元素</div>
<b>这里再放点文字</b>
<span style="width:300px;height:50px;background:#2ecaff;display:block;">行内元素转块级元素</span>
```

可以把这一小节的这6行代码放一起，就能在浏览器看出很明显的效果了。

### 1.3. 标签通用属性

1. 标签名是由标签名、标签属性和文本内容三部分组成（注意：单标签没有文本内容）；

2. 标签属性分为通用属性、自有属性和自定义属性：

   1. 通用属性有：

      - id：给标签起一个唯一标识符，id在一个网页内==必须是唯一的==；
      - class：用来给标签取一个类名（同一类的就方便统一使用 .box 这样的样式）；
      - title：当鼠标移到该标签时，所显示的提示内容；
      - style：用来设置行内样式。

      ```html
      <body>
          <p id="p1">这是id1</p>   <!-- 注意id必须唯一-->
          <p id="p2">这是id2</p>
      
          <!-- class= 给一组标签取一个类名 -->
          <div class="test">a_div</div>
          <p class="test">a_PP</p>
      
          <!-- title= 给当前标签一个提示名-->
          <p title="这是一个提示">鼠标放上来有提示</p>
      
          <!-- style: 设置样式，注意style中的键值对是用的冒号:   -->
          <p style="color:red; width:200px; border:2px solid #0000ff">这是一个行内样式</p>
      </body>
      ```

   2. 自定义标签属性：通常用来传值或是图片懒加载(滑到某区域时，某区域才加载图片)等方面

      格式：data-*       // `data-`是固定的，后面的*是自己起

      如：\<img data-src="图片名" alt="提示文本" />    // 多个属性之间空格隔开就是，不要加逗号

      \<p data-goods_name="goods_name">....</p\>
      上面的src以及goods_name都是自己起的，尽量跟后面的值相关，然后后面代码会把具体值传过来


### 1.4. form表单

form表单是用来实现前后端交互的一个重要标签,常用属性：

- name：表单名称
- action：表单数据提交的地方(通常是一个后滩文件名(.jsp、.php、.py等，或网址))
- method：前端提交数据到后端的方法，主要有：get和post（注：默认是get,但尽量用post,因为get会把数据明文显示出来，而post不会）

```html
<body>
    <form name="stuInfo" action="abc.py" method="post">   <!-- 这行里的属性都不要也行-->
        <input type="text" name="userName" placeholder="请输入您的姓名">
        <input type="submit">
    </form>
    <!-- 这个点击后就会跳转到百度网页，一定注意这里的网址都是要https开头 -->
    <form name="whatever_is_ok" action="https://baidu.com">   <!--这里没给post，默认都是get方法-->
        <input type="text" name="phone" placeholder="请输入电话号码">
        <input type="submit">
    </form>
</body>
```

表单元素分为四类：（==以下的每一个大类或是大类里又细分的，其实就是一个标签，可单独使用==）

1. ==**input类**==：主要用来输入，根据其不同的type属性，可以变化为多种状态输入方式

   - ==<input type="text" /\>==           // 定义提供文本输入的单行输入字段（这是默认值，什么都不给就是这）

     - placeholder  //文本框内提示

     - name        // 命名

     - minlength   // 最少输入的字符个数

     - maxlength   // 最多输入的字符个数，超过了就输入不进去了

     - disabled    // 失效（disabled或disabled=""或disanled="disabled"都会让这个框变灰而无方法选中）

     - readonly    // 只读（这也不能修改，与disabled写法一样，区别是它跟正常框一样，不会变灰）

     - value       // 可以给一个默认值（有这个就不会再显示placeholder的提示了）

     - pattern     // 正则匹配，（比如注册邮箱时，不合法，直接前端就验证了）

       ```html
       <form action="">
           <input type="text" name="phone" placeholder="输入电话" value="135" disabled />
           <input type="text" name="phone" value="4199" readonly="readonly" />
           <input type="text" name="phone" placeholder="输入电话" maxlength="5" /> <br/>
       </form>
       ```

   - ==<input type="password" /\>==       // 定义密码字段

     它的属性跟text是一样的，主要就是不是明文显示

   - ==<input type="radio" /\>==         // 定义==单选==按钮

     - name     // 这个很重要，做抉择的选项的name值必须一样，这样保证只有一个能被选中，不给的话，两个都能被选中，所以这name跟上面的name不一样

     - checked  // 给这个值，代表默认选择（一般单选都会给一个默认值,多给也是最后一个起作用）

     - 这个还有value、disabled、readonly属性，但是不常用

       ```html
       <form action="">
           <!--  radio：单选钮(多个选一个)  -->
         <input type="radio" name="sex" checked="checked"/>男
           <input type="radio" name="sex" />女  <!-- 这组的name-->
       	<!-- 下面的又是另外一组选择了，有相同name值的视为一组  -->
           <input type="radio" name="num" />1    
           <input type="radio" name="num" checked />2
           <input type="radio" name="num" />3
       </form>
       ```

   - ==<input type="checkbox" /\>==     // 定义复选框(也叫检查框)，可选择0项、1项或多项

     - name   // 这个属性必须要有

     - 其它属性基本同上面的radio

       这个选择的==默认值可以不给==，也可以给多个(注意html直接渲染的结果)

       ```html
       <form action="">
             <input type="checkbox" name="hobby" />music    <!-- 后面这些值就是选项的值 -->
           <input type="checkbox" name="hobby" />sport
             <input type="checkbox" name="hobby" />travel
       </form>
       ```

       <form action="">
             <input type="checkbox" name="hobby" />music    <!-- 后面这些值就是选项的值 -->
           <input type="checkbox" name="hobby" />sport
             <input type="checkbox" name="hobby" />travel
       </form>

   - ==<input type="file" /\>==    // 主要是文件的上传，点击就会在本地选择文件

     - name   # 常用的是这个属性，具体可看Django笔记中的上传文件的使用 

   - ==<input type="button" /\>==       // 定义普通按钮

     - value     // 这个属性它的值主要是在button上显示

     - disabled  // 跟上面用法一样，设置了这个按钮就变灰了，就不能点了

       ```html
         <form action="">
       	<!-- file 文件上传-->
         	<input type="file">    <br />
       
         	<!-- button  普通按钮，通常用它去调用脚本代码      -->
       	<input type="button" value="登录" disabled>
       </form>
       ```

   - ==<input type="image" /\>==   // 定义图片提交按钮(就是把一个按钮图片化了，弹幕说就是带皮肤的button)，用法同button一样

     - src      // 属性 用来放图片的路径

     - title    // 属性  用来鼠标在图片上悬停时的友好提示

     - 注意：这个点击提交会跳转到demo.app处,跟"submit一样"，而button却不会提交

       ```html
       <form action="">
       	<input type="image" src="img/1.png" title="刷新">
       </form>   
       ```

   - ==<input type="submit" /\>==         // 定义提交表单数据至表单处理程序的按钮

     - value    // 属性，提交按钮上显示的字，默认是submit

       注意：这个点击提交会跳转到demo.app处

       ```html
       <form action="demo.app">
       	<input type="submit" value="提交">
       </form>  
       ```

   - ==<input type="reset" /\>==     // 前面改了一些值，这个将其全部还原为初始状态

     - value   // 属性 按钮上显示的字  默认是Reset

       ```html
       <form action="">
       	<input type="reset" value="取消">
       </form>  
       ```

   - ==<input type="email" /\>==     // 用于输入邮箱时吧，好像用text也一样啊

2. ==**textarea类**==：     // 这个主要用于输入大批量的内容

   - 常用属性：name/id/cols/rows/placeholder/minlength/maxlength/required(有这个值表示必须输入)/value

   - 列数固定死了，行数给定了，显示区域就那么大，要是文字超过给的行数，右侧就会出现滑动拉条

     ```html
     <form action="">
     	<textarea name="a_demo" id="a_random" cols="30" rows="10" placeholder="这里放提示内容"></textarea>
     </form>  
     ```

     ​	注：这里还可以\<textarea>备注：</textarea\>，这里只是为了简单暂时，可以把提示文字放这里，这样框里初始状态就会有“备注：”这俩字，哪怕有placeholder，placeholderdr的值也会被这个覆盖，而且它是永远不会消失的。

3. ==**select类**==：

   - 下拉列表框，默认用于单项选择：

     ```html
     <form action="">    <!-- 下面汉字一定是要的，就是显示的内容 -->
         <label for="sex">选择性别：</label>  <!-- label标签做个选择提示，与下面select的id关联起来；如果没引用就会给warn，但是写的是 for=""，不给值的话，是错的，所以实在没关联时，把for去掉不要 -->
     	<select name="a_sel" id="sex">    <!-- name是随便给的 -->
     		<option value="male">男</option>
     		<option value="female">女</option>  <!-- 每多一个选择，就加一个option， -->
     		<option value="secret" selected>保密</option>   
     	</select>
     </form>  
     ```

     - 提交表单后，里面会有一个键值对，key就是select的name(这里即a_sel)，若是选的option中的男，那键值对的值就是所选的option中的value(这里即male)

   - 多项选择，加上关键字 multiple

     如果选择很多，全部显示出来很长，那就加一个 size（代表最多显示的行数，超过的都会被收起来）
     option的默认选中就加个==selected==。

     ```html
     <form action="">
     	<label for="cate">请选择科目：</label>
     	<select name="mul_sle" id="cate" size="3">  <!-- 这里就只会展示3个选项 -->
     		<option value="语文">语文</option>
     		<option value="数学">数学</option>
     		<option value="英语">英语</option>
     		<option value="计算机" selected>计算机</option>   <!-- 这里的默认选中加selected -->
     		<option value="其它">其它</option>
     	</select>
     </form>  
     ```

4. ==**button类**==：

   - 普通按钮，具有提交功能，一般是执行js代码，可以单独使用；

   - 如果写在form中，具有提交功能:

     ```html
     <button id="a_signal">确认</button> <!-- 可能主要用来掉js代码 -->
     <form action="demo.py">
     	<input type="text" name="my_info">
     	<button>提交</button>  <!--这里的button功能与input中的submit按钮功能一样-->
     </form>
     ```

---

​	补充：最后还有一个iframe框架标签，就是把几个html文件组合到一起，但是十几种几乎不用，它会破坏网页的前进后退功能，且不利于SEO看弹幕说一般是用div，放[这里](https://www.bilibili.com/video/BV1i7411Z7d8?p=36&spm_id_from=pageDriver)做个了解吧。

### 1.5. 表格

​	在html中，table表示表格，tr表示行，td表示列，生成一个表格的快速写法：`table>tr*2>td{这里放内容}*3`，然后再按tab键，就会生成两行三列的表格

```html
<body>
<!--
    table+tr*2>td{这里放内容}*3   这是错的，那里不能是+，但是注意用+会生成什么
    table>tr*2>td{这里放内容}*3   tr是行， td是列

  -->
    <table border="1" width="400" cellspacing="0" cellpadding="10" align="center">
        <tr>
            <th>这里放内容</th>    <!-- th就是表头特殊那一行(这是手动改的) -->
            <th>这里放内容</th>
            <th>这里放内容</th>
        </tr>
        <tr>
            <td>这里放内容</td>
            <td>这里放内容</td>
            <td>这里放内容</td>
        </tr>
    </table>
</body>
```

注意：一般把第一行的tr改成th，这样它就会是表头，与后面的不一样。

表格属性：（但是WebStorm提示这些将被Deprecated，建议用css来修改样式）

- border：设置表格边框，默认单位是像素；
- width：设置表格宽度，默认但是像素；
- align：表格相对出现在页面中的位置，（left(默认)/center/right）；
- cellspacing：表格最外面的边框跟里面的距离，当不设置为0时，可以明显看到差别；
- cellpadding：单元格内文本与边框的距离，换种理解，可理解为表格的高度。

更细更多的东西，就看[这里](https://www.bilibili.com/video/BV1i7411Z7d8?p=27&t=3.6)。

## 二、CSS

一个很详细的示例，如果要看css效果的一些实现，一定要来[这里](https://www.w3school.com.cn/css/css_image_transparency.asp)看看。

css语法由三个部分组成：选择器、属性、属性值。

> selector { property: value}             

- value前面的空格可以不要
- 属性完了都是以`;`隔开
- 一个属性可能有多个值，多个值之间用空格隔开

### 2.1. css引入方式

一共有四种引用方法：

第一种：==行间样式==（又叫嵌入式样式）

​	直接在html文件的body的里面写：

```html
<div style="color: olive; width: 100px; border: 1px solid orange">行间样式演示</div>
<div>行间样式演示</div>
```

<div style="color: olive; width: 100px; border: 1px solid orange">行间样式演示</div>
<div>行间样式演示</div>

---

第二种：==内部样式表==，一般都是定义放在html文件的head中，然后在body中使用：
	下面想要修改p标签的样式，那就用  style 把 p 标签包裹起来，再设置p标签的样式

```html
<head>
    <!--2.内部样式表，，一般都是定义放在head中；这样就定义了所有p标签的样式 -->
    <style>
        p {    /*注意这里面注释方法的不同*/
            background-color: #eeeeee;
            font-size: 18px;
            font-style: italic;  /*代表字体倾斜*/
        }
    </style>
</head>
<body>
    <p>这是内部样式</p>
    <p>这是内部样式</p>  <!--p标签都会是一样的效果-->
</body>
```

---

第三种：==外部样式==，

（1）先在外面写一个css文件，（2）ling:css把这个文件引入

​	假设写的css文件名“01css.css”，放在html同路径下的“my_style”文件夹下：

```css
span {
    font-size: 15px;
    color: rgba(108, 141, 23, 0.66);
    display: block;  /*这样就把行元素转成块元素了，就会自动换行了，原来是不会的*/
}
```

然后html文件：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CSS学习</title>
    <!-- 3.引入外部样式文件 -->
    <!-- Emmet语法： link:css 然后在按tab，就会快速补充 -->
    <link rel="stylesheet" href="my_style/01css.css">
</head>
<body>
    <span>这是引入外部样式文件</span>
    <span>这是引入外部样式文件</span>
</body>
</html>
```

---

第四种：==导入外部样式==，与第三种其实差不多，就是用的@impoet 

​	这种先写的一个02css.css文件，跟第三种方法有点不一样：

```css
.my_box {   /* 前面的点是固定写法，my_box可以是任意的*/
    font-weight: bold;  /*加粗*/
    font-size: 20px;
    color: darkorange;
}
```

然后在html中：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CSS学习</title>
    <!--4.导入外部样式，一定放在style中 -->
    <style>
        @import "my_style/02css.css";   /* 千万别忘了分号结尾*/
    </style>
</head>
<body>
    <!-- 快速写法： .my_box{这是导入外部样式}*3  然后再tab  -->
    <div class="my_box">这是导入外部样式</div>
    <div class="my_box">这是导入外部样式</div>
    <div class="my_box">这是导入外部样式</div>
    <em>em就倾斜的意思</em>  <!-- 这就不会有效果 -->
    <em class="my_box">em就倾斜的意思</em>  <!-- 这就会有效果 -->
</body>
</html>
```

Tips：

- 这种导入的css文件也能是第三种方法里的那种css文件；
- 主要看第三种方法和第四种方法的css文件的写法不同，第四种方法更具有自定义性；
- .my_box{这是导入外部样式}*3  然后再tab  这种快速写法，点`.`默认就是用div布局；
- @import导入时：
  - 文件一定要加引号，且结尾一定要是分号；
  - ==这个@import语句一定要放到 style 里包裹起来==。

区别：

- link除了加载CSS外，还可以定义RSS等其它事务；而@import属于css范畴，只能加载css；
- link引用css时，在页面加载时同时加载；@import需要网页页面完全载入后加载；
- link是XHTML标签，无兼容问题；@import是在CSS2.1提出的，低版本的浏览器不支持；
- link支持使用Javascript控制DOM去改变样式；而@import不支持。

实际开发中，可能更多的还是用的link。

### 2.2. 样式写法

#### 2.2.1 css选择器

CSS选择器有几种分类：`所有写在html中的css选择器，都一定要用 style 标签包裹起来！` 

1、==*==：匹配html中所有标签，（所以性能比较差，实际开发中，不建议使用）

注意点：

- 一般是把这写到html文件的head中，它会对body中的所有标签都产生作用；

- 在head中一定要用==style==标签包裹起来。

  ```html
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <title>Title</title>
      <style>   /* 一定要用style包裹 */
          * {
              color: orange;  /* 写法就是这三行 */
          }
      </style>
  </head>
  <body>
      <p>这是一个测试</p>
      <div>这效果会是一样的</div>
  </body>
  </html>
  ```

2、==标签选择器==：==设置的那种标签，那就只有对应的标签才生效==

- 注意：一定是已有的标签，如span、div、p这种

  ```html
  <head>
      <style>   /* 一定要用style包裹 */
          /* 2.标签选择器 */
          span {
              display: block;  /*前面讲了，这就当块级元素*/
              margin-right: 20px;
              border: brown;
              color: #2ecaff;
          }
      </style>
  </head>
  <body>
      <div>这就没效果</div>
      <span>这才会有效果</span>  <!-- 和上面span对应起来了 -->
  </body>
  ```

3、==类选择器：自定义一个类名，设置样式，凡是使用 class=此类名 的标签均为这个样式==（示例很重要）
   （一般都是用这个）

- 注意：名字可以自己起，前面一定要加一个点`.`；

- Emmet语法快速写法(假设div标签，class想要写my_sty)：先输入 div#my_sty 再tab 就会自动生成（可能会生成错误，成了id=my_sty,那就建议直接 .my_sty，然后tab,默认就是div布局， 也可以 .my_sty>p 再table，就是div中嵌套着p标签了 ）。

  ```html
  <head>
      <style>   /* 一定要用style包裹 */
          /* 3.类选择器 */
          .my_sty {   /*千万别忘了这个点 . */
               /* 一般给下面这三个参数，就相当于有了一个文本框，也叫盒子模型，就可以进行各种操作了  */
              width: 300px;
              height: 300px;   
              background-color: hotpink;  
          }
      </style>
  </head>
  <body>
      <div>这就没效果</div>
      <!-- Emmet语法快速写法：p.my_sty 然后再tab就会得到这个   -->
      <span class="my_sty">这才会有效果</span>   <!-- class用了才有效果 -->
      <!-- class中的值  my_sty 前面一定不能有那个点 . -->
      <div class="my_sty">这跟上面就是一样的效果</div>
  </body>
  ```

4、==ID选择器：自定义一个id名，然后 id=此id 的标签就会使用这样式==

- 注意：名字也是自己起，前面一定要加一个`#`；

- 一般id是唯一的，在IDE中两个相同的id会报错提醒，但是在网页上像个相同id的标签还是会显示一样的效果；

- Emmet语法快速写法(假设p标签，id想要写my_id)：先输入 p#my_id 再tab 就会自动生成。

  ```html
  <head>
      <style>   /* 一定要用style包裹 */
          /* 4.id选择器 */
          #my_id {   /*千万别忘了这个 # */
              color: olive;
          }
      </style>
  </head>
  <body>
      <div>这就没效果</div>
      <!-- Emmet语法快速写法：p#my_id 然后再tab就会得到这个   -->
      <p id="my_id">这是id选择器的效果</p>
  </body>
  ```

5、派生选择器：一般就是父类选择了一个样式(就是一般的类选择器)，后续的不选都是这个样式，常见于有/无序列表。

- Emmet语法快速写法：先输入 ul>li{这是内容$$}*3 再tab就得到了三条无序列表

  ```html
  <head>
  
      <style>   /* 一定要用style包裹 */
          /* 5.派生选择器 */
          .my_der {
              color: coral;
          }
      </style>
  </head>
  <body>
      <ul class="my_der">
          <li>这是内容的说001</li>
          <li>这是内容的说002
              <ul>
                  <li>注意这子内容的位置</li>
                  <li>跟内容002是在一个li里面</li>
              </ul>
          </li>
          <li>这是内容的说003</li>
          <p>nihaio </p>   
      </ul>
  </body>
  ```

- 这样的话，所有的内容的样式都是上面==my_der==的样式，但是注意它的写，上面这种写法测试没问题，它会对里面所有标签都生效，包括哪不合法的p标签；

- 还有一种写法：.my_der li {color: coral;}  或者  .my_der>li {color: coral;} 
  这样就只会有li标签生效，而p标签是不会生效的。

- 注意：20行，p标签放这里可有效果，但是IDE会报“Element p is not allowed here”，不让放进ul中，放其它标签也是，暂时没找到除了li以外的其它可以放的标签。

6、伪类选择器(说是后面学)

#### 2.2.2 选择器分组

让多个选择器(元素)具有相同的样式，一般用于设置公共样式，避免重复写相同样式的代码。

```html
<head>
    <style>   /* 一定要用style包裹 */
        /* 选择器分组 */
        p, .box, h1 {    /* 注意写法，就是上面不同的选择器，写一起，用逗号隔开 */
            color: darkorange;
        }
        p {
            background-color: #2ecaff;
            width: 200px;
            color: red;  /* 这再给样色就会把上面覆盖掉 */
        }
    </style>
</head>
<body>
    <div class="box">样式~~</div>
    <h1>一级标题</h1>
    <p>~~样式</p>
</body>
```

解读：

- p、h1标签以及类选择器box(所以前面有个点)，写一起后，三个的样式都是相同的，就不用写三次；
- p标签又在下面自主定义了，就会增加样式，里面新加的color，就会把组里的颜色覆盖掉。

#### 2.2.3 样式继承

被别的标签包裹起来的就是人家的子类，子类是会继承父类的，也可以重写，有点选择器分组的味道

```html
<head>
    <style>   /* 一定要用style包裹 */
        /* 样式继承 */
        div {
            font-size: 18px;
            color: orange;
        }
        div span {    /* span子类继承了color，覆盖了font-size */
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div>这是一段测试<span>内容</span></div>   <!-- 不能是同一个标签 -->
</body>
```

Tips：要在标签里加新的标签的快捷写法：比如第14行

​	先写好了 \<div>这是一段测试内容</div\>,要在“内容”用span包裹起来，那就在"内容"后打一个空格，然后输入span，再按tab，然后再把"内容"两字剪切进来

其实下面是更常见的继承写法：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <style>
        .content {
            font-size: larger;
            color: aquamarine;
        }
        .content .border {          /* 这些名字都是自己起的  */
            color: orangered;
        }
    </style>

</head>
<body>
    <p class="content">这是一段文字</p>
    <p class="border">这是一段文字</p>   <!-- border随机继承的，这里单用没任何效果 -->
	
    <!-- 下面23行这样才有效果，被嵌套着，且尽量不能是两个相同的p标签，有时候不行，其它好像都行，<p class="content">外面的东西<p class="border">新的东西</p></p> 尽量不这样用 -->
    <div class="content">
        这是第一级别的文字
        <p class="border">这是里面的新的文字</p>
    </div>
</body>
</html>
```

Tips：

- 一般看见这种 .content .border .player {

  box-shadow:3px 3px 8px 3px rgba(200,200,200,0.5)

  }        # 全都带点，这名字都是自己起的，继承的，然后一般也用于一层层嵌套的样式

- 一般看见这种 .content .border img {

  box-shadow:3px 3px 8px 3px rgba(200,200,200,0.5)

  }        # 前面两个名字是自己起的，后面的 img 是自带的标签名

#### 2.2.4 样式优先级

外部样式<内部样式<内联样式    // 总之就是一句话， 就近原则

优先级权值：
	把特殊性分为4个等级，每个等级代表一类选择器，每个等级的值为其代表的选择器的个数乘以这一等级的权值，最后把所有等级的值相加得出选择器的特殊值。

- !important：加在样式属性值后，权重值为10000，一般加了这个的，样式都以这为准了；
- 内联样式(就是`<p style="">这里面的</p>`)，如：style="",权重值为1000；
- ID选择器，如：#my_content,权重值为100；
- 类、伪类选择器，如：.content、:hover,权重值为10；
- 标签选择器：如：h2、div、p 等 权重值为1。

```html
<head>
    <style>   /* 一定要用style包裹 */
        #content div.main_content h2 {
            color: red;
        }
        #content .main_content h2 {
            color: blue;
            /*color: blue!important;*/
        }
    </style>
</head>
<body>
    <div id="content">
        <div class="main_content">
            <h2>什么颜色？</h2>   <!--红色的-->
        </div>
    </div>

    <h2>这不会有颜色的</h2>  
</body>
```

讲解：

- 上面style中，它不是选择器分组，因为他们之间没有逗号分隔，是样式继承那种；
- 就计算权重值，#content(ID选择器)和h2(标签选择器)都是一样的，都是100×1+1×1，然后div.main_content是“标签指定式选择器”，权重比 .main_content(这就是一个类选择器，名字是随便起的)高一点，所以会是红色的；
- 18行的h2标签是不会有颜色的，因为并没有单独定义h2标签的样式；
- 14行的h2标签，有颜色，也一定要搭配两个父级，因为都是这么定义的。
- 重要：如果想要14行显示蓝色，那就加个!impoertant,把第7行改成==color: blue!important;==.

### 2.3. 字体属性

注意：==要是一个属性有多个值，直接写多个属性，用空格隔开就好了==。如下面的上划线和下划线

- font-size：设置文本大小(如下两种方式)
  - p { font-size: 20px; }      // 固定值尺寸像素
  - p { font-size: 100%}        // 其百分比取值是基于父对象中字体的尺寸大小

---

- font-family：设置字体
  - p {font-family: Courier, "Courier new", monospace; }  // 按此顺序来，如前面的字体被支持就直接使用，后续字体就失效，若是不支持，就以此往后推(若都不支持，就会使用默认字体)；若是字体名包含空格，则用引号括起来，

---

- font-style：设置文本字体的样式(三种属性值)
  - p { font-style: normal; }    // 默认值，正常中的字体
  - p { font-style: italic; }    // 斜体，对于没有斜体变量的特殊字体，将应用 oblique
  - p { font-style: oblique; }   // 倾斜的字体

---

- font-weight：设置文本==字体的粗细==（属性值有 normal、bold、bolder、lighter(比nornal细)、100-900的整数）
  - p { font-weight: normal; }  // 默认值，正常的字体
  - p { font-weight: bold; }    // 粗体
  - p { font-weight: bolder; }  // 比bold粗
  - p { font-weight: 600; }     // 定义由细到粗的字符；400等同于normal,700等同于bold

---

- color：设置文本字体的颜色(三种方式)
  - p { color: red; }                // 方式一：直接使用颜色名字
  - p { color: rgb(100, 13, 200); }   // 方式二：使用rgb函数
  - p { color: #345678; }            // 方式三：指定颜色为16进制(推荐)
    - 一般红色：#ff0000,这种可以简写为#f00，（就是#ff1122，可以简写成#f12，即#AABBCC才可以写成#ABC，像#ff1233就不可以简写，尽量还是不简写）

---

- line-height：设置文本字体的==行高==
  - p { line-height: normal; }      // 默认值，默认行高
  - p { line-height: 24px; }        // 指定行高为长度像素
  - p { line-height: 1.5; }         // 指定==行高为字体大小的倍数==，这里就是行高是字体的1.5倍
  - p { line-height: 2em; }         // 这里也可以是两个字体的高    

---

- text-decoration：设置文本字体的修饰(有无==各种划线==)
  - p { text-decoration: none; }        // 默认值，无修饰
  - p { text-decoration: underline ; }     // 下划线
  - p { text-decoration: line-through; }  // 贯穿线
  - p { text-decoration: overline underline; }      // 上划线  `多个属性直接用空格隔开就好了`

---

- text-align：设置文本字体的对齐方式
  - p { text-align: left; }      // 默认值，左对齐
  - p { text-align: center; }    // 居中对齐
  - p { text-align: right; }     // 右对齐

---

- text-transform：设置文本字体的==字母大小写==（默认值是none，表示无转换发生）
  - p { text-transform: capitalize; }     // 单词首字母转为大写
  - p { text-transform: uppercase; }      //  全部转换为大写
  - p { text-transform: lowercase; }      // 字母全部转换为小写

---

- text-indent：设置文本字体的==首行缩进==
  - p { text-indent: 24px; }   // 首行缩进 number 个像素
  - p { text-indent: 2em; }    // 首行缩进 number 个字符(em这里代表字符，前面2就是2个字符)(推荐这种方式，因为字体大小不同，这样就有一个自适应的效果)

Tips：以上都是针对字体的属性，每个属性都要写一行，为了简单些，有一个font的==复合属性==：

用法：`font: font-style font-variant font-weight font-size/line-height font-family;`

- 一定要注意属性值的位置顺序
- 除了font-size和font-family之外，其它任何一个属性值都可以省略
- font-variant：它的属性值有 normal、small-caps(让小写字母都变大写，且非单词首字母的字母会小写)

示例：(以下，除了18px、微软雅黑这两个值必须要有，其它的值可以省略不要的)

```html
<style>
    em {
        font: italic small-caps bolder 18px/1.5 微软雅黑;
    }
</style>
<body>

    <em>Hello World 这是忙着开着快乐阿达</em>
</body>
```

### 2.4. 背景background属性

- background-color：背景色

  - 直接给color属性值，同上面字体的color属性值
  - transparent     // 透明的，有点去掉背景的意思
- background-image：背景图(说是有加多个背景的方式，疑惑先留在这里吧)

  - none       // 这是默认值，代表没有背景图
  - url(图片路径)   
- background-repeat：图片的铺排方式

  - repeat    // 这是默认值，图片小了，一张铺不满，它就会在纵向以及横向复制铺完
  - no-repeat  // 就用原图大小，铺不满也无所谓
  - repeat-x   // 只在x方向复制，不管y方向
  - repeat-y   // 只在y方向复制，不管x方向
- background-position：设置背景图像所在的位置

  - { x-number | top | center | bottom } { y-number | left | center }   // x、y两个方向的值
    - background-position: 100px center;
    - background-position: 100px 10%;        //多种书写方式
    - background-position: right top;
    - background-position: left;   /* 如果只有一个参数，默认y方向为50% */
  - Tips：与这个同等级的一个属性 height: 2000px;  这个给一下吧，不给可能效果不是那么直观
- background-attachment：设置背景==图像滚动与否==，滚动位置(scroll/fixed)

  - scroll       // 背景图会随着滚动条滑动
  - fixed        // 背景图会固定，不会随着滚动条滑动(无论滚动条滑到哪里，它始终在那个位置)


Tips：以上都是针对background的属性，可以在一个声明中设置所有的背景属性

语法：`background: color image repeat attachment position;`

示例：

```html
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <style>
        /* 这里注释了的是针对单个使用的示例 */
        /*body {*/
        /*    background-color: #eeeeee;*/
        /*    background-color: transparent;  !*使透明了*!*/
        /*    background-image: url(./img/1.png);*/
        /*    background-repeat: no-repeat;  !*默认是repeat，会铺满*!*/

        /*    !*background-position: 100px center;*!*/
        /*    !*background-position: 100px 10%;*!*/
        /*    !*background-position: right top;*!*/
        /*    background-position: center;   !* 如果只有一个参数，默认y方向为50% *!*/
        /*    background-attachment: fixed;*/
        /*    height: 2200px;*/
        /*}*/
        
        /* 这就是一起使用 */
        body {
            background: orange url("./img/1.png") repeat-y fixed 20% 0;
        }
    </style>

</head>
```

### 2.5. CSS选择器补充

#### 2.5.1 伪类选择器

1. 超链接伪类：在支持CSS的浏览器中，链接的不同状态都可以以不同的方式显示（主要就是针对a标签）
   - a:link	 未访问的状态(这个是可以省略掉后面的==:link==，因为这是默认的)
   - a:hover    鼠标悬停状态(即鼠标放上去，不点，它的状态也会改变)
   - a:visited  已被访问状态(即已经点过)
   - a:active   用户激活(即鼠标左键已经点下去但并未松开时)
2. 表单： :focus  （:focus表单获得焦点时触发样式，这么写，就是只要能获得焦点的都会有这个效果）
   - input:focus { backgroud-color: yellow; }   # 这里前面加了input就是说只有input框才会有这个效果，相当于特别指定了，没特别指定的话，那就是大家都可以
3. :first-child  伪类来选择元素的第一个子元素

示例：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>伪类选择器</title>
    <style>
        /* 超链接伪类  */
        a:link {   /* 这里的 :link 可以省去，其它的不能省  */
            color: red;
        }
        a:hover {
            color: orange;
        }
        a:visited {
            color: black;
        }
        a:active {
            color: blue;
        }

        /* 表单 :focus */
        input:focus {
            background-color: red;
            outline: 5px solid #7e982e;   /* 输入框获得焦点时的框 */
        }
        /* 下面也是ul、li  */
        ul li:first-child {
            color: red;
        }   /* li:first-child 和 li:last-child 是固定写法 */
        ul li:last-child {
            color: #7e982e;
        }
        ul li:nth-child(2) {  /* 这里要显示第几个就给数字几 */
            color: orange;
        }

    </style>
</head>
<body>
    <a href="https://baidu.com/">这是一个超链接</a>
    <input type="text">

    <!-- 快速写法 ul>li{aaaa}*4  -->
    <ul>
        <li>aaaa</li>
        <li>aaaa</li>
        <li>aaaa</li>
        <li>aaaa</li>
    </ul>
</body>
</html>
```

#### 2.5.2 属性选择器

可以理解为，好比当有很多p标签，但是只是想对其中一部分的样式做改变，那么就可以通过这个方式：

- [属性名]：包含有指定属性名的元素   # 这里可以理解属性名为字典的key

  ```html
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <title>属性选择器</title>
      <style>
          /* 这就是把div全部设置了 */
          div {
              font-weight: bolder;
          }
          /* 注意content这里不是固定写法，因为下面有两条这个，
           这里只写div.content跟上面div就是一个效果了
           所以这里再加了一个title，以区分是第一个div  */
          div.content[title] {
              color: red;
          }
      </style>
  </head>
  <body>
      <div class="content" title="内容">这是第一条内容</div>
      <div class="content">this is a name!</div>
  </body>
  </html>
  ```

- [属性名=值]：属性名的值为指定值的元素  # 这里理解为要字典的key和value都要对应
  可以理解为当所有的key都相同时，就由不同的value值做出判定

  ```html
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <style>
  		/*  两条都有content和title，就是title的值不一样 */
          div.content[title=内容123] {
              color: red;
          }
      </style>
  </head>
  <body>
      <div class="content" title="内容123">这是第一条内容</div>
      <div class="content" title="内容456">this is a name!</div>
  </body>
  </html>
  ```

  ```html
  <!DOCTYPE html>
  <html lang="en"><head>
      <meta charset="UTF-8">
      <title>属性选择器</title>
      <style>
          /* 这就会把两个都设置了 */
         /*input {*/
         /*    background-color: black;*/
         /*}*/
          /* 这就只设置第一个 */
          input[name=account]{   
              background-color: red;
          }
      </style>
  </head>
  <body>
      <form action="">
          <input type="text" name="account">
          <input type="text" name="users">
      </form>
  </body>
  ```

- [属性名~=值]：属性名的值包含指定值的元素  # 这个没试验出来，总有点问题

- [属性名^=值]：属性名的值以指定值为开头的元素    # 注意：属性可以好几个，以空格隔开

- [属性名$=值]：属性名的值以指定值为结尾的元素  # 有点类似于正则

  ```html
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <title>属性选择器</title>
      <style>
          /* 这就只设置以a头(属性可以是好几个) */
          input[name^=a] {
              background-color: red;
          }
          input[name$=s] {
              background-color: black;
          }
      </style>
  </head>
  <body>
      <form action="">
          <input type="text" name="account age123 name456bb">
          <input type="text" name="account">
          <input type="text" name="users">
      </form>
  </body>
  </html>
  ```

#### 2.5.3 关系选择器

​	简单来说，就是针对同一个标签，若是其所在的层级不一样(被1或2或更多次嵌套)，那么可以选择设定不一样的显示：

- 以空格      所有的后代，无论被多少次嵌套，都会被选择
- \>          这就只会选择儿子元素(第一级的)，多次被嵌套的就不会被选中

+ \+          兄弟元素选中，不好说明，看例子吧

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>关系选择器</title>
    <style>
        /* 一、这会全部选择h1中的strong标签，不管它嵌套了几层 */
        h1 strong {
            color: #2ecaff;
        }

        /* 二、这就只会选中 h2中的儿子标签，span中的strong就不会选中 */
        h2>strong {
            color: aquamarine;
        }
	    
        /* 三、注意这里，是下面的4行被选中了(打印出来看) */
        ul li+li+li {
            color: red;
            list-style-type: none;   /* 这就是去掉前面的小黑点（还可以给其它样式） */
        }
    </style>
</head>
<body>
    <h1>
        <strong>这是儿子中的strong</strong>
        <span>
            这几个字就赢应该无strong的效果<strong>这是span中的strong，算孙子</strong>	         </span>
    </h1>

    <h2>
        <strong>这是儿子中的strong（只有这会有效果）</strong>
        <span>
            这几个字就赢应该无strong的效果<strong>这是span中的strong，算孙子</strong>        	</span>
    </h2>

    <!-- 快捷写法 ul>li{文字内容}*6 -->
    <ul>
        <li>this is a line</li>
        <li>this is a line</li>
        <li>this is a line</li>
        <li>this is a line</li>
        <li>this is a line</li>
        <li>this is a line</li>
    </ul>  <!-- 这个的选择跟我们想的不太一样 -->
</body>
</html>
```

### 2.6. CSS伪元素

​	就理论而言，有些复杂了，我就不多写了。主要用的一个是after和before，他们是能在标签之外添加内容东西，主要的伪元素有：

- ==:before==     在元素之前添加内容（这还不用去改标签内的内容，有点装饰器的味道）

- ==:after==      在元素之后添加内容

- ==:first-letter==  向文本的首字(母)添加特殊的样式

- ==:first-line==    向文本的首行添加特殊的样式

  \# 以上这几个(常用)前面可以是一个冒号，也可以是两个

==::selection==  ==::placeholder== ==::backdrop==      # 这几个(不常用)前面只能是两个冒号

示例：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>伪元素</title>
    <style>
        /* 一、对首字母的处理 */
        p:first-letter {
            font: 60px 黑体;   /* font这种就可以直接给多个字体的属性，以空格隔开 */
            color: #7f55aa;
        }
        /* 二、第一行加红色下划线(这是动态的，无论第一行长度因为页面变化而变化，都只会加第一行) */
        p:first-line {
            text-decoration: underline red;
        }
        /* 三、在p标签内容前加内容 */
        p:before{
            content: "★";  /* content 就是加内容的key */
            margin-right: 50px;  /* 这个 margin-right 就是加的内容距离原内容的距离 */
        }
        /* 四、在p标签之后加内容 */
        p:after {
            content: "这些加的内容是无法被选中的，可用鼠标去选中试试";
            color: aqua;
        }
    </style>
</head>
<body>
    <p>伪元素好难顶哦，多来一点内容不他铺满伪元素好难顶哦！！</p>
</body>
</html>
```

## 三、JavaScript

javasceript组成：

1. ECMAscript javascript的语法：变量、函数、循环语句等语法都是按照这个规则编写的；
2. ==DOM==文档对象模型：操作html和css的方法，如常用的document;
3. ==BOM浏==览器对象模型：操作浏览器的一些方法，如 alert() 的弹窗，以及后面的浏览器定时器等。

### 3.0. js库的使用

​	以[panolens.js](https://github.com/pchen66/panolens.js)这个==360°全景视图==的js项目来说，在其[example](https://pchen66.github.io/Panolens/#Example)中随便选择一个，然后F12把对应的js文件、图片、html内容这些下载下来(这样是为了保证版本可用，下载最新版本的three.js可能会报错)，然后再本地启动服务就可以本地看了。

​	下面代码的核心是 body 中的代码，就是使用这相关的js库。

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, width=device-width, shrink-to-fit=no">
    <title>Panolens.js panorama image panorama</title>
    <style>
      html, body {
        margin: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        background-color: #000;
      }

      a:link, a:visited{
        color: #bdc3c7;
      }

      .credit{
        position: absolute;
        text-align: center;
        width: 100%;
        padding: 20px 0;
        color: #fff;
      }
    </style>
  </head>

  <body>

    <script src="./three.min.js"></script>
    <script src="./panolens.min.js"></script>

    <script>

      const panorama = new PANOLENS.ImagePanorama( './field.jpg' );
      const viewer = new PANOLENS.Viewer( { output: 'console' } );
      viewer.add( panorama );

    </script>

  </body>
</html>
```

注意：

- ==会发现在github上开源大部分的js库，都有一个名为build的文件夹，只需要直接用里面的.js文件就好了==，
  - .js 是原始文件，格式方便看；
  - min.js 是压缩后的对应的js文件，效果一样的
- 这个项目还要依靠three.js，也是只要这个项目build的.js文件就行；
- 都准备好后，本地打开这个html文件，还是无法看到图片，F12会看到报错，搜索后说是==跨域==的问题，但具体我也没有深究，解决方式说是要以服务的方式，于是 python -m http.server 8080  起一个服务，然后就能正常访问了。

### 3.1. js引入方式

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <!-- 第三种（alert的内容直接写到.js文件中去了）  -->
    <script type="text/javascript" src="my_js/my_index.js"></script>
    
    <!-- 第二种 -->
    <script type="text/javascript">
        alert("一打开页面，这就会弹窗");
    </script>
</head>
<body>
    <!-- 第一种 -->
    <input type="button" value="登录" onclick="alert('登录成功！')">
</body>
</html>
```

1. 第一种：==行间事件==：（主要用于事件）
   - onclick是一个点击事件，==alert==代表弹窗，弹窗里面的内容是‘登录成功！’
   - 一定注意：如果是这种方式的话，且有==多个标签嵌套的话==，js的代码(onclick="alert('登录成功！')")一定要放在最外面那个标签，不管那标签是个<a></a>还是<button></button>
2. 第二种：==页面script标签嵌入==：(跟style一样，写到head中的)
   - alert事件是用<script type="text/javascript">  </script> 包裹起来的
3. 第三种：==外部导入==，
   - 对应的js文件就只写了 alert("hello") 这么一句话

注意：这是顺序执行的，这个页面所有出现弹窗的顺序是第三种-->第二种-->第一种，且第一种要点击才会弹窗

### 3.2. js语法基础

#### 3.2.1 变量、属性设置

变量的声明调用：js是弱类型，就一个关键字`var`

命名：第一个字符必须是字母、下划线或者美元符号($)

var iNum = 12;

var name = "hello";

js有5种基本数据类型(如下)： && 1种复合类型：object

1. 数字类型
2. 字符串类型
3. 布尔类型(true或false)
4. undefined类型(变量声明未初始化，它的值就是undefined)
5. null类型(表示空对象，如果定义的变量将来准备保存对象，可以将变量初始化为null，在页面上获取不到对象，返回的值就是null)

赋值属性、获取属性：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <script type="text/javascript">
        window.onload = function() {
            document.getElementById("div1").style.color = "red";
            document.getElementById("div1").style.fontSize="30px";

            /* 用变量来精简代码 */
            var oDiv = document.getElementById("div1");
            oDiv.style.color = "orange";
            oDiv.style.fontSize = "10px"
        }
    </script>
</head>
<body>
    <div id="div1">这是一个div</div>
</body>
</html>
```

解读：

-  window.onload = function() {}  这里面的代码说这里面的内容最后来加载，因为是从上而下加载的原因，直接写里面的内容，或获取不到"div1"，因为那时还没有；
-  document.getElementById 是固定写法,别写错了，byId的内容就是同过div标签中的 id 属性来获取到这个对象；
-  .sty.color = "red" 就是等于 <div id="div1" style="color:red">这是一个div</div> 
-  style.fontSize 它在style中的写法应该是 style.font-size, js中的写法要求凡是带`-`的属性，就不要这个-，然后把后面的字母，也是s大写

#### 3.2.2 js属性写法

1. js里面属性写法和html属性写法一样；
2. “class”属性要写成“className”;
3. html中style属性里面的属性，有横杠的改成驼峰式，比如"style:font-size"，改成"style.fontSize"

下面这就是通过js代码直接改div2的样式为div1的css样式，解读：

- (1)js代码最后把div2的class属性变为box1了，并没有直接去改div2中的代码；
- (1)第10行：html中的class属性一定要写成className；css样式赋值时千万别带前面的点；
- (2)注意第18行，[]这样去获取变量值和直接去.变量值 是一样的；
- (3)==可通过`innerHTML`来获取标签中的内容或是修改==。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <!-- js代码 -->
    <script type="text/javascript">
        window.onload = function() {
           // （1）通过`className`去改成其它的css的样式
           var oDiv2 = document.getElementById("div2");
           // html中的class属性一定要写成className
           oDiv2.className = "box1";     // 这个box1前面一定不能有点啊
            
           
            // （2）可通过`[]`来取变量值
            var oDivStyle = "background";
            var oDivStyle_value = "rgb(0, 0, 0)";
            oDiv2.style[oDivStyle] = oDivStyle_value;  // 核心是这
            // 这两行的效果就是一样的
            // oDiv2.style.background = oDivStyle_value;
            
         
            // （3）通过`innerHTML`来获取标签中的内容或是修改
            var my_content = oDiv2.innerHTML;
            alert(my_content);  // 获取到的内容展示出来
            // 把整个标签里的内容改了
            oDiv2.innerHTML = '<a href="http://www.baidu.com" id="my_link">百度连接</a>';
            
        }
    </script>

    <!-- 写样式 -->
    <style type="text/css">
        .box1, .box2 {
            width: 300px;
            height: 300px;
            background: orange;
        }
        .box2 {
            height: 150px;
            background: hotpink;
        }
    </style>
</head>
<body>
    <div class="box1" id="div1">这是div1</div>
    <div class="box2" id="div2">这是div2</div>
</body>
    
</html>
```

#### 3.3.3 条件语句 ===

运算符：

1. 算术运算符：+  -  *  /  %(模或者求余)

2. 赋值运算符：=  +=  -=  *=  /\*  %=

3. 条件运算符：==  ===  >  >=  <  <=  !=  && || !

   - == 类型不一样，数据一样也会相等，

   - === 先比类型，类型都不一样，就绝不可能再相等了。

     ```javascript
     <script type="text/javascript">
            var v1 = 2;
            var v2 = '2';
            if (v1 == v2) {
                alert("相等");    // 会执行这个
            }
            else {
                alert("不相等");
            }
     
            if (v1 === v2) {
                alert("相等");
            }
            else {
                alert("不相等");  // 会执行这个
            }
     </script>
     ```

   - if else 还有 switch 以及 for 循环条件语句，跟c++的用法都一样

4. 这里面，return还可阻止默认行为，写到这里吧。

#### 3.3.4 数组|数组去重

数组的各种常用方式：

```javascript
    <script type="text/javascript">
        // （1）创建数组var aList01 = new Array(1, 2, 3, 4, 5);  // 有这么个方式，基本不用
        var aList01 = [1, 2, 3, 4, 5];  // 注意是不能 aList01[-1]，没这种用法

        // （2）获取长度
        alert(aList01.length);  // 5

        // （3）下标操作取值， aList01[2]

        // （4）join()将数组成员统过一个指定符号合并成字符串
        alert(aList01.join("-"));  //  1-2-3-4-5
        // 如果给的空字符串， aList01.join(""); 那就是这数组中的所有值拼成一个字符串

        // （5）push()和pop()从数组最后增加或删除成员
        aList01.push("hello");   // 相当于.append("hello")
        alert(aList01);
        aList01.pop();        // 把刚刚新加的"hello"又删除了

        // （6）unshift()和shift()从数组前面增加成员或删除成员
        aList01.unshift(123);  // 那么aList01[0]的结果就是 123 了
        aList01.shift();  // 这就是把前面新增的 123 的删除

        // （7）反转数组
        aList01.reverse();
        alert(aList01);    // 5,4,3,2,1

        // （8）indexOf() 返回数组中元素第一次出现的索引值(这个思想用来数组去重特别好用)
        alert(aList01.indexOf(3));  // 结果是2，就是代表3这个数第一次出现的索引

        // （9）splice()在数组中增加或删除成员
        aList01.splice(2, 1, 7, 6, "hello");
        // 从第2个元素开始，删除1个元素，然后在此位置上新增 7、8、"hello"这三个元素
        // 所以第二个参数可以给0，这样就是 insert的功能了：aList01.splice(2, 0, "hello"); 就是单纯的在第二个位置插入一个hello
    </script>
```

Tips：

- 多维数组：var li = [[1, 2, 3], ['a', 'b', 'c']]  用法一模一样，li[0]\[1]的结果就是2 

- 数组第（8）点用来给==数组去重==(Python可以参考哈)

  ```javascript
      <script type="text/javascript">
          var li = [1, 3, 3, 5, 7, 4, 6, 5, 7];
          var result = [];
          for (var i = 0; i < li.length; ++i) {
              // （1）按索引取数字，当这个数组第一次出现的索引值等于i，就代表它是第一次出现，否则就不是
              if (li.indexOf(li[i]) == i) {
                  result.push(li[i]);
              }
          }
          alert(result);
      </script>
  ```

- js通过for循环，来给网页添加数据，一般很少这么写吧，就是通过给innerHTML属性赋值，值是一些标签，这就跟前面web后端给前端传递网页数据类似了（视频：".\就业班\09 JavaScriptv\04-数组和循环语句\03for循环-实例.flv" 大概第10分钟左右）

#### 3.4.5 字符串的方法

```javascript
    <script type="text/javascript">
        //（1）合并操作：+ 可以是int+str,int会当做str处理
        alert(12 + "hello");

        //（2）parseInt() 将数字字符串转为整数
        parseInt(12.13);  // 结果会是12

        //（3）parseFloat() 转小数
        parseFloat(12.13);  // 12.13

        //（4）split() 把一个字符串按给定的分隔符，分割成数组
        var str04 = "2012-13-14";
        alert(str04.split("-"));  // 返回值是 [2012, 13, 14]
        str04.split("");  // 分割符是空字符的话，结果就是 [2, 0, 1, 2, -, 1, 3, -, 1, 4]

        //（5）charAt() 通过索引获取字符串中的某一个字符
        var num5 = str04.charAt(2);  // 就取str04字符串索引为2的字符

        //（6）indexOf() 查找字符串是否含有某字符，找到就返回匹配开头位置的索引值，没有就返回-1
        var str06 = "abcdef micro 123as";
        var num6 = str06.indexOf("mic");  // 7
        var num6_1 = str06.indexOf("hello");  // 没找到就是返回-1

        //（7）substring()截取子字符串，和c++的用法基本一样
        var str07 = str06.substring(3, 10);  // 截取3-10，不包括10，"def mic"
        // 同样，不给第二个参数，就是从第一个位置开始截取完

        //（8）toUpperCase() 字符串转大写
        var str08 = str06.toUpperCase()

        // （9）toLowerCase() 字符串转小写
        var str09 = str08.toLowerCase()

        //（10）字符串反转
        var str = "123abc";
        var res = str.split("").reverse().join("");
        // 先转数组，再reverse(),再转成字符串
    </script>
```

以下是网页上让输入两个整数，然后相加：（注意下面的==+==和=====可以不用标签包裹起来）:

```html
<head>
    <title>Document</title>
    <script type="text/javascript">
        window.onload = function() {
            // (1)先获取到每个对象
            var iNum1 = document.getElementById("num1");
            var iNmu2 = document.getElementById("num2");
            var btn = document.getElementById("btn");

            btn.onclick = function() {
                // (2)注意 .value 可能不会只能提示，但它确实是存在的（页面传进来的肯定是str类型）
                var n1 = parseInt(iNum1.value);  // (3)通过parseInt将字符串转为int
                var n2 = parseInt(iNmu2.value);
                // (4)把结果弹窗显示出来，
                alert(n1 + n2);
            }
        }
    </script>
</head>
<body>
    <input type="text" name="num" placeholder="请输入一个整数" id="num1"/>
    +
    <input type="text" name="num" placeholder="请输入一个整数" id="num2"/>
    =
    <button id="btn">计算</button>
</body>
```

### 3.3. 隐藏/显示样式

​	style中默认是开启了样式的，在style中display属性默认是空，也是代表开启了的：

- 当设置style="display: block;"也是代表开启样式，
- 如要关闭样式，style="display: none;" 所以要用过js来控制一个按钮开启或是关闭样式也很很常用：

```html
<head>
    <script type="text/javascript">
    window.onload = function() {
        var btn = document.getElementById("btn");
        var oBox = document.getElementById("div1");
	    // (1)此时oBox.style.display得到的是个空值（那么判断语句无论是判断=="none"还是=="block"都是false），默认也是开启了样式了，所以一定会执行else；
	    // 所以如果判断语句写成 oBox.style.display == "block" ，那么else中就会是oBox.style.display == "block",那么第一次点击就不会将效果隐藏(默认是开启样式,属性为空，又把样式属性设为block，肯定不会有下效果)
        btn.onclick = function() {
            if (oBox.style.display == "none") {  // 判断语句这么写是有深意的，用这种
                oBox.style.display = 'block';  // 开启样式
            }
            else {
                oBox.style.display = 'none';  // 关闭样式
            }
        }
    }
    </script>
    <style type="text/css">
        .box {
            width: 200px;
            height: 200px;
            background-color: orange;
        }
    </style>
</head>
<body>
    <input type="button" id="btn" value="切换">
    <div class="box" id="div1"></div>
</body>
</html>
```

#### document.getElementsByTagName

除了上面的==document.getElementById==，常用的还有：

​	document.getElementsByTagName("li") 获取元素对象

​	可以使用内置对象document中的==getElementsByTagName==方法来获取页面上的某一种标签，获取的是一个==选择集，不是数组==，但是==可以用下标的方式操作==选择集里面的标签元素：

```html
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <script type="text/javascript">
        window.onload = function() {
            // （1）这里得到的就是一个选择集，不是数组，  "li"就是指的<li></li>标签
            var aLi = document.getElementsByTagName("li");  // 名字千万别写错了
            // （2）获取选择集的的元素个数
            alert(aLi.length);  // 8个，会得到所有的li标签

            // （3）给li标签一个style
            // 这是错误的，不能这么直接一次性设置，它是一个选择集，必须通过下面的循环
            // aLi.style.backgroundColor = "orange";
            for (var i = 0; i < aLi.length; ++i) {
                // （4）给偶数行上色，但更多的是用 CSS3 完成这种设置
                if (i % 2 == 0) {
                    aLi[i].style.backgroundColor = "orange";
                }
            }

            // （5）如果想选中 <ul class="list2"> 中的li，而不是全部的li,那就：
            // - 先通过id拿到这个对象
            var oUl = document.getElementById("list2");
            // - 再通过这个对象来拿到里面的所有li标签
            var aLi2 = oUl.getElementsByTagName("li");
            alert(aLi2.length);
        }
    </script>
</head>
<body>
    <ul id="list1">
        <li>1</li>
        <li>2</li>
        <li>3</li>
        <li>4</li>
        <li>5</li>
    </ul>
    <!-- 快速写法 ul.list2>li*3    ul.list2>li{"123"}*3  这就会把li标签中的值快速填充  -->
    <ul id="list2">
        <li>13</li>
        <li>14</li>
        <li>15</li>
    </ul>
</body>
```

### 3.4. js函数的使用

定义：function 函数名() {}     // 可以定义参数及return返回值

​	首先js会预解析，预解析会把变量的声明提前，即变量使用之前没有声明或定义，但在使用之后的代码里是有声明或是定义的，那么得到的变量的值就会是==undefined==,

​	但如果是函数，只要有函数的实现，调用函数的代码在函数定义之前也是可以的，因为js的预解析会把声明提前。

```javascript
<script type="text/javascript" >
    var iNum;      // （1）
    alert(iNum);   // 无论哪种弹出来的一定的undefined
    // var iNum = 123;  （2）
    iNum = 5;      // （1）
    
	alert(num2);  // 这种直接调用一个不存在的，那就会报错
	

	// 函数这中就是OK的，调用在函数定义之前
    myalert();
    function myalert() {
        alert("hello");
    }
</script>
```

且这个函数也可以传参，有返回值，是弱类型，各种都可以相加，形参前也不用加var

```javascript
<script type="text/javascript" >
    function myAdd(a, b) {
        var out = a + b;
        return ("string和int相加了：" + out)
    }
    var result = myAdd(1, 2.1);
    alert(result);
</script>
```

---

js函数的定义。简单使用：（以下是在html中调用js代码中函数，不提倡使用）

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>function</title>
    <script type="text/javascript">
        function myAlert() {
            alert("函数的弹窗");
        }

        function chText() {
            var oDiv1 = document.getElementById("div1");
            oDiv1.innerHTML = "把显示的数据改了";
            oDiv1.style.color = "red";
            oDiv1.style.fontSize = "30px";
        }
    </script>
</head>
<body>
    <!-- 注意要点击这段文字才会有效果，因为是onclik;;注意这里函数调用的话要带括号 -->
    <div id="div1" onclick="myAlert()">这是函数的学习</div>
    <!-- 下面整个按钮，来改变上面div中的内容 -->
    <input type="button" id="btn1" value="点击" onclick="chText()">
</body>
</html>
```

解读：

- 先是定义了一个div，里面有onclick事件，点击文字，就会调用函数，实现谈弹窗；
- div下紧跟了一个button，它也调用了一个函数，是用来点击修改div中的内容和样式；
- 注意：这里函数的定义没有用==window.onload = function() {}==包裹起来，是因为函数的执行就在html代码里，可以不用最后再加载。

但是以上，还是把js的代码写到html中，不要这种写法，js还是要单独写，接着上面的代码，做一点改造：（==这是把js代码写出来，去修改html中的属性==）

```html
<head>
    <title>function</title>
    <script type="text/javascript">
        /* （1）这就要用这包裹起来了，不然会直接运行到getElementById，就会报错 */
        window.onload = function() {
            /*（2） 获取到按钮，然后让其onclick属性等于 要去执行的函数名 */
            var obtn1 = document.getElementById("btn1");
            obtn1.onclick = chText;  /* （3）注意这里不能有()。不然就直接是函数的执行了 */

            function chText() {
                var oDiv1 = document.getElementById("div1");
                oDiv1.innerHTML = "把显示的数据改了";
                oDiv1.style.color = "red";
                oDiv1.style.fontSize = "30px";
            }
        }
    </script>
</head>
<body>
    <div id="div1">这是函数的学习</div>
    <input type="button" id="btn1" value="点击">
</body>
```

Tips：

- 上面的核心是7、8行，获取到button的变量，然后将其onclick属性赋值为定义的用来改变div标签属性的函数；

- 这是用 window.onload = function() {} 包裹起来了的，不然直接顺序执行到第7行是不行的，都还没那个标签；

- ==匿名函数==：

  - 注意第8行，意义不大，直接就赋值的函数名，那不如就用匿名函数，那么第8行就可以写成

  - 相当于定义里没要函数名了，直接 function () {}

    ```javascript
    // 改成匿名函数
    obtn1.onclick = function () {      // 
    	var oDiv1 = document.getElementById("div1");
    	oDiv1.innerHTML = "把显示的数据改了";
    	oDiv1.style.color = "red";
    	oDiv1.style.fontSize = "30px";
    }
    ```


#### 3.4.1. 案例，网页换肤

案例，网页换肤：（==就是通过botton的onclick的点击事件，来改变css的href引入属性达到换肤==）

（1）css文件：（.box1这种前面带点.的，html中属性引入时都是用的class=".box1"）

skin_orange.css

```css
body {
    background-color: orange;
}
/*
box, .box1, .box2 {
    font-size: 30px;
    border-radius: 15px;
}
*/
/*  不应该上面那么写，都是 input 这个标签,直接input设置总的属性，再用里面的box1自定义增加不一样的 */
input {
    font-size: 30px;
    border-radius: 15px;
}
.box1 {
    color: orange;
}
.box2 {
    color: hotpink;
}
```

skin_pink.css

```css
body {
    background-color: hotpink;
}
input {
    font-size: 30px;
    border-radius: 15px;
    border: 0;   /* 这就是不要边框那圈黑的 */
}
.box1 {
    color: orange;
}
.box2 {
    color: hotpink;
}
```

skin.js

```javascript
window.onload = function () {
    var btn1 = document.getElementById("btn1");
    var btn2 = document.getElementById("btn2");
    var skin_link = document.getElementById("my_link");

    // 用函数来改变成导入的外部的css的href链接属性就好了
    btn1.onclick = function () {
        skin_link.href = "my_css/skin_orange.css";
    }
    btn2.onclick = function () {
        skin_link.href = "my_css/skin_pink.css";
    }
}
```

skin.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>skin</title>
    <!-- （1）引入css样式文件 -->
    <link rel="stylesheet" href="my_css/skin_orange.css" id="my_link">
    <!-- （2）引入js文件，来实现函数的换肤功能 -->
    <script type="text/javascript" src="my_js/skin.js"> </script>
</head>
<body>
    <input type="button" value="橘色皮肤" id="btn1" class="box1">
    <input type="button" value="粉色皮肤" id="btn2" class="box2">
</body>
</html>
```

#### 3.4.2. 封闭函数

使用场景：
	在从别的地方导入进了js文件，里面有函数变量，自己如果不清楚，恰巧写了同名的变量、函数，就会将原来的功能覆盖掉，特别是新加功能时，很可能遇到覆盖旧功能的情况，那此时就要用封闭函数：

格式简单的来说，就是  (function (){自己的函数、变量写这里})() 

```
;(function () {
	var num = 24;
	function myalert() {
		alert("hello");
	}
	alert(num);
	myalert();
})()
```

解读：

- 最后一对括号()就相当于是调用这个封装函数了，那么第6、7行就会直接执行；
- 如果这时这个文件导入的js文件中，也有一个变量叫做num，值是12，也有一个名为myalert的函数，这时在封装函数外面调用alert(num);得到的是12，myalert();也是执行它原本的内容，就不会被覆盖掉。
- ==封装函数还有别的写法==：
  - 把那对括号换成 ！ ，即  !function () {自己的函数、变量写这里}()
  - 把那对括号换成 ~  ，即  ~function () {自己的函数、变量写这里}()

- 第一行那里加分号，是因为js代码可能会压缩程一行，避免跟别的代码混合在一起了，保险起见加个分号。

### 3.5. 定时器

定时器在javascript中的作用：

1. 制作动画
2. 异步操作
3. 函数缓冲与节流

定时器：

- setTimeout(函数名，int)    只执行一次的定时器

  - 函数名这里可以给一个匿名函数；
  - int这里是给一个整数值，代表多少ms时间后，定时器执行

- clearTimeout  关闭只执行一次的定时器

  ```javascript
      <script type="text/javascript">
          function myalert() {
              alert("hello");
          }
          // 不管有没有返回值，定时器都是会执行的，给个返回值就只是为了clearTimeout可以获取到它
          var st = setTimeout(myalert, 2000);  // 2s后弹窗
          clearTimeout(st)  // 加了这句，这就不会弹窗了，定时器没执行，就背着关
      </script>
  ```

  ---

- setInterval(函数名，int)   反复执行的定时器

- clearInterval 关          闭反复执行的定时器

  ```javascript
      <script type="text/javascript">
          function myalert() {
              alert("hello");
          }
  	    // 这就是用的匿名函数
          setInterval(function() {
              alert("world");
          }, 5000);  // 每5秒钟弹窗一次
  
  		// 若想要关闭它，必须将其赋值于一个对象，即 var obj = setInterval...
  		clearInterval(obj);
      </script>
  ```

#### 3.5.1 定时器做动画

第一步：简单的让一个div盒子，从==左边的地方往右边移动==：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>定时器动画</title>
    <script type="text/javascript">
        window.onload = function() {
            var oDiv = document.getElementById("box1");
            // alert(oDiv.style.height);  // 不能这样直接来获得，得到的结果是空，必须要直接赋值
            // oDiv.style.display = "none";  // 让整个样式不起作用
		   
            // 方式一：（演示时屏蔽掉其中一个）
            var abs_pos = 0;
            function addLeft() {
                abs_pos += 2;
                oDiv.style.left = abs_pos + "px";  // 别忘了加px，不然是错的
                // 大于700时就关闭掉这个定时器
                if (abs_pos > 700) {
                    clearInterval(timer1);
                }
            }
            var timer1 = setInterval(addLeft, 10);  // 注意要这个返回值，不然不好关闭定时器

		   // 方式二：匿名函数
            var timer2 = setInterval(function () {
                abs_pos += 2;
                oDiv.style.left = abs_pos + "px";  // 别忘了加px，不然是错的
                if (abs_pos > 700) {
                    clearInterval(timer2);
                }
            }, 10)
        }
    </script>
	
    <style type="text/css">
        .box {
            width: 300px;
            height: 300px;
            background-color: hotpink;
            position: absolute;  /* 有了这个参数，设置的下面的这俩参数才有用 */
            left: 0;
            top: 100px;
        }
    </style>
</head>
<body>
    <div id="box1" class="box"></div>
</body>
</html>
```

第二步：让这==来回反复的运动==：（只保留js的代码，其它都一样）

```html
    <script type="text/javascript">
        window.onload = function () {
            var oDiv = document.getElementById("box1");
            var abs_pos = 0;
            var speed = 2;  // 加一个变量把速度存起来，后面好改
            function addLeft() {
                abs_pos += speed;
                oDiv.style.left = abs_pos + "px";  // 别忘了加px，不然是错的
                // 大于700时不是关闭掉这个定时器，而是让speed称为负数，就往左运动了
                if (abs_pos > 700) {
                    speed = -2;
                }
                // 这里不能是if else，必须是两个if
                if (abs_pos <= 0) {
                    speed = 2;
                }
            }
            var timer1 = setInterval(addLeft, 10);
        }
    </script>
```

---

​	如果是要做连续==滚动效果==，就看（".\就业班\09 JavaScriptv\06-定时器和变量作用域\02无缝滚动01.flv"），里面的思想还是不错：

​	其实滚动就是把一张平面图通过 innerHTML = innerHTML + innerHTML 把标签里内容复制了一份，这样滑动时就可以了，当第二份即将滑动完时，做个判断，立马又把图定位回最开始的位置。

#### 3.5.2 放鼠标暂停

​	接着上面，一般自己动滑动时，把鼠标放上去就会暂停(就是把速度设为0)，移开又动起来(把速度设回去),下面的代码只是示意：

```
var oDiv = document.getElementById("div1");
var iSpeed = 2;  // 原来在动
var iNowSpeed = 0;   // 一个变量
// 匿名函数
// 鼠标移入时，把此时速度存起来，再把速度设为0，就停止了
oDiv.onmouseover = function () {
	iNowSpeed = iSpeed；
	iSpeed = 0；
}
// 鼠标移出时，就把速度设回来
oDiv.onmouseout = function () {
	iSpeed = iNowSpeed;
}
```

解读：

- oDiv是通过getElementById获取到的一个对象；
- 鼠标事件跟 oDiv.onclick 这个是一个意思：
  - 鼠标移入：oDiv.==onmouseove==
  - 鼠标移出：oDiv.==onmouseout==

#### 3.5.3 实时时钟

实时显示的时钟：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>时钟</title>

    <script type="text/javascript">
        window.onload = function () {
            var oDiv = document.getElementById("div1");
		    // 从这里封装函数，这样时间才会更新
            function TimeGo() {
                var now = new Date();  // 这是系统的方法

                // 1、获取年份
                var year = now.getFullYear();
                // 2、获取月份(注意，月份是0-11，所以要+1)
                var month = now.getMonth() + 1;
                // 3、获取日
                var iDate = now.getDate();
                // 4、星期几也是从0-6，且0是星期天
                var week = now.getDay();
			   // 5、时
                var hour = now.getHours();
			   // 6、分
                var min = now.getMinutes();
  			   // 7、秒
                var sec = now.getSeconds();
			   //  把时间拼接起来
                var sTr = "当前时间是：" + year + "年" + month + "月" + iDate + "日" 
                + " 星期" + week + " " + hour + ":" + min + ":" + sec;
                oDiv.innerHTML = sTr;
            }
            TimeGo();  // 注意：因为定时器要等一秒钟才调用，进来是没东西的，就先调用一次
            setInterval(TimeGo, 1000);
        }
    </script>
    <style type="text/css">
        .box1 {
            font: italic small-caps bolder 18px/1.5 微软雅黑;
            color: hotpink;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="box1" id="div1"></div>
</body>
</html>
```

Tips:

- 注意月份，还有星期几，星期几返回的也是数子，可以写一个switch语句将其转变成大写；
- 注意要先让函数先单独执行一次，不然一进来页面是会空白一秒钟；
- 分、秒这些，也会出现 5、6这钟，可以通过一个函数来将其变为05、06这种。

#### 3.5.4 倒计时

距离未来某一个时间的倒计时：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>倒计时</title>
    <script type="text/javascript">
        window.onload = function () {
            var oDiv = document.getElementById("div1");

            function timeLeft() {
                // 注意，这是读取的本地时间，是可以修改的，实际开发中是要读取后台服务器的时间，通过ajax读取
                var now = new Date();

                // 未来时间（离未来的51还有多久）(两个写法一样，注意月份是从0开始，要比实际小1)
                var future = new Date(2022, 3, 30, 24, 0, 0);
                // var future = new Date(2022, 4, 1, 0, 0, 0);
                // 剩下的时间，毫秒要换成秒
                var lefts = parseInt((future - now) / 1000);
			   // parseInt(3.99);  得到的结果就是 3
                var day = parseInt(lefts / 86400);
                var hour = parseInt(lefts % 86400 / 3600);
                var min = parseInt(lefts % 86400 % 3600 / 60);
                var sec = lefts % 60;
                oDiv.innerHTML = "距离2022年4月31日晚24点还剩下：" + day + "天" + hour + "时" + min + "分" + sec + "秒";
            }
            timeLeft();   // 注意：因为定时器要等一秒钟才调用，进来是没东西的，就先调用一次
            setInterval(timeLeft, 1000);
        }
    </script>
    <style type="text/css">
        .box1 {
            font: italic small-caps bolder 18px/1.5 微软雅黑;
            color: hotpink;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="box1" id="div1"></div>
</body>
</html>
```

Tips：

- 一定要注意==写未来的日期时，那个月份是从0开始，所以想要的月份要给小一个1==；
- parseInt(3.99);  得到的结果就是 3

### 3.6. 常用内置对象

（注意加不加括号的使用）

document:

- document.getElementById();          // 通过id属性获取元素
- document.getElementsByTagNameNS();   // 通过标签名获取元素
- document.referrer                   // 获取上一个跳转页面的地址(需要服务器环境)
  - 在浏览器的console中输出 document.referrer 就可以看到上一个页面的地址（比如没登录浏览商品，看到一个想买，登录后肯定是跳转回该商品界面的体验最好，那就要用到这个来记录上次的网页地址）

location：

- ==window.location.href==   // 获取或者重定url地址

  示例：（不再是给button标签上加 <a></a> 标签来跳转，而是通过js的事件控制）

  ```html
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <title>内置对象</title>
      <script type="text/javascript">
          window.onload = function () {
              var oDiv = document.getElementById("btn1");
              // 这是通过程序的点击跳转
              // oDiv.onclick = function () {
              //     window.location.href = "http://www.baidu.com";
              // }
              
              // 这就是把鼠标移上去就会跳转
              // 可搭配前面的 document.referrer 使用，先把这存起来
              // var before_url = document.referrer;  // (1)
              oDiv.onmouseover = function () {
                  window.location.href = "http://www.baidu.com";
                  // 然后重定向链接时就给前面保存的地址
                  // window.location.href = before_url;  // （1）
              }
          }
      </script>
  </head>
  <body>
      <input type="button" VALUE="跳转" id="btn1">
  </body>
  </html>
  ```

- ==window.location.search==      // 获取html页面跟的参数

  - index.html?aa456%789       //那么window.location.search获取的就是 ?aa456%789

  - 注意，.html后一定是要紧跟==?==才行，跟其它符号或是内容，都会是404
    示例：

    ```html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Title</title>
        <script type="text/javascript">
            window.onload = function () {
                var oBody = document.getElementById("body1");
    
                var data = window.location.search;  // 会得到?以及后面的所有字符串
    
                var num = data.split("=")[1];  // 这个是没有[-1]的写法的
                var color = "";
                switch (parseInt(num)) {
                    case 1:
                        color = "orange";
                        break;
                    case 2:
                        color = "hotpink";
                        break;
                    default:
                        color = "green";
                }
                oBody.style.backgroundColor = color;
            }
        </script>
    </head>
    <body id="body1">
        <div>hello</div>
    </body>
    </html>
    ```

- window.location.hash     // 获取页面锚点或者叫哈希值

### 3.7. 调试 | Math对象

调试的方法，

- ==alert(一个变量名);==     // 通过弹窗的方式将其打印出来=

  - 这会阻止程序后续的运行

- ==console.log(比如一个数组的名字);==       // 就可以在浏览器的console里看到对应的数据=

  - 这不会阻止程序运行，可直接在console控制台看数据
  - console里面还有很多其它的方法，看后面用到再说吧
  - Math是内置对象，有点像python自带的库，且还不需要导入
  - 几个常用的Math对象中的函数：
    - Math.random()   // 获取0-1的随机数，不包括1
    - Math.floor(5.6)    // 向下取整,5
    - Math.ceil(5.3)     // 向上取整,6
    - Math.round(n)      // 四舍五入

  注意：==var num = (max - min) * Math.random() + min;==这种生成随机数的写法

  ```html
  <script type="text/javascript">
      var pi = Math.PI;
      // 生成指定范围的随机整数数(包括最大最小)
      var min = 23;
      var max = 28;
  
      var arr = [];
      for (var i = 0; i < 10; ++i) {
          // 特别注意这种随机生成不规则范围内的数的写法
          var num = (max - min) * Math.random() + min;
          arr.push(Math.round(num));  // 四舍五入，那么 27.5及以上的数就会成为28
      }
      console.log(arr);  // 浏览器 F12 的console控制台就可以看到相关数据了
      console.log(pi);
  </script>
  ```

- ==document.title==   // 改变标题title的方式 (这就会看到页面标题一直在变)

  ```html
  <script type="text/javascript">
      // 生成指定范围的随机整数数(包括最大最小)
      var min = 23;
      var max = 28;
      // 通过定时器循环打印
      setInterval(function () {
          var new_num = Math.round((max - min) * Math.random() + min);
          // （1）通过console控制台的方式
          console.log(new_num);
  
          // （2）改变标题title的方式 (这就会看到页面标题一直在变)
          document.title = new_num;
      }, 500)
  </script>
  ```





