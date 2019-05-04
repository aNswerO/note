# MySQL用户和权限管理：
## 与用户和权限管理有关的数据库和表：
+ 元数据数据库：mysql

+ 系统授权表：
    + db, host, user
    + columns_priv, tables_priv, procs_priv, proxies_priv
## 用户管理相关：
+ 用户账号格式：
```shell
    'USERNAME'@'HOST'
    #HOST：可以使用主机名、IP地址或网络地址
    #可以使用MySQL的通配符："%"（任意数量的任意字符），"_"（任意单个字符）
```
+ 创建用户：默认权限--USAGE
```
    CREATE USER 'USERNAME'@'HOST' [IDENTIFIED BY 'PASSWORD'];
```
+ 用户重命名：
```
    RENAME USER OLD_NAME TO NEW_NAME;
```
+ 删除用户：
```shell
    DROP USER 'USERNAME'@'HOST';

    DROP USER ''@'localhost';
    #删除默认的匿名用户
```
+ 修改用户密码：
```shell
    SET PASSWORD FOR 'username'@'host'=PASSWORD('password')
    #PASSWORD是一个MySQL的内置函数，用来加密字符串

    UPDATE mysql.user password=PASSWORD('password') WHERE user='USER';
    #通过更改表的方式修改用户密码
    FLUSH PRIVILEGES;
    #需要执行此命令更改表的密码修改才会生效
```
+ 忘记管理员密码的解决方法步骤：
    1. 启动mysqld进程时，使用--skip-grant-tables和--skip-networking选项
    2. 使用UPDATE命令修改管理员密码
    3. 关闭mysqld进程，移除上述两个选项，重启mysqld
## 权限管理相关：
+ 权限类别：
    + 管理类
        + CREATE USER：创建用户
        + SHOW DATABASES：显示数据库
        + RELOAD：重新加载配置文件
        + SHUTDOWN：关闭数据库
        + CREATE TEMPORARY TABLES：创建临时表
        + PROCESS：管理进程
    + 程序类：FUNCTION（函数）、PROCRDURE（存储过程）、TRIGGER（触发器）
        + CREATE：创建
        + ALTER：修改
        + DROP：删除
        + EXCUTE：执行
    + 数据库级别：DATABASE、TABLE
        + ALTER：修改
        + CREATE：创建
        + DROP：删除
        + CREATE VIEW：创建视图
        + SHOW VIEW：显示视图
        + GRANT OPTION：能将自己的权限转增给其他用户
    + 数据操作：
        + SELECT：查
        + INSERT：增
        + DELETE：删
        + UPDATE：改
    + 字段级别：
        + SELETE(col1,col2...)：针对指定的字段，有查询权限
        + UPDATE(col1,col2...)：针对指定字段，有修改权限
        + INSERT(col1,col2...)：针对指定字段，有添加权限
+ 授权：
    + 语法：
    ```shell
        GRANT priv_type [(column_list)],... ON [object_type] priv_level TO 'user'@'host' [IDENTIFIED BY 'password'] [WITH GRANT OPTION];
        #priv_type（权限类型）：ALL [PRIVILEGES]
        #column_list（指定字段）
        #object_type（对象类型）：TABLE|FUNCTION|PROCEDURE
        #priv_level（权限级别）：*（所有库）|*.*（所有库的所有表）|db_name.*（指定数据库的所有表）|db_name.tbl_name（指定数据库的指定表）|tbl_name（当前库的表）|db_name.toutine_name（指定库的函数、存储过程、触发器）
        #with GRANT option（被授权的用户将自己的权限授予其他用户）：GRANT OPTION| MAX_QUERIES_PER_HOUR count| MAX_UPDATES_PER_HOUR count| MAX_CONNECTIONS_PER_HOUR count| MAX_USER_CONNECTIONS count
    ```
    + 示例：
    ```shell
        GRANT SELECT (col1),INSERT (col1,col2) ON mydb.mytbl TO 'someuser'@'somehost';
        #授权用户对mydb数据库的mytbl表的可以查询字段1、可以增加字段1和字段2
    ```
+ 查看权限：
```
    SHOW GRANTS FOR user@'host';
```
+ 回收授权：
    + 语法：
    ```
        REVOKE priv_type [(column_list)] [, priv_type [(column_list)]] ... ON [object_type] priv_level FROM user [, user] ...
    ```
    + 示例：
    ```shell
        REVOKE DELETE ON testdb.* FROM 'testuser'@‘172.16.0.%’;
        #回收testuser用户在172.16.0.0网段内所有主机上对于testdb数据库的所有表的delete权限
    ```
