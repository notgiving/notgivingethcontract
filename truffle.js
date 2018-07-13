var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = "really there is no ether in this seed why are you still reading it";


module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      provider: () => {return new HDWalletProvider(mnemonic,"https://rinkeby.infura.io")},
      port: 8545,
      network_id: '*' // Match any network id
    },

    gyaan: {
      provider: () => {return new HDWalletProvider(mnemonic,"http://gyaan.network:8545")},
      port: 8545,
      gas: 4700000,
      network_id: '*' // Match any network id
    }

  }
};
