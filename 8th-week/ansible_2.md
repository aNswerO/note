# ansible系列命令
## ansible：
+ 语法：
```shell
    ansible <HOST-PATTERN> [-m MODULE_NAME] [-a ARGS...]

    #HOST-PATTERN：匹配主机的列表
    #-m MODULE：指定模块；默认为command
    #-a ARGS：指定参数
```
+ host-pattern：
    + ALL：表示所有主机列表中的主机
    + *：通配符，表示任意数量的任意字符
    + 或关系：
    ```
        ansible "IP1:IP2" -m MOUDLE
        ansible "GROUP1:GROUP2" -m MOUDLE
    ```
    + 与关系：
    ```shell
        ansibile "GROUP1:&GROUP2" -m MOUDLE
        #引号中内容表示既在GROUP1中又在GROUP2中的主机
    ```
    + 逻辑非：
    ```shell
        ansibile "GROUP1:!GROUP2" -m MOUDLE
        #引号中内容表示在GROUP1中但不在GROUP2中的主机
    ```
    >可以使用组合逻辑，也支持使用正则表达式，在主机范围前使用“~”来使用正则表达式
+ 常用选项：
    + --version：显示版本信息
    + -v：显示过程（-vv、-vvv显示更详细的信息）
    + --list[-hosts]：显示主机列表
    + -k：提示输入ssh连接密码；默认使用可以认证
    + -K：提示输入sudo时的口令
    + -C：检查语法错误，不执行
    + -T：执行命令到的超时时长，默认为10s
    + -u：执行远程执行命令的用户身份
    + --become-user=USERNMAE：指定sudo的runas用户，默认为root
+ 示例：
```shell
    ansible all -m ping -u qyh -k    #以qyh用户执行ping命令对所有主机清单列表中所有主机进行存活检测，需要输入密码
    ansible all -m ping -u qyh -k -b    #以qyh身份sudo至root对主机清单列表中的所有主机执行ping存活检测
    ansible all -m -u qyyh -k -b --become-user=bin    #以qyh身份sudo至bin对主机清单列表中的所有主机执行ping存活检测需要输入密码
```
## ansible常用模块：
+ command：在远程主机执行命令，默认模块
    + 示例：
    ```
        ansible all -m command -a "server network start"
    ```
    >此命令不支持$引用变量值、<、>、|、；、&等，这些可以使用shell模块实现
+ shell：和command相似，但用shell执行命令
    + 示例：
    ```
        ansible all -m shell -a "echo qyhqyh | passwd --stdin qyh"
    ```
    >调用bash执行命令，但过于复杂的命令仍可能会失败  
    解决办法：将复杂命令写到脚本中cp到远程执行，再把需要的结果拉回执行命令的机器
+ script：在远程主机上运行ansible服务器上的脚本
    + 示例：
    ```
        ansible all -m script -a /data/1.sh
    ```
+ copy：从主控端复制文件到远程主机
    + 示例：
    ```shell
        ansible all -m copy -a "src=/PATH/TO/SRC_FILE dest=/PATH/TO/DST_FILE owner =qyh mode=600 backup=yes"
        #若目标存在，默认覆盖，此处指定先备份

        ansible all -m copy -a "content='test' dest=/PATH/TO/DEST_FILE"
        #指定内容，直接生成目标文件
    ```
+ fetch：与copy相反，从远程主机提取文件至主控端；对目录执行时可先tar
    + 示例：
    ```shell
        ansible all -m fetch -a 'src=/PATH/TO/SRC_FILE dest=/PATH/TO/DST_FILE'
    ```
+ file：设置文件属性
    + 示例：
    ```shell
        ansible all -m file -a "path=/PATH/TO/FILE owner=qyh mode=700"

        ansible all -m file -a 'src=/PATH/TO/FILE dest=/PATH/TO/LINK_FILE state=link'
    ```
+ hostname：管理主机名
    + 示例：
    ```
        ansible IP -m hostname -a "name=websrv"
    ```
+ cron：计划任务
    + 示例：
    ```shell
        ansible all -m cron -a "minute=*/5 job='/usr/sbin/ntpdate 172.22.0.1 &> ' name=synctime"
        #创建一个每五分钟从时间服务器上同步时间的计划任务
        ansible all -m cron -a "state=absent name=synctime"
    ```
