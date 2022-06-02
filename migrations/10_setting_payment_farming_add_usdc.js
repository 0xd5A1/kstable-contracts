const PaymentFarmingProxy = artifacts.require("PaymentFarmingProxy");
const TokenUSDC = artifacts.require("TokenUSDC");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
	let config = data[deployer.network_id];
	return PaymentFarmingProxy.deployed().then(async payment => {
		let usdc = await TokenUSDC.deployed();
		return payment.addCoins(usdc.address, 2);
	});
};
