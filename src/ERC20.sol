// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ERC20 {

    uint256 public ERC_total;

    mapping (address => uint256) public BalanceOf;
    mapping (address => mapping(address => uint256)) public Allowance;

    string public ERC_name; 
    string public ERC_symbol;
    uint8 public ERC_decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimal_){
        ERC_name = name_;
        ERC_symbol = symbol_;
        ERC_decimals = decimal_;
        ERC_total = 10000000000;
    }

    // 토큰 생성
    function _mint(uint _value) external {
        BalanceOf[msg.sender] += _value;
        ERC_total += _value;
        emit Transfer(address(0), msg.sender, _value);
    }
    // 토큰 소각
    function burn(uint _value) external {
        BalanceOf[msg.sender] -= _value;
        ERC_total -= _value;
        emit Transfer(msg.sender, address(0), _value);
    }

    //토큰 이름을 반환
    function name() public view returns (string memory){
        return ERC_name;
    }
    //토큰의 심볼을 반환
    function symbol() public view returns (string memory){
        return ERC_symbol;
    }
    //토큰의 소수점 자릿수를 반환
    function decimals() public view returns (uint8){
        return ERC_decimals;
    }
    //토큰의 총발행량을 반환
    function totalSupply() public view returns (uint256){
        return ERC_total;
    }

    //매개 변수의 전달되는 _owner의 토큰 잔액을 반환
    function balanceOf(address _owner) public view returns (uint256 balance){
        return BalanceOf[_owner];
    }

    //전송하는데 사용되는 매서드 (받는 사람, 보내는 양)
    function transfer(address _to, uint256 _value) public returns (bool success){
        BalanceOf[msg.sender] -= _value;
        BalanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    // approve를 통해 권한을 부여받은 사용자가 토큰을 전송할 때 사용하는 메서드
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        if(Allowance[_from][msg.sender] < _value){
            return false;
        }

        Allowance[_from][msg.sender] -= _value;
        BalanceOf[_from] -= _value;
        BalanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);

        return true;
    }
    // 토큰을 호출한 사용자가 spender에게 특정양(value) 만큼의 사용권한을 부여
    function approve(address _spender, uint256 _value) public returns (bool success){
        Allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    // approve를 통해 부여 받은 권한으로 사용할 수 있는 토큰의 양을 반환
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return Allowance[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}