// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IZKLinkL2Gateway {
    event ClaimedDepositERC20(
        address token,
        uint104 amount,
        bytes32 zklinkAddress,
        uint8 subAccountId,
        bool _mapping,
        uint256 nonce,
        bytes _calldata
    );

    event ClaimedDepositETH(
        bytes32 zkLinkAddress,
        uint8 subAccountId,
        uint104 amount
    );
    event SetBridge(address token, address bridge);
    event SetRemoteBridge(address token, address remoteBridge);
    event SetRemoteToken(address token, address remoteToken);

    error OnlyMessageService();
    error InvalidValue();
    error InvalidParmas();
    error NoRemoteTokenSet();

    function claimDepositERC20(
        address token,
        uint104 amount,
        bytes32 zkLinkAddress,
        uint8 subAccountId,
        bool _mapping,
        bytes calldata _calldata,
        uint256 nonce
    ) external;

    function claimDepositETH(
        bytes32 zkLinkAddress,
        uint8 subAccountId,
        uint104 amount
    ) external payable;
}
