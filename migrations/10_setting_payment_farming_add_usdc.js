const PaymentFarmingProxy = artifacts.require("PaymentFarmingProxy");
const TokenUSDT = artifacts.require("TokenUSDT");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
	let config = data[deployer.network_id];
	return PaymentFarmingProxy.deployed().then(payment => {
		return payment.addCoins(config.usdc, 2);
	});
};
