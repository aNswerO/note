# ping模块：
+ 功能：测试与指定受控主机们之间是否可以正常连接
+ 使用：
```
  ansible srvs -m ping 
```  
![avagar]()
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
![avagar]()  
![avagar]()
+ 当不指定src时，可以使用content指定内容，在受控主机指定路径创建文件
```
  ansible srvs -m copy -a "content=COMMENT dest=/PATH/TO/FILE"
```
![avagar]()
![avagar]()
# fetch模块：
+ 功能：主控从受控端拉取文件
+ 使用：
```
  ansible srvs -m fetch -a "src=/PATH/TO/FILE dest=/PATH/TO/DIR"
```
![avagar]()  
![avagar]()
# file模块：
+ 功能：完成基本的文件操作
+ 使用：
```
  ansible srvs -m file -a "ARGS"
```
