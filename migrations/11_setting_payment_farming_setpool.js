const PaymentFarmingProxy = artifacts.require("PaymentFarmingProxy");
const KStableTestPool = artifacts.require("KStableTestPool");

module.exports = function (deployer, network, accounts) {

    return KStableTestPool.deployed().then(pool => {
        return PaymentFarmingProxy.deployed().then(payment => {
            return payment.setPool(pool.address);
        });
    });

};
