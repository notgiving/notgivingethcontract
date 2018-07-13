import web3 from './web3';
import MultiSigContract from './build/MultiSigContract.json'

const instance = new web3.eth.Contract(
  JSON.parse(MultiSigContract.interface),
  '0x86A8F6b3BAfC06A5bA62B920633FE736cB9082C0'
);

export default instance;
