# docker数据管理：
>如果运行中的容器中，生成了新的数据，或现有的文件内容被修改，那么新产生的数据会被复制到读写层进行持久化保存，这个读写层也就是容器的工作目录，这就是所谓的“写时复制”（COW）机制

>docker的镜像是分层设计的，底层是只读的；  
通过镜像启动的容器添加了一层可读写的文件系统，用户写入的数据都保存在这一层中，如果要使写入的数据永久生效，则需要将其提交为一个镜像然后通过这个镜像再启动实例（这个新镜像有两个layer，它们都是只读的），然后会给这个启动的实例添加一层可读写的文件系统，这里称之为容器层  
此时用户对于任何文件的操作都会记录在容器层；如修改文件时，容器会先去镜像层找到这个文件，并将其复制到容器层进行修改，删除文件时则会删除容器层中的这个文件，镜像层的这个文件会保留下来
+ 查看指定容器的信息：
    ```
    [root@master ~]#docker inspect f68d6e55e065
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E6%95%B0%E6%8D%AE%E7%AE%A1%E7%90%86/%E5%AE%B9%E5%99%A8%E7%9A%84%E7%9B%AE%E5%BD%95.png)  
    + LowerDir：只读层目录

    + UpperDir：可读写层目录；任何对容器的改变都写在这个目录中
    + MergedDir：容器的mount point，暴露的lowerdir和uperdir的统一视图；任何对容器的改变都会影响这个目录
    + WorkDir：OverLayFS功能所需要的，会被如copy_up之类的操作使用
+ 
# docker管理数据的方式：
>使用docker时，经常要对数据进行持久化，或者需要在多个容器间进行数据共享，此时就涉及到了容器的数据管理
+ 数据卷：
    >实际上，数据卷就是宿主机上的目录或文件，可以被直接mount到容器中使用
    + 特点：
        + 数据卷是文件或目录，可以在多个容器间共同使用

        + 对数据卷更改进行数据更新，容器里面的数据会立即更新
        + 数据卷的数据可以持久保存，即使删除，使用该数据卷的容器也不会受到影响
        + 对数据卷的数据更新不会影响到镜像本身，解耦了应用和数据
        + 挂载了数据卷的容器被删除，数据卷不会被删除
        + 在挂载了数据卷的容器中修改挂载文件或目录的内容时，数据卷也会被改变
    + 使用场景：
        ```
            用于很少更改文件内容的场景，如nginx配置文件、tomcat配置文件等
        ```
        + 日志输出

        + 静态web页面
        + 应用配置文件
        + 多容器间文件或目录的共享

+ 数据卷容器：
    >数据卷容器是一个放置了数据卷的server容器，用于数据卷提供，其他挂载数据卷容器的容器作为client，这个数据卷容器类似于一个文件共享服务的NFS服务器  

    >使用数据容器的一个好处就是，不用暴露宿主机的实际目录  

    >在docker中，若一个数据卷还在容器中使用，那它就会一直存在，使用数据卷容器来挂载数据时，实际上数据容器起到的作用仅仅是将数据卷挂载的配置传递到挂载了数据卷容器的容器中，即使数据卷容器被删除，已经运行的容器server依然可以使用挂载的数据卷，但无法创建新的挂载了数据卷容器中数据卷的容器客户端  

    >生产中可以启动一个容器挂载本地的目录，然后其他容器分别挂载此容器的目录，这样可以保证各容器之间的数据一致性
## 数据卷实验：
1. 在宿主机创建目录并创建web页面文件：
    ```
    [root@master ~]#mkdir -p testapp/{test1,test2}

    [root@master ~]#echo "test page" > testapp/test1/index.html

    [root@master ~]#echo "test read-only page" > testapp/test2/index.html
    ```
2. 创建容器并测试：
    + 挂载目录：
        + 创建容器使用-v参数使其挂载一个目录（默认为读写挂载）：
            ```
            [root@master testapp]#docker run -d -v /root/testapp/test1/:/usr/share/nginx/html -p 8008:80 nginx
            ```
            + 浏览器访问测试：  
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E6%95%B0%E6%8D%AE%E7%AE%A1%E7%90%86/%E9%AA%8C%E8%AF%81%E6%B5%8B%E8%AF%95%E9%A1%B5.png)  
            + 测试是否可读写：  
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E6%95%B0%E6%8D%AE%E7%AE%A1%E7%90%86/%E5%8F%AF%E8%AF%BB%E5%86%99.png)  
        + 创建容器使用-v参数和“ro”使其只读挂载一个数据卷：
            ```
            [root@master testapp]#docker run -d -v /root/testapp/test2/:/usr/share/nginx/html:ro -p 8009:80 nginx
            ```
            + 测试是否可读写：  
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E6%95%B0%E6%8D%AE%E7%AE%A1%E7%90%86/%E5%8F%AA%E8%AF%BB.png)  
            + 浏览器访问测试：  
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E6%95%B0%E6%8D%AE%E7%AE%A1%E7%90%86/%E6%B5%8B%E8%AF%95%E5%8F%AA%E8%AF%BB%E6%8C%82%E8%BD%BD%E6%B5%8B%E8%AF%95%E9%A1%B5.png)  
            >删除容器后数据卷不会收到影响
## 数据卷容器实验：
1. 创建数据卷容器server：
    ```
    [root@master ~]#docker run -d -v /root/testapp/test1/:/usr/share/nginx/html nginx
    ```
2. 创建数据卷容器client：
    ```
    [root@master ~]#docker run -d -p 8010:80 --volumes-from 6f7776392646 nginx
    ```
3. 进入client容器测试读写：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E6%95%B0%E6%8D%AE%E7%AE%A1%E7%90%86/%E8%BF%9B%E5%85%A5client%E5%AE%B9%E5%99%A8%E6%B5%8B%E8%AF%95%E8%AF%BB%E5%86%99.png)  
    >读写权限依赖于数据卷容器server
4. 关闭数据卷容器，测试能否启动新容器：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E6%95%B0%E6%8D%AE%E7%AE%A1%E7%90%86/%E5%85%B3%E9%97%AD%E6%95%B0%E6%8D%AE%E5%AE%B9%E5%99%A8%E4%BE%9D%E7%84%B6%E5%8F%AF%E4%BB%A5%E5%88%9B%E5%BB%BA%E6%96%B0%E5%AE%B9%E5%99%A8.png)  
5. 删除数据卷容器，测试：
    + 浏览器访问：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E6%95%B0%E6%8D%AE%E7%AE%A1%E7%90%86/%E5%88%A0%E9%99%A4%E6%95%B0%E6%8D%AE%E5%8D%B7%E5%AE%B9%E5%99%A8%E5%90%8E%E8%AE%BF%E9%97%AE%E6%B5%8B%E8%AF%95.png)  
        >删除了数据卷容器后，之前运行的容器依然可以访问到数据卷容器中挂载的数据卷的内容
    + 创建新容器：
        >由于新容器的创建基于之前的数据卷容器，但是它被删除了，所以无法创建新容器
