const LiquidityFarmingProxy = artifacts.require("LiquidityFarmingProxy");
const KSTToken = artifacts.require("KSTToken");

module.exports = function (deployer, network, accounts) {

    return KSTToken.deployed().then(bst => {
        return LiquidityFarmingProxy.deployed().then(proxy => {
            return proxy.setToken(bst.address);
        });
    });

};
