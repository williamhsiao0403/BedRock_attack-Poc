// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface MintProxy {
    event AdminChanged(address previousAdmin, address newAdmin);
    event BeaconUpgraded(address indexed beacon);
    event Upgraded(address indexed implementation);

    fallback() external payable;

    receive() external payable;

    function changeAdmin(address newAdmin) external;
    function multicall(bytes[] memory data) external returns (bytes[] memory results);
    function upgradeTo(address newImplementation) external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

/// @title ERC20 Token Interface (簡化版)
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

/// @title Balancer Vault FlashLoan Interface
interface iBalancerVault {
    function flashLoan(
        address receiver,
        address[] calldata tokens,
        uint256[] calldata amounts,
        bytes calldata userData
    ) external;
}

/// @title WETH9 Interface (簡化版)
interface WETH9 {
    function balanceOf(address account) external view returns (uint256);
    function withdraw(uint256 wad) external;
    function deposit() external payable;
}

/// @title Uniswap V3 Swap Router Interface
interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

/// @title SwapRouter Interface
/// 此介面與 ISwapRouter 中的 exactInputSingle 函數功能相同，可依需求選擇使用哪一個。
interface SwapRouter {
    function exactInputSingle(ISwapRouter.ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}


/// @title Bedrock Interface
/// 用於調用床岩合約的 mint 函數
interface bedrockInterface {
    function mint() external payable;
}

/// @title Vault Interface
/// 用於調用 Vault 合約的 mint 函數
/// 測試一下，2419行的mint理論上可以用任意的erc20代幣, 1:1 兌換成uniBTC
/// 但是vault裡面的caps[weth] 一開始是0, 所以沒法兌換成功
/// 也許有其他方法，但是要先想辦法修改掉caps中的weth數量
/// caps[wbtc] = 500000000000
interface IVault {
    function mint(address _token, uint256 _amount) external;

}