#!/usr/bin/bash

# ___________________________________________________________________________

source ./config.sh
export $(cut -d= -f1 config.sh)

echo -e "发布开始 .."

# ___________________________________________________________________________

echo -e "环境检查 ..."

    if [[ -n `docker ps | grep $MYSQL_NAME` ]]; then
        echo -ne "发现已有 mysql 容器在运行, \n\n\t中止 ? [yes/no] "
        read stop_mysql
        if [ $stop_mysql == "yes" ]; then
            echo -e "发现已有 mysql 容器在运行, 停止 ..."
                docker stop $MYSQL_NAME
            echo -e "现有 mysql 容器停止 完毕 ."
        else
            echo -e "发现已有 mysql 容器在运行, 用户选择不中止($stop_mysql 而非 yes), 发布中止 ."
            exit 1
        fi
    fi

    if [[ -n `docker ps | grep $VC_NAME` ]]; then
        echo -ne "发现已有 voerkacloud 容器在运行, \n\n\t中止 ? [yes/no] "
        read stop_voerkacloud
        if [ $stop_voerkacloud == "yes" ]; then
            echo -e "发现已有 voerkacloud 容器在运行, 停止 ..."
                docker stop $VC_NAME
            echo -e "现有 voerkacloud 容器停止 完毕 ."
        else
            echo -e "发现已有 voerkacloud 容器在运行, 用户选择不中止($stop_voerkacloud 而非 yes), 发布中止 ."
            exit 1
        fi
    fi

    if [ -d alpine-mysql/data ]; then
        echo -ne "发现已有数据在 $(pwd)/alpine-mysql/data，\n\n\t清除 ? [yes/no] "
        read clear_data
        if [ $clear_data == "yes" ]; then
            rm -rf alpine-mysql/data
            echo -e "现有数据清除 完毕 ."
        else
            echo -e "发现已有数据, 用户选择不清除($clear_data 而非 yes), 发布中止 ."
            exit 1
        fi
    fi

echo -e "环境检查 完毕 ."

# ___________________________________________________________________________

echo -e "获取 mysql 容器资源 ..."

    git clone https://github.com/catcuts/alpine-mysql

    if [ -z `docker images -q $MYSQL_IMAGE` ]; then
        echo -e "本地镜像不存在, 创建 ..."
        docker load < $MYSQL_ARCHIVE 
        if [ $? -eq 0 ]; then
            echo -e "本地镜像创建 完毕 ."
        else
            echo -e "本地镜像创建 失败 ! 发布中止 . 请检查配置后重试 ."
            exit 1
        fi
    else
        echo -e "本地镜像已存在 ."
    fi

echo -e "获取 mysql 容器资源 完毕 ."

# ___________________________________________________________________________

echo -e "获取 voerkacloud 容器资源 ..."

    git clone https://github.com/catcuts/alpine-voerkacloud

    if [ -z `docker images -q $VC_IMAGE` ]; then
        echo -e "本地镜像不存在，创建 ..."
        docker load < $VC_ARCHIVE 
        if [ $? -eq 0 ]; then
            echo -e "本地镜像创建 完毕 ."
        else
            echo -e "本地镜像创建 失败 ! 发布中止 . 请检查配置后重试 ."
            exit 1
        fi
    else
        echo -e "本地镜像已存在 ."
    fi

echo -e "获取 voerkacloud 容器资源 完毕 ."

# ___________________________________________________________________________

echo -e "创建到 voerkacloud 资源目录的软连接 ..."

    VC_SRC="alpine-voerkacloud/src"

    if [ -e $VC_SRC ]; then
        if [ -L $VC_SRC ]; then
            echo -e "移除原有连接 ..."
            rm -rf $VC_SRC
            echo -e "移除原有连接 完毕 ."
        else
            echo -e "资源目录已存在，且不是连接. 发布中止. 另行指定后重试 ."
            exit 1
        fi
    fi

    ln -s $VC_LOCAL_PATH $VC_SRC
    ls -l $VC_SRC

    # cd alpine-voerkacloud
    # git clone http://192.168.38.165/wxzhang/voerkacloud src
    # cd src
    # git checkout $VC_REPO_BRANCH
    # cd ..

echo -e "创建到 voerkacloud 资源目录的软连接 完毕 ."

# ___________________________________________________________________________

echo -e "启动 voerkacloud ..."

cd alpine-mysql
    
    MYSQL_RUN="\
        bash $(pwd)/run.sh \
        -c $MYSQL_NAME \
        -i $MYSQL_IMAGE \
        -w `readlink -f $(pwd)` \
        -d `readlink -f $(pwd)`/data \
        -p $MYSQL_PORT"

cd ../alpine-voerkacloud 
    
    VC_INIT="/bin/bash init.sh"

    VC_RUN="\
        bash $(pwd)/run.sh \
        -c $VC_NAME \
        -i $VC_IMAGE \
        -w `readlink -f $(pwd)` \
        -d `readlink -f $(pwd)/src` \
        -p $VC_HTTP_PORT \
        -m $MYSQL_NAME"

cd ..

$MYSQL_RUN

if [ $? -ne 0 ]; then
    echo -e "mysql 容器启动失败 ! 发布中止 . 请检查后重试 ."
    exit 1
fi

$VC_RUN -n "$VC_INIT" -u 

if [ $? -ne 0 ]; then
    echo -e "voerkacloud mysql data 初始化失败 ! 发布中止 . 请检查后重试 ."
    exit 1
fi

$VC_RUN

# ___________________________________________________________________________

echo $VC_RUN > start.sh

echo "docker stop $VC_NAME" > stop.sh

echo -e "voerkacloud 脚本已自动生成：\
\nstart.sh:\t用于启动（重启） voerkacloud \
\nstop.sh:\t用于停止 voerkacloud
"

echo -e "启动 voerkacloud 完毕 ."

echo -e "发布结束 ."

# ___________________________________________________________________________