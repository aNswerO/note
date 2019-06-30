# 拓扑：  
![avagar]()  

# 环境：
+ 控制节点：172.20.102.145

+ 计算节点：172.20.6.10
+ 负载均衡器：172.20.6.60,172.20.6.61
+ 数据库节点（同时部署rabbitMQ和memcached）：172.20.6.40
# 1. 安装OpenStack包（控制节点和计算节点）：
```sh
    yum install centos-release-openstack-ocata
    yum install python-openstackclient    #安装OpenStack客户端
    yum install openstack-selinux    #若启用了SELinux，则需要安装此包实现对openstack服务的安全策略进行自动管理
```
# 2. 安装数据库并配置组件（单独节点）：
1. 安装软件包：
    ```
    yum install mariadb mariadb-server python2-PyMySQL -y
    ```
2. 创建并编辑/etc/my.cnf.d/openstack.cnf：
    ```sh
    [mysqld]
    bind-address = 10.1.3.1
    default-storage-engine = innodb
    innodb_file_per_table = on
    max_connections = 4096
    collation-server = utf8_general_ci
    character-set-server = utf8
    ```
3. 设置数据库服务开机自启，并启动：
    ```
    systemctl enable mariadb.service
    systemctl start mariadb.service
    ```
# 3. 安装rabbitmq并配置组件（与数据库同节点）：
1. 安装软件包：
    ```
    yum install rabbitmq-server -y
    ```
2. 设置rabbitmq开机自启，并启动：
    ```
    systemctl enable rabbitmq-server.service
    systemctl start rabbitmq-server.service
    ```
3. 添加OpenStack用户：
    ```sh
    rabbitmqctl add_user openstack centos
    #密码为centos
    ```
4. 为OpenStack用户配置读、写权限：
    ```
    rabbitmqctl set_permissions openstack ".*" ".*" ".*"
    ```
# 4. 安装memcached并配置组件（与数据库同节点）：
1. 安装软件包：
    ```
    yum install memcached python-memcached -y
    ```
2. 编辑memcached配置文件/etc/sysconfig/memcached：
    ```
    PORT="11211"
    USER="memcached"
    MAXCONN="1024"
    CACHESIZE="64"
    OPTIONS="-l 127.0.0.1,::1,172.20.102.145"
    ```
3. 设置memcached开机自启，并启动：
    ```
    systemctl enable memcached.service
    systemctl start memcached.service
    ```
# 6. 配置keepalived（负载均衡器）：
1. 安装包：
    ```
    yum install -y keepalived
    ```
2. 编辑配置文件：
    ```sh
    global_defs {
    notification_email {
     acassen
    }
    notification_email_from Alexandre.Cassen@firewall.loc
    smtp_server 192.168.200.1
    smtp_connect_timeout 30
    router_id LVS_DEVEL
    }

    vrrp_instance VI_1 {
        interface eth0
        virtual_router_id 68
    #   nopreempt
        priority 100
        advert_int 2
        virtual_ipaddress {
            172.20.6.240
        }
    }
    ```
