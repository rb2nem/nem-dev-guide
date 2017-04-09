+++
prev = "/03-setting-up-environment"
next = "04-blockchain-requests"
weight = 35
title = "NEM Accounts"
toc = true
+++

As explained in Chapter 2 of the [Technical
Reference](http://nem.io/NEM_techRef.pdf), an account is an Ed25519
cryptographic keypair associated to a mutable state stored on the NEM
blockchain. The state of the account is modified when transactions involving it
are accepted by the network. 

An account is identified by its address, which is a base-32 encoded triplet consisting of:
* network byte: is it an address on the testnet or the mainnet?
* 160-bit hash of the public key
* 4 byte checksum, for detection of mistyped addresses

From this description we see that we can generate a new account offline, there's
no need to be connected to the network to create an account.
