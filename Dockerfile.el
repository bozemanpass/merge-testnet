FROM skylenet/ethereum-genesis-generator AS ethgen

FROM ethereum/client-go
RUN apk add --no-cache python3 py3-pip curl wget jq build-base gettext libintl openssl bash

COPY --from=ethgen /usr/local/bin/eth2-testnet-genesis /usr/local/bin/eth2-testnet-genesis
COPY --from=ethgen /usr/local/bin/eth2-val-tools /usr/local/bin/eth2-val-tools
COPY --from=ethgen /apps /apps

RUN cd /apps/el-gen && pip3 install -r requirements.txt

COPY genesis /opt/testnet
COPY run-el.sh /opt/testnet/run.sh

RUN cd /opt/testnet && make genesis-el

RUN chmod a+x /usr/local/bin/*
RUN ls -l /usr/local/bin
RUN geth init /opt/testnet/build/el/geth.json && rm -f ~/.ethereum/geth/nodekey

ENTRYPOINT ["/opt/testnet/run.sh"]
