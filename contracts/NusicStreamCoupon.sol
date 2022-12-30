// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
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

    enum ContractType {
        Edition,
        Collection
    }

    struct MusicConfig {
        address contractAddress; // The contract address
        uint256 tokenId; // The ID of the token on the contract
        string contractType; // Music collection type
        address contractOwner; // NFT Contract Owner Address
    }

    mapping(uint256 => string) private _tokenURIs;

    mapping(address => uint256[]) public usersMusic;  // userAddress => configIds
    mapping(uint256 => MusicConfig) public tokenMapping; // configId => MusicConfig
    mapping(address => ContractType) public contractType;  // contract address => configId

    mapping(address => mapping(uint256 => uint256)) public configMapping; // contractAddress => tokenId => configId
    mapping(uint256 => uint256) public configTokenMapping; // configId => token Id in this contract


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
    function registerEdition(address contractAddress) public whenNotPaused {
        uint256 _configId;
        uint256 _tokenId = 0;
        string memory _type = "Edition";
        _configId = uint256(keccak256(abi.encodePacked(contractAddress, _tokenId, _type)));



        configMapping[contractAddress][_tokenId] = _configId;
        usersMusic[msg.sender].push(_configId);
        tokenMinted++;
        configTokenMapping[_configId] = tokenMinted;
        contractConfig[contractAddress] = _configId;
        tokenMapping[_configId] = MusicConfig({
            contractAddress: contractAddress, // The contract address
            tokenId: _tokenId, // The ID of the token on the contract
            contractType: _type, // Music collection type 
            contractOwner: msg.sender // NFT contract owner
        });
/*
        mapping(address => uint256[]) public usersMusic;  // userAddress => configIds
    mapping(uint256 => MusicConfig) public tokenMapping; // configId => MusicConfig

    mapping(address => mapping(uint256 => uint256)) public configMapping; // contractAddress => tokenId => configId
    mapping(uint256 => uint256) public configTokenMapping; // configId => token Id of Nusic Stream coupon contract
*/
    }

    function claim(uint256 streamCount, uint256 timestamp, bytes calldata signature) public whenNotPaused{

        bytes32 msgHash = keccak256(abi.encodePacked(msg.sender, streamCount,timestamp, address(this)));
        bytes32 signedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        require(owner() == signedHash.recover(signature), "Signer address mismatch.");
        //_safeMint(msg.sender, tokenMinted);
        _mint(msg.sender, tokenMinted, 5, "");
        tokenMinted++;
        emit Claimed(msg.sender, tokenMinted, address(0), 1);

        /*
        for(uint256 i=0; i<tokenQuantity; i++) {
            tokenMinted++;// if want to start with zero than remove then use prefix ++
            _safeMint(msg.sender, tokenMinted); 
            emit Minted(msg.sender, tokenQuantity, msg.value, "CryptoNative");
        }*/
    }
}