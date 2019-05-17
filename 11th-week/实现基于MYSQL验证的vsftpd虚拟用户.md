# 实现基于MYSQL验证的vsftpd虚拟用户：
## 实验环境：
+ 一台ftp服务器（192.168.1.129），一台mysql服务器（192.168.1.132）,一台测试主机（192.168.1.128）：
    + ftp版本：3.0.2
    + mariadb版本：5.5.60
## 实验步骤：
1. 在192.168.1.132上准备数据库：
    ```sh
    create database vsftpd;
    #创建一个名为vsftpd的数据库
    use vsftpd
    create table vuser (id int auto_increment primary key,username char(30),password char(50) binary);
    #创建一个名为vuser的表，用于存放虚拟用户的用户名和密码
    insert vuser(username,password)values('ftp1',password('centos')),('ftp2',password('123456'));
    #添加两条记录，用于认证虚拟用户
    grant select on vsftpd.vuser to vsftpd@'192.168.1.129' identified by 'centos';
    #给予192.168.1.129上的vsftpd用户对于vsftpd数据库中的vuser表的查询权限
    ```
2. 在192.168.1.129上准备pam_msyql：
    1. 编译安装pam_mysql：
    ```sh
    yum install gcc gcc-c++ pam-devel mariadb-devel
    #安装所需包
    tar xf pam_mysql-0.7RC1.tar.gz
    #解包
    cd pam_mysql-0.7RC1/
    ./configure  --with-pam-mods-dir=/lib64/security 
    make && make install
    #编译安装
    ```
    2. 创建pam配置文件：
    ```
    vim /etc/pam.d/vsftpd.mysql

    auth required pam_mysql.so user=vsftpd passwd=centos host=192.168.1.132  db=vsftpd table=vuser usercolumn=username passwdcolumn=password crypt=2
    account required pam_mysql.so user=vsftpd passwd=centos host=192.168.1.132 db=vsftpd table=vuser usercolumn=username passwdcolumn=password crypt=2
    ```
3. 在192.168.1.129上准备vsftpd：
    1. 修改vsftpd的配置文件,调用pam配置：
    ```
    vim /etc/vsftpd/vsftpd.conf
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E5%9F%BA%E4%BA%8EMySQL%E9%AA%8C%E8%AF%81%E7%9A%84vsftpd%E8%99%9A%E6%8B%9F%E7%94%A8%E6%88%B7/vsftpd%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
    2. 为两个虚拟用户做不同的ftp配置：
        + ftp1（允许上传文件）：
            ```sh
            vim /etc/vsftpd/vusers.d/ftp1

            anon_upload_enable=YES
            allow_writeable_chroot=YES    #如果没有此选项，则用户的根目录不能具有写权限，否则无法登录ftp服务器
            anon_mkdir_write_enable=YES
            anon_other_write_enable=YES
            local_root=/data/ftp1
            ```
        + ftp2（不允许上传文件）：
            ```
            vim /etc/vsftpd/vusers.d/ftp2

            allow_writeable_chroot=YES
            local_root=/data/ftp1
            ```
        + 重启服务：
            ```
            systemctl restart vsftpd
            ```
4. 创建系统用户：
    ```
    useradd -r -s /sbin/nologin -d /data/ftproot
    mkdir /data/ftproot
    ```
5. 创建共享目录,并修改权限（写入需要）：
    ```
    mkdir /data/ftp1
    mkdir /data/ftp2

    chmod 757 /data/ftp1
    chmod 757 /data/ftp2
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E5%9F%BA%E4%BA%8EMySQL%E9%AA%8C%E8%AF%81%E7%9A%84vsftpd%E8%99%9A%E6%8B%9F%E7%94%A8%E6%88%B7/%E6%9D%83%E9%99%90.png)
6. 测试：  
    + ftp1：  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E5%9F%BA%E4%BA%8EMySQL%E9%AA%8C%E8%AF%81%E7%9A%84vsftpd%E8%99%9A%E6%8B%9F%E7%94%A8%E6%88%B7/ftp1%E6%B5%8B%E8%AF%95.png)  
    + ftp2：    
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E5%9F%BA%E4%BA%8EMySQL%E9%AA%8C%E8%AF%81%E7%9A%84vsftpd%E8%99%9A%E6%8B%9F%E7%94%A8%E6%88%B7/ftp2%E6%B5%8B%E8%AF%95.png)  
