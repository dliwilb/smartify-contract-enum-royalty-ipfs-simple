// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


// https://github.com/dliwilb/ppx-testnet-Rinkeby-flatten-0xcert.git

import "./ipfs-simple-nft-enum.sol";


contract Smartify is ipfsSimpleNFT {
    
    bool public nftNameSymbolHardcoded;
    bool public isMintAvailable;
    bool public treasuryHardcoded;
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

        ipfsGateway = 0x697066732e696f2f697066730000000000000000000000000000000000000000;
    }


    modifier mintActive() {
        require(isMintAvailable, "Mint is not available");
        _;
    }

    event SetNameSymbol(string newName, string newSymbol, address changedBy);
    event SetTreasury(address toAddress, address changedBy);

    event CreateToken(
        uint256 indexed tokenId, 
        string indexed hashedIpfsCID, 
        address indexed createdBy, 
        address mintTo, 
        uint16 editions, 
        uint16 royaltyAmount, 
        string plainIpfsCID
    );

    event TokenHashtags(
        uint256 tokenId, 
        bytes32 indexed hashtag_1, 
        bytes32 indexed hashtag_2, 
        bytes32 indexed hashtag_3
    );

    function setNameSymbol(string memory _nftName, string memory _nftSymbol) external onlyOwner {
        require(!nftNameSymbolHardcoded, "Name and symbol are hardcoded");

        nftName = _nftName;
        nftSymbol = _nftSymbol;
        emit SetNameSymbol( _nftName, _nftSymbol, msg.sender);
    }

    function setTreasury(address _addressToMakeTreasury) public onlyOwner {
        require(!treasuryHardcoded, "Treasury is hardcoded");

        treasuryAddress = _addressToMakeTreasury;
        emit SetTreasury(_addressToMakeTreasury, msg.sender);
    }

    function hardcodeTreasury() external onlyOwner {
        treasuryHardcoded = true;
    }

    function hardcodeNftNameSymbol() external onlyOwner {
        nftNameSymbolHardcoded = true;
    }

    function setIsMintAvailable(bool _isMintAvailable) external isAdmin(msg.sender) {
        isMintAvailable = _isMintAvailable;
    }

    function collectContractBalanceToTreasury(uint256 amount) external onlyOwner {
        (bool sent, ) = treasuryAddress.call{value: amount}("");
        require(sent, "Cannot collect ether");
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

    function createTokenHashtags(
        uint256 _tokenId, 
        bytes32 _hashtag_1, 
        bytes32 _hashtag_2, 
        bytes32 _hashtag_3) 
        external {

        require(msg.sender == royalties[_tokenId].receiver, "Only creator can add hashtag");

        emit TokenHashtags( _tokenId, _hashtag_1, _hashtag_2, _hashtag_3);
    }

    function createToken(
        uint16 _editions, 
        address _to, 
        bytes32 _part_1, 
        bytes32 _part_2, 
        uint16 _royaltyAmount
        ) 
        external payable mintActive verifyMinter(msg.sender) {
        require(msg.value == mintFee * _editions, "Incorrect mint fee"); 

        (bool sent, ) = treasuryAddress.call{value: mintFee}("");
        require(sent, "Cannot send ether");

        for (uint256 i = 0; i < _editions; i++) {
            uint256 _tokenId = tokens.length+1;
            _create(_to, _tokenId);
            _setTokenRoyalty(_tokenId, msg.sender, _royaltyAmount);
            iDToCid[_tokenId].part_1 = _part_1;
            iDToCid[_tokenId].part_2 = _part_2;

            emit CreateToken(
                _tokenId, 
                string(abi.encodePacked(
                    IPFSTools.bytes32ToString(_part_1), 
				    IPFSTools.bytes32ToString(_part_2)
                    )), 
                msg.sender, 
                _to, 
                _editions, 
                _royaltyAmount, 
                string(abi.encodePacked(
                    IPFSTools.bytes32ToString(_part_1), 
				    IPFSTools.bytes32ToString(_part_2)
                    )) 
            );

        }
    }

}

