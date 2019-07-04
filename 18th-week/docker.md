# docker：
## docker的组成：
+ docker host（主机）：运行docker服务完进程和容器的物理机或虚拟机

+ docker server（服务端）：docker守护进程，运行docker容器
+ docker client（客户端）：客户端使用docker命令或其他工具调用docker API
+ docker image（镜像）：创建容器时使用的模板
+ docker registry（仓库）：保存镜像的仓库
+ docker container（容器）：从镜像生产对外提供服务的一个或一组服务  
![avagar]()  
## docker的优势：
+ 快速部署：短时间内部署大量应用，快速交付上线

+ 高效虚拟化：不需要额外的hypervisor支持，直接基于Linux实现应用虚拟化，相比于虚拟机，大幅提高了性能和效率
+ 节省开支：提高服务器利用率，降低IT支出
+ 简化配置：将允许环境打包保存至容器，使用时直接启动即可
+ 快速迁移和扩展：可跨平台运行在物理机、虚拟机和云环境上，良好的兼容性使得应用在宿主机之间，甚至是平台之间的迁移变得很方便
## docker的劣势：
+ 隔离性：各应用之间的隔离不如虚拟机彻底

## linux namespace：
+ namespace是linux系统的底层概念，它在内核层实现
    ```
        即有一些不同类型的命名空间被部署在内核内，各个docker容器运行在同一个docker主进程、同一个宿主机的用户空间，并且共用同一个宿主机系统内核，但每个容器都要有类似于虚拟机一样的相互隔离的运行空间，且容器技术是在一个进程内实现运行指定服务的运行环境，还可以保护宿主机的内核不受这些进程的干扰和影响，如文件系统空间、网络空间、进程空间等
    ```
+ 隔离技术：  

    |隔离类型|功能|系统调用参数|内核版本|
    |--|--|--|--|
    |MNT Namespace（mount）|提供磁盘挂载点和文件系统的隔离能力|CLONE_NEWS|Linux 2.4.19|
    |IPC Namespace（Inter Process Communication）|提供进程间通信的隔离能力|CLONE_NEWIPC|Linux 2.6.19|
    |UTS Namespace（UNIX Timesharing System）|提供主机名隔离能力|CLONE_NEWUTS|Linux 2.6.19|
    |PID Namespace（Process Identification）|提供进程隔离能力|CLONE_NEWPID|Linux 2.6.24|
    |Net Namespace（network）|提供网络隔离能力|CLONE_NEWNET|Linux 2.6.29|
    |User Namespace（user）|提供用户隔离能力|CLONE_NEWUSER|Linux 3.8|  
    + MNT Namespace：
        ```
            每个容器都要有独立的根文件系统和独立的用户空间，以实现在容器中启动服务并使用容器的运行环境，但在容器中不能使用宿主机的资源（指文件相关资源），宿主机使用了chroot技术把容器锁定在一个指定的运行目录里
        ```
        >如/var/lib/containerd/io.containerd.runtime.v1.linux/moby/容器ID/
    + IPC Namespace：
        ```
            一个容器内的进程间通信，允许一个容器内不同进程的（内存、缓存等）数据访问，但不能跨容器访问其他容器的数据
        ```
    + UTS Namespace：
        ```
            UTS中包含了运行内核的名称、版本、底层体系结构类型等信息用于系统标识，其中包含了hostname和domainname，它使一个容器拥有自己的hostname标识，这个主机名标识独立于宿主机系统和其上的其他容器
        ```
    + PID Namespace：
        ```
            Linux系统中有一个PID为1的进程是其他所有进程的父进程，每个容器内也要有一个父进程来管理其下属的子进程，容器中的进程和宿主机的进程通过PID Namespace隔离
        ```
    + Net Namespace：
        ```
            每个容器都像虚拟机一样有自己的网卡、监听端口、TCP/IP协议栈等，docker会使用Net Namespace启动一个vethX接口，这样容器就会拥有它自己的桥接IP地址，该设备通常为docker0，docker0实质就是Linux的虚拟网桥，通过mac地址对网络进行划分，并且在不同网络中直接传递数据
        ```
    + User Namespace：
        ```
            User Namespace允许在各个宿主机的各个容器空间内创建相同的用户名和相同的UID、GID，只是会把用户的作用范围限制在每个容器内，不能访问另一个容器内的文件系统
        ```
