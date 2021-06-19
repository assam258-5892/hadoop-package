#!/bin/bash

cd "${HADOOP_BASE}"
pgrep -f proc_hiveserver2 | xargs -r kill -9
pgrep -f proc_nodemanager | xargs -r kill -9
pgrep -f proc_resourcemanager | xargs -r kill -9
pgrep -f proc_secondarynamenode | xargs -r kill -9
pgrep -f proc_datanode | xargs -r kill -9
pgrep -f proc_namenode | xargs -r kill -9
pgrep -f postgres | xargs -r kill -9
rm -rf /tmp/hadoop-*
cd "hadoop"
rm -rf hadoop/logs hive/logs nodes pgdata tmp
