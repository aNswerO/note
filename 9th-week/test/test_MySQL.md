# 数据库中各表的内容如下：
+ students表：

| StuID | Name          | Age | Gender | ClassID | TeacherID |
|-------|---------------|-----|--------|---------|-----------|
|     1 | Shi Zhongyu   |  22 | M      |       2 |         3 |
|     2 | Shi Potian    |  22 | M      |       1 |         7 |
|     3 | Xie Yanke     |  53 | M      |       2 |        16 |
|     4 | Ding Dian     |  32 | M      |       4 |         4 |
|     5 | Yu Yutong     |  26 | M      |       3 |         1 |
|     6 | Shi Qing      |  46 | M      |       5 |      NULL |
|     7 | Xi Ren        |  19 | F      |       3 |      NULL |
|     8 | Lin Daiyu     |  17 | F      |       7 |      NULL |
|     9 | Ren Yingying  |  20 | F      |       6 |      NULL |
|    10 | Yue Lingshan  |  19 | F      |       3 |      NULL |
|    11 | Yuan Chengzhi |  23 | M      |       6 |      NULL |
|    12 | Wen Qingqing  |  19 | F      |       1 |      NULL |
|    13 | Tian Boguang  |  33 | M      |       2 |      NULL |
|    14 | Lu Wushuang   |  17 | F      |       3 |      NULL |
|    15 | Duan Yu       |  19 | M      |       4 |      NULL |
|    16 | Xu Zhu        |  21 | M      |       1 |      NULL |
|    17 | Lin Chong     |  25 | M      |       4 |      NULL |
|    18 | Hua Rong      |  23 | M      |       7 |      NULL |
|    19 | Xue Baochai   |  18 | F      |       6 |      NULL |
|    20 | Diao Chan     |  19 | F      |       7 |      NULL |
|    21 | Huang Yueying |  22 | F      |       6 |      NULL |
|    22 | Xiao Qiao     |  20 | F      |       1 |      NULL |
|    23 | Ma Chao       |  23 | M      |       4 |      NULL |
|    24 | Xu Xian       |  27 | M      |    NULL |      NULL |
|    25 | Sun Dasheng   | 100 | M      |    NULL |      NULL |
+ classes表：

| ClassID | Class          | NumOfStu |
|---------|----------------|----------|
|       1 | Shaolin Pai    |       10 |
|       2 | Emei Pai       |        7 |
|       3 | QingCheng Pai  |       11 |
|       4 | Wudang Pai     |       12 |
|       5 | Riyue Shenjiao |       31 |
|       6 | Lianshan Pai   |       27 |
|       7 | Ming Jiao      |       27 |
|       8 | Xiaoyao Pai    |       15 |
+ courses表：

| CourseID | Course         |
|----------|----------------|
|        1 | Hamo Gong      |
|        2 | Kuihua Baodian |
|        3 | Jinshe Jianfa  |
|        4 | Taiji Quan     |
|        5 | Daiyu Zanghua  |
|        6 | Weituo Zhang   |
|        7 | Dagou Bangfa   |
+ score表：

| ID | StuID | CourseID | Score |
|----|-------|----------|-------|
|  1 |     1 |        2 |    77 |
|  2 |     1 |        6 |    93 |
|  3 |     2 |        2 |    47 |
|  4 |     2 |        5 |    97 |
|  5 |     3 |        2 |    88 |
|  6 |     3 |        6 |    75 |
|  7 |     4 |        5 |    71 |
|  8 |     4 |        2 |    89 |
|  9 |     5 |        1 |    39 |
| 10 |     5 |        7 |    63 |
| 11 |     6 |        1 |    96 |
| 12 |     7 |        1 |    86 |
| 13 |     7 |        7 |    83 |
| 14 |     8 |        4 |    57 |
| 15 |     8 |        3 |    93 |

