#!/bin/bash

cd "${HADOOP_BASE}"
pgrep -f org.apache.hive.service.server.HiveServer2 | xargs kill -TERM
"${HADOOP_HOME}/sbin/stop-yarn.sh"
"${HADOOP_HOME}/sbin/stop-dfs.sh"
