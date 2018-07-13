var express = require('express');
var Web3 = require("web3");
var abi = require("../build/contracts/NotGivingEthToken.json")
console.log("",abi.abi);

var config = require("./config.js") 
const EthereumTx = require('ethereumjs-tx')
const web3 = new Web3();

var BigNumber = require('bignumber.js');
var bodyParser = require('body-parser');

var app = express();


app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); 


web3.setProvider(new web3.providers.HttpProvider(config.rpcurl));
var contractAddress = abi.networks[4].address;

var address = config.walletaddress; // wallet from whih token will be taken
//var to_address = "0x85148b2debD2a2ea4eA744500BeAD37453b5004b"
var tokenContract = new web3.eth.Contract(abi.abi, contractAddress, {
    from: address
});



 app.post('/transfer', function (req, res) {
     var payload = req.body;
    console.log(payload)
    transact(payload.address, payload.amount, res);
});

app.post('/spot', function (req, res) {
    var payload = req.body;
   console.log(payload.tx)
   getTx(payload.tx)
  // transact(payload.address, payload.amount, res);
});

 
app.listen(config.port);
console.log('Listening on port ',config.port);


function balance(address,res){
      var balance =    tokenContract.methods.balanceOf(address).call().then(function(bal){
        res.send({"Balance":bal});
    })
}



async function getTx(tx){

    var txnCount =   await  web3.eth.getTransactionCount("0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5","pending")
    console.log("txnCount",txnCount)



    try {
        var tx = await web3.eth.getTransaction(tx)
    console.log("-----------",tx)
      } catch (error) {
        console.error(error);
      }

}
 

async function spot(victimaddress, spamaddress, amount, res) {
    var txnCount =   await  web3.eth.getTransactionCount(address,"pending")
    console.log("txnCount",txnCount)
    // if (txnCount ==0){
    //     txnCount++
    // }
   
    var gasPrice = web3.eth.gasPrice;
    console.log(gasPrice);
    var gasLimit = 90713;
    amount = BigNumber(amount) * Math.pow(10, 18) // 18 decimal

    var data = tokenContract.methods.contractAddress(victimaddress,spamaddress, BigNumber(amount)).encodeABI();
    var rawTransaction = {
        "from": address,
        "nonce": web3.utils.toHex(txnCount),    
        "gasPrice": web3.utils.toHex(2000000000),  // 2gwei
        "gasLimit": web3.utils.toHex(gasLimit),
        "to": contractAddress,
        "value": 0,
        "data": data,
        "chainId": web3.utils.toHex(1)
    };

  
    var privKey = new Buffer(config.privatekey, 'hex');
    var tx = new EthereumTx(rawTransaction);
    tx.sign(privKey);
    var serializedTx = tx.serialize();
    web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'), function (err, hash) {
        if (!err) {
            console.log(hash);
            rawTransaction.transactionhash = hash
            res.send(rawTransaction);
        }
        else {
            console.log(err);
            rawTransaction.error = err
            res.send({"Error":err,"rawTransaction":rawTransaction});
        }
    });



}


async function transact(to_address, amount, res) {
    var txnCount =   await  web3.eth.getTransactionCount(address,"pending")
    console.log("txnCount",txnCount)
    // if (txnCount ==0){
    //     txnCount++
    // }
   
    var gasPrice = web3.eth.gasPrice;
    console.log(gasPrice);
    var gasLimit = 90713;
    amount = BigNumber(amount) * Math.pow(10, 18) // 18 decimal

    var data = tokenContract.methods.transfer(to_address, BigNumber(amount)).encodeABI();


    var rawTransaction = {
        "from": address,
        "nonce": web3.utils.toHex(txnCount),    
        "gasPrice": web3.utils.toHex(2000000000),  // 2gwei
        "gasLimit": web3.utils.toHex(gasLimit),
        "to": contractAddress,
        "value": 0,
        "data": data,
        "chainId": web3.utils.toHex(1)
    };

  
    var privKey = new Buffer(config.privatekey, 'hex');
    var tx = new EthereumTx(rawTransaction);
    tx.sign(privKey);
    var serializedTx = tx.serialize();
    web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'), function (err, hash) {
        if (!err) {
            console.log(hash);
            rawTransaction.transactionhash = hash
            res.send(rawTransaction);
        }
        else {
            console.log(err);
            rawTransaction.error = err
            res.send({"Error":err,"rawTransaction":rawTransaction});
        }
    });



}