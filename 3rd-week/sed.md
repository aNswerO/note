# sed
+ 介绍：一种流编辑器，一次处理一行，处理时把当前处理的行放入一个叫“模式空间”的临时缓冲区中，接着处理“模式空间”中的内容，处理完成后打印到屏幕，之后读入下一行。如果没有使用特殊命令，就会在两个循环的中间清空模式空间，但不会删除保留空间的内容。如此不断重复直到处理到最后。默认不会改变文件的内容，除非使用重定向存储输出。
+ 功能：主要用来自动编辑一个或多个文件，简化对文件重复的操作、编写转换程序等
+ 语法：
```
    sed [OPTION]... 'SCRIPT' INPUTFILE  
        -n：不自动输出模式空间的内容至屏幕
        -e：多点编辑
        -f /PATH/TO/SCRIPT：从指定文件中读取脚本
        -r：使用扩展正则表达式
        -i.bak：以.bak后缀备份文件，并在当前文件中编辑
```
## 地址界定：
>SCRIPT：地址命令  
+ 不给地址：默认对全文做处理
+ 单地址：
    + #：指定的行 
    + $：最后一行
    + /pattern/：被此处模式所能匹配到的每一行
+ 地址范围：
    + #，#：第几行到第几行
    + #，+#：第几行到第几行的后几行
    + /part1/，/part2/：匹配part1与匹配part2之间的行
    + #，/part/：第几行与匹配part之间的行
+ 步进：~
    + 1~2：第一行开始处理，隔一行处理下一个一行，即处理奇数行
    + 2~2：第二行开始处理，隔一行处理下一个一行，
    即处理偶数行
>编辑命令：
+ d：删除模式空间匹配的行，并开始下一个循环
+ p：打印当前模式空间内容，追加到默认输出之后
+ a TEXT：在指定行下面追加文本，支持使用换行符\n
+ i TEXT：在指定行上面追加文本，支持使用换行符\n
+ c TEXt：替换指定行的内容为单行或多行文本
+ w /PATH/TO/FILE：保存匹配的行，并将内容写入到指定文件中
+ r /PATH/TO/FILE：读取指定文件中的内容，将其追加到模式空间中匹配到的行后
+ =：为模式空间中的行打印行号
= !:取模式空间中匹配行的补集
## 查找：
```
    s///    也可使用#、@当做分隔符
```
+ 替换标记：
    g：行内全局替换
    p：显示成功替换的行
    w /PATH/TO/FILE：将替换成功的行写入到指定文件中
## eg：
```
    sed '2p' /etc/passwd  
    显示/etc/passwd文件的内容，其中第二行打印两遍

    sed -n '2p' /etc/passwd  
    只显示/etc/passwd的第二行

    sed -n '1,4p' /etc/passwd
    显示/etc/passwd的第一行到第四行的内容

    sed- n '/root/p' /etc/passwd
    只显示/etc/passwd中出现root的行

    sed -n '2,/root/p' /etc/passwd
    只显示第二行到下面第一次出现root的行

    sed -n '^$=' /etc/passwd
    显示空行的行号

    sed -n -e '/^$/p' -e '/^$/=' /etc/passwd
    显示空行并显示行号

    sed '/root/a\superman' /etc/passwd
    在出现root的行的下一行追加superman

    sed '/root/i\superman' /etc/passwd
    在出现root的行的下一行追加superman

    sed '/root/i\superman' /etc/passwd
    将出现root的行的内容替换成为superman

    sed '/^$/d'FILE
    将空行删除

    sed '1,10d' FILE
    将第一行到第十行删除

    sed 's/test/mytest/g' FILE
    将所有的test替换成mytest

    sed -n 's/root/&superman/p' FILE
    将每行第一个root后增加superman

    sed -n 's/root/superman&/p' FILE
    将每行第一个root前增加superman

    sed -e 's/dog/cat/' -e 's/hi/lo/' pets
    将pets文件中每行第一次出现的dog替换为cat、hi替换成lo

    sed -i.bak 's/dog/cat/g' pets
    将pets中所有dog替换为cat，并将原文件以.bak文件名备份，将修改写入当前文件
```
