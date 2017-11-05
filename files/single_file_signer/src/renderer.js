// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.
const $ = require('jquery');
const nemLibrary = require("nem-library");
const NEMLibrary = nemLibrary.NEMLibrary,
    Address = nemLibrary.Address,
    NetworkTypes = nemLibrary.NetworkTypes,
    TimeWindow = nemLibrary.TimeWindow,
    TransferTransaction = nemLibrary.TransferTransaction,
    MultisigTransaction = nemLibrary.MultisigTransaction,
    TransactionHttp = nemLibrary.TransactionHttp,
    XEM = nemLibrary.XEM,
    EmptyMessage = nemLibrary.EmptyMessage,
    Account = nemLibrary.Account,
    PublicAccount = nemLibrary.PublicAccount,
    PlainMessage = nemLibrary.PlainMessage;
const QRCode = require('qrcode');

NEMLibrary.bootstrap(NetworkTypes.TEST_NET);

function computeSignedTransaction(e) {
        
        // parameters initialisation
        var privateKey = $("#pk").val();
        var recipient =  $("#recipient").val();
        var amount =  $("#amount").val();
        var message = $("#msg").val();
        var msig_pubkey = $("#msig_pubkey").val();
        
       
       let transferTransaction = TransferTransaction.create(
           TimeWindow.createWithDeadline(),
           new Address(recipient),
           new XEM(amount),
           PlainMessage.create(message)
       );
       let tx = transferTransaction;

       if (msig_pubkey!="") {
               tx = MultisigTransaction.create(
                   TimeWindow.createWithDeadline(),
                   transferTransaction,
                   PublicAccount.createWithPublicKey(msig_pubkey)
               );
       }

       let account = Account.createWithPrivateKey(privateKey);
       let signedTransaction = account.signTransaction(tx);

       let text=JSON.stringify(signedTransaction);


       // display results
       $("#result").html(text);
       var canvas = document.getElementById('canvas')

       QRCode.toCanvas(canvas,text, function (error) {
         if (error) console.error(error)
       })
        
}


$("#send").on('click', computeSignedTransaction);


