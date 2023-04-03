// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract Ballot {
    address public chairperson;

    // profile of each voter
    struct Voter {
        uint vote; // the actual vote
        uint weight; // weight of the voter
        bool voted; // whether the voter has voted or not
    }

    // profile of each game to be voted on
    struct Game {
        bytes32 name; // 32-bytes
        uint voteCount; // number of accumulated votes

    }

    // given address, return voter
    mapping(address => Voter) public voters;

    // array of Proposal
    Game[] public games;

    constructor() {
        bytes32[4] memory gameName = [bytes32("Monopoly"), "Sorry", "Catan", "Battleship"]; // games to vote on
        chairperson = msg.sender;
        voters[chairperson].weight = 1; // chairperson can vote, and has a weight of 1

        for (uint i=0; i < gameName.length; i++) { // initialize each game
            games.push(
                Game({
                    name: gameName[i],
                    voteCount: 0
                })
            );
        }     
    }

    function giveRightToVote(address _voter) public {
        // check that the chairperson deployed the contract
        require(msg.sender == chairperson, "Only chairperson can assign right to vote");
        require(!voters[_voter].voted, "The voter has already voted.");
        require(voters[_voter].weight == 0, "The voter already has the right to vote.");

        voters[_voter].weight = 1; // changes weight to vote from 0 to 1
    }

    function vote(uint _game) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight > 0, "No rights to vote");
        require(!sender.voted,"Already voted");

        sender.vote = _game;
        sender.voted = true;

        games[_game].voteCount += sender.weight;
    }

    // returns index of winning proposal
    function winningGame() public view returns(uint winningGame_) {

        uint winningVoteCount;

        for(uint i=0;i < games.length; i++){
            if(games[i].voteCount >= winningVoteCount){
                winningGame_ = i;
                winningVoteCount = games[i].voteCount;
            }
        }

    }

    function winnerName() external view returns(bytes32 winnerName_){
            winnerName_ = games[winningGame()].name;
    }
}
