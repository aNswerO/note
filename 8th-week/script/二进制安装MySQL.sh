!#/bin/bash
groupadd -r -g 336 mysql >& /dev/null
useradd -r -g mysql -u 336 -s /sbin/nologin -d /data/mysql mysql >& /dev/null
tar xvf mariadb-10.2.22-linux-x86_64.tar.gz -C /usr/local/ >& /dev/null
cd /usr/local
ln -s mariadb-10.2.22-linux-x86_64/ mysql
chown -R root:root /usr/local/mysql
chown -R root:root /ur/local/mariadb-10.2.22-linux-x86_64/
echo "PATH=/usr/local/mysql/bin:$PATH" > /etc/profile.d/mysql.sh
mkdir -p /data/mysql
chown mysql:mysql /data/mysql/
cd /usr/local/mysql
./scripts/mysql_install_db --datadir=/data/mysql --user=mysql
mkdir /etc/mysql
cp /usr/local/mysql/support-files/my-huge.cnf /etc/mysql/my.cnf
sed -r -i.bak 's@^#[[:space:]]Try.*@datadir=/data/mysql@' /etc/mysql/my.cnf
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
systemctl start mysqld
