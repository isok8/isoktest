#!/bin/bash

[ -f /etc/init.d/functions ]&& . /etc/init.d/functions

###Check if user is root
if [ $UID -ne 0 ]; then
    echo "Error: You must be root to run this script, please use root to install"
    exit 1
fi

clear
echo "========================================================================="
echo "A tool to auto-compile & install MySQL 5.7.24 on Redhat/CentOS Linux "
echo "========================================================================="

#set mysql root password
    echo "==========================="
        mysqlrootpwd="$1"
        if [ "$1" = "" ]; then
                mysqlrootpwd="rootmysql"
        fi

#which MySQL Version do you want to install?
echo "==========================="

    isinstallmysql57="5.7.24"
    echo "Install MySQL 5.7.24,Please input y"
    read -p "(Please input y , n):" 
# Initialize  the installation related content.
    #Delete Old Mysql program
    rpm -qa|grep mysql
    rpm -e mysql

cat >>/etc/security/limits.conf<<EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF

echo "fs.file-max=65535" >> /etc/sysctl.conf

echo "============================Install MySQL 5.7.24=================================="

#Backup old my.cnf
#rm -f /etc/my.cnf
if [ -s /etc/my.cnf ]; then
    mv /etc/my.cnf /etc/my.cnf.`date +%Y%m%d%H%M%S`.bak
fi
echo "============================MySQL 5.7.24 installing…………========================="

##define mysql directory configuration variable
Datadir=/data/mysql/data
Binlogdir=/data/mysql/binlog
Logdir=/data/mysql/logs

