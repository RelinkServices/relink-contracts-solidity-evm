// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "hardhat/console.sol";

/**
 * @title ChainlinkVRFv2DirectFundingProducer
 * @dev This contract is used to request randomness from Chainlink VRF V2 and relay it to another chain.
 * 
 * The contract is pausable in case of emergency.
 * The contract is a contract that uses the VRFV2WrapperConsumerBase contract to interact with the Chainlink VRF V2 contract.
 * The contract is a ConfirmedOwner contract that allows the owner to transfer ownership to another address.
 *
 * In terms of Chainlink VRF V2, the contract is a consumer contract that requests randomness from the Chainlink VRF V2 contract.
 * For the relaying service, the contract is a producer contract that relays the randomness to another chain.
 */

contract ChainlinkVRFv2DirectFundingProducer is VRFV2WrapperConsumerBase, ConfirmedOwner, Pausable {
    using SafeERC20 for IERC20;

    // ERRORS
    error ChainlinkVRFv2DirectFundingProducer_RequestAlreadyExists();
    error ChainlinkVRFv2DirectFundingProducer_RequestDoesNotExist(uint256 requestId);

    // EVENTS 
    // proxyRequestId is generated in proxy contract: keccak256(abi.encodePacked(address of proxy contract, internal counter))
    event RandomnessRequested(
        address indexed sender,
        uint256 indexed chainId,
        bytes32 indexed proxyRequestId,
        uint32 numWords,
        uint256 requestId
    );

    event RandomnessReceived(
        address indexed requester,
        uint256 indexed chainId,
        bytes32 indexed proxyRequestId,
        uint256[] randomWords
    );

    // VARIABLES
    struct RandomnessRequestStatus {
        address origin; // address of the requester
        uint256 chainId; // chainId of the destination chain
        bytes32 proxyRequestId; // external identifier on destination chain
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords; // randomness request result
    }

    // maps request id to the request
    // Chainlink generated requestId => RandomnessRequestStatus
    mapping(uint256 => RandomnessRequestStatus) public chainlinkRequests;

    // Relayer request mapping
    // chainId => proxyRequestId => bool
    mapping(uint256 => mapping(bytes32 => bool)) public requestCreated;
    
    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function.
    uint32 public callbackGasLimit = 100000;

    // Address LINK - ERC677 token
    address public linkTokenAddress;

    uint256 public relayerServiceFeePpm = 1000000; // 1000000 = 100% fee

    // CONSTRUCTOR
    constructor(address _linkAddress, address _wrapperAddress)
        ConfirmedOwner(msg.sender)
        VRFV2WrapperConsumerBase(_linkAddress, _wrapperAddress)
    {
        linkTokenAddress = _linkAddress;
    }

    // CHAINLINK VRF V2 FUNCTIONS
    // requestRandomWords function
    function requestRandomWords(uint256 _chainId, bytes32 _proxyRequestId, uint32 _numWords, uint16 _requestConfirmations) public whenNotPaused {
        if (requestCreated[_chainId][_proxyRequestId])
            revert ChainlinkVRFv2DirectFundingProducer_RequestAlreadyExists();
        else requestCreated[_chainId][_proxyRequestId] = true;

        // calculate the LINK amount and ensure that the fee is paid
        uint256 linkRequestFee = VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit);
        uint256 relayerServiceFee = linkRequestFee * relayerServiceFeePpm / 1000000;
        uint256 totalFee = linkRequestFee + relayerServiceFee;

        require(
            LinkTokenInterface(linkTokenAddress).balanceOf(msg.sender) >= totalFee,
            "Not enough LINK - ERC677 tokens"
        );

        require(
            LinkTokenInterface(linkTokenAddress).transferFrom(
                msg.sender,
                address(this),
                totalFee
            ), 
            "Unable to transfer link tokens"
        );

        // request randomness from Chainlink VRF V2
        // config: https://docs.chain.link/vrf/v2/direct-funding/supported-networks
        uint256 requestId = requestRandomness(
            callbackGasLimit,
            _requestConfirmations,
            _numWords // Maximum Random Values: 10
        );

        chainlinkRequests[requestId] = RandomnessRequestStatus({
            origin: msg.sender,
            chainId: _chainId,
            proxyRequestId: _proxyRequestId,
            paid: linkRequestFee,
            randomWords: new uint256[](0),
            fulfilled: false
        });
        emit RandomnessRequested(msg.sender, _chainId, _proxyRequestId, _numWords, requestId);
    }

    // fulfillRandomWords function
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        RandomnessRequestStatus memory request = chainlinkRequests[_requestId];

        // case that the request has not been set yet
        if (request.origin == address(0))
            revert ChainlinkVRFv2DirectFundingProducer_RequestDoesNotExist(_requestId);

        request.fulfilled = true;
        request.randomWords = _randomWords;

        // emitting event to signal that random data received
        emit RandomnessReceived(
            request.origin,
            request.chainId,
            request.proxyRequestId,
            _randomWords
        );
    }

    // SETTER FUNCTIONS
    function setCallbackGasLimit(uint32 _callbackGasLimit) external onlyOwner {
        callbackGasLimit = _callbackGasLimit;
    }

    function setLinkTokenAddress(address _linkTokenAddress) external onlyOwner {
        linkTokenAddress = _linkTokenAddress;
    }

    function setRelayerServiceFeePpm(uint256 _newRelayerServiceFeePpm) external onlyOwner {
        relayerServiceFeePpm = _newRelayerServiceFeePpm;
    }

    // WITHDRAW FUNCTIONS
    // Allow withdraw of Link tokens from the contract
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkTokenAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to withdraw Link tokens"
        );
    }

    // Allow withdraw of native token from the contract
    function withdrawNativeToken() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Allow withdraw of any ERC20 tokens from the contract which accidentally can be sent to this smart contract.
    function withdrawERC20Token(address _tokenContractAddress, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContractAddress);

        // needs to execute `approve()` on the token contract to allow itself the transfer
        tokenContract.approve(address(this), _amount);
        tokenContract.transferFrom(address(this), owner(), _amount);
    }
}
