pragma solidity ^0.4.24;

import './NotgivingEth_interface.sol';
import './SafeMath.sol';

contract NotGivingEthToken is NotGivingEthInterface {
    using SafeMath for uint;

    address public owner = msg.sender;

    mapping(address => uint) private whiteBalance;
    mapping(address => uint) private blackBalance;
    mapping(address => uint) public lastBlock;

    event TransferWhiteCoin(address indexed _sellto, uint _value);
    event Spot(address indexed _victim, address indexed _spammer, uint _value);
    event BalanceOf(address indexed _owner);
    event BalanceOfWhite(address indexed _owner);
    
    //this will be called by owner, in our case trading ui
    function transferWhiteCoin(address _sellto, uint _value) public {
      //Burn white token of sellfrom
      //Burn Black Token of sellTo
      require(whiteBalance[msg.sender] >= _value ,"Not sufficient White coin to sell");
      require(blackBalance[_sellto] >= _value ,"Not sufficient Black coin to receive White coin");
      whiteBalance[msg.sender] = whiteBalance[msg.sender].sub(_value);
      blackBalance[_sellto] = blackBalance[_sellto].sub(_value);
      
      emit TransferWhiteCoin(_sellto, _value);
    }

    //only owner can call, called from dapp
    function spot(address _victim, address _spammer, uint _value) public {
        require(msg.sender == owner,"You are not the Owner!!!");
        
        require(_victim != address(0),"Victim cannot be address(0)");
        require(_spammer != address(0),"Spammer cannot be address(0)");
        
        if(lastBlock[_victim] != 0) {
            //dont allow to spot transaction for 5000 block passed
            require(lastBlock[_victim].add(5) < block.number,"Allowed only every 5 blocks");
            //require(lastBlock[_victim].add(5000) < block.number,"Allowed only every 5000 blocks");
        }
        
        if(_victim == _spammer) {
            blackBalance[_spammer] = blackBalance[_spammer].add(_value).mul(2);
        } else {
            whiteBalance[_victim] = whiteBalance[_victim].add(_value);
            blackBalance[_spammer] = blackBalance[_spammer].add(_value);    
        }
        
        lastBlock[_victim] = block.number;
        
        emit Spot(_victim, _spammer, _value);
    }

    // send balance of black token, for wallets
    function balanceOf(address _owner) public returns (uint balance) {
        require(_owner != address(0),"Balance of address(0) is not possible");
        
        emit BalanceOf(_owner);
        
        return blackBalance[_owner];
    }

    // send balance of while token, for dapp
    function balanceOfWhite(address _owner) public returns (uint balance) {
        require(_owner != address(0),"Balance of address(0) is not possible");
        
        emit BalanceOfWhite(_owner);
        
        return whiteBalance[_owner];
    }
    
    function getBN() returns(uint) {
        return block.number;
    }
}
