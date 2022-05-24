const KSTToken = artifacts.require("KSTToken");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
    let config = data[deployer.network_id];
    let _owner = config.owner;
    return KSTToken.deployed().then(bst => {
        bst.transferOwnership(_owner);
    });

};
