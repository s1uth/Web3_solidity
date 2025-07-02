// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Vote {
    struct Agenda {
        uint256 id;
        string description;
        uint256 agree;
        uint256 opposite;
        uint256 startTime;
    }

    address public owner; //contract 생성시 사용자를 저장해 owner로 관리
    uint256 public votingDelay = 5 minutes;
    uint256 public nextAgendaId;

    mapping(uint256 => Agenda) public agendas;
    uint256[] public agendaIds;

    mapping(address => bool) public voter;
    // 투표 완료한 인원을 관리하는 리스트
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event VotingRightGranted(address indexed voter);
    event AgendaAdded(uint256 indexed id, string description);
    event Voted(address indexed voter, uint256 indexed agendaId, bool support);

    // owner(contract 생성를 한 유저)만 이용할 수 있는 기능
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;// 이용자에게 권한 부여, 안건 추가 기능
    }

    constructor() {
        owner = msg.sender;
    }

    // 이용자에게 투표 권한을 부여하는 함수(owner만)
    function grantVotingRight(address _voter) external onlyOwner {
        require(!voter[_voter], "Already granted");
        voter[_voter] = true;
        emit VotingRightGranted(_voter);
    }

    // 안건을 추가하는 내부 함수 (owner만)
    function addAgenda(string calldata _description) external onlyOwner {
        agendas[nextAgendaId] = Agenda({
            id: nextAgendaId,
            description: _description,
            agree: 0,
            opposite: 0, 
            startTime : block.timestamp
        });
        agendaIds.push(nextAgendaId);
        emit AgendaAdded(nextAgendaId, _description);
        nextAgendaId++;
    }

    // 1. 안건을 확인하는 함수
    function getAgendas() external view returns (Agenda[] memory) {
        Agenda[] memory list = new Agenda[](agendaIds.length);
        for (uint i = 0; i < agendaIds.length; i++) {
            list[i] = agendas[agendaIds[i]];
        }
        return list;
    }

    // 2. 안건에 대해 투표하는 함수
    function vote(uint256 _agendaId, bool _support) external {
        require(voter[msg.sender], "No voting right");
        require(agendas[_agendaId].id == _agendaId, "Invalid agenda");
        require(!hasVoted[_agendaId][msg.sender], "Already voted");

        hasVoted[_agendaId][msg.sender] = true;
        if (_support) {
            agendas[_agendaId].agree++;
        } else {
            agendas[_agendaId].opposite++;
        }
        emit Voted(msg.sender, _agendaId, _support);
    }

    // 3. 안건 배포된 이후 5분 뒤부터 결과 확인 가능
    function isPassed(uint256 _agendaId) external view returns (bool) {
        require(block.timestamp >= agendas[_agendaId].startTime + votingDelay, "Wait for voting period");
        Agenda storage A = agendas[_agendaId];
        require(A.id == _agendaId, "Invalid agenda");
        return A.agree > A.opposite;
    }
}