## Linux control groups：
> Linux cgroup，宿主机对容器进行资源分配限制，限制了一个进程组能够使用的资源上限，包括CPU、内存、磁盘、网络带宽等；还能对进程进行优先级设置，以及进程的挂起和恢复操作
+ cgroup的具体实现（/sys/fs/cgroup/）：
    + blkio：块设备IO限制

    + cpu：使用调度程序为cgroup任务提供cpu的访问
    + cpuacct：产生cgroup任务的cpu资源报告
    + cpuset：若是多核心的cpu，这个子系统会为cgroup任务分配单独的cpu和内存
    + devices：允许或拒绝cgroup任务对设备的访问
    + freezer：暂停和恢复cgroup任务
    + memory：设置每个cgroup的内存限制以及产生内存资源报告
    + net_cls：标记每个网络包以供cgroup方便使用
    + ns：命名空间子系统
    + perf_event：增加了对group的监测跟踪的能力，可以监测属于某个特定的group的所有线程以及运行在特定CPU上的线程
## docker的核心技术：
+ 容器 runtime：
    ```
        真正运行容器的地方，因此为了运行不同的容器，runtime需要和操作系统内核紧密合作、相互支持，以便为容器提供相应的运行环境
    ```
    + lxc：docker早期采用lxc作为runtime

    + runc：目前docker默认使用的runtime，runc遵守OCI规范，因此可以兼容lxc
+ 容器定义工具：
    ```
        容器定义工具允许用户定义容器的属性和内容，以方便容器能够被保存、共享和重建
    ```
    + docker image：docker容器的模板，runtime依据image创建容器

    + dockerfile：包含多个命令的文本文件，通过dockfile创建image
## docker的编排工具：
```
    当多个容器在多个主机上运行，单独管理容器复杂且易出错，而且无法实现容器的自动迁移（某主机宕机后，迁移容器以实现高可用），也无法实现动态伸缩，因此需要编排工具实现统一管理、动态伸缩、故障自愈、批量执行等功能
```
>容器编排通常包括容器管理、调度、集群定义和服务发现等功能
+ docker swarm：docker开发的容器编排引擎

+ kubernetes：google领导开发的容器编排引擎，内部项目为Brog，同时支持docker和CoreOS
+ Mesos + Marathon：通用的集群组员调度平台，Mesos（资源分配）与Marathon（容器编排平台）一起提供容器编排引擎功能
## docker的依赖技术：
+ 容器网络：
    ```
        docker自带的网络docker network仅支持管理单机上的容器网络，当多主机运行时就需要使用第三方开源网络，如calico、flannel等
    ```
+ 服务发现：
    ```
        容器的动态扩容特性决定了容器的IP会随之改变，因此需要一种机制自动识别，并将用户的请求动态转发到新创建的容器上；kubernetes自带服务发现功能，需要结合kube-dns服务解析内部域名
    ```
+ 容器监控：
    ```
        可通过原生命令docker ps/top/stats查看容器运行状态，也可以使用heapster/prometheu
        s等第三方监控工具监控容器的运行状态
    ```
+ 数据管理：
    ```
        容器的动态迁移会导致其在不同的Host间迁移，因此可以使用逻辑卷/存储挂载等方式保证与容器相关的数据也能随之迁移或随时访问
    ```
+ 日志收集：
    ```
        docker原生的日志查看工具docker logs，但是容器内部的日志需要通过ELK等专门的日志收集分析和展示工具进行处理
    ```