const TokenXUSD = artifacts.require("TokenXUSD");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
	return deployer.deploy(TokenXUSD).catch(e => {
		console.error(e);
	});
};
