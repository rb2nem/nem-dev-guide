//////////////////////////////////////////////////////////////////////////////////
// WARNIGN:
// This is an untested code snippet shared only as an example. This is NOT published as a functional software!
// You should write your own version, this is only an example that worked for me at a specific time 
// but that might screw things up for you. Do not run this code if you don't understand what it does. Use
// at your own risk!
//////////////////////////////////////////////////////////////////////////////////


// This is an example of code that will create a transactioni for a multisig account, sign it and save it to a file.

// Private key of the cosignatory that will initiate the transaction
var privateKey=''
// Public key of the multisig account for which we want to create a transaction
var multisig_public_key=""
// Amount in XEMs that we send 
var amount=3
// Recipient account to which we send 
var dest=""
// Multisig fee
// Currently nem-sdk doesn't compute the multisig fee correctly. Set it manually, in microXems.
var multisig_fee=6000000;
// Network on which we will want to broadcast this transaction. Comment lines as needed.
var network_id;
network_id=nem.model.network.data.mijin;
network_id=nem.model.network.data.mainnet;
network_id=nem.model.network.data.testnet;



var real_sender={publicKey: multisig_public_key}
var transferTransaction = nem.model.objects.get("transferTransaction");
// objects.js line 84:
transferTransaction.isMultisig= true;
transferTransaction.multisigAccount=real_sender
var common = nem.model.objects.get("common");
common.privateKey =privateKey
if (common.privateKey.length !== 64 && common.privateKey.length !== 66) { console.log('Invalid private key, length must be 64 or 66 characters !'); process.exit(1);} 
if (!nem.utils.helpers.isHexadecimal(common.privateKey)) { console.log('Private key must be hexadecimal only !'); process.exit(2); }

transferTransaction.amount = amount
transferTransaction.recipient = dest;
transferTransaction.message = "multisig"
var transactionEntity = nem.model.transactions.prepare("transferTransaction")(common, transferTransaction, network.id);
transactionEntity.fee=multisig_fee

var kp = nem.crypto.keyPair.create(common.privateKey);
var serialized = nem.utils.serialization.serializeTransaction(transactionEntity);
var signature = kp.sign(serialized);

var result = {
	        'data': nem.utils.convert.ua2hex(serialized),
	        'signature': signature.toString()
	    };



console.log(result);

var fs = require('fs');
fs.writeFile("/tmp/tx.json", JSON.stringify(result), function(err) {
    if(err) {
        return console.log(err);
    }

    console.log("The file was saved!\n");
}); 

