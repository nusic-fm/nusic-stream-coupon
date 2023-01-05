// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";


contract NusicStreamCoupon is ERC1155Supply, Pausable, Ownable  {
    using Address for address;
    using Strings for uint256;
    using ECDSA for bytes32;

    string public defaultURI;

    address public treasuryAddress;
    address public managerAddress;
    uint256 public tokenMinted;

    string private _name;
    string private _symbol;

    struct MusicConfig {
        address contractAddress; // The contract address
        uint256 tokenId; // The ID of the token on the contract
        uint256 contractType; // Music collection type -- 1 for EDITION or 2 for COLLECTION
        address contractOwner; // NFT Contract Owner Address,
        uint256 fractions;
        string tokenURI;
    }

    mapping(uint256 => string) private _tokenURIs;

    mapping(address => uint256[]) public usersMusic;  // userAddress => configIds
    mapping(uint256 => MusicConfig) public tokenMapping; // configId => MusicConfig
    mapping(address => uint256) public contractType;  // contract address => 1 for EDITION or 2 for COLLECTION

    mapping(address => mapping(uint256 => uint256)) public configMapping; // contractAddress => tokenId => configId
    mapping(uint256 => uint256) public configTokenMapping; // configId => token Id in this contract

    mapping(uint256 => mapping(address => uint256)) public streamCount; // tokenId => holder address => stream count

    event Claimed(address indexed to, uint256 tokenId, address nftContractAddress, uint256 nftContractTokenNumber);

    constructor(string memory name_, string memory symbol_) ERC1155(""){
        _name = name_;
        _symbol = symbol_;
        defaultURI = "https://bafkreigj4ynovugfqsewvfgche6ql5gozlox7p5cjfiw7uelfscfbk3keu.ipfs.nftstorage.link/";
    }

    modifier onlyOwnerOrManager() {
        require((owner() == msg.sender) || (managerAddress == msg.sender), "Caller needs to Owner or Manager");
        _;
    }

    function setDefaultRI(string memory _defaultURI) public onlyOwnerOrManager {
		defaultURI = _defaultURI;
	}

    function pause() public onlyOwnerOrManager {
        _pause();
    }

    function unpause() public onlyOwnerOrManager {
        _unpause();
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    // OpenSea require proper implementation of URI function just like it is for ERC721
    function uri(uint256 tokenId) public view override returns (string memory) {
        require(exists(tokenId), "Token does not exists");
        string memory _tokenURI = _tokenURIs[tokenId];
        return bytes(_tokenURI).length > 0 ? _tokenURI : defaultURI;
    }

    function setManager(address _manager) public onlyOwner{
        managerAddress = _manager;
    }

/*
    function mintToken(address _to, uint256 _id, uint256 _amount) public idExists(_id) {
        uint256 _tokenSupply = totalSupply(_id); 
        require(_tokenSupply + _amount <= maxSupplyEachToken, "Not enough supply");
        _mint(_to, _id, _amount, "");
        emit TokenMinted(_to, _id, _amount);
    }
*/
    function testEnum(address addr1, address addr2) public {
        //contractType[addr1] = EDITION;
        //contractType[addr2] = COLLECTION;

        //Ownable  own = Ownable(address);
        contractType[addr1] = 1;
        contractType[addr2] = 2;
        
    }

    function registerEdition(address _contractAddress, uint256 _fractions, string memory _tokenURI, bytes calldata signature) public whenNotPaused {
        
        bytes32 msgHash = keccak256(abi.encodePacked(msg.sender, _contractAddress, _fractions));
        bytes32 signedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        require(managerAddress == signedHash.recover(signature), "Signer address mismatch.");
        
        uint256 _configId;
        uint256 _tokenId = 0;
        uint256 _type = 1; // Edition
        //ERC721 _erc721 = ERC721(contractAddress);

        require(contractType[_contractAddress] == 0, "Contract Already Registered as Edition"); 
        //_erc721.owner   

        _configId = uint256(keccak256(abi.encodePacked(_contractAddress, _tokenId, _type)));

        configMapping[_contractAddress][_tokenId] = _configId;
        usersMusic[msg.sender].push(_configId);
        //tokenMinted++;
        //configTokenMapping[_configId] = tokenMinted;
        contractType[_contractAddress] = 1;
        tokenMapping[_configId] = MusicConfig({
            contractAddress: _contractAddress, // The contract address
            tokenId: _tokenId, // The ID of the token on the contract
            contractType: _type, // Music collection type 
            contractOwner: msg.sender, // NFT contract owner
            fractions: _fractions,
            tokenURI:_tokenURI
        });
    }

    function registerCollection(address _contractAddress, uint256 _tokenId, string memory _tokenURI, bytes calldata signature) public whenNotPaused {
        
        bytes32 msgHash = keccak256(abi.encodePacked(msg.sender, _contractAddress, _tokenId));
        bytes32 signedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        require(managerAddress == signedHash.recover(signature), "Signer address mismatch.");
        
        uint256 _configId;
        uint256 _type = 2; // Collection
        //ERC721 _erc721 = ERC721(contractAddress);

        require(contractType[_contractAddress] != 1, "Contract Already Registered as Edition"); 
        if(contractType[_contractAddress] == 2) {
            require(configMapping[_contractAddress][_tokenId] == 0, "Colleciton with given token id already registered");
        }

        _configId = uint256(keccak256(abi.encodePacked(_contractAddress, _tokenId, _type)));

        configMapping[_contractAddress][_tokenId] = _configId;
        usersMusic[msg.sender].push(_configId);
        //tokenMinted++;
        //configTokenMapping[_configId] = tokenMinted;
        contractType[_contractAddress] = 1;
        tokenMapping[_configId] = MusicConfig({
            contractAddress: _contractAddress, // The contract address
            tokenId: _tokenId, // The ID of the token on the contract
            contractType: _type, // Music collection type 
            contractOwner: msg.sender, // NFT contract owner
            fractions: 2,
            tokenURI:_tokenURI
        });
    }
    

    function claim(uint256 _configId, address _contractAddress,uint256 _tokenIdInContract, uint256 _streamCount, uint256 _timestamp, uint256 _fractionCount, bytes calldata signature) public whenNotPaused{

        bytes32 msgHash = keccak256(abi.encodePacked(msg.sender, _contractAddress, _tokenIdInContract, _streamCount, _timestamp));
        bytes32 signedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        require(managerAddress == signedHash.recover(signature), "Signer address mismatch.");
        //_safeMint(msg.sender, tokenMinted);
        //tokenMinted++;
        MusicConfig memory _musicConfig = tokenMapping[_configId];
        require(_musicConfig.contractAddress == _contractAddress, "Incorrect Config provided");

        uint256 _tokenId = configTokenMapping[_configId];
        if(_tokenId == 0) {
            _tokenId = ++tokenMinted;
            configTokenMapping[_configId] = _tokenId;
        }
        uint256 _tokenSupply = totalSupply(_tokenId); 
        require(_tokenSupply + _fractionCount <= _musicConfig.fractions, "Cannot mint too much");
        

        _mint(msg.sender, _tokenId, _fractionCount, "");

        emit Claimed(msg.sender, tokenMinted, address(0), 1);

        /*
        for(uint256 i=0; i<tokenQuantity; i++) {
            tokenMinted++;// if want to start with zero than remove then use prefix ++
            _safeMint(msg.sender, tokenMinted); 
            emit Minted(msg.sender, tokenQuantity, msg.value, "CryptoNative");
        }*/
    }
}