// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IChainlinkVRFv2DirectFundingConsumer {
    error IChainlinkVRFv2DirectFundingConsumer_RandomnessProviderUnauthorized(
        address unauthorizedProvider
    );
    error IChainlinkVRFv2DirectFundingConsumer_NativeFeeIncorrect(
        uint256 needed,
        uint256 provided
    );
    error IChainlinkVRFv2DirectFundingConsumer_InsufficientERC20Balance(
        address token,
        uint256 needed,
        uint256 balance
    );
    
    event ProxyContractSet(
        address indexed operator,
        address indexed proxyContractAddress
    );

    function verifyAndFulfillRandomness(
        uint8[] memory sigV,
        bytes32[] memory sigR,
        bytes32[] memory sigS,
        address requestOrigin,
        uint256 chainId,
        bytes32 requestId,
        uint256[] memory randomWords
    ) external;
}
