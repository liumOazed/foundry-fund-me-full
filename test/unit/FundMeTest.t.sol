//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe; // since fundme scoped inside setUp to access it it we initialize as a state variable

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //100000000000000000 (17 zero)
    uint256 constant STARTING_BALANCE = 10 ether;

    // uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); // run() is gonna return FundMe contract
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18); // assertEq came from Test
    }

    function testOwnerIsSender() public view {
        // console.log(fundMe.i_owner());
        // console.log(address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // Four types of tests
    // 1. Unit - Testing a specific part of our code
    // 2. Integration - Testing how our code works with other parts of our code
    // 3. Forked - Testing our code on a simulated real environment
    // 4. Staging - Testing our code in a real environment that is not prod

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        uint256 expectedVersion;

        if (block.chainid == 11155111) {
            expectedVersion = 4;
        } else if (block.chainid == 1) {
            expectedVersion = 6;
        } else if (block.chainid == 31337) {
            expectedVersion = 4;
        } else {
            revert("Unsupported chainid");
        }
        assertEq(version, expectedVersion);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // hey, the next line should revert!
        fundMe.fund(); // send 0 value (this line is indeed reverting/failing)
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); // above 2 lines will fund

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw(); // but the user is not the owner so it will revert/fail
    }

    function testWithDrawWithASingleFunder() public funded {
        // methodology of tworking with test
        // Arrange (First arrange the test or setup the test)
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // Balance before calling withdraw
        uint256 startingFundMeBalance = address(fundMe).balance; // Balance before calling withdraw

        // Act (Action you want to the test)
        // uint256 gasStart = gasleft(); //1000
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); // 200 used
        fundMe.withdraw(); // This is what we are testing

        // uint256 gasEnd = gasleft(); // left 800
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);

        // Assert (Finally assert the test is working or not)
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // Balance after calling withdraw
        uint256 endingFundMeBalance = address(fundMe).balance; // Balance after calling withdraw
        assertEq(endingFundMeBalance, 0); // withdrawn all the money
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    // Now test with multiple funders
    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10; // as of solidity 0.8 u can no longer cast explicitly from address to uint256
        uint160 startingFunderIndex = 1; // you have to do uint160 it has the same amount of bytes as an address

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // hoaxing it means we are pranking it as well
            fundMe.fund{value: SEND_VALUE}(); //funding in the above new address
        }

        // Act
        uint256 startOwnerBalance = fundMe.getOwner().balance;
        uint256 startFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance == 0); // REMOVE ALL the fund from fundme
        assert(
            startFundMeBalance + startOwnerBalance == fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10; // as of solidity 0.8 u can no longer cast explicitly from address to uint256
        uint160 startingFunderIndex = 1; // you have to do uint160 it has the same amount of bytes as an address

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // hoaxing it means we are pranking it as well
            fundMe.fund{value: SEND_VALUE}(); //funding in the above new address
        }

        // Act
        uint256 startOwnerBalance = fundMe.getOwner().balance;
        uint256 startFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance == 0); // REMOVE ALL the fund from fundme
        assert(
            startFundMeBalance + startOwnerBalance == fundMe.getOwner().balance
        );
    }
} // with is inheriting from Test
