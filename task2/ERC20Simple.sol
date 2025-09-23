// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Simple {

    address public  owner;

    mapping(address account => uint256 amount) private balances;

    mapping(address owner => mapping(address spender => uint256 amount)) private allowances;

    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    //合约所有者赋值，并且初始铸币1000000枚
    constructor(){
        owner = msg.sender;
        mint(1000000*10**18);
    }

    //铸币及增发
    function mint(uint256 value) public onlyOwner{
        totalSupply += value;
        balances[msg.sender] += value;
        emit Transfer(address(0), msg.sender, value);
    }

    //查询账户余额
    function bananceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    //转账
    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= balances[msg.sender], "Insufficient balance");
        require(to!=address(0),"to not 0 address");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    //授权
    function approve(address spender, uint256 value) public returns (bool) {
        require(value <= balances[msg.sender], "Insufficient balance");
        require(spender!=address(0),"spender not 0 address");
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    //代扣转账
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(allowances[from][msg.sender]>0,"Unauthorized");
        require(allowances[from][msg.sender]>=value,"Not enough amount");
        require(balances[from]>=value,"Not enough amount");
        require(from!=address(0),"from not 0 address");
        require(to!=address(0),"to not 0 address");
        allowances[from][msg.sender] -= value;
        balances[from] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
    // 自定义修饰符，仅允许合约所有者调用
    modifier onlyOwner {
        require(msg.sender == owner, "only owner can call");
        _;
    }

}
//合约地址
//0x2E8Bd53369b6459C3E0e19aB8790322eC7482909