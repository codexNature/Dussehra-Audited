// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {RamNFT} from "./RamNFT.sol";

//This contract allows users to increase their values and select as Ram if all characteristics are true. if the user has not selected Ram before 12th October 2024. then, Organiser can select Ram if not selected.
contract ChoosingRam {
    error ChoosingRam__InvalidTokenIdOfChallenger();
    error ChoosingRam__InvalidTokenIdOfPerticipent();
    error ChoosingRam__TimeToBeLikeRamFinish();
    error ChoosingRam__CallerIsNotChallenger();
    error ChoosingRam__TimeToBeLikeRamIsNotFinish();
    error ChoosingRam__EventIsFinished();

    bool public isRamSelected; //isRamSelected: A boolean to track whether a Ram has been selected.
    RamNFT public ramNFT; //ramNFT: An instance of the RamNFT contract.
    address public selectedRam; //selectedRam: The address of the selected Ram.

    modifier RamIsNotSelected() {
        require(!isRamSelected, "Ram is selected!"); //RamIsNotSelected: Ensures that a Ram has not yet been selected before allowing the function to proceed.
        _;
    }

    modifier OnlyOrganiser() {
        require(ramNFT.organiser() == msg.sender, "Only organiser can call this function!"); //OnlyOrganiser: Ensures that only the organiser (as defined in the RamNFT contract) can call the function.
        _;
    }

    constructor(address _ramNFT) {
        isRamSelected = false;
        ramNFT = RamNFT(_ramNFT);
    } //The constructor initializes the contract by setting isRamSelected to false and assigning the provided _ramNFT address to the ramNFT state variable.


    //error ChoosingRam__CannotPlayAgainstYourself(); //added after audit.
    function increaseValuesOfParticipants(uint256 tokenIdOfChallenger, uint256 tokenIdOfAnyPerticipent) //Defines a public function increaseValuesOfParticipants that takes two parameters, tokenIdOfChallenger and tokenIdOfAnyPerticipent.
        public
        RamIsNotSelected // ensures that a Ram has not yet been selected.
    {
        if (tokenIdOfChallenger > ramNFT.tokenCounter()) {
            //if (tokenIdOfChallenger >= ramNFT.tokenCounter()) { //added after audit
            revert ChoosingRam__InvalidTokenIdOfChallenger(); //Validates that the tokenIdOfChallenger and tokenIdOfAnyPerticipent are within valid ranges and that the caller is the owner of the tokenIdOfChallenger.
        }
        if (tokenIdOfAnyPerticipent > ramNFT.tokenCounter()) { 
            //if (tokenIdOfAnyPerticipent >= ramNFT.tokenCounter()) { // added after audit
            revert ChoosingRam__InvalidTokenIdOfPerticipent(); //Ensures the function is called before a specific timestamp.
        }
        if (ramNFT.getCharacteristics(tokenIdOfChallenger).ram != msg.sender) {
            revert ChoosingRam__CallerIsNotChallenger(); //Generates a random number to decide which participant's characteristics to increase.
        }
        // added after audit. 
        // if (ramNFT.getCharacteristics(tokenIdOfAnyPerticipent).ram == msg.sender) {
        //    revert ChoosingRam__CannotPlayAgainstYourself();
        // }
        if (block.timestamp > 1728691200) {
            revert ChoosingRam__TimeToBeLikeRamFinish();
        }

        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % 2;

        if (random == 0) {
            if (ramNFT.getCharacteristics(tokenIdOfChallenger).isJitaKrodhah == false) {
                ramNFT.updateCharacteristics(tokenIdOfChallenger, true, false, false, false, false);
        } else if (ramNFT.getCharacteristics(tokenIdOfChallenger).isDhyutimaan == false) {
                ramNFT.updateCharacteristics(tokenIdOfChallenger, true, true, false, false, false);
            } else if (ramNFT.getCharacteristics(tokenIdOfChallenger).isVidvaan == false) {
                ramNFT.updateCharacteristics(tokenIdOfChallenger, true, true, true, false, false);
            } else if (ramNFT.getCharacteristics(tokenIdOfChallenger).isAatmavan == false) {
                ramNFT.updateCharacteristics(tokenIdOfChallenger, true, true, true, true, false);
            } else if (ramNFT.getCharacteristics(tokenIdOfChallenger).isSatyavaakyah == false) {
                ramNFT.updateCharacteristics(tokenIdOfChallenger, true, true, true, true, true);

                //isRamSelected = true; //added after audit to fix

                selectedRam = ramNFT.getCharacteristics(tokenIdOfChallenger).ram;
            }
        } else {
            if (ramNFT.getCharacteristics(tokenIdOfAnyPerticipent).isJitaKrodhah == false) {
                ramNFT.updateCharacteristics(tokenIdOfAnyPerticipent, true, false, false, false, false);
            } else if (ramNFT.getCharacteristics(tokenIdOfAnyPerticipent).isDhyutimaan == false) {
                ramNFT.updateCharacteristics(tokenIdOfAnyPerticipent, true, true, false, false, false);
            } else if (ramNFT.getCharacteristics(tokenIdOfAnyPerticipent).isVidvaan == false) {
                ramNFT.updateCharacteristics(tokenIdOfAnyPerticipent, true, true, true, false, false);
            } else if (ramNFT.getCharacteristics(tokenIdOfAnyPerticipent).isAatmavan == false) {
                ramNFT.updateCharacteristics(tokenIdOfAnyPerticipent, true, true, true, true, false);
            } else if (ramNFT.getCharacteristics(tokenIdOfAnyPerticipent).isSatyavaakyah == false) {
                ramNFT.updateCharacteristics(tokenIdOfAnyPerticipent, true, true, true, true, true);

                //isRamSelected = true; //added after audit to fix

                selectedRam = ramNFT.getCharacteristics(tokenIdOfAnyPerticipent).ram;
            }
        }
    }

    function selectRamIfNotSelected() public RamIsNotSelected OnlyOrganiser {
        if (block.timestamp < 1728691200) {
            revert ChoosingRam__TimeToBeLikeRamIsNotFinish();
        }
        if (block.timestamp > 1728777600) {
            revert ChoosingRam__EventIsFinished();
        }
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % ramNFT.tokenCounter();
        selectedRam = ramNFT.getCharacteristics(random).ram;
        isRamSelected = true;
    }
}
