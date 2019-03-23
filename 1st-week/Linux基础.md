# 冯诺依曼体系结构
+ 计算机由5部分组成：运算器、存储器、控制器、输入设备、输出设备
# 操作系统的功能
1. 管理硬件资源
2. 提供运行应用软件的平台
3. 为应用程序开发人员提供环境使应用程序具有更好的兼容性
# 用户空间和内核空间
+ 用户空间（user space）：用户程序运行的空间，只进行简单运算，不能直接调用系统资源。只有通过系统调用（system call）才能向内核发出指令。
+ 内核空间（kernel space）：为Linux内核的运行空间，可执行一切命令，调用一切系统资源
# 系统调用
# Linux哲学思想
+ 一切皆文件
+ 小型、单一用途的程序
+ 连接程序，使其完成复杂任务
+ 避免令人困惑的界面
+ 配置储存在文本中
# Linux用户
+ root用户：uid为0，拥有系统管理的最高权限
+ 普通用户：uid非0
# 终端
+ 虚拟终端（/dev/tty#）：tty
+ 串行终端（/dev/ttyS#）：ttyS
+ 伪终端（/dev/pty/#）：pts
# 内部命令和外部命令
+ 内部命令：shell自带，且通过某种命令形式提供
	help：显示内部命令列表
	enable COMMAND：启用内部命令
	enable -n COMMAND：禁用内部命令
	enable -a：显示所有启用和禁用的内部命令
	enable -n：显示所有禁用的内部命令
+ 外部命令：在文件系统路径下有对应的可执行程序文件
	whereis：查看外部命令路径
# hash缓存表
+ 系统初始时hash缓存表是空的，当执行外部命令看时到PATH里寻找该命令后并将其执行次数和绝对路径缓存在hash缓存表中，再次执行时到hash中取，可以加快执行速度
	hash：显示缓存
	hash -r：清除缓存
# 命令别名
+ 在命令行定义的别名仅对当前shell进程有效，注销后失效
+ 永久生效需要在配置文件中定义：
	~/.bashrc：对当前用户有效
	/etc/bashrc：对所有用户有效
+ alias：显示当前shell可用的所有命令别名
+ alias NAME=‘COMMAND’：为COMMAND命令设置别名，alias相当于执行COMMAND命令
+ unalias：撤销命令别名
+ unalias -a：撤销所有别名
# 命令格式
+ COMMAND [-OPTIONS...] [-ARGUMENTS...]
	OPTIONS：用于开启或关闭命令的某个功能
		短选项
		长选项
	ARGUMENTS：命令的作用对象
+ 注意：
	1. 多个选项和多个参数之间用空白字符分分隔
	2. CTRL+c、CTRL+d：取消、结束命令
	3. 多个命令一起执行时可用；分隔
	4. 一个长度过长的命令可用/分成多行
# 日期和时间
+ Linux的两种时钟
	1. 系统时钟：由内核通过CPU频率进行计算
	2. 硬件时钟：存储在主板上CMOS的时钟
# 有关时间的命令
+ date：显示和设置系统时间
	date +%s：从1970.1.1到当前时间所经历的秒数
	date +%F：以YYYY-MM-DD格式显示当前时间
+ hwclock、clock：显示硬件时钟
	-s、--hctosys：以硬件时钟为准，修改系统时钟
	-w、--systohc：以系统时间为准，修改硬件时钟
+ cal：日历
	-y：显示全年的日历
	cal YYYY：显示YYYY年的日历
# 有关网络的命令
+ nmcli connection：查看网络设备状况
+ nmcli connection up/down DEV：启用/禁用指定设备
# 关机与重启
+ 关机：shutdown、halt、poweroff、init 0
	shutdown [OPTIONS...] [TIME] [WALL...]
		OPTIONS:
			-r：reboot  重启
			-h：halt    关机
			-c：cancle  取消
		TIME：
			now：立刻
			+m：相对时间，即m分钟后执行
			hh:mm：绝对时间，即在hh:mm时执行
+ 重启：reboot、init6
>关机前使用**who**命令查看是否还有其他用户在线
>在Linux系统中，为了提高运行效率，文件及数据处理不会立即写入磁盘，而是放入buff（内存缓冲区），之后在适当的时间写入磁盘，所以关机前使用**sync**命令进行同步可以防止数据丢失
# 用户登录信息查看命令
+ whoami：查看当前登录用户
+ who：显示当前连接的所有用户和使用终端
+ w：显示当前连接的用户、终端、登陆时间、运行程序及占用CPU
# screen命令
+ 在远程登录主机时，可以将需要长时间执行的任务剥离，即可后台执行任务，避免因与远程主机意外断开连接导致用户失去对任务的控制；还可实现会话共享
1. screen -S [SESSION]：创建新会话
	ctrl+a d：剥离当前会话
	exit：退出当前会话
2. screen -ls：显示所有已经打开的会话
3. screen -x [SESSION]：加入指定会话
4. screen -r [SESSION]：恢复指定会话
# echo命令
+ echo会将指定的字符串输出到标准输出，输出的字符串间会用空格隔开，并在末尾加上换行符

+ 选项：
  + -E：不支持\解释功能（默认此选项开启）
  + -n：不自动换行
  + -e：启用\解释功能

+ 显示变量：

  ```
  [root@CenrOS_7 ~]#echo "echo $PS1"
  echo [\t\e[1;32m][\u@\h \W]$[\e[0m]  弱引用
  [root@CenrOS_7 ~]#echo ‘echo PS1’
  echo PS1   强引用
  [root@CenrOS_7 ~]#echo `echo $PS1`
  [\t\e[1;32m][\u@\h \W]$[\e[0m]
  命令引用，``中的内容会被当做命令执行，执行结果作为echo命令的参数
  [root@CenrOS_7 ~]#echo ${SHELL}
  /bin/bash   显示当前使用shell
  ```

+ 括号扩展{ }：
	+ eg：

  ```
  [root@CenrOS_7 ~]#echo a{1,4,7}
  a1 a4 a7
  ```
# 有关环境变量
+ 系统默认的环境变量都使用大写字母，可以使用echo $环境变量名称 的方法查看此环境变量的值；而要改变环境变量的值，可以使用以下两种方法：
	1. 使用export命令将值写入配置文件~/.bash_profile，再重读配置文件，永久生效
	```
	[root@CenrOS_7 ~]#echo "VAR=NUM" >> ~/.bash_profile
	[root@CenrOS_7 ~]#source ~/.bash_profile
	[root@CenrOS_7 ~]#. ~/.bash_profile
	```
	2. 在命令行界面使用export命令方式设置环境变量，重启或注销后失效
	```
	[root@CenrOS_7 ~]#export VAR=NUM
	```
# bash常用快捷键
+ ctrl+l：清屏
+ ctrl+c：终止命令
+ ctrl+z：挂起命令
+ ctrl+a：光标移动至行首
+ ctrl+e：光标移动至行尾
+ ctrl+u：从光标处删除内容至行首
+ ctrl+k：从光标处删除内容至行尾
+ alt+r：删除当前命令行整行
+ ctrl+w：从光标处向左删除至**单词**首
+ alt+d：从光标处向右删除至**单词**尾
+ ctrl+d：删除**光标处**的一个字符
+ ctrl+h：删除**光标前**的一个字符
# 其他
+ cat /proc/meminfo：查看内存情况
+ cat /proc/partion：查看分区情况
