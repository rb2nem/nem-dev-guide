+++
next = "/02-about"
prev = "/"
weight = 10
title = "Introduction"
date = "2017-03-26T15:02:00+02:00"
toc = true

+++


## Nem Presentation

Nem is a blockchain built from scratch, learning some lessons from Bitcoin.
If you need an introduction to the blockchain concept, here is a [good visual introduction](https://anders.com/blockchain/),
 which also propose an interactive part.

Nem is providing:

* editable n-of-m multi-sig: an action in a Nem account is authorized only if n of m key identified as authorised validate it. 
  When you create your account, it is a 1-of-1 account, meaning only you need to validate any operation. It is however possible
  to modify the account to add authorised keys, and specify how many of them need to validate an operation. This can be 1-of-2,
  or 2-of-5, and can evolve over time.
* mosaic, an implementation of asset also known as colored coins.
* namespaces.
* a [client](https://www.nem.io/install.html) (on the desktop: previously NCC, currently NanoWallet; or mobile) - server (NIS, the next version of it being named Catapult) approach, easing the development of solutions on Nem as your software only has to talk to a NIS instance.
* software backed by a test suite
* Proof of Importance
* a peers reputation system
* a one minute average block time
* delegated harvesting: no need to let your own computer connected to compute blocks and reap fees, you can delegate your importance to 
  a NIS instance of your choice without risk of loosing your funds
* a currency named XEM, used to pay for fees of operations on the blockchain

These can be leveraged to build products and tools, such as [Apostille](https://blog.nem.io/apostille/), a notarisation service; or  [Landstead](http://landstead.atraurablockchain.com/#!/), a land and property registry. The NEM features enable you to rapidly deliver working products

## Integrating with Nem

At time of writing in April 2017, the Catapult rewrite of NIS is well underway. It is said to provide a mostly compatible REST API with NIS, the 
server currently available. We will thus base this guide on the REST API. That API can be accessed from any language.

## Testing net

Before you run your code on the Nem blockchain, you might want to validate it in a test environment, without having to spend real XEMS
to pay the fees of your operations. That's the purpose of the test net, a version of the Nem blockchain used for testing not only your
applications, but also newer versions of the Nem software itself.

If you run a NIS instance yourself, you can configure it with the key `nem.network`. For you NIS to join the production Nem blockchain, 
set its value to `mainnet`, and for it to use the test blockchain, set its value to `testnet`. `mainnet` and `testnet`  is also the way we will identify 
in this document the two environments. 

If you don't run your own NIS instance, but still want to work in the testnet, you can find a list of NIS instance part of the testnet at
[http://bob.nem.ninja:8765/#/nodes/](http://bob.nem.ninja:8765/#/nodes/).

