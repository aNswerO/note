# kubeadm安装k8s集群：
## kubeadm：
>
## 实验主机：

|角色|主机|
|--|--|
|master|192.168.6.100|
|node1|192.168.6.101|
|node2|192.168.6.102|
## 步骤：
### master节点：
1. 安装docker：
    1. 安装必要的系统工具：
        ```
        [root@master ~]#apt update && apt -y install apt-transport-https ca-certificates curl software-properties-common
        ```
    2. 安装GPG证书：
        ```
        [root@master ~]#curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -
        ```
    3. 写入软件源信息：
        ```
        [root@master ~]#add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
        ```
    4. 更新并安装Docker-CE：
        ```
        [root@master ~]#apt -y update && apt-get -y install docker-ce
        ```
        ```
        [root@master ~]#systemctl start docker && systemctl enable docker
        ```
2. 配置docker加速：
    ```
    [root@master ~]#tee /etc/docker/daemon.json <<-'EOF' 
    { 
        "registry-mirrors": ["https://9916w1ow.mirror.aliyuncs.com"] 
    }
    EOF
    ```
    ```
    [root@master ~]#systemctl daemon-reload
    ```
    ```
    [root@master ~]#systemctl restart docker
    ```
3. 配置阿里云仓库地址：
    >配置阿里云镜像的kubernetes源，主要用于安装kubelet、kubeadm和kubectl命令
    ```
    [root@master ~]#apt update && apt install -y apt-transport-https
    ```
    ```
    [root@master ~]#curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
    ```
    ```
    [root@master ~]#echo "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" >> /etc/apt/source.list
    ```
4. 安装kubeadm命令：
    >不安装最新版是为了后面的k8s升级实验
    ```
    [root@master ~]#apt update && apt install -y kubeadm=1.13.5-00 kubelet=1.13.5-00 kubectl=1.13.5-00
    ```
5. 准备镜像：
    + 下载镜像：
        ```
        [root@master ~]#docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.14.1
        [root@master ~]#docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.14.1
        [root@master ~]#docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.14.1
        [root@master ~]#docker pull registry.cn-hangzhou.aliyuncs.com/google _containers/kube-proxy:v1.14.1
        [root@master ~]#docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
        [root@master ~]#docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10
        [root@master ~]#docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1
        ```
    + 导入镜像：
        ```
        docker load < registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.14.1
        docker load < registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.14.1
        docker load < registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.14.1
        docker load < registry.cn-hangzhou.aliyuncs.com/google _containers/kube-proxy:v1.14.1
        docker load < registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
        docker load < registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10
        docker load < registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1
        ```
6. 关闭swap：
    >将/etc/fstab文件中swap的那一行注释，重启机器  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E5%85%B3%E9%97%ADswap.png)  
7. 初始化master：
    + 初始化：
        ```
        kubeadm init --apiserver-advertise-address=192.168.6.100 --apiserver-bind-port=6443 --kubernetes-version=v1.13.5 --pod-network-cidr=10.10.0.0/16 --service-cidr=10.20.0.0/16 --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers 
        ```
        + --apiserver-advertise-address：APIserver公布的它监听的地址

        + --apiserver-bind-port：APIserver绑定的端口
        + --kubernetes-version：指定一个k8s版本
        + --pod-network-cidr：指定Pod网络的IP地址范围，设置后**kube-controller-manager**会自动为每个节点分配此范围内的地址
        + --service-cidr：为service的VIP使用备选IP地址范围
        + --service-dns-domain：为API service使用备选域名
        + --image-repository：自定义镜像地址，解决默认k8s仓库被墙的问题  
    + 初始化成功：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E5%88%9D%E5%A7%8B%E5%8C%96%E6%88%90%E5%8A%9F.png)  
        >之后要使用下面红框内的信息来加入node
8. master配置kube证书：
    >证书中包含kube-apiserver的地址和相关认证信息
    ```
    [root@master ~]#mkdir ~/.kube
    ```
    >若为非root用户，使用命令如下：mkdir -p $HOME/.kube

    ```
    [root@master ~]#cp /etc/kubernetes/admin.conf ~/.kube/config
    ```
    >若为非root用户，使用命令如下：sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config

    ```
    [root@master ~]#chown root.root ~/.kube/config 
    ```
    >若为非root用户，使用命令如下：sudo chown $(id -u).$(id -g) $HOME/.kube/config
