pragma solidity ^0.4.24;

import './NotgivingEth_interface.sol';
import './SafeMath.sol';

contract NotGivingEthToken is NotGivingEthInterface {
    address public owner = msg.sender;
    using SafeMath for uint;

    mapping(address => uint) whiteBalance;
    mapping(address => uint) blackBalance;
    mapping(address => uint) lastBlock;


    //this will be called by owner, in our case trading ui
    function transferWhiteCoin(address _sellto, uint _value) public {
      //Burn white token of sellfrom
      //Burn Black Token of sellTo
      require(whiteBalance[msg.sender] >= _value ,"Not sufficient White coin to sell");
      require(blackBalance[_sellto] >= _value ,"Not sufficient Black coin to receive White coin");
      whiteBalance[msg.sender] = whiteBalance[msg.sender].sub(_value);
      blackBalance[_sellto] = blackBalance[_sellto].sub(_value);
    }

    //only owner can call, called from dapp
    function spot(address _victim, address _spammer, uint _value) public {
        require(_victim != address(0),"Victim cannot be address(0)");
        require(_spammer != address(0),"Spammer cannot be address(0)");
        require(msg.sender == owner,"You are not the Owner!!!");
        //dont allow to spot transaction for 5000 block passed
        //require(lastBlock[_victim] + 5000 > block.number);
        require(lastBlock[_victim] + 2 > block.number,"Allowed only every 2 blocks");
        //require(block.number%2 == 0);
        whiteBalance[_victim] = whiteBalance[_victim].add(_value);
        blackBalance[_spammer] = blackBalance[_spammer].add(_value);
        
        lastBlock[_victim] = block.number;
        
        emit SpottedSpam(_victim, _spammer, _value);
    }

    // send balance of black token, for wallets
    function balanceOf(address _owner) constant public returns (uint balance) {
        require(_owner != address(0),"Balance of address(0) is not possible");        
        return blackBalance[_owner];
    }

    // send balance of while token, for dapp
    function balanceOfWhite(address _owner) constant public returns (uint balance) {
        require(_owner != address(0),"Balance of address(0) is not possible");
        return whiteBalance[_owner];
    }
    
    function getBN(address _victim) returns(uint) {
        return lastBlock[_victim];
    }
}
