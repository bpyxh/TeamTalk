fork的版本代码和脚本有些地方不能顺利编译，我进行了一些修改。
下面是完整的编译和部署流程。
使用的开发机是腾讯云OpenCloudOS 9。

### 一、编译teamtalk
##### 1.编译mariadb库
```bash
cd TeamTalk/server/src
chmod +x make_mariadb.sh
sudo ./make_mariadb.sh
```
##### 2.编译log4cxx
```bash
chmod +x make_log4cxx.sh
sudo ./make_log4cxx.sh
```

##### 3.编译protobuf
```bash
chmod +x make_protobuf.sh
sudo ./make_protobuf.sh
```

##### 4.编译hiredis
```bash
chmod +x make_hiredis.sh
sudo ./make_hiredis.sh
```

##### 5.安装其他开发包
```bash
chmod +x make_dev_lib.sh
sudo ./make_dev_lib.sh
```
##### 6.编译teamtalk
```bash
chmod +x build.sh
./build.sh version 1 # 没有特殊情况，不用root权限
```

### 二、安装 redis 数据库

```bash
cd ../../auto_setup/redis
chmod +x setup.sh
sudo ./setup.sh
```

### 三、安装 mariadb 数据库
##### 1.安装mariadb

```bash
cd ../mariadb
chmod +x setup_centos7.sh
sudo ./setup_centos7.sh
```

上面命令执行后，会执行`mysql_secure_installation`对mariadb数据库进行初始配置。
可以进行如下选择：
```
Enter current password for root (enter for none): Press Enter
OK, successfully used password, moving on...

Switch to unix_socket authentication [Y/n] n
 ... skipping.

Change the root password? [Y/n] Y

Remove anonymous users? [Y/n] Y
 ... Success!

Disallow root login remotely? [Y/n] Y
 ... Success!

Remove test database and access to it? [Y/n] Y

Reload privilege tables now? [Y/n] Y

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.
```

##### 2.创建普通账号
```bash
# 连接mysql
mysql -uroot -p

# 创建普通账号
CREATE USER 'teamtalk'@'localhost' IDENTIFIED BY '12345';

# 设置账号权限
GRANT ALL PRIVILEGES ON *.* TO 'teamtalk'@'localhost' WITH GRANT OPTION;
```

### 四、部署TeamTalk

##### 1.复制库文件
```bash
cd ../../server/src/
chmod +x sync_lib.sh
./sync_lib.sh
```

##### 2.复制配置文件
```bash
cd ../../auto_setup/im_server/conf
# (1)
# 修改dbproxyserver.conf，把teamtalk_master_username和teamtalk_slave_username的值改成上边创建
# 的普通账号名 teamtalk

# (2)
# 修改msgserver.conf，把IpAddr1、IpAddr2修改为vps的外网ip

# (3)
# 修改loginserver.conf，把msfs字段的ip替换为vps外网ip

cd ../../../server/src
chmod +x sync_conf_to_run.sh
./sync_conf_to_run.sh
```

##### 3.启动服务
需要按特定顺序启动各个服务。

```bash
cd ../run
chmod +x restart.sh

./restart.sh db_proxy_server
./restart.sh file_server
./restart.sh msfs
./restart.sh route_server
./restart.sh login_server
./restart.sh msg_server

# http_server 可以不启动
```

---

更多编译和部署细节可以参考张小方的文档 https://cppguide.cn/pages/975322/