# 练习：
1. 在students表中，查询年龄大于25岁，且为男性的同学的名字和年龄
```
    MariaDB [hellodb]> SELECT name,age FROM students WHERE age>25 AND gender='M';
```
2. 以ClassID为分组依据，显示每组的平均年龄\
```
    MariaDB [hellodb]> SELECT classid,avg(age) FROM students GROUP BY classid;
```
3. 显示第2题中平均年龄大于30的分组及平均年龄
```
    MariaDB [hellodb]> SELECT classid,avg(age) FROM students GROUP BY classid HAVING avg(age)>30;
```
4. 显示以L开头的名字的同学的信息
```
    MariaDB [hellodb]> SELECT * FROM students WHERE name LIKE 'L%';
```
5. 显示TeacherID非空的同学的相关信息
```
    MariaDB [hellodb]> SELECT * FROM students WHERE teacherid IS NOT null;
```
6. 以年龄排序后，显示年龄最大的前10位同学的信息
```
    MariaDB [hellodb]> SELECT * FROM students ORDER BY age DESC LIMIT 10;
```
7. 查询年龄大于等于20岁，小于等于25岁的同学的信息
```
    MariaDB [hellodb]> SELECT * FROM students WHERE age>=20 AND age<=25;
```
8. 以ClassID分组，显示每班的同学的人数
```
    MariaDB [hellodb]> SELECT classid,count(*) FROM students GROUP BY classid;
```
9. 以Gender分组，显示其年龄之和
```
    MariaDB [hellodb]> SELECT gender,sum(age) FROM students GROUP BY gender;
```
10. 以ClassID分组，显示其平均年龄大于25的班级
```
    MariaDB [hellodb]> SELECT classid FROM students GROUP BY classid HAVING avg(age)>25;
```
11. 以Gender分组，显示各组中年龄大于25的学员的年龄之和
```
    MariaDB [hellodb]> SELECT gender,sum(age) FROM students WHERE age>25 GROUP BY gender;
```
12. 显示前5位同学的姓名、课程及成绩
```
    MariaDB [hellodb]> SELECT st.stuid,st.name,co.course,sc.score FROM students AS st INNER JOIN scores AS sc on st.stuid=sc.stuid INNER JOIN courses AS co ON sc.courseid=co.courseid WHERE st.stuid<=5;
```
13. 显示其成绩高于80的同学的名称及课程
```
    MariaDB [hellodb]> SELECT st.name,co.course FROM students AS st INNER JOIN scores AS sc on st.stuid=sc.stuid INNER JOIN courses AS co ON sc.courseid=co.courseid WHERE sc.score>80;
```
14. 取每位同学各门课的平均成绩，显示成绩前三名的同学的姓名和平均成绩
```
    MariaDB [hellodb]> SELECT st.name,avg(sc.score) FROM students AS st INNER JOIN scores AS sc ON st.stuid=sc.stuid INNER JOIN courses AS co ON sc.courseid=co.courseid GROUP BY st.stuid LIMIT 3;
```
15. 显示每门课程课程名称及学习了这门课的同学的个数
```
    MariaDB [hellodb]> SELECT co.course,count(co.course) FROM courses AS co INNER JOIN scores AS sc ON sc.courseid=co.courseid GROUP BY co.course;
```
16. 显示其年龄大于平均年龄的同学的名字
```
    MariaDB [hellodb]> SELECT name,age FROM students WHERE age>(SELECT avg(age) FROM students);
```
17. 显示其学习的课程为第1、2，4或第7门课的同学的名字
```
    MariaDB [hellodb]> SELECT st.name FROM students AS st INNER JOIN scores AS sc ON st.stuid=sc.stuid WHERE sc.courseid=1 OR sc.courseid=2 OR sc.courseid=4 OR sc.courseid=7;
```
18. 显示其成员数最少为3个的班级的同学中年龄大于同班同学平均年龄的同学
```
    
```
19. 统计各班级中年龄大于全校同学平均年龄的同学
```
    MariaDB [hellodb]> select st.name,st.age,cl.class from students AS st INNER JOIN classes AS cl ON st.classid=cl.classid WHERE age>(select avg(age) from students);
```
