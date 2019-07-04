# docker安装（Ubuntu 18.04.1 LTS）：
>docker version： 18.09.7
1. 更换软件源为国内软件源：
    + 替换/etc/apt/source.list内容：
        ```
            sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
        ```
    + 更新缓存：
        ```
            apt update
        ```
2. 安装所需包：
    ```
        apt install apt-transport-https ca-certificates software-properties-common curl
    ```
3. 添加GPG密钥，并添加docker-ce的软件源：
    + 添加密钥：
        ```
            curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | apt-key add -
        ```
    + 添加软件源：
        ```
            add-apt-repository "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
        ```
    + 更新缓存：
        ```
            apt update
        ```
4. 安装docker-ce：
    ```
        apt install docker-ce
    ```
    >安装后自动启动了docker服务
5. 查看docker版本信息：
    ```
        [root@docker ~]#docker version
        Client:
        Version:           18.09.7
        API version:       1.39
        Go version:        go1.10.8
        Git commit:        2d0083d
        Built:             Thu Jun 27 17:56:23 2019
        OS/Arch:           linux/amd64
        Experimental:      false

        Server: Docker Engine - Community
        Engine:
        Version:          18.09.7
        API version:      1.39 (minimum version 1.12)
        Go version:       go1.10.8
        Git commit:       2d0083d
        Built:            Thu Jun 27 17:23:02 2019
        OS/Arch:          linux/amd64
        Experimental:     false
    ```
6. 查看docker0网卡信息：
    >docker安装启动后，默认会生成一个叫docker0的网卡，且默认IP为地址为172.17.0.1
    ```
        [root@docker ~]#ifconfig docker0
        docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:d1:07:0d:3b  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0 
    ```
7. docker镜像加速配置：
    >国内下载国外的镜像有时候会很慢，因此可以更改docker配置文件添加一个加速器，可以通过加速器达到加速下载镜像的目的
    + 生成配置文件：
        ```
        [root@docker ~]#tee /etc/docker/daemon.json <<-'EOF'
        > {
        > "registry-mirrors": ["https://gnsn4usf.mirror.aliyuncs.com"]
        > }
        > EOF
        ```
    + 验证：
        ```
        [root@docker ~]#cat /etc/docker/daemon.json
        {
        "registry-mirrors": ["https://gnsn4usf.mirror.aliyuncs.com"]
        }
        ```
8. 重启docker服务：
    ```
    [root@docker ~]#systemctl daemon-reload
    [root@docker ~]#systemctl restart docker
    ```
# docker服务进程：
## containerd进程关系：
+ dockerd：被client直接访问，其父进程为宿主机的systemd守护进程

+ docker-proxy：实现容器通信，其父进程为dockerd
+ containerd：被dockerd进程调用以实现与runc交互
+ containerd-shim：真正运行容器的载体，其父进程为containerd
# 容器的创建与管理过程：
+ 通信过程：
    1. dockerd通过grpc和containerd模块通信，dockerd有libcontainerd负责和containerd进行交换
    >dockerd和containerd通信的socket文件：/run/containerd/containerd.sock

    2. containerd在docke启动时被启动，然后containerd启动grpc请求监听，由containerd处理grpc请求，根据请求做响应动作
    3. 若是start或是exec容器，containerd拉起一个containerd-shim，并进行响应操作
    4. containerd-shim被拉起后，start/exec/create拉起一个runc进程，并通过exit、control文件和containerd通信，通过父子进程关系和SIGCHLD监控容器中进程状态
    5. 在整个容器的生命周期中，containerd通过epoll监控容器文件和容器事件  
    ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E8%BF%9B%E7%A8%8B%E6%A0%91.png)  
# docker镜像管理：
## docker镜像：
>docker镜像含有启动容器所需要的文件系统及所需要的内容，因此镜像主要用于创建并启动docker容器
```
    docker镜像中是一层一层的文件系统，叫Union FS（联合文件系统），联合文件系统可以将几层目录挂载到一起，形成一个虚拟文件系统，这个虚拟文件系统的目录结构就像普通的Linux的目录结构一样，docker通过Union FS下的文件再加上宿主机的内核提供了一个Linux的虚拟环境

    每一层文件系统被称为一层layer，Union FS可以对每一层文件系统设置三种权限：readonly（只读）、readwrite（读写）、writeout-able（写出）
    
    但docker镜像中每一层文件系统都是只读的，构建镜像的时候从一个最基本的操作系统开始，每个构建的操作都相当于做了一层的修改，增加了一层文件系统，就这样一层层向上叠加，上层的修改会覆盖底层该位置的可见性，
```
## 搜索镜像：
>以下命令为在官方docker仓库中搜索指定名称的docker镜像
```
[root@docker ~]#docker search centos
[root@docker ~]#docker search centos:7.2.1511
```
>可以指定版本号，不指定版本号默认为latest
## 下载镜像：
```
[root@docker ~]#docker pull nginx
[root@docker ~]#docker pull centos
```
>下载的为压缩包，下载完成后会解压
## 查看本地镜像：
```
[root@docker ~]#docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nginx               latest              f68d6e55e065        2 days ago          109MB
centos              latest              9f38484d220f        3 months ago        202MB
```
+ REPOSITORY：镜像所属的仓库名称

