// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


// https://github.com/dliwilb/ppx-testnet-Rinkeby-flatten-0xcert.git

import "./ipfs-nft-enum.sol";


contract Smartify is ipfsNFT {
    
    bool public nftNameSymbolHardcoded;
    bool public isMintAvailable;
    uint256 public mintFee;
    address public treasuryAddress;


    constructor() {
        adminAddresses[msg.sender] = true;
        whitelistedAddresses[msg.sender] = true;
        treasuryAddress = 0x92A9E00F3B52342B47bF5526c1c8cdD43bC76D25;
        allowAdmin = true;

        nftName = "Smartify Items";
        nftSymbol = "ITMS";
        isMintAvailable = true;
        mintFee = 1000000000000000;
    }


    modifier mintActive() {
        require(isMintAvailable, "Mint is not available");
        _;
    }

    event SetNameSymbol(string indexed newName, string indexed newSymbol, address indexed changedBy);
    event SetTreasury(address indexed toAddress, address indexed changedBy);
    event CreateToken(uint256 indexed tokenId, uint8 quantity, address mintTo, address indexed createdBy, string indexed ipfsCID);

    function setNameSymbol(string memory _nftName, string memory _nftSymbol) external onlyOwner {
        require(!nftNameSymbolHardcoded, "Name and symbol are hardcoded");

        nftName = _nftName;
        nftSymbol = _nftSymbol;
        emit SetNameSymbol( _nftName, _nftSymbol, msg.sender);
    }

    function setTreasury(address _addressToMakeTreasury) public onlyOwner {
      treasuryAddress = _addressToMakeTreasury;
      emit SetTreasury(_addressToMakeTreasury, msg.sender);
    }

    function hardcodeNftNameSymbol() external onlyOwner {
        nftNameSymbolHardcoded = true;
    }

    function setIsMintAvailable(bool _isMintAvailable) external isAdmin(msg.sender) {
        isMintAvailable = _isMintAvailable;
    }

    function collectContractBalanceToTreasury(uint256 amount) external onlyOwner {
        (bool sent, ) = treasuryAddress.call{value: amount}("");
        require(sent, "Failed to collect Ether");
    }

    function setMintFee(uint256 _mintFee) external onlyOwner {
        require(_mintFee != mintFee, "Specify a different amount");

        mintFee = _mintFee;
    }

    modifier verifyMinter(address _minterAddress) {
        bool isLegit = (whitelistedAddresses[_minterAddress] || whitelistWaiver);
        require(isLegit, "Mint not allowed");
        _;
    }

    function createToken(uint8 _quantity, address _to, bytes32 _part_1, bytes32 _part_2, uint16 _royaltyAmount) public payable mintActive verifyMinter(msg.sender) {
        require(msg.value == mintFee * _quantity, "Incorrect mint fee"); 

        (bool sent, ) = treasuryAddress.call{value: mintFee}("");
        require(sent, "Cannot send ether");

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 _tokenId = tokens.length+1;
            _create(_to, _tokenId);
            _setTokenRoyalty(_tokenId, msg.sender, _royaltyAmount);
            iDToCid[_tokenId].part_1 = _part_1;
            iDToCid[_tokenId].part_2 = _part_2;

            emit CreateToken(_tokenId, _quantity, _to, msg.sender, string(abi.encodePacked(_part_1, _part_2)));
        }

    }

}

