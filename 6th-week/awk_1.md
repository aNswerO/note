# awk语法：
```shell
    awk [OPTIONS] 'PROGRAM' VAR=VALUE FILE...

    awk [OPTIONS] -f programfile VAR=VALUE FILE...

    awk [OPTIONS] 'BEGIN{action;...}pattern{action;...}END{action;...}' FILE...
```
+ pattern和action：
    + pattern部分决定动作语句何时触发及触发事件
        + BEGIN、END
    + action statements对数据进行处理，放在{}中指明
        + print、printf
+ print格式：print item1，item2...
    1. 逗号分隔符
    2. 输出item可以是字符串，也可以是数值；当前记录的字段、变量或awk的表达式
    3. 若省略item，则相当于print $0
+ 格式化输出printf：
```shell
    printf "FORMAT",item1,item2,...

    1. 必须指定FORMAT
    2. 不会自动换行，需要显示给出换行符\n
    3. FORMAT中需要分别为后面每个item指定格式符

    格式符：与items一一对应
        %c：显示字符的ASCII码
        %d，%i：显示十进制整数
        %e，%E：显示科学计数法数值
        %f：显示浮点数
        %g，%G：以科学计数法或浮点形式显示数值
        %s：显示字符串
        %u：无符号整数
        %%：显示%自身

    修饰符：
        .：%#[.#]f，第一个数字控制显示的宽度，第二个数字表示小数点后的精度
        -：%-#s，左对齐；默认为右对齐
        +：%+d，显示数值的正负符号
```
## awk组成：
+ BEGIN语句块

+ 能使用模式匹配的通用语句块
+ END语句块
+ program通常被放在单引号中
## awk选项：
+ -F “分隔符”

+ -v var=value：赋值变量
## awk中的几个概念：
+ 分隔符：awk执行时，由分隔符分隔的字段标记（如$1,$2...）称为域标识；$0为所有域

    >此时$和shell中的变量$符含义不同
+ 域（字段）：被分隔符分隔的字段被称为域
+ 记录：默认情况下，文件的每一行被称为一条记录
+ 省略action时，默认执行print $0的操作
# awk的工作过程：
1. 执行BEGIN{action;...}语句块中的语句
    >BEGIN语句块在awk开始从输入流中读取行之前被执行；这是一个可选的语句块，比如变量初始化、打印输出表格的表头等语句通常可以写在BEGIN语句中

2. 从文件或标准输入中读入一行，然后执行pattern{action;...}语句块；它逐行扫描文件，从第一行到最后一行重复此过程，直到文件全部被读取完毕
    >pattern语句块中的通用命令是最重要的部分，也是可选的；若没有提供pattern语句块，则默认执行{print}，即打印每一个读取到的行，awk读取的每一行都会执行该语句块
3. 当读入输入流末尾时，执行END{action;...}语句块
    >END语句块在awk从输入流中读完所有行之后被执行，比如打印所有行的分析结果这类信息汇总都是在END语句块中完成的，它也是一个可选语句块
# awk示例：
```shell
    awk '{print}' /etc/passwd #打印出/etc/passwd的每一行

    awk '{print "hah"}' /etc/passwd #/etc/passwd有多少行，就打印多少行hah

    awk -F: '{print $1}' /etc/passwd #以冒号为分隔符，打印出/etc/passwd中每行的第一个字段

    awk -F: '{print $0}' /etc/passwd #打印出/etc/passwd文件中每行的所有字段

    awk -F: '{print $1" \t" $3}' /etc/passwd #以冒号为分隔符，打印出/etc/passwd每行的第一个字段和第三个字段，中间由制表符分隔

    grep "^UUID" /etc/fstab | awk '{print $2,$4}' #取出/etc/fstab文件中以^开头的行的第2和第四个字段
```
# awk变量：
>引用变量时，无需使用$
+ 内置变量：

    + FS：输入字段分隔符，默认为空白字符

    + OFS：输出字段分隔符，默认为空白字符
    + RS：输入记录分隔符，默认为换行符
    + ORS：输出记录分隔符，输出时用指定字符替换换行符
    + NF：字段数量
    + NR：记录号
    + FNR：各文件分别计数记录号
    + FILENAME：当前文件名
    + ARGC：命令行参数的个数
    + ARGV：保存着命令行给出参数组成的数组，编号从**0**开始
+ 自定义变量（区分字符大小写）：
1. -v var=value；这种定义的方法使得awk可以调用shell中定义的变量
    ```shell
       awk -v var=$VAR '{ACTION}' /PATH/TO/FILE 
       #此命令中的VAR就是shell中的变量
    ```