3. 重启keepalived，并查看VIP是否生成：
    ```
    systemctl restart keepalived
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E6%9F%A5%E7%9C%8BVIP%E7%94%9F%E4%BA%A7.png)  
# 7. 配置haproxy代理（负载均衡器）：
1. 修改配置文件/etc/haproxy/haproxy.conf：
    ```
    #openstack-mysql
    frontend openstack_mysql
            bind 172.20.6.240:3306
            mode tcp
            default_backend openstack_mysql_node
    backend openstack_mysql_node
            mode tcp
            balance source
            server mysql 10.1.3.1:3306 check inter 2000 fall 3 rise 5

    #openstack-rabbit
    frontend openstack_rabbit
            bind 172.20.6.240:5672
            mode tcp
            default_backend openstack_rabbit_node
    backend openstack_rabbit_node
            mode tcp
            server rabbit 10.1.3.1:5672 check inter 2000 fall 3 rise 5

    #openstack-memcached
    frontend openstack_memcached
            bind 172.20.6.240:11211
            mode tcp
            default_backend openstack_memcached_node
    backend openstack_memcached_node
            mode tcp
            balance source
            server memcached 10.1.3.1:11211 check inter 2000 fall 3 rise 5
    ```
2. 重启haproxy：
    ```
    systemctl restart haproxy
    ```
# 5. 认证服务“keystone”：
1. 准备数据库（数据库节点）：
    1. 在数据库服务器上连接数据库，创建keystone数据库：
        ```
        mysql -uroot -p

        MariaDB [(none)]> CREATE DATABASE keystone;
        ```
    2. 创建keystone用户，并给予恰当的权限：
        ```sh
        MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'keystone';
        #密码为keystone
        ```
    3. 刷新MySQL的系统权限相关表:
        ```
        MariaDB [(none)]> flush privileges;
        ```
3. 配置组件（控制节点）：
    1. 安装包：
        ```
        yum install openstack-keystone httpd mod_wsgi -y
        ```
    2. 编辑配置文件/etc/keystone/keystone.conf：
        ```sh
        [database]
        connection = mysql+pymysql://keystone:keystone@172.20.102.145/keystone
        #配置数据库访问，填写控制节点IP

        [token]
        provider = fernet
        #配置fernet UUID令牌的提供者
        ```
    3. 初始化身份认证服务的数据库：
        1. 初始化：
            ```
            su -s /bin/sh -c "keystone-manage db_sync" keystone
            ```
        2. 查看是否生成表（数据库服务器）：  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9D%E5%A7%8B%E5%8C%96keystone%E6%95%B0%E6%8D%AE%E5%BA%93%E5%88%9B%E5%BB%BA%E8%A1%A8.png)  
    4. 初始化Fernet key：
        ```
        keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
        keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
        ```
    5. 引导认证服务：
        ```sh
        keystone-manage bootstrap --bootstrap-password admin --bootstrap-admin-url http://172.20.102.145:35357/v3/ --bootstrap-internal-url http://172.20.102.145:5000/v3/ --bootstrap-public-url http://172.20.102.145:5000/v3/ --bootstrap-region-id RegionOne
        #密码为admin
        ```
    6. 配置apache服务（通过apache代理python）：
        1. 编辑/etc/httpd/conf/httpd.conf，配置servername为控制节点：
            ```
            ServerName 172.20.102.145:80
            ```
        2. 创建软链接：
            ```
            ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
            ```
        3. 设置apache开机自启，并启动：
            ```
            systemctl enable httpd.service
            systemctl start httpd.service
            ```
# 6. 创建域、项目、用户和角色（控制节点）：
1. 生成token，并将其写入/etc/keystone/keystone.conf的[DEFAULT]配置段中：
    ```
    openssl rand -hex 10
    ```
    ```sh
    [DEFAULT]
    admin_token = 1d9c39eadfbecbf320c7
    ```
2. 导入变量：
    ```sh
    export OS_TOKEN=1d9c39eadfbecbf320c7
    export OS_URL=http://172.20.102.145:35357/v3    #控制节点IP
    export  OS_IDENTITY_API_VERSION=3
    ```
3. 创建默认域：
    ```
    openstack domain create --description "Default Domain" default
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BA%E9%BB%98%E8%AE%A4%E5%9F%9F.png)  
4. “admin”项目：
    1. 创建”admin“项目：
        ```
        openstack project create --domain default --description "Admin Project" admin
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAadmin%E9%A1%B9%E7%9B%AE.png)  
    2. 创建“admin”用户并设置密码（admin）：
        ```
        openstack user create --domain default --password-prompt admin
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAadmin%E7%94%A8%E6%88%B7.png)  
    3. 创建“admin”角色：
        ```
        openstack role create admin
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAadmin%E8%A7%92%E8%89%B2.png)  
    4. 将"admin"用户添加到"admin"项目，并为其授权（admin）：
        ```
        openstack role add --project admin --user admin admin
        ```
5. “demo”项目（该项目可用于演示和测试）：
    1. 创建”demo“项目：
        ```
        openstack project create --domain default --description "Demo Project" demo
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAdemo%E9%A1%B9%E7%9B%AE.png)  
    2. 创建“demo”用户并设置密码（demo）：
        ```
        openstack user create --domain default --password-prompt demo
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAdemo%E7%94%A8%E6%88%B7.png)  
    3. 创建“user”角色：
        ```
        openstack role create user
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAuser%E8%A7%92%E8%89%B2.png)  
    4. 将"demo"用户添加到"demo"项目，并为其授权（user）：
        ```
        openstack role add --project demo --user demo user
        ```
6. “service”项目：
    1. 创建“service”项目：
        ```
        openstack project create --domain default   --description "Service Project" service
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAservice%E9%A1%B9%E7%9B%AE.png)  
    2. 创建“glance”用户，并设置密码（glance）：
        ```
        openstack user create --domain default --password-prompt glance
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAglance%E7%94%A8%E6%88%B7.png)  
    3. 创建“nova”用户，并设置密码（nova）：
        ```
        openstack user create --domain default --password-prompt nova
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAnova%E7%94%A8%E6%88%B7.png)  
    4. 创建“neutron”用户，并设置密码（neutron）：
        ```
        openstack user create --domain default --password-prompt neutron
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAneutron%E7%94%A8%E6%88%B7.png)  
    5. 将"glance"用户添加到"service"项目，并为其授权（admin）：
        ```
        openstack role add --project service --user glance admin
        ```
    6. 将"nova"用户添加到"service"项目，并为其授权（admin）：
        ```
        openstack role add --project service --user nova admin
        ```
    7. 将"neutron"用户添加到"service"项目，并为其授权（admin）：
        ```
        openstack role add --project service --user neutron admin
        ```
