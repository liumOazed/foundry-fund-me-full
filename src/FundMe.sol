// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity 0.8.19;
// 2. Imports

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// Get funds from users
// Withdraw funds
// Set a minimum value USD

error FundMe__NotOwner(); // making it more gas efficient (naming error with contract name and __ )

contract FundMe {
    using PriceConverter for uint256; // attaching the functions in PriceConverer library to all uint256s

    uint256 public constant MINIMUM_USD = 5 * 1e18; //"constant" u don't want to change the variable plus its gas efficient
    AggregatorV3Interface private s_priceFeed;

    address[] private s_funders; // keep an array of senders of funds
    // mapping of address to make it easier how much money each funders have sent

    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;

    address private immutable i_owner; // variables that set onetime but outside the sameline they declared(e.g in constructor) can be marked as immutable gas efficient

    constructor(address priceFeed) {
        // priceFeed as our constructor parameter
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // This function will get funds from the users
        // This func will allow users to send money
        // Have a minimum $
        // msg.value is a uint256 and get passed as an argument to the function
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "didn't send enough ETH"
        ); // access the value
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value; // Whatever they have previously funded plus additional amount
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length; // reading only onetime from the storage and storing in memory
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // Still need to do reset the array
        s_funders = new address[](0); // resetting the array
        // actually withdraw the real funds
        // we can do it in 3 different ways 1. transfer 2. send 3. call (best is call)
        // call returns 2 variables to show them by placing them in the parenthesis on the left side
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        //Owner of the contract will use This function to withdraw the funds
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0; // set the amount funded to 0 cause we are withdrawing
        }

        // Still need to do reset the array
        s_funders = new address[](0); // resetting the array
        // actually withdraw the real funds
        // we can do it in 3 different ways 1. transfer 2. send 3. call (best is call)
        // call returns 2 variables to show them by placing them in the parenthesis on the left side
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    // There is a problem anyone can call the withdraw function and take all the money, We dont want that
    // We want to only allow the owner to withdraw
    // So withdraw function should be only accessible/called by the owner
    // So whoever deploys it should be the owner and his address gets signed to be the owner
    // So need add some parameters which will make sure withdraw can be called by that address/owner
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Only owner can withdraw");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner(); // throw an error plus gas efficient
        }
        _; // whatever else
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    // There are people who would want to send money/interact with smart contract without actually goin thru the function calling (anon funders)
    // What happens if someone sends this contract ETH without calling the fund function?
    // Receive() // Ether is sent msg.data is empty and receive function exist triggers receive
    // fallback() // if it is data(msg.data) and no receive function exist triggers fallback

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * Following View / Pure functions (Getters) will be used to checked to see i they are populated
     * cause we made them private
     */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
