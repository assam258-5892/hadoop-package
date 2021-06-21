#!/bin/bash

if [ -z "${DATALAKE_HADOOP_HOST}" ]; then
    export DATALAKE_HADOOP_HOST="localhost"
fi

cd "${HADOOP_BASE}"
pg_ctl start -D "${PGDATA}" -l "${PGDATA}/logfile"
"${HADOOP_HOME}/sbin/start-dfs.sh"
"${HADOOP_HOME}/sbin/start-yarn.sh"
( cd "${HIVE_HOME}"; nohup "${HIVE_HOME}/bin/hiveserver2" >"${HIVE_HOME}/logs/logfile" 2>&1 & )
echo "HIVE 접속 : \"${HIVE_HOME}/bin/beeline\" -u jdbc:hive2://${DATALAKE_HADOOP_HOST}:10000"
