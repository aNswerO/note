# 添加10个用户user1-user10，密码为8位随机字符

```
#!/bin/bash
for i in {1..10};do
    PSWD=$(openssl rand -base64 8 | md5sum | cut -c1-8)
    useradd user$i -p "$PSWD"
    echo user$1 has been created!
done
```