2. 在program中直接定义
# 操作符：
+ 算术操作符：
```
    + , - , * , / , ^ , %

    - x：把X转换成负数
    + x：将字符串转换为数值
```
+ 字符串操作符：
    + 无符号操作符时，可以实现字符串连接的效果
    ```
    [root@localhost test]#awk 'BEGIN{a=100;b=100;c=(a""b);print c}'
    100100
    ```
+ 赋值操作符：
```
    = , += , -= , *= , /= , %= , ^= , ++ , --

    [root@localhost test]#awk 'BEGIN{i=0;print ++i;i}'
    1

    [root@localhost test]#awk 'BEGIN{i=0;print i++;i}'
    0

```
>++与i的位置关系导致结果不同，++i是在print之前先自增，i++是在print之后自增
+ 比较操作符：
```
    == , != , > , >= , < , <=
```
+ 模式匹配符：
    + ~：左边是否与右边匹配（模糊匹配）

    + !~：是否不匹配
    + 示例：
    ```shell
        awk -F: '$0 ~ /root/{print $1}' /etc/passwd
        #以冒号为分隔符，取出行内有root的行中第一个字段的内容（此处为用户名）

        awk '$0 ~ "^root"' /etc/passwd
        #打印出以root开头的行

        awk '$0 !~ /root/' /etc/passwd
        #打印出所有不以root开头的行

        awk -F: '$3==0' /etc/passwd
        #打印出第三字段（此处即UID）为0的行
    ```
+ 逻辑操作符：
    + &&：与
    + ||：或
    + !：非
    + 示例：
    ```shell
        awk -F: '$3>=0 && $3<=1000{print $1}' /etc/passwd
        #以冒号为分隔符，打印出第三字段（此处即UID）在0~1000范围内（闭区间）的行的第一个字段（此处即用户名）

        awk -F: '$3==0 || $3>=1000{print $1}' /etc/passwd
        #以冒号为分隔符，打印出第三字段（此处即UID）等于0或者大于1000的行的第一字段（此处即用户名）

        awk -F '!($3==0){print $1}' /etc/passwd
        #以冒号为分隔符，打印出第三字段不为0的行的第一字段

        awk -F: '!($3>=500){print $3}' /etc/passwd
        #以冒号为分隔符，打印出第三字段大于等于500的行的第三字段
    ```
+ 条件表达式（三目表达式）：
```
    selector?if-ture-expression:if-false-expression

    selector：判断条件
    if-ture-expression：判断条件为真时执行的表达式
    if-false-expression：判断条件为假时执行的表达式
```
+ PATTERN：
>根据pattern条件，过滤匹配的行，再做处理
+ 若未指定：即为空模式，匹配每一行
+ /regular expression/：仅处理能够模式匹配到的行，//中使用扩展正则表达式
    + 使用类似{#,#}这样的次数匹配时，需要--posix选项
+ 关系表达式：结果为真才会处理
    + 真：结果为非0、非空值
    + 假：结果为空或0
    + 示例：
    ```shell
        awk -F: '$NF=="/bin/bash"{print $1,$NF}' /etc/passwd

        #以冒号为分隔符，精确匹配找出每行最后一个字段为/bin/bash的行，打印出这些行的第一个和最后一个字段

        awk -F: '$NF ~ /bash$/{print $1,$NF}' /etc/passwd

        #以冒号为分隔符，找出以bash结尾的行，并打印出这些行的第一个字段和最后一个字段
    ```
+ 行范围：
    /startline/,/endline/：指定起始行和结束行
    + 示例：
    ```shell
        awk -F: '/^root/,/^nobody/{print $1}' /etc/passwd
        #打印出/etc/passwd行首为root与行首为nobody中间的行

        awk -F: '(NR>=10&&NR<=20){print NR,$1}' /etc/passwd
        #打印出/etc/passwd文件的第10行（包含）到第20行（包含）中间的行
    ```
+ BEGIN\END模式：
    + BEGIN：仅在开始处理文本之前执行一次
    + END：仅在文本处理完成之后执行一次
    + 示例：
    ```shell
        awk -F: 'BEGIN{print "user userid"}{print $1":"$3}END{print "END"}' /etc/passwd
        #在处理文本前先打印user userid，然后处理文本，以冒号为分隔符，打印出每行的的第一、三字段，最后打印END
    ```
+ 常用的action分类：
    1. expressions：算术、比较表达式等

    2. control statements：if、while等
    3. compound statements：组合语句
    4. input statements
    5. output statements：print等
