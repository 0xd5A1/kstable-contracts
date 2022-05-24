const LiquidityFarmingProxy = artifacts.require("LiquidityFarmingProxy");
const KSTMinter = artifacts.require("KSTMinter");

module.exports = function (deployer, network, accounts) {

    return KSTMinter.deployed().then(minter => {
        return LiquidityFarmingProxy.deployed().then(proxy => {
            return proxy.setMinter(minter.address);
        });
    });

};
