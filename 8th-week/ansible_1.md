# Ansible：EPEL源
>ansible通过ssh实现、应用部署、任务执行等功能
## 特性：
+ 模块化：

    + 调用特定模块执行特定任务
    + 支持自定义模块
+ 基于python实现
+ 部署简单：
    + python、SSH皆为默认安装
    + 无需在受控端安装代理软件
+ 安全：基于Openssl
+ 支持**playbook**编排任务
+ 幂等性：任务的执行结果与执行次数无关，不会因重复执行引发意外状况
+ 无需代理不依赖PKI（无需ssl）
+ 可使用任何编程语言写模块
+ YAML格式，支持丰富的数据结构
+ 较强大的多层解决方案
## 主要组成部分：
+ playbook：任务列表；由一个或多个ansible命令组成的列表
    + 功能：play的主要功能在于将预定义的一组主机，装扮成事先通过ansible中的task定义好的角色。Task实际是调用ansible的一个module，将多个play组织在一个playbook中，即可以让它们联合起来，按事先编排的机制执行预定义的动作

    + 格式：通常为JSON格式的YML文件
    + 使用：由ansible顺序依次执行定义playbook的配置文件
+ inventory：ansible管理主机的清单
    + 配置文件：/etc/ansible/hosts
+ modules：ansible执行命令的功能模块
    + 内置核心模块
    + 也可自定义模块
+ plugins：模块功能的补充
+ API：供第三方程序调用的应用程序编程接口
+ ansible：ansible命令的核心执行工具
## ansible命令的执行来源：
+ user：普通用户
+ CMDB（配置管理数据库）API调用
+ PUBLIC/PRIVATE CLOUD API调用
## 利用ansible实现管理的方式：
+ ansible命令：用于使用临时命令的场景
+ ansible-playbook：主要用于提前规划好的、大型项目的场景
## 剧本的执行过程：
1. 将已编排好的任务集写入ansible-playbook
2. 通过ansible-playbook命令将任务机拆分成逐条ansible命令，在按预定的规则逐条执行
## ansible主要操作对象：
+ **hosts**：主机
    + 执行ansible的主机一般称为主控机、中控、master或堡垒机
    + 被控制的主机一般称为受控端
+ **NETWORKING**：网络设备
## 注意事项：
+ 主控端的python版本需要2.6或以上
+ 受控端python版本小于2.4时需要安装python-simplejson
+ 被控端如开启SELinux需要安装libselinux-python
+ Windows不能作为主控端
## 相关文件：
+ 配置文件：
    + 主配置文件：/etc/ansible/ansible.cfg；配置ansible的工作特性
    + 主机清单：/etc/ansible/hosts
    + 存放角色的目录：/etc/ansible/roles；存放角色的目录
+ 程序：
    + 主程序：/usr/bin/ansible主程序，临时命令的执行工具
    + /usr/bin/ansible-doc：查看配置文档；模块功能查看工具
    + /usr/bin/ansible-galaxy：下载/上传优秀代码或**roles**模块的官网平台
    + /udt/bin/ansible-playbook：编排剧本的工具
    + /ust/bin/ansible-vault：文件加密工具
    + /usr/bin/ansiable-pull：远程执行命令的工具
    + /usr/bin/ansible/console：基于**console**界面与用户交互的执行工具
## inventory（主机清单）相关：
+ 可在主机清单文件中将主机分组并命名来便携使用其中的部分主机
+ 默认的主机清单文件为/etc/ansible/hosts
+ 主机文件可以有多个，且可以通过dynmatic inventory来动态生成
+ 文件格式：
    + 遵循INI格式
    + 可将同一个主机归并到多个不同的组中
    + 中括号中的字符为组名
    + 若目标主机使用了非默认的SSH端口，还可以在主机名称之后使用冒号加端口号来标明
    ```
        [websrvs]
        www.baidu.com:1234
    ```
    + 若主机名称遵循相似的命名模式，还可以使用列表的方式来表示主机
    ```
        [websvrs]
        www.baidu[1..10].com
    ```
## 配置文件相关：
```shell
    [defaults]
    inventory=/etc/ansible/hosts    #主机列表配置文件
    library=/usr/share/my_modules    #库文件存放目录
    remote_tmp=$HOME/.ansible/tmp    #临时py命令文件存放在远程主机的哪个目录
    local_tmp=$HOME/.ansible/tmp    #本机的临时命令执行目录
    forks=5    #默认并发数
    sudo_user=root    #默认以root身份控制远程主机
    ask_sudo_pass=True    #每次执行ansible命令是否询问密码
    ask_pass=Ture    #使用ansible连接远程主机时是否询问登录密码
    remote_port=22    #默认端口
    host_key_checking=False   #检查对应服务器的key，基于密钥登录时建议取消此行注释
    log_path=/var/log/ansible    #日志文件路径
    module_name=command    #默认模块
```
