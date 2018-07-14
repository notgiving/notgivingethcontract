import web3ws from './web3ws';
// var NotGivingEthToken = require ('../../build/contracts/NotGivingEthToken.json')
import NotGivingEthToken from '../ethereum/build/NotGivingEthToken.json';

const instance = new web3ws.eth.Contract(
  NotGivingEthToken.abi,
  NotGivingEthToken.networks[4].address
);

export default instance;
