// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC1400 {
    // Document Management

    function getDocument(bytes32 _name) external view returns (string memory, bytes32, uint256);
    function setDocument(bytes32 _name, string calldata _uri, bytes32 _documentHash) external;
    function removeDocument(bytes32 _name) external;
    function getAllDocuments() external view returns (bytes32[] memory);

    // Token Transfers
    
    function transferWithData(address _to,string memory symbol, uint256 _value) external;
    
    // Issuance and Redemption
    
    function isIssuable() external view returns (bool);
    function issue(address _tokenHolder,string memory symbol, uint256 _value) external;
    function redeem(address _tokenHolder,string memory symbol,uint256 _value) external;
    
    // Transfer Validity
   
    function canTransfer(address _to, string memory symbol,uint256 _value) external view returns (bool, bytes1, bytes32);
    
   // Token Information
    function totalSupply(string memory symbol) external view returns (uint);
    function balanceOf(address tokenOwner,string memory symbol) external view returns (uint balance);
    function transfer(address _to,string memory symbol, uint value) external returns (bool success);

 
 /**************************************** Events **************************************/
    // Document Management
    event DocumentUpdated(bytes32 indexed _name, string _uri, bytes32 _documentHash);
    event DocumentRemoved(bytes32 indexed _name, string _uri, bytes32 _documentHash);

   // Token Transfers
    event TransferWithData(address indexed from, address indexed to, string  symbol,uint256 value);
    
  // Issuance and Redemption
    event Issued(address indexed _operator, address indexed _to,string symbol, uint256 _value);
    event Redeemed(address indexed _operator, address indexed _from,string symbol, uint256 _value);


}