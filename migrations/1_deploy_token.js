// const TokenDAI = artifacts.require("TokenDAI");
// const TokenAUSD = artifacts.require("TokenAUSD");
const TokenUSDT = artifacts.require("TokenUSDT");
const TokenUSDC = artifacts.require("TokenUSDC");
const TokenXUSD = artifacts.require("TokenXUSD");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
    let pArr = new Array();
    // pArr.push(deployer.deploy(TokenDAI));
    // pArr.push(deployer.deploy(TokenAUSD));
    pArr.push(deployer.deploy(TokenUSDT));
    pArr.push(deployer.deploy(TokenUSDC));
    pArr.push(deployer.deploy(TokenXUSD));
    return Promise.all(pArr).catch(e=>{
        console.error(e);
    });
};
