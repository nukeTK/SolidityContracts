// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Sigwallet{
    event Deposit(address indexed sender,uint amount);
    event newTransactionSubmit(uint txid);
    event Approved(address indexed owner,uint txid);
    event TransactionFullfilled(address owner,address to,uint amount,uint txid);
    event Revoked(address owner,uint txid);
     struct Transaction {
        address to;
        uint amount;
        bool isCompleted;
     }
     Transaction[] public transactions;
     mapping(address=>bool) public isOwner;
     mapping(uint=> mapping(address=>bool)) public isApproved;
     address[] public owners;
     uint required;

    constructor(address[] memory _owners, uint _required) public {
        require(_owners.length>1,"Owners length");
        require(_required>0 && _required <=_owners.length,"not fullfill the conditon");
        for(uint i=0;i<_owners.length;i++)
        {
          require(_owners[i]!=address(0),"address not valid");
          require(!isOwner[_owners[i]],"already an owner");
          isOwner[_owners[i]]=true;
          owners.push(_owners[i]);
        }
        required=_required;
    }   

    receive() external payable{
        emit Deposit(msg.sender,msg.value);
    } 

    modifier OnlyOwner() {
        require(isOwner[msg.sender],"You are not an Owner");
        _;
    }
    modifier IsAlreadyCompleted(uint _txid){
        require(!transactions[_txid].isCompleted,"this transaction already completed");
        _;
    }
     modifier IsAlreadyApproved(uint _txid){
        require(!isApproved[_txid][msg.sender],"this transaction already Approved");
        _;
    }
    modifier IsExist(uint txid){
        require(transactions.length<txid,"Not exist");
        _;
    }
    function newTransaction(address _to,uint _amount) public OnlyOwner{
     transactions.push(Transaction({to:_to,amount:_amount,isCompleted:false}));
     emit newTransactionSubmit(transactions.length-1);
    }

    function approval(uint txid)public OnlyOwner IsExist(txid) IsAlreadyApproved(txid) IsAlreadyCompleted(txid){
        isApproved[txid][msg.sender]=true;
        emit Approved(msg.sender,txid);
    }

    function countApprovals(uint txid) private view OnlyOwner IsAlreadyCompleted(txid) returns(uint count){
        for(uint i=0;i<owners.length;i++)
        {
            if(isApproved[txid][msg.sender])
            count++;
        }
    }
    function submit(uint txid) public OnlyOwner IsExist(txid) IsAlreadyCompleted(txid){
        require(countApprovals(txid)>=required,"you are not authorize to processed");
        Transaction storage transaction=transactions[txid];
        transaction.isCompleted=true;
        (bool success,)=transaction.to.call{value:transaction.amount}(msg.data);
        require(success,"Transaction failed");
        emit TransactionFullfilled(msg.sender,transaction.to,transaction.amount,txid);
    }

    function revokeApproval(uint txid) public  OnlyOwner IsExist(txid) IsAlreadyCompleted(txid){
         isApproved[txid][msg.sender]=false;
        emit Revoked(msg.sender,txid);
    }


    

}