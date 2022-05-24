const KStablePool = artifacts.require("KStablePool");
constKUSDToken = artifacts.require('CUSDToken');
const USDTToken = artifacts.require('USDTToken');
const USDCToken = artifacts.require('USDCToken');
const BigNumber = require('bignumber.js');
const log4js = require('log4js');
const log4jsConfig = {
	appenders: {
		stdout: {
			type: 'stdout',
			layout: {
				type: 'pattern',
				pattern: '%[[%d] [%p] [%f{2}:%l] %m'
			}
		},
	},
	categories: { default: { appenders: ["stdout"], level: "debug", enableCallStack: true } }
};
log4js.configure(log4jsConfig);
const logger = log4js.getLogger('KStablePool test case');
// const addressZero = "0x0000000000000000000000000000000000000000";
// const mnemonic = require('../secret');
// const ethe = require('ethe');
// const account1 = ethe.Wallet.fromMnemonic(mnemonic.dev, "m/44'/60'/0'/0/1"); // accounts[1]
// const account2 = ethe.Wallet.fromMnemonic(mnemonic.dev, "m/44'/60'/0'/0/2"); // accounts[2]
// const account3 = ethe.Wallet.fromMnemonic(mnemonic.dev, "m/44'/60'/0'/0/3"); // accounts[3]
// const account4 = ethe.Wallet.fromMnemonic(mnemonic.dev, "m/44'/60'/0'/0/4"); // accounts[4]
// const account5 = ethe.Wallet.fromMnemonic(mnemonic.dev, "m/44'/60'/0'/0/5"); // accounts[5]


