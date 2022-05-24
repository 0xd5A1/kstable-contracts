const PaymentFarmingProxy = artifacts.require("PaymentFarmingProxy");
const KSTToken = artifacts.require("KSTToken");

module.exports = function (deployer, network, accounts) {

    return KSTToken.deployed().then(bst => {
        return PaymentFarmingProxy.deployed().then(payment => {
            return payment.setToken(bst.address);
        });
    });

};
