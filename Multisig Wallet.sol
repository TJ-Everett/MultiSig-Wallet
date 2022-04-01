// ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.5; 
pragma abicoder v2; 


contract multiSigWallet {
    address [] owners; 
    uint limit; 

    struct Transfer{
        uint amount;
        address payable receiver; 
        uint approvals;
        bool hasBeenSent;
        uint txId; 
          
    }

    //Events 
    event transferRequestInitiated(uint _id, uint _amount, address _initiator, address _receiver);
    event txApprovalSent(uint _id, uint _approvals,address _approver); 
    event txApproved(uint _id); 
    event newOwnerCreated(address indexed owners); 

    Transfer[] transferRequests; 

    mapping(address => mapping(uint => bool)) approvals;
    mapping(address => uint) balance;

    modifier onlyOwners(){
        bool owner = false;
        for(uint i=0; i<owners.length; i++){
            if(owners[i] == msg.sender){
                owner = true;
            }
        }
        require(owner == true);
        _;
    }

    constructor(address[] memory _owners, uint _limit){
        owners = _owners;
        limit = _limit; 

    }
    

    //Functions 
    function deposit() public payable {}

    function createTransfer(uint _amount, address payable _receiver) public onlyOwners {
        require(_amount > 0, "Transfer amount must be greater than 0");
        require(address(this).balance >= _amount, "Insufficient Funds");
        emit transferRequestInitiated(transferRequests.length, _amount, msg.sender, _receiver);
        transferRequests.push(
            Transfer(_amount, _receiver, 0, false, transferRequests.length)
        );
    }

    function approveTx(uint _txId) public onlyOwners {
        require(approvals[msg.sender][_txId] == false);
        require(transferRequests[_txId].hasBeenSent == false);

       approvals[msg.sender][_txId] = true;
       transferRequests[_txId].approvals++; 

       emit txApprovalSent(_txId, transferRequests[_txId].approvals, msg.sender);

        if(transferRequests[_txId].approvals >= limit){
            transferRequests[_txId].hasBeenSent = true;
            transferRequests[_txId].receiver.transfer(transferRequests[_txId].amount);
            emit txApproved(_txId);
        }
    }


    function getTransferRequests() public view returns (Transfer[] memory) {
        return transferRequests; 
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

}