# systemd
>CentOS 7开始使用的系统启动和服务器守护进程管理器，代替了init；它负责在系统启动和运行时，激活系统资源、服务器进程和其他进程
## systemd的特性：
+ 较之init的新特性：

    1. 系统引导时实现服务并行启动
    2. 按需启动守护进程
    3. 自动化的服务依赖关系管理
    4. 同时采用socket式与D-Bus总线式激活服务
    5. 系统状态快照
+ 关键特性：

    + 基于socket的激活机制：socket与服务程序分离
    
    + 基于D-Bus的激活机制：D-BUS的协议是低延迟而且低开销的，设计得小且高效，以便最小化传送时间；从设计上避免往返交互并允许异步操作。
    + 基于device的激活机制：能监控内核输出的硬件信息，当设备插入时一旦发现就创建设备文件，再自动挂载至某挂载点，若挂载点不存在还能自动创建
    + 基于path的激活机制：系统可监控某目录或文件是否存在，如果文件存在，立即就能激活一个服务或进程；若某服务运行中忽然崩溃，此时会生成一个log或lock文件，一旦发现这个文件立即激活一个程序，例如发送报告
    + 系统快照：能将当前unit的状态信息保存到持久存储设备中；由于systemd的所有管理都是通过unit实现的，所以可在回滚时使用
    + 向后兼容SysV、init脚本：所以位于/etc/init.d/下的服务脚本一样能通过systemd启动
+ systemd的缺点：

    + systemctl的命令时固定不变的，无法自定义

    + 不是由systemd启动的服务，systemd无法与之通信，无法控制此服务
