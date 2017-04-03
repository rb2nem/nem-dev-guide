+++
prev = "/03-setting-up-environment"
next = "/99-references"
weight = 40
title = "Blockchain requests"
toc = true
+++

In this chapter we'll send [blockchain related requests](http://bob.nem.ninja/docs/#block-chain-related-requests) to our NIS instance on the testnet.

## Current chain height (/chain/height)

The response to this request just contains the height of the blockchain as known by our NIS instance.
If you repeat this query just after starting your node, you will see the height returned vary rapidly.
Note that it takes some time for your NIS instance to got through the whole blockchain after start up.l v 

Here is a sample run:

{{< httpie "code/blockchain_height.html" >}}


## Getting the last block (/chain/last-block)

The response to this request holds the last block known by the NIS instance interrogated.

{{< httpie "code/blockchain_last_block.html" >}}

However, as is the case here, the probability to get an empty list of transactions on the testnet is quite high.
We can repeat this query on the mainnet, using [another server](http://chain.nem.ninja/#/nodes) than the one running in our docker container:

{{< httpie "code/blockchain_last_block_main.html" >}}

We will take a closer look to the transaction data in a later section.

## Getting a block at height (POST /block/at/public)

You can request a block at a particular height. Not that this is a POST request, with a JSON payload of the form
```
{ height: $block_height }
```

Here is an example query:
{{< httpie "code/blockchain_block_at.html" >}}
