#!/bin/bash

export HADOOP_HOME="${HADOOP_BASE}/hadoop/hadoop"
export HIVE_HOME="${HADOOP_BASE}/hadoop/hive"
export PGDATA="${HADOOP_BASE}/hadoop/pgdata"

HADOOP_VERSION="2.9.2"
HIVE_VERSION="2.3.7"
PSQL_VERSION="42.2.16"

if [ -z "${DATALAKE_HADOOP_HOST}" ]; then
    export DATALAKE_HADOOP_HOST="localhost"
fi
if [ -z "${DATALAKE_YARN_MEMORY}" ]; then
    export DATALAKE_YARN_MEMORY="8192"
fi
if [ -z "${DATALAKE_YARN_CORE}" ]; then
    export DATALAKE_YARN_CORE="4"
fi

cd "${HADOOP_BASE}"
pgrep -f proc_hiveserver2       | xargs -r kill -9
pgrep -f proc_nodemanager       | xargs -r kill -9
pgrep -f proc_resourcemanager   | xargs -r kill -9
pgrep -f proc_secondarynamenode | xargs -r kill -9
pgrep -f proc_datanode          | xargs -r kill -9
pgrep -f proc_namenode          | xargs -r kill -9
pgrep -f postgres               | xargs -r kill -9
rm -rf hadoop /tmp/hadoop-*

mkdir hadoop
cd "hadoop"
curl -s "${HADOOP_REPOSITORY}/start.sh"                                  >"start.sh"
curl -s "${HADOOP_REPOSITORY}/init.sh"                                   >"init.sh"
curl -s "${HADOOP_REPOSITORY}/clean.sh"                                  >"clean.sh"
curl -s "${HADOOP_REPOSITORY}/stop.sh"                                   >"stop.sh"
curl -s "${HADOOP_REPOSITORY}/hadoop-${HADOOP_VERSION}.tar.gz.1"         >"hadoop-${HADOOP_VERSION}.tar.gz"
curl -s "${HADOOP_REPOSITORY}/hadoop-${HADOOP_VERSION}.tar.gz.2"        >>"hadoop-${HADOOP_VERSION}.tar.gz"
curl -s "${HADOOP_REPOSITORY}/hadoop-${HADOOP_VERSION}.tar.gz.3"        >>"hadoop-${HADOOP_VERSION}.tar.gz"
curl -s "${HADOOP_REPOSITORY}/hadoop-${HADOOP_VERSION}.tar.gz.4"        >>"hadoop-${HADOOP_VERSION}.tar.gz"
curl -s "${HADOOP_REPOSITORY}/hadoop-${HADOOP_VERSION}.tar.gz.5"        >>"hadoop-${HADOOP_VERSION}.tar.gz"
curl -s "${HADOOP_REPOSITORY}/apache-hive-${HIVE_VERSION}-bin.tar.gz.1"  >"apache-hive-${HIVE_VERSION}-bin.tar.gz"
curl -s "${HADOOP_REPOSITORY}/apache-hive-${HIVE_VERSION}-bin.tar.gz.2" >>"apache-hive-${HIVE_VERSION}-bin.tar.gz"
curl -s "${HADOOP_REPOSITORY}/apache-hive-${HIVE_VERSION}-bin.tar.gz.3" >>"apache-hive-${HIVE_VERSION}-bin.tar.gz"
tar xzf "hadoop-${HADOOP_VERSION}.tar.gz"
tar xzf "apache-hive-${HIVE_VERSION}-bin.tar.gz"
mv "hadoop-${HADOOP_VERSION}"        hadoop
mv "apache-hive-${HIVE_VERSION}-bin" hive
rm -f "hadoop-${HADOOP_VERSION}.tar.gz" "apache-hive-${HIVE_VERSION}-bin.tar.gz"
echo "export JAVA_HOME=${JAVA_HOME}"                           >"${HADOOP_HOME}/etc/hadoop/hadoop-env.sh"
if [ -n "${DATALAKE_HADOOP_HEAPSIZE}" ]; then
    echo "export HADOOP_HEAPSIZE=${DATALAKE_HADOOP_HEAPSIZE}" >>"${HADOOP_HOME}/etc/hadoop/hadoop-env.sh"
fi
curl -s "${HADOOP_REPOSITORY}/conf/hadoop/hadoop-env.sh"      >>"${HADOOP_HOME}/etc/hadoop/hadoop-env.sh"
rm "${HADOOP_HOME}/etc/hadoop/yarn-env.sh"
if [ -n "${DATALAKE_YARN_HEAPSIZE}" ]; then
    echo "export YARN_HEAPSIZE=${DATALAKE_YARN_HEAPSIZE}"      >"${HADOOP_HOME}/etc/hadoop/yarn-env.sh"
fi
curl -s "${HADOOP_REPOSITORY}/conf/hadoop/yarn-env.sh"        >>"${HADOOP_HOME}/etc/hadoop/yarn-env.sh"
curl -s "${HADOOP_REPOSITORY}/conf/hadoop/core-site.xml"       >"${HADOOP_HOME}/etc/hadoop/core-site.xml"
cat                                                     <<EOF >>"${HADOOP_HOME}/etc/hadoop/core-site.xml"
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://${DATALAKE_HADOOP_HOST}:8020</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>${HADOOP_BASE}/hadoop/tmp</value>
    </property>
    <property>
        <name>hadoop.proxyuser.${USER}.groups</name>
        <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.${USER}.hosts</name>
        <value>*</value>
    </property>
</configuration>
EOF
curl -s "${HADOOP_REPOSITORY}/conf/hadoop/hdfs-site.xml"       >"${HADOOP_HOME}/etc/hadoop/hdfs-site.xml"
cat                                                     <<EOF >>"${HADOOP_HOME}/etc/hadoop/hdfs-site.xml"
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.permissions.enabled</name>
        <value>false</value>
    </property>
    <property>
        <name>dfs.namenode.rpc-bind-host</name>
        <value>0.0.0.0</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>${HADOOP_BASE}/hadoop/nodes/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>${HADOOP_BASE}/hadoop/nodes/datanode</value>
    </property>
</configuration>
EOF
curl -s "${HADOOP_REPOSITORY}/conf/hadoop/mapred-site.xml"     >"${HADOOP_HOME}/etc/hadoop/mapred-site.xml"
curl -s "${HADOOP_REPOSITORY}/conf/hadoop/yarn-site.xml"       >"${HADOOP_HOME}/etc/hadoop/yarn-site.xml"
cat                                                     <<EOF >>"${HADOOP_HOME}/etc/hadoop/yarn-site.xml"
<configuration>
    <property>
        <name>yarn.resourcemanager.scheduler.class</name>
        <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>${DATALAKE_YARN_MEMORY}</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>${DATALAKE_YARN_CORE}</value>
    </property>
</configuration>
EOF
if [ -n "${DATALAKE_HIVE_HEAPSIZE}" ]; then
    echo "export HADOOP_HEAPSIZE=${DATALAKE_HIVE_HEAPSIZE}"    >"${HIVE_HOME}/conf/hive-env.sh"
fi
curl -s "${HADOOP_REPOSITORY}/conf/hive/hive-site.xml"         >"${HIVE_HOME}/conf/hive-site.xml"
curl -s "${HADOOP_REPOSITORY}/postgresql-${PSQL_VERSION}.jar"  >"${HIVE_HOME}/lib/postgresql-${PSQL_VERSION}.jar"

sh "${HADOOP_BASE}/hadoop/init.sh"
