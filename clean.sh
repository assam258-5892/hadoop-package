#!/bin/bash

cd "${HADOOP_BASE}"
pgrep -f proc_hiveserver2 | xargs kill -9
pgrep -f proc_nodemanager | xargs kill -9
pgrep -f proc_resourcemanager | xargs kill -9
pgrep -f proc_secondarynamenode | xargs kill -9
pgrep -f proc_datanode | xargs kill -9
pgrep -f proc_namenode | xargs kill -9
pgrep -f postgres | xargs kill -9
rm -rf /tmp/hadoop-*
cd "hadoop"
rm -rf hadoop/logs hive/logs nodes pgdata tmp
