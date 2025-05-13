// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract LntPreDeposit is Ownable, Multicall, IERC721Receiver, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;

    IERC721 public nft;
    uint256 public totalDeposit;
    mapping(address => EnumerableSet.UintSet) stakedNFTs;

    event NFTStaked(address indexed user, uint256 indexed tokenId);
    event NFTUnstaked(address indexed user, uint256 indexed tokenId);

    constructor(address erc721) Ownable(msg.sender) {
        nft = IERC721(erc721);
    }

    function deposit(uint256 nftId) external nonReentrant {
        require(nft.ownerOf(nftId) == _msgSender(), "Owner error");
        require(
            nft.isApprovedForAll(_msgSender(), address(this)) || nft.getApproved(nftId) == address(this), "Not approved"
        );
        nft.transferFrom(_msgSender(), address(this), nftId);
        stakedNFTs[_msgSender()].add(nftId);
        totalDeposit += 1;
        emit NFTStaked(_msgSender(), nftId);
    }

    function withdraw(uint256 nftId) external nonReentrant {
        require(stakedNFTs[_msgSender()].contains(nftId), "Not find nft");
        nft.transferFrom(address(this), _msgSender(), nftId);
        stakedNFTs[_msgSender()].remove(nftId);
        totalDeposit -= 1;
        emit NFTUnstaked(_msgSender(), nftId);
    }

    function deposited(address user) external view returns (uint256[] memory) {
        return stakedNFTs[user].values();
    }

    function depositedCount(address user) external view returns (uint256) {
        return stakedNFTs[user].length();
    }

    function deposited(address user, uint256 count, uint256 skip) external view returns (uint256[] memory) {
        uint256[] memory res = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            res[i] = stakedNFTs[user].at(i + skip);
        }
        return res;
    }

    function callother(address target, bytes memory data) external onlyOwner returns (bool, bytes memory) {
        return target.call(data);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return bytes4("lnt");
    }
}
