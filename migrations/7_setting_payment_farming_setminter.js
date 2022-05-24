const PaymentFarmingProxy = artifacts.require("PaymentFarmingProxy");
const KSTMinter = artifacts.require("KSTMinter");

module.exports = function (deployer, network, accounts) {

    return KSTMinter.deployed().then(minter => {
        return PaymentFarmingProxy.deployed().then(payment => {
            return payment.setMinter(minter.address);
        });
    }).catch(e=>{
        console.error(e);
    });

};
