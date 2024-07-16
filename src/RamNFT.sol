// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


// @notice This contract allows the Dussehra contract to mint Ram NFTs, update the characteristics of the NFTs, and get the characteristics of the NFTs.
contract RamNFT is ERC721URIStorage {
    error RamNFT__NotOrganiser();
    
    //error RamNFT__NotDussehraContract(); // added after the audit. 

    error RamNFT__NotChoosingRamContract(); //These lines define custom error messages to be used within the contract. RamNFT__NotOrganiser and RamNFT__NotChoosingRamContract will be used to revert transactions when certain conditions are not met.

    // https://medium.com/illumination/16-divine-qualities-of-lord-rama-24c326bd6048
    struct CharacteristicsOfRam {
        address ram; //address of user
        bool isJitaKrodhah;
        bool isDhyutimaan;
        bool isVidvaan;
        bool isAatmavan;
        bool isSatyavaakyah;
    } //This defines a struct named CharacteristicsOfRam which holds the characteristics of an NFT, including the address of the owner and five boolean attributes.

    uint256 public tokenCounter; //Tracks the number of tokens minted.
    address public organiser; //Stores the address of the contract organiser.
    address public choosingRamContract; //Stores the address of the contract that is allowed to update characteristics.

    //address public dussehraContract; // added after the audit.

    mapping(uint256 tokenId => CharacteristicsOfRam) public Characteristics; //This line creates a mapping from token IDs to CharacteristicsOfRam structs, storing the characteristics for each token.

   

    modifier onlyOrganiser() {
        if (msg.sender != organiser) {
            revert RamNFT__NotOrganiser(); //This modifier restricts function execution to the organiser. If msg.sender is not the organiser, the transaction is reverted with RamNFT__NotOrganiser.
        }
        _;
    }

    modifier onlyChoosingRamContract() {
        if (msg.sender != choosingRamContract) {
            revert RamNFT__NotChoosingRamContract(); //This modifier restricts function execution to the address stored in choosingRamContract. If msg.sender is not choosingRamContract, the transaction is reverted with RamNFT__NotChoosingRamContract.
        }
        _;
    }

    constructor() ERC721("RamNFT", "RAM") { //Calls the ERC721 constructor with the name "RamNFT" and symbol "RAM".
        tokenCounter = 0; //Sets tokenCounter to 0.
        organiser = msg.sender; //Sets the organiser to the address that deploys the contract (msg.sender).
    }

    //  @notice: Allows the organiser to set the choosingRam contract.
    // q are we sure onlyOrganiser is restricted for onlyOrganiser to set the choosingRanContract???
    function setChoosingRamContract(address _choosingRamContract) public onlyOrganiser {
        choosingRamContract = _choosingRamContract; //This function allows the organiser to set the choosingRamContract address. It uses the onlyOrganiser modifier to ensure only the organiser can call it
    }



    // added after the audit.
//     function setDussehraContract(
//        address _dussehraContract
//    ) public onlyOrganiser {
//        dussehraContract = _dussehraContract;
//    }



   // added after the audit.
//     modifier onlyDussehraContract() {
//        if (msg.sender != dussehraContract) {
//            revert RamNFT__NotDussehraContract();
//        }
//        _;
//    }

    // @notice Allows the Dussehra contract to mint Ram NFTs.
    // q who is allowed to mint?
    // added after the audit.
    //function mintRamNFT(address to) public onlyDussehraContract {
    function mintRamNFT(address to) public {
        uint256 newTokenId = tokenCounter++; //Increments the tokenCounter and assigns the new value to newTokenId.
        _safeMint(to, newTokenId); //Calls _safeMint to mint the new NFT to the to address with the ID newTokenId.

        // q why are all set to false, it it is ok, then can one be set to true and still be minted??
        Characteristics[newTokenId] = CharacteristicsOfRam({
            ram: to,
            isJitaKrodhah: false,
            isDhyutimaan: false,
            isVidvaan: false,
            isAatmavan: false,
            isSatyavaakyah: false
        });
    }


    // @notice Allows the ChoosingRam contract to update the characteristics of the NFTs.
    // @notice can a nonChoosingRam contract update the xteristrics of the NFTs??
    // This function updates the characteristics of an NFT:
    // @notice It requires the caller to be the choosingRamContract via the onlyChoosingRamContract modifier.
    // q looiking at a likely reentrancy as this function calls an external contract. 
    function updateCharacteristics(
        uint256 tokenId,
        bool _isJitaKrodhah,
        bool _isDhyutimaan,
        bool _isVidvaan,
        bool _isAatmavan,
        bool _isSatyavaakyah
    ) public onlyChoosingRamContract {
        Characteristics[tokenId] = CharacteristicsOfRam({ //The function updates the characteristics of the specified tokenId with the provided boolean values, but keeps the original ram address. It updates the characteristics of the specified NFT with new values, but keeps the owner's address the same.
            ram: Characteristics[tokenId].ram,
            isJitaKrodhah: _isJitaKrodhah,
            isDhyutimaan: _isDhyutimaan,
            isVidvaan: _isVidvaan,
            isAatmavan: _isAatmavan,
            isSatyavaakyah: _isSatyavaakyah
        });
    }

    // @notice Allows the user to get the characteristics of the NFTs.
    function getCharacteristics(uint256 tokenId) public view returns (CharacteristicsOfRam memory) {
        return Characteristics[tokenId];
    }

    // @notice Allows the users to get the next token id.
    function getNextTokenId() public view returns (uint256) {
        return tokenCounter;
    }
}
