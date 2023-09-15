// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IChainlinkVRFv2DirectFundingProxy {
    // ERRORS 
    error ChainlinkVRFv2DirectFundingProxy_InsufficientGasForConsumer(
        uint256 gasLeft
    );
    error ChainlinkVRFv2DirectFundingProxy_UnauthorizedBackend(
        address offendingAddress
    );
    error ChainlinkVRFv2DirectFundingProxy_ZeroAddress();
    error ChainlinkVRFv2DirectFundingProxy_RequestAlreadyHandled(
        bytes32 requestId
    );
    
    event RandomnessRequest(
        address indexed user,
        address indexed dapp,
        uint256 indexed nonce,
        bytes32 requestId,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        uint32 _numWords
    );
    
    // access 
    function callingContracts(bytes32 requestId) external view returns (address callingContract);
    function requestHandled(bytes32 requestId) external view returns (bool handled);

    function requestRandomness(uint32 _callbackGasLimit, uint16 _requestConfirmations, uint32 _numWords) external payable returns (bytes32 requestId);
    function callbackWithRandomness(
        uint8[] memory sigV,
        bytes32[] memory sigR,
        bytes32[] memory sigS,
        address requestOrigin,
        uint256 chainId,
        bytes32 requestId,
        uint256[] memory randomWords
    ) external;
}
