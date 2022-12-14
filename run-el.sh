#!/bin/bash

if [ "true" == "$RUN_BOOTNODE" ]; then 
    geth \
      --nodekeyhex="b0ac22adcad37213c7c565810a50f1772291e7b0ce53fb73e7ec2a3c75bc13b5" \
      --nodiscover \
      --ipcdisable \
      --networkid=${NETWORK_ID} \
      --netrestrict="172.16.254.0/28"  2>&1 | tee /var/log/geth_bootnode.log
else
    cd /opt/testnet/accounts
    ./import_keys.sh
    
    echo -n "$JWT" > /opt/testnet/build/el/jwtsecret

    geth \
      --bootnodes="${ENODE}" \
      --allow-insecure-unlock \
      --http \
      --http.addr="0.0.0.0" \
      --http.vhosts="*" \
      --http.api="eth,web3,net,admin,personal" \
      --http.corsdomain="*" \
      --authrpc.addr="0.0.0.0" \
      --authrpc.vhosts="*" \
      --authrpc.jwtsecret="/opt/testnet/build/el/jwtsecret" \
      --networkid=${NETWORK_ID} \
      --netrestrict="172.16.254.0/28" \
      --syncmode=full \
      --mine \
      --miner.threads=1 \
      --miner.etherbase=${ETHERBASE} 2>&1 | tee /var/log/geth.log
fi
