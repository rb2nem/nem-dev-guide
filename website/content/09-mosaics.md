+++
prev = "08-multisig-accounts"
next = "80-debugging"
weight = 80
title = "Namespaces and Mosaics"
toc = true
+++

NEM's mosaics are let you create and manage tokens on the NEM blockchain. These tokens can then be transferred by issuing transactions
just as with NEM's native tokens, XEMs.

A Mosaic is always created in a namespace. A namespace is analog to a domain name you register on the internet. A domain name can be 
seen as a namespace on the internet. john@example1.com and john@example2.com are distinct email addresses even though they have the same user part.
Across namespace, you can have duplicate items, but the combination of the namespace and the user part are distinct.

The same goes for namespaces and Mosaics. You first need to create a namespace on the NEM blockchain, and in that namespace you can create
your mosaic and name it (nearly) anything you want. A [detailed overview of namespaces](https://blog.nem.io/mosaics-and-namespaces-2/) is available.

A good guide is available to [create your Mosaics with NanoWallet](https://blog.nem.io/maing-namespaces-and-mosaics/) and we will not duplicate
this content here. In this section, we will focus on how you can programmatically create and manipulate NEM's Mosaics. We will do that
with [nem-library](http://www.nemlibrary).


## Namespaces

### Root namespaces

Creating a namespace with nem-library is straight-forward and [illustrated in the project's documentation](https://nemlibrary.com/guide/namespace/).
You create a ProvisionNamespaceTransaction passing the namespace to create as argument along the deadline of the transaction:

```
const namespace = "new-namespace";

const provisionNamespaceTransaction: Transaction = ProvisionNamespaceTransaction.create(
    TimeWindow.createWithDeadline(),
    namespace
);
```

The object created has this form:
```
ProvisionNamespaceTransaction {
  type: 8193,
  version: 1,
  timeWindow: 
   TimeWindow {
     deadline: LocalDateTime { _date: [Object], _time: [Object] },
     timeStamp: LocalDateTime { _date: [Object], _time: [Object] } },
  signature: undefined,
  signer: undefined,
  transactionInfo: undefined,
  rentalFee: 100000000,
  rentalFeeSink: 
   Address {
     value: 'TAMESPACEWH4MKFMBCVFERDPOOP4FK7MTDJEYP35',
     networkType: 152 },
  newPart: 'testdevguide',
  parent: undefined,
  fee: 150000 }

```
 transaction type is 8193, as listed in the [Transactions Overview](/05-transaction-overview).
The name of the namespace is under the key `newPart`. As this is a root namespace, the `parent` is undefined.
Also note that the `fee` and `rentalFee` are set. The `rentalFee` is collected in a multisig account.

{{% notice note %}}
The rentalFee is not given to the harvesters because this would encourage
harvesters to wait until they are allowed to harvest a block, include their
provision namespace transaction in that block and thus essentially getting the
namespace for free.
{{% /notice %}}


Once this transaction is created, you sign and announce it as you would any other transaction:
```
const signedTransaction = account.signTransaction(provisionNamespaceTransaction);
transactionHttp.announceTransaction(signedTransaction).subscribe( x => console.log(x));
```

When the transaction is integrated in the blockchain, your namespace is registered.


Here is the complete code:



```
import{
    NEMLibrary, NetworkTypes, Transaction, TimeWindow, ProvisionNamespaceTransaction, Account, TransactionHttp
} from "nem-library";

declare let process: any;

// Initialize NEMLibrary for TEST_NET Network
NEMLibrary.bootstrap(NetworkTypes.TEST_NET);

const privateKey: string = process.env.PRIVATE_KEY;
const account = Account.createWithPrivateKey(privateKey);
const transactionHttp = new TransactionHttp({domain: "104.128.226.60"});

const namespace = "new-namespace";

const provisionNamespaceTransaction: Transaction = ProvisionNamespaceTransaction.create(
    TimeWindow.createWithDeadline(),
    namespace
);

const signedTransaction = account.signTransaction(provisionNamespaceTransaction);
transactionHttp.announceTransaction(signedTransaction).subscribe( x => console.log(x));
```

### Sub-namespaces


Creating a sub-namespace is very similar, but you pass the subspace before the parent namespace.

```
const provisionNamespaceTransaction: Transaction = ProvisionNamespaceTransaction.create(
    TimeWindow.createWithDeadline(),
    subnamespace,
    namespace
);
```

You can add only one level of subnamespace at a time. 


### Other operations

The nem-library allows you to [check if a namespace exists](https://nemlibrary.com/guide/namespace/#how-to-know-if-a-namespace-exists) and 
[query the owner of a namespace](https://nemlibrary.com/guide/namespace/#how-to-know-the-owner-of-a-namespace). Examples are provided in the 
documentation of the project.


## Mosaics

When creating a Mosaic, you have to first define several parameters applying to it.
The first thing to define is the namespace in which the Mosaic will be defined. It has to be 
a namespace owned by the account creating the Mosaic.
The namespace has to respect this pattern:`[a-z0-9][a-z0-9'_-]*( [a-z0-9'_-]+)*`. 
This means it has to start with a lowercase letter or a digit, optionally followed by a lowercase letter, a digit or one of the characters `'_-`.
After that we can have several single-space separated groups of the same characters (lower case letter, digit or one of `'_-`).

In short it means:

* it has to start with a lowercase letter or a digit
* from the second character you can also use the characters `'`, `_` and `-`.
* from the second character you can use spaces, but not multiple subsequent spaces.
* no trailing space, i.e. a space always must be followed by another character

Some example of valid Mosaic definitions:

* `allright`
* `4llright`
* `4 llright`
* `4 llright 4 nem`

But those are invalid:

* `Allright` (uppercase)
* `all  right` (2 subsequent spaces)
* `allright!` (unsupported character)
* `allright ` (trailing space)

You can easily check your Mosaic name with a regular expression checker as [regex101](https://regex101.com/).
Enter the regular expression `[a-z0-9][a-z0-9'_-]*( [a-z0-9'_-]+)*` and enter you Mosaic name as the test string.
The whole name of your mosaic must be covered by one match. If you have more than one match or some characters not 
covered by the regexp, your name is invalid.

Accompanying the name of the Mosaic, you can provide an optional 512 character long description. All characters are
accepted in the description string.

There are also fundamental parameters that will defined your Mosaic such as:

* the initial supply, the initial number of token that will be available at creation time.
* the supply can also be marked as mutable if you want to modify the supply of your token over time.
* the transferability of your token
* the divisibility of your token, i.e the number after the decimal separator that you can specify when transfering the token.
  0 means one token can not be subdivided and can only be transfered as a whole. 1 means you can transfer a tenth of a token.


You can also decide to impose a levy or not. The levy a fee that is transfered to an account determined at mosaic definition time 
for every transfer of that mosaic.
You can decide to impose a levy in the Mosaic of your choice: 

* XEMs, which are the standard tokens on the NEM blockchain
* or your own newly defined token.

The levy is either an absolute value, independent from the amount of tokens transfered, or it can be expressed in percentile of the
number of tokens transfered. A percentile of 100 will apply 1% of the amount transferred as levy. As such, the lowest levy you can apply a
1/10000 (on ten thousandth) of the transfered amount.

When creating the Mosaic, a fee is paid to a sink address. An addressed managed by the NEM project.

### Mosaic creation

Nem-library supports the creation of Mosaics. The first step is to create a MosaicDefinition, which specifies:

* the account for which the Mosaic is created
* a MosaicId, composed  of
  * the namespace in which the Mosaic will be created
  * the Mosaic name
* a description of the Mosaic
* all properties of the Mosaic:
  * the divisibility (number)
  * the initial supply (number)
  * the transferability (boolean)
  * the supply mutability (boolean)
* the definition of the levy:
  * the type of levy (percentile or absolute)
  * the address to which the levy will be sent
  * the MosaicId in which the levy will be paid (specifyin namespace and mosaic name as above)
  * the fee value
    * if percentile, the fee paid is `amount_transfered * fee/10000`
    * if absolute, the value is the fee paid whatever the amount transfered

This translate in this code, taken from nem-library's documentation:

```
    const md = new MosaicDefinition(
        PublicAccount.createWithPublicKey(account.publicKey),
        new MosaicId("my-namespace", "my-mosaic"),
        "my test mosaic description",
        new MosaicProperties(0, 9000000, true, true),
        new MosaicLevy(
            MosaicLevyType.Percentil,
            account.address,
            new MosaicId("nem", "xem"),
            2
        )
    )
```

This defines

* a Mosaic named `my-mosaic`in the namespace `my-namespace`, with a description text
* a transferable Mosaic that is not divisible, has an initial supply of 9000000 that can be changed over time
* the levy applied to transfers of this Mosaic. The levy is paid in XEMs to the account creating the Mosaic. The amount of the levy is 2 ten-thousandths of the transfered value.


This is the resulting object  m̀d`:

```
MosaicDefinition {
  creator: 
   PublicAccount {
     address: 
      Address {
        value: 'TA6XFSJYZYAIYP7FL7X2RL63647FRMB65YC6CO3G',
        networkType: 152 },
     publicKey: '4fe5efd97360bc8a32ec105d419222eeb714e6d06fd8b895a5eedda2b0edf931' },
  id: 
   MosaicId {
     namespaceId: 'devguidetest.sub1.sub2',
     name: 'devguide-mosaic' },
  description: 'my test mosaic description',
  properties: 
   MosaicProperties {
     initialSupply: 9000000,
     supplyMutable: true,
     transferable: true,
     divisibility: 0 },
  levy: 
   MosaicLevy {
     type: 2,
     recipient: 
      Address {
        value: 'TA6XFSJYZYAIYP7FL7X2RL63647FRMB65YC6CO3G',
        networkType: 152 },
     mosaicId: MosaicId { namespaceId: 'nem', name: 'xem' },
     fee: 2 },
  metaId: undefined }


```


This MosaicDefinition instance can then be used in the creation of a `MosaicDefinitionCreationTransaction` to be advertised to the network:

```
    const mosaicDefinitionTransaction = MosaicDefinitionCreationTransaction.create(
        TimeWindow.createWithDeadline(),
        md
    );
```

The advertisement of the transaction is done as for other transaction types:

```
    const signedTransaction = account.signTransaction(mosaicDefinitionTransaction);
    transactionHttp.announceTransaction(signedTransaction).subscribe( x => console.log(x));
```

The complete code is:

```
import {
    NEMLibrary, NetworkTypes, TimeWindow, Account, TransactionHttp,
    MosaicDefinitionCreationTransaction, MosaicDefinition, PublicAccount, MosaicId, MosaicProperties, MosaicLevy,
    MosaicLevyType
} from "nem-library";

declare let process: any;

// Initialize NEMLibrary for TEST_NET Network
NEMLibrary.bootstrap(NetworkTypes.TEST_NET);

const privateKey: string = process.env.PRIVATE_KEY;
const account = Account.createWithPrivateKey(privateKey);
const transactionHttp = new TransactionHttp();
const md = new MosaicDefinition(
        PublicAccount.createWithPublicKey(account.publicKey),
        new MosaicId("devguidetest.sub1.sub2", "devguide-mosaic"),
        "mosaic description",
        new MosaicProperties(0, 9000000, true, true),
        new MosaicLevy(
            MosaicLevyType.Percentil,
            account.address,
            new MosaicId("nem", "xem"),
            2
        )
     );

const mosaicDefinitionTransaction = MosaicDefinitionCreationTransaction.create(
    TimeWindow.createWithDeadline(),
    md
);

const signedTransaction = account.signTransaction(mosaicDefinitionTransaction);
transactionHttp.announceTransaction(signedTransaction).subscribe( x => console.log(x));

```

### Modifying a Mosaic

The NEM API has the best explanation about this, and it is copied verbatim here:

There might be the need to alter a mosaic definition, either because you want to change the description or because you supplied faulty properties or faulty levy data. This is done simply by issuing another mosaic definition creation transaction as described above with the same mosaic id but different description/properties/levy. However there are some restriction when doing so:

The description can be changed at any point even if the creator does not own the entire supply.
Properties and the levy data can only be changed if the creator owns every single mosaic of that type. This is necessary to prevent the creator from secretly introducing a levy or inflating the mosaic by increasing the supply.
Keep in mind that renewing the mosaic definition costs you the creation fee again, so it is worthwhile to double check the data before issuing the transaction.

### Mosaic supply change

If you defined your Mosaic with a mutable supply, you can change the supply with a `MosaicSupplyChangeTransaction`.
You initialise such a transaction with:

* the MosaicId (namespace and Mosaic name) of the Mosaic to update
* the type of your change: increase or decrease the supply
* the change in value to apply

Here is an example creating the transaction:

```
import {
    MosaicSupplyChangeTransaction, MosaicSupplyType
} from "nem-library";

var tx = MosaicSupplyChangeTransaction.create(
    TimeWindow.createWithDeadline(),
    new MosaicId("my-namespace", "my-mosaic"),
    MosaicSupplyType.Increase,
    1000000);
```

This is the object created:

```
MosaicSupplyChangeTransaction {
  type: 16386,
  version: 1,
  timeWindow: 
   TimeWindow {
     deadline: LocalDateTime { _date: [Object], _time: [Object] },
     timeStamp: LocalDateTime { _date: [Object], _time: [Object] } },
  signature: undefined,
  signer: undefined,
  transactionInfo: undefined,
  mosaicId: 
   MosaicId {
     namespaceId: 'devguidetest.sub1.sub2',
     name: 'devguide-mosaic' },
  supplyType: 1,
  delta: 1000000,
  fee: 150000 }

```

This defines a transaction to update our mosaic, increasing its total supply by on million, resulting
in a total supply of 10000000 after it has been broadcasted and accepted by the network.


### Requesting Mosaic definition

nem-library lets you send request to the network to retrieve existing Mosaic definitions in a namespace. 
This is done with a MosaicHttp instance

```
import {
    NEMLibrary, NetworkTypes, MosaicHttp, TransactionTypes
} from "nem-library";


const mosaicHttp = new MosaicHttp();
const namespace = "devguidetest.sub1.sub2";

mosaicHttp.getAllMosaicsGivenNamespace(namespace).subscribe(mosaicDefinitions => {
	    console.log(mosaicDefinitions);
});
```
Answers to this request have this format:
```
[ MosaicDefinition {
    creator: 
     PublicAccount {
       address: [Object],
       publicKey: '4fe5efd97360bc8a32ec105d419222eeb714e6d06fd8b895a5eedda2b0edf931' },
    id: 
     MosaicId {
       namespaceId: 'devguidetest.sub1.sub2',
       name: 'devguide-mosaic' },
    description: 'my test mosaic description',
    properties: 
     MosaicProperties {
       initialSupply: 9000000,
       supplyMutable: true,
       transferable: true,
       divisibility: 0 },
    levy: MosaicLevy { type: 2, recipient: [Object], mosaicId: [Object], fee: 2 },
    metaId: 718 } ]

```

Note that these are parameters used at definition time. Changes in supply are not reflected!
Nem-library does not yet support requesting current supply. It will soon though!

### Mosaic transfers

Transfering Mosaics rather than XEMs is a bit more difficult, but still very easy.
You first initialise a `MosaicHttp` instance, which gives you the method `getMosaicTransferableWithAmount` taking a MosaicId and an amount.
The trick is that the method `getMosaicTransferableWithAmount` returns an `Observable`, requiring you to subscribe to its return value to 
have access to the transferable mosaics?

So we first need to initialise our `MosaicId`:

```
var namespace = "devguidetest.sub1.sub2"
var mosaic = "devguide-mosaic
var mosaicId = new MosaicId(namespace, mosaic);
```

This can be passed to the call to `getMosaicTransferableWithAmount`.
You subscribe on its return value to get access to the `transferable` Mosaics, which 
you can use in your code in curly braces:
```
mosaicHttp.getMosaicTransferableWithAmount( mosaicId, amount).subscribe( transferable => { ... });
```

The code in the curly braces needs to initialise a `TransferTransaction`, but for Mosaics, which is done with the method `createWithMosaics`:
It takes as arguments the timewindow for setting the deadline, the recipient address, the transferable mosaics and a message:
```
                var transferTransaction: Transaction = TransferTransaction.createWithMosaics( 
                                             TimeWindow.createWithDeadline(), 
                                             new Address("TDK4QK-F7HBHE-AFTEUR-OFMCAF-JQGBZT-SZ2ZSG-ZKZM"),
                                             [transferable],  
                                             EmptyMessage);

```

This transaction can then be signed and broadcasted as other transactions:

```
               const signedTransaction = account.signTransaction(transferTransaction);
               transactionHttp.announceTransaction(signedTransaction).subscribe( x => console.log(x));
```

The complete code for this example is:
```
import {
    NEMLibrary, NetworkTypes, Address, TransferTransaction, Transaction, TimeWindow,
    EmptyMessage, MultisigTransaction, PublicAccount, TransactionHttp, XEM, MosaicHttp, MosaicId, Account
} from "nem-library";

// Initialize NEMLibrary for TEST_NET Network
NEMLibrary.bootstrap(NetworkTypes.TEST_NET);


const privateKey: string = "$YOUR_PRIVATE_KEY";
const account = Account.createWithPrivateKey(privateKey);

const mosaicHttp = new MosaicHttp();
const transactionHttp = new TransactionHttp();

var namespace = "devguidetest.sub1.sub2"
var mosaic = "devguide-mosaic"
var amount = 1

var mosaicId = new MosaicId(namespace, mosaic);

mosaicHttp.getMosaicTransferableWithAmount( mosaicId, amount).subscribe( transferable =>  {
                var transferTransaction: Transaction = TransferTransaction.createWithMosaics( 
                                             TimeWindow.createWithDeadline(), 
					     new Address("TDK4QK-F7HBHE-AFTEUR-OFMCAF-JQGBZT-SZ2ZSG-ZKZM"), 
					     [transferable], 
					     EmptyMessage);
                // sign and broadcast
                const signedTransaction = account.signTransaction(transferTransaction);
                transactionHttp.announceTransaction(signedTransaction).subscribe( x => console.log(x));
});
```

