PATH := ./work/redis-git/src:${PATH}
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
STUNNEL_BIN := $(shell which stunnel)
BREW_BIN := $(shell which brew)
YUM_BIN := $(shell which yum)
APT_BIN := $(shell which apt-get)

# Main test instance
define REDIS1_CONF
daemonize yes
port 6479
pidfile work/redis1-6479.pid
logfile work/redis1-6479.log
save ""
appendonly no
client-output-buffer-limit pubsub 256k 128k 5
unixsocket $(ROOT_DIR)/work/socket-6479
unixsocketperm 777
endef

# debugSegfault instance
define REDIS2_CONF
daemonize yes
port 6480
pidfile work/redis2-6480.pid
logfile work/redis2-6480.log
save ""
appendonly no
unixsocket $(ROOT_DIR)/work/socket-6480
unixsocketperm 777
endef


# shutdown instance
define REDIS3_CONF
daemonize yes
port 6481
pidfile work/redis3-6481.pid
logfile work/redis3-6481.log
save ""
appendonly no
unixsocket $(ROOT_DIR)/work/socket-6481
unixsocketperm 777
endef

# Sentinel monitored master
define REDIS4_CONF
daemonize yes
port 6482
pidfile work/redis4-6482.pid
logfile work/redis4-6482.log
save ""
appendonly no
unixsocket $(ROOT_DIR)/work/socket-6482
unixsocketperm 777
endef

# Sentinel monitored slave
define REDIS5_CONF
daemonize yes
port 6483
pidfile work/redis5-6483.pid
logfile work/redis5-6483.log
save ""
appendonly no
slaveof 127.0.0.1 6482
unixsocket $(ROOT_DIR)/work/socket-6483
unixsocketperm 777
endef


# SENTINELS
define REDIS_SENTINEL1
port 26379
daemonize yes
sentinel monitor mymaster 127.0.0.1 6482 1
sentinel down-after-milliseconds mymaster 100
sentinel failover-timeout mymaster 100
sentinel parallel-syncs mymaster 1
pidfile work/sentinel1-26379.pid
logfile work/sentinel1-26379.log
unixsocket $(ROOT_DIR)/work/socket-26379
unixsocketperm 777
endef

define REDIS_SENTINEL2
port 26380
daemonize yes
sentinel monitor mymaster 127.0.0.1 6481 1
sentinel down-after-milliseconds mymaster 100
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 100
pidfile work/sentinel2-26380.pid
logfile work/sentinel2-26380.log
unixsocket $(ROOT_DIR)/work/socket-26380
unixsocketperm 777
endef

# CLUSTER REDIS NODES
define REDIS_CLUSTER_NODE1_CONF
daemonize yes
port 7379
cluster-node-timeout 50
pidfile work/redis-cluster-node1-7379.pid
logfile work/redis-cluster-node1-7379.log
save ""
appendonly no
cluster-enabled yes
cluster-config-file work/redis-cluster-config1-7379.conf
unixsocket $(ROOT_DIR)/work/socket-7379
unixsocketperm 777
endef

define REDIS_CLUSTER_CONFIG1
c2043458aa5646cee429fdd5e3c18220dddf2ce5 127.0.0.1:7380 master - 1434887920102 1434887920002 0 connected 12000-16383
27f88788f03a86296b7d860152f4ae24ee59c8c9 127.0.0.1:7379 myself,master - 0 0 1 connected 0-11999
2c07344ffa94ede5ea57a2367f190af6144c1adb 127.0.0.1:7382 slave c2043458aa5646cee429fdd5e3c18220dddf2ce5 1434887920102 1434887920002 2 connected
1c541b6daf98719769e6aacf338a7d81f108a180 127.0.0.1:7381 slave 27f88788f03a86296b7d860152f4ae24ee59c8c9 1434887920102 1434887920002 3 connected
vars currentEpoch 3 lastVoteEpoch 0
endef

define REDIS_CLUSTER_NODE2_CONF
daemonize yes
port 7380
cluster-node-timeout 50
pidfile work/redis-cluster-node2-7380.pid
logfile work/redis-cluster-node2-7380.log
save ""
appendonly no
cluster-enabled yes
cluster-config-file work/redis-cluster-config2-7380.conf
unixsocket $(ROOT_DIR)/work/socket-7380
unixsocketperm 777
endef

