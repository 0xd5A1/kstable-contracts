const KSTMinter = artifacts.require("KSTMinter");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
    let config = data[deployer.network_id];
    let _owner = config.owner;
    return KSTMinter.deployed().then(minter => {
        minter.transferOwnership(_owner);
    });

};
