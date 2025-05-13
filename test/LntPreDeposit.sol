// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {LntPreDeposit} from "../src/LntPreDeposit.sol";
import {MockERC721} from "../src/MockERC721.sol";
import {Arrays} from "openzeppelin-contracts/contracts/utils/Arrays.sol";
import {ERC721Holder} from "openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";

contract LntPreDepositTest is Test, ERC721Holder {
    LntPreDeposit public lnt;
    MockERC721 public nft;

    function setUp() public {
        nft = new MockERC721("My Lnt", "mLNT");
        lnt = new LntPreDeposit(address(nft));
    }

    function _range(uint256 len, uint256 start) internal pure returns (uint256[] memory) {
        uint256[] memory data = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            data[i] = start + i;
        }
        return data;
    }

    function test_Deposit() public {
        uint256[] memory nftIds = _range(3, 1);
        for (uint256 i = 0; i < nftIds.length; i++) {
            nft.mint(address(this), nftIds[i]);
        }
        nft.setApprovalForAll(address(lnt), true);
        for (uint256 i = 0; i < nftIds.length; i++) {
            lnt.deposit(nftIds[i]);
        }
        assertEq(Arrays.sort(lnt.deposited(address(this))), nftIds, "Deposited error");
        assertEq(lnt.totalDeposit(), 3, "totalDeposit error");
        lnt.withdraw(1);
        assertEq(Arrays.sort(lnt.deposited(address(this))), _range(2, 2), "Deposited error");
        assertEq(lnt.totalDeposit(), 2, "totalDeposit error");
        lnt.withdraw(2);
        assertEq(lnt.deposited(address(this)), _range(1, 3), "Deposit error");
        assertEq(lnt.totalDeposit(), 1, "totalDeposit error");
        lnt.withdraw(3);
        assertEq(lnt.deposited(address(this)), _range(0, 0), "Deposit error");
        assertEq(lnt.totalDeposit(), 0, "totalDeposit error");
    }

    function test_Multi() public {
        uint256[] memory nftIds = _range(3, 4);
        for (uint256 i = 0; i < nftIds.length; i++) {
            nft.mint(address(this), nftIds[i]);
        }
        nft.setApprovalForAll(address(lnt), true);
        bytes[] memory data = new bytes[](3);
        for (uint256 i = 0; i < nftIds.length; i++) {
            data[i] = abi.encodeCall(LntPreDeposit.deposit, (nftIds[i]));
        }
        lnt.multicall(data);
        assertEq(Arrays.sort(lnt.deposited(address(this))), _range(3, 4), "Deposited error");
        bytes[] memory withdraws = new bytes[](3);
        for (uint256 i = 0; i < nftIds.length; i++) {
            withdraws[i] = abi.encodeCall(LntPreDeposit.withdraw, (nftIds[i]));
        }
        lnt.multicall(withdraws);
        assertEq(lnt.deposited(address(this)), _range(0, 0), "Deposit error");
        assertEq(lnt.totalDeposit(), 0, "totalDeposit error");
    }
}
