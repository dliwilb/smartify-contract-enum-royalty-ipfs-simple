// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Ownable {
	address public owner;
	address public nextOwner;
	
	constructor () {
		owner = msg.sender;
	}

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner only");
        _;
    }

    modifier onlyOwners() {
		bool isOwner = (msg.sender == owner || msg.sender == nextOwner);
        require(isOwner, "Owners only");
        _;
    }

	function nameNextOwner(address _nextOwner) external onlyOwner {
		nextOwner = _nextOwner;
	}

	function claimOwnership() external {
		require(msg.sender == nextOwner);
		require(msg.sender != address(0));
		
		owner = nextOwner;
		nextOwner = address(0);
	}
}
