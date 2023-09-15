// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IChainlinkVRFv2DirectFundingConsumer.sol";
import "./IChainlinkVRFv2DirectFundingProxy.sol";

abstract contract ChainlinkVRFv2DirectFundingConsumerBase is IChainlinkVRFv2DirectFundingConsumer {
    using SafeERC20 for IERC20;

    // EVENTS
    event SignaturesCheckPassedRandomnessReceived(
        bytes32 indexed requestId,
        uint256[] indexed randomWords
    );

    event OraclePermissionSet(
        address indexed operator,
        address indexed oracle,
        bool indexed permitted
    );

    event OracleThresholdSet(
        address indexed operator,
        uint256 indexed newThreshold
    );

    // ERRORS
    error ChainlinkVRFv2DirectFundingConsumerBase_ToFewSignatures(
        uint256 sigCount,
        uint256 sigThreshold
    );
    error ChainlinkVRFv2DirectFundingConsumerBase_MismatchedSignaturesCount();
    error ChainlinkVRFv2DirectFundingConsumerBase_UnauthorizedOracleSignatures();
    error ChainlinkVRFv2DirectFundingConsumerBase_UnorderedOracles();
    error ChainlinkVRFv2DirectFundingConsumerBase_RandomRequestFailed(bytes reason);

    modifier onlyRandomnessProvider() {
        if (msg.sender != proxyContractAddress)
            revert IChainlinkVRFv2DirectFundingConsumer_RandomnessProviderUnauthorized(
                msg.sender
            );
        _;
    }

    // VARIABLES
    address public proxyContractAddress;

    // EIP712
    bytes32 private constant EIP712DOMAINTYPE_HASH =
        0xd87cd6ef79d4e2b95e15ce8abf732db51ec771f1ca2edccf22a46c729ac56472; // "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"
    bytes32 private constant NAME_HASH =
        keccak256("Relink MultiSig");
    bytes32 private constant VERSION_HASH = keccak256("1");
    bytes32 private constant SALT =
        0x151543af6b722378665a73fe38dbceae4871a070b7cdaf5c6e30cf758dc33cc8;
    // stores signature metadata
    bytes32 private domainSeparator;

    // HASH for signature verification
    bytes32 private constant RANDOMNESS_RECEIVED_HASH =
        keccak256(
            "ProxyRequest(address requestOrigin,uint256 chainId,bytes32 requestId,uint256[] randomWords)"
        );
    /// stores the number of signatures needed to pass a verification
    uint256 public multiSignatureThreshold;
    /// mapping from address of the contract to true/false if permitted as an oracle
    mapping(address => bool) public permittedOracleAddresses;

    constructor(
        address _proxyContractAddress,
        address[] memory _permittedOracles,
        uint256 _oracleThreshold
    ) {
        // initialize required state variables
        domainSeparator = keccak256(
            abi.encode(
                EIP712DOMAINTYPE_HASH,
                NAME_HASH,
                VERSION_HASH,
                block.chainid,
                address(this),
                SALT
            )
        );
        uint256 oracleCount = _permittedOracles.length;
        for (uint256 i = 0; i < oracleCount; i++) {
            _setOraclePermitted(_permittedOracles[i], true);
        }
        _setOracleThreshold(_oracleThreshold);
        _setProxyContractAddress(_proxyContractAddress);
    }

    function _setProxyContractAddress(address _proxyContractAddress)
        internal
    {
        proxyContractAddress = _proxyContractAddress;
        emit ProxyContractSet(msg.sender, _proxyContractAddress);
    }

    function _setOraclePermitted(address _oracleAddress, bool _permitted)
        internal
    {
        permittedOracleAddresses[_oracleAddress] = _permitted;
        emit OraclePermissionSet(msg.sender, _oracleAddress, _permitted);
    }

    function _setOracleThreshold(uint256 _newThreshold) internal {
        multiSignatureThreshold = _newThreshold;
        emit OracleThresholdSet(msg.sender, _newThreshold);
    }
    
    // requestRandomness with default requestConfirmations and numWords
    function requestRandomness() internal returns (bytes32) {
        // default numWords ist 1
        return requestRandomness(1);
    }

    // requestRandomness with default requestConfirmations and custom numWords parameter
    function requestRandomness(uint32 _numWords) internal returns (bytes32) {
        // default requestConfirmations is 3 (minimum allowed value on Polygon)
        return requestRandomness(3, _numWords);
    }
    
    // requestRandomness with default callbackGasLimit and custom requestConfirmations and numWords parameter
    function requestRandomness(uint16 _requestConfirmations, uint32 _numWords) internal returns (bytes32) {
        // default callbackGasLimit is 120000
        return requestRandomness(120000, _requestConfirmations, _numWords);
    }

    function requestRandomness(uint32 _callbackGasLimit, uint16 _requestConfirmations, uint32 _numWords) internal returns (bytes32) {
        require(_numWords <= 10, "Maximum Random Values: 10");
        try
            IChainlinkVRFv2DirectFundingProxy(proxyContractAddress)
                .requestRandomness{value: msg.value}(_callbackGasLimit, _requestConfirmations, _numWords)
        returns (bytes32 v) {
            return v;
        } catch (bytes memory data) {
            revert ChainlinkVRFv2DirectFundingConsumerBase_RandomRequestFailed(data);
        }
    }

    function verifyAndFulfillRandomness(
        uint8[] memory sigV,
        bytes32[] memory sigR,
        bytes32[] memory sigS,
        address requestOrigin,
        uint256 chainId,
        bytes32 requestId,
        uint256[] memory randomWords
    ) external onlyRandomnessProvider {
        signaturesCheckRandomnessReceived(
            sigV,
            sigR,
            sigS,
            requestOrigin,
            chainId,
            requestId,
            randomWords
        );
        fulfillRandomWords(requestId, randomWords);
    }

    // user implemented
    function fulfillRandomWords(bytes32 _requestId, uint256[] memory _randomWords) internal virtual;

    function signaturesCheckRandomnessReceived(
        uint8[] memory sigV,
        bytes32[] memory sigR,
        bytes32[] memory sigS,
        address requestOrigin,
        uint256 chainId,
        bytes32 requestId,
        uint256[] memory randomWords
    ) internal {
        if (sigV.length < multiSignatureThreshold)
            revert ChainlinkVRFv2DirectFundingConsumerBase_ToFewSignatures(
                sigV.length,
                multiSignatureThreshold
            );
        if (sigR.length != sigS.length || sigR.length != sigV.length)
            revert ChainlinkVRFv2DirectFundingConsumerBase_MismatchedSignaturesCount();

        // produce transaction input hash from input parameters
        bytes32 txInputHash = keccak256(
            abi.encode(
                RANDOMNESS_RECEIVED_HASH,
                requestOrigin,
                chainId,
                requestId,
                keccak256(abi.encodePacked(randomWords))
            )
        );

        // verify oracle signatures
        bool verified = _verifySignatures(sigV, sigR, sigS, txInputHash);
        if (!verified) revert ChainlinkVRFv2DirectFundingConsumerBase_UnauthorizedOracleSignatures();

        // signatures verified - emit event
        emit SignaturesCheckPassedRandomnessReceived(requestId, randomWords);
    }

    function _verifySignatures(
        uint8[] memory sigV,
        bytes32[] memory sigR,
        bytes32[] memory sigS,
        bytes32 txInputHash
    ) private view returns (bool) {
        bytes32 totalHash = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, txInputHash)
        );

        uint256 verifiedSignatures = 0;
        address lastAdd = address(0); // cannot have address(0) as an owner
        for (uint256 i = 0; i < sigV.length; i++) {
            address recovered = ecrecover(totalHash, sigV[i], sigR[i], sigS[i]);

            // if the same address is used multiple times, fail
            if (recovered <= lastAdd)
                revert ChainlinkVRFv2DirectFundingConsumerBase_UnorderedOracles();

            // check if the computed address is included in the permitted oracles list
            if (permittedOracleAddresses[recovered]) {
                // address is a part of the permitted oracles list, increase verified signature counter
                verifiedSignatures = verifiedSignatures + 1;
                lastAdd = recovered;
            }
        } // return true if the amount of verified signatures is equal to or above multisig threshold
        return verifiedSignatures >= multiSignatureThreshold;
    }
}
