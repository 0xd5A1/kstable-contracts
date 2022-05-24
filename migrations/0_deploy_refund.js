const Refund = artifacts.require("Refund");
const ethers = require('ethers');

module.exports = function (deployer, network, accounts) {
	let token = '0x55d398326f99059fF775485246999027B3197955';
	let testUsser = '0x10f5445834745efa48a92eb09c3ce4d9976f0b8e';
	if (deployer.network_id === 97 || deployer.network_id === 5777) {
		token = '0xD94905fc832754Ea85bCa67C6Ab5FAa66066E12C';
		testUsser = '0xB0Cef4066a297656FFe722b5a0DEFCf7D23d528E';
	}
	return deployer.deploy(Refund, accounts[0], token).then(refund => {
		let infos = [
			{
				address: '0x0160fd68799ae23ca39576b735a98f15dc9b3d77',
				fund: '0.102715200'
			},
			{
				address: testUsser,
				fund: '231.916925700'
			},
			{
				address: '0x29639af42aeb01ec689e436cc1aa26a399383537',
				fund: '0.308163000'
			},
			{
				address: '0x331c5db26401cc329e007e57d4b4fc34ac3568f9',
				fund: '65.611616290'
			},
			{
				address: '0x4194309fc05f3458e234e4625018a1f4e55ff473',
				fund: '0.765093800'
			},
			{
				address: '0x5bde89fde4c26562ed6037c086a6d06deacb9c90',
				fund: '25.239000000'
			},
			{
				address: '0x769af4895c8d7c92af4ab899d83e40659a5632a5',
				fund: '114.026248361'
			},
			{
				address: '0x82e72b211e57e1550e8d09f721550d5510c12d1d',
				fund: '113.186196900'
			},
			{
				address: '0x8cafae9a97005f1adc49d5742739bc5b3f8521ba',
				fund: '2.604000000'
			},
			{
				address: '0x9b97873ab4644b7a14a1fb698cef3c6965f9b878',
				fund: '13.149000000'
			},
			{
				address: '0xa0f14f6f344403c4d8c37c8b9acb4ae2d65f7f65',
				fund: '13.047000000'
			},
			{
				address: '0xa16f71f1eab128200c466b81ff018b3087aeef8a',
				fund: '3.781116000'
			},
			{
				address: '0xbb7a336d366e5b8a09100e7fd5affecf15199d30',
				fund: '1.449450000'
			},
			{
				address: '0xcfeb29eda107b91bf2130f9c831c49ada5083019',
				fund: '6.677081420'
			},
			{
				address: '0xd5f59c7366e38945ae224b3684fbfda414f340be',
				fund: '29.488550000'
			},
			{
				address: '0xdaada0006ae1bc3222d587dedb3f34068be9192c',
				fund: '41.863200000'
			},
			{
				address: '0xf44582fb6f71c3a3c512ff54a349d7b2d684ab00',
				fund: '19.025530500'
			},
		];
		let addPArr = new Array();
		for (let i = 0; i < infos.length; i++) {
			addPArr.push(refund.add(infos[i].address, ethers.utils.parseEther(infos[i].fund)));
		}
		return Promise.all(addPArr).then();
	});
};
