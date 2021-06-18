#!/bin/bash

export HADOOP_HOME="${HADOOP_BASE}/hadoop/hadoop"
export HIVE_HOME="${HADOOP_BASE}/hadoop/hive"
export PGDATA="${HADOOP_BASE}/hadoop/pgdata"

HADOOP_VERSION="2.9.2"
HIVE_VERSION="2.3.7"
PSQL_VERSION="42.2.16"
TOMCAT_VERSION="9.0.46"

if [ -z "${DATALAKE_HADOOP_HOST}" ]; then
    export DATALAKE_HADOOP_HOST="localhost"
fi

cd "${HADOOP_BASE}"
pkill java
pkill postgres
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
curl -s "${HADOOP_REPOSITORY}/apache-tomcat-${TOMCAT_VERSION}.tar.gz"    >"apache-tomcat-${TOMCAT_VERSION}.tar.gz"
tar xzf "hadoop-${HADOOP_VERSION}.tar.gz"
tar xzf "apache-hive-${HIVE_VERSION}-bin.tar.gz"
tar xzf "apache-tomcat-${TOMCAT_VERSION}.tar.gz"
mv "hadoop-${HADOOP_VERSION}"        hadoop
mv "apache-hive-${HIVE_VERSION}-bin" hive
mv "apache-tomcat-${TOMCAT_VERSION}" tomcat
rm -f "hadoop-${HADOOP_VERSION}.tar.gz" "apache-hive-${HIVE_VERSION}-bin.tar.gz" "apache-tomcat-${TOMCAT_VERSION}.tar.gz"
echo "export JAVA_HOME=${JAVA_HOME}"                                       >"${HADOOP_HOME}/etc/hadoop/hadoop-env.sh"
curl -s "${HADOOP_REPOSITORY}/etc-${HADOOP_VERSION}/hadoop/hadoop-env.sh" >>"${HADOOP_HOME}/etc/hadoop/hadoop-env.sh"
curl -s "${HADOOP_REPOSITORY}/etc-${HADOOP_VERSION}/hadoop/core-site.xml"  >"${HADOOP_HOME}/etc/hadoop/core-site.xml"
cat                                                                 <<EOF >>"${HADOOP_HOME}/etc/hadoop/core-site.xml"
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
curl -s "${HADOOP_REPOSITORY}/etc-${HADOOP_VERSION}/hadoop/hdfs-site.xml"  >"${HADOOP_HOME}/etc/hadoop/hdfs-site.xml"
cat                                                                 <<EOF >>"${HADOOP_HOME}/etc/hadoop/hdfs-site.xml"
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
curl -s "${HADOOP_REPOSITORY}/etc-${HADOOP_VERSION}/hadoop/mapred-site.xml"  >"${HADOOP_HOME}/etc/hadoop/mapred-site.xml"
curl -s "${HADOOP_REPOSITORY}/etc-${HADOOP_VERSION}/hadoop/yarn-site.xml"  >"${HADOOP_HOME}/etc/hadoop/yarn-site.xml"
cat                                                                 <<EOF >>"${HADOOP_HOME}/etc/hadoop/yarn-site.xml"
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
    echo "export HADOOP_HEAPSIZE=${DATALAKE_HIVE_HEAPSIZE}"                >"${HIVE_HOME}/conf/hive-env.sh"
fi
curl -s "${HADOOP_REPOSITORY}/etc-${HADOOP_VERSION}/hive/hive-site.xml"    >"${HIVE_HOME}/conf/hive-site.xml"
curl -s "${HADOOP_REPOSITORY}/postgresql-${PSQL_VERSION}.jar"              >"${HIVE_HOME}/lib/postgresql-${PSQL_VERSION}.jar"

sh "${HADOOP_BASE}/hadoop/init.sh"
