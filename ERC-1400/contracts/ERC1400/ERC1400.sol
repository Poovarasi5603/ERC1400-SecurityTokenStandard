
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./IERC1400.sol";
import "./KYC.sol";
import "./IPFShashStorage.sol";
import "../math/KindMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



 /**************************************** ERC1400 TokenStandard **************************************/



contract ERC1400 is IERC1400,KYC,IPFShashStorage{



 /**************************************** Token behaviours **************************************/
  bool internal _isIssuable;


/********************************** ERC20 Token mappings ****************************************/

    mapping(address => mapping(string => uint256)) internal _balances;

    mapping(string => uint256) internal _totalSupply;


/**************************************** Documents *********************************************/
struct Document {
        bytes32 docHash; // Hash of the document
        uint256 lastModified; // Timestamp at which document details was last modified
        string uri; // URI of the document that exist off-chain
    }

    // mapping to store the documents details in the document
    mapping(bytes32 => Document) internal _documents;

    // mapping to store the document name indexes
    mapping(bytes32 => uint256) internal _docIndexes;

    // Array use to store all the document name present in the contracts
    bytes32[] _docNames;



/// Constructor

constructor(address _adminAddress) KYC(_adminAddress) {
        
        _isIssuable = true;
     
    }


/***************************************************************************************************/
/****************************** FUNCTIONS (ERC20 INTERFACE) ****************************/
/***************************************************************************************************/

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply(string memory symbol) public view returns (uint256) {
        return _totalSupply[symbol];
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner,string memory symbol) public view returns (uint256) {
        return _balances[owner][symbol];
    }



    function transfer(address _to, string memory symbol,uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to,symbol, _value);
        return true;
    }

    
       function _transfer(address from, address _to,string memory symbol, uint256 _value) internal {
        require(_value <= _balances[from][symbol]);
        require(_to != address(0));
        _balances[from][symbol] -= _value ;
        _balances[_to][symbol] += _value;
        //emit _transfer(from, to,symbol, value);
    }


 /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account,string memory symbol, uint256 value) internal {
        require(account != address(0), "Account cannot be zero address");

        _totalSupply[symbol] += value;
        _balances[account][symbol] += value;
        //emit _transfer(address(0), account,symbol, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account,string memory symbol, uint256 value) internal {
        require(account != address(0), "Account cannot be zero address");

        require(value <= _balances[account][symbol]);

        _totalSupply[symbol] -= value;
        _balances[account][symbol] -= value;
        //emit _transfer(account, address(0), symbol,value);
    }

/***************************************************************************************************/
/****************************** EXTERNAL FUNCTIONS (ERC1400 INTERFACE) ****************************/
/***************************************************************************************************/



/************************************* Document Management **************************************/
    /**
     * @notice Used to attach a new document to the contract, or update the URI or hash of an existing attached document
     * @dev Can only be executed by the owner of the contract.
     * @param _name Name of the document. It should be unique always
     * @param _uri Off-chain uri of the document from where it is accessible to investors/advisors to read.
     * @param _documentHash hash (of the contents) of the document.
     */
    function setDocument(bytes32 _name, string calldata _uri, bytes32 _documentHash) external onlyOwner {
        
        require(_name != bytes32(0), "Zero value is not allowed");
        require(bytes(_uri).length > 0, "Should not be a empty uri");
        if (_documents[_name].lastModified == uint256(0)) {
            _docNames.push(_name);
            _docIndexes[_name] = _docNames.length;
        }
        _documents[_name] = Document(_documentHash, block.timestamp, _uri);
        emit DocumentUpdated(_name, _uri, _documentHash);
    }

    /**
     * @notice Used to remove an existing document from the contract by giving the name of the document.
     * @dev Can only be executed by the owner of the contract.
     * @param _name Name of the document. It should be unique always
     */
    function removeDocument(bytes32 _name) external onlyOwner {
        require(_documents[_name].lastModified != uint256(0), "Document should be existed");
        uint256 index = _docIndexes[_name] - 1;
        if (index != _docNames.length - 1) {
            _docNames[index] = _docNames[_docNames.length - 1];
            _docIndexes[_docNames[index]] = index + 1; 
        }
        _docNames.pop();
        emit DocumentRemoved(_name, _documents[_name].uri, _documents[_name].docHash);
        delete _documents[_name];
    }

    /**
     * @notice Used to return the details of a document with a known name (`bytes32`).
     * @param _name Name of the document
     * @return string The URI associated with the document.
     * @return bytes32 The hash (of the contents) of the document.
     * @return uint256 the timestamp at which the document was last modified.
     */
    function getDocument(bytes32 _name) external view returns (string memory, bytes32, uint256) {
        return (
            _documents[_name].uri,
            _documents[_name].docHash,
            _documents[_name].lastModified
        );
    }

    /**
     * @notice Used to retrieve a full list of documents attached to the smart contract.
     * @return bytes32 List of all documents names present in the contract.
     */
    function getAllDocuments() external view returns (bytes32[] memory) {
        return _docNames;
    }
   


 /****************************************** Transfers *******************************************/



 function transferWithData(address _to,string memory symbol, uint256 _value)  override public{
         require(validateData(msg.sender, _to), "Invalid data provided");
        transfer( _to,symbol, _value);
        
    }

    function validateData(address _from, address _to) internal view returns (bool) {
        // Example of regulatory compliance data validation
        // The data format is expected to include a KYC identifier 
        // For simplicity, let's assume the data contains the recipient's address encoded in the first 20 bytes

        require(super.KYCVerified(_from), "Sender address not KYC verified");
        require(super.KYCVerified(_to), "Recipient address not KYC verified");
        require(super.IndianResident(_from), "Sender is not an Indian resident");
        require(super.IndianResident(_to), "Recipient is not an Indian resident");

         return true;
    }

 function isIssuable() public view returns (bool) {
        return _isIssuable;
    }


/**************************************** Token Issuance ****************************************/



    function issue(address _tokenHolder,string memory symbol, uint256 _value)  override public onlyOwner {
        require(validateData(msg.sender, _tokenHolder), "Invalid data provided");
        require(isIssuable(), "Issuance is closed");
        _mint(_tokenHolder, symbol, _value);

        emit Issued(msg.sender, _tokenHolder,symbol, _value);
    }



/*************************************** Token Redemption ***************************************/



    function redeem(address _tokenHolder,string memory symbol,uint256 _value) public {
        
        _burn(_tokenHolder,symbol, _value);

        emit Redeemed(msg.sender, _tokenHolder,symbol, _value);
    }


/************************************** Transfer Validity ***************************************/


 /**
     * @notice Transfers of securities may fail for a number of reasons. So this function will used to understand the
     * cause of failure by getting the byte value. Which will be the ESC that follows the EIP 1066. ESC can be mapped 
     * with a reson string to understand the failure cause, table of Ethereum status code will always reside off-chain
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     * @return bool It signifies whether the transaction will be executed or not.
     * @return byte Ethereum status code (ESC)
     * @return bytes32 Application specific reason code 
     */
    function canTransfer(address _to, string memory symbol,uint256 _value) external view returns (bool, bytes1, bytes32) {
        require(validateData(msg.sender, _to), "Invalid data provided");
        
        if (_balances[msg.sender][symbol] < _value)
            return (false, 0x52, bytes32(0));

        else if (_to == address(0))
            return (false, 0x57, bytes32(0));

        else if (!KindMath.checkAdd(_balances[_to][symbol], _value))
            return (false, 0x50, bytes32(0));
        return (true, 0x51, bytes32(0));
    }


}