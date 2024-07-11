

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



import "./ERC1400.sol";


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