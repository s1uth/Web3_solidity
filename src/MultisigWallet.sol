// SPDX-License-Identifier: UNLICENSED
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.20;
 
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

 
contract MultisigWallet is Ownable{
    using ECDSA for bytes32;
    // 시스템을 가진 소유자의 주소
    address public systemAddress;
    
    struct Agenda {
        uint256 id; // 안건의 인덱스
        address to; // 누구에게
        uint256 value; // 얼마나
        bytes data;
        uint256 agree; //찬성
        uint256 opposite;//반대
        uint256 startTime; //생성시간
    }

    uint256 public votingDelay = 5 minutes;
    uint256 public nextAgendaId; //다음 안건의 인덱스

    mapping(uint256 => Agenda) public agendas; //안건 목록을 관리하는 테이블
    uint256[] public agendaIds;

    mapping(address => bool) public voter; //투표 권한을 가진 참여자
    mapping(uint256 => mapping(address => bool)) public hasVoted; //투표 완료한 인원을 관리하는 리스트

    event VotingRightGranted(address indexed voter);
    event AgendaAdded(uint256 indexed id, address to, uint256 value, bytes data);
    event Voted(address indexed voter, uint256 indexed agendaId, bool support);

    constructor(address _systemAddress) Ownable(msg.sender) {
         systemAddress = _systemAddress;
    }
    // 이용자에게 투표 권한을 부여하는 함수(owner만)
    function grantVotingRight(address _voter) external onlyOwner {
        require(!voter[_voter], "Already granted");
        voter[_voter] = true;
        emit VotingRightGranted(_voter);
    }

    // 안건을 추가하는 내부 함수 (owner만)
    function addAgenda(address _to, uint256 _value, bytes calldata _data) external onlyOwner {
        agendas[nextAgendaId] = Agenda({
            id: nextAgendaId,
            to: _to,
            value: _value,
            data: _data,
            agree: 0,
            opposite: 0, 
            startTime : block.timestamp
        });
        agendaIds.push(nextAgendaId);
        emit AgendaAdded(nextAgendaId,agendas[nextAgendaId].to, agendas[nextAgendaId].value, agendas[nextAgendaId].data);
        nextAgendaId++;
    }

    // 안건을 확인하는 함수
    function getAgendas(uint256 id) external view returns (Agenda memory target) {
        return agendas[id];
    }

    // 투표
    function vote(uint256 id, address _to, uint8 _value, bytes calldata _data, bytes calldata _signature, bool support) external payable {
        require(isValidSignature(
            systemAddress,
            keccak256(abi.encodePacked(id, _to, _value, _data)),
            _signature
            ), "Invalid Signature"
        );
         Agenda storage a = agendas[id];
        require(block.timestamp >= a.startTime + votingDelay, "Voting not started");
        require(voter[msg.sender], "No voting right");
        require(!hasVoted[id][msg.sender], "Already voted");

        hasVoted[id][msg.sender] = true;
        if (support) a.agree++;
        else a.opposite++;

        emit Voted(msg.sender, id, support);

        
    }
     // 사인을 검증하는 함수
    function isValidSignature(address _systemAddress, bytes32 hash, bytes memory _signature) internal pure returns (bool) {
        require(_systemAddress != address(0), "Missing System Address");
    
        return ECDSA.recover(hash, _signature) == _systemAddress;
    }

}