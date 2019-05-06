# 查询缓存：
## 查询缓存的原理：
>将SELECT操作或预处理查询的结果集和SQL语句缓存下来，当有新的SELECT语句或预处理查询语句请求时，先去查询缓存，判断是否存在可用的记录集  
判断标准：与缓存的SQL语句是否完全一致（区分大小写）
## 优缺点：
+ 优点：在语法解析通过后，不需要对SQL语句做解析和执行，直接从**Query Cache**（查询缓存）中获取查询结果，可以提高查询性能
+ 缺点：
    + 查询缓存的判断规则不够智能，降低了效率
    + 使用查询缓存会增加检查和清理**Query Cache**中记录集的开销，降低了性能
## 可能不会被缓存的查询：
+ 查询语句中加了SQL_NO_CACHE参数

+ 查询语句中含有获得值的函数，包含自定义函数；如：NOW()、CURDATE()、GET_LOCK、RAND、CONVERT_TZ()
+ 对系统数据库的查询：查询语句中使用SESSION级别变量或存储过程中的局部变量
+ 查询语句中使用了LOCK IN SHARE MODE、FOR UPDATE的语句，查询语句中类似SELECT ...INTO导出数据的语句
+ 对表的临时查询操作；存在警告信息的查询语句；不涉及任何表或视图的查询语句；某用户只有列级别权限的查询语句
+ 事务隔离级别为Serializabled时，所有查询语句都不能缓存
## 查询缓存相关的服务器变量：
+ query_cache_min_res_unit：查询缓存中内存块的最小分配单位，默认4K，设置得较小可减少浪费，但会导致更频繁的内存分配操作；设置得较大会造成空间的浪费，还会导致碎片过多，内存不足

+ query_cache_limit：单个查询结果能缓存的最大值，默认为1M；对于查询结果过大而无法缓存的语句，建议使用SQL_NO_CACHE（查询结果不被缓存）
+ query_cache_size：查询缓存总共可用的内存空间；单位字节，必须是1024的整数倍，最小值为40KB，低于此值有警报
+ query_cache_wlock_invalidate：如果某表被其他的会话锁定，是否仍然可以从查询缓存中返回结果，默认值为OFF，表示可以在表被其他会话锁定的场景中继续从缓存返回数据；ON则表示不允许
+ query_cache_type：是否开启缓存功能，取值为ON，OFF，DEMAND
## SELECT语句的缓存控制：
+ SQL_CACHE：显式指定存储查询结果于缓存中
+ SQL_NO_CACHE：查询结果不会被缓存
## query_cache_type参数变量：
+ 值为0或OFF：查询缓存功能关闭

+ 值为1或ON：查询缓存功能启用，SELECT的结果符合缓存条件则会缓存；否则不予缓存
+ 值为2或DEMAND：查询缓存功能按需使用，显式指定SQL_CACHE的SELEC语句才会缓存；其余不予缓存
## 查询缓存相关的的状态变量：
+ 查看：
```
    SHOW GLOBAL STATUS LIKE 'Qcache%'
```
+ Qcache_free_blocks：处于空闲状态Qcache Cache中的内存block数

+ Qcache_total_blocks：Qcache Cache中的总block，当Qcache_free_blocks相对此值较大时，可能会有内存碎片，可以执行FLUSH_QUERY_CACHE清理碎片
+ Qcache_free_memory：处于空闲状态的Query_Cache内存总量
+ Qcache_hits：Qcache Cache命中次数
+ Qcache_inserts：向Qcache Cache中插入新的Qcache Cache的次数，即未命中的次数
+ Qcache_lowmem_prunes：记录因为内存不足而被移除出查询缓存的查询数
+ Qcache_not_cached：没有被Cache的SQL数，包括无法被Cache的SQL以及由于query_cache_type设置的不会被Cache的SQL语句
+ Qcache_queries_in_cache：在Qcache Cache中的SQL数量
## 命中率和内存使用率估算：
+ 查询缓存中内存块的最小分配单位：query_cache_min_res_unit
>(query_cache_size - Qcache_free_memory)/ Qcache_queries_in_cache
+ 查询缓存命中率：
>：Qcache_hits/(Qcache_hits + Qcache_inserts)*100%
+ 查询缓存内存使用率：
>(query_cache_size – qcache_free_memory)/query_cache_size *100%

# 索引：
>索引是特殊的数据结构，通过存储引擎实现，定义了在查找时作为查找条件的字段
## 优缺点：
+ 优点：
    + 索引可以降低服务需要扫描的数据量，减少了I/O次数
    + 索引可以帮助服务避免排序和使用临时表
    + 索引可以帮助将随机I/O转化为顺序I/O
+ 缺点：
    + 占用了额外的空间，影响插入速度
## 索引类型：
+ B+ TREE、HASH、R TREE
+ 聚簇索引、非聚簇索引
+ 主键索引、二级索引
+ 稠密索引、稀疏索引
+ 简单索引、复合索引
### B+ TREE索引：
+ 顺序索引：
    + 每一个叶子节点与根节点的距离都相同

    + 左前缀索引，适合查询范围类的数据
