# 一次https通信的过程：
1. 客户端向服务器的443端口（https默认使用443端口）发起请求

2. 服务器向客户端传递证书（本质是公钥），其中包含了很多信息，如证书的颁发机构和过期时间等
>采用https协议的服务器都必须有一套证书，可以向一些组织申请，也可以自己制作
3. 客户端解析证书，验证公钥的有效性，如证书的颁发机构和过期时间：
    + 若发现异常，客户端的浏览器会弹出一个警告框提示证书可能存在问题

    + 若未发现异常，客户端会生成一个随机值，然后使用服务器的公钥对该随机值进行加密，然后将其传递给服务器
4. 服务器收到客户端加密的随机值后，使用自己的私钥解密，就得到了客户端生成的随机值，然后服务器和客户端就可以使用这个随机值对要发送的内容进行加密（对称加密），保证了安全性

# nginx实现https：
1. 服务器自签名证书：
    ```sh
    cd /apps/nginx

    mkdir certs

    cd /app/nginx/certs

    openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 3650 -out ca.crt
    #自签名CA证书

    openssl req -newkey rsa:4096 -nodes -sha256 -keyout https.key -out https.csr
    #自制key和csr文件

    openssl x509 -req -days 3650 -in https.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out https.crt
    #签发证书

    openssl x509 -in https.crt -noout -text
    #验证证书内容
    ```
2. 修改配置文件：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/https/%E9%85%8D%E7%BD%AE.png)  
3. 重载nginx配置文件并测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/https/%E6%B5%8B%E8%AF%95_1.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/https/%E6%B5%8B%E8%AF%95_2.png)  
