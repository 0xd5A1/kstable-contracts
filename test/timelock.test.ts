import { expect, assert } from 'chai';
import {
    HuaMiuToeknContract,
    HuaMiuToeknInstance,
    TimeLockTestContract,
    TimeLockTestInstance,
} from '../build/types/truffle-types';
// Load compiled artifacts
const huamiuContract: HuaMiuToeknContract = artifacts.require('HuaMiuToken.sol');
const timelockContract: TimeLockTestContract = artifacts.require('TimeLockTest.sol');
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));
import { BigNumber } from 'bignumber.js';
import { config } from './config';

contract('TimeLock', async accounts => {

    let huamiu: HuaMiuToeknInstance;
    let timelock: TimeLockTestInstance;
    let denominator = new BigNumber(10).exponentiatedBy(18);

    before('Get contract instance', async () => {
        huamiu = await huamiuContract.deployed();
        timelock = await timelockContract.deployed();
        let hmBal = await huamiu.balanceOf(accounts[0]);
        console.log('hmBal: ' + new BigNumber(hmBal).toFormat(0, BigNumber.ROUND_DOWN));
        await huamiu.transfer(timelock.address, hmBal);
    });


    describe('Test Time Lock', async () => {

        it('Get HuaMiu', async () => {
            await delay(60 * 1000);
            while (true) {
                console.log("=====================");
                let bBal = await huamiu.balanceOf(accounts[0]);
                console.log('Balance before: ' + new BigNumber(bBal).toFormat(0, BigNumber.ROUND_DOWN));
                let reward = await timelock.getReward();
                console.log('Reward: ' + new BigNumber(reward).toFormat(0, BigNumber.ROUND_DOWN));
                if (new BigNumber(reward).comparedTo(0) > 0) {
                    await timelock.withdraw();
                }
                let aBal = await huamiu.balanceOf(accounts[0]);
                console.log('Balance after: ' + new BigNumber(aBal).toFormat(0, BigNumber.ROUND_DOWN));
                console.log("=====================");
                await delay(60 * 1000);
            }
        }).timeout(84600 * 1000);
    });

});
