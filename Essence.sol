// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IRarity {
    function ownerOf(uint256) external view returns (address);

    function level(uint256) external view returns (uint256);
}

contract Essence is ERC20 {
    using SafeMath for uint256;
    IRarity constant rarity =
        IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    address payable beneficiary;
    uint256 public register_fee;
    uint256 private immutable _cap;
    mapping(uint256 => bool) public is_registered;

    event Registered(uint256 token_id);

    constructor() ERC20("Essence", "ESS") {
        beneficiary = payable(msg.sender);
        _cap = 198 * 10**28;
        register_fee = 5 * 10**16;
        _mint(msg.sender, 132 * 10**28);
    }

    function pre_register(uint256 token_id) external payable {
        require(
            rarity.ownerOf(token_id) == msg.sender,
            "You are not the token holder"
        );
        require(!is_registered[token_id], "This token has been registered");
        require(msg.value == register_fee);
        beneficiary.transfer(msg.value);
        uint256 _level = rarity.level(token_id);
        uint256 reward = _level.mul(1000 * 10**18);
        if (reward.add(ERC20.totalSupply()) <= _cap) {
            _mint(msg.sender, reward);
        } else {
            _mint(msg.sender, _cap.sub(ERC20.totalSupply()));
        }
        is_registered[token_id] = true;
        emit Registered(token_id);
    }

    function register(uint256 token_id) external payable {
        require(
            rarity.ownerOf(token_id) == msg.sender,
            "You are not the token holder"
        );
        require(!is_registered[token_id], "This token has been registered");
        require(msg.value == register_fee);
        beneficiary.transfer(msg.value);
        is_registered[token_id] = true;
        emit Registered(token_id);
    }

    function cap() public view returns (uint256) {
        return _cap;
    }
}
