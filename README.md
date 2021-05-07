# 사용법

아래의 명령들을 수행한 후, "hadoop-reinstall"을 수행하여 설치한다.

~~~
export HADOOP_REPOSITORY="file:///downloaded-directory/hadoop-package"
export HADOOP_BASE="${HOME}/Downloads"
export HADOOP_HOME="${HADOOP_BASE}/hadoop/hadoop"
export HIVE_HOME="${HADOOP_BASE}/hadoop/hive"
export PGDATA="${HADOOP_BASE}/hadoop/pgdata"
export PATH=$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH

alias hadoop-reinstall="curl -s \"${HADOOP_REPOSITORY}/hadoop-reinstall.sh\" >/tmp/hadoop-reinstall.sh; sh /tmp/hadoop-reinstall.sh"
alias hadoop-start="sh \"${HADOOP_BASE}/hadoop/start.sh\""
alias hadoop-stop="sh \"${HADOOP_BASE}/hadoop/stop.sh\""
alias beeline='beeline -u jdbc:hive2://localhost:10000'
~~~
