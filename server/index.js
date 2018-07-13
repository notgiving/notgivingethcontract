var express = require('express');
var Web3 = require("web3");
var abi = require("../build/contracts/NotGivingEthToken.json")
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
console.log("contractAddress", contractAddress)
console.log("owner address", address);

var tokenContract = new web3.eth.Contract(abi.abi, contractAddress, {
    from: address
});

app.post('/spot', function (req, res) {
    var payload = req.body;
    getTx(payload.tx, res)
});


app.listen(config.port);
console.log('Listening on port ', config.port);


function balance(address, res) {
    var balance = tokenContract.methods.balanceOf(address).call().then(function (bal) {
        res.send({ "Balance": bal });
    })
}



async function getTx(tx, res) {
    try {
        var tx = await web3.eth.getTransaction(tx);
        spot(tx.from, tx.to, tx.value.toString(10), res);
    } catch (error) {
        console.error("Error while gettin tx details", error);
        res.send({ "Error": error, "rawTransaction": {} });
    }

}


async function spot(victimaddress, spamaddress, amount, res) {
    var txnCount = await web3.eth.getTransactionCount(address, "pending")
    console.log("txnCount", txnCount)

    var gasPrice = web3.eth.gasPrice;
    var gasLimit = 90713;
    amount = BigNumber()

    var data = tokenContract.methods.spot(victimaddress, spamaddress, BigNumber(amount)).encodeABI();
    var rawTransaction = {
        "from": address,
        "nonce": web3.utils.toHex(txnCount),
        "gasPrice": web3.utils.toHex(2000000000),  // 2gwei
        "gasLimit": web3.utils.toHex(gasLimit),
        "to": contractAddress,
        "value": 0,
        "data": data,
        "chainId": web3.utils.toHex(4)
    };
    var privKey = new Buffer(config.privatekey, 'hex');
    var tx = new EthereumTx(rawTransaction);
    tx.sign(privKey);
    var serializedTx = tx.serialize();
    web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'), function (err, hash) {
        if (!err) {
            console.log(hash);
            rawTransaction.transactionhash = hash
            rawTransaction.blackcointto = spamaddress
            rawTransaction.whitecointto = victimaddress
            rawTransaction.bwvalue = amount
            res.send(rawTransaction);
        }
        else {
            console.log("Error while sending tokens", err);
            rawTransaction.error = err
            res.send({ "Error": err, "rawTransaction": rawTransaction });
        }
    });



}
