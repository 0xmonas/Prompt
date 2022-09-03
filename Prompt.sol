// SPDX-License-Identifier: MIT
// Author: 

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "https://github.com/0xmonas/onechain/blob/main/master/contracts/Base64.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

pragma solidity >=0.8.0 <0.9.0;


contract Prompt is ERC721Enumerable, Ownable {
    error MaxNfts();


    using Strings for uint256;
    mapping(uint256 => string) private wordsToTokenId;
    uint private fee = 0.01 ether;
    uint256 minted = 0;
    mapping (string => bool) public  newString;

    
        string text;
    

    constructor() ERC721("The Prompt", "TPC") {}

    function mint(string memory _Prompt) public payable {
        require(bytes(_Prompt).length <= 421, "MAX LENGTH 421 // Only base64 characters");
        if( newString[_Prompt] == true) {
        revert(); 
        }
        uint256 supply = totalSupply();
        if(supply + 1 > 10000) {
        revert MaxNfts();
      }
       newString[_Prompt] = true;



        if (msg.sender != owner()) {
            require(msg.value >= fee, string(abi.encodePacked("Missing fee of ", fee.toString(), " wei")));
        }

        wordsToTokenId[supply + 1] = _Prompt;
        _safeMint(msg.sender, supply + 1);
        minted += 1;
        
    }


    function buildImage(string memory _Prompt) private pure returns (bytes memory) {
        return
            Base64.encode(
                abi.encodePacked(
                    '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"', " xmlns:xlink='http://www.w3.org/1999/xlink'>",
                    '<rect height="100%" width="100%" y="0" x="0" fill="#0c0c0c"/>',
                    '<defs>',
                    '<path id="path1" d="M7.55,33.94H484M7.55,67.38H484M7.3,100.83H483.74M7.44,134.24H483.88M7.44,167.67H483.88M7.44,201.11H483.88M7.18,234.54H483.62M7.74,267.97H484.19M7.74,301.41H484.19M7.49,334.86H483.92M7.63,368.27H484.07M7.63,401.7H484.07M7.63,435.14H484.07M7.37,468.57H483.8"></path>',
                    '</defs>',
                     '<use xlink:href="#path1" />',
                     '<text font-size="26.47px" fill="#a9f9d5" font-family="Courier New">',
                     '<textPath xlink:href="#path1">', _Prompt,'</textPath>',"</text>"
                     "</svg>"
                )
            );
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        bytes memory title = abi.encodePacked("Prompt #", _tokenId.toString());
        
        string memory tokenWord = wordsToTokenId[_tokenId];
        return
            string(
                bytes.concat(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            "{"
                                '"name":"', title, '",'
                                '"description":"\'', bytes(tokenWord), '\' ",'
                                '"image":"data:image/svg+xml;base64,', buildImage(tokenWord), '"'
                            "}"
                        )
                    )
                )
            );
    }

    function getFee() public view returns (uint) {
        return fee;
    }

    function setFee(uint _newFee) public onlyOwner {
        fee = _newFee;
    }

    function withdraw() public payable onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
}
