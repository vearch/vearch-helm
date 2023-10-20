#!/bin/bash

set -ex
if [ ${GLOBAL_DATA:0-1} == "/" ];then
    GLOBAL_DATA=${GLOBAL_DATA:0:0-1} 
fi
if [ ${GLOBAL_LOG:0-1} == "/" ];then
    GLOBAL_LOG=${GLOBAL_LOG:0:0-1} 
fi

echo  "
[global]
  name = \"${GLOBAL_NAME}\"
  domain_name = \"master-service-${GLOBAL_NAME}\"
  data = [\"${GLOBAL_DATA}/\"]
  log = \"${GLOBAL_LOG}/\"
  level = \"${GLOBAL_LEVEL}\"
  signkey = \"${GLOBAL_SIGNKEY}\"
  skip_auth = ${GLOBAL_SKIP_AUTH}
  self_manage_etcd = ${GLOBAL_SELF_MANAGE_ETCD}
" > /vearch/config.toml

for i in $(seq 0 ${VEARCH_MASTER_NUM})
do
    if [ $i == ${VEARCH_MASTER_NUM} ];then
        break
    fi
    echo "
[[masters]]
    name = \"master-${i}\"
    address = \"master-${GLOBAL_NAME}-${i}.master-service-${GLOBAL_NAME}.${NAMESPACE}.svc.cluster.local\"
    api_port = ${VEARCH_MASTER_API_PORT}
    etcd_port = 2378
    etcd_peer_port = 2390
    etcd_client_port = 2370
    pprof_port = 6062
    monitor_port = ${VEARCH_MASTER_MONITOR_PORT}
" >> /vearch/config.toml
done

echo "
# self_manage_etcd = true,means manage etcd by yourself,need provide additional configuration
[etcd]
    #etcd server ip or domain
    address = [\"${VEARCH_ETCD_ADDRESS}\"]
    # advertise_client_urls AND listen_client_urls
    etcd_client_port = ${VEARCH_ETCD_PORT}
    # provider username and password,if you turn on auth
    user_name = \"${VEARCH_ETCD_USER}\"
    password = \"${VEARCH_ETCD_PWD}\"

[router]
    port = ${VEARCH_ROUTER_PORT}
    pprof_port = 6061
    monitor_port = ${VEARCH_ROUTER_MONITOR_PORT}

[ps]
    rpc_port = 8081
    raft_heartbeat_port = 8898
    raft_replicate_port = 8899
    heartbeat-interval = 200 #ms
    raft_retain_logs = 20000000
    raft_replica_concurrency = 1
    raft_snap_concurrency = 1
    raft_truncate_count = 20000
    engine_dwpt_num = 8
    pprof_port = 6060
    private = false
" >> /vearch/config.toml

cat /vearch/config.toml
echo "after prepare config"
