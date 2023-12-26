// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract EventContract{
    address public organizer;
    struct Event{
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }



    mapping(uint=>Event) public events; // creating a dictionary type with key as uint and value as Event struct
    mapping(address=>mapping(uint=>uint)) public tickets;
    uint public nextId;

    function regAsOrganizer() public {
        // require(organizer == address(0), "Organizer is already set");
        organizer = msg.sender;
    }

    function createEvent(string memory name, uint date, uint price, uint ticketCount) external{
        require(msg.sender == organizer, "Only the organizer can create events");
        require(date>block.timestamp,"you can organize event for future date");
        require(ticketCount>0, "You can organize event only if you create more than 0 ticket");
        events[nextId] = Event(msg.sender,name,date,price,ticketCount,ticketCount); // Here I am assiging each of the created event using mapping as key value pair
        nextId++;
    }

    function buyTicket(uint id, uint quantity) external payable{
        require(events[id].date!=0,"This Event does not exist");
        require(events[id].date>block.timestamp, " Event has already occured");
        require(msg.sender != organizer, "Organizer cannot buy tickets");
        Event storage _event = events[id]; //permanently storing in the blockchain using the storage basically a state variable
        require(msg.value==(_event.price*quantity),"Ether is not enough"); // as the parameter is taking the event id and quantity, so first checking the price*quantity equals to msg.value or not msg.value will contain the Ethers 
        require(_event.ticketRemain>=quantity, "not enough tickets");

        _event.ticketRemain-=quantity;
        tickets[msg.sender][id]+= quantity;
    }

    function transferTicket(uint eventId, uint quantity, address to) external {
        require(events[eventId].date!=0,"This Event does not exist");
        require(events[eventId].date>block.timestamp, " Event has already occured");
        require(tickets[msg.sender][eventId]>=quantity,"You dont have enough tickets");
        tickets[msg.sender][eventId]-=quantity;
        tickets[to][eventId]+=quantity;
    }

    function getbalance() public view returns(uint){
        return address(this).balance;
    }
}