define REDIS_CLUSTER_CONFIG2
2c07344ffa94ede5ea57a2367f190af6144c1adb 127.0.0.1:7382 slave c2043458aa5646cee429fdd5e3c18220dddf2ce5 1434887920102 1434887920002 2 connected
27f88788f03a86296b7d860152f4ae24ee59c8c9 127.0.0.1:7379 master - 1434887920102 1434887920002 1 connected 0-11999
1c541b6daf98719769e6aacf338a7d81f108a180 127.0.0.1:7381 slave 27f88788f03a86296b7d860152f4ae24ee59c8c9 1434887920102 1434887920002 3 connected
c2043458aa5646cee429fdd5e3c18220dddf2ce5 127.0.0.1:7380 myself,master - 0 0 0 connected 12000-16383
vars currentEpoch 3 lastVoteEpoch 0
endef

define REDIS_CLUSTER_NODE3_CONF
daemonize yes
port 7381
cluster-node-timeout 50
pidfile work/redis-cluster-node3-7381.pid
logfile work/redis-cluster-node3-7381.log
save ""
appendonly no
cluster-enabled yes
cluster-config-file work/redis-cluster-config3-7381.conf
unixsocket $(ROOT_DIR)/work/socket-7381
unixsocketperm 777
endef

define REDIS_CLUSTER_CONFIG3
1c541b6daf98719769e6aacf338a7d81f108a180 127.0.0.1:7381 myself,slave 27f88788f03a86296b7d860152f4ae24ee59c8c9 0 0 3 connected
2c07344ffa94ede5ea57a2367f190af6144c1adb 127.0.0.1:7382 slave c2043458aa5646cee429fdd5e3c18220dddf2ce5 1434887920102 1434887920002 2 connected
c2043458aa5646cee429fdd5e3c18220dddf2ce5 127.0.0.1:7380 master - 1434887920102 1434887920002 0 connected 12000-16383
27f88788f03a86296b7d860152f4ae24ee59c8c9 127.0.0.1:7379 master - 1434887920102 1434887920002 1 connected 0-11999
vars currentEpoch 3 lastVoteEpoch 0
endef

define REDIS_CLUSTER_NODE4_CONF
daemonize yes
port 7382
cluster-node-timeout 50
pidfile work/redis-cluster-node4-7382.pid
logfile work/redis-cluster-node4-7382.log
save ""
appendonly no
cluster-enabled yes
cluster-config-file work/redis-cluster-config4-7382.conf
unixsocket $(ROOT_DIR)/work/socket-7382
unixsocketperm 777
endef

define REDIS_CLUSTER_CONFIG4
c2043458aa5646cee429fdd5e3c18220dddf2ce5 127.0.0.1:7380 master - 0 1434887920102 0 connected 12000-16383
1c541b6daf98719769e6aacf338a7d81f108a180 127.0.0.1:7381 slave 27f88788f03a86296b7d860152f4ae24ee59c8c9 0 1434887920102 3 connected
2c07344ffa94ede5ea57a2367f190af6144c1adb 127.0.0.1:7382 myself,slave c2043458aa5646cee429fdd5e3c18220dddf2ce5 0 0 2 connected
27f88788f03a86296b7d860152f4ae24ee59c8c9 127.0.0.1:7379 master - 0 1434887920102 1 connected 0-11999
vars currentEpoch 3 lastVoteEpoch 0
endef

define REDIS_CLUSTER_NODE5_CONF
daemonize yes
port 7383
cluster-node-timeout 50
pidfile work/redis-cluster-node5-7383.pid
logfile work/redis-cluster-node5-7383.log
save ""
appendonly no
cluster-enabled yes
cluster-config-file work/redis-cluster-config5-7383.conf
unixsocket $(ROOT_DIR)/work/socket-7383
unixsocketperm 777
endef

define REDIS_CLUSTER_NODE6_CONF
daemonize yes
port 7384
cluster-node-timeout 50
pidfile work/redis-cluster-node6-7384.pid
logfile work/redis-cluster-node6-7384.log
save ""
appendonly no
cluster-enabled yes
cluster-config-file work/redis-cluster-config6-7384.conf
unixsocket $(ROOT_DIR)/work/socket-7384
unixsocketperm 777
endef

