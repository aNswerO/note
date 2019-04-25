# ping模块：
+ 功能：测试与指定受控主机们之间是否可以正常连接
+ 使用：
```
  ansible srvs -m ping 
```  
![avagar]()
# copy模块：
+ 功能：将主控机的指定文件发送到受控端
+ 使用：
```
  ansible srvs -m copy -a "ARGS"
```  
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
  ansible srvs -m file -a ""
```
