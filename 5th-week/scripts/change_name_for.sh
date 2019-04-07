#/etc/rc.d/rc3.d目录下分别有多个以K开头和以S开头的文件；分别读取每个文件，以K开头的输出为文件加stop，以S开头的输出为文件名加start，如K34filename stop S66filename start
#!/bin/bash
for i in /etc/rc.d/rc3.d/*;do
    if [[ "$i" =~ ^S* ]];then
        mv $i $i\ start
    elif [[ "$i" =~ ^K* ]];then
        mv $i $i\ stop
    fi
done