## 管理服务的命令上，CentOS 6和7对应的关系：
```shell
    systemctl CMD NAME.service
```
| |CentOS 6| CentOS 7|
|--|--|--|
| 启动|service NAME start|systemctl start NAME|
|停止|service NAME stop|systemctl stop NAME|
|重启|service NAME restart|systemctl restart NAME|
|状态|service NAME status|systemctl status NAME|
|条件是式启动|service NAME condrestart|systemctl condrestart NAME|
|重载或重启服务||systemctl reload-or-restart NAME|
|重载或条件式重启服务||systemctl reload-or-try-restart NAME|
|禁止自动和手动启动||systemctl mask NAME|
|取消禁止||systemctl unmask NAME|
|查看某服务当前激活与否||systemctl is-active NAME|
|查看所有已激活的服务||systemctl list-units --type\|-t service|
|查看所有服务||systemctl list-units --type service --all\|-a|
## chkconfig命令的对应关系
||CentOS 6|CentOS 7|
|--|--|--|
|设定某服务开机自启|chkconfig NAME on|systemctl enable NAME|
|设定某服务禁止开机自启|chkconfig NAME off|systemctl disable NAME|
|查看所有服务的开机自启状态|chkconfig --list|systemctl list-unit-files --type service|
|列出该服务在哪些运行级别下启用和禁用|chkconfig sshd --list|ls /etc/systemd/system/*.wants/sshd.service|
|查看服务是否开机自启||systemctl is-enable NAME|
|查看服务的依赖关系||systemctl list-depencies NAME|
# 核心概念：unit
>unit表示不同类型的systemd对象，通过配置文件进行标识和配置；文件中主要包括了系统服务、监听socket、保存的系统快照以及其他与init相关的信息
+ 配置文件：
    + /usr/lib/systemd/system/：每个服务最主要的启动脚本设置，类似于之前版本的/etc/init.d/ （发行版打包者使用）

    + /run/systemd/system/：系统运行过程中所产生的服务脚本，比上面目录先运行
    + /etc/systemd/system/：管理员创建的执行脚本，类似于/etc/rc#.d/S#功能，比上面的目录先运行（系统管理员和用户使用）
## unit类型：
+ systemctl -t help：查看unit类型

    + service unit：文件扩展名为.service，用于定义系统服务

    + target unit：文件扩展名为.target，用于模拟实现运行级别
    + device unit：文件扩展名为.device，用于定义内核识别的设备
    + mount unit：文件扩展名为.mount，用于定义系统挂载点
    + socket unit：文件扩展名为.socket，用于标识进程间通信使用的socket文件，也可以在系统启动时延时启动服务，实现按需启动
    + snapshot unit：文件扩展名为.snapshot，管理系统快照
    + swap unit：文件扩展名为.swap，用于标识swap设备
    + automount unit：文件扩展名为.automount，文件系统的自动挂载点
    + path unit：文件扩展名为.path，用于定义文件系统中的一个文件或目录使用；常用于文件系统变化时延时激活服务
## 服务的状态：
+ 显示状态
```shell
    systemctl list-unit-files --type service --all
```
|||
|-|-|
|loaded|unit配置文件已处理|
|active（running）|一次或多次持续处理的进行|
|active（exited）|成功完成一次性的配置|
|active（waiting）|运行中，等待一个事件|
|inactive|不运行|
|enable|开机启动|
|disable|开机不自启|
|static|开机不启动，但可被另一个启用的服务激活|
## systemctl命令示例：
```shell
    systemctl|systemctl list-units #显示所有单元状态

    systemctl --type=service #只显示服务单元的状态

    systemctl -l status sshd.service #显示sshd服务单元

    systemctl is-active sshd #验证sshd服务当前是否处于活动状态

    systemctl reload sshd #重新加载配置

    systemctl list-units-files --type=service #查看服务单元的启用与禁用状态

    systemctl --failed -type=service #列出失败的服务
```
## service unit文件格式：
+ 以#开头的行后面被认为是注释

+ 相关布尔值：1、yes、on、ture表示开启；0、no、off、false
+ 默认时间单位是**s**，要使用**ms**和**m**时需要显式说明
+ service unit file文件的组成部分：
    + [Unit]：定义与unit类型无关的通用选项；用于提供unit的描述信息、unit行为及依赖关系
    + [Service]：与特定类型相关的专用选项；此处为service类型
    + [Install]：定义由“systemctl enable|disable”命令在实现服务启动或禁用时用到的一些选项
### Unit段常用选项：

+ Description：描述信息

+ After：定义unit的启动次序，表示当前unit应晚于哪些unit启动；其功能与before相反
+ Requires：依赖到的其他units，强依赖；被依赖到的unit无法启动时，此unit也无法启动
+ Wants：依赖到其他units，弱依赖
+ Conflicts：定义units间的冲突关系
### Service段常用选项：

+ Type：定义影响ExecStart及相关参数的功能的unit进程启动类型

+ simple：默认值，这个daemon主要由ExecStart接的指令串来启动，启动后常驻于内存中
+ forking：由ExecStart启动的程序透过spawns延伸出其他子程序来作为此daemon的主要服务。原生父程序在启动结束后就会终止
+ oneshot：与simple类似，不过这个程序在工作完毕后就结束了，不会常驻在内存中
+ dbus：与simple类似，但这个daemon必须要在取得一个D-Bus的名称后，才会继续运作.因此通常也要同时设定BusNname= 才行
+ notify：在启动完成后会发送一个通知消息。还需要配合 NotifyAccess 来让 Systemd 接收消息
+ idle：与simple类似，要执行这个daemon必须要所有的工作都顺利执行完毕后才会执行。这类的daemon通常是开机到最后才执行即可的服务 
+ EnvironmentFile：环境配置文件
+ ExecStart：指明启动unit要运行命令或脚本的绝对路径
+ ExecStartPre： ExecStart前运行
+ ExecStartPost： ExecStart后运行
+ ExecStop：指明停止unit要运行的命令或脚本
+ Restart：当设定Restart=1 时，则当次daemon服务意外终止后，会再次自动启动此服务
### Install段常用选项：
+ Alias：别名，可使用systemctl command Ailas.service

+ RequriedBy：被哪些units依赖，强依赖
+ WAantedBy：被哪些units所依赖，弱依赖
+ Also：安装本服务的时候还要安装别的相关服务
>对于新创建的或修改了的unit文件，要通知systemctl重载此配置文件，而后可以选择重启
## 运行级别
+ 对应关系：
```
    0   runlevel0.target    poweroff.target
    1   runlevel1.terget    rescue.target
    2   runlevel2.terget    mutli-user.target
    3   runlevel3.terget    mutli-user.target
    4   runlevel4.terget    mutli-user.target
    5   runlevel5.terget    graphical.target
    6   runlevel6.terget    reboot.target
```
+ 查看运行级别：
```shell
    runlevel
    who -r
    systemctl list-units --type target
```

+ 查看运行级别：
```
    systemctl get-default
```
+ 修改默认运行级别：
```
    systemctl set-default NAME.target
```
+ 级别切换：
>只有/lib/systemd/system/*.target文件中AllowIsolate=yes，才能切换（修改文件后需执行systemctl daemon-reload才能使改动生效）
```shell
    systemctl isolate *.target
```
