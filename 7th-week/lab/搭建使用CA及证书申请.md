# openssl的配置文件：
>/etc/pki/tls/openssl.cnf

+ 三种策略：
    + match（匹配）：要求申请填写的信息跟CA设置信息必须一致

    + optional（可选）：跟CA设置信息可不一致
    + supplied（提供）：必须填写这项申请信息
# 创建私有CA及证书申请：
1. 创建必需的文件：
```shell
    touch /etc/pki/CA/index.txt #创建证书索引数据库文件

      echo 01 > /etc/pki/CA/serial #指定颁发的第一个的证书的系序列号
```
2. CA自签证书：
```shell
    cd /etc/pki/CA

    umask 066;openssl genrsa -out private/cakey.pem 2048 
    -new：生成新证书签署请求
    -x509：专用于CA生成自签证书
    -key：生成请求时用到的私钥文件
    -days N：证书的有效期限
    -out /PATH/TO/CERT_FILE：证书的保存路径
    #生成私钥    
```
3. 颁发证书：
>在需要使用证书的主机生成证书请求
+ 客户端生成私钥:
```shell
    umask 066;openssl genrsa -out ~/test/test.key 2048
```
+ 客户端生成证书申请文件：
```shell
    openssl req -new -key ~/test/test.key -out ~/test/test.csr 
```
+ 客户端将请求文件发送给CA

+ CA签署证书，并将证书颁发给请求者：
```shell
    openssl ca -in /PATH/TO/CSR_FILE /etc/pki/CA/certs/test.crt -days 365 #默认要求国家、省、公司名三项必须和CA一致
```
4. 查看证书中的信息：
```shell
    openssl ca -status SERIAL #查看指定编号的证书状态
```
5. 吊销证书：
+ 在客户端获取要吊销的证书的serial：
```
    openssl x509 -in /PATH/FORM/CERT_FILE -noout -serial -subject
```
+ 在CA上根据客户日交的serial与subject信息，对比检验是否与index.txt中的信息一致
+ 吊销证书：
```
    openssl ca -revoke /etc/pki/CA/newcerts/SERIAL.pem
```
+ 指定第一个吊销证书的编号：
>第一次更新证书吊销列表前才需要执行
```
    echo 01 > /etc/pki/CA/crlnumber
```
+ 更新证书吊销列表：
```
    openssl ca -gencrl -out /etc/pki/CA/crl.pem
```
+ 查看吊销信息：
```
    openssl crl -in /etc/pki/CA/crl.pem -noout -test
```
