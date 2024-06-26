
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IEERC314 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event AddLiquidity(uint32 _blockToUnlockLiquidity, uint256 value);
  event RemoveLiquidity(uint256 value);
  event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out);
}

abstract contract ERC314 is IEERC314 {
    mapping(address account => uint256) private _balances;
    mapping(address account => uint256) private _lastTxTime;
    mapping(address account => uint32) private lastTransaction;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 public _maxWallet;
    uint32 public blockToUnlockLiquidity;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    string private _name;
    string private _symbol;

    address public owner;
    address public liquidityProvider;

    bool public tradingEnable;
    bool public liquidityAdded;
    bool public maxWalletEnable;

  modifier onlyOwner() {
    require(msg.sender == owner, 'Ownable: caller is not the owner');
    _;
  }

  modifier onlyLiquidityProvider() {
    require(msg.sender == liquidityProvider, 'You are not the liquidity provider');
    _;
  }

  constructor(string memory name_, string memory symbol_, uint256 totalSupply_) {
    _name = name_;
    _symbol = symbol_;
    _totalSupply = totalSupply_;
    _maxWallet = totalSupply_ * 100 / 100;
    owner = msg.sender;
    maxWalletEnable = true;

    //初始入池代币数量
    uint256 liquidityAmount = 16800000 * 10 ** 18;
    _balances[address(this)] = liquidityAmount;
    _balances[owner] = totalSupply_ - liquidityAmount;
    emit Transfer(address(0), address(this), liquidityAmount);
    emit Transfer(address(0), owner, totalSupply_ - liquidityAmount);

    //已开启交易资金池
    liquidityAdded = true;
    //开启交易
    tradingEnable = true;
    //资金池管理员
    liquidityProvider = msg.sender;
  }

  function name() public view virtual returns (string memory) {
    return _name;
  }

  function symbol() public view virtual returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual returns (uint8) {
    return 18;
  }

  function totalSupply() public view virtual returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view virtual returns (uint256) {
    return _balances[account];
  }

    function allowance(
        address _owner,
        address spender
    ) public view virtual returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual returns (bool) {
        address _owner = msg.sender;
        _approve(_owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);

        if (to == address(this)) {
            sell(from, amount);
        } else {
            _transfer(from, to, amount);
        }

        return true;
    }


    function transfer(address to, uint256 value) public virtual returns (bool) {
        //目的地址是否为当前合约 若是，则为卖出代币
        if (to == address(this)) {
            sell(msg.sender, value);
        } else {
            _transfer(msg.sender, to, value);
        }
        return true;
    }

    function _approve(
        address _owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function _spendAllowance(
        address _owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(_owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(_owner, spender, currentAllowance - amount);
            }
        }
    }


    //交易间隔
    uint256 public cooldownSec = 30;
    function setCooldownSec(uint256 newValue) public onlyOwner{
        require(newValue <= 60,"too long");
        cooldownSec = newValue;
    }

    mapping(address => bool) public excludeCoolingOf;
    function setExcludeCoolingOf(
        address[] memory accounts,
        bool _ok
    ) external onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            excludeCoolingOf[accounts[i]] = _ok;
        }
    }

  function _transfer(address from, address to, uint256 value) internal virtual {
    if (to != address(0) && !excludeCoolingOf[msg.sender]) {
      require(lastTransaction[msg.sender] != block.number, "You can't make two transactions in the same block");
      lastTransaction[msg.sender] = uint32(block.number);

      require(block.timestamp >= _lastTxTime[msg.sender] + cooldownSec, 'Sender must wait for cooldown');
      _lastTxTime[msg.sender] = block.timestamp;
    }

    require(_balances[from] >= value, 'ERC20: transfer amount exceeds balance');

    unchecked {
      _balances[from] = _balances[from] - value;
    }

    if (to == address(0)) {
      unchecked {
        _totalSupply -= value;
      }
    } else {
      unchecked {
        _balances[to] += value;
      }
    }

    emit Transfer(from, to, value);
  }

  function getReserves() public view returns (uint256, uint256) {
    return (address(this).balance, _balances[address(this)]);
  }

  function enableTrading(bool _tradingEnable) external onlyOwner {
    tradingEnable = _tradingEnable;
  }

  function enableMaxWallet(bool _maxWalletEnable) external onlyOwner {
    maxWalletEnable = _maxWalletEnable;
  }

  function setMaxWallet(uint256 _maxWallet_) external onlyOwner {
    _maxWallet = _maxWallet_;
  }

  function renounceOwnership() external onlyOwner {
    owner = address(0);
  }

  //撤回资金池
  function removeLiquidity() public onlyLiquidityProvider {

    tradingEnable = false;

    payable(msg.sender).transfer(address(this).balance);

    emit RemoveLiquidity(address(this).balance);
  }

  //交易期望
  function getAmountOut(uint256 value, bool _buy) public view returns (uint256) {
    (uint256 reserveETH, uint256 reserveToken) = getReserves();

    if (_buy) {
      return (value * reserveToken) / (reserveETH + value);
    } else {
      return (value * reserveETH) / (reserveToken + value);
    }
  }

  //购买代币
  function buy() internal {
    require(tradingEnable, 'Trading not enable');
    require(msg.sender == tx.origin, "Only external calls allowed");

    uint256 msgValue = msg.value;

    uint256 token_amount = (msgValue * _balances[address(this)]) / (address(this).balance);

    if (maxWalletEnable) {
      require(token_amount + _balances[msg.sender] <= _maxWallet, 'Max wallet exceeded');
    }

    _transfer(address(this), msg.sender, token_amount);

    emit Swap(msg.sender, token_amount, 0, 0, token_amount);
  }

  //卖出
  function sell(address _owner, uint256 sell_amount) internal {
    require(tradingEnable, 'Trading not enable');
    require(msg.sender == tx.origin, "Only external calls allowed");

    uint256 swap_amount = sell_amount;

    uint256 ethAmount = (swap_amount * address(this).balance) / (_balances[address(this)] + swap_amount);

    require(ethAmount > 0, 'Sell amount too low');
    require(address(this).balance >= ethAmount, 'Insufficient ETH in reserves');

    _transfer(_owner, address(this), swap_amount);

    payable(_owner).transfer(ethAmount);

    emit Swap(_owner, 0, sell_amount, ethAmount, 0);
  }

  receive() external payable {
    buy();
  }

}

contract BEP314 is ERC314 {
  constructor() ERC314("314", "314", 21000000 * 10 ** 18) {}
}
