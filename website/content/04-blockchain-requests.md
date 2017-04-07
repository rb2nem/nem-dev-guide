+++
prev = "/03-setting-up-environment"
next = "05-transaction-overview"
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

## Getting a transaction by its hash (/transaction/get)

It is also possible got get a transaction by its hash. This is useful if you want to validate a Apostile hash.
So let's do exactly that!

Without looking at the details just yet, we will see how we can validate the NIS archive we download from [http://bob.nem.ninja/](http://bob.nem.ninja/).
At the time of writing, `nis-ncc-0.6.84.tgz` is available, together with its signature file `nis-ncc-0.6.84.tgz.sig` which has the content
```
Signatures are now published using apostille.
txId: 06c19b8c53838fdaefb4a04126bc78e0c3ab90db48d8dba43f2063bb02139d69
block: 1002581
```
We see the `txId` which is the hash of the transaction we will need to get. Let's download that transaction:
{{< httpie "code/blockchain_tx_apostile_0.6.84.html">}}

We see that the transaction we have downloaded is well from the block as advertised in the `.sig` file. 
The interesting part is the payload of the transaction, which is `fe4e54590318b3ce5de42067de2af1da69bb082b6c05a425198f407a392cba3bdae5c3b686`.
The first 10 characters, ie `FE4E545903`, indicate that it is a non-signed file hash using SHA-256 (all details are in the [Apostile Whitepaper](https://www.nem.io/ApostilleWhitePaper.pdf). Dropping this prefix leaves us with the SHA-256 of the file `nis-ncc-0.6.84.tgz`, `18b3ce5de42067de2af1da69bb082b6c05a425198f407a392cba3bdae5c3b686`.

If you want to automate this in your scripts, here's how you can extract an Apostile file hash with the help of jq:
```
http http://bigalice3.nem.ninja:7890/transaction/get?hash=06c19b8c53838fdaefb4a04126bc78e0c3ab90db48d8dba43f2063bb02139d69 | jq -r '.transaction.message.payload[10:]'
```
