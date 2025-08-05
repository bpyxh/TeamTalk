#!/bin/bash
# this is a setup scripts for mysql
# author: luoning
# date: 08/30/2014

# setup mysql

IM_SQL=ttopen.sql
MYSQL_CONF=my.cnf
MYSQL_PASSWORD=12345

print_hello(){
	echo "==========================================="
	echo "$1 mysql for TeamTalk"
	echo "==========================================="
}

check_user() {
	if [ $(id -u) != "0" ]; then
    	echo "Error: You must be root to run this script, please use root to install mysql"
    	exit 1
	fi
}


check_run() {
	ps -ef | grep -v 'grep' | grep mysqld
	if [ $? -eq 0 ]; then
		echo "Error: mysql is running."
		exit 1
	fi
}

clean_yum() {
	YUM_PID=/var/run/yum.pid
	if [ -f "$YUM_PID" ]; then
		set -x
		rm -f YUM_PID
		killall yum
		set +x
	fi
}


build_mysql() {
	clean_yum
	yum -y install mariadb
	if [ $? -eq 0 ]; then
		echo "yum install mysql successed."
	else
		echo "Error: yum install mysql failed."
		return 1;
	fi

	clean_yum
	yum -y install mariadb-server
	if [ $? -eq 0 ]; then
		echo "yum install mysql-server successed."
	else
		echo "Error: yum install mysql-server failed."
		return 1;
	fi

	clean_yum
	yum -y install mariadb-devel
	if [ $? -eq 0 ]; then
		echo "yum install mysql-devel successed."
	else
		echo "Error: yum install mysql-devel failed."
		return 1;
	fi

	# 高版本的maridb好像没有/usr/share/mysql/my-huge.cnf，所以这里先注掉，如果有需要可以自行调整
	# if [ -f /usr/share/mysql/my-huge.cnf ]; then
	# 	cp -f /usr/share/mysql/my-huge.cnf /etc/$MYSQL_CONF
	# else
	# 	echo "Error: $MYSQL_CONF is not existed";
	# 	return 1;
	# fi
}

run_mysql() {
	PROCESS=$(pgrep mysql)
	if [ -z "$PROCESS" ]; then 
		echo "no mysql is running..." 
        
		service mariadb start

		if [ $? -eq 0 ]; then
			echo "start mysql successed."
		else
			echo "Error: start mysql failed."
			return 1
		fi
	else 
		echo "Warning: mysql is running"
	fi
}	

set_password() {
	mysql_secure_installation
}


create_database() {
	cd ./conf/
	if [ -f "$IM_SQL" ]; then
		echo "$IM_SQL existed, begin to run $IM_SQL"
	else
		echo "Error: $IM_SQL not existed."
		cd ..
		return 1
	fi

	mysql -u root -p$MYSQL_PASSWORD < $IM_SQL
	if [ $? -eq 0 ]; then
		echo "run sql successed."
		cd ..
	else
		echo "Error: run sql failed."
		cd ..
		return 1
	fi
}

build_all() {

    build_mysql
    if [ $? -eq 0 ]; then
        echo "build mysql successed."
    else
        echo "Error: build mysql failed."
        exit 1
    fi

	run_mysql
	if [ $? -eq 0 ]; then
		echo "run mysql successed."
	else
		echo "Error: run mysql failed."
		exit 1
	fi

	set_password
	if [ $? -eq 0 ]; then
		echo "set password successed."
	else
		echo "Error: set password failed."
		exit 1
	fi

	create_database
	if [ $? -eq 0 ]; then
		echo "create database successed."
	else
		echo "Error: create database failed."
		exit 1
	fi	
}


print_help() {
	echo "Usage: "
	echo "  $0 check --- check environment"
	echo "  $0 install --- check & run scripts to install"
}

case $1 in
	check)
		print_hello $1
		check_user
		check_run
		;;
	install)
		print_hello $1
		check_user
		check_run
		build_all
		;;
	*)
		print_help
		;;
esac

