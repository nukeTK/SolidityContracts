// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
//mesge
//hash the mesge
//sign the hash mesge,private key | offchain
//ecrecover(hash(msge),signature)=signer
contract Verifysignature {

  function Verify(address _signer,string memory _mesge,bytes memory sig) public pure returns(bool)
  {
    bytes32 mesgeHash=getMessageHash(_mesge);
    bytes32 ethSignedhash= getEthSignedMessageHash(mesgeHash);
    return recover(ethSignedhash, sig) == _signer; 
  }

  function getMessageHash(string memory _mesge) public pure returns(bytes32)
  {
    return keccak256(abi.encodePacked(_mesge));
  }
  function getEthSignedMessageHash(bytes32 _msghash) public pure returns(bytes32)
  {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",_msghash)); 
  }
  function recover(bytes32 _ethSignedHash,bytes memory _sig) public pure returns(address)
  {
    (bytes32 r,bytes32 s,uint8 v)=_split(_sig);
   return ecrecover(_ethSignedHash, v, r, s);

  }
  //_sig is dynamic data type so the first 32 bytes it will store the length of the data and not a actual signature it is a pointer to the signature where actual signature is stored

  function _split(bytes memory _sig) internal pure returns(bytes32 r ,bytes32 s,uint8 v) 
  {
      require(_sig.length == 65,"invalid signature length");
      assembly {
          r:=mload(add(_sig,32)) //32 means skip the first 32 bytes of arrays 
          s:=mload(add(_sig,64)) 
          v:=byte(0,mload(add(_sig,96))) //we need only one byte so we did typecast here 
      }
    
  }

}
