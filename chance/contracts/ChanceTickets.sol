//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";

contract ChanceTickets is Ownable, ERC1155Pausable {
    using SafeMath for uint256;
    using Strings for uint256;

    string internal chanceBaseURI = "";
    uint256 public constant saleEnd = 1648247583;
    uint256 public constant saleStart = 1648161183;
    address public redempionAddress;

    /*
     * type: 0 = single, 1 = bundle of 5, 2 = bundle of 10
     */
    enum TokenOptions {
        Silver,
        Gold,
        Platinum,
        Token
    }

    constructor(string memory _chanceBaseURIi) ERC1155(_chanceBaseURIi) {
        chanceBaseURI = _chanceBaseURIi;
    }

    function setContract(address _contract) public onlyOwner {
        redempionAddress = _contract;
    }

    modifier onlyRedempion() {
        require(
            msg.sender == redempionAddress,
            "Only Redempion contract can call this."
        );
        _;
    }

    function burn(
        address from,
        uint256 id,
        uint256 amount
    ) external onlyRedempion {
        require(
            balanceOf(from, uint256(TokenOptions.Token)) > 0,
            "Tokens: No tokens to be burnt"
        );
        _burn(from, id, amount);
    }

    function togglePause() public onlyOwner {
        if (paused()) {
            _unpause();
        } else {
            _pause();
        }
    }

    function purchaseTicket(TokenOptions _option, uint32 _quantity)
        public
        payable
        whenNotPaused
    {
        _purchaseTicketTo(msg.sender, _option, _quantity);
    }

    function _purchaseTicketTo(
        address _to,
        TokenOptions _option,
        uint32 _quantity
    ) public payable whenNotPaused {
        require(_to != address(0), "A");
        // require(block.timestamp > saleStart && block.timestamp < saleEnd, "T");
        require(_quantity > 0 && _quantity <= 3, "Q");
        require(
            _option == TokenOptions.Silver ||
                _option == TokenOptions.Gold ||
                _option == TokenOptions.Platinum,
            "O"
        );

        uint32 numTokens = 1;
        uint256 tokenPrice = 0.07 ether;

        if (_option == TokenOptions.Gold) {
            tokenPrice = 0.3 ether;
            numTokens = 5;
        } else if (_option == TokenOptions.Platinum) {
            numTokens = 10;
            tokenPrice = 0.55 ether;
        }

        uint256 totalPrice = _quantity * tokenPrice;

        require(msg.value >= totalPrice, "I");

        _mint(msg.sender, uint256(_option), _quantity, "");
        _mint(msg.sender, uint256(TokenOptions.Token), numTokens, "");
    }

    function uri(uint256 _optionId)
        public
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(chanceBaseURI, _optionId.toString()));
    }

    function withdrawTo() public onlyOwner {
        // verify withdrawal address is set
        require(msg.sender != address(0), "A");

        // ETH value of contract
        uint256 value = address(this).balance;

        // verify sale balance is positive (non-zero)
        require(value > 0, "ZB");

        // send the sale balance minus the developer fee
        // to the withdrawer
        payable(msg.sender).transfer(value);
    }
}
