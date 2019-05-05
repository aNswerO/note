# 文件管理系统的缺点：
+ 编写引用程序不方便

+ 数据的冗余不可避免
+ 依赖应用程序
+ 不支持对文件的并发访问
+ 数据间的联系弱
+ 难以按用户的视图表示数据
+ 无安全控制功能
# 数据库管理系统的优点：
+ 数据管理系统是相互关联数据的集合

+ 数据的冗余较少
+ 程序与数据相互独立
+ 保证数据的安全和可靠
+ 最大限度地保证数据的正确性
+ 数据可以并发使用并能同时保证一致性

# DBMS（数据管理系统）：
>管理数据库的系统软件，是数据库体系的核心
+ 数据库是数据的汇集，它以一定的组织方式存于存储设备上

+ 应用程序指以数据库为基础的应用程序
+ DBMS的基本功能：
    + 数据定义
    + 数据处理
    + 数据安全
    + 数据备份
# 关系型数据库：
+ 关系：二维表；列与行的次序不重要

+ 行（row）：表中的行，也被称为记录（record）
+ 列（column）：表中的列，也被称为属性、字段（filed）
+ 主键（Primary Key）：用于唯一确定一个记录中的字段
+ 域（domain）：属性的取值范围
# 关系型数据库：
## 联系类型：
+ 一对一
+ 一对多
+ 多对多
## 数据的操作：
+ 增：insert
+ 删：delete
+ 改：update
+ 查：select
## 数据的约束条件：
+ 约束（constraint）：表中的数据要遵守的限制
    + 主键（primary key）：一个或多个字段的组合，填入的数据必须能在表中唯一标识本行；必须提供数据（非空）；一个表中只能有一个

    + 唯一键（unique key）：一个或多个字段的组合，填入的数据必须能在表中唯一标识本行；内容允许为空；一个表中可以存放多个
    + 外键：一个表中的某个字段可填入的数据取决于另一个表中的主键或唯一键已有的数据
    + 检查：字段值在一定范围内
+ 数据的约束条件：一组完整性规则的集合
    + 实体（行）完整性
    + 域（列）完整性
    + 参考完整性
## 关系型数据库的常见组件：
+ database：数据库

+ table：表
    + row：行
    + column：列
+ index：索引
+ view：视图
+ user：用户
+ privilege：权限
+ procedure：存储过程
+ function：存储函数
+ trigger：触发器
+ event schedule：事件调度器
>命名规则：  
可包括数字和"#"、"_"、"$"  
必须以字母开头  
不能使用MySQL保留字  
同一database（schema）下的对象不能重名
# 简易数据规划流程：
+ 第一阶段：收集数据，得到字段

    + 收集必要的、完整的数据
    + 转换成字段
+ 第二阶段：把字段归类，归入表，建立表的关联
    + 关联：表和表间的关系
    + 分隔数据表并建立关联
    + 节省空间、减少输入错误
    + 方便数据修改
+ 第三阶段：
    + 规范数据库
# 数据库设计范式：
+ 设计范式基础概念：
>设计关系型数据库时，遵从不同的规范要求，设计出合理的关系型数据库，不同的规范被称为不同的**范式**，越高的**范式**的数据库冗余越小
+ 范式：
    + **第一范式**（1NF）：无重复的列，每一列都是不可分割的基本数据项，同一列中不能有多个值（即实体中的某个属性不能有多个值或不能有重复的值），确保每一列的原子性；**第一范式**是对关系模型的基本要求不满足**第一范式**的数据库不是关系型数据库

    + **第二范式**（2NF）：**第二范式**必须先满足**第一范式**；属性完全依赖于**主键**，要求每行必须可以被唯一区分；通常为表加上一个列，以存储各个实例的唯一标识（**主键**），非主键的字段需要与整个**主键**有直接相关性
    + 第三范式（3NF）：满足**第三范式**必须先满足**第二范式**；属性不依赖其他非主属性，**第三范式**要求一个数据库表中不包含已在其他表中已包含的非主关键字信息，非主键的字段间不能有从属关系
# SQL：
+ SQL（Structure Query Language）：结构化查询语言
    + 数据存储协议：应用层协议
    + 基于C/S架构：
        + S（server）：监听与套接字，接收处理客户端的应用请求
        + C（client）
+ SQL语言规范：
    + **SQL语句**不区分大小写（建议大写）
    
    + **SQL语句**可单行或多行书写（使用";"结尾）
    + 关键词不能跨行写、不能简写
    + 用空格和缩进提高可读性
    + 子句通常位于独立行；便于编辑、提高可读性
    + 注释：
        + /\* 注释内容 \*/：多行注释
        + --注释内容：单行注释
+ SQL语句分类：
    + DDL（Data Defination Language）：数据定义语言

    + DML（Data Manipulation Language）：数据操纵语言
    + DCL（Data Control Language）：数据控制语言
    + DQL（Data Query Language）：数据查询语言
+ SQL语句组成：
    + keyword（关键字）组成clause（子句）
    + 多条clause（子句）组成语句