+ TAG：镜像版本号，默认为latest
+ IMAGE ID：镜像唯一指定标识
+ CREATED：镜像创建时间
+ VIRTUAL SIZE：镜像的大小
## 导出镜像：
>可以将镜像从本地导出为一个压缩文件，复制到其他主机进行导入使用
+ 导出镜像：
    + 方法一：
        ```
        [root@docker ~]#docker save centos -o /opt/centos.tar.gz
        ```

    + 方法二：
        ```
        [root@docker ~]#docker save nginx > /opt/nginx.tar.gz
        ```
+ manifest.json：
    >包含了镜像的相关配置、配置文件、分层信息
    + 内容：
        ```
        [{"config":"配置文件.json","RepoTags":["docker.io/nginx:latest"],"分层1/layer.tar","分层2/layer.tar"," 分层3/layer.tar"]}]
        ```
## 导入镜像：
+ 导入：
    ```
    [root@docker_2 ~]#docker load < /opt/nginx.tar.gz
    cf5b3c6798f7: Loading layer [==================================================>]  58.45MB/58.45MB
    197c666de9dd: Loading layer [==================================================>]  54.62MB/54.62MB
    d2f0b6dea592: Loading layer [==================================================>]  3.584kB/3.584kB
    Loaded image: nginx:latest
    ```
+ 验证：
    ```
    [root@docker_2 ~]#docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    nginx               latest              f68d6e55e065        2 days ago          109MB
    ```
## 删除镜像：
```
[root@docker_2 ~]#docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nginx               latest              f68d6e55e065        2 days ago          109MB

[root@docker_2 ~]#docker rmi nginx
Untagged: nginx:latest
Deleted: sha256:f68d6e55e06520f152403e6d96d0de5c9790a89b4cfc99f4626f68146fa1dbdc
Deleted: sha256:1b0c768769e2bb66e74a205317ba531473781a78b77feef8ea6fd7be7f4044e1
Deleted: sha256:34138fb60020a180e512485fb96fd42e286fb0d86cf1fa2506b11ff6b945b03f
Deleted: sha256:cf5b3c6798f77b1f78bf4e297b27cfa5b6caa982f04caeb5de7d13c255fd7a1e

[root@docker_2 ~]#docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```
>docker rmi 镜像名/ID：删除指定镜像；但通过镜像启动容器未关闭时不能删除此镜像  

# 容器操作基础命令：
+ 命令格式：
    ```sh
        docker run [option] [IMAGE_NAME] [SHELL_COMMAND] [argument]
        #IMAGE_NAME必须在所有option后面
    ```
## 从镜像启动一个容器：
+ 启动容器：
>docker run -it 会直接进入到容器，并随机生成容器ID和名称
```
[root@docker opt]#docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS              NAMES

[root@docker opt]#docker run -it centos /bin/bash

[root@3c6172ffb7e8 /]# exit
exit

[root@docker opt]#docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS              NAMES
```
>退出后容器关闭
+ 后台启动容器：
>使用-d选项后台启动容器
```
[root@docker opt]#docker run -d -p 80:80 --name nginx_test nginx
1aae455ec8c2be59ab32cfd8cdd03d59fedeade79511c3db6748207bd96e3068

[root@docker opt]#docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                NAMES
1aae455ec8c2        nginx               "nginx -g 'daemon of…"   6 seconds ago       Up 5 seconds        0.0.0.0:80->80/tcp   nginx_test
```
+ 前台单次运行容器（用于测试）：
```
[root@docker opt]#docker run -it --rm nginx /bin/bash
```
+ 删除容器（使用-f选项强制删除容器，即使是运行中的容器）：
```
[root@docker opt]#docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
9aa449f83ba0        centos              "bash"              5 minutes ago       Exited (0) 4 minutes ago                       eloquent_kepler

[root@docker opt]#docker rm 9aa449f83ba0
9aa449f83ba0

[root@docker opt]#docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```
### 指定端口映射：
+ 端口映射：
```sh
docker run -p 81:80 --name test1 nginx
#本地81端口映射到容器的80端口，--name指定容器名

docker run -p 192.168.6.100:81:80 --name test2 nginx
#本地IP和81端口映射到容器的80端口

docker run -p 192.168.6.100::80 --name test3 nginx
#本地IP和随机端口映射到容器的80端口，随机端口默认从32768

docker run -p 192.168.6.100:81:80/tcp --name test4 nginx
#加上协议

docker run -p 81:80/tcp -p 443:443/tcp -p 53:53/udp --name test5 nginx
#映射多个端口和协议
```
+ 前台启动一个容器：
    ```
    [root@docker opt]#docker run -p 80:80 --name test_port nginx
    ```
    + 浏览器测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E6%B5%8B%E8%AF%95%E7%AB%AF%E5%8F%A3%E6%98%A0%E5%B0%84_2.png)  
    + 查看日志：
    ```
    [root@docker ~]#docker logs test_port
    ```
    ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E6%B5%8B%E8%AF%95%E7%AB%AF%E5%8F%A3%E6%98%A0%E5%B0%84_1.png)  
    + 查看容器已经映射的端口：
    ```
    [root@docker ~]#docker port test_port 
    80/tcp -> 0.0.0.0:80
    ```
