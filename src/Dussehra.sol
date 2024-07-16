// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ChoosingRam} from "./ChoosingRam.sol";
import {RamNFT} from "./RamNFT.sol";

contract Dussehra {
    using Address for address payable;

    error Dussehra__NotEqualToEntranceFee();
    error Dussehra__AlreadyPresent();
    error Dussehra__MahuratIsNotStart();
    error Dussehra__MahuratIsFinished();
    error Dussehra__AlreadyClaimedAmount();

    address[] public WantToBeLikeRam;
    uint256 public entranceFee;
    address public organiser;
    address public SelectedRam;
    RamNFT public ramNFT;
    bool public IsRavanKilled;
    mapping(address competitor => bool isPresent) public peopleLikeRam;
    uint256 public totalAmountGivenToRam;
    ChoosingRam public choosingRamContract;

    event PeopleWhoLikeRamIsEntered(address competitor);

    modifier RamIsSelected() {
        require(choosingRamContract.isRamSelected(), "Ram is not selected yet!");
        _;
    }

    modifier OnlyRam() {
        require(choosingRamContract.selectedRam() == msg.sender, "Only Ram can call this function!");
        _;
    }

    modifier RavanKilled() {
        require(IsRavanKilled, "Ravan is not killed yet!");
        _;
    }

    constructor(uint256 _entranceFee, address _choosingRamContract, address _ramNFT) {
        entranceFee = _entranceFee;
        organiser = msg.sender;
        ramNFT = RamNFT(_ramNFT);
        choosingRamContract = ChoosingRam(_choosingRamContract);
    }

    // @audit No requirements for payment, meaning anyone may be able to enter without payment. 
    function enterPeopleWhoLikeRam() public payable {
        if (msg.value != entranceFee) {
            revert Dussehra__NotEqualToEntranceFee();
        }

        if (peopleLikeRam[msg.sender] == true) {
            revert Dussehra__AlreadyPresent();
        }

        peopleLikeRam[msg.sender] = true;
        WantToBeLikeRam.push(msg.sender);
        ramNFT.mintRamNFT(msg.sender);
        emit PeopleWhoLikeRamIsEntered(msg.sender);
    }


    // added after audit
//      modifier RavanNotKilled() {
//        require(!IsRavanKilled, "Ravan is already killed");
//        _;
//    }

    // Allows users to kill Ravana and Organiser will get half of the total amount collected in the event. 
    // this function will only work after 12th October 2024 and before 13th October 2024.

    //function killRavana() public RamIsSelected RavanNotKilled {
    function killRavana() public RamIsSelected {
        if (block.timestamp < 1728691069) {
        //if (block.timestamp < 1728691200) {  //added after audit.
            revert Dussehra__MahuratIsNotStart();
        }
        if (block.timestamp > 1728777669) {
        //if (block.timestamp > 1728777600) { //added after audit.
            revert Dussehra__MahuratIsFinished();
        }
        IsRavanKilled = true;
        uint256 totalAmountByThePeople = WantToBeLikeRam.length * entranceFee;
        totalAmountGivenToRam = (totalAmountByThePeople * 50) / 100;


        // @audit slither sends eth to arbitrary user. 

        //uint256 remainder = totalAmountByThePeople - totalAmountGivenToRam; //added after audit

        (bool success,) = organiser.call{value: totalAmountGivenToRam}("");
        //(bool success, ) = organiser.call{value: remainder}(""); //added after audit
        require(success, "Failed to send money to organiser");
    }

    function withdraw() public RamIsSelected OnlyRam RavanKilled {
        if (totalAmountGivenToRam == 0) {
            revert Dussehra__AlreadyClaimedAmount();
        }
        //@audit -High Likely Reentrancy slither. 
        uint256 amount = totalAmountGivenToRam;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Failed to send money to Ram");
        totalAmountGivenToRam = 0;
    }

    // function withdrawBalance(){
    //     // send userBalance[msg.sender] Ether to msg.sender
    //     // if msg.sender is a contract, it will call its fallback function
    //     if( ! (msg.sender.call.value(userBalance.msg.sender)() ) ){
    //         revert;
    //     }
    //     userBalance.msg.sender = 0;
    // }
}

