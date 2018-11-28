#!/bin/bash
# export PATH=$PATH:/bin:/sbin:/usr/sbin

if [ ! -n "$1" -o ! -n "$2" ]; then
    echo "请在脚本后输入参数： 进程端口号 目标端口号"
    exit 1
fi

id=$(netstat -tunlp | grep $1 | awk '{print $7}' | awk -F '/' '{print $1}')

echo "端口$1所属进程id为：${id}"

ip=$(lsof -p ${id}  -nP | grep TCP | awk '{print $9}' | awk -F '->' '{print $2}' | awk -F ':' '{print $1}'| sort| uniq | grep -v '^$')

for i in ${ip}; do
 #cr=$(curl -I -m 10 -o /dev/null -s -w %{http_code} http://${i}:$2/swagger-ui.html)
 #echo $i ${cr}
 nc -z -w 2 ${i} $2 >> /dev/null 2>&1
 result=$?
 if [ ${result} != 0 ]; then
	echo -e "${i}:$2 \t 端口关闭"
 else
	echo -e "${i}:$2 \t 端口开放 <-- http://${i}:$2/swagger-ui.html"
 fi
done
