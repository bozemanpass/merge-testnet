#!/bin/bash

if [ "true" == "$RUN_BOOTNODE" ]; then 
    geth \
      --nodekeyhex="b0ac22adcad37213c7c565810a50f1772291e7b0ce53fb73e7ec2a3c75bc13b5" \
      --nodiscover \
      --ipcdisable \
      --networkid=${NETWORK_ID} \
      --netrestrict="172.16.254.0/28"  2>&1 | tee /var/log/geth_bootnode.log &
    gbpid=$!

    sleep 10

    cd /opt/testnet/cl
    ./bootnode.sh 2>&1 | tee /var/log/lighthouse_bootnode.log &
    lbpid=$!
fi


if [ "true" == "$RUN_GETH" ]; then 
    cd /opt/testnet/accounts
    ./import_keys.sh
    
    geth \
      --bootnodes="${ENODE}" \
      --allow-insecure-unlock \
      --http \
      --http.addr="0.0.0.0" \
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
      --miner.etherbase=${ETHERBASE} 2>&1 | tee /var/log/geth.log &
    gpid=$!
fi

if [ "true" == "$RUN_LIGHTHOUSE" ]; then 
    while [ 1 -eq 1 ]; do
      echo "Waiting on DAG ..."
      sleep 5
      result=`wget --no-check-certificate --quiet \
        -O - \
        --method POST \
        --timeout=0 \
        --header 'Content-Type: application/json' \
        --body-data '{ "jsonrpc": "2.0", "id": 1, "method": "eth_getBlockByNumber", "params": ["0x3", false] }' "${ETH1_ENDPOINT:-localhost:8545}" | jq -r '.result'`
       if [ ! -z "$result" ] && [ "null" != "$result" ]; then
           break
       fi
    done

    cd /opt/testnet/cl

    if [ -z "$LIGHTHOUSE_GENESIS_STATE_URL" ]; then
        ./reset_genesis_time.sh
    else
        while [ 1 -eq 1 ]; do
            echo "Waiting on Genesis time ..."
            sleep 5
            result=`wget --no-check-certificate --quiet -O - --timeout=0 $LIGHTHOUSE_GENESIS_STATE_URL | jq -r '.data.genesis_time'`
            if [ ! -z "$result" ]; then
              ./reset_genesis_time.sh $result
              break;
            fi
        done
    fi

    ./beacon_node.sh 2>&1 | tee /var/log/lighthouse_bn.log &
    lpid=$!
    ./validator_client.sh 2>&1 | tee /var/log/lighthouse_vc.log &
    vpid=$!
fi

wait $gpid $lpid $vpid $gbpid $lbpid
