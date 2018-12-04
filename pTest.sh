#!/bin/bash
# export PATH=$PATH:/bin:/sbin:/usr/sbin

if [ ! -n "$1" -o ! -n "$2" ]; then
    echo "请在脚本后输入参数：注册中心端口号 目标服务端口号"
    exit 1
fi

PID=$(netstat -tunlp | grep $1 | awk '{print $7}' | awk -F '/' '{print $1}')

echo "端口$1所属进程PID为：${PID}"

ips=$(lsof -p ${PID}  -nP | grep TCP | awk '{print $9}' | awk -F '->' '{print $2}' | awk -F ':' '{print $1}' | grep -v '^$' | sort | uniq)

for i in ${ips}; do
 nc -z -w 2 ${i} $2 >> /dev/null 2>&1
 result=$?
 if [ ${result} != 0 ]; then
        echo -e "${i}:$2 \t 端口关闭"
 else
        swagger="http://${i}:$2/swagger-ui.html"
        cr=$(curl -I -m 10 -o /dev/null -s -w %{http_code} ${swagger})
        if [ ${cr} != 200 ]; then
           desUrl="manager - http://${i}:$2/"
        else
           desUrl="microservice - ${swagger}"
        fi
        echo -e "${i}:$2 \t 端口开放 <-- ${desUrl}"
 fi
done
