const HDWalletProvider = require('truffle-hdwallet-provider');
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      provider: () => new HDWalletProvider(`sing mechanic ripple crowd wool toe sick render devote spatial wide tool`, `https://rinkeby.infura.io/v3/4b39b2267bc2481d8fbc40f5498d43bf`),
      network_id: 4,       // rinkeby's id
        gas: 4500000,        // rinkeby has a lower block limit than mainnet
        gasPrice: 10000000000,
        networkCheckTimeout: 10000000
    },
  }
};