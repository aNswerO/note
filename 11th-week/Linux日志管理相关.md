# Linux日志管理：
## 日志：
>日志记录了系统中发生的历史事件，包括事件的时间、地点、人物和事件名称
+ 通常的日志格式：
    ```shell
    date:time host pid: content
    #事件产生的日期时间 主机 进程 ：时间内容
    ```
## 系统日志服务：
+ rsyslog：CentOS-6、CentOS-7
    + rsyslog是一个**daemon**——**守护进程**

    + 兼容syslogd（CentOS—5之前版本记录日志的**守护进程**）的syslog.conf配置文件
    + 多线程工作
    + 具有强大的过滤器，可以实现过滤记录日志信息中的任意部分
    + 可以自定义输出格式
    + 可使用TCP进行消息传输
    + 配置选项灵活，配置文件中支持简单逻辑
    + 有前端web展示程序——kibana

+ rsyslog的程序包和主程序：
    + 程序包：rsyslog
    + 主程序：/usr/sbin/rsyslogd
+ rsyslog的库文件：/usr/lib/systemd/system/rsyslog.service
+ rsyslog的配置文件**/etc/rsyslog.conf**：
    + 配置文件的格式：
        + MODULES：相关模块配置
        + GLOBAL DIRECTIVES：全局配置
        + RULES：日志记录相关的规则配置
            ```
            facility.priority   target
            ```
            + facility：设施
                ```shell
                facility1,facility2,facility3,...
                #指定的facility列表，可以使用“*”代表所有的facility
                ```
                + auth：pam产生的日志

                + authpriv：ssh，ftp等登录信息的验证消息
                + cron：时间任务相关
                + ftp：FTP进程的信息
                + kern：内核相关
                + lpr：打印相关
                + mail：邮件相关
                + mark（syslog）：rsyslog服务内部的信息，时间标识
                + news：新闻组
                + user：用户程序产生的相关信息
                + uucp（unix to unix copy）：unix主机之间相关的通讯
                + local 1~7：自定义的日志设备

            + priority：级别
                ```shell
                priority   #指定priority以上（含）的所有级别
                =priority    #仅记录指定priority的日志信息
                *    #所有级别
                none    #不记录
                ```
                + debug（7）：调试信息

                + info（6）：一般信息（最常用）
                + notice（5）：最具有重要性的普通条件的信息
                + warning（4）：警告
                + err（3）：错误；阻止某个功能或者模块不能正常工作的信息
                + crit（2）：严重；阻止整个系统或整个软件不能正常工作的信息
                + alert（1）：需要立即修改的信息
                + emerg（0）：内核崩溃等严重信息
                + none：什么都不记录
            + target：目标
                + filename：指定绝对路径的日志文件名来记录日志信息

                + :omusrmsg:users：发送信息到指定的用户，users可以指定多个用户，中间用“，”隔开，“*”表示所有用户
                + device：将信息发送到指定设备中
                + |named-pipe：将日志记录到命令管道，使调试日志变得方便
                + @hostname：将信息发送到目标主机（运行着rsyslog，且可识别rsyslog的配置文件），可以指定hostname（前提是可解析）或IP地址；使用**514/udp**端口传送日志
                + @@hostname：将信息发送到目标主机（运行着rsyslog，且可识别rsyslog的配置文件），可以指定hostname（前提是可解析）或IP地址；使用**514/tdp**端口传送日志
## 日志文件：
+ /var/log/secure：系统安装日志；文本格式，应周期性分析

