###### 二进制自动安装数据库脚本root密码ROOT将脚本和安装包放在/root目录即可###############
######数据库目录/usr/local/mysql############
######数据目录/data/mysql############
######慢日志目录/data/slowlog############
######端口号默认3306############

 
 
# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install"
    exit 1
fi
 
clear
echo "========================================================================="
echo "A tool to auto-compile & install MySQL 8.0.12 on Redhat/CentOS Linux "
echo "========================================================================="
cur_dir=$(pwd)
 
#which MySQL Version do you want to install?
echo "==========================="
 
 
    isinstallmysql812="n"
    echo "Install MySQL 8.0.12,Please input y"
    read -p "(Please input y , n):" isinstallmysql812
 
 
    case "$isinstallmysql812" in
    y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
    echo "You will install MySQL 8.0.12"
 
    isinstallmysql812="y"
    ;;
    *)
    echo "INPUT error,You will exit install MySQL 8.0.12"
 
    isinstallmysql812="n"
    exit
    esac
 
    get_char()
    {
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    #dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
    }
    echo ""
    echo "Press any key to start...or Press Ctrl+c to cancel"
    char=`get_char`
 
# Initialize  the installation related content.
function InitInstall()
{
    cat /etc/issue
    uname -a
    MemTotal=`free -m | grep Mem | awk '{print  $2}'`  
    echo -e "\n Memory is: ${MemTotal} MB "
    #Set timezone
    #rm -rf /etc/localtime
    #ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
 
 
 
    #Disable SeLinux
    if [ -s /etc/selinux/config ]; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    fi
    setenforce 0
 
 
}
 
 
#Installation of depend on and optimization options.
function InstallDependsAndOpt()
{
cd $cur_dir
 
cat >>/etc/security/limits.conf<<EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF
 
echo "fs.file-max=65535" >> /etc/sysctl.conf
}
 
#Install MySQL
function InstallMySQL812()
{
echo "============================Install MySQL 8.0.12=================================="
cd $cur_dir
 
#Backup old my.cnf
#rm -f /etc/my.cnf
if [ -s /etc/my.cnf ]; then
    mv /etc/my.cnf /etc/my.cnf.`date +%Y%m%d%H%M%S`.bak
fi
 
echo "============================MySQL 8.0.12 installing…………========================="
#mysql directory configuration
tar xvf /root/mysql-8.0.12-linux-glibc2.12-x86_64.tar
mv /root/mysql-8.0.12-linux-glibc2.12-x86_64 /usr/local/mysql
#edit /etc/my.cnf
cat >>/etc/my.cnf<<EOF
[mysqld]
server-id                      = 224
port                           = 3306
mysqlx_port                    = 33060
mysqlx_socket                  = /tmp/mysqlx.sock
datadir                        = /data/mysql
socket                         = /tmp/mysql.sock
pid-file                       = /tmp/mysqld.pid
auto_increment_offset          = 2
auto_increment_increment       = 2 
log-error                      = error.log
slow-query-log                 = 1
slow-query-log-file            = slow.log
long_query_time                = 0.2
log-bin                        = bin.log
relay-log                      = relay.log
binlog_format                 =ROW
relay_log_recovery            = 1
character-set-client-handshake = FALSE
character-set-server           = utf8mb4
collation-server               = utf8mb4_unicode_ci
init_connect                   ='SET NAMES utf8mb4'
innodb_buffer_pool_size        = 1G
join_buffer_size               = 128M
sort_buffer_size               = 2M
read_rnd_buffer_size           = 2M
log_timestamps                 = SYSTEM
lower_case_table_names         = 1
default-authentication-plugin  =mysql_native_password
EOF
groupadd mysql -g 512
useradd -u 512 -g mysql -s /sbin/nologin -d /home/mysql mysql
mkdir -p /data/mysql
chown -R mysql:mysql /data/mysql
chmod -R 775 /data/mysql/
chown -R mysql:mysql /usr/local/mysql
  

/usr/local/mysql/bin/mysqld --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql --initialize-insecure
cat /data/mysql/error.log | grep -i password
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
 
/etc/init.d/mysql start
 
cat >>/etc/profile.d/mysql.sh<<EOF
export PATH=$PATH:/usr/local/mysql/bin
export PATH=$PATH:/usr/local/mysql/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/mysql/lib
EOF
 
source /etc/profile.d/mysql.sh

cat >>/tmp/mysql_sec_script<<EOF
use mysql;
ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
create user root@'%' identified by '123456';
GRANT all ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;
EOF

/usr/local/mysql/bin/mysql -u root -p -h localhost < /tmp/mysql_sec_script

mysqld --version
systemctl stop firewalld.service
systemctl disable firewalld.service
 
echo "============================MySQL 8.0.12 install completed========================="
}
 
 
 
function CheckInstall()
{
echo "===================================== Check install ==================================="
clear
ismysql=""
echo "Checking..."
 
if [ -s /usr/local/mysql/bin/mysql ] && [ -s /usr/local/mysql/bin/mysqld_safe ] && [ -s /etc/my.cnf ]; then
  echo "MySQL: OK"
  ismysql="ok"
  else
  echo "Error: /usr/local/mysql not found!!!MySQL install failed."
fi
 
if [ "$ismysql" = "ok" ]; then
echo "Install MySQL 8.0.12 completed! enjoy it."
echo "========================================================================="
netstat -ntl
else
echo "Sorry,Failed to install MySQL!"
echo "You can tail /root/mysql-install.log from your server."
fi
}
 
#The installation log
InitInstall 2>&1 | tee /root/mysql-install.log
InstallDependsAndOpt 2>&1 | tee -a /root/mysql-install.log
InstallMySQL812 > /dev/null
CheckInstall 2>&1 | tee -a /root/mysql-install.log