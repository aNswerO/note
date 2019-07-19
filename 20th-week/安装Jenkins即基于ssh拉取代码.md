# <h1 id="top">Jenkins（基于Ubuntu 18.04）：</h1>
### <a href="#1">1. 配置Java环境</a>
### <a href="#2">2. 安装Jenkins</a>
### <a href="#3">3. 配置Jenkins权限管理</a>
### <a href="#4">4. 配置Jenkins邮箱</a>
### <a href="#5">5. 新建任务</a>
### <a href="#6">6. 基于ssh key拉取代码</a>

## <h2 id="1">配置Java环境：</h2>
1. 下载并解压jdk：
```
tar xvf jdk-8u192-linux-x64.tar.gz
```
2. 创建软链接：
```
ln -sv /usr/local/src/jdk1.8.0_192/ /usr/local/jdk
ln -sv /usr/local/jdk/bin/java /usr/bin/
```
3. 添加环境变量：
```shell
vim /etc/profile

#添加如下三行
export JAVA_HOME=/usr/local/jdk
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
export CLASSPATH=.$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
```
4. 使环境变量生效：
```
. /etc/profile
```
5. 查看java版本以验证环境变量是否成功添加：
```
java -version
```
## <h2 id="2">安装Jenkins：</h2>
1. 解决依赖关系，先安装daemon：
```
apt install -y daemon
```

2. 安装Jenkins：
```
dpkg -i jenkins_2.164.3_all.deb
```
3. 修改配置文件，做如下修改：
```
vim /etc/default/jenkins

JAVA_ARGS="-Djava.awt.headless=true -server -Xms1g -Xmx1g -Xss512k -Xmn1g \
-XX:CMSInitiatingOccupancyFraction=65 \
-XX:+UseFastAccessorMethods \
-XX:+AggressiveOpts -XX:+UseBiasedLocking \
-XX:+DisableExplicitGC -XX:MaxTenuringThreshold=10 \
-XX:NewSize=2048M -XX:MaxNewSize=2048M -XX:NewRatio=2 \
-XX:PermSize=128m -XX:MaxPermSize=512m -XX:CMSFullGCsBeforeCompaction=5 \
-XX:+ExplicitGCInvokesConcurrent -XX:+UseConcMarkSweepGC -XX:+UseParNewGC \
-XX:+CMSParallelRemarkEnabled -Djava.awt.headless=true \
-Dcom.sun.management.jmxremote \
-Dcom.sun.management.jmxremote.port=12345 \
-Dcom.sun.management.jmxremote.authenticate=false \
-Dcom.sun.management.jmxremote.ssl=false \
-Djava.rmi.server.hostname="192.168.6.111""

JENKINS_USER=root
JENKINS_GROUP=root
```
4. 启动Jenkins：
```
systemctl start jenkins
```
5. 访问web界面并解锁：  
![Demo](pic/Jenkins/解锁.png)  
6. 安装推荐插件：  
![Demo](pic/Jenkins/安装推荐插件.png)  
7. 创建管理员admin
8. 配置Jenkins URL为默认：http://192.168.6.111:8080/
9. 配置完成，登录Jenkins：  
![Demo](pic/Jenkins/登录.png)  
![Demo](pic/Jenkins/界面.png)  
10. 安装插件：  
![Demo](pic/Jenkins/安装插件1.png)  
![Demo](pic/Jenkins/安装插件2.png)  
## <h2 id="3">配置Jenkins权限管理：</h2>
1. 安装插件：  
![Demo](pic/Jenkins/安装插件3.png)  
2. 创建新用户：  
![Demo](pic/Jenkins/新建用户.png)  
3. 更改认证方式：  
![Demo](pic/Jenkins/更改认证方式.png)  
4. 创建角色：  
![Demo](pic/Jenkins/新建角色1.png)  
5. 为角色分配权限：  
![Demo](pic/Jenkins/设置角色权限.png)  
6. 将用户关联至角色：  
![Demo](pic/Jenkins/关联.png)  
7. 普通用户登录测试（没有管理选项）：  
![Demo](pic/Jenkins/普通用户登录.png)  
## <h2 id="4">配置Jenkins邮箱：</h2>
1. 生成qq邮箱登录授权码：
![Demo](pic/Jenkins/生成授权码.png)  
2. 配置管理员邮箱：  
![Demo](pic/Jenkins/设置邮箱1.png)  
![Demo](pic/Jenkins/设置邮箱2.png)  
3. 设置邮件通知：  
![Demo](pic/Jenkins/设置邮件通知.png)  
4. 发送测试邮件并验收：  
![Demo](pic/Jenkins/测试邮件.png)  
## <h2 id="5">新建任务：</h2>  
+ 新建任务：  
![Demo](pic/Jenkins/新建任务.png)  
+ 构建环境中启用此项：  
![Demo](pic/Jenkins/删除workspace.png)  


## <h2 id="6">基于ssh key拉取代码：</h2>
+ gitlab服务器：
1. 添加ssh key：  
![Demo](pic/Jenkins/gitlab添加公钥.png)  
2. 在Jenkins服务器上测试ssh拉取代码：  
![Demo](pic/Jenkins/测试命令行ssh拉取代码.png) 
+ Jenkins服务器：
1. 在Jenkins服务器上生成ssh密钥对：
```
ssh-keygen
```
2. 添加凭据：  
![Demo](pic/Jenkins/添加凭据1.png)  
![Demo](pic/Jenkins/添加凭据2.png)  
3. 查看生成的凭据：  
![Demo](pic/Jenkins/生成凭据.png)  
4. 在创建好的项目中设置git项目的地址和用户，然后保存：  
![Demo](pic/Jenkins/添加git仓库.png)  
5. 验证构建结果：  
![Demo](pic/Jenkins/查看控制台.png)  
![Demo](pic/Jenkins/查看控制台输出.png)  
## <a href="#top">回到顶部</a>