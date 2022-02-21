// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./admin-whitelist.sol";
import "./nf-token-metadata-enumerable.sol";
import "./ipfs-tools.sol";

contract ipfsNFT is NFTokenMetadataEnumerable, AdminWhitelist {

    bool public useIpfsHardcoded;
    bool public useIpfs;   				// uses https if false
	bytes32 public ipfsGateway;

	struct ipfsCID{
		bytes32 part_1;
		bytes32 part_2;
	}

	mapping(uint256 => ipfsCID) iDToCid;

    function hardcodeUseIpfs() external onlyOwner {
		require(useIpfs, "useIpfs is false");
        useIpfsHardcoded = true;
    }

    function setUseIpfs(bool _useIpfs) external onlyOwner {
        require(!useIpfsHardcoded, "useIpfs is hardcoded");
        useIpfs = _useIpfs;
    }

	function setIpfsGateway(bytes32 _ipfsGateway) external onlyOwner {
		ipfsGateway = _ipfsGateway;
	}

	function tokenURI(uint256 _tokenId) public view override returns (string memory) {
		require(idToOwner[_tokenId] != address(0), 'nonexistent token');
		
		if (useIpfs) {
			return string(abi.encodePacked(
				'ipfs://', 
				IPFSTools.bytes32ToString(iDToCid[_tokenId].part_1), 
				IPFSTools.bytes32ToString(iDToCid[_tokenId].part_2)));
		} else {
			return string(abi.encodePacked(
				'https://', 
				IPFSTools.bytes32ToString(ipfsGateway), 
				'/', 
				IPFSTools.bytes32ToString(iDToCid[_tokenId].part_1), 
				IPFSTools.bytes32ToString(iDToCid[_tokenId].part_2)));
		}

	}

	function setTokenUri(uint256 _tokenId, bytes32 _part_1, bytes32 _part_2) internal isAdmin(msg.sender) {
		iDToCid[_tokenId].part_1 = _part_1;
		iDToCid[_tokenId].part_2 = _part_2;
	}

}