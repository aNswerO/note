# 编写脚本的注意事项：
1. 开头指定使用什么shell，例如：bash，ksh，csh等
2. 脚本功能描述，使用方法，作者，版本，日期等
3. 变量名，函数名要有实际意义，函数名以动名词形式，第二个单词首字母要大写。例如：updateConfig()
4. 缩进统一用4个空格，不用TAB
5. 取变量值使用大括号，如${varname}
6. 删除文件时，如果路径有变量的，要判断变量有值，如rm -f ${abc}/* 
7. 如果变量abc没有值，则会把根目录下的文件删除
8. 脚本中尽量不要使用cd变换目录
9. 函数中也要有功能描述，使用依法，版本，日期等
10. 函数的功能要单一，不要太复杂
11. 引用时使用$()比\`  \`更好
12. 尽量不要使用多层if语句，而应该以case语句替代
如果需要执行确定次数的循环，应该用for语句替代while语句
13. 输入的参数要有正确性判断
14. 多加注释，方便自己或他人阅读。
--------------------- 
作者：斯言甚善  
引用自CSDN：https://blog.csdn.net/qq_18312025/article/details/78278989 
# shell脚本中的循环：
+ for
+ while
+ until
## for循环：
>执行机制：依次将列表中的元素赋值给VAR_NAME，每次赋值执行一次LOOP_BODY,知道LIST中的元素耗尽，循环结束
+ for循环的语法格式：
1. shell中的for循环语法格式：
```
    for VAR_NAME in LIST;do
        LOOP_BODY
    done
```
2. c语言风格的for循环语法格式：
```
    for ((VAR_INIT;EXPRESSION;EXPR_CORRECT))
    do
        LOOP_BODY
    done

    VAR_INIT：控制变量初始化，仅在运行到循环代码段时执行一次
    EXPR_CORRECT：控制变量的修正表达式，每轮结束先执行修正表达式，再进行条件判断
```
+ 列表的生成方式：
    1. 直接给出列表
    2. 整数列表
        + {#，#}
        + $(seq [start [step]] end)
    3. 引用返回列表的命令
    4. 使用glob通配
    5. 变量引用：$@,$*
--------------------- 
## while循环：
>执行机制：进入循环时，对**循环控制条件**进行一次判断，每次循环结束后再进行一次判断；当条件为**true**时，执行一次循环，直到条件为**false**时，终止循环
+ while循环的语法格式：
```
    while CONDITION;do
        LOOP_BODY
    done

    CONDITION：循环控制条件，一般会有循环控制变量，此变量会在循环体中不断地被修正
```
+ while循环的特殊用法：
```
    while read LINE；do
        LOOP_BODY
    done < /PATH/FROM/SMOEFILE
```
>依次读取/PATH/FROM/SMOEFILE文件中的每一行，且将行内容赋值给变量LINE
--------------------- 
## until循环：
>执行机制：与while循环相反，进入循环时，对**循环控制条件**进行一次判断，每次循环结束后再进行一次判断；当条件为**false**时，执行一次循环，知道条件为**true**时，终止循环
+ until循环的语法格式：
```
    until CONDITION;do
        LOOP_BODY
    done
```
--------------------- 
## 循环控制语句：
+ continue
+ break
+ shift
### continue：
```
    while CONDITION1;do
        CMD1
        ...
        if CONDITION2;do
            continue [#]
        fi
        CMDn
        ...
    done
```
>作用：提前结束第#层的**本轮循环**，直接进入下一轮判断（最内层为第1层）
### break：
```
    while CONDITION1;do
        CMD1
        ...
        if CONDITION2;do
            break [#]
        fi
        CMDn
        ...
    done
```
>作用：提前结束第#层循环（最内存为第1层）
### shift：
```
    shift [#]
```
>作用：将参量列表LIST左移#次，缺省为左移一次；LIST一旦被移动，最左端的那个参数会从LIST中删除。在while循环遍历位置参量列表时，常使用shift
--------------------- 
## 死循环：
+ while：
```
    while true;do
        LOOP_BODY
    done
```
+ until:
```
    while false;do
        LOOP_BODY
    done
```
## select循环与菜单：
>select循环主要用来创建菜单，select将LIST中的内容按数字顺序排列成菜单项并显示到**标准错误**上，同时显示PS3提示符，等待用户输入
```
    select VAR in LIST
    do
        LOOP_CMD
    done
```
+ 用户输入列表中的数字，执行相应的命令
+ 用户的输入被保存在内置变量REPLY中
+ select是一个死循环，所以要使用break或exit结束循环
+ select经常与case一起使用
+ 与for循环类似，可省略“in LIST”，使用位置变量组成的LIST
--------------------- 
# 函数（function）：
+ 函数是由若干条shell命令组成的语句块
+ 使用函数以实现代码重用和模块化编程
+ 函数不是一个单独的进程，是shell的一部分，不能单独运行
## shell程序与函数的区别：
1. shell程序在子shell中运行
2. shell函数在当前shell中运行，因此在当前shell中，函数可以对shell中的变量进行修改
## 函数的定义：
+ 可在交互式环境下定义函数
+ 可将函数放在脚本中作为他的一部分
+ 可放在只包含函数的单独文件中
+ 函数在使用前必须定义，且应定义在脚本的开始部分
1. 语法一：
```
    f_name （）{
        FUNTION_BODY
    }
```
2. 语法二：
```
    function f_name {
        FUNTION_BODY
    }
```
3. 语法三：
```
    function f_name() {
        FUNTION_BODY
    }
```
## 函数的调用：
+ 函数只有被调用才会被执行
+ 使用函数名以调用函数
+ 函数名出现的地方，会替换为函数的代码
## 函数的生命周期：
+ 被调用时创建，返回时终止
## 函数的返回值：
1. 函数的执行结果返回值：
    + 使用echo等命令进行输出
    + 函数体中调用命令的输出结果
2. 函数的退出状态码：
    + 默认取决于函数中执行的最后一条代码的退出状态码
    + 自定义退出状态码：
        + return：从函数中返回，用最后命令状态决定返回值
        + return 0：无错误返回
        + return 1~255：有错误返回
## 函数的使用：
+ 可以将常用的函数写在一个文件中，然后将此文件载入shell
+ 一旦函数文件载入shell，就可以在命令行或脚本中调用函数；可使用set命令查看所有定义的函数，其输出列表包括已载入shell的所有函数
+ 如要改动函数，应先用unset将函数从shell中删除；在改动后重新载入此文件
## 环境函数：
+ 子进程也可以调用环境函数
+ 声明：export -f FUNC_NAME
+ 查看：export -f | declare -xf
## 函数变量：
+ 变量：存储单个元素的内存空间
+ 变量的作用域：
    + 本地变量：作用范围为当前shell脚本程序文件，包括脚本中的函数
    + 局部变量：只在函数中有效，函数结束时自动销毁
        + local FUNC_NAME=VALUE
    + 环境变量：在当前shell和子shell中有效
## 函数的递归：
>函数直接或间接调用自身
# trap（信号捕捉）：
+ trap '触发指令' SIGNAL：进程收到SIGNAL时，将执行触发指令，而不会执行原操作
+ trap '' SIGNAL：忽略信号的操作
+ trap '-' SIGNAL：恢复原信号的操作
+ trap -p：列出自定义信号的操作
+ trap finish EXIT：当脚本结束时执行finish函数
--------------------
# 数组：
>存储多个元素的连续内存空间，相当于多个变量的集合
## 数组的索引：
+ 索引编号从**0**开始
+ 索引可支持使用自定义的格式，这种索引叫做关联索引
+ bash中的数组支持稀疏格式（索引不连续）
## 数组的声明：
+ declare -a ARRAY_NAME：声明数组
+ declare -A ARRAY_NAME：声明关联数组（关联数组必须先声明再调用）
+ declare -a：显示所有数组
>两种数组不能相互转化
## 数组元素的赋值：
1. 一次赋值一个元素：
```
    ARRAY_NAME[INDEX]=VALUE
```
2. 一次赋值全部元素：
```
    ARRAY_NAME=("VAL1" "VAL2" "VAL3" ...)
```
3. 只赋值特定元素：
```
    ARRAY_NAME=([0]="VAL1" [3]="VAL2" ...)
```
4. 交互式对数组元素赋值：
```
    read -a ARRAY
```
---------------
## 引用数组：
+ 引用数组的元素：
```
    ${ARRAY_NAME[INDEX]}
    省略[INDEX]时表示应用0下标的元素
```
+ 引用数组的所有元素：
```
    ${ARRAY_NAME[*]}
    ${ARRAY_NAME[@]}
```
+ 引用数组的长度：
```
    ${#ARRAY_NAME[*]}
    ${#ARRAY_NAME[@]}
```
+ 删除数组中的某元素：
```
    unset ARRAY_NAME[INDEX]
```
+ 删除整个数组：
```
    unset ARRAY_NAME
```
+ 数组切片：
```
    ${ARRAY_MAME[@]:OFFSET:NUMBER}
        OFFSET：偏移量，指要跳过的元素个数
        NUMBER：要取出的元素个数

    ${ARRAY_NAME[@]:OFFSET}
    取出偏移量之后的所有元素
```
+ 向数组中追加元素：
```
    ARRAY_NAME[${#ARRAY_NAME[*]}]=VALUE
```