define REDIS_CLUSTER_NODE7_CONF
daemonize yes
port 7385
cluster-node-timeout 50
pidfile work/redis-cluster-node7-7385.pid
logfile work/redis-cluster-node7-7385.log
save ""
requirepass foobared
appendonly no
cluster-enabled yes
cluster-config-file work/redis-cluster-config7-7385.conf
unixsocket $(ROOT_DIR)/work/socket-7384
unixsocketperm 777
endef

define REDIS_CLUSTER_CONFIG8
c2043458aa5646cee429fdd5e3c18220dddf2ce5 127.0.0.1:7580 master - 0 1434887920102 0 connected
1c541b6daf98719769e6aacf338a7d81f108a180 127.0.0.1:7581 master - 0 1434887920102 3 connected 10001-16384
2c07344ffa94ede5ea57a2367f190af6144c1adb 127.0.0.1:7582 myself,master - 0 0 2 connected 0-10000
27f88788f03a86296b7d860152f4ae24ee59c8c9 127.0.0.1:7579 master - 0 1434887920102 1 connected
vars currentEpoch 3 lastVoteEpoch 0
endef

define REDIS_CLUSTER_NODE8_CONF
daemonize yes
port 7582
cluster-node-timeout 50
pidfile work/redis-cluster-node8-7582.pid
logfile work/redis-cluster-node8-7582.log
save ""
appendonly no
cluster-enabled yes
cluster-config-file work/redis-cluster-config8-7582.conf
endef

define STUNNEL_CONF
cert=$(ROOT_DIR)/work/cert.pem
key=$(ROOT_DIR)/work/key.pem
capath=$(ROOT_DIR)/work/cert.pem
cafile=$(ROOT_DIR)/work/cert.pem
delay=yes
pid=$(ROOT_DIR)/work/stunnel.pid
foreground = no

[stunnel]
accept = 127.0.0.1:6443
connect = 127.0.0.1:6479

endef

export REDIS1_CONF
export REDIS2_CONF
export REDIS3_CONF
export REDIS4_CONF
export REDIS5_CONF
export REDIS_SENTINEL1
export REDIS_SENTINEL2
export REDIS_CLUSTER_NODE1_CONF
export REDIS_CLUSTER_CONFIG1
export REDIS_CLUSTER_NODE2_CONF
export REDIS_CLUSTER_CONFIG2
export REDIS_CLUSTER_NODE3_CONF
export REDIS_CLUSTER_CONFIG3
export REDIS_CLUSTER_NODE4_CONF
export REDIS_CLUSTER_CONFIG4
export REDIS_CLUSTER_NODE5_CONF
export REDIS_CLUSTER_NODE6_CONF
export REDIS_CLUSTER_NODE7_CONF
export REDIS_CLUSTER_NODE8_CONF
export REDIS_CLUSTER_CONFIG8

export STUNNEL_CONF

