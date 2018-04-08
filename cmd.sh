#!/bin/bash

function checkEnv(){
    res=`which docker-compose`
    if [ "$res"x != ""x ]; then
        return 0
    else
        return 1
    fi
}

# 1: init mongo
function initMongo(){
    echo "正在初始化MongoDB, 若失败或不小心退出请重试该步骤..."
    sudo docker-compose -f init_mongo.yml up
    echo "始化MongoDB完成!"
}

# 2: init node
function getIP(){
    ip=`cat config.js |grep -o -P "(\d+\.)(\d+\.)(\d+\.)\d+"`
    echo $ip
}

function setIP(){
    echo "是否需要重置 IP ? [y/n]"
    read ans
    if [ "$ans"x = "y"x ] || [ "$ans"x = "Y"x ]; then
        echo "请输入您的 IP 地址: "
        read ip
        setConfigJS $ip
    elif [ "$ans"x = "n"x ] || [ "$ans"x = "N"x ]; then
        echo "未修改 IP"
        return 0
    else
        echo "输入有误"
        return 1
    fi
}

function setConfigJS(){
    echo "IP 已修改为: (此处 IP 显示正确才可编译!)"
    a="var apiHost = 'http://$1:8009/';"
    sed -i "1c $a" config.js
    getIP
}

function buildWeb(){
    echo "正在编译前端代码..."
    sudo docker-compose -f build_web.yml build --no-cache
    sudo docker-compose -f build_web.yml up
}

function start(){
    echo "正在启动 x-utest 测试平台..."
    echo "启动完成后, 浏览器输入 IP:8099 访问."
    sudo docker-compose up
}

function main(){
    clear
    echo "输入对应数字选择你需要的操作:"
    echo " 1.初始化 MongoDB  2.编译前端代码  3.启动 x-utest  0.退出"
    echo "注意: 执行步骤 3 前, 请先完成步骤 1, 2"
    read select1
    case "$select1" in
        1)
            initMongo
            ;;
        2)
            echo "当前 IP 为: (此处 IP 显示正确才可编译!)"
            getIP
            setIP
            if [ $? = 0 ]; then
                echo "是否开始编译前端代码? [y/n]"
                read ans2
                if [ "$ans2"x = "y"x ] || [ "$ans2"x = "Y"x ]; then
                    buildWeb
                elif [ "$ans2"x = "n"x ] || [ "$ans2"x = "N"x ]; then
                    echo "未编译, 正在返回主菜单..."
                    return 1
                else
                    echo "输入有误, 正在返回主菜单..."
                    return 1
                fi
            else
                return $?
            fi
            ;;
        3)
            start
            ;;
        *)
            echo "exit"
            exit 1
            ;;
    esac
    sleep 3;
}

checkEnv
if [ $? = 0 ]; then
    while :
    do
        main
    done
else
    echo "请先安装 docker-compose!"
    exit $?
fi