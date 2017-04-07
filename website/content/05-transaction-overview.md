+++
prev = "/04-blockchain-requests"
next = "06-transaction-transfer"
weight = 50
title = "Transactions Overview"
toc = true
+++
In this chapter we will take a closer look at transactions.
Transactions can be seen as actions taken on the blockchain, chaging the state of the block chain.
As different actions can be taken, different transaction types have been define.

Transaction types are grouped by kind. For example all multisig transaction are of the same kind, but
still have a differrent type according to their effect. Some kinds have multiple transaction types, others
only have one.

Each transaction kind has a base id, from which the id of their transaction types are derived. For example, the transfer kind has base id `0x100`,
and a mosaic transfer type has id `0x101`. If one days it is decided that NEM needs a new transfer type, it would be assigned the id `0x102`, which
today is not used.

Here are the transfer kinds and their respective types, each with their id noted in hexadecimal and decimal notation, as extracted 
[from the code](https://github.com/NemProject/nem.core/blob/master/src/main/java/org/nem/core/model/TransactionTypes.java):

Transaction  | Kind         | Type                       | ID            |
-------------|--------------|----------------------------|---------------|
Transfer     | 0x100, 256   | Mosaic transfer            | 0x101, 257    |
Importance   | 0x800, 2048  | Importance transfer        | 0x801, 2049   |
Multisig     | 0x1000, 4096 | Multisig change            | 0x1001, 4097  |
             |              | Multisig sign              | 0x1002, 4098  |
             |              | Multisig tx                | 0x1004, 4100  |
Namespace    | 0x2000, 8192 | Provision ns               | 0x2001, 8193  |
Mosaic       | 0x4000, 16384| Mosaic definition creation | 0x4001, 16385 |
             |              | Mosaic supply change       | 0x4002, 16386 |

Keep this as a reference for when we'll monitor or create transactions.

Just for the completeness, there are gaps in the numbers because some of them have been 
assigned to kinds and types that were never used in the end. Here they are:

Transaction  | Kind         | Type                           | ID            |
-------------|--------------|--------------------------------|---------------|
~~Asset~~    | 0x200, 512   | ~~Asset new~~                  | 0x201, 513    |
             |              | ~~Asset ask~~                  | 0x202, 514    |
             |              | ~~Asset bid~~                  | 0x203, 515    |
~~Snapshot~~ | 0x400, 1024  | ~~Snapshot~~                   | 0x241, 1025   |