# 7. 服务注册（控制节点）：
1. 创建keystone认证服务：
    ```
    openstack service create --name keystone --description "OpenStack Identity" identity
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAkeystone%E8%AE%A4%E8%AF%81%E6%9C%8D%E5%8A%A1.png)  
2. 查看服务是否创建：
    ```
    openstack service list
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E6%9F%A5%E7%9C%8Bkeystone%E6%9C%8D%E5%8A%A1%E6%98%AF%E5%90%A6%E5%88%9B%E5%BB%BA.png)  
3. 创建“keystone”的API端点：
    1. 创建公共端点：
        ```
        openstack endpoint create --region RegionOne identity public http://172.20.102.145:5000/v3
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BA%E5%85%AC%E5%85%B1%E7%AB%AF%E7%82%B9.png)  
    2. 创建私有端点：
        ```
        openstack endpoint create --region RegionOne identity internal http://172.20.102.145:5000/v3
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BA%E7%A7%81%E6%9C%89%E7%AB%AF%E7%82%B9.png)  
    3. 创建管理端点：
        ```
        openstack endpoint create --region RegionOne identity admin http://172.20.102.145:35357/v3
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BA%E7%AE%A1%E7%90%86%E7%AB%AF%E7%82%B9.png)  
4. 配置haproxy代理（负载均衡器）：
    1. 编辑配置文件/etc/haproxy/haproxy.cfg，增加如下内容：
        ```
        listen keystone-publish-url
            bind 172.20.6.240:5000
            mode tcp
            log global
            balance source
            server keystone1 172.20.102.145:5000 check inter 5000 fall 3 rise 5

        listen keystone-admin-url
            bind 172.20.6.240:35357
            mode tcp
            log global
            balance source
            server keystone1 172.20.102.145:35357 check inter 5000 fall 3 rise 5
        ```
    2. 重启haproxy：
        ```
        systemctl restart haproxy
        ```
5. 验证keystone能否做用户验证：
    ```sh
    openstack --os-auth-url http://172.20.6.240:35357/v3 --os-project-domain-name default --os-user-domain-name default  --os-project-name admin  --os-username admin token issue
    #测试用户为admin，密码为admin
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81keystone%E7%9A%84%E7%94%A8%E6%88%B7%E9%AA%8C%E8%AF%81.png)  
6. 环境变量设置脚本（在进行需要认证的操作之前，要导入一些环境变量）：
+ admin：
    ```sh
    #!/bin/bash
    export OS_PROJECT_DOMAIN_NAME=default
    export OS_USER_DOMAIN_NAME=default
    export OS_PROJECT_NAME=admin
    export OS_USERNAME=admin
    export OS_PASSWORD=admin
    export OS_AUTH_URL=http://172.20.6.240:35357/v3
    export OS_IDENTITY_API_VERSION=3
    export OS_IMAGE_API_VERSION=2
    ```
+ demo：
    ```sh
    #!/bin/bash
    export OS_PROJECT_DOMAIN_NAME=default
    export OS_USER_DOMAIN_NAME=default
    export OS_PROJECT_NAME=demo
    export OS_USERNAME=demo
    export OS_PASSWORD=demo
    export OS_AUTH_URL=http://172.20.6.240:5000/v3
    export OS_IDENTITY_API_VERSION=3
    export OS_IMAGE_API_VERSION=2
    ```
