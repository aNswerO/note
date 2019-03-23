# I/O设备
## Linux系统中打开的文件都有一个fd（文件标识符）
+ 文件位于/proc/PID/fd/下，其中的0、1、2代表标准输入、标准输出、标准错误。
+ 可以使用pidof PROCESSNAME命令查询指定进程的pid
## Linux为程序提供了三种I/O设备：
+ 标准输入（STDIN）：-0 默认为接受键盘输入
+ 标准输出（STDOUT）：-1 默认为输出到终端
+ 标准错误（STDERR）：-2 默认为输出到终端
# 重定向
## STDOUT和STDERR可以被重定向至文件
```
命令 操作符号 文件名
```
+ \>：把STDOUT重定向至文件，文件原有内容会被覆盖
    + 合并多个程序的STDOUT：
    ```
        (COMMAND;COMMAND) > FILE.OUT
    ```
+ \>>：把STDOUT重定向至文件，但在文件原有内容后追加
+ 2>：把STDERR重定向至文件
+ 2>>：把STDERR重定向至文件，但在文件原有内容后追加
+ 合并STDOUT和STDERR重定向至文件：
    + &>：把STDERR和STDOUT一起重定向至文件，文件原有内容会被覆盖

    + &>>：把STDERR和STDOUT一起重定向至文件，但在文件原有内容后追加

    + COMMAND > FILE.OUT 2&>1：将STDOUT覆盖重定向至FILE.OUT，并将STDERR转化为STDERR，结果为STDOUT和STDERR一同被覆盖重定向至FILE.OUT

    + COMMAND >> FILE.OUT 2&>1：将STDOUT追加重定向至FILE.OUT，并将STDERR转化为STDERR，结果为STDOUT和STDERR一同被追加重定向至FILE.OUT

    + set -C：禁止覆盖重定向

    + set+C：解除禁止覆盖重定向

    + \> |：强制覆盖重定向
+ 标准输出和错误输出分别重定向到不同文件中：
```
    COMMAND > /PATH/TO/FILE.OUT 2> /PATH/TO/FILE.ERROR
```
+ 重定向标准输入:
```
    COMMAND < FILE.IN
```
+ eg：
```
    cat < file1 > file2
```
>将file1中的内容覆盖重定向至file2
```
    cat < file1 >> file1
```
>将file1的内容追加重定向至file1，如果不停止该命令会一直执行下去
+ 多行输入重定向：
```
<<EOF
LINE1
LINE2
...
EOF
```
# tr命令
## 转换或删除字符的处理工具
```shell
    tr [OTPION]...SET1 [SET2]
```
+ -c -C --completment：取字符集的补集
+ -d --delete：删除所有属于SET1中的字符
+ -s --squeeze-repeats：把所有连续重复的字符转换一个指定的单独的字符
+ -t --trucate-set1：将SET1中的字符对应转换为SET2中的字符
+ 特殊字符集：
    + [:alnum:]：字母和数字 
    + [:alpha:]：字母 
    + [:cntrl:]：控制（非打印）字符
    + [:digit:]：数字 
    + [:graph:]：图形字符 
    + [:lower:]：小写字母 
    + [:print:]：可打印字符
    + [:punct:]：标点符号 
    + [:space:]：空白字符 
    + [:upper:]：大写字母
    + [:xdigit:]：十六进制字符
+ eg：
```
    tr 'a-z' 'A-Z'
```
>将待处理文本中的小写字母转换为大写字母
```
tr -d PATTERN
```
>将待处理文本中的PATTERN中的任意字母删除
# 管道
>使用管道命令可以将多个命令连接到一起，将 | 前面的命令的执行结果输出到 | 后面的命令，作为它的输入，可以实现多种工具组合以完成复杂任务
+ STDERR默认不能通过管道转发，但可以通过&>或2>&1实现
+ 管道中最后一个进程是当前shell下的子进程，而其他命令是该子进程的子进程
+ eg：
```
    ls | tr 'a-z' 'A-Z'
```
>此命令将ls的输出结果发送给tr命令，从而实现将显示出的当前目录下的文件名由小写转为大写的功能
## 重定向到多个目标
```
    COMMAND1 | tee [-a] FILE | COMMAND2
```
>将命令1的STDOUT输出到FILE中，再作为COMMAND2的输入
+ 功能：
    + 可同时查看和记录输出
    + 保存不同阶段的输出
    + 复杂管道的故障排除
