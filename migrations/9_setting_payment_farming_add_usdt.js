const PaymentFarmingProxy = artifacts.require("PaymentFarmingProxy");
const TokenUSDT = artifacts.require("TokenUSDT");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
	let config = data[deployer.network_id];
	return PaymentFarmingProxy.deployed().then(async payment => {
		let usdt = await TokenUSDT.deployed();
		return payment.addCoins(usdt.address, 1);
	});
};
