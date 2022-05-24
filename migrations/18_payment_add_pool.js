const PaymentFarmingProxy = artifacts.require("PaymentFarmingProxy");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
	let config = data[deployer.network_id];
	return PaymentFarmingProxy.deployed().then(proxy => {
		return proxy.add(config.payment.allocation);
	});

};
