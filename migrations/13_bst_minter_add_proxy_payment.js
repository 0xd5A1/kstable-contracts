const PaymentFarmingProxy = artifacts.require("PaymentFarmingProxy");
const KSTMinter = artifacts.require("KSTMinter");

module.exports = function (deployer, network, accounts) {

	return KSTMinter.deployed().then(bstMinter => {
		return PaymentFarmingProxy.deployed().then(payment => {
			return bstMinter.addProxy(payment.address);
		});
	});

};
