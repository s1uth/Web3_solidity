// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Bank{

    mapping (address => uint256) public balance_; // 각 유저가 저금한 금액

    event Deposited(address indexed _owner, uint256 value);
    event Withdrawal(address indexed _owner, uint256 value);


    // 저축, 호출한 사용자가 value로 넣은 금액만큼 저금통에 금액이 저장 payable 키워드를 통해서 ETH를 받음
    function _deposit() external payable {
        require(msg.value > 0, "No ETH sent");
        balance_[msg.sender] += msg.value;

        emit Deposited(msg.sender, msg.value);
    }
    // 출금, 반드시 저금한 사람만 출금 가능
    function _withdraw(uint256 amount) external {
        require(balance_[msg.sender] >= amount, "It can not, Ask for too Many ETH");
        balance_[msg.sender] -= amount;
        // sender의 주소로 인자로 받은 값만큼 송금
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }   
    // 저장된 금액을 반환
    function _balanceOf(address _owner) public view returns(uint256 balance){
        return balance_[_owner];
    }
}