+ /var/log/btmp：当前系统上用户失败登录相关的日志信息；二进制格式，使用**lastb**命令查看
+ /var/log/wtmp：当前系统上用户正常登录相关的日志信息；二进制格式，使用**last**命令查看
+ /var/log/lastlog：每一个用户最近一次的登录信息；二进制格式，使用**lastlog**命令查看
+ /var/log/dmesg：系统引导过程中的日志信息；文本格式，可直接使用文本查看工具查看，也可使用专用命令**dmesg**查看
+ /var/log/messsages：系统中大部分的信息
+ /var/log/anaconda：anaconda的日志
## 日志管理：journalctl
>在CentOS-7中，**systemd**同一管理所有**unit**（service和socket）的启动日志   
可以只用journalctl一个命令查看所有日志（内核日志和应用日志）   
journalctl的配置文件：/etc/systemd/journalctl.conf
+ journalctl用法：
    ```shell
    journalctl
    #查看所有日志（默认情况下，只保存本次启动的日志）

    journalctl -k
    #查看内核日志（不显示应用日志）

    journalctl -b
    journalctl -b -0
    #查看系统本次启动的日志

    journalctl -b -1
    #查看上一次启动的日志（需要更改设置）

    journalctl --since="YYYY-MM-DD hh-mm-ss"
    journalctl --since="XX min ago"
    journalctl --since=yestoday
    journalctl --since="YYYY-MM-DD" --until "YYYY-MM-DD"
    journalctl --since=hh-mm --until "1 hour ago"
    #查看指定时间的日志

    journalctl -n
    #查看尾部最新10行的日志

    journalctl -n X
    #查看尾部最新指定行数的日志

    journalctl -f
    #实时滚动显示最新日志

    journalctl /usr/lib/systemd/system/SERVICE
    #查看指定服务的日志

    journalctl_PID=X
    #查看指定进程的日志

    journalctl /usr/bin/SCRIPT
    #查看指定脚本的日志

    journalctl_UID=X
    #查看指定用户的日志；可以和时间组合使用

    journalctl -u XXX
    #查看指定unit的日志；可以使用多个-u合并显示多个unit的日志

    journalctl -p PRIORITY -b
    #查看指定优先级的日志

    journalctl --no-pager
    #日志默认分页输出，使用--no-pager改为正常的标准输出

    journalctl -OPTIONS -o json
    #以JSON格式（单行）输出

    journalctl -OPTIONS -o json-pretty
    #以JSON格式（多行）输出，可读性更强

    journalctl --disk-usage
    #显示日志占据的磁盘空间

    journalctl --vacuum-size=X
    #指定日志文件占据的最大空间

    journalctl -vacuum-time=X
    #指定日志保存时间
    ``` 
## logrotate日志存储：
>logrotate程序是一个日志文件管理工具  
用来把旧的日志文件删除并创建新的日志文件，这个过程被称为日志转储或滚动  
可根据日志文件的大小或日志文件的天数进行转储，这个过程一般通过cron程序来执行
+ 配置文件：/etc/logrotate.conf
+ 主要参数：
    ```sh
    conpress    #通过gzip压缩转储以后的日志
    nocompress    #不需要压缩时，用这个参数
    copytruncate    #用于还在打开中的日志文件，把当前日志备份并截断
    nocopytruncate    #备份日志文件但是不截断
    create mode owner group    #转储文件；使用指定的文件模式创建新的日志文件
    no create    #不建立新的日志文件
    delaycompress和compress    #一起使用时，转储的日志文件到下一次转储时才压缩
    nodelaycompress    #覆盖delaycompress，转储并压缩
    errors address    #转储时的错误信息发送到指定的Email地址
    ifempty    #即使是空文件也转储；是缺省参数
    notifempty    #如果是空文件，不转储
    mail address    #把转储的日志文件发送到指定Email地址
    nomail    #转储时不发送日志文件
    olddir directory    #转储后的日志文件放入指定的目录，必须和当前的日志文件在同一个文件系统
    noolddir    #转储后的日志文件和当前日志文件放在同一目录下
    prerotate/endscript    #在转储之前需要执行的命令可以放入这个对，这两个关键词必须单独成行
    postrotate/endscript    #在转储之后需要执行的命令可以放入这个对，这两个关键词必须单独成行
    daily    #指定转储周期为每天
    weekly    #指定转储周期为每周
    monthly    #指定转储周期为每月
    size    #大小；指定日志文件超过多大时执行转储
    rotate count    #指定日志文件删除之前转储的次数；0指没有备份，5指保留5个备份
    missingok    #如果日志不存在，提示错误
    nomissingok    #如果日志文件不存在，继续下一次日志，不提示错误
    ```
