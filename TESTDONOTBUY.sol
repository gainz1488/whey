/*

I am testing something, please DO NOT buy. After a few minutes I will be pulling liquidity. This is NOT an investment. 

I warned you.



*/

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface Antibot {
    function whitelistedAddresses() external view returns (address [] memory);
    function isWhitelisted(address account) external view returns (bool);
    function isAntibotOnDuty() external view returns (bool);
    function isTradingEnabled() external view returns (bool);
    function nextBuyForAddressAfterBlock(address account) external view returns (uint256);
    function nextSellForAddressAfterBlock(address account) external view returns (uint256);
    function getNumberOfBlocksBetweenBuys() external view returns (uint256);
    function getNumberOfBlocksBetweenSells() external view returns (uint256);
    function blacklistedAddresses() external view returns (address [] memory);
    function isBlacklisted(address account) external view returns (bool);
    function blacklistAddress(address addressToBlacklist) external;
    function whitelistAddress(address addressToWhitelist) external;
    function checkBuyTransaction(address seller, address buyer) external;
    function checkSellTransaction(address seller, address buyer) external;
    function setProtectedContract(address contractAddress) external;
}

contract TESTDONOTBUY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    // Dead address
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    // Allowances
    mapping (address => mapping (address => uint256)) private _allowances;
    // Account's balances
    mapping (address => uint256) private _balances;
   
    // Initial total supply (1M)
    uint256 private _totalSupply = 10000 * 10**6 * 10**18;
    
    // Max transaction amount (1,000)
    uint256 private _maxTxAmount = 1000 * 10**3 * 10**18;
    // Max wallet amount (20,000)
    uint256 private _maxWalletAmount = 20 * 10**3 * 10**18;

    // Name
    string private _name = "TESTDONOTBUY";
    // Symbol
    string private _symbol = "DONTBUY";
    // Decimals
    uint8 private _decimals = 18;

    // Initial liquidity fee
    uint256 public _liquidityFee = 20; // 50 equals to 5%
    // Initial buyback fee
    uint256 public _buybackFee = 50; // 100 equals to 10%
    // Initial burn fee
    uint256 public _burnFee = 5; // 50 equals to 5%

    // Previous variables for fees
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 private _previousBuybackFee = _buybackFee;
    uint256 private _previousBurnFee = _burnFee;
    
    // Are we in the process of adding liquidity / selling buyback fee?
    bool private inSwap = false;

    // Router
    IUniswapV2Router02 public uniswapV2Router;
    // Pair
    address public uniswapV2Pair;
    
    // Marketing address getting 0.5% to 1% of sell transactions
    address payable private _marketingAddress = payable(0xf0cE66392D5546BC681a7C9414dd04d4f5c52954);
    // Marketing percent, compared to the buyback fee percent (10% of 5% to 10%)
    uint256 private _marketingPercent = 5;
    
    Antibot antibot;
    
    event Burn(uint256 amountBurned);
    event Buyback(uint256 amountBoughtBack);
    event LiquidityAdded(uint256 tokenAmount, uint256 bnbAmount);
    event SwapTokensForBNB(uint256 tokenAmount);
    event SwapBNBForTokens(uint256 bnbAmount);
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address antibotAddress) {
        _balances[_msgSender()] = _totalSupply;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        
        antibot = Antibot(antibotAddress);
        antibot.setProtectedContract(address(this));
        antibot.whitelistAddress(owner());
        antibot.whitelistAddress(address(uniswapV2Router));
        antibot.whitelistAddress(deadAddress);

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    // TOKEN GETTERS
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() override external view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * Main transfer function
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0) && recipient != address(0), "BEP20: transfer from or to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool isExcludedFromLimitsAndFees = antibot.isWhitelisted(sender) || antibot.isWhitelisted(recipient);
        
        if(inSwap || isExcludedFromLimitsAndFees) {
            _transferExcluded(sender, recipient, amount);
        } else {
            if(sender == uniswapV2Pair) {
                // Buying
                
                // HARD antibot, sorry guys
                if(!antibot.isTradingEnabled()) {
                    antibot.blacklistAddress(recipient);
                    return;
                }
                
                require(checkMaxAmount(amount) || antibot.isBlacklisted(recipient), "Transfer amount exceeds the max transaction amount.");
                require(checkMaxWalletAmount(recipient, amount) || antibot.isBlacklisted(recipient), "Transfer amount exceeds the max wallet holding.");
                antibot.checkBuyTransaction(sender, recipient);
                _transferStandard(sender, recipient, amount, true);
            } else if(recipient == uniswapV2Pair) {
                // Selling or adding liquidity
                
                require(checkMaxAmount(amount), "Transfer amount exceeds the max transaction amount.");
                antibot.checkSellTransaction(sender, recipient);
                _transferStandard(sender, recipient, amount, false);
            } else {
                // Between wallets
                
                require(checkMaxAmount(amount), "Transfer amount exceeds the max transaction amount.");
                require(checkMaxWalletAmount(recipient, amount), "Transfer amount exceeds the max wallet holding.");
                require(!antibot.isBlacklisted(sender), "Blacklisted can not send their tokens to any wallet but dead address.");
                _transferStandard(sender, recipient, amount, true);
            }
        }
    }

    /**
     * Standard transfer with all fees
     */
    function _transferStandard(address sender, address recipient, uint256 amount, bool isUserBuying) private {
       (uint256 burnFee, uint256 buybackFee, uint256 liquidityFee, uint256 amountAfterFees) = _getFeesAmount(amount, isUserBuying);
        
        if(liquidityFee > 0) {
            _balances[address(this)] = _balances[address(this)].add(liquidityFee);
            emit Transfer(sender, address(this), liquidityFee);
            _sellTokensAndAddToLiquidity(liquidityFee);
        }
        
        if(buybackFee > 0) {
          _balances[address(this)] = _balances[address(this)].add(buybackFee);
          emit Transfer(sender, address(this), buybackFee);
          _sellTokensBuybackFee(buybackFee);
        }
        
        if(burnFee > 0) {
            _balances[deadAddress] = _balances[deadAddress].add(burnFee);
            emit Transfer(sender, deadAddress, burnFee);
            _burnTokensFromDeadAddress();
        }
        
        _balances[sender] = _balances[sender].sub(amount, "BEP20: standard transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amountAfterFees);
        
        emit Transfer(sender, recipient, amountAfterFees);
    }

    /**
     * Transfer between at least one excluded to another address, without any fees
     */
    function _transferExcluded(address sender, address recipient, uint256 amount) private {
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer excluded amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        
        if(recipient == deadAddress) _burnTokensFromDeadAddress();
    }
    
    /**
     * Destroy tokens from dead address, and reduce the total supply
     */
    function _burnTokensFromDeadAddress() private {
        uint256 amount = _balances[deadAddress];
        _totalSupply = _totalSupply.sub(amount, "BEP20: burn to dead address, from total supply transfer amount exceeds balance");
        _balances[deadAddress] = 0;

        emit Burn(amount);
    }
    
    /**
     * Burn the remaining tokens shard on contract balance, because when we add liquidity, it doesn't use 100% of the tokens 
     */
    function burnRemainingTokenShards() external onlyOwner {
        uint256 amount = balanceOf(address(this));
        address sender = address(this);
        _balances[deadAddress] = _balances[deadAddress].add(amount);
        _balances[sender] = _balances[sender].sub(amount, "BEP20: burn transfer amount exceeds balance");
        
        emit Transfer(sender, deadAddress, amount);
        
        _burnTokensFromDeadAddress();
    }
    
    /**
     * Buyback tokens
     */
    function _buyBackTokens(uint256 amount) private lockTheSwap {
    	if (amount > 0) {
    	    swapBNBForTokens(amount);
    	    emit Buyback(amount);
    	}
    }
    
    /**
     * Swap BNBs for tokens
     */
    function swapBNBForTokens(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            deadAddress,
            block.timestamp
        );
        
        _burnTokensFromDeadAddress();
        emit SwapBNBForTokens(amount);
    }
    
    /**
     * Sell tokens for buyback fee
     */
    function _sellTokensBuybackFee(uint256 amount) private lockTheSwap {
        if(amount > 0) {
            uint256 previousBNBBalance = address(this).balance;
            
            _swapTokensForBNB(amount);
            
            uint256 newBNBBalance = address(this).balance;
            uint256 deltaAmount = newBNBBalance.sub(previousBNBBalance, "BEP20: Selling tokens for buyback fee, can not sub previous balance from new one");
            
            transferBNBToAddress(_marketingAddress, deltaAmount.mul(_marketingPercent).div(100));
        }
    }
    
    /**
     * Buyback and burn a % of contract BNB balance 
     */
    function buyBackAndBurn(uint256 percent) external onlyOwner {
        _buyBackTokens(address(this).balance.mul(percent).div(100));
    }

    /**
     * Sell tokens from fees to liquidity
     */
    function _sellTokensAndAddToLiquidity(uint256 tokenAmount) private lockTheSwap {
        if(tokenAmount > 0) {
            uint256 halfTokenAmount = tokenAmount.div(2);
            uint256 otherHalf = tokenAmount.sub(halfTokenAmount, "BEP20: In liquidity, can not sub one half on the other");
            uint256 previousBNBBalance = address(this).balance;
    
            _swapTokensForBNB(halfTokenAmount);
    
            uint256 newBNBBalance = address(this).balance;
            uint256 deltaAmount = newBNBBalance.sub(previousBNBBalance, "BEP20: In liquidity, can not sub previous balance to new one");
        
            _addTokensToLiquidity(otherHalf, deltaAmount);
        }
    }
    
    /**
     * Add tokens to liquidity 
     */
    function _addTokensToLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            deadAddress,
            block.timestamp
        );
        
        emit LiquidityAdded(tokenAmount, bnbAmount);
    }
    
    /**
     * Swap tokens for BNB
     */
    function _swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        emit SwapTokensForBNB(tokenAmount);
    }
    
    /**
     * Burn tokens from blacklisted wallets
     */
    function burnTokensFromBlacklistedAddresses() external onlyOwner {
        for(uint i = 0; i < antibot.blacklistedAddresses().length; i++) {
            address sender = antibot.blacklistedAddresses()[i];
            uint256 amount = _balances[sender];
            
            if(amount > 0) {
                _balances[deadAddress] = _balances[deadAddress].add(amount);
                _balances[sender] = _balances[sender].sub(amount);
                emit Transfer(sender, deadAddress, amount);
               _burnTokensFromDeadAddress();
            }
        }
    }

    /**
     * Get fees amount
     */
    function _getFeesAmount(uint256 amount, bool isUserBuying) private view returns (uint256, uint256, uint256, uint256) {
        uint256 burnFee = calculateBurnFee(amount, isUserBuying);
        uint256 buybackFee = calculateBuybackFee(amount, isUserBuying);
        uint256 liquidityFee = calculateLiquidityFee(amount, isUserBuying);
        uint256 feesSum = burnFee.add(buybackFee).add(liquidityFee);
        uint256 amountAfterFees = amount.sub(feesSum, "Can not sub fees");
        return (burnFee, buybackFee, liquidityFee, amountAfterFees);
    }
    
    /**
     * Calculate liquidity fee based on amount of tokens
     */
    function calculateLiquidityFee(uint256 _amount, bool isUserBuying) private view returns (uint256) {
        if(isUserBuying) {
            return 0; // No liquidity fee on buy
        } else {
            return _amount.mul(_liquidityFee).div(10**3);
        }
    }

    /**
     * Calculate buy back fee based on amount of tokens
     */
    function calculateBuybackFee(uint256 _amount, bool isUserBuying) private view returns (uint256) {
        if(isUserBuying) {
            return 0; // No buyback fee on buy
        } else {
            return _amount.mul(_buybackFee).div(10**3);
        }
    }
    
    /**
     * Calculate burn fee based on amount of tokens
     */
    function calculateBurnFee(uint256 _amount, bool isUserBuying) private view returns (uint256) {
        if(isUserBuying) {
            return _amount.mul(_burnFee).div(10**3); // Buyback fee divided by 2 on buy
        } else {
            return 0; // No burn fee on sell
        }
    }
    
    /**
     * Modify the liquidity fee percent
     */
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        require(liquidityFee < 400, "Liquidity fee too high");
        _previousLiquidityFee = _liquidityFee;
        _liquidityFee = liquidityFee;
    }

    /**
     * Modify the buy back fee percent
     */
    function setBuybackFeePercent(uint256 buybackFee) external onlyOwner() {
        require(buybackFee < 400, "Buyback fee too high");
        _previousBuybackFee = _buybackFee;
        _buybackFee = buybackFee;
    }
    
    /**
     * Modify the burn fee percent
     */
    function setBurnFeePercent(uint256 burnFee) external onlyOwner() {
        require(burnFee < 500, "Burn fee too high");
        _previousBurnFee = _burnFee;
        _burnFee = burnFee;
    }
    
    /**
     * Check if current wallet amount + bought amount is under max wallet amount
     */
    function checkMaxWalletAmount(address buyer, uint256 amount) private view returns (bool) {
      return _balances[buyer].add(amount) <= _maxWalletAmount;
    }

    /**
     * Check if bought amount is under max amount 
     */
    function checkMaxAmount(uint256 amount) private view returns (bool) {
      return amount <= _maxTxAmount;
    }
    
    // _maxTxAmount

    function getMaxTxAmount() public view returns (uint256) {
      return _maxTxAmount;
    }

    function setMaxTxAmount(uint256 maxTxAmount) public onlyOwner {
      _maxTxAmount = maxTxAmount;
    }

    // _maxWalletAmount

    function getMaxWalletAmount() public view returns (uint256) {
      return _maxWalletAmount;
    }

    function setMaxWalletAmount(uint256 maxWalletAmount) public onlyOwner {
      _maxWalletAmount = maxWalletAmount;
    }

    // _marketingAddress
    
    function setMarketingAddress(address newMarketingAddress) external onlyOwner() {
        _marketingAddress = payable(newMarketingAddress);
    }
    
    function marketingAddress() external view returns (address) {
        return _marketingAddress;
    }

    // _marketingPercent
    
    function setMarketingPercent(uint256 percent) external onlyOwner {
        _marketingPercent = percent;
    }
    
    function marketingPercent() external view returns (uint256) {
        return _marketingPercent;
    }
    
    // ANTIBOT GETTERS
    
    function whitelistedAddresses() external view returns (address [] memory) {
        return antibot.whitelistedAddresses();
    }
    
    function isAntibotOnDuty() external view returns (bool) {
        return antibot.isAntibotOnDuty();
    }
    
    function isTradingEnabled() external view returns (bool) {
        return antibot.isTradingEnabled();
    }
    
    function nextBuyForAddressAfterBlock(address account) external view returns (uint256) {
        return antibot.nextBuyForAddressAfterBlock(account);
    }
    
    function nextSellForAddressAfterBlock(address account) external view returns (uint256) {
        return antibot.nextSellForAddressAfterBlock(account);
    }
    
    function getNumberOfBlocksBetweenBuys() external view returns (uint256) {
        return antibot.getNumberOfBlocksBetweenBuys();
    }
    
    function getNumberOfBlocksBetweenSells() external view returns (uint256) {
        return antibot.getNumberOfBlocksBetweenSells();
    }
    
    function numberOfBlacklistedAddresses() external view returns (uint256) {
        return antibot.blacklistedAddresses().length;
    }

    function amIBlacklisted(address account) external view returns (bool) {
        return antibot.isBlacklisted(account);
    }
    
    function currentBlock() external view returns (uint256) {
        return block.number;
    }
    
    /**
     * Allows the contract to receive BNB
     */
    receive() external payable {}

    /**
     * Transfer bnb amount to address 
     */
    function transferBNBToAddress(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
}
