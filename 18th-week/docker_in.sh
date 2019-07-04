#!/bin/bash
#使用nsenter命令进入容器的脚本
read -p "Enter the container's name/ID:" CONTAINER    #输入要进入的容器的ID或name
PID=$(docker inspect -f "{{.State.Pid}}" $CONTAINER)
nsenter -t $PID -m -u -i -n -p
