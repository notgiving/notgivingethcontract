import web3 from './web3';
// var NotGivingEthToken = require ('../../build/contracts/NotGivingEthToken.json')
import NotGivingEthToken from '../ethereum/build/NotGivingEthToken.json';

const instance = new web3.eth.Contract(
  NotGivingEthToken.abi,
  NotGivingEthToken.networks[4].address
);

export default instance;
