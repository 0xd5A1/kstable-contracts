'use strict'

const ethers = require('ethers');
const mnemonics = require('./secret.js');

// 初始化rpc provider，浏览器中不需要
const provider = new ethers.providers.JsonRpcProvider('https://forno.celo.org');
// 初始化助记词
const walletMnemonic = ethers.Wallet.fromMnemonic(mnemonics.deployer);
// 初始化钱包
const wallet = walletMnemonic.connect(provider);
const PaymentJson = require('./build/contracts/PaymentFarmingProxy.json');
const PoolJson = require('./build/contracts/KStablePool.json');
const PaymentFarmingProxy = new ethers.Contract(PaymentJson.networks[42220].address, PaymentJson.abi, provider);
const Pool1 = new ethers.Contract(PoolJson.networks[42220].address, PoolJson.abi, provider);
Pool1.coins(0).then(coin => {
	return PaymentFarmingProxy.coins(coin).then(exists => {
		console.log(exists.toString());
	}).catch(e => {
		console.log(e.message);
	});
}).then(() => {
	return Pool1.coins(1).then(coin => {
		return PaymentFarmingProxy.coins(coin).then(exists => {
			console.log(exists.toString());
		}).catch(e => {
			console.log(e.message);
		});
	});
}).then(() => {
	return Pool1.coins(2).then(coin => {
		return PaymentFarmingProxy.coins(coin).then(exists => {
			console.log(exists.toString());
		}).catch(e => {
			console.log(e.message);
		});
	});
});



