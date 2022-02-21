// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "./ownable.sol";

contract AdminWhitelist is Ownable {

    bool public allowAdmin;
    bool public whitelistWaiver;
	bool public userAddsUser;

    mapping(address => bool) adminAddresses;
    mapping(address => bool) whitelistedAddresses;


    constructor() {
		owner = msg.sender;
    }

    modifier isAdmin(address _address) {
		if (msg.sender != owner){
			require(allowAdmin, "Admin delegation is suspended");
		}
		require(adminAddresses[_address], "You need to be admin");
		_;
    }

    modifier isWhitelisted(address _address) {
		require(whitelistedAddresses[_address], "You need to be whitelisted");
		_;
    }

    modifier isWhitelistWaived() {
		require(whitelistWaiver, "Whitelist requirement needs to be waived");
		_;
    }


    event AdminAdded			(address indexed newAdmin,      address indexed approvedBy);
    event AdminRemoved			(address indexed removedAdmin,  address indexed removedBy);
    event UserAddedByAdmin		(address indexed newUser,       address indexed approvedBy);
	event UserAddedByUser		(address indexed newUser,       address indexed approvedBy);
    event UserRemoved			(address indexed removedUser,   address indexed removedBy);  
    event SetWhitelistWaiver	(bool    indexed _toStatus,     address indexed changedBy);
    event SetAllowAdmin			(bool    indexed _toStatus,     address indexed changedBy);
	event SetUserAddsUser		(bool    indexed _toStatus,     address indexed changedBy);

    function setAllowAdmin(bool _allowAdmin) external onlyOwner {
		allowAdmin = _allowAdmin;
		emit SetAllowAdmin(_allowAdmin, msg.sender);
    }

    function setUserAddsUser(bool _userAddsUser) external onlyOwner {
		require(allowAdmin, "Admin delegation is suspended");

		userAddsUser = _userAddsUser;
		emit SetUserAddsUser(_userAddsUser, msg.sender);
    }

    function setWhitelistWaiver(bool _whitelistWaiver) external onlyOwner {
		whitelistWaiver = _whitelistWaiver;
		emit SetWhitelistWaiver(_whitelistWaiver, msg.sender);
    }

    function addAdmin(address _addressToMakeAdmin) external onlyOwner {
		require(!adminAddresses[_addressToMakeAdmin], "Address is already admin");

		adminAddresses[_addressToMakeAdmin] = true;
		emit AdminAdded(_addressToMakeAdmin, msg.sender);
    }

    function removeAdmin(address _addressToRemoveFromAdmin) external onlyOwner {
		require(adminAddresses[_addressToRemoveFromAdmin], "Address is not admin");

		adminAddresses[_addressToRemoveFromAdmin] = false;
		emit AdminRemoved(_addressToRemoveFromAdmin, msg.sender);
    }

    function verifyAdmin(address _adminAddress) external view returns(bool) {
		bool userIsAdmin = adminAddresses[_adminAddress];
		return userIsAdmin;
    }

	function userAddUser(address _addressToWhitelist) external isWhitelisted(msg.sender) {
		require(userAddsUser, "Users currently cannot add users");
		require(!whitelistedAddresses[_addressToWhitelist], "Address is already whitelisted");

		whitelistedAddresses[_addressToWhitelist] = true;
		emit UserAddedByUser(_addressToWhitelist, msg.sender);
    }

    function adminAddUser(address _addressToWhitelist) external isAdmin(msg.sender) {
		require(!whitelistedAddresses[_addressToWhitelist], "Address is already whitelisted");

		whitelistedAddresses[_addressToWhitelist] = true;
		emit UserAddedByAdmin(_addressToWhitelist, msg.sender);
    }

    function removeUser(address _addressToRemove) external isAdmin(msg.sender) {
		require(whitelistedAddresses[_addressToRemove], "Address is not whitelisted");

		whitelistedAddresses[_addressToRemove] = false;
		emit UserRemoved(_addressToRemove, msg.sender);
    }

    function verifyUser(address _whitelistedAddress) external view returns(bool) {
		bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
		return userIsWhitelisted;
    }


}