##yum install  devel and wget mysql
yum install numactl 
##/usr/bin/wget -P /tmp https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz
sleep 2
tar xf /tmp/mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz -C /usr/local/
ln -s /usr/local/mysql-5.7.24-linux-glibc2.12-x86_64 /usr/local/mysql
grep mysql /etc/passwd
RETVAL=$?
if [ $RETVAL -ne 0 ];then
   useradd mysql -s /sbin/nologin -M
     action "mysql user added successfully" /bin/true
  else
     action " $(echo -e "\e[31;47;5m mysql user already exists\e[0m")" /bin/false
fi

if [ ! -d "$Datadir" ]
 then 
   mkdir -p  /data/mysql/data
fi

if [ ! -d "$Binlogdir" ]
 then
   mkdir -p  /data/mysql/binlog
fi

if [ ! -d "$Logdir" ]
 then
   mkdir -p  /data/mysql/logs
fi

chown -R mysql:mysql /data/mysql
chown -R mysql:mysql /usr/local/mysql

#edit /etc/my.cnf
#SERVERID=`ifconfig eth0 | grep "inet addr" | awk '{ print $2}'| awk -F. '{ print $3$4}'`
cat >>/etc/my.cnf<<EOF
[client]
port            = 3306

[mysql]
auto-rehash
prompt="\\u@\\h [\\d]>"
#pager="less -i -n -S"
#tee=/opt/mysql/query.log

[mysqld]
####: for global
user                                =mysql                         
basedir                             =/usr/local/mysql/             
datadir                             =/data/mysql/data    
server_id                           =2333306                       
port                                =3306                          
character_set_server                =utf8                          
explicit_defaults_for_timestamp     =off                           
log_timestamps                      =system                        
socket                              =/tmp/mysql.sock               
read_only                           =0                             
skip_name_resolve                   =1                             
auto_increment_increment            =1                             
auto_increment_offset               =1                             
lower_case_table_names              =1                             
secure_file_priv                    =                              
open_files_limit                    =65536                         
max_connections                     =1000                          
thread_cache_size                   =64                            
table_open_cache                    =81920                         
table_definition_cache              =4096                          
table_open_cache_instances          =64                            
max_prepared_stmt_count             =1048576                       

####: for binlog
binlog_format                       =row                           
log_bin                             =/data/mysql/binlog/mysql-bin                     
binlog_rows_query_log_events        =on                            
log_slave_updates                   =on                            
expire_logs_days                    =7                             
binlog_cache_size                   =65536                         
#binlog_checksum                    =none                         
sync_binlog                         =1                             
slave-preserve-commit-order         =ON                            

####: for error-log
log_error                           =/data/mysql/logs/error.log                      

general_log                         =off                            
general_log_file                    =/data/mysql/logs/general.log                    

####: for slow query log
slow_query_log                      =on                             
slow_query_log_file                 =/data/mysql/logs/slow.log                       
#log_queries_not_using_indexes      =on                            
long_query_time                     =1.000000                       

####: for gtid
#gtid_executed_compression_period   =1000                          
gtid_mode                           =on                             
enforce_gtid_consistency            =on                             

####: for replication
skip_slave_start                     =1                             
#master_info_repository              =table                         
#relay_log_info_repository           =table                         
slave_parallel_type                  =logical_clock                 
slave_parallel_workers               =4                             
#rpl_semi_sync_master_enabled        =1                             
#rpl_semi_sync_slave_enabled         =1                             
#rpl_semi_sync_master_timeout        =1000                          
#plugin_load_add                     =semisync_master.so            
#plugin_load_add                     =semisync_slave.so             
binlog_group_commit_sync_delay       =100                           
binlog_group_commit_sync_no_delay_count = 10                        

####: for innodb
default_storage_engine                          =innodb                    
default_tmp_storage_engine                      =innodb                    
innodb_data_file_path                           =ibdata1:1024M:autoextend  
innodb_temp_data_file_path                      =ibtmp1:12M:autoextend     
innodb_buffer_pool_filename                     =ib_buffer_pool            
innodb_log_group_home_dir                       =/data/mysql/data                        
innodb_log_files_in_group                       =3                         
innodb_log_file_size                            =1024M                     
innodb_file_per_table                           =on                        
innodb_online_alter_log_max_size                =128M                      
innodb_open_files                               =65535                     
innodb_page_size                                =16k                       
innodb_thread_concurrency                       =0                         
innodb_read_io_threads                          =4                         
innodb_write_io_threads                         =4                         
innodb_purge_threads                            =4                         
innodb_page_cleaners                            =4         
                 #   4(刷新lru脏页)
innodb_print_all_deadlocks                      =on                        
innodb_deadlock_detect                          =on                        
innodb_lock_wait_timeout                        =20                        
innodb_spin_wait_delay                          =128                       
innodb_autoinc_lock_mode                        =2                         
innodb_io_capacity                              =200                       
innodb_io_capacity_max                          =2000                      
#--------Persistent Optimizer Statistics
innodb_stats_auto_recalc                        =on                        
innodb_stats_persistent                         =on                        
innodb_stats_persistent_sample_pages            =20                        

innodb_adaptive_hash_index                      =on                        
innodb_change_buffering                         =all                       
innodb_change_buffer_max_size                   =25                        
innodb_flush_neighbors                          =1                         
#innodb_flush_method                             =                         
innodb_doublewrite                              =on                        
innodb_log_buffer_size                          =128M                      
innodb_flush_log_at_timeout                     =1                         
innodb_flush_log_at_trx_commit                  =1                         
innodb_buffer_pool_size                         =4096M                      
innodb_buffer_pool_instances                    =4
autocommit                                      =1                         
#--------innodb scan resistant
innodb_old_blocks_pct                           =37                        
innodb_old_blocks_time                          =1000                      
#--------innodb read ahead
innodb_read_ahead_threshold                     =56                        
innodb_random_read_ahead                        =OFF                       
#--------innodb buffer pool state
innodb_buffer_pool_dump_pct                     =25                        
innodb_buffer_pool_dump_at_shutdown             =ON                        
innodb_buffer_pool_load_at_startup              =ON                        

EOF

/usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql  --datadir=/data/mysql/data
Pass=$(grep 'A temporary password' /data/mysql/logs/error.log |awk  '{print $NF}')
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig  mysqld on
/etc/init.d/mysqld start
echo "export PATH=$PATH:/usr/local/mysql/bin" > /etc/profile.d/mysql.sh
source /etc/profile.d/mysql.sh
echo "============================MySQL 5.7.24 install completed========================="
ps -eo start,cmd,pid|grep mysql
/usr/local/mysql/bin/mysqladmin -uroot -p"$Pass" password $mysqlrootpwd