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
