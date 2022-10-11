# merge-testnet

## Build and Run

To start the testnet, use `docker-compose`.  By default, this will start one bootnode and two "miner" nodes.  Each node is running both `geth` and `lighthouse`.

```
$ docker compose build
$ docker compose up -d
```

## Status

When the testnet first starts, in needs to build its DAG.  This will take a couple of minutes, and its progress can be observed in the logs of a `geth` "miner" node.

After the DAG has been built, Lighthouse is started.  The Lighthouse testnet will quickly transition versions from `phase0` to `altair` to `bellatrix` over the course of a few minutes.  Additionally, the `bellatrix` state will have two distinct states: pre-Merge and post-Merge.

> With the default settings, the transition to `altair` will occur at slot 32 and `bellatrix` at slot 64.

Once Lighthouse is running, you can easily check the current version by executing:

```
$ wget -O - -q 'http://localhost:5052/eth/v2/beacon/blocks/head' | jq '.version'
"bellatrix"
```

To check if your `bellatrix` network is in the pre- or post-Merge state, look at the contents of the `ExecutionPayload` in the latest block.  The simplest member to check is the ETH1 block number. As long as this is `0`, the testnet is pre-Merge.  If the value is non-0, it is post-Merge.

```
# Pre-Merge
$ wget -O - -q 'http://localhost:5052/eth/v2/beacon/blocks/head' | jq '.data.message.body.execution_payload.block_number'
"0"

# Post-Merge
$ wget -O - -q 'http://localhost:5052/eth/v2/beacon/blocks/head' | jq '.data.message.body.execution_payload.block_number'
"541"
```

> With the default settings, the testnet will reach terminal total difficulty, triggering the Merge, somewhere around the time of slot 100.

In the logs, the transition to proof-of-stake is marked with ASCII art, and is fairly easy to spot:

```
    ,,,         ,,,                                               ,,,         ,,,
  ;"   ^;     ;'   ",                                           ;"   ^;     ;'   ",
  ;    s$$$$$$$s     ;                                          ;    s$$$$$$$s     ;
  ,  ss$$$$$$$$$$s  ,'  ooooooooo.    .oooooo.   .oooooo..o     ,  ss$$$$$$$$$$s  ,'
  ;s$$$$$$$$$$$$$$$     `888   `Y88. d8P'  `Y8b d8P'    `Y8     ;s$$$$$$$$$$$$$$$
  $$$$$$$$$$$$$$$$$$     888   .d88'888      888Y88bo.          $$$$$$$$$$$$$$$$$$
 $$$$P""Y$$$Y""W$$$$$    888ooo88P' 888      888 `"Y8888o.     $$$$P""Y$$$Y""W$$$$$
 $$$$  p"LFG"q  $$$$$    888        888      888     `"Y88b    $$$$  p"LFG"q  $$$$$
 $$$$  .$$$$$.  $$$$     888        `88b    d88'oo     .d8P    $$$$  .$$$$$.  $$$$
  $$DcaU$$$$$$$$$$      o888o        `Y8bood8P' 8""88888P'      $$DcaU$$$$$$$$$$
    "Y$$$"*"$$$Y"                                                 "Y$$$"*"$$$Y"
        "$b.$$"                                                       "$b.$$"

       .o.                   .   o8o                         .                 .o8
      .888.                .o8   `"'                       .o8                "888
     .8"888.     .ooooo. .o888oooooo oooo    ooo .oooo.  .o888oo .ooooo.  .oooo888
    .8' `888.   d88' `"Y8  888  `888  `88.  .8' `P  )88b   888  d88' `88bd88' `888
   .88ooo8888.  888        888   888   `88..8'   .oP"888   888  888ooo888888   888
  .8'     `888. 888   .o8  888 . 888    `888'   d8(  888   888 .888    .o888   888
 o88o     o8888o`Y8bod8P'  "888"o888o    `8'    `Y888""8o  "888"`Y8bod8P'`Y8bod88P"
````

## Accounts
There are several prefunded accounts:

```
$ wget -O - -q --method POST --header 'Content-Type: application/json' --body-data '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "eth_accounts",
    "params": []
}' 'localhost:8545' | jq

{
  "jsonrpc": "2.0",
  "id": 1,
  "result": [
    "0xe6ce22afe802caf5ff7d3845cec8c736ecc8d61f",
    "0xe22ad83a0de117ba0d03d5e94eb4e0d80a69c62a",
    "0xf1ac8dd1f6d6f5c0da99097c57ebf50cd99ce293",
    "0x9d2edb2b30bce41375179571944a3f92636ce1cd",
    "0x5d81e609c15e292bb8255bd9b1b2494dc0386062",
    "0x5929ad4a1d6b899065acf2a66d5eb086a2863bee"
  ]
}
```

The accounts are automatically imported into the `geth` wallet on each node locked with the `ACCOUNT_PASSWORD` specified in `docker.env` (default: `secret1212`).

Full account details are in the `genesis/accounts` directory.
