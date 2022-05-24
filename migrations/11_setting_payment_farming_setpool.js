const PaymentFarmingProxy = artifacts.require("PaymentFarmingProxy");
const KStablePool = artifacts.require("KStablePool");

module.exports = function (deployer, network, accounts) {

    return KStablePool.deployed().then(pool => {
        return PaymentFarmingProxy.deployed().then(payment => {
            return payment.setPool(pool.address);
        });
    });

};
