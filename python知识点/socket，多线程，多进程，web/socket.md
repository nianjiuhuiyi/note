`client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)`

- family中一般两个参数：AF_INET(用于inretnet进程通信)、AF_UNIX(同一台机器进程间通信)
- type一般也是俩：SOCK_STREAM(TCP)、SOCK_DGRAM(UDP)
- 流程：创建套接字、收/发数据、关闭套接字

UDP、TCP[原理](https://zhuanlan.zhihu.com/p/108822858)。

## UDP

udp 分单工(像收音机，只能接收)、半双工(对讲机，讲完了才能收)、全双工(电话，可是同时发消息、收消息)

```python
import socket
# 发送消息
def send():
    # 1、创建套接字
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    udp_socket.bind(("", 9999))  
    # 发可绑定也可不绑定端口，收才要指定端口（但那这样对面收到的端口信息一直在变）
    # udp_socket.sendto(b"aaaaa", ("192.168.1.6", 7788))  # 这是目标ip和端口

    while True:
        send_data = input("请输入发送的内容:")
        udp_socket.sendto(send_data.encode("utf-8"), ("192.168.1.6", 7788))   		 # 接收的ip和端口要一直啊
        if send_data == "exit":
            break
    udp_socket.close()


if __name__ == '__main__':
    send()
```

```python
# 接收
import socket

def receive():
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    local_addr = ("", 7788)   # ip不用写，表示本机，端口不指定，系统会随机分配，（收还是一定要指定）
    udp_socket.bind(local_addr)  # 必须要绑定本地的相关信息
    while True:
        receive_data = udp_socket.recvfrom(1024)      # 1024表次本次接收的最大字节数
        # print(receive_data)   # 元祖  --> (内容, (ip,port))  #后面是发送方的ip和端口
        out = receive_data[0].decode("utf-8")
        print(out)
        if out == "exit":
            break
    udp_socket.close()


if __name__ == '__main__':
    receive()
```

## TCP

tcp是分服务器和客户端的  （更好的是看web学习.md中的“2.3. 单进程、单线程实现非堵塞并发”）

​	client

```python
import socket
def client():
    # 1、创建socket
    tcp_client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)   # 注意是socket.SOCK_STREAM
    # 客服端还是不要绑定端口了

    # 2、连接服务器
    tcp_client_socket.connect(("192.168.1.5", 8090))   # 服务器的ip和端口，记得以元祖的形式

    while True:
        # 3、输入数据
        send_data = input("请输入要发送的数据：")  # 这里面的提示数据不会算到输入的内容里
        if send_data == "exit":
            break
        tcp_client_socket.send(send_data.encode("utf-8"))

        # 接收对方发送过来的数据，最大接收1024个字节  (因为服务器可能不止发一个数据，用循环等待，只有当服务发数据的套接字调用.close()的，这里才为空，然后退出去)
        print("接收到的数据为：")
        while True:
        	receive_data = tcp_client_socket.recv(1024).decode("utf-8")
            if not receive_data:
				break
        	print(receive_data)   # 因为上面设定了连接的服务器，所以直接收到的就是数据

    # 4、关闭套接字
    tcp_client_socket.close()

if __name__ == '__main__':
    client()
```

​	server

```python
import socket

def server():
    # 1、创建套接字(参数上面有解释)
    tcp_server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # 2、绑定本地信息（别人要来连接服务器，ip、端口不能一直变的）
    tcp_server_socket.bind(("", 8090))   # 注意是元祖

    # 3、 使用socket创建的套接字默认的属性属主动的，使用listen将其变为被动的，这样就可以接受别人的链接的
    tcp_server_socket.listen(128)  # 一般就是128

    # 一个客户完了后，要不停的接后面的客户
    while True:
        # 4、如果有新的客户端来链接服务器，那么就会产生一个新的套接字专门为这个客服服务
        # 一旦监听到了，这个服务器的套接字就会搞一个新的套接字去服务，然后就可以接受别的client的请求了（哪怕在while中）
        a_client_socket, client_address = tcp_server_socket.accept()
        print("正在服务{}客户。".format(client_address))
        
        # 一个客户可能有多个请求
        while True:
            # 5、接收client发送过来的数据
            receive_data = a_client_socket.recv(1024)   # 这里的方法注意跟UDP的不同，因为上面有地址了，这里直接就是收的数据
            receive_data = receive_data.decode("utf-8")
            if receive_data == "exit":
                break
            print("客户端发过来的消息是:{}".format(receive_data))
            # 回一些数据回客户端
            a_client_socket.send("服务器已经收到消息了！".encode("utf-8"))

        # 关闭套接字，就代表不再为这个客户端服务了
        a_client_socket.close()
        print("已经为客户{}服务完毕。".format(client_address))
        print("--------------------分隔符------------------------")

    # 6、最后关闭服务端的套接字
    tcp_server_socket.close()

if __name__ == '__main__':
    server()
```

