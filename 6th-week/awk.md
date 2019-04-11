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
1. -v var=value
2. 在program中直接定义
# 操作符：
+ 算术操作符：