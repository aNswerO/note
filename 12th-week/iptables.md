# 基本认识： 
+ Netfilter组件：
    + 集成在内核中

    + 在内核中选取5个位置放了5个**hook function**（钩子函数）：
        + PREROUTING
        + INPUT
        + FORWARD
        + OUTPUT
        + POSTROUTING
    + **hook function**向用户开放，用户可以通过**iptables**命令工具向其写入规则
    + 由**table**（信息过滤表）组成，包含控制IP包处理的**rules**（规则集），**rules**被分组放在**chain**（链上）

+ 三种报文流向：
    + 流入本机：PREROUTING --> INPUT --> 用户空间进程

    + 流出本机：用户空间进程 --> OUTPUT --> POSTROUTING
    + 转发：PREROUTING --> FORWARD --> POSTROUTING
+ 防火墙工具：iptables
    + 命令行工具，工作在用户空间

    + 用来编写规则，写好的规则被送往**Netfilter**，由**Netfilter**告诉内核如何去处理包
# iptables的组成：
+ table（表）：
    + filter：过滤规则表，根据预定义的规则去过滤符合条件的数据包

    + nat（network address translation）：地址转换规则表
    + mangle：修改数据标记位规则表
    + raw：关闭nat表上启用的连接跟踪机制，加快封包穿越防火墙速度
    + security：用于强制访问控制网络规则，由Linux安全模块（如SELinux）实现

+ chain（链）：每个内置chain对应一个hook function
    + 内置chain：
        + PREROUTING

        + INPUT
        + FORWARD
        + OUTPUT
        + POSTROUTING
    + 自定义chain：用于对内置chain进行扩展或补充，可实现更灵活的rule组织管理机制；只有在hook function调用自定义chain时，才生效
+ rule（规则)：根据规则的匹配条件尝试匹配报文，对匹配成功的报文根据规则定义的处理动作做出处理
    >rule要加在chain上才能生效；添加在自定义chain上的rule不会自动生效，需要先在内置chain上做引用
    + 匹配条件：默认为**与**条件；同时满足
        + 基本匹配：IP、port，TCP的标志位（SYN、ACK）等

        + 扩展匹配：通过复杂高级功能匹配
    + 处理动作：
        + 内建处理动作：ACCEPT、DROP、REJECT、SNAT、DNATMASQUERADE、MARK、LOG...
        + 自定义处理动作：自定义**chain**，利用分类管理复杂情形
    + 添加rule时的考量点：
        + 要实现那种功能：判断添加在哪个table上

        + 报文流经的路径：判断添加在哪个chain上
        + 报文的流向：判断源和目的
        + 匹配规则：根据业务需要制定
# 内核中数据包的传输过程：  
+ 当一个数据包进入网卡时，数据包会首先到达**PREROUTING**链，内核根据数据包的目的IP判断是进入本机还是转发

    + 若数据包是进入本机的，数据包就会到达**INPUT**链，当其到达**INPUT**链后，任何进程都会收到它，本机运行的程序可以发送数据包，这些数据包经过**OUTPUT**链，然后到达**POSTROUTING**链传出

    + 若数据包是要转发出去的，且内核开启了转发功能，数据包就会经过**FORWARD**链，然后到达**POSTROUTING**链传出  
