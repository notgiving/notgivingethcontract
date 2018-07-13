pragma solidity ^0.4.11;

import './NotgivingEth_interface.sol';
import './SafeMath.sol';


contract NotGivingEthToken is NotGivingEthInterface {
    address public owner = msg.sender;
    using SafeMath for uint;

    mapping(address => uint) whitebalance;
    mapping(address => uint) blackbalance;
    mapping(address => uint) lastblock;


    //this will be called by owner, in our case trading ui
    function transferWhiteCoin(address _sellto, uint _value){
      //Burn white token of sellfrom
      //Burn Black Token of sellTo
      require(whitebalance[msg.sender] >= _value ,'Not sufficient white token to sell');
      require(blackbalance[_sellto] >= _value ,'Not sufficient Black token to recieve whitecoin');
      whitebalance[msg.sender] = whitebalance[msg.sender].sub(_value);
      blackbalance[_sellto] = blackbalance[_sellto].sub(_value);

    }

    //only owner can call, called from dapp
    function spot(address _victim, address _spammer, uint _value) {
        require(msg.sender == owner);
        //dont allow to spot transaction for 5000 block passed
        require(lastblock[_victim] + 5000 > block.number)
        whitebalance[_victim] = whitebalance[_victim].add(_value);
        blackbalance[_spammer] = blackbalance[_spammer].add(_value);
        emit SpottedSpam(_victim, _spammer, _value);
    }

    // send balance of black token, for wallets
    function balanceOf(address _owner) constant returns (uint balance) {
        return blackbalance[_owner];
    }

    // send balance of while token, for dapp
    function balanceOfWhite(address _owner) constant returns (uint balance) {
        return whitebalance[_owner];
    }
}
