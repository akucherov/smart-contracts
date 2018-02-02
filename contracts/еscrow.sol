pragma solidity ^0.4.16;

contract Escrow {
    enum Stages {
        None,
        Offer,
        Accepted,        
        Finished
    }

    Stages stage;
    address public token;
    uint256 public tokensForSell;
    uint256 public tokensCost;
    uint256 public withdrawTimeout;
    uint256 public withdrawDeadline;
    address public tokensSeller;
    address public tokensBuyer;

    function Escrow(address erc20) public {
        stage = Stages.None;
        token = erc20;
    }     

    function offer(uint256 tokens, uint256 cost, uint256 timeout, address buyer) public {
        require(stage == Stages.None);
        require(buyer != address(0));

        tokensSeller = msg.sender;
        tokensBuyer = buyer;
        tokensForSell = tokens;
        tokensCost = cost;
        withdrawTimeout = timeout;

        token.call(bytes4(keccak256("transferFrom(address,address,uint256)")), tokensSeller, address(this), tokensForSell);

        stage = Stages.Offer;
    }

    function cancel() public {
        require(stage == Stages.Offer);
        require(msg.sender == tokensSeller);
        token.call(bytes4(keccak256("transfer(address,uint256)")), tokensSeller, tokensForSell);
        selfdestruct(tokensSeller);
    }

    function accept() public payable {
        require(stage == Stages.Offer);
        require(msg.sender == tokensBuyer);
        require(msg.value == tokensCost);
        
        tokensCost = msg.value;
        withdrawDeadline = now + withdrawTimeout;
        stage = Stages.Accepted;
    }

    function withdraw() public returns(bool) {
        require(stage == Stages.Accepted);

        if (msg.sender == tokensSeller) {
            msg.sender.transfer(this.balance);
            return true;
        }

        if (msg.sender == tokensBuyer && now > withdrawDeadline) {
            assert(token.call("transfer", tokensBuyer, tokensForSell));
            stage = Stages.Finished;
            return true;
        }

        return false;
    }

    function done() public {
        require(stage == Stages.Finished);
        require(msg.sender == tokensSeller);
        selfdestruct(tokensSeller);
    }
}