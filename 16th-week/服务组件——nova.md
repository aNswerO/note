## 服务组件nova：
+ nova的功能：
    + 控制节点：通过rabbitMQ与计算节点通信

    + 计算节点：计算节点通过nova computer进行虚拟机创建，通过libvirt调用kvm创建虚拟机
+ 组件：
    + nova-api：
        ```
            nova-api作为nova组件对外的唯一窗口，接收和响应用户的API请求，当需要执行虚拟机相关操作时，能且只能向nova-api发送REST API请求
        ```
    + nova-api-metadata：
        ```
            nova=api-metadata主要接收虚拟机的元数据请求，通常在带有nova-network的多主机模式下才会使用
        ```
    + nova-computer：
        ```
            nova-computer在计算节点上运行，是一个工作进程，通过hypervisor APIs创建或关闭虚拟机实例；它从队列服务接收信息后，启动虚拟机并在数据库中更新状态
            功能可分为两类，一是定时向OpenStack报告计算节点的状态，二是实现instance生命周期的管理
        ```
    + nova-scheduler：
        ```
            nova-scheduler处理队列中的请求，然后根据计算节点当时的资源使用情况选择一个最合适的计算节点来运行虚拟机，它通过rabbitMQ向选定的计算节点发出launch instance的命令
        ```
    + nova-conductor：
        ```
            nova-computer需要获取和更新数据库中instance的信息，但nova-computer不会直接访问数据库，而是通过nova-conductor实现数据的访问；nova-conductor不要部署在计算节点上
        ```
    + nova-cert：
        ```
            nova的证书服务，提供x509证书支持
        ```
    + novncproxy：
        ```
            VNC代理，用于显示虚拟机操作终端
        ```
+ 各组件之间的协调工作：
    1. 客户向API发送请求，如创建一个虚拟机

    2. API对请求做出必要处理后，向messaging发送消息，如创建一个虚拟机
    3. scheduler从messaging获取到API发给他的消息，然后通过调度算法从若干节点选出一个节点A
    4. scheduler向messaging发出一个消息，如创建一个虚拟机
    5. 计算节点A的compute从messaging中获取到scheduler发给他的消息，然后在本节点的hypervisor上启动虚拟机
    6. 在虚拟机的创建过程中，compute若需要查询或更新数据库信息，会通过messaging向conductor发送消息，conductor负责访问数据库
