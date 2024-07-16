// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Dussehra} from "../src/Dussehra.sol";
import {ChoosingRam} from "../src/ChoosingRam.sol";
import {RamNFT} from "../src/RamNFT.sol";

contract LockedFundsAfterWithDraw is Test {
    error Dussehra__NotEqualToEntranceFee();
    error Dussehra__AlreadyClaimedAmount();
    error ChoosingRam__TimeToBeLikeRamIsNotFinish();
    error ChoosingRam__EventIsFinished();

    Dussehra public dussehra;
    RamNFT public ramNFT;
    ChoosingRam public choosingRam;

    address public organiser = makeAddr("organiser");
    address public player1 = makeAddr("player1");
    address public player2 = makeAddr("player2");
    address public player3 = makeAddr("player3");

    function deploy(uint256 entranceFee) public {

        vm.startPrank(organiser);
        ramNFT = new RamNFT();
        choosingRam = new ChoosingRam(address(ramNFT));
        dussehra = new Dussehra(entranceFee, address(choosingRam), address(ramNFT));

        ramNFT.setChoosingRamContract(address(choosingRam));
        vm.stopPrank();
    }

    function enterParticipants(uint256 entranceFee) internal {
        vm.startPrank(player1);
        vm.deal(player1, entranceFee);
        dussehra.enterPeopleWhoLikeRam{value: entranceFee}();
        vm.stopPrank();

        vm.startPrank(player2);
        vm.deal(player2, entranceFee);
        dussehra.enterPeopleWhoLikeRam{value: entranceFee}();
        vm.stopPrank();

        vm.startPrank(player3);
        vm.deal(player3, entranceFee);
        dussehra.enterPeopleWhoLikeRam{value: entranceFee}();
        vm.stopPrank();
    }

    function test_withdraw_locks_funds(uint256 entranceFee) public {
        // Set up the contracts with the fuzzed entrance fee
        entranceFee = bound(entranceFee, 0.01 ether, 1 ether);
        deploy(entranceFee);

        // Enter participants with the fuzzed entrance fee
        enterParticipants(entranceFee);

        // Warp to the time when the event is finished
        vm.warp(1728691200 + 1);

        // Select Ram as a winner
        vm.startPrank(organiser);
        choosingRam.selectRamIfNotSelected();
        vm.stopPrank();

        // Determine the winner
        address winner = choosingRam.selectedRam() == player1
            ? player1
            : choosingRam.selectedRam() == player2
                ? player2
                : player3;

        vm.startPrank(winner);
        dussehra.killRavana();

        uint256 RamWinningAmount = dussehra.totalAmountGivenToRam();

        // Check the balance of the organiser
        //assertEq(organiser.balance, RamWinningAmount);

        dussehra.withdraw();
        vm.stopPrank();

        // check the balance of the winner
        //assertEq(winner.balance, RamWinningAmount);

        // check that the balance of the winner and the organiser is the same
        assertEq(winner.balance, organiser.balance);

        // check that the balance of the contract is 0
        //assertEq(address(dussehra).balance, 0 ether);
     }
}