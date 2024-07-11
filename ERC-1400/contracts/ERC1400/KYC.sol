

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**************************************** KYC contract *******************************************/

contract KYC is Ownable{

    mapping(address => bool) public isKYCCompleted;
    mapping(address => bool) public isIndianResident;
    mapping(address => string) public aadharNumber;
    mapping(address => bool) public isDocumentVerified;
   
constructor(address initialOwner) Ownable(initialOwner) {
       
    }

    
    function completeKYC(address _user, string memory _aadharNumber) public onlyOwner {
        require(bytes(_aadharNumber).length == 12, "Invalid Aadhar number");
        // Mock Aadhar verification process
        isKYCCompleted[_user] = true;
        isIndianResident[_user] = true; // Assume that Aadhar verification implies Indian residency
        aadharNumber[_user] = _aadharNumber;
    }

    function revokeKYC(address _user) public onlyOwner {
        isKYCCompleted[_user] = false;
        isIndianResident[_user] = false;
        aadharNumber[_user] = "";
    }
	
    function KYCVerified(address _addr) public view returns(bool) {
        return isKYCCompleted[_addr];
    }

    function IndianResident(address _addr) public view returns(bool) {
        return isIndianResident[_addr];
    }

    function setDocumentVerified(address _addr) public onlyOwner {
        isDocumentVerified[_addr] = true;
    }

    function setDocumentRevoked(address _addr) public onlyOwner {
        isDocumentVerified[_addr] = false;
    }
   
   function DocumentVerified(address _addr) public view returns(bool) {
        return isDocumentVerified[_addr];
    }
    
	}