7. 测试脚本：
    1. 未导入环境变量：  
    ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E6%B5%8B%E8%AF%95_%E6%9C%AA%E5%AF%BC%E5%85%A5%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F.png)  
    2. 使用admin-ocata.sh导入admin环境变量：
    ```
    . admin-ocata.sh
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%AF%BC%E5%85%A5admin%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F.png)  
    3. 使用demo-ocata.sh导入demo环境变量：
    ```
    . demo-ocata.sh
    ```
    ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%AF%BC%E5%85%A5demo%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F.png)  
# 8. 镜像服务“glance”：
1. 准备数据库：
    1. 创建数据库（数据库节点）：
        ```
        MariaDB [(none)]> CREATE DATABASE glance;
        ```
    2. 创建“glance”用户并授权（数据库节点）：
        ```
        MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'glance';
        ```
    3. 刷新MySQL的系统权限相关表（数据库节点）:
        ```
        MariaDB [(none)]> flush privileges;
        ```
2. 创建“glance”服务（控制节点）：
    >前提：使用admin-ocata.sh脚本导入环境变量
    ```
    openstack service create --name glance --description "OpenStack Image" image
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAglance%E6%9C%8D%E5%8A%A1.png)  
3. 创建“glance”服务的API端点（控制节点）：
    1. 创建公共端点：
        ```
        openstack endpoint create --region RegionOne image public http://172.20.102.145:9292
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAglance%E5%85%AC%E5%85%B1%E7%AB%AF%E7%82%B9.png)  
    2. 创建私有端点：
        ```
        openstack endpoint create --region RegionOne image internal http://172.20.102.145:9292
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAglacne%E7%A7%81%E6%9C%89%E7%AB%AF%E7%82%B9.png)  
    3. 创建管理端点：
        ```
        openstack endpoint create --region RegionOne image admin http://172.20.102.145:9292
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAglance%E7%AE%A1%E7%90%86%E7%AB%AF%E7%82%B9.png)  
4. 配置组件（控制节点）：
    1. 安装包：
        ```
        yum install openstack-glance
        ```
    2. 编辑文件/etc/glance/glance-api.conf，修改如下内容：
        1. [database]配置段：
            ```
            connection = mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
            ```
        2. [keystone_authtoken]配置段：
            ```
            auth_uri = http://172.20.6.240:5000
            auth_url = http://172.20.6.240:35357
            memcached_servers = 172.20.6.240:11211
            auth_type = password
            project_domain_name = default
            user_domain_name = default
            project_name = service
            username = glance
            password = glance
            ```
        3. [paste_deploy]配置段：
            ```
            flavor = keystone
            ```
        4. [glance_store]配置段：
            ```
            stores = file,http
            default_store = file
            filesystem_store_datadir = /var/lib/glance/images/
            ```
    3. 编辑/etc/glance/glance-registry.conf，修改如下：
        1. [database]配置段：
            ```
            connection = mysql+pymysql://glance:glance@172.20.6.240/glance
            ```
        2. [keystone_authtoken]配置段：
            ```
            auth_uri = http://172.20.6.240:5000
            auth_url = http://172.20.6.240:35357
            memcached_servers = 172.20.6.240:11211
            auth_type = password
            project_domain_name = default
            user_domain_name = default
            project_name = service
            username = glance
            password = glance
            ```
        3. [paste_deploy]配置段：
            ```
            flavor = keystone
            ```
    4. 配置haproxy代理（负载均衡器）：
        1. 修改配置文件/etc/haproxy/haproxy.conf：
            ```sh
            listen glance-api
                bind 172.20.6.240:9292
                mode tcp
                log global
                balance source
                server glance-api1 172.20.102.145:9292 check inter 5000 fall 3 rise 5

            listen glance
                bind 172.20.6.240:9191
                mode tcp
                log global
                balance source
                server glance1 172.20.102.145:9191 check inter 5000 fall 3 rise 5
            ```
        2. 重启haproxy：
            ```
            systemctl restart haproxy
            ```
    5. 初始化glance数据库（控制节点）：
        1. 写入glance服务数据库：
            ```
            su -s /bin/sh -c "glance-manage db_sync" glance
            ```
        2. 查看数据库是否生成相应表（数据库服务器）：  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E6%9F%A5%E7%9C%8Bglance%E6%95%B0%E6%8D%AE%E5%BA%93%E6%98%AF%E5%90%A6%E7%94%9F%E6%88%90%E8%A1%A8.png)  
    6. 设置glance服务开机自启，并启动（控制节点）：
        ```
        systemctl enable openstack-glance-api.service openstack-glance-registry.service
        systemctl start openstack-glance-api.service openstack-glance-registry.service
        ```
    7. 验证glacne服务（控制节点）：
        >前提：使用admin-ocata脚本导入环境变量
        1. 下载源镜像：
            ```
            wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.5-x86_64-disk.img
            ```
        2. 使用 QCOW2 磁盘格式， bare 容器格式上传镜像到镜像服务并设置公共可见，这样所有的项目都可以访问它：
            ```
            openstack image create "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E4%B8%8A%E4%BC%A0%E9%95%9C%E5%83%8F.png)  
        3. 确认镜像已上传：
            ```
            openstack image list
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81%E9%95%9C%E5%83%8F%E4%B8%8A%E4%BC%A0.png)  
# 9. 计算服务“nova”：
1. 创建数据库（数据库节点）：
    1. 创建以下数据库：
        ```
        MariaDB [(none)]> CREATE DATABASE nova_api;
        MariaDB [(none)]> CREATE DATABASE nova;
        MariaDB [(none)]> CREATE DATABASE nova_cell0;
        ```
    2. 创建nova用户，并给予恰当的权限：
        ```
        MariaDB [(none)]> GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'nova';
        MariaDB [(none)]> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'nova';
        MariaDB [(none)]> GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'nova';
        ```
2. 配置控制节点：
    1. 创建nova服务：
        >前提：使用admin-ocata.sh脚本导入环境变量
        ```
        openstack service create --name nova --description "OpenStack Compute" compute
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAnova%E6%9C%8D%E5%8A%A1.png)  
    2. 创建API端点：
        1. 创建公共端点：
            ```
            openstack endpoint create --region RegionOne compute public http://172.20.102.145:8774/v2.1
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAnova%E5%85%AC%E5%85%B1%E7%AB%AF%E7%82%B9.png)  
        2. 创建私有端点：
            ```
            openstack endpoint create --region RegionOne compute internal http://172.20.102.145:8774/v2.1
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAnova%E7%A7%81%E6%9C%89%E7%AB%AF%E7%82%B9.png)  
        3. 创建管理端点：
            ```
            openstack endpoint create --region RegionOne compute admin http://172.20.102.145:8774/v2.1
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAnova%E7%AE%A1%E7%90%86%E7%AB%AF%E7%82%B9.png)  
    3. 创建placement用户（密码为placement）：
        ```
        openstack user create --domain default --password-prompt placement
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAplacement%E7%94%A8%E6%88%B7.png)  
    4. 将placement**用户**以admin的**角色**加入到service**项目**中：
        ```
        openstack role add --project service --user placement admin
        ```
    5. 创建placement API服务：
        ```
        openstack service create --name placement --description "Placement API" placement
        ```  
    6. 创建API端点：
        1. 创建公共端点：
            ```
            openstack endpoint create --region RegionOne placement public http://172.20.102.145:8778
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAplacement%E5%85%AC%E5%85%B1%E7%AB%AF%E7%82%B9.png)  
        2. 创建私有端点：
            ```
            openstack endpoint create --region RegionOne placement internal http://172.20.102.145:8778
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAplacement%E7%A7%81%E6%9C%89%E7%AB%AF%E7%82%B9.png)  
        3. 创建管理端点：
            ```
            openstack endpoint create --region RegionOne placement admin http://172.20.102.145:8778
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAplacement%E7%AE%A1%E7%90%86%E7%AB%AF%E7%82%B9.png)  
    7. 配置组件：
        1. 安装包：
            ```
            yum install openstack-nova-api openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler openstack-nova-placement-api
            ```
        2. 编辑配置文件/etc/nova/nova.conf，做如下修改：
            + [DEFAULT]配置段：
                ```sh
                enabled_apis = osapi_compute,metadata
                transport_url=rabbit://openstack:centos@172.20.6.240
                my_ip=10.0.6.6
                use_neutron=true
                firewall_driver = nova.virt.firewall.NoopFirewallDriver
                #默认情况下，计算服务使用内置的防火墙服务。由于网络服务包含了防火墙服务，必须使用"nova.virt.firewall.NoopFirewallDriver"防火墙服务来禁用掉计算服务内置的防火墙服务
                ```
            + [api_database]配置段：
                ```
                connection = mysql+pymysql://nova:nova@controller/nova_api
                ```
            + [database]配置段：
                ```
                connection = mysql+pymysql://nova:nova@172.20.6.240/nova
                ```
            + [api]配置段：
                ```
                auth_strategy = keystone
                ```
            + [keystone_authtoken]配置段：
                ```
                auth_uri = http://172.20.102.145:5000
                auth_url = http://172.20.102.145:35357
                memcached_servers = 172.20.6.240:11211
                auth_type = password
                project_domain_name = default
                user_domain_name = default
                project_name = service
                username = nova
                password = nova
                ```
            + [vnc]配置段：
                ```
                enabled = true
                vncserver_listen = 10.0.6.6
                vncserver_proxyclient_address = 10.0.6.6
                ```
            + [glance]配置段：
                ```
                api_servers = http://172.20.102.145:9292
                ```
            + [oslo_concurrency]配置段：
                ```
                lock_path = /var/lib/nova/tmp
                ```
            + [placement]配置段：
                ```
                os_region_name = RegionOne
                project_domain_name = Default
                project_name = service
                auth_type = password
                user_domain_name = Default
                auth_url = http://172.20.102.145:35357/v3
                username = placement
                password = placement
                ```
        3. 在/etc/httpd/conf.d/00-nova-placement-api.conf文件中添加如下内容，以允许apache访问placement API：
            ```
            <Directory /usr/bin>
            <IfVersion >= 2.4>
                Require all granted
            </IfVersion>
            <IfVersion < 2.4>
                Order allow,deny
                Allow from all
            </IfVersion>
            </Directory>
            ```
        4. 重启apache：
            ```
            systemctl restart httpd
            ```
        5. 初始化数据库：
            1. nova_api数据库：
                ```
                su -s /bin/sh -c "nova-manage api_db sync" nova
                ```
            2. nova_cell0数据库：
                ```
                su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
                ```
            3. nova_cell1数据库：
                ```
                su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
                ```
            4. nova数据库：
                ```
                su -s /bin/sh -c "nova-manage db sync" nova
                ```
            5. 验证nova cell0和nova cell1是否正常注册：
                ```
                nova-manage cell_v2 list_cells
                ```  
                ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81nova_cell%E6%98%AF%E5%90%A6%E6%B3%A8%E5%86%8C.png)  
            6. 设置computer服务开机自启，并启动：
                ```
                systemctl enable openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service

                systemctl start openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
                ```
3. 配置计算节点：
    1. 安装包：
        ```
        yum install openstack-nova-compute
        ```
    2. 编辑/etc/nova/nova.conf文件，做如下修改：
        + [DEFAULT]配置段：
            ```sh
            enabled_apis = osapi_compute,metadata
            transport_url = rabbit://openstack:centos@172.20.6.240:5672
            #后面的IP地址要跟端口号，不然会影响到openstack-nova-compute启动
            my_ip = 10.1.0.1
            use_neutron = True
            firewall_driver = nova.virt.firewall.NoopFirewallDrive
            #缺省情况下，Compute 使用内置的防火墙服务。由于 Networking 包含了防火墙服务，所以必须通过使用 nova.virt.firewall.NoopFirewallDriver 来去除 Compute 内置的防火墙服务。
            ```
        + [api]配置段：
            ```
            auth_strategy = keystone
            ```
        + [keystone_authtoken]配置段：
            ```
            auth_uri = http://172.20.102.145:5000
            auth_url = http://172.20.102.145:35357
            memcached_servers = 172.20.6.240:11211
            auth_type = password
            project_domain_name = default
            user_domain_name = default
            project_name = service
            username = nova
            password = nova
            ```
        + [vnc]配置段：
            ```
            enabled = True
            vncserver_listen = 0.0.0.0
            vncserver_proxyclient_address = 10.1.0.1
            novncproxy_base_url = http://172.20.102.145:6080/vnc_auto.html
            ```
        + [glance]配置段：
            ```
            api_servers = http://172.20.102.145:9292
            ```
        + [oslo_concurrency]配置段：
            ```
            lock_path = /var/lib/nova/tmp
            ```
        + [placement]配置段：
            ```
            os_region_name = RegionOne
            project_domain_name = Default
            project_name = service
            auth_type = password
            user_domain_name = Default
            auth_url = http://172.20.102.145:35357/v3
            username = placement
            password = placement
            ```
    3. 确定您的计算节点是否支持虚拟机的硬件加速:
        ```
        egrep -c '(vmx|svm)' /proc/cpuinfo
        ```
        + 若返回值非零那么，说明计算节点支持硬件加速且不需要额外的配置。

        + 若返回值为零，说明计算节点不支持硬件加速，需要额外配置：
            + 为虚拟机开启虚拟化：  
                ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%BC%80%E5%90%AF%E8%99%9A%E6%8B%9F%E5%8C%96.png)  
            + 编辑/etc/nova/nova.conf文件，在[libvirt]配置段修改：
                ```
                virt_type = qemu
                ```
    4. 启动计算服务及其依赖，并设置开机自启：
        ```
        systemctl enable libvirtd.service openstack-nova-compute.service
        systemctl start libvirtd.service openstack-nova-compute.service
        ```
    5. 查看hypervisor（控制节点）：
        ```
        openstack hypervisor list
        ```
    6. 主动发现计算节点（控制节点）：
        ```
        su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
        ```
    7. 设定定期主动发现计算节点，编辑/etc/nova/nova.conf，添加如下内容（控制节点）：
        + [scheduler]配置段：
            ```
            discover_hosts_in_cells_interval=300
            ```
    8. 验证计算节点（控制节点）：
        1. 列出主机列表：
            ```
            nova host-list
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81%E8%AE%A1%E7%AE%97%E8%8A%82%E7%82%B9_1.png)  
        2. 列出服务列表：
            ```
            nova service-list
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81%E8%AE%A1%E7%AE%97%E8%8A%82%E7%82%B9_2.png)  
        3. 列出镜像列表：
            ```
            nova image-list
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81%E8%AE%A1%E7%AE%97%E8%8A%82%E7%82%B9_3.png)  
            >此命令即将被替代，可使用openstack image list命令
        4. 列出服务组件：
            ```
            openstack compute service list
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81%E8%AE%A1%E7%AE%97%E8%8A%82%E7%82%B9_4.png)  
        5. 检查cells和placement API是否工作正常：
            ```
            nova-status upgrade check
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81%E8%AE%A1%E7%AE%97%E8%8A%82%E7%82%B9_5.png)  
        6. 列出keystone服务中的端点，以验证keystone的连通性：
            ```
            openstack catalog list
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81%E8%AE%A1%E7%AE%97%E8%8A%82%E7%82%B9_6.png)  
# 10. 网络服务“neutron”：
1. 准备数据库（数据库节点）：
    1. 创建neutron数据库：
        ```
        MariaDB [(none)]> create database neutron;
        ```
    2. 创建neutron用户并给予适当权限：
        ```
        MariaDB [(none)]> grant all on neutron.* to 'neutron'@'%' identified by 'neutron';
        ```
2. 配置控制节点（控制节点）：
    1. 创建neutron用户：
        ```
        openstack user create --domain default --password-prompt neutron
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAneutron%E7%94%A8%E6%88%B7.png)  
    2. 将neutron**用户**以admin的**角色**加入到service**项目**中：
        ```
        openstack role add --project service --user neutron admin
        ```
    3. 创建neutron服务：
        ```
        openstack service create --name neutron --description "OpenStack Networking" network
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAneutron%E6%9C%8D%E5%8A%A1.png)  
    4. 创建API端点：
        1. 创建公共端点：
            ```
            openstack endpoint create --region RegionOne network public http://172.20.102.145:9696
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAnetwork%E5%85%AC%E5%85%B1%E7%AB%AF%E7%82%B9.png)  
        2. 创建私有端点：
            ```
            openstack endpoint create --region RegionOne network internal http://172.20.102.145:9696
            ```
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAnetwork%E7%A7%81%E6%9C%89%E7%AB%AF%E7%82%B9.png)  
        3. 创建管理端点：
            ```
            openstack endpoint create --region RegionOne network admin http://172.20.102.145:9696
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BAnetwork%E7%AE%A1%E7%90%86%E7%AB%AF%E7%82%B9.png)  
    5. 配置网络选项：
        + 提供者网络：
            1. 安装组件：
                ```
                yum install openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables
                ```
            2. 配置组件：
                1. 编辑/etc/neutron/neutron.conf文件，做如下改动：
                    + [database]配置段：
                        ```sh
                        connection = mysql+pymysql://neutron:neutron@172.20.6.240/neutron
                        ```
                    + [DEFAULT]配置段：
                        ```sh
                        core_plugin = ml2
                        service_plugins =
                        #启用ml2插件，禁用其他插件

                        transport_url = rabbit://openstack:centos@172.20.6.240

                        auth_strategy = keystone
                        
                        notify_nova_on_port_status_changes = true
                        notify_nova_on_port_data_changes = true
                        ```
                    + [keystone_authtoken]配置段：
                        ```
                        auth_uri = http://172.20.102.145:5000
                        auth_url = http://172.20.102.145:35357
                        memcached_servers = 172.20.6.240:11211
                        auth_type = password
                        project_domain_name = default
                        user_domain_name = default
                        project_name = service
                        username = neutron
                        password = neutron
                        ```
                    + [nova]配置段：
                        ```
                        auth_url = http://172.20.102.145:35357
                        auth_type = password
                        project_domain_name = default
                        user_domain_name = default
                        region_name = RegionOne
                        project_name = service
                        username = nova
                        password = nova
                        ```
                    + [oslo_concurrency]配置段：
                        ```
                        lock_path = /var/lib/neutron/tmp
                        ```
                2. 配置Modular Layer 2(ML2)插件：
                    + 编辑/etc/neutron/plugins/ml2/ml2_conf.ini文件，做如下改动：
                        + [ml2]配置段：
                            ```sh
                            type_drivers = flat,vlan
                            #启用flat和VLAN网络
                            tenant_network_types =
                            #禁用私有网络
                            mechanism_drivers = linuxbridge
                            #启用Linuxbridge机制
                            extension_drivers = port_security
                            #启用端口安全扩展驱动
                            ```
                        + [ml2_type_flat]配置段：
                            ```sh
                            flat_networks = external,internal
                            #配置公共虚拟网络为flat网络
                            ```
                        + [securitygroup]配置段：
                            ```sh
                            enable_ipset = true
                            #启用ipset增加安全组的方便性
                            ```
                3. 配置Linuxbridge代理：
                    + 编辑/etc/neutron/plugins/ml2/linuxbridge_agent.ini文件，做如下改动：
                        + [linux_bridge]配置段：
                            ```
                            physical_interface_mappings = external:eth0,internal:eth1
                            ```
                        + [vxlan]配置段：
                            ```sh
                            enable_vxlan = false
                            #禁用VXLAN
                            ```
                        + [securitygroup]配置段：
                            ```sh
                            enable_security_group = true
                            firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
                            #启用安全组并配置Linux桥接iptables防火墙驱动
                            ```
                4. 配置DHCP代理：
                    + 编辑/etc/neutron/dhcp_agent.ini文件，做如下改动：
                        + [DEFAULT]配置段：
                        ```
                        interface_driver = linuxbridge
                        dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
                        enable_isolated_metadata = true
                        ```
    6. 配置元数据代理：
        + 编辑/etc/neutron/metadata_agent.ini文件，做如下改动：
            + [DEFAULT]配置段：
                ```sh
                nova_metadata_ip = 172.20.102.145
                metadata_proxy_shared_secret = metadata
                #元数据密码
                ```
    7. 配置计算服务来使用网络服务: 
        + 编辑/etc/nova/nova.conf文件，做如下改动：
            + [neutron]配置段：
                ```
                url = http://172.20.102.145:9696
                auth_url = http://172.20.102.145:35357
                auth_type = password
                project_domain_name = default
                user_domain_name = default
                region_name = RegionOne
                project_name = service
                username = neutron
                password = neutron
                service_metadata_proxy = true
                metadata_proxy_shared_secret = metadata
                ```
        3. 创建一个软链接：
            >网络服务初始化脚本需要一个超链接/etc/neutron/plugin.ini指向ML2插件配置文件/etc/neutron/plugins/ml2/ml2_conf.ini
            ```
            ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
            ```
        4. 同步数据库：
            ```
            su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
            ```
        5. 重启计算API服务：
            ```
            systemctl restart openstack-nova-api.service
            ```
        6. 设置服务开机自启并启动：
            ```
            systemctl enable neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
            systemctl start neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
            ```
        7. 控制端验证计算节点是否注册成功：
            >此步骤要求各服务器的时间必须一致
            ```
            neutron agent-list
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81neutron%E6%B3%A8%E5%86%8C%E6%88%90%E5%8A%9F.png)  
3. 配置计算节点（计算节点）：
    1. 安装组件：
        ```
        yum install openstack-neutron-linuxbridge ebtables ipset
        ```
    2. 配置通用组件：
        1. 编辑/etc/neutron/neutron.conf文件，做如下改动：
            + [DEFAULT]配置段：
                ```
                transport_url = rabbit://openstack:centos@172.20.6.240
                auth_strategy = keystone
                ```
            + [keystone_authtoken]配置段：
                ```
                auth_uri = http://172.20.102.145:5000
                auth_url = http://172.20.102.145:35357
                memcached_servers = 172.20.6.240:11211
                auth_type = password
                project_domain_name = default
                user_domain_name = default
                project_name = service
                username = neutron
                password = neutron
                ```
            + [oslo_concurrency]配置段：
                ```
                lock_path = /var/lib/neutron/tmp
                ```
    3. 提供者网络：
        + 配置Linuxbridge代理：
            + 编辑/etc/neutron/plugins/ml2/linuxbridge_agent.ini文件，做如下改动：
                + [linux_bridge]配置段：
                    ```
                    physical_interface_mappings = external:eth0,internal:eth1
                    ```
                + [vxlan]配置段：
                    ```
                    enable_vxlan = false
                    ```
                + [securitygroup]配置段：
                    ```
                    enable_security_group = true
                    firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
                    ```
    4. 配置计算服务来使用网络服务:
        + 编辑/etc/nova/nova.conf文件，做如下改动：
            + [neutron]配置段：
                ```
                url = http://172.20.102.145:9696
                auth_url = http://172.20.102.145:35357
                auth_type = password
                project_domain_name = default
                user_domain_name = default
                region_name = RegionOne
                project_name = service
                username = neutron
                password = neutron
                ```
    5. 重启计算服务：
        ```
        systemctl restart openstack-nova-compute.service
        ```
    6. 设置Linuxbridge代理开机自启，并启动：
        ```
        systemctl enable neutron-linuxbridge-agent.service
        systemctl start neutron-linuxbridge-agent.service
        ```
    7. 验证：
        1. 控制端验证计算节点是否注册成功：
            ```
            neutron agent-list
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81neutron%E6%B3%A8%E5%86%8C%E6%88%90%E5%8A%9F.png)  
        2. 列出加载的扩展来验证``neutron-server``进程是否正常启动：
            ```
            openstack extension list --network
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81neutron%E6%9C%8D%E5%8A%A1%E8%BF%9B%E7%A8%8B%E6%98%AF%E5%90%A6%E8%BF%90%E8%A1%8C.png)  
# 11. 仪表盘服务“horizon”：
1. 配置组件（控制节点）：
    1. 安装组件：
        ```
        yum install openstack-dashboard
        ```
    2. 编辑/etc/openstack-dashboard/local_settings文件，做如下改动：
        + 配置仪表盘以使用OpenStack服务：
            ```
            OPENSTACK_HOST = "controller"
            ```
        + 允许主机可以访问dashboard：
            ```sh
            ALLOWED_HOSTS = ['*']
            #此处为了测试，不考虑安全性，允许所有主机访问
            ```
        + 配置memcached会话存储服务：
            ```
            SESSION_ENGINE = 'django.contrib.sessions.backends.cache'

            CACHES = {
                'default': {
                    'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
                    'LOCATION': '172.20.6.240:11211',
                }
            }
            ```
        + 启用第3版认证API:
            ```
            OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST
            ```
        + 启用对域的支持:
            ```
            OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
            ```
        + 配置API版本:
            ```
            OPENSTACK_API_VERSIONS = {
                "identity": 3,
                "image": 2,
                "volume": 2,
            }
            ```
        + 配置Default为默认域：
            ```
            OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "Default"
            ```
        + 通过仪表盘创建的用户默认角色配置为user：
            ```
            OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"
            ```
        + 提供者网络下，禁用第三层网络服务：
            ```
            OPENSTACK_NEUTRON_NETWORK = {
                ...
                'enable_router': False,
                'enable_quotas': False,
                'enable_distributed_router': False,
                'enable_ha_router': False,
                'enable_lb': False,
                'enable_firewall': False,
                'enable_vpn': False,
                'enable_fip_topology_check': False,
            }
            ```
        + 配置时区：
            ```
            TIME_ZONE = "Asia/Shanghai"
            ```
    + 重启web服务器及会话存储服务：
        ```
        systemctl restart httpd.service memcached.service
        ```
2. 验证：
    >在浏览器输入http://172.20.102.145/dashboard  
    ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81web%E9%A1%B5%E9%9D%A2_1.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E9%AA%8C%E8%AF%81web%E9%A1%B5%E9%9D%A2_2.png)  
# 12. 创建虚拟机：
1. 创建提供者网络：
    + 创建网络：
        ```
        openstack network create  --share --external --provider-physical-network external --provider-network-type flat external-net
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack/%E5%88%9B%E5%BB%BA%E7%BD%91%E7%BB%9C.png)  
    + 创建子网：
        ```
        openstack subnet create --network external --allocation-pool start=172.20.248.100,end=172.20.248.200 --dns-nameserver 114.114.114.114 --gateway 172.20.0.1 --subnet-range 172.20.248.0/21 external_sub
        ```  
        ![avagar]()  
