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
* information about multisig in multisigInfo. This account is not a multisig account
* the publicKey. As this account's public key is on the blockchain, it means it has already generated a transaction
* the [vestedBalance](https://blog.nem.io/the-beginners-guide-to-nem/#whatisavestedbalance)

As we see, this account has its public key on the blockchain. We can retrieve the exact same information using the public key of the account

### From public key (/account/get/from-public-key)
Here is the data retrieved for the same account using the public key:


{{< httpie "code/account_get_from_pk.html" >}}
