// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ERC20 {

  string public token_name="NUKETK";
  string public token_symbol="KAN";
  uint public totalsupplies;
  mapping(address=>uint) public balanceof;
  mapping(address=>mapping(address=>uint)) public allow;
  
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  constructor(uint _value) public{
    totalsupplies=_value;
    
  }
  
  function allowancetalSupply() public view returns (uint256)
  {
    return totalsupplies;
  } 
  function balanceOf(address _owner) public view returns (uint256 balance)
  {
    return balanceof[_owner];
  }
  function transfer(address _to, uint256 _value) public returns (bool success)
  {
    require(balanceof[msg.sender]>0,"account balance does not have enough allowancekens allowance spend");
    balanceof[msg.sender]-=_value;
    balanceof[_to]+=_value;
    emit Transfer(msg.sender,_to,_value);
    return true;
  }

  function transferbalanceOf(address _from, address _to, uint256 _value) public returns (bool success)
  {
    allow[_from][msg.sender]+=_value;
    balanceof[_from]-=_value;
    balanceof[_to]+=_value;
    emit Transfer(_from,_to,_value);
    return true;
  }
   function approve(address _spender, uint256 _value) public returns (bool success)
  {
    allow[msg.sender][_spender] = _value;   
    emit Approval(msg.sender,_spender,_value);
    return true;
  } 
 
  function mint(uint amount) external {
        balanceof[msg.sender] += amount;
        totalsupplies += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balanceof[msg.sender] -= amount;
        totalsupplies -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
