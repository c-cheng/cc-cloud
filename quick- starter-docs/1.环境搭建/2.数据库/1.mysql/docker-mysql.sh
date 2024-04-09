#!/bin/bash

ContainerName=mysql #容器名称，可自定义
ImageVersion=mysql:8.3.0 #镜像版本，即安装的mysql的版本
Port=3306:3306 #端口映射
DataPath=/opt/docker/mysql/data:/var/lib/mysql #数据目录映射
LogPath=/opt/docker/mysql/log:/var/log/mysql #日志目录映射
ConfPath=/opt/docker/mysql/conf.d:/etc/mysql/conf.d #配置目录映射
MYSQL_ROOT_PASSWORD=cchengtop # 默认root密码映射
TZ=Asia/Shanghai #容器使用上海时区，否则默认使用utc，会比北京时间晚8小时

# 创建容器，如果镜像不存在则自动拉取镜像
function run()
{
  echo "run $ContainerName"
	PID=`docker container ls |grep $ContainerName| grep -v grep | awk '{print $9}'`
	if [ x"$PID" != x"" ]; then
	    echo "$ContainerName is running..."
	else
	    docker run \
	    --name $ContainerName \
      -p $Port \
      -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
      -e TZ=$TZ \
      -v $DataPath \
      -v $LogPath \
      -v $ConfPath \
      -d $ImageVersion
	fi
}

# 启动已有容器
function start()
{
	echo "start $ContainerName"
	PID=`docker container ls |grep $ContainerName| grep -v grep | awk '{print $9}'`
	if [ x"$PID" != x"" ]; then
	    echo "$ContainerName is running..."
	else
	    docker start  $ContainerName 
	fi
}

# 停止容器
function stop()
{
  echo "stop $ContainerName"
  PID=""
  query(){
    PID="`docker container ls |grep $ContainerName| grep -v grep | awk '{print $9}'`"
  }
  query
  if [ x"$PID" != x"" ]; then
    docker stop  $ContainerName 
    echo "$ContainerName (pid:$PID) exiting..."
    while [ x"$PID" != x"" ]
      do
        sleep 1
        query
      done
    echo "$ContainerName exited."
  else
    echo "$ContainerName already stopped."
  fi
}

# 删除容器
function rm()
{
  echo "rm $ContainerName"
	PID=""
	query(){
		PID="`docker container ls |grep $ContainerName| grep -v grep | awk '{print $9}'`"
	}
	query
	if [ x"$PID" != x"" ]; then
		docker rm -f  $ContainerName 
		echo "$ContainerName (pid:$PID) exiting..."
		while [ x"$PID" != x"" ]
		do
			sleep 1
			query
		done
		echo "$ContainerName exited."
	else
		docker rm -f  $ContainerName
		echo "$ContainerName already stopped."
	fi
}

# 重启容器，先stop后start
function restart()
{
  stop
  sleep 2
  start
}

# 查询容器是否正在运行
function status()
{
  PID=`docker container ls |grep $ContainerName| grep -v grep | awk '{print $9}'`
  if [ x"$PID" != x"" ];then
    echo "$ContainerName is running..."
  else
      echo "$ContainerName is not running..."
  fi
}

if [ "$1" = "" ];
then
    echo -e "\033[0;31m 未输入操作名 \033[0m  \033[0;34m {run|start|stop|rm|restart|status} \033[0m"
    exit 1
fi

case $1 in
    run)
    run;;
    start)
    start;;
    stop)
    stop;;
    rm)
    rm;;
    restart)
    restart;;
    status)
    status;;
    *)

esac