+ yum：管理包
    + 示例：
    ```shell
        ansible all -m yum -a "name=httpd state=present"    #安装
        ansible all -m yum -a "name=httpd state=absent"     #删除
        ```
+ service：管理服务
    + 示例：
    ```shell
        ansible all -m service -a 'name=httpd state=started enabled=yes'    #启动服务并设定为开机自启

        ansible all -m service -a 'name=httpd state=stopped'    #关闭服务

        ansible all -m service -a 'name=httpd state=reloaded'    #重载服务

        ansible all -m service -a 'name=httpd state=restarted'    #重启服务
    ```
+ user：管理用户
    + 示例：
    ```shell
        ansible all -m user -a 'name=user comment="test" uid=2222 home=/PATH/TO/DIR group=root'    #新建用户并设置用户属性

        ansible all -m user -a "name=sysuser system=yes home=/PATH/TO/DIR"    #新建系统用户并指定家目录位置

        ansible all -m user -a "name=user state=absent remove=yes"    #删除用户同时删除其家目录
    ```
+ group：管理组
    + 示例：
    ```shell
        ansible all -m group -a "name=testgroup system=yes"    #新建系统组
        ansible all -m group -a "name=testgroup state=absent"    #删除系统组
    ```
## ansible命令执行相关：
+ 执行过程：
    1. 加载自己的配置文件，默认为/etc/ansible/ansible.conf

    2. 加载自己对应的模块文件，默认为command
    3. 通过ansible将模块或命令生成对应的临时py文件，并将此文件传输至远程主机对应执行用户的$HOME/.ansible/tmp/下
    4. 给文件+x权限
    5. 执行并返回结果
    6. 删除临时py.文件,sleep 0退出
+ 执行状态：
    + 绿色：执行成功并且不需要做改变的操作
    + 黄色：执行成功并且对目标主机做出了变更
    + 红色：执行失败
+ ansible-doc：显示模块帮助
    + 语法：
    ```shell
        ansible-doc [options] [module...]
    ```
    + 常用选项：
        + -a：显示所有模块的文档
        + -l：列出可用模块
        + -s：显示指定模块的playbook片段
    + 示例：
    ```shell
        ansible-doc MODULE   #显示指定模块的帮助文档
        ansible-doc -s MODULE   #查看指定模块的简要帮助
    ```
