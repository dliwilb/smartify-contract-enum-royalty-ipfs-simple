// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "./ownable.sol";

contract AdminWhitelist is Ownable {

    bool public allowAdmin;
    bool public whitelistWaiver;

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


    event adminAdded              (address indexed newAdmin,      address indexed approvedBy);
    event adminRemoved            (address indexed removedAdmin,  address indexed removedBy);
    event userAdded               (address indexed newUser,       address indexed approvedBy);
    event userRemoved             (address indexed removedUser,   address indexed removedBy);  
    event waiverStatusChange      (bool    indexed _toStatus,     address indexed changedBy);
    event allowAdminStatusChange  (bool    indexed _toStatus,     address indexed changedBy);

    function setAllowAdmin(bool _allowAdmin) public onlyOwner {
      allowAdmin = _allowAdmin;
      emit allowAdminStatusChange(_allowAdmin, msg.sender);
    }

    function setWhitelistWaiver(bool _whitelistWaiver) public onlyOwner {
      whitelistWaiver = _whitelistWaiver;
      emit waiverStatusChange(_whitelistWaiver, msg.sender);
    }

    function addAdmin(address _addressToMakeAdmin) public onlyOwner {
      require(!adminAddresses[_addressToMakeAdmin], "Address is already admin");

      adminAddresses[_addressToMakeAdmin] = true;
      emit adminAdded(_addressToMakeAdmin, msg.sender);
    }

    function removeAdmin(address _addressToRemoveFromAdmin) public onlyOwner {
      require(adminAddresses[_addressToRemoveFromAdmin], "Address is not admin");

      adminAddresses[_addressToRemoveFromAdmin] = false;
      emit adminRemoved(_addressToRemoveFromAdmin, msg.sender);
    }

    function verifyAdmin(address _adminAddress) public view returns(bool) {
      bool userIsAdmin = adminAddresses[_adminAddress];
      return userIsAdmin;
    }

    function addUser(address _addressToWhitelist) public isAdmin(msg.sender) {
      require(!whitelistedAddresses[_addressToWhitelist], "Address is already whitelisted");

      whitelistedAddresses[_addressToWhitelist] = true;
      emit userAdded(_addressToWhitelist, msg.sender);
    }

    function removeUser(address _addressToRemove) public isAdmin(msg.sender) {
      require(whitelistedAddresses[_addressToRemove], "Address is not whitelisted");

      whitelistedAddresses[_addressToRemove] = false;
      emit userRemoved(_addressToRemove, msg.sender);
    }

    function verifyUser(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
      return userIsWhitelisted;
    }


}