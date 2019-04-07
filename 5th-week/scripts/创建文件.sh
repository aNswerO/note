#在/testdir目录下创建10个html文件,文件名格式为数字N（从1到10）加随机8个字母，如：1AbCdeFgH.html
#!/bin/bash
for i in {1..10};do
    RAND=$(openssl rand -base64 8 | md5sum | cut -c1-8)
    touch /root/test/scripts/testdir/"$i""$RAND".html
    echo ""$i""$RAND".html has been created!"
done
