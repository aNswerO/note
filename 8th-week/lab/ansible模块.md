# ping模块：
+ 功能：测试与指定受控主机们之间是否可以正常连接
+ 使用：
```
  ansible srvs -m ping 
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/ping%E6%A8%A1%E5%9D%97.png)
# copy模块：
+ 功能：将主控机的指定文件发送到受控端
+ 基本使用方法：
```
  ansible srvs -m copy -a "ARGS"
```
+ 参数：
  + src：指定源文件路径
  + dest：指定拷贝到哪个路径
  + content：不指定src时，使用content指定内容，在受控主机指定路径创建文件
  + force：当远程主机存在与src同名且内容不同的文件时，是否覆盖。yes--覆盖；no--不覆盖
  + backup：当远程主机存在与src同名且内容不同的文件时，是否那个同名文件进行备份，之后再进行覆盖。yes--备份；no--不备份
  + owner：指定文件拷贝之后的属主，前提是受控主机必须要有那个用户
  + group：指定文件拷贝之后的属组，前提是受控主机必须要有那个组
  + mode：指定文件拷贝之后的权限
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/copy%E6%A8%A1%E5%9D%97_1.png)  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/copy%E6%A8%A1%E5%9D%97_2.png)
+ 当不指定src时，可以使用content指定内容，在受控主机指定路径创建文件
```
  ansible srvs -m copy -a "content=COMMENT dest=/PATH/TO/FILE"
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/copy%E6%A8%A1%E5%9D%97_3.png)
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/copy%E6%A8%A1%E5%9D%97_4.png)
# fetch模块：
+ 功能：主控从受控端拉取文件
+ 使用：
```
  ansible srvs -m fetch -a "src=/PATH/TO/FILE dest=/PATH/TO/DIR"
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/fetch%E6%A8%A1%E5%9D%97_1.png)  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/fetch%E6%A8%A1%E5%9D%97_2.png)
# file模块：
+ 功能：完成基本的文件操作
+ 使用：
```
  ansible srvs -m file -a "ARGS"
```
+ 参数：
    + path：必需参数；用于指定操作的文件或目录

    + state：创建文件时，指定文件的类型
        + link：软链接
        + hard：硬链接
        + directory：目录
        + touch：普通文件
    + src：当state为link或hard时，src指定链接的源文件
    + force：当state为link时，可使用force=yes强制创建
    + owner：指定被操作文件的属主
    + group：指定被操作文件的属组
    + mode：指定被操作文件的权限
    + recurse：当被操作文件是目录时，使用recurse=yes递归操作目录下的文件  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/file%E6%A8%A1%E5%9D%97_1.png)  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/file%E6%A8%A1%E5%9D%97_2.png)
# shell模块：
+ 功能：与command相似；使用shell,可以执行稍复杂的命令
+ 使用：
```
    ansible dbsrvs -m shell -a "COMMAND"
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/shell%E6%A8%A1%E5%9D%97.png)
# script模块：
+ 功能：在远程主机上执行主控的脚本
+ 使用：
```
    ansible srvs -m script -a "/PATH/TO/SCRIPT"
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/script%E6%A8%A1%E5%9D%97.png)
# hostname模块：
+ 功能：管理主机名
+ 使用：
```
    ansible srvs -m hostname -a "name=NAME"
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/hostname%E6%A8%A1%E5%9D%97_1.png)  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/hostnamename%E6%A8%A1%E5%9D%97_2.png)
# user模块：
+ 功能：管理用户
+ 使用：
```
    ansible srv -m user -a "ARGS"
```
+ 常用参数：
    + name="NAME"：指定用户名
    + comment="COMMENT"：添加注释
    + uid="NUM"：指定UID
    + group="GROUP"：指定属组
    + home="/PATH/TO/HOME_DIR"：指定家目录路径
    + system=yes：创建系统用户
    + state=absent：删除用户  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/user%E6%A8%A1%E5%9D%97_1.png)  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/user%E6%A8%A1%E5%9D%97_2.png)
# group模块：
+ 功能：管理组
+ 使用：
```
    ansible srv -m group -a "ARGS"
```
+ 常用参数：
    + name：指定组名
    + system=yes：创建系统组
    + gid：指定GID
    + state=absent：删除组  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/group%E6%A8%A1%E5%9D%97_1.png)  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/group%E6%A8%A1%E5%9D%97_2.png)
