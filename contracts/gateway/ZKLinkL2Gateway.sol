// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";
import {IZKLinkL2Gateway} from "../interfaces/IZKLinkL2Gateway.sol";
import {IMessageService} from "../interfaces/IMessageService.sol";
import {IZkLink} from "../interfaces/IZkLink.sol";

contract ZKLinkL2Gateway is
    OwnableUpgradeable,
    UUPSUpgradeable,
    IZKLinkL2Gateway
{
    // Claim fee recipient
    address payable public feeRecipient;
    // message service address
    IMessageService public messageService;

    // Remote Gateway address
    address public remoteGateway;

    IZkLink public zklinkContract;
    // Mapping from token to token bridge
    mapping(address => address) bridges;

    // Mapping from token to remote bridge
    mapping(address => address) remoteBridge;

    // Mapping L1 token address to L2 token address
    mapping(address => address) remoteTokens;

    uint256[49] internal __gap;

    modifier onlyRelayer() {
        _;
    }

    modifier onlyMessageService() {
        if (msg.sender != address(messageService)) {
            revert OnlyMessageService();
        }
        _;
    }

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function claimDepositERC20(
        address _token,
        uint104 _amount,
        bytes32 _zkLinkAddress,
        uint8 _subAccountId,
        bool _mapping,
        bytes calldata _calldata,
        uint256 nonce
    ) external override onlyMessageService {
        messageService.claimMessage(
            remoteBridge[_token],
            bridges[_token],
            0,
            0,
            feeRecipient,
            _calldata,
            nonce
        );
        IERC20Upgradeable(_token).approve(address(zklinkContract), _amount);
        zklinkContract.depositERC20(
            IERC20Upgradeable(_token),
            _amount,
            _zkLinkAddress,
            _subAccountId,
            _mapping
        );
    }

    function claimDepositETH(
        bytes32 zkLinkAddress,
        uint8 subAccountId,
        uint104 amount
    ) external payable override {
        if (msg.value != amount) {
            revert InvalidValue();
        }
        zklinkContract.depositETH{value: msg.value}(
            zkLinkAddress,
            subAccountId
        );

        emit ClaimedDepositETH(zkLinkAddress, subAccountId, amount);
    }

    function setBridges(
        address[] calldata _tokens,
        address[] calldata _bridges
    ) external onlyOwner {
        if (_tokens.length != _bridges.length) {
            revert InvalidParmas();
        }

        for (uint i = 0; i < _tokens.length; i++) {
            bridges[_tokens[i]] = _bridges[i];
            emit SetBridge(_tokens[i], _bridges[i]);
        }
    }

    function setRemoteBridges(
        address[] calldata _tokens,
        address[] calldata _remoteBridges
    ) external onlyOwner {
        if (_tokens.length != _remoteBridges.length) {
            revert InvalidParmas();
        }

        for (uint i = 0; i < _tokens.length; i++) {
            remoteBridge[_tokens[i]] = _remoteBridges[i];
            emit SetRemoteBridge(_tokens[i], _remoteBridges[i]);
        }
    }

    function setRemoteTokens(
        address[] calldata _tokens,
        address[] calldata _remoteTokens
    ) external onlyOwner {
        if (_tokens.length != _remoteTokens.length) {
            revert InvalidParmas();
        }

        for (uint i = 0; i < _tokens.length; i++) {
            remoteTokens[_tokens[i]] = _remoteTokens[i];
            emit SetRemoteToken(_tokens[i], _remoteTokens[i]);
        }
    }

    function setRemoteGateway(address _remoteGateway) external onlyOwner {
        if (_remoteGateway == address(0)) {
            revert InvalidParmas();
        }

        remoteGateway = _remoteGateway;
    }

    function setMessageService(address _messageService) external onlyOwner {
        if (_messageService == address(0)) {
            revert InvalidParmas();
        }

        messageService = IMessageService(_messageService);
    }

    function setZKLink(address _zklinkContract) external onlyOwner {
        if (_zklinkContract == address(0)) {
            revert InvalidParmas();
        }
        zklinkContract = IZkLink(_zklinkContract);
    }

    function getBridge(address token) external view returns (address) {
        return bridges[token];
    }

    function getRemoteBridge(address token) external view returns (address) {
        return remoteBridge[token];
    }

    function getRemoteToken(address token) external view returns (address) {
        return remoteTokens[token];
    }
}