start: cleanup
	echo "$$REDIS1_CONF" > work/redis1-6479.conf && redis-server work/redis1-6479.conf
	echo "$$REDIS2_CONF" > work/redis2-6480.conf && redis-server work/redis2-6480.conf
	echo "$$REDIS3_CONF" > work/redis3-6481.conf && redis-server work/redis3-6481.conf
	echo "$$REDIS4_CONF" > work/redis3-6482.conf && redis-server work/redis3-6482.conf
	echo "$$REDIS5_CONF" > work/redis2-6483.conf && redis-server work/redis2-6483.conf
	echo "$$REDIS_SENTINEL1" > work/sentinel1-26379.conf && redis-server work/sentinel1-26379.conf --sentinel
	@sleep 0.5
	echo "$$REDIS_SENTINEL2" > work/sentinel2-26380.conf && redis-server work/sentinel2-26380.conf --sentinel

	echo "$$REDIS_CLUSTER_CONFIG1" > work/redis-cluster-config1-7379.conf
	echo "$$REDIS_CLUSTER_CONFIG2" > work/redis-cluster-config2-7380.conf
	echo "$$REDIS_CLUSTER_CONFIG3" > work/redis-cluster-config3-7381.conf
	echo "$$REDIS_CLUSTER_CONFIG4" > work/redis-cluster-config4-7382.conf
	echo "$$REDIS_CLUSTER_CONFIG8" > work/redis-cluster-config8-7582.conf

	echo "$$REDIS_CLUSTER_NODE1_CONF" > work/redis-cluster-node1-7379.conf && redis-server work/redis-cluster-node1-7379.conf
	echo "$$REDIS_CLUSTER_NODE2_CONF" > work/redis-cluster-node2-7380.conf && redis-server work/redis-cluster-node2-7380.conf
	echo "$$REDIS_CLUSTER_NODE3_CONF" > work/redis-cluster-node3-7381.conf && redis-server work/redis-cluster-node3-7381.conf
	echo "$$REDIS_CLUSTER_NODE4_CONF" > work/redis-cluster-node4-7382.conf && redis-server work/redis-cluster-node4-7382.conf
	echo "$$REDIS_CLUSTER_NODE5_CONF" > work/redis-cluster-node5-7383.conf && redis-server work/redis-cluster-node5-7383.conf
	echo "$$REDIS_CLUSTER_NODE6_CONF" > work/redis-cluster-node6-7384.conf && redis-server work/redis-cluster-node6-7384.conf
	echo "$$REDIS_CLUSTER_NODE7_CONF" > work/redis-cluster-node7-7385.conf && redis-server work/redis-cluster-node7-7385.conf
	echo "$$REDIS_CLUSTER_NODE8_CONF" > work/redis-cluster-node8-7582.conf && redis-server work/redis-cluster-node8-7582.conf
	echo "$$STUNNEL_CONF" > work/stunnel.conf
	which stunnel4 >/dev/null 2>&1 && stunnel4 work/stunnel.conf || stunnel work/stunnel.conf


cleanup: stop
	- mkdir -p work
	rm -f work/redis-cluster-node*.conf 2>/dev/null
	rm -f work/*.rdb work/*.aof work/*.conf work/*.log 2>/dev/null
	rm -f *.aof
	rm -f *.rdb

ssl-keys:
	- mkdir -p work
	- rm -f work/keystore.jks
	openssl genrsa -out work/key.pem 4096
	openssl req -new -x509 -key work/key.pem -out work/cert.pem -days 365 -subj "/O=lettuce/ST=Some-State/C=DE/CN=lettuce-test"
	chmod go-rwx work/key.pem
	chmod go-rwx work/cert.pem
	$$JAVA_HOME/bin/keytool -importcert -keystore work/keystore.jks -file work/cert.pem -noprompt -storepass changeit

stop:
	pkill stunnel || true
	pkill redis-server && sleep 1 || true
	pkill redis-sentinel && sleep 1 || true

test-coveralls:
	make start
	mvn -B -DskipTests=false clean compile test jacoco:report coveralls:report
	make stop

test: start
	mvn -B -DskipTests=false clean compile test
	make stop

prepare: stop

ifndef STUNNEL_BIN
ifeq ($(shell uname -s),Linux)
ifdef APT_BIN
	sudo apt-get install -y stunnel
else

ifdef YUM_BIN
	sudo yum install stunnel
else
	@echo "Cannot install stunnel using yum/apt-get"
	@exit 1
endif

endif

endif

ifeq ($(shell uname -s),Darwin)

ifndef BREW_BIN
	@echo "Cannot install stunnel because missing brew.sh"
	@exit 1
endif

	brew install stunnel

endif

endif
	[ ! -e work/redis-git ] && git clone https://github.com/antirez/redis.git --branch unstable --single-branch work/redis-git && cd work/redis-git|| true
	[ -e work/redis-git ] && cd work/redis-git && git fetch && git merge origin/master || true
	make -C work/redis-git clean
	make -C work/redis-git -j4

clean:
	rm -Rf work/
	rm -Rf target/

release:
	mvn release:clean
	mvn release:prepare -Psonatype-oss-release
	mvn release:perform -Psonatype-oss-release
	ls target/checkout/target/*-bin.zip | xargs gpg -b -a
	ls target/checkout/target/*-bin.tar.gz | xargs gpg -b -a
	cd target/checkout && mvn site:site && mvn -o scm-publish:publish-scm -Dgithub.site.upload.skip=false

apidocs:
	mvn site:site
	./apidocs.sh