# MySQL：
## MySQL的特性：
+ 插件式存储引擎
+ 单进程，多线程
+ 诸多扩展和新特性
+ 提供了较多测试组件
+ 开源
## MariaDB程序：
+ 客户端程序：

    + mysql：交互式CLI工具
    
    + mysqldump：备份工具；基于mysql协议向mysqld发起查询请求，并将查得的所有数据转换成操作语句保存在文本文件中
    + mysqladmin：基于mysql协议管理mysqld
    + mysqlimport：数据导入工具
+ MyISAM存储引擎的管理工具
    + myiasmchk：检查MyISAM库
    + myisampack：打包MyISAM库（只读）
+ 服务器端程序：
    + mysqld_safe：
    + mysqld
    + mysql_mutli
+ 服务器端配置：
    + 工作特性的配置方式：
        + 命令行选项
        + 配置文件：类ini格式；/etc/my.cnf
+ 端口：3306/tcp
## 用户账号相关：
+ mysql用户账号由两部分组成：
```
    USERNAME@HOST
```
+ 说明：HOST限制此用户可以通过哪些远程主机连接mysql服务器
+ 支持使用通配符：
    + %：匹配任意长度任意字符
    + _：匹配任意单个字符
## mysql使用模式：
+ 交互式模式：
    + 客户端命令：
        + \h：help
        + \u：user
        + \s：status
        + \!：system
    + 服务器命令：
        + SQL语句，需要语句结束符";"
            + mysql>use mysql;：切换至mysql数据库
            + mysql>select user();：查看当前用户
+ 非交互式模式：
    + 客户端可用选项：
        + -A：禁止补全
        + -u：用户名；默认root
        + -h：服务器主机；默认localhost
        + -p：用户密码；默认为空密码
        + -P：服务器端口
        + -S：指定连接socket文件路径
        + -D：指定数据库
        + -C：启用压缩
        + -e "SQL"：执行SQL命令
        + -V：显示版本
        + -v：显示详细信息
        + --print-defaults：获取程序默认使用的配置
## socket相关：
+ 服务器监听的两种socket地址：
    + ip socket：监听在tcp的3306端口，用于远程通信
    + unix socket：监听在sock文件（/var/lib/mysql/mysql.sock）上，用于本机进程间通信
    >host为localhost（127.0.0.1）时，自动使用unix sock
## MySQL中的系统数据库：
+ mysql：

>MySQL中的核心数据库，主要负责存储数据库的用户、权限设置、关键字等MySQL需要使用的控制和管理信息
+ performance_schema：
>主要用于收集数据库服务器性能参数；库中表使用的存储引擎为performance_schema，用户不能创建存储引擎为performance_schema的表
+ information_schema：
>虚拟数据库，提供了访问数据库元数据的方式，即数据的数据（数据库名和表名、列类型、访问权限）
## MySQL服务器配置相关：
+ 配置文件中mysqld段：内容为服务器系统变量和状态变量
>服务器有些参数（会话级）支持服务运行时修改，会立即生效，但不会永久生效，退出会话会失效；有些参数不支持，只能修改配置文件后重启服务使之永久生效；有些参数的作用域为全局，且无法改变；有些则可为每个用户提供单独的设置（会话）
+ 获取mysqld的可用选项列表：
```shell
    mysqld --help --verbose
    mysqld --print-defaults    #获取默认设置
```
+ 设置服务器选项的方法：
    + 命令行设置：
    ```shell
        ./msyqld-safe --skip-name-resolve=1
        #关闭DNS反向解析
    ```
    + 在配置文件中设置：
    ```
        vim /etc/my.cnf

        [mysqld]
        skip-name-resolve=1
    ```
## MySQL服务器变量：
+ 服务器系统变量：全局和会话
    + 查看系统变量：
    ```
        mysql> SHOW GLOBAL VARIABLES;
        mysql> SHOW [SESSION] VARIABLES;
        mysql> SELECT @@VARIABLES;
    ```
    + 修改服务器变量的值：
    ```
        msyql> SET var_name=expr
    ```
    + 修改全局变量：
    >仅对修改之后新创建的会话有效
    ```
        mysql> SET GLOBAL var_name=value
        mysql> SET @@global.var_name=value
    ```
    + 修改会话变量：
    ```
        mysql> SET [SESSION] var_name=value
        mysql> SET @@[SESSION.] var_name=value
    ```
+ 服务器状态变量：全局和会话
>只读；用于保存mysqld运行中的统计数据的变量
```
    msyql> SHOW GLOBAL STATUS;
    mysql> SHOW [SESSION] STATUS;
```
## 服务器变量SQL_mode：
>定义了MySQL支持的SQL语法；对其进行设置可以完成一些约束检查的工作，可分别进行全局的设置和当前会话的设置
+ 常见mode：
```shell
   NO_AUTO_CREATE_USER    
   #禁止GRANT创建密码为空的用户
   
   NO_ZERO_TIME    
   #禁止使用'0000-00-00'的时间
   
   ONLY_FULL_GROUP_BY    
   #对于GROUP BY的聚合操作，如果在SELECT语句中没有出现GROUP BY，则认为此SQL语句是不合法的
   
   NO_BACKSLASH_ESCAPES
   #"\"视为普通字符而非转义字符
   
   PIPES_AS_CONCAT
   #'|'视为连接操作而非“或”运算符
```
