#!/bin/bash
set -ex
sh /vearch/script/config-master.sh
cat /vearch/config.toml
echo "start master"

export LD_LIBRARY_PATH=/vearch/lib/:$LD_LIBRARY_PATH
# /vearch/bin/vearch -conf /vearch/config.toml master
/vearch/bin/vearch -conf /vearch/config.toml -master ${HOSTNAME} master
