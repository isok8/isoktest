useradd mysql -s /sbin/nologin -M
#tar -xf /server/tools/mysql-5.7.26-linux-glibc2.12-x86_64.tar.gz
mkdir /application -p 
mv /server/tools/mysql-5.7.26-linux-glibc2.12-x86_64 /application/mysql-5.7.26
ln -s /application/mysql-5.7.26/ /application/mysql
rpm -e --nodeps mariadb-libs
cat >/etc/my.cnf<<EOF
[mysqld]
basedir = /application/mysql/
datadir = /application/mysql/data
socket = /tmp/mysql.sock
server_id = 1
port = 3306
log_error = /application/mysql/data/zhangweibin_mysql.err

[mysql]
socket = /tmp/mysql.sock
prompt = zhangweibin [\d]>
EOF
yum install libaio-devel -y
mkdir -p /application/mysql/data
chown -R mysql.mysql /application/mysql/
/application/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/application/mysql/ --datadir=/application/mysql/data
cat >/etc/systemd/system/mysqld.service<<EOF
[Unit]
Description=MySQL Server by zhangweibin
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target
[Install]
WantedBy=multi-user.target
[Service]
User=mysql
Group=mysql
ExecStart=/application/mysql/bin/mysqld --defaults-file=/etc/my.cnf
LimitNOFILE = 5000
EOF
systemctl start mysqld
systemctl enable mysqld
netstat -lntup|grep mysql
ps -ef|grep mysql|grep -v grep
echo 'export PATH=/application/mysql/bin:$PATH' >>/etc/profile
source  /etc/profile
mysqladmin -u root password '123456'