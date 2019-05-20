# MySQL主从复制：
>实验需要2台主机，一主一从  
mariadb版本：5.5.60

1. 在两台主机上安装mariadb-server：
```
    yum install -y mariad-server
```
2. 配置主节点：
+ 修改主节点的配置文件：
```
    vim /etc/my.cnf
```  
![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E4%B8%BB%E4%BB%8E%E5%A4%8D%E5%88%B6%E5%AE%9E%E9%AA%8C/%E4%B8%BB%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
3. 查看二进制日志位置信息:
```
    mysql> SHOW master logs;
```  
![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E4%B8%BB%E4%BB%8E%E5%A4%8D%E5%88%B6%E5%AE%9E%E9%AA%8C/%E6%9F%A5%E7%9C%8B%E4%BA%8C%E8%BF%9B%E5%88%B6%E6%97%A5%E5%BF%97%E4%BD%8D%E7%BD%AE%E4%BF%A1%E6%81%AF.png)  
4. 创建一个用户并授权，使其可以通过从服务器登录并从主服务器复制二进制日志：
```
    mysql> GRANT replication slave ON *.* TO repluser@'192.168.113.20' identified BY 'centos';
```  
![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E4%B8%BB%E4%BB%8E%E5%A4%8D%E5%88%B6%E5%AE%9E%E9%AA%8C/%E5%88%9B%E5%BB%BA%E7%94%A8%E6%88%B7.png)  
5. 配置从节点：
+ 修改配置文件：
```
    vim /etc/my.cnf
```
![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E4%B8%BB%E4%BB%8E%E5%A4%8D%E5%88%B6%E5%AE%9E%E9%AA%8C/%E4%BB%8E%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  

+ 配置同步信息：
```
    mysql> CHANGE MASTER TO   
            MASTER_HOST='192.168.1.128',
            MASTER_USER='repluser', 
            MASTER_PASSWORD='centos', 
            MASTER_PORT=3306, 
            MASTER_LOG_FILE='mariadb-bin.000001', 
            MASTER_LOG_POS=2097;
```
+ 启动复制线程并查看线程状态：
```
    mysql> start slave;
    mysql> SHOW slave status\G;
```  
![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E4%B8%BB%E4%BB%8E%E5%A4%8D%E5%88%B6%E5%AE%9E%E9%AA%8C/%E7%BA%BF%E7%A8%8B%E7%8A%B6%E6%80%81.png)  
+ 测试：
    1. 在主服务器上创建一个数据库：
    ```
        CREATE database db1;

        SHOW databases;
    ```
    2. 在从服务器上查看是否同步成功：
    ```
        SHOW databases;
    ```  
![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E4%B8%BB%E4%BB%8E%E5%A4%8D%E5%88%B6%E5%AE%9E%E9%AA%8C/%E6%B5%8B%E8%AF%95.png)
