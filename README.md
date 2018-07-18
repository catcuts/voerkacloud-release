
# voercloud cloud 发布脚本

1. 配置 `nano config.sh` 示例：

    ```shell
    # 注意：实际配置中，不支持注释
    # mysql 容器名称 
    MYSQL_NAME=xxx_mysql
    # mysql 归档名称
    MYSQL_ARCHIVE_NAME=mysql:latest-alpine3.6
    # mysql 归档路径
    MYSQL_ARCHIVE=$(pwd)/alpine-mysql/$MYSQL_ARCHIVE_NAME
    # mysql 镜像名称
    MYSQL_IMAGE=catcuts/$MYSQL_ARCHIVE_NAME
    # mysql 端口
    MYSQL_PORT=3307

    # 同理
    VC_NAME=xxx_voerkacloud
    VC_ARCHIVE_NAME=voerkacloud:v1.2.python3.6.6.alpine3.7
    VC_ARCHIVE=$(pwd)/alpine-voerkacloud/$VC_ARCHIVE_NAME
    VC_IMAGE=meeyi/$VC_ARCHIVE_NAME
    VC_HTTP_PORT=8000

    # voerkacloud 资源（代码）位置
    VC_LOCAL_PATH=$(pwd)/voerkacloud

    # voerkacloud 运行配置文件位置
    VC_CONFIG_FILE=$VC_LOCAL_PATH/voerka/data/settings/for_test_run_on_192.168.110.12.yaml
    ```

2. 运行 `bash release.sh [配置文件路径]` 依照指引。