# 实验前提：
+ 关闭SELinux
+ 启用二进制日志功能（默认为启用）；添加log_bin=/PATH/TO/_BIN_LOG_FILE指定二进制日志的存放位置和名字  
![avagar](https://github.com/aNswerO/note/blob/master/9th-week/pic/%E5%BC%80%E5%90%AF%E4%BA%8C%E8%BF%9B%E5%88%B6%E6%97%A5%E5%BF%97.png)  
# 实验数据库的内容：
![avagar](https://github.com/aNswerO/note/blob/master/9th-week/pic/%E5%AE%9E%E9%AA%8C%E6%95%B0%E6%8D%AE%E5%BA%93%E5%86%85%E5%AE%B9_1.png)  
![avagar](https://github.com/aNswerO/note/blob/master/9th-week/pic/%E4%BF%AE%E6%94%B9%E5%89%8D%E7%9A%84%E8%A1%A8.png)
# 实验步骤：
1. 完全备份：
```shell
  mysqldump -A --single-transaction --master-data=1 | xz > /data/backup/all.sql.xz
  
  #--single-transaction：将事务的隔离级别设置为可重复读（repeatable read），即同一事务中的每一次查询会读取到相同的内容；保证了在备份期间，其他线程提交的对表的修改不会影响到备份线程的数据
  #--master-data：使dump的输出包含CHANGE MASTER TO语句，标记了二进制日志的坐标（包括文件名和位置）；设置为1时，此语句在被导入时生效；设置为2时，此语句被注释，在被导入时不会生效
```

2. 在完全备份后对数据库进行修改：
```msyql
  mysql> insert students (name,age)value(jack,34);
  mysql> insert students (name,age)value(mike,54);
```
3. 模拟数据库的破坏：
```shell
  rm -rf /var/lib/mysql/*
```
4. 配合使用备份文件和二进制日志文件对数据库进行恢复：
    1. 重启服务：
    ```shell
      systemctl restart mariadb
    ```
    1. 将备份文件的压缩文件解压：
    ```
      xz -d /data/backup/all.sql.xz
    ```

    2. 连接数据库，临时关闭二进制日志功能：
    ```msyql
      mysql> SET sql_log_bin=off;
    ```
    3. 将备份文件导入到数据库中：
    ```mysql
      mysql> source /data/backup/all.sql
    ```
    4. 数据库已恢复到完全备份时的状态：  
    ![avagar](https://github.com/aNswerO/note/blob/master/9th-week/pic/%E6%81%A2%E5%A4%8D%E5%90%8E%E7%9A%84%E6%95%B0%E6%8D%AE%E5%BA%93.png)  
    5. 查看备份文件，找到二进制日志的坐标:  
    ![avagar](https://github.com/aNswerO/note/blob/master/9th-week/pic/%E4%BA%8C%E8%BF%9B%E5%88%B6%E6%97%A5%E5%BF%97%E5%9D%90%E6%A0%87.png)  
    6. 将上面记录的二进制日志的坐标之后的内容导出到sql文件中
    ```shell
      mysqlbinlog --start-position=7655 /data/log_bin/mysql_bin_log.000007 > inc.sql

      #--start-position：指定了要导出的二进制日志的开始位置
    ```
    7. 将导出的inc.sql文件导入数据库：
    ```mysql
      mysql> source /data/backup/inc.sql
    ```
    8. 查看students表，已恢复：  
    ![avagar](https://github.com/aNswerO/note/blob/master/9th-week/pic/%E6%81%A2%E5%A4%8D_2.png)
