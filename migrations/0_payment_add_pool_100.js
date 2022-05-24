const PaymentFarmingProxy = artifacts.require("PaymentFarmingProxy");

module.exports = function (deployer, network, accounts) {

	return PaymentFarmingProxy.deployed().then(proxy => {
		return proxy.add(100);
	});

};
