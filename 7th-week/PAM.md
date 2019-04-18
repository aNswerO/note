# PAM（插入式认证模块）：
+ 在Linux中进行身份或状态认证是由PAM进行的

+ PAM可动态加载验证**模块**，能按需动态地对验证的内容进行变更，从而提高验证的灵活性
## PAM认证原理：
+ PAM认证遵循的顺序：service --> PAM配置文件 --> pam_*.so

+ PAM认证要先确定是哪一个服务，然后加载/etc/pam.d/下与服务对应的配置文件，最后调用/lib64/security/下的认证文件进行认证
## PAM相关文件：
+ 模块文件的目录：/lib64/security/
+ 环境相关的设置：/etc/security/
+ 主配置文件：/etc/pam.conf(CentOS 6之后没有此文件；且当/etc/pam.d/存在时，此文件失效)
## PAM的配置文件：
+ 存放PAM配置文件的目录：/etc/pam.d/

+ 修改PAM配置文件将立即生效，所以编辑PAM规则时保持至少有打开一个root会话，以防止身份认证错误
+ PAM配置文件的格式：
    + 分为四列：
        1. type：模块类型
            + Auth：账号的认证和授权

            + Account：与账号管理相关的非认证类功能；如用来限制用户对某个服务的访问时间、当前有效的系统资源（最多可以有多少个用户）、限制用户登陆的位置
            + Password：用户修改密码时密码复杂度检查机制等功能
            + Session：用户获取到服务之前或服务完成之后需要进行的一些附加操作；如：记录打开/关闭数据的信息，监视目录等
            + -type：表示因为确实而不能加载的模块将不记录到系统日志，对于那些不总是安装在系统上的模块有用

        2. control：PAM库如何处理调用与该服务相关的PAM模块时成功或失败的情况
            + 简单方法实现（使用一个关键词）：
                + required：一票否决；表示本模块必须返回成功才能通过认证，如果该模块返回失败，失败结果也不会立即通知用户，而是等到同一type中所有模块全部执行完毕再将失败结果返回给应用程序；是一个必要条件

                + requisite：一票否决；与**required**类似，但在该模块返回失败时，将不再执行同一type中的任何模块，而是直接将控制权返回给应用程序；是一个必要条件
                + sufficient：一票通过；表示该模块返回成功时则通过身份认证，不必再执行同一type中的其他模块；若该模块返回失败时则忽略，是一个充分条件
                + optional：表示该模块是可选的，它的成功与否并不对身份认证起关键性作用，其返回值一般被忽略
                + include：调用其他的配置文件中定义的配置信息
            + 复杂详细方法实现（使用一个或多个"status=action"）：
                + status：检查结果的返回值

                + action：采取行为
                    + ok：模块通过，继续检查
                    + done：模块通过，返回最终结果给应用
                    + bad：结果失败，继续检查
                    + die：结果失败，返回失败结果给应用 
                    + ignore：结果忽略，不影响最后结果
                    + reset：忽略已经得到的结果
        3. module-path：用来指本模块对应的程序文件的路径
            + 绝对路径

            + 相对路径：/lib64/security/目录下的模块可以使用相对路径，如pam_shell.so
            + 模块通过读取配置文件（/etc/serurity/*.conf）完成用户对系统资源的使用控制
            + 
        4. arguments：传递给该模块的参数
# PAM模块示例：
+ 模块：pam_shells

    + 功能：检查有效shell
    + 示例：不允许使用/bin/csh的用户本地登录
        ```shell
        vim /etc/pam.d/login
            auth required pam_shells.so

        vim /etc/shells
            #删除/bin/csh
        ```
+ 模块：pam_securetty.so
    + 功能：只允许root用户在/etc/securetty文件中列出的终端登录
    + 示例：允许root用户在telnet登录  
        1. 第一种方法：
        ```shell
        vim /etc/pam.d/remote
        #将auth required pam_securetty.so这行注释掉
        ```
        2. 第二种方法：在/etc/securetty文件中加入pts/0,pts/1...
        