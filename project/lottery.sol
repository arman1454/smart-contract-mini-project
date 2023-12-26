// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    address public manager; //actuall address of the manager will be stored here
    address payable[] public participants;
    
    constructor(){
        manager = msg.sender; // because manager only has the authority. Basically when I will compile this contract then that particular account address from which it was compiled will be stored in the manager variable.
    }

    receive() external payable {
        require(msg.value == 1 ether); 
        participants.push(payable(msg.sender));
    }

    function getbalance() public view returns(uint){
        require(msg.sender == manager);
        return address(this).balance;
    }

    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,participants.length)));
    }

    function selectWinner() public {
        require(msg.sender==manager);
        require(participants.length>=3);
        uint r = random();
        address payable winner;
        uint index = r % participants.length;
        winner = participants[index];
        winner.transfer(getbalance());
        participants = new address payable[](0); //resetting the participants array

    }


}