![avagar](https://github.com/aNswerO/note/blob/master/12th-week/pic/iptables/iptables%E8%A1%A8%E9%93%BE.png)  
# iptables命令：
+ 规则（rule）格式：
    ```
    iptables [-t TABLE] SUBCOMMAND chain [-m matchname [per-match-options]] -j targetname [per-target-options]
    ```
    + -t TABLE：
        + filter：默认
        + nat
        + mangle
        + raw

    + SUBCOMMAND：
        + 链管理：
            + -N：new；自定义一条新的链

            + -X：delete；删除自定义的空的链（若被某条内置链引用，还要先解除引用才能删除）
            + -P：policy；设置默认策略，对filter表中的链而言，其默认策略有
                + ACCEPT：接受
                + DROP：丢弃
            + -E：重命名自定义链；引用计数不为零的自定义链不能够被重命名，也不能被删除
        + 查看：
            + -L：list；列出指定链上的所有规则，本选项需置后

            + -n：numberic；以数字格式显示地址和端口号
            + -v：verbose；详细信息，使用-vv显示更详细的信息
            + -x：exactly；显示计数器结果的精确值，而非单位转换后的易读值
            + --line-numbers：显示规则的序列号
            + -S：selected；以iptables-save命令格式显示链上的规则
            >常用组合:  
            -vnL  
            -vvnxL --line-numbers
        + 规则管理：
            + -A：append，追加

            + -I：insert；插入，需要指定插入到的规则编号，默认为第一条
            + -D：delete；删除，两种指定方式
                + 指明规则序号
                + 指明规则本身
            + -R：replace；替换指定链上的指定规则编号
            + -F：flush；清空指定的规则链
            + -Z：zero；将计数器置零，每条规则都有两个计数器
                + 匹配到的报文的个数
                + 匹配到的所有报文的大小之和
    + chain：PREROUTING，INPUT，FORWARD，OUTPUT，POSTROUTING
    + 匹配条件：
        + 基本匹配条件：无需加载模块，由iptables/netfilter自行提供
            + -s，--source address：源IP地址或范围

            + -d，--destination address：目标IP地址或范围
            + -p，--protocol：指定协议，可使用all（全部）
            + -i，--in-interface：报文流入的接口；只能应用于数据报文流入的环节，即只应用于INPUT、FORWARD、PREROUTING链
            + -o，--out-interface：报文流出的接口；只能应用于数据报文流出的环节，即只应用于OUTPUT、FORWARD、POSTROUTING链
        + 扩展匹配条件：需要加载扩展模块（/usr/lib64/xtables/*.so）才能生效
            + 隐式扩展：在使用-p选项指明了特定的协议时，无需再使用-m选项指明扩展模块的扩展机制，也不需要手动加载扩展模块
                + tcp协议的扩展选项：
                    ```sh
                    --sport PORT[:PORT]    #匹配报文源端口，可为端口范围
                    --dport PORT[:PORT]    #匹配报文目标端口，可为端口范围
                    --tcp-flags MASK COMP    #MASK为需检查的标志位列表，用逗号分隔；COMP为在MASK列表中必须为1的标志位列表，无指定则必须为0，用逗号分隔
                    ```
            + 显式扩展：必须使用-m选项指定要调用的扩展模块的扩展机制，需要手动加载扩展模块
                ```
                [-m matchname [per-match-options]]
                ```
                + multiport扩展：
                    ```sh
                    #以离散方式定义多端口匹配，最多指定15个端口
                    --sports PORT,PORT|PORT:PORT    #指定多个源端口
                    --dports PORT,PORT|PORT:PORT    #指定多个目标端口
                    ```
                + iprange扩展：
                    ```sh
                    #指明连续的ip地址范围
                    --src-range IP1-IP2    #指定源IP地址范围
                    --drc-range IP1-IP2    #指定目标IP地址范围
                    ```
                + mac扩展：
                    ```sh
                    --mac-source XX:XX:XX:XX:XX:XX    #指明源mac地址
                    ```
                + string扩展：
                    ```sh
                    #对报文中的应用层数据做字符串模式匹配检测
                    --algo {bm|kmp}    #字符串匹配
                    --from offset    #开始偏移
                    --to offset    #结束偏移
                    --string pattern    #要检测的字符串模式
                    --hex-string pattern    #要检测的字符串模式（16进制格式）
                    ```
                + time扩展（由于CentOS系统默认时间时UTC时间，所以使用time扩展时应使用UTC时间）：
                    ```sh
                    #根据将报文到达的时间与指定的时间范围进行匹配
                    --datestart YYYY[-MM[-DD[Thh[:mm[:ss]]]]]
                    --datestop YYYY[-MM[-DD[Thh[:mm[:ss]]]]]
                    #日期和时间

                    --timestart hh:mm[:ss]
                    --timestop hh:mm[:ss]
                    #时间

                    --mouthdays day[,day...]
                    #每个月的几号

                    --weekdays day[,day...]
                    #星期几
                    ```
                + connlimit扩展：
                    ```sh
                    #根据没客户端的IP做并发连接数数量匹配；通常分别于默认拒绝和允许策略配合使用
                    --connlimit-upto    #连接的数量小于等于指定数时匹配

                    --connlimit-above    #连接的数量大于指定数时匹配
                    ```
                + limit扩展：
                    ```sh
                    #基于收发报文的速率做匹配（令牌桶过滤器）
                    --limit NUM[/second|/minute|/hour|/day]
                    #每秒/分钟/小时/天生成几个“令牌”

                    --limit-burst NUM
                    #在单位时间内（由--limit指定）最多可以存放多少个“令牌”；limit触发事件的阈值
                    ```
                + state扩展：
                    >根据“conntrack（连接追踪）机制”去检查连接的状态，较耗资源  
                    CentOS-7需要加载模块：nf_conntrack_ipv4
 
                    + conntrack机制：追踪本机上请求和响应之间的关系
                        + 有如下几种状态：
                        ```sh
                        NEW    #新发出的请求；连接追踪信息库中不存在此连接的相关信息条目，因此将其识别为第一次发出的请求

                        ESTABLISHED    #NEW状态之后，连接追踪信息库中为其建立的条目失效之前期间内所进行的通信状态

                        RELATED    #新发起的但与已有连接向关联的连接；如ftp协议中数据连接和命令连接之间的关系

                        INVALID    #无效的连接；如flag标记不正确

                        UNTRACKED    #未进行追踪的连接；如raw表中关闭追踪
                        ```
                    + 已经追踪到的并记录下来的连接信息库：
                        + /proc/sys/net/nf_conntrack
                    + 调整连接追踪功能所能容纳的最大连接数：
                        + /proc/sys/net/nf_conntrack_max
                    + 不同的协议的连接追踪时长：
                        + /proc/sys/net/netfilter/
        + 处理动作：
            ```
            -j targetname [per-target-options]
            ```
            + 简单动作：ACCEPT、DROP

            + 扩展动作：
                + REJECT：--reject-with:icmp-port-unreachable；默认

                + RETURN：返回调用链
                + REDIRECT：端口重定向
                + LOG：记录日志；非中断处理动作，本身不拒绝或允许，应放在拒绝和允许的**rule**之前
                    + --log-level：级别

                    + --log-prefix：日志前缀；用以区别不同日志
                + MARK：做防火墙标记
                + DANT：目标地址转换
                + SNAT：源地址转换
                + MASQUERADE：地址伪装
+ 规则优化：
>规则在链上的次序即为检查时的生效次序
1. 安全放行所有入站和出站的状态为ESTABLISHED的连接

2. 谨慎放行入站的新请求
3. 有特殊目的限制访问功能，要在放行规则之前加以拒绝
4. 同类规则（访问同一应用），匹配范围小的放在前面用于特殊处理
5. 不同类的规则（访问不同应用），匹配范围大的放在前面
6. 应该将那些可由一条规则能够描述的多个规则合并为一条
7. 设置默认策略，建议使用白名单方式（只放行特定连接）
    + iptables -P（不建议）
    + 建议在规则的最后定义一个拒绝规则作为默认策略
+ 规则的有效期限：
    + 使用iptables命令定义的规则，手动删除之前，其生效期限为kernel存活期限
+ 将rule保存至指定文件：
    + CentOS-6：
        ```sh
        service iptables save
        #将规则覆盖保存至/etc/sysconfig/iptables文件中
        ```
    + CentOS-7：
        ```
        iptables-save > /PATH/TO/SOME_RULES_FILE
        ```
+ 重新载入预存规则文件中的规则：
    + CentOS-6：
        ```sh
        service iptables restart
        #自动从/etc/sysconfig/iptables载入规则
        ```
    + CentOS-7：
        ```sh
        iptables-restore < /PATH/FROM/SOME_RULES_FILE
            #-n，--noflush：不清除原有规则
            #-t，--test：仅分析生成规则集，但不提交
        ```
    
# 网络防火墙：
1. 充当防火墙的主机还需要充当网关

2. 只能使用filter表中的FORWARD链
>注意：  
（1）请求-响应报文均会经由FORWARD链，要注意规则的方向性  
（2）若要启用conntrack机制，建议将双方向的状态为ESTABLISHED的报文直接放行
+ 网络地址转换：
    + NAT：
        + 请求报文：修改源/目标IP，由定义修改
        + 响应报文：修改源/目标IP，根据conntrack机制自动实现
    + SNAT：
        >让本地网络中的主机通过某一特定地址访问外部网络，实现地址伪装
        + 在经过POSTROUTING链时修改源IP
    + DNAT：
        >把本地网络中的主机上的某服务开放给外部网络访问，但隐藏真实IP（发布服务和端口映射）
        + 在经过PREROUTING链时修改目标IP
    + PNAT：
        >将端口和IP都进行修改
