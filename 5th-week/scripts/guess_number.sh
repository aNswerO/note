#随机生成10以内的数字，实现猜字游戏，提示比较大或小，相等则退出
#!/bin/bash
Rand=$((RANDOM%11))
while true;do
read -p "guess a number: " guess
    if [ $guess -eq $Rand ];then                                                          
        echo success
        break
    elif [ $guess -lt $Rand ];then
        echo guess bigger
    else
        echo guess smaller
    fi
done