contract("KStablePool", accounts => {

	// it("测试1", async () => {
	// 	let cusd = awaitKUSDToken.deployed();
	// 	let usdt = await USDTToken.deployed();
	// 	let usdc = await USDCToken.deployed();
	// 	let pool = await KStablePool.deployed();
	// 	await cusd.approve(pool.address, web3.utils.toWei('170000', 'ether'), { from: accounts[1] });
	// 	await usdt.approve(pool.address, web3.utils.toWei('170000', 'mwei'), { from: accounts[1] });
	// 	await usdc.approve(pool.address, web3.utils.toWei('170000', 'mwei'), { from: accounts[1] });
	// 	await pool.add_liquidity(
	// 		[web3.utils.toWei('170000', 'ether'), web3.utils.toWei('170000', 'mwei'), web3.utils.toWei('170000', 'mwei')],
	// 		0,
	// 		{ from: accounts[1] }
	// 	);
	// 	await cusd.approve(pool.address, web3.utils.toWei('170000', 'ether'), { from: accounts[2] });
	// 	await usdt.approve(pool.address, web3.utils.toWei('170000', 'mwei'), { from: accounts[2] });
	// 	await usdc.approve(pool.address, web3.utils.toWei('170000', 'mwei'), { from: accounts[2] });
	// 	await pool.add_liquidity(
	// 		[web3.utils.toWei('10000', 'ether'), web3.utils.toWei('10000', 'mwei'), web3.utils.toWei('10000', 'mwei')],
	// 		0,
	// 		{ from: accounts[2] }
	// 	);
	// 	let lpBal = await pool.balanceOf(accounts[1]);
	// 	logger.info('accounts1充入流动性后，获得的流动性代币的数量 : ' + web3.utils.fromWei(lpBal, 'ether'));
	// 	for (let i = 0; i < 5; i++) {
	// 		await cusd.approve(pool.address, web3.utils.toWei('1000', 'ether'), { from: accounts[3] });
	// 		await pool.exchange(0, 1, web3.utils.toWei('1000', 'ether'), 0, { from: accounts[3] });
	// 		await usdc.approve(pool.address, web3.utils.toWei('1000', 'mwei'), { from: accounts[4] });
	// 		await pool.exchange(2, 1, web3.utils.toWei('1000', 'mwei'), 0, { from: accounts[4] });
	// 	}
	// 	await pool.remove_liquidity(lpBal, [0, 0, 0], { from: accounts[1] });
	// 	let cusdBal = await cusd.balanceOf(accounts[1]);
	// 	let usdtBal = await usdt.balanceOf(accounts[1]);
	// 	let usdcBal = await usdc.balanceOf(accounts[1]);
	// 	logger.info("account1 赎回流动性后 ");
	// 	logger.info("account1 cusd的余额: " + web3.utils.fromWei(cusdBal, 'ether'));
	// 	logger.info("account1 usdt的余额: " + web3.utils.fromWei(usdtBal, 'mwei'));
	// 	logger.info("account1 usdc的余额: " + web3.utils.fromWei(usdcBal, 'mwei'));
	// 	let totalu = new BigNumber(web3.utils.fromWei(cusdBal, 'ether')).plus(web3.utils.fromWei(usdtBal, 'mwei')).plus(web3.utils.fromWei(usdcBal, 'mwei'));
	// 	logger.info("account1 全部u的总和: " + totalu.toFixed(6, BigNumber.ROUND_DOWN));
	// });

	it("测试2", async () => {
		let cusd = awaitKUSDToken.deployed();
		let usdt = await USDTToken.deployed();
		let usdc = await USDCToken.deployed();
		let pool = await KStablePool.deployed();
		await cusd.approve(pool.address, web3.utils.toWei('10000', 'ether'), { from: accounts[2] });
		await usdt.approve(pool.address, web3.utils.toWei('10000', 'mwei'), { from: accounts[2] });
		await usdc.approve(pool.address, web3.utils.toWei('10000', 'mwei'), { from: accounts[2] });
		await pool.add_liquidity(
			[web3.utils.toWei('10000', 'ether'), web3.utils.toWei('10000', 'mwei'), web3.utils.toWei('10000', 'mwei')],
			0,
			{ from: accounts[2] }
		);
		let newBal;
		for (let i = 0; i < 170; i++) {
			await cusd.approve(pool.address, web3.utils.toWei('1000', 'ether'), { from: accounts[1] });
			await usdt.approve(pool.address, web3.utils.toWei('1000', 'mwei'), { from: accounts[1] });
			await usdc.approve(pool.address, web3.utils.toWei('1000', 'mwei'), { from: accounts[1] });
			let orginBal = await pool.balanceOf(accounts[1]);
			await pool.add_liquidity(
				[web3.utils.toWei('1000', 'ether'), web3.utils.toWei('1000', 'mwei'), web3.utils.toWei('1000', 'mwei')],
				0,
				{ from: accounts[1] }
			);
			newBal = await pool.balanceOf(accounts[1]);
			// logger.info("account1 获得的LP数量[" + (i + 1) + "]: " + web3.utils.fromWei(newBal.sub(orginBal), 'ether'));
		}
		logger.info('account1充入流动性后，获得的流动性代币的数量 : ' + web3.utils.fromWei(newBal, 'ether'));
		await pool.remove_liquidity(newBal, [0, 0, 0], { from: accounts[1] });
		let cusdBal = await cusd.balanceOf(accounts[1]);
		let usdtBal = await usdt.balanceOf(accounts[1]);
		let usdcBal = await usdc.balanceOf(accounts[1]);
		logger.info("account1 赎回流动性后 ");
		logger.info("account1 cusd的余额: " + web3.utils.fromWei(cusdBal, 'ether'));
		logger.info("account1 usdt的余额: " + web3.utils.fromWei(usdtBal, 'mwei'));
		logger.info("account1 usdc的余额: " + web3.utils.fromWei(usdcBal, 'mwei'));
		let totalu = new BigNumber(web3.utils.fromWei(cusdBal, 'ether')).plus(web3.utils.fromWei(usdtBal, 'mwei')).plus(web3.utils.fromWei(usdcBal, 'mwei'));
		logger.info("account1 全部u的总和: " + totalu.toFixed(6, BigNumber.ROUND_DOWN));
		await pool.remove_liquidity(await pool.balanceOf(accounts[2]), [0, 0, 0], { from: accounts[2] });
		logger.info("account2赎回流动性之后");
		let cusdBal2 = await cusd.balanceOf(accounts[2]);
		let usdtBal2 = await usdt.balanceOf(accounts[2]);
		let usdcBal2 = await usdc.balanceOf(accounts[2]);
		let totaluIncome = new BigNumber(web3.utils.fromWei(cusdBal2, 'ether')).plus(web3.utils.fromWei(usdtBal2, 'mwei')).plus(web3.utils.fromWei(usdcBal2, 'mwei')).minus(30000);
		logger.info("account2的收入u: " + totaluIncome.toFixed(18, BigNumber.ROUND_DOWN));
		await pool.withdraw_admin_fees();
		logger.info("account0提取手续费之后");
		let cusdBalFee = await cusd.balanceOf(accounts[0]);
		let usdtBalFee = await usdt.balanceOf(accounts[0]);
		let usdcBalFee = await usdc.balanceOf(accounts[0]);
		logger.info("account0 cusd的余额: " + web3.utils.fromWei(cusdBalFee, 'ether'));
		logger.info("account0 usdt的余额: " + web3.utils.fromWei(usdtBalFee, 'mwei'));
		logger.info("account0 usdc的余额: " + web3.utils.fromWei(usdcBalFee, 'mwei'));
		let totaluFee = new BigNumber(web3.utils.fromWei(cusdBalFee, 'ether')).plus(web3.utils.fromWei(usdtBalFee, 'mwei')).plus(web3.utils.fromWei(usdcBalFee, 'mwei'));
		logger.info("account0 全部u的总和: " + totaluFee.toFixed(18, BigNumber.ROUND_DOWN));
		logger.info("account1和account0最后的资金总和: " + totalu.plus(totaluFee).toFixed(18, BigNumber.ROUND_DOWN));
		logger.info("account1、account0最后的资金总和 加上 account2的收入: " + totalu.plus(totaluFee).plus(totaluIncome).toFixed(18, BigNumber.ROUND_DOWN));
	});

});
