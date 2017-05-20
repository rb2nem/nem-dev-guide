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

## Creating a transaction

A transaction that is send to a NIS for inclusion in the blockchain needs to be signed.
Although the process to follow is [very precisely described] (http://bob.nem.ninja/docs/#gathering-data-for-the-signature),
it is rather involved, and using a library including that feature is much easier and less error-prone.

In this section we will use the nodejs [nem-sdk](https://github.com/QuantumMechanics/NEM-sdk).
The procedure (using nem-sdk) to send a transaction includes 3 steps:
* create a transferTransaction object
* prepare the transaction for announcement on a specific network (mainnet, testnet or mijin).
* send the prepared transaction to NIS for inclusion in the blockchain.

The information required to generate a transfer transaction is:
* the private key of the sender account
* the address of the recipient, all uppercase and without hyphen
* the amount of XEMs to be sent
* the message sent with the transaction
* the address and port on which the NIS instance we will send the transaction to is listening

We define all these in variables:

``` javascript
var privateKey = "YOUR_ACCOUNT_PRIVATE_KEY";
var recipient = "TBCI2A67UQZAKCR6NS4JWAEICEIGEIM72G3MVW5S";
var amount = 10;
var message = "dev guide test transaction";
var nisURL = "http://localhost";
var nisPort = "7890";
```
As we are running the containers accompanying this guide, we send our transaction on the testnet to
the NIS instance that runs locally. The sender and recipient accounts are test accounts used for this guide.

We first instanciate the endpoint, i.e. the variable identifying the NIS instance we will contact. 
The nem-sdk has this helper function `nem.model.objects.create` to instanciate model objects. In this case
we instanciate an `endpoint` with the `nisURL`and `nisPort` defined previously:

``` javascript
var endpoint = nem.model.objects.create("endpoint")(nisURL, nisPort);
```

Transactions of any type have at least some common information to be provided. This info is place in a `common` object that
we instanciate. In our case, that object will hold the private key of the sender account under the `privateKey` property:

``` javascript
var common = nem.model.objects.get("common");
common.privateKey = privateKey;
```

We can now execute the three steps required to send a transaction. 
First a transferTransaction object is instanciate with the `recipient` address, the `amount` and the `message`:

``` javascript
var transferTransaction = nem.model.objects.create("transferTransaction")(recipient, amount, message);
```

At that time we can prepare the transaction for sending. This will prepare the transaction to be sent to NIS, including:
* setting the actual sender in case of a multisig transaction
* translate the amount in microXEMs 
* set the due time for accepting the transaction
* wrap the transaction in a multisig transaction if needed (see below for more details)

The sender of the transaction is identified by its public key, derived from its private key. The network this transaction is 
destined for is needed to automatically set the due time. 
This explains the arguments passed to the prepare method: `common` for the sender's private key, `transferTransaction` for the
transaction data, and `nem.model.network.data.testnet.id` for the network:

``` javascript
var transactionEntity = nem.model.transactions.prepare("transferTransaction")(common, transferTransaction, nem.model.network.data.testnet.id)
```

Once the transaction is prepared, it can be signed by the initiating account (which requires its private key), and sent to
 the endpoint we instanciated earlier:

``` javascript
nem.model.transactions.send(common, transactionEntity, endpoint).then(function(res) {console.log("done");});
```

If you don't count the variable initialisation, you have just 6 lines of code required to send a transaction to a NIS instance.
Here is the complete code:

``` javascript
// parameters initialisation
var privateKey = "YOUR_ACCOUNT_PRIVATE_KEY";
var recipient = "TBCI2A67UQZAKCR6NS4JWAEICEIGEIM72G3MVW5S";
var amount = 10;
var message = "dev guide test transaction";
var nisURL = "http://localhost";
var nisPort = "7890";

// endpoint initialisation
var endpoint = nem.model.objects.create("endpoint")(nisURL, nisPort);
// transaction common data initialisation
var common = nem.model.objects.get("common");
common.privateKey = privateKey;

// create transfer transaction object
var transferTransaction = nem.model.objects.create("transferTransaction")(recipient, amount, message);
// prepare transaction
var transactionEntity = nem.model.transactions.prepare("transferTransaction")(common, transferTransaction, nem.model.network.data.testnet.id)
// sign and send to NIS
nem.model.transactions.send(common, transactionEntity, endpoint).then(function(res) {console.log("done");});
```
