# harbor：
+ harbor：
    ```
        Harbor是一个用于存储和分发Docker镜像的企业级Registry服务器，由vmware开源，其通过添加一些企业必需的功能特性，例如安全、标识和管理等，扩展了开源Docker Distribution。作为一个企业级私有Registry服务器，Harbor提供了更好的性能和安全。提升用户使用Registry构建和运行环境传输镜像的效率。Harbor支持安装在多个Registry节点的镜像资源复制，镜像全部保存在私有Registry中，确保数据和知识产权在公司内部网络中管控，另外，Harbor也提供了高级的安全特性，诸如用户管理，访问控制和活动审计等
    ```
+ harbor的功能：
    + 基于角色的访问控制：
        ```
            用户与Docker镜像仓库通过“项目”进行组织管理，一个用户可以对多个镜像仓库在同一命名空间（project）里有不同的权限
        ```
    + 镜像辅助：
        ```
            镜像可以在多个Registry实例中复制（同步）。尤其适合于负载均衡，高可用，混合云和多云的场景。图形化用户界面：用户可以通过浏览器来浏览，检索当前Docker镜像仓库，管理项目和命名空间
        ```
    + AD/LDAP支持： 
        ```
            Harbor可以集成企业内部已有的AD/LDAP，用于鉴权认证管理
        ```
    + 审计管理：
        ```
            所有针对镜像仓库的操作都可以被记录追溯，用于审计管理
        ```
    + RESTful API-RESTful API： 
        ```
            提供给管理员对于Harbor更多的操控,使得与其它管理软件集成变得更容易
        ```
## 部署harbor(CentOS 7.6.1810)：
1. 安装docker：
    ```
    yum install docker -y
    ```
2. 下载离线完整安装包：
    ```
    wget https://github.com/vmware/harbor/releases/download/v1.2.2/harbor-offline-installer-v1.2.2.tgz
    ```
3. 解压并配置harbor：
    + 解压：
        ```
        cd /usr/local/src/

        tar xvf harbor-offline-installer-v1.7.5.tgz
        ```
    + 创建软链接：
        ```
        ln -sv /usr/local/src/harbor/ /usr/local/
        ```
    + 安装python-pip：
        ```
        yum install epel-release -y

        yum install python-pip docker-compose -y
        ```
    + 启动docker-compose：
        ```
        docker-compose start
        ```
    + 编辑配置文件（harbor.cfg）：
        ```
        hostname = 192.168.6.100
        ui_url_protocol = http
        max_job_workers = 10 
        customize_crt = on
        ssl_cert = /data/cert/server.crt
        ssl_cert_key = /data/cert/server.key
        secretkey_path = /data
        admiral_url = NA
        log_rotate_count = 50
        log_rotate_size = 200M
        http_proxy =
        https_proxy =
        no_proxy = 127.0.0.1,localhost,core,registry
        email_identity = 
        email_server = smtp.mydomain.com
        email_server_port = 25
        email_username = sample_admin@mydomain.com
        email_password = abc
        email_from = admin <sample_admin@mydomain.com>
        email_ssl = false
        email_insecure = false
        harbor_admin_password = 123456
        auth_mode = db_auth
        ldap_url = ldaps://ldap.mydomain.com
        ldap_basedn = ou=people,dc=mydomain,dc=com
        ldap_uid = uid 
        ldap_scope = 3 
        ldap_timeout = 5
        ldap_verify_cert = true
        ldap_group_basedn = ou=group,dc=mydomain,dc=com
        ldap_group_filter = objectclass=group
        ldap_group_gid = cn
        ldap_group_scope = 2
        self_registration = on
        token_expiration = 30
        project_creation_restriction = everyone
        db_host = postgresql
        db_password = 123456
        db_port = 5432
        db_user = postgres
        redis_host = redis
        redis_port = 6379
        redis_password = 
        redis_db_index = 1,2,3
        clair_db_host = postgresql
        clair_db_password = 123456
        clair_db_port = 5432
        clair_db_username = postgres
        clair_db = postgres
        clair_updaters_interval = 12
        uaa_endpoint = uaa.mydomain.org
        uaa_clientid = id
        uaa_clientsecret = secret
        uaa_verify_cert = true
        uaa_ca_cert = /path/to/ca.pem
        registry_storage_provider_name = filesystem
        registry_storage_provider_config =
        registry_custom_ca_bundle = 
        verify_remote_cert = on
        ```
    + 更新配置（在harbor目录下）：
        ```
        ./prepare
        ```
        >若在harbor运行一段时间后需要更改配置，要先停止docker-compose，在更改配置，最后更新配置并启动docker-compose
    + 启动docker-compose：
        ```
        docker-compose start
        ```
    + 启动harbor（在harbor目录下）：
        ```
        ./install.sh
        ```
    + 浏览器访问并登录：
        >用户名为admin，密码在配置文件中定义，此处为123456  

        ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/harbor/harbor%E9%A1%B5%E9%9D%A2.png)  
        ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/harbor/%E7%99%BB%E5%BD%95.png)  
+ 配置docker使用harbor仓库上传/下载镜像：
    + 修改服务启动脚本/usr/lib/systemd/system/docker.service：
        >修改这一行的内容为：
        ```
        ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --insecure-registry 192.168.6.20
        ```
    + 重启docker服务：
        ```
        systemctl restart docker 
        ```
    + 启动docker-compose：
        ```
        docker-compose start
        ```
    + 验证能否登录harbor：  
        ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/harbor/%E9%AA%8C%E8%AF%81%E7%99%BB%E5%BD%95.png)  
    + 测试上传、下载镜像：
        + 导入镜像：
        ```
        docker load < /root/nginx.tar.gz 
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/harbor/%E6%B5%8B%E8%AF%95%E4%B8%8A%E4%BC%A0%E9%95%9C%E5%83%8F.png)  
        + 修改镜像的名称（需要指定格式才能将镜像上传至harbor仓库）：
        ```
        docker tag nginx 192.168.6.20/nginx/nginx:v1
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/harbor/%E4%BF%AE%E6%94%B9%E5%90%8D%E5%AD%97.png)  
        + 创建项目：  
            ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/harbor/%E6%96%B0%E5%BB%BA%E9%A1%B9%E7%9B%AE.png)  
            ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/harbor/%E6%88%90%E5%8A%9F%E5%88%9B%E5%BB%BA%E9%A1%B9%E7%9B%AE.png)  
        + 将镜像push到harbor：
            ```
            docker push 192.168.6.20/nginx/nginx:v1
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/harbor/%E4%B8%8A%E4%BC%A0%E9%95%9C%E5%83%8F%E6%88%90%E5%8A%9F.png)  
        + pull镜像：
            >如上图，有自带的pull命令
            ```
            docker pull 192.168.6.20/nginx/nginx:v1
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/harbor/pull%E9%95%9C%E5%83%8F.png)  
        