9. 验证k8s状态：
    ```
    [root@master ~]#kubectl get cs
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E9%AA%8C%E8%AF%81k8s%E7%8A%B6%E6%80%81.png)  
10. 部署flannel：
    >flannel实质上是一种“覆盖网络”（overlay network），将TCP数据包装在另一种网络包里进行路由转发和通信，让二层网络在三层网络中传递，既解决了二层的缺点，有解决了三层的不灵活
    + 使用kubectl apply命令创建对象：
        ```
        [root@master ~]#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kubeflannel.yml
        ```
    + 查看所有pod：
        ```
        [root@master ~]#kubectl get pod --all-namespaces
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E6%9F%A5%E7%9C%8B%E6%89%80%E6%9C%89pod.png)  
### node节点：
>在两个node节点上都执行上面master执行的 1 ~ 4 步
1. 添加两个node节点：
    >使用master初始化后给出的token来加入集群，如果没有记下token，可在master节点上执行kubeadm token list命令查看
    + node1加入：
    ```
    [root@node1 ~]#kubeadm join 192.168.6.100:6443 --token rn92a9.5u3o9y6v7x6v3h5a --discovery-token-ca-cert-hash sha256:136065a9300638a41c80f914d2230f1f95b094c772555404e6d4e297c1f1a39d
    ```
    + node2加入：
    ```
    [root@node2 ~]#kubeadm join 192.168.6.100:6443 --token jbab7k.sxj9pszpz6ays0py --discovery-token-ca-cert-hash sha256:3496a94e0eac857bec523c848a50893d7ccc1993316677f3dcef86294bc869f4
    ```
    + master节点上查看节点信息：
        ```
        [root@master ~]#kubectl get nodes
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E6%9F%A5%E7%9C%8B%E8%8A%82%E7%82%B9%E4%BF%A1%E6%81%AF.png)  
        >此时node节点的状态是NotReady，这是因为节点的docker正在拉取镜像并启动flannel，所以需要等待一会儿
    + 稍等，再次查看节点信息：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E4%B8%A4%E8%8A%82%E7%82%B9ready.png)  
        >此时节点以加入集群
2. master节点上创建容器并测试：
    + 创建容器：
        ```
        [root@master ~]#kubectl run net-test1 --image=apline --replicas=2 sleep 360000
        ```
    + 查看pod，并显示pod所在的node名：
        ```
        [root@master ~]#kubectl get pod -o wide
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E6%9F%A5%E7%9C%8B%E8%8A%82%E7%82%B9%E7%8A%B6%E6%80%81%EF%BC%88%E9%94%99%E8%AF%AF%EF%BC%89.png)  
        >由于创建容器时指定了--replicas=2，所以创建了两个前缀相同的pod
    + 查看指定pod的更多信息：
        ```
        [root@master ~]#kubectl describe pod net-test1-5857c68695-hd24f
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/pod%E8%AF%A6%E7%BB%86%E4%BF%A1%E6%81%AF.png)   
        >这里看到pod并没有READY，且状态为ImagePullBackOff，这里是由于打错了镜像名称，导致k8s未能拉取到镜像...
    + 删除pod：
        ```
        [root@master ~]#kubectl delete pod net-test1-5857c68695-hd24f

        [root@master ~]#kubectl delete pod net-test1-5857c68695-qtwtl
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E5%88%A0%E9%99%A4%E5%90%8E%E8%87%AA%E5%8A%A8%E5%88%9B%E5%BB%BA.png)  
        >可以看到删除pod后，又有新的前缀名和被删除pod相同的pod被自动创建
        + 检查是否创建了deployments任务：
            ```
            [root@master ~]#kubectl get deployment
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E6%9F%A5%E7%9C%8B%E8%87%AA%E5%8A%A8%E5%88%9B%E5%BB%BA%E4%BB%BB%E5%8A%A1.png)  
        + 删除这个deployment任务：
            ```
            [root@master ~]#kubectl delete deployment net-test1
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E5%88%A0%E9%99%A4%E4%BB%BB%E5%8A%A1%E5%90%8Epod%E8%87%AA%E5%8A%A8%E5%88%A0%E9%99%A4.png)  
            >删除了这个deployment任务后，pod被自动删除了
    + 重新创建容器：
        ```
        [root@master ~]#kubectl run net-test1 --image=alpine --replicas=3 sleep 360000
        ```  
    + **再次**查看pod信息：
        ```
        [root@master ~]#kubectl get pods
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E6%9F%A5%E7%9C%8B%E8%8A%82%E7%82%B9%E7%8A%B6%E6%80%81%EF%BC%88%E6%AD%A3%E7%A1%AE%EF%BC%89.png)  
    + master节点创建容器，并测试网络连接：
        >由于安装docker-ce之后，它自动给iptables的FORWARD链添加了默认为DROP的规则，所以要想通信，需要把FORWARD链的默认规则改为ACCEPT
        + node节点上修改iptables规则：
            ```
            [root@node1 ~]#iptables -P FORWARD ACCEPT

            [root@node2 ~]#iptables -P FORWARD ACCEPT
            ```
        + 创建容器并测试：
            ```
            [root@master ~]#kubectl exec -it net-test1-68898c85b7-6jdqf sh
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E6%B5%8B%E8%AF%95%E9%80%9A%E4%BF%A1.PNG)  
## k8s集群升级：
>要升级k8s集群必须先升级kubeadm到目标版本
1. 查看当前kubeadm版本：
    ```
    [root@master ~]#kubeadm version
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E6%9F%A5%E7%9C%8B%E5%BD%93%E5%89%8D%E7%89%88%E6%9C%AC.png)  
2. 安装指定版本的kubeadm：
    + 查看kubeadm版本列表：
        ```
        [root@master ~]#apt-cache madison kubeadm
        ```  
    + 安装指定版本：
        ```
        [root@master ~]#apt-get install kubeadm=1.14.3-00
        ```
3. 查看升级计划：
    ```
    [root@master ~]#kubeadm upgrade plan
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E6%9F%A5%E7%9C%8B%E5%8D%87%E7%BA%A7%E8%AE%A1%E5%88%92.png)  
4. 升级：
    ```
    [root@master ~]#kubeadm upgrade apply v1.14.3
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E5%8D%87%E7%BA%A7%E6%88%90%E5%8A%9F.png)  
5. 验证当前版本信息：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E9%AA%8C%E8%AF%81%E5%BD%93%E5%89%8D%E7%89%88%E6%9C%AC%E4%BF%A1%E6%81%AF.png)  
6. 升级个node节点的配置文件：
    ```
    kubeadm upgrade node config -kubelet-version 1.14.3
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E5%8D%87%E7%BA%A7node%E8%8A%82%E7%82%B9%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
7. 各节点升级kubelet二进制包：
    ```
    apt install kubelet=1.14.3-00
    ```  
8. 验证版本：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/kubeadm%E9%83%A8%E7%BD%B2%E9%9B%86%E7%BE%A4/%E6%9C%80%E7%BB%88%E9%AA%8C%E8%AF%81%E7%89%88%E6%9C%AC.png)  
