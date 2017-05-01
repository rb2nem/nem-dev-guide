+++
next = "99-references"
prev = "80-debugging"
weight = 900
title = "Code snippets"
date = "2017-04-29T15:02:00+02:00"
toc = true
+++

## Warning

You will find in this section untested code snippets shared only as an example. These are NOT published as functional software!
You should write your own version, as these are only examples that worked at a specific time 
but that might screw things up for you. Do not run this code if you don't understand what it does. Use
at your own risk!

## Offline transaction
### Unisig transaction

* Description: Create and save to file a transaction for a unisig account.
* Code: [offline_tx.js](/snippets/offline/offline_tx.js)
* Info: Javascript using nem-sdk

### Multisig transaction

* Description: Create and save to file a transaction initiated for a multisig account by a cosignatory.
* Code: [offline_msig.js](/snippets/offline/offline_msig.js)
* Info: Javascript using nem-sdk

### Broadcaster

* Description: Broadcast on the network a transaction created offline
* Code: [broadcaster.js](/snippets/offline/broadcaster.js)
* Info: Javascript using nem-sdk
