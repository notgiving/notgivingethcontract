import Web3 from 'web3';

let web3;
let web3ws;

if (typeof window !== 'undefined' && typeof window.web3 !== 'undefined') {
  // We are in the browser and metamask is running.
  web3 = new Web3(window.web3.currentProvider);
} else {
  // We are on the server *OR* the user is not running metamask
  const provider = new Web3.providers.HttpProvider(
    'https://rinkeby.infura.io/'
  );
  web3 = new Web3(provider);
  // let ws_provider = 'wss://rinkeby.infura.io/ws'
  // let web3ws = new Web3(new Web3.providers.WebsocketProvider(ws_provider))
}

export default web3;
