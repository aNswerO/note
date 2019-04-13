# awk控制语句：
## if-else：
+ 语法：
```shell
    if(condition){statement;...}[else statement]
    #单分支

    if(condition1){statement1}else if(condition2){statement2}else{statement3}
    #多分支
```
+ 使用场景：对awk取得的整行或某个字段做条件判断
+ 示例：
```shell
    awk -F: '{if($3>=1000)print $1,$3}' /etc/passwd
    #以冒号为分隔符，打印出UID大于1000的行的第一、三字段

    awk -F： '{if($NF=="/bin/bash")print $1}' /etc/passwd
    #以冒号为分隔符，打印出最后一个字段是/bin/bash的行的第一个字段

    awk '{if(NF>5)print $0}' /etc/fstab
    #打印出最后一个字段大于5的行

    awk -F: '{if($3>=1000){printf "common user:%s\n",$1}else{printf "system user:%s\n",$1}}' /etc/passwd
    awk -F: '{if($3>=1000)printf "common user:%s\n",$1;else printf "system user:%s\n",$1}' /etc/passwd
    #以冒号为分隔符，分别匹配UID大于等于1000和小于1000的行，分别格式化打印出这些行“common user：（第一个字段的内容）”

    df -h | awk -F% '/^\/dev/{print $1}' | awk '$NF>=80{print $1,$5}'
    #打印出磁盘利用率高于80%的分区以及它的利用率
```
## whlie：
+ 语法：
```shell
    while(condition){statement;...}
```
+ 执行过程：
    + 真：执行循环体内容
    + 假：退出循环
+ 使用场景：
    1. 对一行内的多个字段逐一类似处理时使用时使用
    2. 对数组中的各元素逐一处理时使用
+ 示例：
```shell
    awk '/^[[:space:]]*linux16/{i=1;while(i<=NF){print $i,length($i);i++}}' /etc/grub2.cfg
    #找出/etc/grub2.cfg文件中以任意个空格后跟linux16开头的行，打印出每个字段的内容和它的长度

    awk '/^[[:space:]]*linux16/{i=1;while(i<=NF){if(length($i)>=10){print $i,length($i)};i++}}' /etc/grub2.cfg 
    #找出/etc/grub2.cfg文件中以任意个空格后跟linux16开头的行，打印出长度超过10的字段及其长度
```
## for：
+ 语法：
```shell
    for(expr1;expr2;expr3){statement;...}
```
+ 常见用法：
```shell
    for(variable assignment;condition;iteration process){for-body}

    variable assignmen：变量赋值
    condition：条件
    iteration process：迭代
    for-body：循环体
```
+ 示例：
```shell
    awk '/^[[:space:]]*linux16/{for(i=1;i<=NF;i++){print $i,length($i)}}' /etc/grub2.cfg
    #找出以任意个空格后跟linux16开头的行，打印出此行所有的字段以及它们的长度
```
## switch：
+ 语法：
```shell
    switch(expression){case VALUE1 or /REGEXP1/:statement1;case VALUE2 or REGEX2:statement2;...;default:statementn}
```
## break和continue：
+ break：结束本层循环
    + 示例：
    ```shell
        awk 'BEGIN{sum=0;for(i=1;i<=100;i++){if(i%2==0)continue;sum+=i}print sum}'
        #打印出1~100以内所有奇数的和
    ```
+ continue：结束本次循环
    + 示例：
    ```shell
        awk 'BEGIN{sum=0;for(i=1;i<=100;i++){if(i==66)break;sum+=i}print sum}'
        #打印出1~65中所有整数的和
    ```
+ next：awk自身循环使用的控制语句（一次循环即处理一个记录）
>提前结束对本行的处理而直接进入下一行处理
```sehll
    示例：
    awk -F: '{if($3%2!=0)next;print $1,$3}' /etc/passwd
    #打印出UID为偶数的行的用户名和UID
```
# awk数组：
+ 为关联数组：array[index-expression]
+ index-expression:
    1. 可使用任意字符串，但字符串要使用双引号括起来
    2. 若某数组元素事先不存在，在引用时awk会自动创建该元素，并将其值初始化为**空**
    3. 若要判断数组中某元素是否存在，要使用INDEX in ARRAY的格式进行遍历
