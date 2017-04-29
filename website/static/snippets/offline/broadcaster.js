//////////////////////////////////////////////////////////////////////////////////
// WARNIGN:
// This is an untested code snippet shared only as an example. This is NOT published as a functional software!
// You should write your own version, this is only an example that worked at a specific time 
// but that might screw things up for you. Do not run this code if you don't understand what it does. Use
// at your own risk!
//////////////////////////////////////////////////////////////////////////////////


// This code will broadcast a transaction written to a file by offline_tx.js of offline_msig.js

// Specify which node to connect to. Comment lines that are not applicable.
var node;
// Custom node
node="http://127.0.0.1"
// Mijin node
node=nem.model.nodes.defaultMijin;
// Mainnet node
node=nem.model.nodes.defaultMainnet;
// Testnet node
node=nem.model.nodes.defaultTestnet;



var endpoint = nem.model.objects.create("endpoint")(node, nem.model.nodes.defaultPort);

var fs = require('fs');
var announce_str;
fs.readFile('/tmp/tx.json', 'utf8', function (err, data) {
  if (err) throw err;
  announce_str = data;
});


nem.com.requests.transaction.announce(endpoint, announce_str).then(function(res) {
                        // If code >= 2, it's an error
                        if (res.code >= 2) {
                                console.log("error response");
                                console.log(res.message);
                        } else {
                                console.log(res.message);
                        }
                }, function(err) {
                        console.log("error in execution");
                        console.log(err);
                });



