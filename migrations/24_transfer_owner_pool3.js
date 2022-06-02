const KStableTestPool = artifacts.require("KStableTestPool");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
    let config = data[deployer.network_id];
    let _owner = config.owner;
    return KStableTestPool.deployed().then(pool => {
        pool.transferOwnership(_owner);
    });

};
