+++
prev = "07-monitoring-blockchain"
next = "09-mosaics"
weight = 80
title = "Managing and using multisig accounts"
toc = true
+++

When an account is created, it is unisig, meaning that it is fully independant, and controls its funds independently from other accounts.
A multisig account on the other hand, does not have control over its funds and assets. Only the cosignatories of the multisig can 
initiate transactions for the account, as illustrated in [the transfer transactions section](/06-transaction-transfer/#multisig-transactions).

A multisig account is labeled as n-of-m, meaning to m cosignatories have been added, and that at least the quorim of n of them have to accept a transaction 
for it to be included in the blockchain.

Cosignatories can be added (one or multiple at a time), removed (one at a time) and the quorum of cosignatories can be modified.

Note that to remove a cosignatory, the cosignatory removed is not allowed required to accept the transaction in case of a n-of-n account! 
This means that a 2-of-2 account can be converted to a 1-of-1 account by any of the cosignatories. Keep that in mind, when creating a
multisig account!

An account with a quorum of 0 means all cosignatories have to sign a transaction.

## Converting to multisig

Before converting an account to multisig, you need ensure to be sure it holds enough XEMs to pay for the conversion fee. The cosignatories
must have initiated confirmed transaction in the past so that their public keys are published on the blockchain.

From the nem api documentation, the fee is `10 + 6 * number of modifications + 6 (if a min cosignatory change is involved)`.
As we convert a unisig account to a multisig, the number of minimum cosignatory is changing and the last part applies.
For example, to convert an account to a 2-of-3 multisig, the fee will be: 10 + 3 * 6 + 6 = 34. The account converted to 2-of-3 multisig
must hold at least 34 XEMs. Fees will evolve with the price of XEMS. Always check the latest info in the official NEM documentation, and
edit this page (link in top right corner) if updates are required.

We will look at an example provided by [nem-library](http://nemlibrary.com). It is coded in Typescript and uses nemlibrary.
First all required classes are imported:

```
import {
    AccountHttp, NEMLibrary, NetworkTypes, Address, Account, TransferTransaction, TimeWindow,
    EmptyMessage, MultisigTransaction, PublicAccount, TransactionHttp, XEM, MultisigAggregateModificationTransaction,
    CosignatoryModification, CosignatoryModificationAction
} from "nem-library";
```

With everything imported, we can bootstrap the network (here the testnet) and specify which NIS we want to send the transaction to:

```
nemlibrary.bootstrap(networktypes.test_net);
const transactionhttp = new TransactionHttp({domain: "104.128.226.60"});
```

The nem-library examples use environment variables to set key parameters. In your own code you can replace
`process.env.XXX` by a string `"my_key"` whose value is the key.
`PRIVATE_KEY` is the private key of the account converted to multisig. For cosignatories,
the public key has to be provided.
```
const privateKey: string = process.env.PRIVATE_KEY;
const cosignatory1PublicKey: string = process.env.COSIGNATORY_1_PUBLIC_KEY;
const cosignatory2PublicKey: string = process.env.COSIGNATORY_2_PUBLIC_KEY;
```

Once all parameters have been set, we can create the transaction that will convert our account into multisig.
The first argument is a [timewindow](https://nemlibrary.com/guide/overview/), setting the deadline of the transaction.
The second argument is an array holding the cosignatories modification. In our case, as we convert an account to multisig,
we only add cosignatories.
The last argument is the number of cosignatories required to accept a transaction for it to be committed to the blockchain.

```
const convertIntoMultisigTransaction = MultisigAggregateModificationTransaction.create(
    TimeWindow.createWithDeadline(),
    [
        new CosignatoryModification(cosignatory1, CosignatoryModificationAction.ADD),
        new CosignatoryModification(cosignatory2, CosignatoryModificationAction.ADD),
    ],
    2
);

```

At this time, all that's left to do is sign the transaction and announce it to the network.
```
const signedTransaction = account.signTransaction(convertIntoMultisigTransaction);
transactionHttp.announceTransaction(signedTransaction).subscribe(x => console.log(x));
```

Once this transaction is included in the blockchain, the converted account is a multisig account. That means
transactions from that account can only be initiated by a cosignatory.

Here is the complete code:

```
import {
    AccountHttp, NEMLibrary, NetworkTypes, Address, Account, TransferTransaction, TimeWindow,
    EmptyMessage, MultisigTransaction, PublicAccount, TransactionHttp, XEM, MultisigAggregateModificationTransaction,
    CosignatoryModification, CosignatoryModificationAction
} from "nem-library";

// Initialize NEMLibrary for TEST_NET Network
nemlibrary.bootstrap(networktypes.test_net);

const transactionhttp = new TransactionHttp({domain: "104.128.226.60"});

// Replace with the private key of the account that you want to convert into multisig
const privateKey: string = process.env.PRIVATE_KEY;
const cosignatory1PublicKey: string = process.env.COSIGNATORY_1_PUBLIC_KEY;
const cosignatory2PublicKey: string = process.env.COSIGNATORY_2_PUBLIC_KEY;

const account = Account.createWithPrivateKey(privateKey);

const cosignatory1 = PublicAccount.createWithPublicKey(cosignatory1PublicKey);
const cosignatory2 = PublicAccount.createWithPublicKey(cosignatory2PublicKey);

const convertIntoMultisigTransaction = MultisigAggregateModificationTransaction.create(
    TimeWindow.createWithDeadline(),
    [
        new CosignatoryModification(cosignatory1, CosignatoryModificationAction.ADD),
        new CosignatoryModification(cosignatory2, CosignatoryModificationAction.ADD),
    ],
    2
);

const signedTransaction = account.signTransaction(convertIntoMultisigTransaction);

transactionHttp.announceTransaction(signedTransaction).subscribe(x => console.log(x));
```


## Modifying the multisig

Once an account is converted to multisig, it cannot itself initiate a transaction, only a cosignatory can,
as already illustrated in the [transfer transactions](/06-transaction-transfer) section. The same applies for
changes to the multisig account like the number of cosignatories (adding and removing), or the minimum number
of signatures required.

Hence, to modify a multisig account, one of the cosignatories has to initiate a `MultisigAggregateModificationTransaction`,
which will add or remove cosignatories, wrap it in a multisig transaction specifying the multisig account it applies to, 
and finally sign and send it to a NIS.

Here is how we can add a third cosignatory. 
The imports and network initialisation are identical to the previous example.
However, the private key to use is from the current cosignatory that will initiate the transaction.
And both the multisig account we modify and the cosignatory to be added are identified by their respective
public keys.




```
import { AccountHttp, NEMLibrary, NetworkTypes, Address, Account, TransferTransaction, TimeWindow, EmptyMessage, MultisigTransaction, PublicAccount, TransactionHttp, XEM, MultisigAggregateModificationTransaction, CosignatoryModification, CosignatoryModificationAction } from "nem-library";

// private key of current cosignatory initiating the transaction
const privateKey: string = "current_cosignatory_private_key";
// public key of the cosignatory to be added
const cosignatory3PublicKey: string = "3eee54c75945d22500f1c6844b175b9efc9db171e2e941704fa396dc6ecd2ffd";
// public key of the multisig account we modify
const multisigPublicKey: string = "2382b88894b9697b227125fbaff8069dd41c75ed279c841781e1bea389fe488d";


// Initialize NEMLibrary for TEST_NET Network
NEMLibrary.bootstrap(NetworkTypes.TEST_NET);

const transactionHttp = new TransactionHttp({domain: "localhost"});

const account = Account.createWithPrivateKey(privateKey);

const cosignatory3 = PublicAccount.createWithPublicKey(cosignatory3PublicKey);

```

We then create a `MultisigAggregateModificationTransaction` similarly to the previous example.
We add the new cosignatory, and increase the minimum number of signature required by the multisig account by 1.

```
const cosignatory3 = PublicAccount.createWithPublicKey(cosignatory3PublicKey);

const modifyMultisigTransaction = MultisigAggregateModificationTransaction.create(
    TimeWindow.createWithDeadline(),
    [
        new CosignatoryModification(cosignatory3, CosignatoryModificationAction.ADD),
    ],
    1
);
```

This transaction has to be broadcasted in the name of the multisig account, but the multisig account cannot 
initiate a transaction itself. We have to wrap it in a multisig account. The last argument for which multisig account
this transaction is initiate:

```
const multisigTransaction: MultisigTransaction = MultisigTransaction.create(
    TimeWindow.createWithDeadline(),
    modifyMultisigTransaction,
    PublicAccount.createWithPublicKey(multisigPublicKey)
);



```

This transaction can now be signed by a current cosignatory, and sent to NIS:
```
const signedTransaction = account.signTransaction(multisigTransaction);
transactionHttp.announceTransaction(signedTransaction).subscribe(x => console.log(x));
```

Here is the complete code:

```
import { AccountHttp, NEMLibrary, NetworkTypes, Address, Account, TransferTransaction, TimeWindow, EmptyMessage, MultisigTransaction, PublicAccount, TransactionHttp, XEM, MultisigAggregateModificationTransaction, CosignatoryModification, CosignatoryModificationAction } from "nem-library";

// private key of current cosignatory initiating the transaction
const privateKey: string = "current_cosignatory_private_key";
// public key of the cosignatory to be added
const cosignatory3PublicKey: string = "3eee54c75945d22500f1c6844b175b9efc9db171e2e941704fa396dc6ecd2ffd";
// public key of the multisig account we modify
const multisigPublicKey: string = "2382b88894b9697b227125fbaff8069dd41c75ed279c841781e1bea389fe488d";


// Initialize NEMLibrary for TEST_NET Network
NEMLibrary.bootstrap(NetworkTypes.TEST_NET);

const transactionHttp = new TransactionHttp({domain: "localhost"});

const account = Account.createWithPrivateKey(privateKey);

const cosignatory3 = PublicAccount.createWithPublicKey(cosignatory3PublicKey);

const modifyMultisigTransaction = MultisigAggregateModificationTransaction.create(
    TimeWindow.createWithDeadline(),
    [
        new CosignatoryModification(cosignatory3, CosignatoryModificationAction.ADD),
    ],
    1
);

// wrap in a multisig transaction

const multisigTransaction: MultisigTransaction = MultisigTransaction.create(
    TimeWindow.createWithDeadline(),
    modifyMultisigTransaction,
    PublicAccount.createWithPublicKey(multisigPublicKey)
);



const signedTransaction = account.signTransaction(multisigTransaction);

transactionHttp.announceTransaction(signedTransaction).subscribe(x => console.log(x));
```

## Signing multisig transactions

When using a multisig account, you will not only want to initiate transactions like we did in the [transfer transactions section](06-transaction-transfer/#multisig-transactions), you will also want to sign transactions initiated by others. That is what we will do in this section, using nem-library.

We will write a script that will 
* get all unconfirmed transaction from the multisig account
* filter to keep only the multisig transactions
* filter to keep only the transactions pending to be signed and not having our signature yet present

For each of these transactions, it will 
* create a MultisigSignatureTransaction instance for the transaction
* sign it, which will add us in the signers that have accepted the transaction
* send it to the network. 

All these steps are done by chaining calls to functions working on the array of transactions we receive.
These functions take as argument a function that will be applied to each element of the array, and return a new array, on which the next
function can be called.
Calling `filter` on a array will return an array containing only elements for which the function passed as argument returns true. 
For example, calling this on an array of transactions will return an array holding only the multisig transactions:
```
my_array.filter(transaction => transaction.type == TransactionTypes.MULTISIG)
``` 

The function `map` will map each element of the array to the result of the call of the function passed as argument. This means the array returned
has the same lenght as the array on which the function `map` is called.

For example, this call on an array of transactions will sing the transactions, and return an array of signed transactions:
```
my_array.map(transaction => signer.signTransaction(transaction))
```

With these explanations, you should be able to understand the following code. The interesting code is after the comment `handle unconfirmed transactions`.
```
import {Account, MultisigTransaction, TimeWindow, Transaction, TransactionTypes, AccountHttp, Address, NEMLibrary, NetworkTypes, MultisigSignatureTransaction, Transact
ionHttp} from "nem-library";

NEMLibrary.bootstrap(NetworkTypes.TEST_NET);

const accountHttp = new AccountHttp();
const transactionHttp = new TransactionHttp({domain: "localhost"});

// signer1
const signerKey:string = "SIGNER_PRIVATE_KEY";
const signerPubKey:string = "61a2896696fef452d001299f279567aacc79706c2b2c899f9dec70e0b92eb6b6"
const multisigAddress:string = "TARZB5-LXSVCB-3PO52A-JU2TBS-6TAONI-NY5AIF-LPWH";
const signer = Account.createWithPrivateKey(signerKey);

//--------------------------------
// handle unconfirmed transactions
//--------------------------------
accountHttp.unconfirmedTransactions(new Address(multisigAddress))
    // flatten array so we work with Transactions, and not arrays
    .flatMap(x => x)
    // keep only multisig transactions
    .filter(transaction => transaction.type == TransactionTypes.MULTISIG)
    // keep only pending to sign transaction that don't have our signature
    .filter((transaction: MultisigTransaction)  => transaction.isPendingToSign()
                           && transaction.signatures
                           && ! transaction.signatures.map( (s:MultisigSignatureTransaction) => { return s.signer.publicKey}).some((s:string , index,array) => { return
 s==signerPubKey})
    )
    // create for each transaction selected a MultisigSignatureTransaction
    .map((transaction: MultisigTransaction): MultisigSignatureTransaction => MultisigSignatureTransaction.create(
        TimeWindow.createWithDeadline(),
        transaction.otherTransaction.signer!.address,
        transaction.hashData!
    ))
    // sign the MultisigSignatureTransaction
    .map(transaction => signer.signTransaction(transaction))
    // announce the signed transaction
    .map(signedTransaction => transactionHttp.announceTransaction(signedTransaction))
    // then print the result
    .subscribe(result => {
        // Listen the success
        console.log("success");
        console.log(result);
    }, err => {
        // Know if something has gone wrong
        console.log("error");
        console.error(err)
    });

```
