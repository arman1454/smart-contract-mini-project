// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract crowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters; //consists the voters addresses
    }

    mapping(uint=>Request) public requests; //pointing the Request struct which is named as requests
    uint public numRequests; //request count

    constructor(uint _target,uint _deadline){
        target = _target;
        deadline = block.timestamp+_deadline; //when the contract block will be mined, then from that timestamp the deadline will be set basically adding with it
        minContribution = 100 wei;
        manager=msg.sender;

    }

    function sendEth() public payable{
        require(block.timestamp<deadline,"Deadline has passed");
        require(msg.value>=minContribution,"minimum contribution has not met");
        if(contributors[msg.sender]==0){
          noOfContributors++;   
        }

        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }

    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target,"Refund is not possible until deadline passed and less than target");
        require(contributors[msg.sender]>0,"You are not a contributor");
        address payable user = payable(msg.sender); //first making the declared variable payable that that value can be sent to the person
        user.transfer(contributors[msg.sender]); //transfering his contributions
        contributors[msg.sender] = 0;
    }

    modifier onlyManager(){
        require(msg.sender==manager,"Only manager can call this function");
        _;
    }

    function createRequests(string memory _description,address payable _recipient, uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender]>0, "You must be a contributor first");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;    
    }

    function requestPayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target);
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed==false,"The request has already been completed");
        require(thisRequest.noOfVoters>noOfContributors/2,"Majority has not votted yet"); //50% greater majority vote check
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }


}