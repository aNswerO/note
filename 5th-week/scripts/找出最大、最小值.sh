#利用变量RANDOM生成10个随机数字，输出这个10数字，并显示其中的最大值和最小值
#!/bin/bash
i=0
R_Number=$RANDOM
Max=$R_Number
Min=$R_Number
while [ $i -le 9 ];do
    R_Number=$RANDOM
    if [ $R_Number -lt $Min ];then
    	Min=$R_Number
    fi
    if [ $R_Number -gt $Max ];then
    	Max=$R_Number
    fi
    i=$((i+1))
    echo $R_Number
done
echo min_number is $Min
echo max_number is $Max
