# SQL语句：
## DML语句：
+ INSERT：一次插入一行或多行数据
    + 语法：
    ```shell
       INSERT table_name [(column_name1,...)] VALUES (val1,...), (val2,...)
    ```
    + 示例：
    ```shell
        INSERT students (stuid,name,age,gender,classid,teacherid)VALUES(6,'qyh',24,'M',36,1);
        #添加一行“qyh”的数据，录入stuid、name等信息；VALUES前后的值要一一对应

        INSERT students （stuid,name,age,gender,classid,teacherid）VALUES(7,'asd',23,'M',36,1),(8,'zxc',25,'F',37,2);
        #添加两行数据，分别为名字为“asd”和“zxc”的学生的信息
    ```
+ UPDATE：修改表内容
    + 语法：
    ```shell
        UPDATE [LOW_PRIORITY] [IGORE] table_reference SET col_name1={expr1|DEFAULT} [, col_name2={expr2|DEFAULT}]... [WHERE where_condition]
    ```
    + 示例：
    ```shell
        UPDATE students SET name='qwe',age=25 WHERE stuid=7;
        #修改stuid=7那条记录的name和age字段、
        #如果未指定WHERE，会更改表中所有的记录；可以在连接登录数据库时使用-U选项启用secure update mode（安全更新模式）避免出现忘记添加WHERE导致出现误操作；或者在配置文件中添加safe-updates开启secure update mode
    ```
+ DELETE：删除表中的某些记录
    + 语法：
    ```shell
        DELETE [LOW_PRIORITY] [QUICK] [IGNORE] FROM tbl_name [WHERE where_condition]
    ```
    + 示例：
    ```shell
        DELETE FROM students WHERE stuid=6;
        #删除stuid=6的记录；若未指定WHERE，则会删除表中所有的记录
        #可以开启secure update mode防止出现误操作
    ```
## DQL语句：
+ SELECT：查询表中的信息
    + 语法：
    ```shell
        SELECT
    [ALL | DISTINCT | DISTINCTROW ]
      [HIGH_PRIORITY]
      [STRAIGHT_JOIN]
      [SQL_SMALL_RESULT] [SQL_BIG_RESULT] [SQL_BUFFER_RESULT]
      [SQL_CACHE | SQL_NO_CACHE] [SQL_CALC_FOUND_ROWS]
    select_expr [, select_expr ...]
    [FROM table_references
    [WHERE where_condition]
    [GROUP BY {col_name | expr | position}
      [ASC | DESC], ... [WITH ROLLUP]]
    [HAVING where_condition]
    [ORDER BY {col_name | expr | position}
      [ASC | DESC], ...]
    [LIMIT {[offset,] row_count | row_count OFFSET offset}]
    [PROCEDURE procedure_name(argument_list)]
    [INTO OUTFILE 'file_name'
        [CHARACTER SET charset_name]
        export_options
      | INTO DUMPFILE 'file_name'
      | INTO var_name [, var_name]]
    [FOR UPDATE | LOCK IN SHARE MODE]]
    ```
    + MySQL中的聚合函数：
        + max()：对查询结果进行分组取出最大值
        + min()：对查询结果进行分组取出最小值
        + avg()：对查询结果进行分组计算出平均值
        + sum()：对查询结果进行分组计算出总和
        + count()：对查询结果进行分组计算出个数
    + 示例（单表查询）：
    ```shell
        SELECT name,age FROM students;
        #查询students表中的name和age字段

        SELECT name AS 姓名,age AS 年龄 FROM students;
        #将name和age以对应的别名显示

        SELETE * FROM student WHERE gender='F';
        #显示students表中所有gender字段为'F'的记录

        SELECT * FROM students WHERE age<20;
        #显示students表中所有age字段小于20的记录

        SELECT * FROM students WHERE age>=20 AND age<=30;
        SELECT * FROM students WHERE age BETWEEN 20 AND 30;
        #显示students表中所有age字段大于等于20且小于等于30的记录

        SELECT * FROM students WHERE name LIKE 's%';
        #显示students表中所有name字段以's'开头的记录

        SELECT * FROM students WHERE classid IS [NOT] null;
        #显示students表中所有classid为[不为空]的记录

        SELECT DISTINCT gender FROM students;
        #显示有多少种性别，即gender字段中有多少值

        SELECT AVG(age) from students where gender='M';
        #显示gender字段为'M'的记录的age字段的平均值

        SELECT gender,avg(age) FROM students GROUP BY gender;
        #显示所有种类的gender字段的值对应记录的age字段的平均值

        SELECT gender,count(*) FROM students GROUP BY gender;
        #显示所有种类的gender字段对应记录的个数

        SELECT gender,count(*) FROM students GROUP BY gender HAVING gender='M';
        SELECT gender,count(*) FROM students WHERE gender='M' GROUP BY gender;
        #显示gender字段为'M'的记录的个数

        SELECT classid,gender,count(*) FROM students GROUP BY gender,classid;
        #显示以gender和classid字段分组的记录中的classid和gender字段，并计算出个数

        SELECT age FROM students ORDER BY age;
        #升序显示students表中的age字段
        SELECT age FROM students ORDER BY age DESC;
        #降序显示students表中的age字段

        SELECT * FROM students ORDER BY age LIMIT 3;
        #以age字段为基准从小到大排序，显示student表中前三条记录所有字段
    ```
    + 示例（子查询）：在SQL语句中调用另一个SQL语句的结果
    ```shell
        SELECT * FROM students WHERE age < (SELECT avg(age) FROM students);
        #显示students表中age字段对应的值小于平均值的记录
    ```
