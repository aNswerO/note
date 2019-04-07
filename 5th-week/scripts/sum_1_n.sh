#编写脚本，提示输入正整数n的值，计算1+2+…+n的总和
#!/bin/bash
sum=0
while true;do
        read -p "please input a positive integer: " number
        expr $number + 1 &> /dev/null
        if [ $? -eq 0 -a $number -gt 0 &> /dev/null ];then     #利用expr做计算时变量或字符串必须是整数的规则，把一个变量或字符串和一个已知的整数（非0）相加，看命令返回的值是否为0.如果为0，就认为加法的变量或字符串为整数，否则就不是。
                for i in `seq $number`;do
                    sum=$((sum+i))
                    i=$((i+1))
                done
                echo sum="$sum"
                break
        else
                echo error:$number is not a positive integer!
        fi
done
