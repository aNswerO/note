# MySQL存储引擎：
>决定了如何将数据库的信息以某种方式转存到磁盘的数据库文件中
## 管理存储引擎：
+ 查看MySQL支持的存储引擎：
```
    SHOW engines;
```
+ 查看当前默认的存储引擎：
```
    SHOW variables LIKE '%storage_engine%';
```
+ 设置默认的存储引擎:
```
    vim /etc/my.cnf

    [mysqld]
    default_storage_engine= InnoDB
```
+ 查看库中所有表使用的存储引擎：
```
    SHOW table STATUS FROM db_name;
```
+ 查看库中指定表的存储引擎：
```
    SHOW table STATUS LIKE 'tb_name';
    SHOW CREATE table tb_name;
```
+ 设置表的存储引擎：
```
    CREATE table tb_name(...) ENGINE=InnoDB
    ALTER TABLE tb_name ENGINE=InnoDB
```
## MyISAM：
>MySQL5.5.5前默认的数据库引擎；适用于只读或写操作较少、表较小、可接受长时间进行修复操作的场景
+ MyISAM的引擎文件：
    + tbl_name.frm：表格式定义
    + tbl_name.MYD：数据文件
    + tbl_name.MYI：索引文件
+ 引擎特点：
    + 不支持事务
    + 表级别锁定
    + 读写相互阻塞
    + 只缓存索引
    + 不支持外键约束
    + 不支持聚簇索引
    + 读取数据较快，占用资源较少
    + 不支持MVCC（多版本并发控制机制）高并发
    + 崩溃恢复性较差
## InnoDB：
+ InnoDB的数据库文件：
    + 两类文件放置在数据库独立目录中：
        + 数据文件（存储数据和索引）：tb_name.idb
        + 表格式定义：tb_name.frm
    + 所有InnoDB表的数据和索引放置于同一个表空间中
        + 表空间文件：datadir定义的目录下
        + 数据文件：ibddata1，ibddata2，...
    + 每个表单独使用一个表空间存储表的数据和索引
        + 启用：innodb_file_per_table=ON