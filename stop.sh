#!/bin/bash

cd "${HADOOP_BASE}"
kill -TERM `pgrep -f org.apache.hive.service.server.HiveServer2`
"${HADOOP_HOME}/sbin/stop-yarn.sh"
"${HADOOP_HOME}/sbin/stop-dfs.sh"
pg_ctl stop -D "${PGDATA}"