### 多表操作：
+ union：纵向合并（将多个表的内容纵向合并，前提需要合并的表的字段数相同）
    + 去重功能：
    ```
        SELECT * FROM students UNION SELECT * FROM students;
    ```
+ cross join：交叉连接（将表1的每一条记录分别于表2的每一条记录横向合并，笛卡尔乘积；意义不大）
    + 示例：
    ```
        SELECT * FROM students CROSS JOIN teachers;
    ```
+ inner join：内连接
    + 示例：
    ```shell
        SELECT * FROM students INNER JOIN teachers ON students.teacherid=teachers.tid;
        #显示出students表中teacherid与teachers表中tid相同的记录
    ```
+ left [outer] join：左[外]连接
    + 示例：
    ```shell
        SELECT * FROM students  LEFT JOIN teachers ON students.teacherid=teachers.tid;
        #显示students表中所有记录以及teachers表中tid与students表中teacherid相等的记录，不相等的记录用null填充

        SELECT * FROM students  LEFT JOIN teachers ON students.teacherid=teachers.tid WHERE teachers.tid IS null;
        #显示students表中所有记录以及teachers表中tid与students表中teacherid相等的记录，并刨去相等的记录只剩下用null填充的记录
    ```
+ right [outer] join：右[外]连接
    + 示例：
    ```shell
        SELECT * FROM students  RIGHT JOIN teachers ON students.teacherid=teachers.tid;
        #显示teachers表中所有记录以及students表中teacherid与teachers表中tid相等的记录，不相等的记录用null填充

        SELECT * FROM students  RIGHT JOIN teachers ON students.teacherid=teachers.tid WHERE teachers.tid IS null;
        #显示teachers表中所有记录以及students表中teacher与teachers表中tid相等的记录，并刨去相等的记录只剩下用null填充的记录
    ```
+ full outer join：全外连接（MySQL不支持，需要使用左连接和外连接的纵向合并）
    + 示例：
    ```shell
        SELECT * FROM students LEFT JOIN teachers ON students.teacherid=teachers.tid UNION SELECT * FROM students  RIGHT JOIN teachers ON students.teacherid=teachers.tid;
        #显示students表、teachers表中的所有记录和students表中teacher与teachers表中tid相等的记录

        SELECT * FROM (SELECT s.stuid,s.name s_name,s.teacherid,t.tid,t.name t_name FROM students s LEFT JOIN teachers t ON s.teacherid=t.tid UNION SELECT s.stuid,s.name s_name,s.teacherid,t.tid,t.name t_name FROM students s RIGHT JOIN teachers t ON s.teacherid=t.tid) AS a WHERE a.teacherid IS null OR a.tid IS null;
        #显示students表、teachers表中的所有记录和students表中teacher与teachers表中tid相等的记录，刨去相等的记录，只显示用null填充的记录
    ```
