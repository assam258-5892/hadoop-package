#!/bin/bash

export HADOOP_HOME="${HADOOP_BASE}/hadoop/hadoop"
export HIVE_HOME="${HADOOP_BASE}/hadoop/hive"
export PGDATA="${HADOOP_BASE}/hadoop/pgdata"

if [ -z "${DATALAKE_HADOOP_HOST}" ]; then
    export DATALAKE_HADOOP_HOST="localhost"
fi

sh "${HADOOP_BASE}/hadoop/clean.sh"

cd "${HADOOP_BASE}/hadoop"
mkdir ${HIVE_HOME}/logs
pg_ctl init -D "${PGDATA}"
echo "listen_addresses = '*'"                                                >>"${PGDATA}/postgresql.conf"
echo "host    all             all             0.0.0.0/0               trust" >>"${PGDATA}/pg_hba.conf"
pg_ctl start -D "${PGDATA}" -l "${PGDATA}/logfile"
psql postgres -c "create user hadoop"
psql postgres -c "create database hadoop"
psql postgres -c "create database hive"
"${HADOOP_HOME}/bin/hdfs" namenode -format
"${HADOOP_HOME}/sbin/start-dfs.sh"
"${HADOOP_HOME}/sbin/start-yarn.sh"
"${HADOOP_HOME}/bin/hdfs" dfs -mkdir     /tmp
"${HADOOP_HOME}/bin/hdfs" dfs -mkdir -p  /user/hive/warehouse
"${HADOOP_HOME}/bin/hdfs" dfs -chmod g+w /tmp
"${HADOOP_HOME}/bin/hdfs" dfs -chmod g+w /user/hive/warehouse
"${HADOOP_HOME}/bin/hdfs" dfs -mkdir -p  /apps/tez-0.9.2
"${HADOOP_HOME}/bin/hdfs" dfs -put tez/tez-0.9.2-minimal.tar.gz /apps/tez-0.9.2
( cd "${HIVE_HOME}"; "${HIVE_HOME}/bin/schematool" -dbType postgres -initSchema )
( cd "${HIVE_HOME}"; nohup "${HIVE_HOME}/bin/hiveserver2" >"${HIVE_HOME}/logs/logfile" 2>&1 & )
echo "HIVE 접속 : \"${HIVE_HOME}/bin/beeline\" -u jdbc:hive2://${DATALAKE_HADOOP_HOST}:10000"
