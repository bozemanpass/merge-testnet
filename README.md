# merge-testnet

## Build and Run

To start the testnet, use `docker-compose`.  By default, this will start one bootnode and two "miner" nodes.  Each node is running both `geth` and `lighthouse`.

```
$ docker-compose up --build -d
```

## Status

When the testnet first starts, in needs to build its DAG.  This will take a couple of minutes, and its progress can be observed in the logs of a `geth` "miner" node.

One the DAG has completed, Lighthouse is started.  The Lighthouse testnet will quickly transition from `phase0` to `altair` to `bellatrix` states over a few minutes.  Additionally, the `bellatrix` state will have two distinct forms, pre-Merge and post-Merge.

> With the default settings, the transition to `altair` will occur at slot 32 and `bellatrix` at slot 64.

Once Lighthouse is running, you can easily check the current version by executing:

```
$ wget -O - -q 'http://localhost:5052/eth/v2/beacon/blocks/head' | jq '.version'
"bellatrix"
```

To check if your `bellatrix` network is in a pre- or post-Merge state, look at the contents of the `ExecutionPayload`.  The easiest item to check is the ETH1 block number. As long as this is `0`, the testnet is pre-Merge.  If it is non-0, it is post-Merge.

```
# Pre-Merge
$ wget -O - -q 'http://localhost:5052/eth/v2/beacon/blocks/head' | jq '.data.message.body.execution_payload.block_number'
"0"

# Post-Merge
$ wget -O - -q 'http://localhost:5052/eth/v2/beacon/blocks/head' | jq '.data.message.body.execution_payload.block_number'
"541"
```

> With the default settings, you can expect the testnet to haved reached terminal total difficulty, triggering the Merge, somewhere around slot 100.

In the Lighthouse beacon node logs, the transition to proof-of-stake is marked with ASCII art, and is fairly easy to spot:

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
