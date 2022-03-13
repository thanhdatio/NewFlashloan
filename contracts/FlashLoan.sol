pragma solidity ^0.5.0;

import "./base/FlashLoanReceiverBase.sol";
import "./interfaces/ILendingPoolAddressesProvider.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/IDefi.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Router.sol";
//import "https://github.com/thanhdatio/FlashloanTrade/blob/master/token/Ownable.sol";
//import "./interfaces/IERC20.sol";

contract Demo is FlashLoanReceiverBase {

    address public constant BNB_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public constant _tokenAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public constant WBNB_ADDRESS = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    //address public constant _EXRouter1 = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public constant _EXRouter1 = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address public constant _EXRouter2 = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address public defi;
    IERC20 BUSD;
    uint256 amountToTrade;
    uint256 tokensOut;
    IUniswapV2Router uniswapV2Router;

    constructor(ILendingPoolAddressesProvider _addressesProvider)
        public
        FlashLoanReceiverBase(_addressesProvider)
        
    {
        //defi = _defi;
        uniswapV2Router = IUniswapV2Router(address(_EXRouter1));
    }

    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    ) external    {
        require(
            _amount <= getBalanceInternal(address(this), _reserve),
            "Invalid balance, was the flashLoan successful?"
        );

        //
        // Your logic goes here.
        // !! Ensure that *this contract* has enough of `_reserve` funds to payback the `_fee` !!
        //
        //uint u_mount=_amount/1000000000000000000;
        //start(u_mount);
        // execute arbitrage strategy
        start();
        
        
        //IDefi app = IDefi(defi);
        // Todo: Deposit into defi smart contract
        //app.depositBNB.value(_amount)(_amount);
        //app.swap(_amount);
        // Todo: Withdraw from defi smart contract
        //app.withdraw(_amount);
        

        uint256 totalDebt = _amount.add(_fee);
        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

  
    function flashloanBnb(
        uint _amountToTrade,
        uint256 _tokensOut,
        uint _amount
        ) public  {
        bytes memory data = "";
        amountToTrade = _amountToTrade; // how much wei you want to trade
        tokensOut = _tokensOut; // how many tokens you want converted on the return trade     
        ILendingPool lendingPool = ILendingPool(
            addressesProvider.getLendingPool()
        );
        lendingPool.flashLoan(address(this), BNB_ADDRESS, 
        1000000000000000000,//_amount, 
        data);
        
    }
/*
    function check(
        //address _tokenBorrow, // example: BUSD
        uint _amount, // example: BNB => 10 * 1e18
        address _tokenAddress, // example: BNB
        address _EXRouter1,
        address _EXRouter2
    ) public view returns(uint) {
        address[] memory path1 = new address[](2);
        address[] memory path2 = new address[](2);
        path1[0] = _tokenAddress;
        path1[1] = BNB_ADDRESS;
        path2[1] = _tokenAddress;
        path2[0] = BNB_ADDRESS;
        uint EX1amountOut = IUniswapV2Router(_EXRouter1).getAmountsOut(_amount,path2)[1];
        //uint256 EX2amountOut = IUniswapV2Router(_EXRouter1).getAmountsOut(EX1amountOut,path1)[1];
        return (
            EX1amountOut // the amount we get from our input "_amountTokenPay"; example: BUSD amount
        );
    }
*/
    function getAmountOutMin(
    address _tokenIn, 
    address _tokenOut, 
    uint _amountIn,
    address _EXRouter) external view returns (uint,uint) {
        //address _tokenIn=BUSD_ADDRESS;
       //path is an array of addresses.
       //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
       //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path = new address[](2);
        path[1] = address(_tokenOut);
        path[0] = address(_tokenIn);
        
        uint[] memory amountOutMins = IUniswapV2Router(_EXRouter).getAmountsOut(_amountIn, path);
        //uint amountshow=amountOutMins[1]/1000000000000000000;
        return (amountOutMins[1],amountOutMins[1]);  
    }  

    function getAmountOut(
    address _tokenIn, 
    address _tokenOut, 
    uint _amountIn,
    address _EXRouter) public returns (uint) {
        //address _tokenIn=BUSD_ADDRESS;
       //path is an array of addresses.
       //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
       //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path = new address[](2);
        path[1] = address(_tokenOut);
        path[0] = address(_tokenIn);
        
        uint[] memory amountOutMins = IUniswapV2Router(_EXRouter).getAmountsOut(_amountIn, path);
        return amountOutMins[1];  
    }  

    function getPathForETHToToken(address ERC20Token) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = WBNB_ADDRESS;
        path[1] = ERC20Token;
    
        return path;
    }

    /**
        Using a WETH wrapper to convert ERC20 token back into ETH
     */
     function getPathForTokenToETH(address ERC20Token) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = ERC20Token;
        path[1] = WBNB_ADDRESS;
        
        return path;
    }

    function start() public payable 
        {
                /*require(
            address(this).balance >= amountToTrade,
            "Khong du tien"
        );*/
        address[] memory path1 = new address[](2);
        path1[1] = _tokenAddress;
        path1[0] = WBNB_ADDRESS;
        uniswapV2Router.swapETHForExactTokens
        (
            100,//amountToTrade,
            path1, 
            address(this), 
            block.timestamp + 300
        );
        //uint256 _tokenAmount = EX1amountOut;
        //uint256 _tokenAmount=EX1amountOut;
        uint256 tokenAmountInWEI = tokensOut.mul(1000000000000000000); //convert into Wei
        //uint256 estimatedETH = getEstimatedETHForToken(tokensOut, _tokenAddress)[0]; // check how much ETH you'll get for x number of ERC20 token
        //uint256 estimatedETH = getAmountOut(_tokenAddress,WBNB_ADDRESS,tokenAmountInWEI,_EXRouter1);
        //path[0] = _tokenAddress;
        //path[1] = WBNB_ADDRESS;
        //uint256 _AmountgetToken;
        //uint256 _AmountgetBNB;
        //_AmountgetToken=getAmountOut(WBNB_ADDRESS, _tokenAddress, _amount,_EXRouter1);
        //_AmountgetToken=_AmountgetToken;
       
        //uint amountgetTokenuint=_AmountgetToken;
    
        //_AmountgetBNB=getAmountOut(_tokenAddress, WBNB_ADDRESS,  _AmountgetToken,_EXRouter2);
        //_AmountgetBNB=_AmountgetBNB;
        
        //uint amountgetBNBuint=_AmountgetBNB;
        //IERC20 token = IERC20(_tokenAddress);
        //token.approve(_EXRouter2, _AmountgetToken*1000000000000000000);
        //BUSD.approve(address(_EXRouter2), tokenAmountInWEI);
        //require(msg.value % 2 == 0, "Even value required.");
            // Trade 2: Execute swap of the ERC20 token back into ETH on Sushiswap to complete the arb
        /*IUniswapV2Router(_EXRouter2).swapExactTokensForETH(
            1000000000000,//tokenAmountInWEI, 
            1907627099,//estimatedETH, 
            getPathForTokenToETH(_tokenAddress), 
            msg.sender,//address(this), 
            block.timestamp + 300
        );*/
}

/**
        helper function to check ERC20 to ETH conversion rate
     */
    function getEstimatedETHForToken(uint _tokenAmount, address ERC20Token) public view returns (uint[] memory) {
        return IUniswapV2Router(_EXRouter1).getAmountsOut(_tokenAmount, getPathForTokenToETH(ERC20Token));
        //IUniswapV2Router(_EXRouter).getAmountsOut(_amountIn, path);
    }
 
    
}
