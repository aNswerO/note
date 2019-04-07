#每隔3秒钟到系统上获取已经登录的用户的信息；如果发现用户hacker登录，则将登录时间和主机记录于日志/var/log/login.log中,并退出脚本
#!/bin/bash
while true;do
    sleep 3
    w | grep -e "^hacker.*" &> /dev/null
    if [ $? -eq 0 ];then
        w | sed -ne "/^hacker.*/p" | tr -s " " | cut -d" " -f1,2,3,4 >> /var/log/login.log
        echo found hacker!
        echo log has been recorded!                                                       
        exit
    fi
done
