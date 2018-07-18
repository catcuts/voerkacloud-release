MYSQL_NAME=xxx_mysql
MYSQL_ARCHIVE_NAME=mysql:latest-alpine3.6
MYSQL_ARCHIVE=$(pwd)/alpine-mysql/$MYSQL_ARCHIVE_NAME
MYSQL_IMAGE=catcuts/$MYSQL_ARCHIVE_NAME
MYSQL_PORT=3307

MYSQL_TIMEOUT=200

VC_NAME=xxx_voerkacloud
VC_ARCHIVE_NAME=voerkacloud:v1.2.python3.6.6.alpine3.7
VC_ARCHIVE=$(pwd)/alpine-voerkacloud/$VC_ARCHIVE_NAME
VC_IMAGE=meeyi/$VC_ARCHIVE_NAME
VC_HTTP_PORT=8000

VC_LOCAL_PATH=$(pwd)/../voerkacloud-src-v2.0.0

VC_CONFIG_FILE=$VC_LOCAL_PATH/voerka/data/settings/for_test_run_on_192.168.110.12.yaml
