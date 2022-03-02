// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string private _baseURIvar;
  string private _baseExtension = ".json";
  uint256 private _cost1 = 1 ether;
  uint256 private _cost2 = 2 ether;
  uint256 private _cost3 = 3 ether;
  uint256 private _supply1 = 1000;
  uint256 private _supply2 = 2000;
  uint256 private _maxSupply = 10000;
  uint256 private _maxMintAmount = 500;
  bool private _paused = false;

  mapping(uint256 => uint256) private _predictions;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return _baseURIvar;
  }

  // public
  function mint(uint256 _mintAmount) public payable {
    require(!_paused, "the contract is paused");
    uint256 supply = totalSupply();
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    require(_mintAmount <= _maxMintAmount, "max mint amount per session exceeded");
    require(supply + _mintAmount <= _maxSupply, "max NFT limit exceeded");

    if (msg.sender != owner()) 
    {
        if( (supply + _mintAmount) < _supply1)
        {
            require(msg.value >= _cost1 * _mintAmount, "insufficient funds");
        }
        else if( (supply + _mintAmount) < _supply2 )
        {
            require(msg.value >= _cost2 * _mintAmount, "insufficient funds");
        }
        else
        {
            require(msg.value >= _cost3 * _mintAmount, "insufficient funds");
        }
    }
    
    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }
  
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), _baseExtension))
        : "";
  }

  function makePrediction(uint256 index, uint256 prediction) public
  {
    address sender = msg.sender;
    uint256 balance = balanceOf(sender);

    require(balance > 0, "you need at least one NFT");
    uint256 id = tokenOfOwnerByIndex(msg.sender, index);
    _predictions[id] = prediction;
  }

  function getPrediction(uint256 _id) public view returns (uint256)
  {
    return (_predictions[_id]);
  }


  function setCost1(uint256 _newCost) public onlyOwner {
    _cost1 = _newCost;
  }

  function setCost2(uint256 _newCost) public onlyOwner {
    _cost2 = _newCost;
  }

  function setCost3(uint256 _newCost) public onlyOwner {
    _cost3 = _newCost;
  }

  function setSupply1(uint256 _newSupply) public onlyOwner {
    _supply1 = _newSupply;
  }

  function setSupply2(uint256 _newSupply) public onlyOwner {
    _supply2 = _newSupply;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    _maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    _baseURIvar = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    _baseExtension = _newBaseExtension;
  }
  
  function pause(bool _state) public onlyOwner {
    _paused = _state;
  }

  function withdraw() public payable onlyOwner {
      require(payable(msg.sender).send(address(this).balance));
  }
}