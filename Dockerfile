FROM sigp/lighthouse AS lighthouse
FROM sigp/lcli AS lcli
FROM ethereum/client-go:stable AS geth
FROM skylenet/ethereum-genesis-generator AS ethgen

FROM ubuntu:22.04
RUN apt-get update && apt-get -y upgrade && apt-get install -y --no-install-recommends \
  libssl-dev ca-certificates \
  curl socat iproute2 telnet wget jq \
  build-essential python3 python3-dev python3-pip gettext-base \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=lighthouse /usr/local/bin/lighthouse /usr/local/bin/lighthouse
COPY --from=lcli /usr/local/bin/lcli /usr/local/bin/lcli
COPY --from=geth /usr/local/bin/geth /usr/local/bin/geth
COPY --from=ethgen /usr/local/bin/eth2-testnet-genesis /usr/local/bin/eth2-testnet-genesis
COPY --from=ethgen /usr/local/bin/eth2-val-tools /usr/local/bin/eth2-val-tools
COPY --from=ethgen /apps /apps

RUN cd /apps/el-gen && pip3 install -r requirements.txt

COPY genesis /opt/testnet
COPY run.sh /opt/testnet/run.sh

RUN cd /opt/testnet && make

RUN geth init /opt/testnet/build/el/geth.json && rm -f ~/.ethereum/geth/nodekey

# Work around some bugs in lcli where the default path is always used.
RUN mkdir -p /root/.lighthouse && cd /root/.lighthouse && ln -s /opt/testnet/build/cl/testnet

ENTRYPOINT ["/opt/testnet/run.sh"]