# ansible-galaxy命令：
+ 连接(https://galaxy.ansible.com)下载相应的roles
```shell
    ansible-galaxy list    #列出所有已安装的galaxy
    ansible-galaxy install geerlingguy.redis  #安装galaxy
    ansible-galaxy remove geerlingguy.redis    #删除galaxy
```
# ansible-playbook命令：
##YAML：
>是一个可读性高的用来表达资料序列的格式
+ 特性：
    + 可读性好
    + 和脚本语言的交互性好
    + 使用实现语言的数据类型
    + 由一个一致的信息模型
    + 易于实现
    + 可基于流来实现
    + 表达能力强，扩展性好
+ 语法：
    + 在单一文档中使用“---”区分多个档案，并使用“...”用来结束档案
    + 次行开始playbook的内容
    + 使用“#”进行注释
    + 缩进必须统一，空格与tab不能混用
    + 同样的缩进代表同样的缩进级别
    + 区分大小写
    + 一个完整的代码块功能最少元素包括**name**和**task**
    + 一个**name**只能包括一个**task**
+ YAML中常使用的数据结构类型：
    + list：列表
    >其所有**元素**均使用“-”打头

    + dictionary：字典
    >通常由多个key与value构成；  
    可将字典中的键值对置于{}中，每一对用“，”分隔
## playbook中的核心元素：
+ hosts：执行命令的远程主机列表

    + playbook中的每一个play的目的都是为了让特定主机以某个指定的用户身份执行任务。hosts用于指定要执行指定任务的主机，须事先定义在主机清单中

    + remote_users：可用于**hosts**和**task**中。也可以通过指定其通过sudo的方式在远程主机上执行任务，其可用于play全局或某任务；此外，甚至可以在sudo时使用sudo_user指定sudo时切换的用户
+ tasks：任务集；playbook的主体部分
    + task list中的各任务按次序逐个在hosts中指定的所有主机上执行，即在所有主机上完成第一个任务后，再开始第二个任务

    + task的目的是使用指定的参数执行模块，而在模块参数中可以使用变量。模块执行是幂等的，这意味着多次执行是安全的，因为其结果均一致
    + 每个task都应该有其name，用于playbook的执行结果输出，建议其内容能清晰地描述任务执行步骤。如果未提供name，则action的结果将用于输出
    + 若命令或脚本的退出状态码不为0，可使用以下方式替代：
    ```
    tasks:
      - name:ignore the result
        shell:/PATH/TO/COMMAND || /bin/ture

    tasks:
      - name:ignore the result
        shell:/PATH/TO/COMMAND
        ignore_errors:True
    ```
+ variables：内置变量或自定义变量在playbook中调用
+ templates：模板，可替换模板文件中的变量实现一些简单逻辑的文件
+ handlers和notify：组合使用；由特定条件触发，满足条件执行
+ tags：标签；指定某条任务执行，用于选择运行playbook中的部分代码。ansible具有幂等性，因此会自动跳过没有变化的部分，即便如此，有些代码为测试其确实没有发生变化的时间依然会非常地长。此时，如果确信其没有变化，就可以通过tags跳过此些代码片断
## 运行playbook的方式：
+ 语法：
```
    ansible-playbook <FILE_NAME.yml> ...[options]
```
+ 常用选项：
    -C：只检测可能会发生的改变，但不真正执行操作
    --list-hosts：列出运行任务的主机
    --list-tags：列出tags
    --list-tasks：列出tasks
    --limit INVENTORY：只针对主机列表中的主机执行
## playbook中变量使用：
+ 变量名：仅能由字母、数字、下划线组成，且只能用字母开头

+ 变量来源：
    + ansible setup facts：远程主机的所有变量都可以直接调用

    + 在/etc/ansible/hosts中定义：
        + 公共变量：针对主机组中所有主机定义的同一变量
        + 普通变量：主机组中为主机单独定义；优先级高于公共变量
    + ansible-playbook -e：通过命令行指定变量，优先级最高
    + 在playbook中定义：
        ```
        vars:
          - var1:value1
          - var2:value2
        ```
    + 在单独的变量YAML文件中定义,用下面方法YAML文件中使用：
        ```
            vars_files:
              -vars.yml
        ```
    + 在role中定义
+ 变量调用方式：
    + 通过{{ variable_name }}调用，且变量名前后必须有空格，

    + ansible-playbook -e 选项指定
        ```
        ansible-playbook test.yml -e "hosts=www user=qyh"
        ```
## template：模板
+ 嵌套有脚本的文本文件（使用编程语言编写）

+  Jinja2语言，使用字面量，有以下形式：
    + 字符串：使用单引号或双引号
    + 数字：整数和浮点数
    + 列表：[item1,item2]
    + 元祖：（item1,item2）
    + 字典：{key1:value1,key2:value2...}
    + 布尔型：true/false
+ 算术运算：+, -, *, /, //, %, **
+ 比较运算：==, !=, >, >=, <, <=
+ 逻辑运算：and、or、not
+ 流表达式：for、if、when
+ 功能：根据模块文件动态生成对应的配置文件
>template文件必须存放于template目录下，且为.j2结尾  
yaml文件需和template目录平级
+ 流表达式：
    + when：条件测试
        + 使用方法：在task后添加when子句即可；when语句支持Jinja表达式语法
        + 示例：
        ```
        tasks:
          - name:"shutdown RedHat flavored system"
            command:/usr/sbin/shutdown -h now
            when:ansible_os_family == "RedHat"
        ```
    + for：
    ```
        {% for i in LIST %}
        ...
        {% endfor %}
    ```
    + if:
    ```
        {% if CONDITION %}
        ...
        {% endif %}
    ```
+ 迭代：with_items；当有需要重复性执行的任务时，可以使用迭代机制
    + 对迭代项的引用，变量名固定为“item”
    + 在task中使用with_items给定要迭代的元素列表
    + 列表格式：
        + 字符串
        + 字典