+ 示例：
```shell
    awk 'BEGIN{weekends["mon"]="Monday";weekends["tue"]="Tuesday";print weekends["mon"]}'
    #定义关联数组weekends，定义元素weekends["mon"]的值为Monday，weekends["tue"]的值为Tuesday；打印出weekends["mon"]的值

    awk '!line[$0]++' FILE
    #将每行的全部内容作为line数组的索引。由于每个元素第一次出现，在引用时awk会初始化其值为空，之后命令会将其值先自增1，在取反；这样第一次出现后再出现的元素的值都为0，不会执行默认的print $0，所以该命令作用为去除重复行

    awk '{!line[$0]++;print $0,line[$0]}' FILE
    #此命令可以显示上面命令每行内容和line数组元素的值，有助理解
```
## 数组遍历：
>若要遍历数组中的每个元素，要使用for循环；var会遍历array的每个索引
+ 语法：
```shell
    for(var in array){for-body}
```
+ 示例：
```shell
    netstat -tan | awk '/^tcp/{state[$NF]++}END{for(i in state){print i,state[i]}}'
    #找出以tcp开头的每一行，将每行的连接状态（每行最后一个字段）作为state数组的索引，索引重复的不打印，打印出所有的连接状态及处于同一连接状态的个数
```
# awk函数：
## 数值处理：
+ rand()：返回0~1之间的一个随机数，但每次都是同一个数字
+ srand(expr)：与rand()配合使用可以产生一个0~1之间的随机数
+ 用法示例：
```shell
    awk 'BEGIN{print rand()}'
    #每次打印的都是同一个数字

    awk 'BEGIN{srand();print int(rand()*100)}'
    #生成1~100之间的随机整数
```
## 字符串处理：
+ length([s])：返回指定字符串的长度
+ sub(r,s,[t])：对**t**字符串搜索**r**模式匹配的内容，并将第一个匹配内容替换为**s**
+ gsub(r,s,[t]):对**t**字符串搜索**r**模式匹配的内容，并将全部匹配内容替换为**s**
+ split(s,array,[r])：以**r**为分隔符，切割字符串**s**，将结果保存在数组**array**中，第一个索引为1，第二个为2，以此类推
### 示例：
```shell
    echo "2008:08:08 08:08:08" | awk 'sub(/:/,"-",$0)'
    #sub查找替换，仅替换第一个符合匹配的内容

    echo "2008:08:08 08:08:08" | awk 'gsub(/:/,"-",$0)'
    #gsub查找替换，替换指定范围内所有匹配的内容

    netstat -tn | awk '/^tcp/{split($5,ip,":");count[ip[1]]++}END{for(i in count){print i,count[i]}}'
    #将netstat -tn结果中每行的第五个字段（IP地址）存到ip数组中（重复的不存，但每重复一次就让count[此出现重复IP地址]的值+1），最后打印出IP地址和出现的次数
```
## 自定义函数:
+ 格式：
```shell
    function name (parameter,parameter,...){
        statements
        return expression
    }
```
+ 示例：
```shell
    function max(x,y){
        x>y?var=x:var=y  #三目表达式；x>y时，将x赋值给变量var，否则将y赋值给变量var
        return var
    }
    BEGIN{a=3;b=2;print max(a,b)}

    awk -f fun.awk  #使用awk运行fun.awk脚本
```
+ 参数：
    + 形参：定义函数名和函数体时使用的参数，用来接收调用该函数时传入的参数
    + 实参：调用时传递给函数的参数；进行函数调用时，他们必须有确定的值，以便把值传给形参；因此需预先使用赋值，输入等方式使实参获得确定值
# awk中调用shell命令：
>使用system命令
+ 空格是awk中的字符串连接符，如果system命令中要使用awk中的变量可以使用空格分隔，或者说除了awk的变量外其他一律用**引号**括起来
+ 示例：
```shell
    awk 'BEGIN{system("hostname")}'
    #使用system命令调用shell中的hostname命令

    awk 'BEGIN{score=100;system("echo "score)}'
    #使用system调用shell中的echo命令，引号中的echo后要加空格
```
# awk脚本：
>将awk程序写成脚本，以便直接调用或执行
+ 示例：
```shell
    {if($3>100)print $1,$3} #脚本中内容

    awk -F: -f sum.awk /etc/passwd #执行awk命令调用脚本

    #!/bin/awk -f
    {if($3>100)print $1,$3}

    chmod +x sum.awk
    sum.awk -F: /etc/passwd
    #执行sum.awk脚本
```
## 向awk脚本中传递参数
+ 格式：
```
    AWK_FILE var=value1 var=value2...INPUT_FILE
```
>注意：在BEGIN过程中不可用，直到开始处理第一行时，变量才可用；可通过-v参数，让awk在执行BEGIN之前得到变量的值；命令中每一个指定的变量都需要一个-v参数
+ 示例：
```shell
    #!bin/awk -f
    {if($3>=min && $3<=max)print $1,$3}

    chmod +x test.awk
    test.awk -F: min=100 max=200 /etc/passwd #传递参数
```