## 容器的开启和关闭：
+ 开启：
```
[root@docker opt]#docker start nginx_test
```
+ 关闭：
```
[root@docker opt]#docker stop nginx_test
```  
![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E5%AE%B9%E5%99%A8%E5%90%AF%E5%81%9C.png)  
+ 批量关闭正在运行的容器：
>docker ps  -aq命令可以列出当前正在运行的容器的ID
```
[root@docker ~]#docker stop $(docker ps -aq)
```  
![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E6%89%B9%E9%87%8F%E5%85%B3%E9%97%AD%E6%AD%A3%E5%9C%A8%E8%BF%90%E8%A1%8C%E7%9A%84%E5%AE%B9%E5%99%A8.png)  
+ 批量强行关闭正在运行的容器：
```
[root@docker ~]#docker kill $(docker ps -aq)
```  
![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E6%89%B9%E9%87%8F%E5%BC%BA%E5%88%B6%E5%85%B3%E9%97%AD%E6%AD%A3%E5%9C%A8%E8%BF%90%E8%A1%8C%E7%9A%84%E5%AE%B9%E5%99%A8.png)  
+ 批量删除以退出的容器：
>docker ps -aq -f status=exited
```
[root@docker ~]#docker rm -f `docker ps -aq -f status=exited`
```  
![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E6%89%B9%E9%87%8F%E5%88%A0%E9%99%A4%E4%BB%A5%E9%80%80%E5%87%BA%E5%AE%B9%E5%99%A8.png)  
## 进入正在运行的容器：
+ attach命令：
>类似于VNC，操作会在各个容器界面显示，所有使用此方式进入容器的操作都是同步显示的，且使用exit退出后容器会被关闭，不推荐使用
```
    docker attach 容器ID
```
+ exec命令：
>执行单次命令并进入容器，exit后容器仍运行
```
    docker exec -it "容器名" /bin/bash
```
+ nsenter命令：
    >此命令通过PID进入容器内部，可以使用docker inspect获取到容器的PID

    >取出容器名为“nginx_test”的容器的IP
    ```
    [root@docker opt]#docker inspect -f "{{.NetworkSettings.IPAddress}}" nginx_test
    172.17.0.2
    ```

    >取出容器名为“nginx_test”的容器的PID
    ```
    [root@docker opt]#docker inspect -f "{{.State.Pid}}" nginx_test
    22216
    ```

    >使用nsenter通过取出的PID进入容器
    ```
    [root@docker opt]#nsenter -t 22216 -m -u -i -n -p
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E4%BD%BF%E7%94%A8nsenter%E5%91%BD%E4%BB%A4%E8%BF%9B%E5%85%A5%E5%AE%B9%E5%99%A8.png)  
    + 将nsenter命令写入脚本，使用脚本进人容器：
    >脚本内容
    ```sh
    #!/bin/bash
    read -p "Enter the container's name/ID:" CONTAINER
    PID=$(docker inspect -f "{{.State.Pid}}" $CONTAINER)
    nsenter -t $PID -m -u -i -n -p
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/nsenter%E8%84%9A%E6%9C%AC%E8%BF%9B%E5%85%A5%E5%AE%B9%E5%99%A8.png)  
    + 进入容器后查看hosts文件：  
    ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E5%AE%B9%E5%99%A8%E7%9A%84hosts%E6%96%87%E4%BB%B6.png)  
    >默认会将容器的ID作为主机名，添加到自己的hosts文件中作一条本地解析，在容器内能ping通
    + 容器内安装ping命令：
        ```
        root@1aae455ec8c2:/# apt install iputils-ping
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E5%AE%B9%E5%99%A8%E5%86%85ping.png)  
## 容器的DNS：
>容器的DNS默认是与宿主机相同的，但可以自己定义  
![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E5%AE%B9%E5%99%A8%E7%9A%84hosts%E6%96%87%E4%BB%B6.png)  
+ 修改容器DNS的两种方式：
    + 修改宿主机的DNS

    + 运行容器时将DNS指定：
        ```
        [root@docker ~]#docker run -it --name centos_test --dns 172.20.0.1 centos
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker/%E6%8C%87%E5%AE%9Adns.png)  
