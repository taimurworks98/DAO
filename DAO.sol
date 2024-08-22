
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @author Taimoor Malik

contract DAO {
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCountYes;
        uint256 voteCountNo;
        bool executed;
        address proposer;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    uint256 public proposalCount;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier hasNotVoted(uint256 _proposalId) {
        require(!hasVoted[_proposalId][msg.sender], "You have already voted");
        _;
    }

    modifier proposalExists(uint256 _proposalId) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Proposal does not exist");
        _;
    }

    modifier notExecuted(uint256 _proposalId) {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        _;
    }

    // Function to create a new proposal
    function createProposal(string memory _description) public {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            voteCountYes: 0,
            voteCountNo: 0,
            executed: false,
            proposer: msg.sender
        });
    }

    // Function to vote on a proposal
    function vote(uint256 _proposalId, bool _voteYes) public proposalExists(_proposalId) hasNotVoted(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];

        if (_voteYes) {
            proposal.voteCountYes++;
        } else {
            proposal.voteCountNo++;
        }

        hasVoted[_proposalId][msg.sender] = true;
    }

    // Function to execute a proposal based on votes
    function executeProposal(uint256 _proposalId) public proposalExists(_proposalId) notExecuted(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];

        // Simple majority rule
        require(proposal.voteCountYes > proposal.voteCountNo, "Proposal did not pass");

        // Mark the proposal as executed
        proposal.executed = true;

        // Proposal execution logic
        // For now, we'll just use a basic logic that transfers some ether to the proposer
        payable(proposal.proposer).transfer(address(this).balance);
    }

    // Function to receive Ether
    receive() external payable {}

    // Fallback function
    fallback() external payable {}
}
