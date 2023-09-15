// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./ChainlinkVRFv2DirectFundingConsumerBase.sol";
import "./IChainlinkVRFv2DirectFundingProxy.sol";
import "hardhat/console.sol";

contract ChainlinkVRFv2DirectFundingConsumerExample is ChainlinkVRFv2DirectFundingConsumerBase {
    using SafeERC20 for IERC20;

    // EVENTS
    event RandomnessProvided(
        bytes32 indexed requestId,
        uint256[] indexed randomWords
    );

    // ERRORS
    error RequestAlreadyExists(bytes32 requestId);
    error RequestDoesntExist(bytes32 requestId, uint256[] randomWords);

    // VARIABLES
    mapping(bytes32 => bool) public requestExists;

    constructor(
        address _proxyContractAddress,
        address[] memory permittedOracles,
        uint256 threshold
    ) ChainlinkVRFv2DirectFundingConsumerBase(_proxyContractAddress, permittedOracles, threshold) {
        // custom init code
    }

    function initiateRandomnessRequest() external payable {
        // initiate randomness request
        // for 2 words of randomness
        // with default values for callback gas limit and confirmations
        bytes32 requestId = requestRandomness(2);
        if (requestExists[requestId]) revert RequestAlreadyExists(requestId);
        requestExists[requestId] = true;
    }

    // user implemented
    function fulfillRandomWords(bytes32 _requestId, uint256[] memory _randomWords) internal override {
        if (!requestExists[_requestId])
            revert RequestDoesntExist(_requestId, _randomWords);
        emit RandomnessProvided(_requestId, _randomWords);
    }
}
