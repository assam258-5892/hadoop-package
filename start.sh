#!/bin/bash

cd "${HADOOP_BASE}"
pg_ctl start -D "${PGDATA}" -l "${PGDATA}/logfile"
"${HADOOP_HOME}/sbin/start-dfs.sh"
( cd "${HIVE_HOME}"; nohup "${HIVE_HOME}/bin/hiveserver2" >"${HIVE_HOME}/logs/logfile" 2>&1 & )
echo "HIVE 접속 : \"${HIVE_HOME}/bin/beeline\" -u jdbc:hive2://localhost:10000"
