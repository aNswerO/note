# zabbix监控tomcat（ubuntu 18.04）：
## 规划：
|角色|主机名|IP|
|--|--|--|
|zabbix_server|server|192.168.6.150|
|tomcat|agent|192.168.6.151|
## 在agent节点部署tomcat：
>在上个实验的基础上进行这个实验，所以将tomcat部署在上个实验配置好的agent上
1. 安装JDK：
    + 安装：
        ```
        [root@agent ~]#apt install -y openjdk-8-jdk
        ```
    + 确认版本：
        ```
        [root@agent ~]#java -version
        ```
2. 部署tomcat：
    + 将下载到的tomcat包解压：
        ```
        [root@agent tomcat]#tar xvf apache-tomcat-8.5.42.tar.gz 
        ```
    + 创建软链接：
        ```
        [root@agent tomcat]#ln -sv /apps/apache-tomcat-8.5.42 /apps/tomcat
        ```
    + 创建测试页面文件：
        + 创建目录：
        ```
        [root@agent tomcat]#cd tomcat

        [root@agent tomcat]#mkdir webapps/test
        ```
        + 创建页面文件：
            ```
            [root@agent tomcat]#vim webapps/test/index.html

            [root@agent tomcat]#cat webapps/test/index.html
            tomcat test
            ```
3. 测试tomcat：
    + 启动tomcat：
        ```
        [root@agent tomcat]#./bin/catalina.sh start
        ```
    + 浏览器访问测试：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%9B%91%E6%8E%A7tomcat/%E8%AE%BF%E9%97%AE%E9%A1%B5%E9%9D%A2%E6%B5%8B%E8%AF%95.png)  
4. 配置tomcat监控参数：
    ```
    [root@agent tomcat]#vim /apps/tomcat/bin/catalina.sh 
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%9B%91%E6%8E%A7tomcat/%E9%85%8D%E7%BD%AEtomcat%E7%9B%91%E6%8E%A7%E5%8F%82%E6%95%B0.png)  
    + 重启tomcat：
        ```
        [root@agent tomcat]#./bin/catalina.sh stop

        [root@agent tomcat]#./bin/catalina.sh start
        ```
## 在server端配置java gateway：
1. 安装zabbix-java-gateway：
    ```
    [root@server ~]#apt install zabbix-java-gateway
    ```
2. 修改其配置文件：
    ```
    [root@server ~]#vim /etc/zabbix/zabbix_java_gateway.conf 

    LISTEN_IP="0.0.0.0"
    LISTEN_PORT=10052
    PID_FILE="/var/run/zabbix/zabbix_java_gateway.pid"
    START_POLLERS=20
    TIMEOUT=30
    ```
    >START_POLLERS：指定启动多少个进程轮询java  
    TIMEOUT：指定多长时间算超时（单位为s）
3. 配置zabbix server调用java gateway：
    ```
    [root@server ~]#vim /etc/zabbix/zabbix_server.conf 

    JavaGateway=192.168.6.150
    JavaGatewayPort=10052
    StartJavaPollers=20
    Timeout=30
    ```
    >JavaGateway：指定java gateway的IP地址  
    StartJavaPollers：启动多少个进程轮询java gateway，此项要和java gateway的配置保持一致
4. 添加监控tomcat：
    >server通过JMX（Java Management Extensions java管理扩展）与tomcat交互
    + 在zabbix web上更改agent主机的信息，加入JMX接口：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%9B%91%E6%8E%A7tomcat/web%E9%A1%B5%E9%9D%A2%E4%BF%AE%E6%94%B9agent%E4%B8%BB%E6%9C%BA%E7%9A%84%E5%B1%9E%E6%80%A7%E5%92%8C%E6%A8%A1%E6%9D%BF.png)  
    + 关联模板：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%9B%91%E6%8E%A7tomcat/%E6%B7%BB%E5%8A%A0%E6%A8%A1%E6%9D%BF.png)  
    + 查看主机状态及接口可用性：
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%9B%91%E6%8E%A7tomcat/%E7%82%B9%E4%BA%AEJMX.png)  
    + 查看采集到的信息：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%9B%91%E6%8E%A7tomcat/%E6%9F%A5%E7%9C%8B%E9%87%87%E9%9B%86%E5%88%B0%E7%9A%84%E4%BF%A1%E6%81%AF.png)  
