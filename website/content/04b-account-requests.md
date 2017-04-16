+++
prev = "/04-blockchain-requests"
next = "05-transaction-overview"
weight = 41
title = "Account requests"
toc = true
+++

In this chapter we'll send [account related requests](http://bob.nem.ninja/docs/#account-related-requests) to our NIS instance on the testnet.

## Account data 
### From address (/account/get)
An account data can be retrieved with a GET request to `/account/get` and
passing the address in hexadecimal format, i.e. without the '-', in the
`address` parameter. Here is a succesful request:

{{< httpie "code/account_get.html" >}}

This returns the account's info:
* address
* balance in microXEMs
* the number of [harvested blocks](https://blog.nem.io/the-beginners-guide-to-nem/#whatisharvesting)
* the account's [importance](https://blog.nem.io/the-beginners-guide-to-nem/#whatisproofofimportance). Accounts need at least 10k vested NEM to be included in the importance calculation
* a label which is always null as it is currently not used
* information about multisig in multisigInfo. This account is not a multisig account.
* the publicKey. As this account's public key is on the blockchain, it means it has already generated a transaction
* the [vestedBalance](https://blog.nem.io/the-beginners-guide-to-nem/#whatisavestedbalance)

The meta information gives us info about

* if it is a multisig account (it isn't)
* if it is a cosignatory for any multisig account (it isn't)
* remoteStatus, which indicates if the account is/has a remote account for harvesting. The values can be (from [the API](http://bob.nem.ninja/docs/#accountMetaData)):
  * "REMOTE": The account is a remote account and therefore remoteStatus is not applicable for it.
  * "ACTIVATING": The account has activated remote harvesting but it is not yet active.
  * "ACTIVE": The account has activated remote harvesting and remote harvesting is active.
  * "DEACTIVATING": The account has deactivated remote harvesting but remote harvesting is still active.
  * "INACTIVE": The account has inactive remote harvesting, or it has deactivated remote harvesting and deactivation is operational.
* the harvesting status:
  * "UNKNOWN": The harvesting status of the account is not known.
  * "LOCKED": The account is not harvesting.
  * "UNLOCKED": The account is harvesting.


As we see, this account has its public key on the blockchain. We can retrieve the exact same information using the public key of the account

### From public key (/account/get/from-public-key)
Here is the data retrieved for the same account using the public key:


{{< httpie "code/account_get_from_pk.html" >}}

## Multisig accounts

The account we have retrieved above was not a multisig account. In this section we will take a look at 
the data returned for a multisig account. We will first take a look at the data returned for an account
that has been converted to a multisig account. It is not possible to initiate a transaction from the account itself,
only from the cosignatories.

Here is the data returned for a 1-of-2 multisig account:


{{< httpie "code/account_get_multisig_1_of_2.html" >}}


And here is the data returned for the 2 cosignatories, of which 1 signature is needed to validate a transaction. This means that
any of these can encode a transaction. In a N-of-M multisig account, with N>1, one of the cosignatories has to initiate the transaction,
and N-1 additional cosignatories need to sign the transaction afterwards.

We see that `account.multisigInfo` holds the number of cosignatories, and how many are required to sign a transaction for it to be accepted by the network.
The `meta.cosignatories` contains the info about the cosignatory accounts, the same info as returned by a request to `/account/get`.

Here is the first cosignatory:
{{< httpie "code/account_get_multisig_signer.html" >}}

And here is the second:
{{< httpie "code/account_get_multisig_signer2.html" >}}

We see that `meta.cosignatoryOf` gives info about the multisig account it is a cosignatory of.
