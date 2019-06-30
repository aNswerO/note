## 服务组件neutron：
>neutron是网络服务组件，为整个OpenStack环境提供网络支持，包括二层交换，三层路由，负载均衡和防火墙等，它将网络、子网、端口和路由器抽象化，之后启动的虚拟机就可以连接到这个虚拟网络上
+ neutron的组件：
    + neutron server：对外提供OpenStack的网络API，接收请求，并调用plugin处理请求

    + plugin：处理neutron server发来的请求，维护OpenStack逻辑网络的状态，并调用agent处理请求
    + agent：处理plugin的请求，负责在network provider上真正实现各种网络功能
    + network provider：提供网络服务的虚拟或物理网络设备，如linux bridge、open vswitch或其他支持neutron的物理交换机
    + queque：neutron server、plugin和agent之间通过messaging queue通信和调用
    + database：存放OpenStack的网络状态信息，包括network、subnet、port、router等
### neutron各服务组件的交互：
1. neutron server接收到创建network的请求，通过messaging queue通知neutron plugin

2. neutron plugin将要创建network的信息保存到数据库中，并通过messaging queue通知运行在各节点的agent
3. agent收到消息后会在节点上的物理网卡上创建VLAN设备，并创建bridge桥接VLAN设备  
![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack%E6%9C%8D%E5%8A%A1%E7%BB%84%E4%BB%B6/neutron%E4%BA%A4%E4%BA%92%E6%B5%81%E7%A8%8B.png)  
