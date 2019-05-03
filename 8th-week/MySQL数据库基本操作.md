# 数据库：
## 数据库操作：
+ 创建数据库：

```
    CREATE DATABASE|SCHEMA [IF NOT EXISTS];
    CHARACTER SET 'character set name' COLLATE 'collate name'
```
+ 修改数据库：
```
    ALTER DATABASE DB_NAME character set utf8;
```
+ 删除数据库：
```
    DROP DATABASE|SHCEMA [IF EXITSTS] 'DB_NAME';
```
+ 查看支持所有字符集：
```
    SHOW CHARACTER SET;
```
+ 查看支持所有排序规则：
```
    SHOW COLLATION;
```
+ 查看数据库列表：
```
    SHOW DATABASES;
```
+ 获取命令使用帮助：
```
    HELP KEYWORD;
```
## 表操作：
+ 创建表：
    + 直接创建：
    ```shell
        CREATE TABLE [IF NOT EXISTS] table_name(create_definition,...) [table_options]
        #CREATE TABLE：创建表
        #[IF NOT EXISTS]：表示表不存在时才创建
        #table_name：创建的表名字
        #(create——definition)：创建表的多种定义（字段定义、约束定义、索引定义）
        #table_options：指定存储引擎、自动增长起始的字段、字符集
    ```
    + 示例：
    ```shell
        MariaDB [db1]> CREATE table students
        -> (
        -> id int primary key auto_increment,    #定义一个“id”字段，添加主键约束，自动增长
        -> name varchar(20) not null,    #定义一个“name”字段，数据类型为定长字串，长度为20，非空
        -> age tinyint unsigned,    #定义一个“age”字段，数据类型为tinyint，不带正负符号
        -> gender enum('m','f') default 'm',    #定义一个“gender”字段，在“f”和“m”中取值的枚举类型，默认为“m”
        -> index(name)    #为“name”创建索引   
        -> );
    ```
    + 通过查询现存表来创建新表，新表会被直接插入查询到的数据：
    ```shell
        CREATE TABLE table_name1 SELECT item1，item2... FROM table_name2
        #只在新表中插入对应的数据，约束和索引不会被插入；需要索引和约束时要手动指明
    ```
    + 复制表结构：
    ```shell
        CREATE TABLE table_name1 LIKE table_name2
        #复制后的新表与旧表的表结构完全相同，即字段、约束、索引完全相同
    ```
+ 删除表：
```
    DROP TABLE table_name[, tablen_ame2...]
```
+ 修改表：
```
    ALTER TABLE table_name [alter_specification[, alter_specification]...]
```
+ 示例：
    + 重命名表：
    ```
        ALTER TABLE table1 RENAME AS table2;
    ```
    + 添加字段：
    ```shell
        ALTER TABLE table1 ADD hobby char;
        #为table1添加一个新字段“hobby”，数据类型为char

        ALTER TABLE table1 ADD id int FIRST;
        #为table1添加一个新字段“id”，数据类型为int，作为表的第一个字段

        ALTER TABLE table1 ADD name char(10) AFTER id;
        #为table1添加一个新字段“name”，数据类型为char，位于id字段后面
    ```
    + 删除字段：
    ```shell
        ALTER TABLE table1 DROP hobby;
        #删除table1表中的hobby字段
    ```
    + 修改字段：
    ```shell
        ALTER TABLE table1 CHANGE name name1 char(5);
        #将table1中的name字段名改为name1，并指定数据类型；不指定会报错
    ```
    + 修改字段的数据类型：
    ```
        ALTER TABLE table1 MODIFY age int;
    ```
## 约束：
+ 非空约束：not null

```shell
    ALTER TABLE table2 MODIFY name char(10) not null;
    #为name字段添加非空约束

    ALTER TABLE table2 MODIFY name char(10) null;
    #取消name字段的非空约束
```
+ 自动增长：auto_increment
```shell
    ALTER TABLE table2 MODIFY id int auto_increment;
    #为id字段添加自动增长

    ALTER TABLE table2 MODIFY id int;
    #删除id字段的自动增长
```
>一个表中同时只能有一个字段为自动增长；如有自动增长的字段，此字段为主键
+ 主键约束：primary key
```shell
    ALTER TABLE table2 ADD primary key(id);
    #为id字段添加主键约束

    ALTER TABLE table2 DROP primary key；
    #删除主键约束；若主键上存在自动增长或外键约束，需要先删除自动增长和外键约束，再删除主键约束
```
+ 唯一键约束：unique key
```shell
    ALTER TABLE  table2 add unique key(id_num);
    #为id_num字段添加唯一键约束

    ALTER TABLE table2 DROP index id_num;
    #为id_num字段删除唯一键约束
```
+ 外键约束：foreign key
```shell
    ALTER TABLE students ADD CONSTRAINT students_id_fk FOREIGN KEY(id) REFERENCES teachers(id);
    #为students表中的id字段添加了一个名为“students_id_fk”的外键，引用了teachers表中的id字段

    ALTER TABLE students DROP FOREIGN KEY student_id_fk；
    #删除外键；前提要先得知外键的名字
```
+ 查看约束：
```
    SELECT * FROM information_schema_column_usage WHERE table_name='table_name'
```
