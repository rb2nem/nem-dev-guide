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

Nem is using the [Ed25519 publick key signature system](https://ed25519.cr.yp.to/) with the
SHA3 hashing algorithm.
Ed25519 was [introduced](https://ed25519.cr.yp.to/ed25519-20110926.pdf) when sha3 was not yet
standardised, and it uses the SHA512 hashing algorithm (the paper names it Ed25519-SHA-512).
However the paper clearly states that `we will not hesitate to recommend Ed25519-SHA-3 after SHA-3 is standardized`.
{{% notice note %}}
Most Ed25519 implementations use the SHA-512 method described in the original paper. To generate NEM keypairs, 
you might need to patch standard implementations, as was [done for the python implementation](https://github.com/NemProject/nem-py/blob/master/ed25519.py)
 by the NEM authors..
{{% /notice %}}

The private key uniquely identifies a NEM account. The public key is derived from the private key, and the address of the account is
derived from the public key.

The address of an account is a base-32 encoded triplet consisting of:
* network byte: is it an address on the testnet or the mainnet?
* 160-bit hash of the public key
* 4 byte checksum, for detection of mistyped addresses

From this description we see that we can generate a new account offline, there's
no need to be connected to the network to create an account.

Here is the code generating an address from the public key, [extracted from nem.code](https://github.com/NemProject/nem.core/blob/master/src/main/java/org/nem/core/model/Address.java#L81):

``` java
        private static String generateEncoded(final byte version, final byte[] publicKey) {
                // step 1: sha3 hash of the public key
                final byte[] sha3PublicKeyHash = Hashes.sha3_256(publicKey);

                // step 2: ripemd160 hash of (1)
                final byte[] ripemd160StepOneHash = Hashes.ripemd160(sha3PublicKeyHash);

                // step 3: add version byte in front of (2)
                final byte[] versionPrefixedRipemd160Hash = ArrayUtils.concat(new byte[] { version }, ripemd160StepOneHash);

                // step 4: get the checksum of (3)
                final byte[] stepThreeChecksum = generateChecksum(versionPrefixedRipemd160Hash);

                // step 5: concatenate (3) and (4)
                final byte[] concatStepThreeAndStepSix = ArrayUtils.concat(versionPrefixedRipemd160Hash, stepThreeChecksum);

                // step 6: base32 encode (5)
                return Base32Encoder.getString(concatStepThreeAndStepSix);
        }

```

We see that the steps are:

  1. take the sha3-256 of the public key
  1. take the [ripemd160](https://en.wikipedia.org/wiki/RIPEMD) hash of that result. 
  1. add the prefix corresponding to the network ('N' for Mainnet, 'T' for Testnet, 'M' for Mijin)
  1. compute the checksum by taking the 4 left-most bytes of the sha3-256 of the previous step
  1. append the checksum to the result of step 3

## Generating a key-pair

The easiest way to generate a key-pair is currently the [nem-sdk](), which is a javascript implementation 
usable in the browser and on nodejs. All this is setup in the docker container accompanying this guide.
Here is how you generate a key-pair:
``` javascript
//import the nem-sdk
var nem = require("nem-sdk").default;
// generate 32 random bytes. 
// You could write the 32 bytes of your choice if you prefer, but that might be dangerous as
// it would be less random.
// 
var rBytes = nem.crypto.nacl.randomBytes(32);
// convert the random bytes to an hex string
var rHex = nem.utils.convert.ua2hex(rBytes);
// generate the keypair
var keyPair = nem.crypto.keyPair.create(rHex);
```

