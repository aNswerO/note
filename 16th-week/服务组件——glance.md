## 镜像服务glance：
+ glance的功能：
    ```
        在创建虚拟机时，需要先将image（镜像）上传到glance，glance负责image的查询、删除、上传、注册、获取和访问权限管理
    ```
+ glance的两个服务：
    + glace-api：
        + 负责接收镜像的上传、删除和读取

        + 监听端口：9292
    + glance-Registry：
        + 负责与数据库进行数据交互，用于存储或获取镜像的metadata（元数据），并提供image的metadata相关的REST接口

        + 监听端口：9191
+ image相关：
    + 数据存放：
    ```
        image的metadata通过glance-Registry存放在数据库中
    ```
    + 访问权限：
        + public：公共的；可以被所有tenant使用

        + private：私有的；只能被image owner所在的tenant使用
        + shared：共享的；一个非公有的image可以共享给其他的tenant
        + protected：受保护的；被保护的image不能被删除
    + 状态：
        + queued：没有上传image data，只有数据库中的image metadata

        + saving：正在上传image data
        + active：正常状态
        + deleted：已删除
        + pending_delete：等待删除
        + killed：image metadata不正确，等待被删除
