// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


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


/**************************************** IPFShashStorage contract *******************************************/


contract IPFShashStorage {

    struct File {
        string fileName;
        string ipfsHash;
    }

    // Mapping from user address to a mapping of file name to File struct
    mapping(address => mapping(string => File)) private userFiles;


    // Event emitted when a file is uploaded
    event FileUploaded(address indexed user, string fileName, string ipfsHash);

    // Function to upload a file
    function upload(string memory fileName, string memory ipfsHash) public {
        require(bytes(userFiles[msg.sender][fileName].ipfsHash).length == 0, "File already exists");
        userFiles[msg.sender][fileName] = File(fileName, ipfsHash);
        emit FileUploaded(msg.sender, fileName, ipfsHash);
    }

    // Function to get the IPFS hash of a file for the caller
    function getIPFSHash(string memory fileName) public view returns (string memory) {
        require(bytes(userFiles[msg.sender][fileName].ipfsHash).length > 0, "File not found");
        return userFiles[msg.sender][fileName].ipfsHash;
    }

    // Function to check if a file is stored for the caller
    function isFileStored(string memory fileName) public view returns (bool) {
        return bytes(userFiles[msg.sender][fileName].ipfsHash).length > 0;
    }

    // Function to get the IPFS hash of a file for a specific user
    function getIPFSHashForUser(address user, string memory fileName) public view returns (string memory) {
        require(bytes(userFiles[user][fileName].ipfsHash).length > 0, "File not found");
        return userFiles[user][fileName].ipfsHash;
    }

    // Function to check if a file is stored for a specific user
    function isFileStoredForUser(address user, string memory fileName) public view returns (bool) {
        return bytes(userFiles[user][fileName].ipfsHash).length > 0;
    }

}



library KindMath {

    /**
     * @dev Multiplies two numbers, return false on overflow.
     */
    function checkMul(uint256 a, uint256 b) internal pure returns (bool) {
        // Gas optimization: this is cheaper than requireing 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return true;
        }

        uint256 c = a * b;
        if (c / a == b)
            return true;
        else 
            return false;
    }

    /**
    * @dev Subtracts two numbers, return false on overflow (i.e. if subtrahend is greater than minuend).
    */
    function checkSub(uint256 a, uint256 b) internal pure returns (bool) {
        if (b <= a)
            return true;
        else
            return false;
    }

    /**
    * @dev Adds two numbers, return false on overflow.
    */
    function checkAdd(uint256 a, uint256 b) internal pure returns (bool) {
        uint256 c = a + b;
        if (c < a)
            return false;
        else
            return true;
    }
}



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



/************************************** SecurityTokenOffering ***************************************/


contract STO is ERC1400{

    struct TokenInfo {
        address tokenOwner;
        string name;
        uint256 totalSupply;
        uint256 availableSupply;
        uint256 price; // Price per token in fiat
    }

    // Mapping from token symbol to TokenInfo
    mapping(string => TokenInfo) public tokens;
    
    string public symbol;

    // Address where all tokens will be minted initially
    address  public adminAddress;
    
    
    event TokenCreated(address indexed tokenOwner,string indexed symbol, string name, uint256 totalSupply, uint256 price);
    event TokensAllocated(address indexed investor, string indexed symbol, uint256 _value);
    event TokensBurned(address indexed _tokenHolder, string indexed symbol, uint256 _value);


    constructor(address _adminAddress) ERC1400(_adminAddress){
        adminAddress = _adminAddress;
       
    }

    // Function to create a new token
    function createToken(address _tokenOwner,string memory _name, string memory _symbol, uint256 _totalSupply, uint256 _price)  external onlyOwner {
       
        symbol = _symbol;
         // Ensure KYC is completed
        require(super.KYCVerified(_tokenOwner), " address not KYC verified");
        // Ensure document is verified
        require(super.DocumentVerified(_tokenOwner), " address not document verified");  

        require(tokens[symbol].totalSupply == 0, "Token with this symbol already exists");
         
        tokens[symbol].tokenOwner = _tokenOwner;
        tokens[symbol].name = _name;
        tokens[symbol].totalSupply = _totalSupply;
        tokens[symbol].availableSupply = _totalSupply;
        tokens[symbol].price = _price;

        super.issue(adminAddress,symbol,_totalSupply);

        emit TokenCreated(_tokenOwner,symbol, _name, _totalSupply, _price);
    }

    // Function to get token details by token symbol
    function getTokenDetails(string memory _symbol) external view returns (address,string memory, uint256,uint256, uint256) {
    
        TokenInfo storage token = tokens[_symbol];
        return (token.tokenOwner,token.name, token.totalSupply,token.availableSupply, token.price);
    }

    // Admin function to allocate tokens to investor upon receiving fiat currency
    function allocateTokens(address investor,string memory _symbol, uint256 _value) public onlyOwner {
         symbol = _symbol;
        require(isIssuable(), "Tokens are not issuable");
        TokenInfo storage token = tokens[symbol];
        require(token.totalSupply > 0, "Token does not exist");
        require(_value > 0, "Amount must be greater than 0");
        require(_value <= token.totalSupply * 20 / 100, "Cannot allocate more than 20% of the total supply");

        require(token.availableSupply >= _value, "Not enough tokens available");
        token.availableSupply -= _value;
        
        super.transferWithData(investor,symbol,_value);

        emit TokensAllocated(investor, symbol, _value);
    }


  //burns tokens from a user’s balance

  function BuybackTokens(address _tokenHolder,string memory _symbol, uint256 _value) external onlyOwner {
   
        TokenInfo storage token = tokens[_symbol];
      require(token.totalSupply > 0, "Token does not exist");
      require(_value > 0, "Amount must be greater than zero");
      token.totalSupply-= _value;

      super.redeem(_tokenHolder,_symbol,_value);

      emit TokensBurned(_tokenHolder, _symbol, _value);
}

}