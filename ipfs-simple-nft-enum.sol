// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./admin-whitelist.sol";
import "./nf-token-metadata-enumerable.sol";
import "./ipfs-tools.sol";

contract ipfsSimpleNFT is NFTokenMetadataEnumerable, AdminWhitelist {

    bool public useIpfsHardcoded;
    bool public useIpfs;   				// uses https if false
	bool public tokenUriHardcoded;
	bool public allowSetUri;
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


	function hardcodeTokenUri() external onlyOwner {
		tokenUriHardcoded = true;
	}

	event SetTokenUri(uint256 indexed _tokenId, bytes32 _part_1, bytes32 _part_2, address _setBy);

	function setTokenUri(uint256 _tokenId, bytes32 _part_1, bytes32 _part_2) external isAdmin(msg.sender) {
		require(!tokenUriHardcoded, 'TokenURI can no longer change');
		require(allowSetUri, 'Change is currently not allowed');

		iDToCid[_tokenId].part_1 = _part_1;
		iDToCid[_tokenId].part_2 = _part_2;
		emit SetTokenUri(_tokenId, _part_1, _part_2, msg.sender);
	}

}