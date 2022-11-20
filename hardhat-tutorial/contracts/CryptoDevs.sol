// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;
//deployed to  0x1bb665CC91b7fC0714f1bf15dBA14A8B0A128769
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    /**
     * _baseTokenURI for computing tokenURI, if set the resulting uri for the token will be the concatenation of the baseURI and tokenId
     */
    string _baseTokenURI;

//price of one crpto dev nft 
uint256 public _price = 0.01 ether;
//pausing the contract incase of an emergency
bool public _paused;
//max no of cryptodevs
uint256 public maxTokenIds = 20;
//total no of tokenIds minted
uint256 public tokenIds;
//whitelist contract instance 
IWhitelist whitelist;
//boolean to keep track of whether presale started or not 
bool public presaleStarted;
//timestamp for when presale would end 
uint256 public presaleEnded;

modifier onlyWhenNotPaused {
    require(!_paused, "contract currently paused");
    _;
}
//constructor takes in  a name, symbol, takes baseURI to set _baseTokenURI  & an instance of whitelist dapp
constructor (string memory baseURI, address whitelistContract) ERC721("CryptoDevs", "CD") {
    _baseTokenURI = baseURI;
    whitelist = IWhitelist(whitelistContract);
}
/**
 * @dev startPresale starts a presale for whitelisted addresses
 */
function startPresale() public onlyOwner {
    presaleStarted = true;//set presale to be current timestamp + 5 mins 
    presaleEnded = block.timestamp + 5 minutes;
}
/**
 * presaleMint allowing a user to mint one nft per transaction during the presale 
 */
function presaleMint() public payable onlyWhenNotPaused {
    require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
    require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
    require(tokenIds < maxTokenIds, "Exceeded maximum cryptodevs supply");
    require(msg.value >=_price, "Ether sent is not correct");
    tokenIds += 1;
    //_safeMint ensures that address being minted to is a contract, then it knows how to deal with ERC720 if not contract, it works the same way as a mint function 
    _safeMint(msg.sender, tokenIds);


}
    /**
     * mint allows a user to mint 1 NFT per transaction after the presale has ended
     */
function mint() public payable onlyWhenNotPaused {
    require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not started");
    require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs Supply");
    require(msg.value >= _price, "Ether sent is not correct");
    tokenIds+=1;
    _safeMint(msg.sender, tokenIds);
}
/**
 * _baseURI overrides openzeppelins defalt which returns an empty string for the baseURI
 */
function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
}
/**
 * setPaused makes the contract paused or unPaused 
 */
function setPaused(bool val) public onlyOwner {
    _paused = val;
}
/**
 * withdraw sends all the eth in the contract to the contract owner
 */
function withdraw() public onlyOwner {
    address _owner = owner();
    uint256 amount = address(this).balance;
    (bool sent, ) = _owner.call{value: amount}("");
    require(sent, "Failed to send Ether");
}
//function to receive ether, msg.data must be empty
receive() external payable{} 
//fallback function is called when msg.data is non-empty
fallback() external payable {}


}