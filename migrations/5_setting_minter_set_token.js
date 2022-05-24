const KSTToken = artifacts.require("KSTToken");
const KSTMinter = artifacts.require("KSTMinter");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
    let config = data[deployer.network_id];
    return KSTMinter.deployed().then(minter => {
        return KSTToken.deployed().then(bst => {
            return minter.setToken(bst.address);
        });
    }).catch(e=>{
        console.error(e);
    });
};
