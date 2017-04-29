//////////////////////////////////////////////////////////////////////////////////
// WARNIGN:
// This is an untested code snippet shared only as an example. This is NOT published as a functional software!
// You should write your own version, this is only an example that worked at a specific time 
// but that might screw things up for you. Do not run this code if you don't understand what it does. Use
// at your own risk!
//////////////////////////////////////////////////////////////////////////////////



// Private key of the account initiating the transaction
private_key=""
// Amount in XEMs to send
amount=0
// Recipient addess of the transaction
recipient=""
// Message to attach to the transaction
message=""

// Network for which the transaction is destined. Comment lines as needed.
network=nem.model.network.data.mijin
network=nem.model.network.data.mainnet
network=nem.model.network.data.testnet

// TESTNET
var transferTransaction = nem.model.objects.get("transferTransaction");
var common = nem.model.objects.get("common");
common.privateKey = privateKey;
if (common.privateKey.length !== 64 && common.privateKey.length !== 66) { console.log('Invalid private key, length must be 64 or 66 characters !'); process.exit(1);} 
if (!nem.utils.helpers.isHexadecimal(common.privateKey)) { console.log('Private key must be hexadecimal only !'); process.exit(2); }

transferTransaction.amount = amount
transferTransaction.recipient = recipient
transferTransaction.message = message
var transactionEntity = nem.model.transactions.prepare("transferTransaction")(common, transferTransaction, network.id);

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


