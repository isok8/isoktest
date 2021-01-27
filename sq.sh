#!/bin/bash
user=‘root’
passwd=“123456”
mycmd=“mysql -u$user -p$passwd -S /tmp/mysql.sock1”
for dbname in wg02 wg03 wg04
do
$mycmd -e “create database $dbname;”
$mycmd -e “use $dbname;create table t1(id int, name varchar(18));insert into t1 values(1,‘hehe’)”
done
EOF