+ 可使用B+ TREE索引的查询类型
    + 全值匹配：精确指定所有索引列；如姓：FIRST_NAME，名：LAST_NAME...

    + 匹配最左前缀：即只使用索引的第一列；如姓：FIRST_NAME
    + 匹配列前缀：即只匹配一列值的开头部分；如姓为x开头的
    + 匹配范围值：如姓x和姓z之间
    + 精确匹配某一列并范围匹配另一列；如姓x，名为c开头的
    + 只访问索引的查询
+ B+ TREE的限制：
    + 若不是从最左列开始，则无法使用索引；如查找姓为y结尾，名为z的

    + 不能跳过索引中的列；如查找姓x，年龄20的，只能使用索引的第一列
+ 注意：
    + 索引列的顺序应和查询语句的写法相匹配，才能更好的使用索引
    
    + 为优化性能，可能要针对相同的列但顺序不同这种情况创建不同的索引，来满足不同类型的查询请求
### Hash索引：
+ 特点：
    + 基于哈希表实现，只有精确匹配索引中的所有列的查询请求才有效

    + 索引自身只存储索引列对应的哈希值和数据指针
    + 索引结构紧凑，查询性能好
+ 适用场景：只支持等值比较查询
+ 不适用Hash索引的场景：
    + 不适用与顺序查询：索引存储的顺序不是值的顺序

    + 不支持模糊匹配
    + 不支持范围查询
    + 不支持部分索引列匹配查找；如A列、B列索引，只查询A索引无效
### 全文索引：
>在文本中查找关键字，而不是直接比较索引中的值；类似于搜索引擎
### 聚簇索引：
+ 特点：
    + 聚簇索引规定了数据在表中的物理存储顺序

    + 因为在聚簇索引下，数据在物理上按顺序排在数据页上，所以重复值也会排在相邻的位置，所以在进行范围查找时避免了大范围扫描，提高了查询效率
    + 一个表只能包含一个聚蔟索引，但该索引可以包含多个列
+ 使用场景：
    + 经常要查找范围值的列
## 管理索引：
+ 创建索引：
```
    CREATE INDEX [UNIQUE] index_name ON table_name (index_col_name[length],...);

    ALTER TABLE table_name ADD INDEX index_name(index_col_name);
```

+ 删除索引：
```
    DROP INDEX index_name ON table_name;

    ALTER TABLE table_name DROP INDEX index_name(index_col_name);
```
+ 查看索引：
```
    SHOW INDEXES FROM [db_name.]table_name;
```
+ 优化表空间：
```
    OPTIMIZE TABLE table_anme;
```
+ 查看索引的使用：
```
    SET GLOBAL userstat=1;
    SHOW INDEX_STATISTICS;
```
+ 分析索引的有效性：EXPLAIN
```shell
    EXPLAIN SELECT clause
    #获取查询执行计划信息，用来查询优化器如何执行查询
```
+ select_type：
    + 简单查询：SIMPLE

    + 复杂查询：
        + SUBQUERY：简单子查询
        + PRIMARY：最外面的SELECT
        + DERIVED：用于FROM中的子查询
        + UNION：UNION语句的第一个之后的SELECT语句
        + UNION RESULT：临时匿名表
+ type：关联类型或访问类型，即MySQL决定的如何取查询表中的行的方式；以下类型的顺序，由性能从低到高排序
    + ALL：全表查询

    + index：根据索引的次序进行全表扫描；若在Extra列中出现“Using index”表示使用覆盖索引，而非全表扫描
        + Extra：额外信息
            + Using index：MySQL将会使用覆盖索引，以避免访问表
            + Using where：MySQL服务器将在存储引擎检索后，再进行一次过滤
            + Using temporary：MySQL对结果排序时会使用临时表
            + Using filesort：对结果使用一个外部索引排序
    + range：有范围限制的根据索引实现范围扫描；扫描位置始于索引中的某一点，结束于另一点
    + ref：根据索引返回表中匹配某单个值的所有行
    + eq_ref：仅返回一个行，但与需要额外与某个参考值作比较
    + const，system：直接返回单个行
## 索引的优化策略：
+ 独立地使用列，尽量避免其参与运算；独立的列指索引既不能是表达式的一部分，也不能是函数的参数

+ 左前缀索引：构建指定索引字段的左侧的字符数，通过索引选择性来评估
    + 索引选择性：不重复的索引值和数据表的记录总数的比值
+ 多列索引：AND操作时更适合使用多列索引，而非对每个列创建单独的索引
+ 选择合适的索引列顺序：在无排序和分组时，将选择性最高的放在左侧
+ 若列中含有NULL值，最好不要在此列设置索引；符合索引若有NULL值，此列在使用时也不会使用索引
+ 尽量使用短索引，最好指定一个索引前缀长度
+ 对于经常在where子句中使用的列，最好设置索引
+ 对于多个列where或order by子句，应该建立复合索引
+ 对于like语句，以"%"或"-"开头的不会使用索引；以"%"结尾的会使用索引
+ 尽量不在列上进行运算（函数操作和表达式操作）
+ 尽量不使用not in和<>操作
## SQL语句性能优化：
+ 查询时尽量写全字段名，不适用"*"

+ 大部分情况连接效率远大于子查询
+ 多表连接时尽量用小表驱动大表，即小表 join 大表
+ 在有大量记录的表分页时使用limit
+ 对于经常使用的查询语句，可以开启缓存
+ 多使用explain和profile分析查找语句
+ 查看慢查询日志，找出执行时间长的SQL语句进行优化