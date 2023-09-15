// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IChainlinkVRFv2DirectFundingConsumer.sol";
import "./IChainlinkVRFv2DirectFundingProxy.sol";

contract ChainlinkVRFv2DirectFundingProxy is IChainlinkVRFv2DirectFundingProxy, ConfirmedOwner, Pausable {
    using SafeERC20 for IERC20;

    // EVENTS
    event FeeSet(
        address indexed sender,
        uint256 indexed fee
    );

    event PurposeSet(
        address indexed sender,
        string purpose
    );

    event NodeBackendAddressAdded(
        address indexed sender,
        address indexed newNodeBackend
    );

    event NodeBackendAddressRemoved(
        address indexed sender,
        address indexed newNodeBackend
    );

    // VARIABLES
    // the only addresses allowed to call the callBackWithRandomness function
    mapping(address => bool) public whitelistedNodeBackendAddresses;

    // internal counter for the request ids
    uint256 public nonce;

    // the contracts for each of the request ids
    // requestId => callingContract (dApp)
    mapping(bytes32 => address) public callingContracts;

    // map holding whether a request has been handled
    mapping(bytes32 => bool) public requestHandled;
    
    // callback forward gas settings
    mapping(bytes32 => uint32) public callbackGasLimit;

    // the fee taken to for the service and to pay for the gas
    uint256 public fee;

    string public contractPurpose;

    // sets the node backend address
    constructor(address _nodeBackendAddress, uint256 _fee, string memory _contractPurpose)
        ConfirmedOwner(msg.sender)
    {
        _addNodeBackendAddress(_nodeBackendAddress);
        _setFee(_fee);
        _setPurpose(_contractPurpose);

    }

    function _addNodeBackendAddress(address _nodeBackendAddress) private {
        require(_nodeBackendAddress != address(0), "Address cannot be 0");
        whitelistedNodeBackendAddresses[_nodeBackendAddress] = true;
        emit NodeBackendAddressAdded(msg.sender, _nodeBackendAddress);
    }

    // update the node backend address (only owner)
    function addNodeBackendAddress(address _nodeBackendAddress)
        external
        onlyOwner
    {
        _addNodeBackendAddress(_nodeBackendAddress);
    }

    function removeNodeBackendAddress(address _nodeBackendAddress)
        external
        onlyOwner
    {
        require(_nodeBackendAddress != address(0), "Address cannot be 0");
        whitelistedNodeBackendAddresses[_nodeBackendAddress] = false;
        emit NodeBackendAddressRemoved(msg.sender, _nodeBackendAddress);
    }

    function _setFee(uint256 _fee) private {
        fee = _fee;
        emit FeeSet(msg.sender, _fee);
    }

    // update the fee to be taken per request (only owner)
    function setFee(uint256 _fee) external onlyOwner {
        _setFee(_fee);
    }

    function _setPurpose(string memory _purpose) private {
        contractPurpose = _purpose;
        emit PurposeSet(msg.sender, _purpose);
    }

    // update the purpose desciption (only owner)
    function setPurpose(string memory _purpose) external onlyOwner {
        _setPurpose(_purpose);
    }

    // internal helper which creates the request ids
    function makeRequestId(address _proxy, uint256 _nonce)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_proxy, _nonce));
    }

    // modifier to revert if anyone but the node backend calls a function
    modifier onlyWhitelistedBackend() {
        if (!whitelistedNodeBackendAddresses[msg.sender])
            revert ChainlinkVRFv2DirectFundingProxy_UnauthorizedBackend(
                msg.sender
            );
        _;
    }

    // external function that can be used to initiate a randomness request
    function requestRandomness(uint32 _callbackGasLimit, uint16 _requestConfirmations, uint32 _numWords)
        external
        payable
        returns (bytes32 requestId)
    {
        require(msg.value >= fee, "Insufficient fee");

        requestId = makeRequestId(address(this), nonce++);
        callingContracts[requestId] = msg.sender;

        callbackGasLimit[requestId] = _callbackGasLimit;

        // event which will be picked up by the backend node
        // tx.origin = message signer 
        // msg.sender = address of the dapp contract
        // solhint-disable-next-line avoid-tx-origin
        emit RandomnessRequest(tx.origin, msg.sender, nonce - 1, requestId, _callbackGasLimit, _requestConfirmations, _numWords);
    }

    function callbackWithRandomness(
        uint8[] memory sigV,
        bytes32[] memory sigR,
        bytes32[] memory sigS,
        address requestOrigin,
        uint256 chainId,
        bytes32 requestId,
        uint256[] memory randomWords
    ) external onlyWhitelistedBackend {
        if (requestHandled[requestId])
            revert ChainlinkVRFv2DirectFundingProxy_RequestAlreadyHandled(
                requestId
            );
        requestHandled[requestId] = true;

        uint32 forwardGas = callbackGasLimit[requestId];

        if (gasleft() < forwardGas)
            revert ChainlinkVRFv2DirectFundingProxy_InsufficientGasForConsumer(
                gasleft()
            );

        // constant gas
        IChainlinkVRFv2DirectFundingConsumer(callingContracts[requestId])
            .verifyAndFulfillRandomness{gas: forwardGas}(
            sigV,
            sigR,
            sigS,
            requestOrigin,
            chainId,
            requestId,
            randomWords
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
