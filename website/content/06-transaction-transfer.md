+++
prev = "/05-transaction-overview"
next = "07-monitoring-blockchain"
weight = 60
title = "Transfer Transactions"
toc = true
+++
This chapter will cover transfer transactions, arguably one of the most command transactions on the NEM blockchain.

As a reminder, the type of these transactions is `0x101`, or `257`.
Let's take a closer look at a transaction we have already seen in the [blockchain requests](/04-blockchain-requests#getting-a-transaction-by-its-hash-transaction-get) section, when we validated an [Apostile](https://blog.nem.io/apostille/) signature.

Here is the data returned when we request a transaction by its hash, with each field explained:

``` javascript
{
    "meta": {
        "hash": {
            //the transaction's hash
            "data": "06c19b8c53838fdaefb4a04126bc78e0c3ab90db48d8dba43f2063bb02139d69"
        }, 
        // height of the block where this transaction is stored
        "height": 1002581, 
        // id of the transaction, this is node dependent (different nodes may return different ids for the same transaction)
        "id": 667140, 
        "innerHash": {}
    }, 
    "transaction": {
        // amount transferred, in microXEMs (a millionth of 1 XEM)
        "amount": 0, 
        // deadline before which this transaction has to be confirmed
        "deadline": 60727263, 
        // fee, in microXEMs
        "fee": 18000000, 
        // the message attached to the transaction
	// type 1 is plain, 2 is secure (encrypted)
        "message": {
            "payload": "fe4e54590318b3ce5de42067de2af1da69bb082b6c05a425198f407a392cba3bdae5c3b686", 
            "type": 1
        }, 
        // recipient account of the transaction
        "recipient": "NCZSJHLTIMESERVBVKOW6US64YDZG2PFGQCSV23J", 
        // signature of the transaction, absent if multisig
        "signature": "bc7676f2ba4cb1d88110956b6b21dcf2356b2f86e47c44359a88a74d3d12e6a918fa5a920aff94af7d0984f644a51e18aa2a24bc1890cabad2f3fd2c9f79340e", 
        // public key of the account who created the account
        "signer": "826cedee421ff66e708858c17815fcd831a4bb68e3d8956299334e9e24380ba8", 
        // number of seconds elapsed since the creation of the nemesis block
        "timeStamp": 60723663, 
        // transaction type
        "type": 257, 
        // version of the data structure used
        "version": 1744830465
    }
}
```
