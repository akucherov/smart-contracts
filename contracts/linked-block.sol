pragma solidity ^0.4.16;

contract LinkedBlock {
    bool public status;
    bool locked;

    address public next;
    address public prev;
    
    modifier once() {
        if (!locked) {
            locked = true;
            _;
            locked = false;
        }
    }
    
    function LinkedBlock() public {
        status = false;
    }

    function linkNext(address nextBlock) public {
        require(nextBlock != address(0));
        next = nextBlock;
        LinkedBlock(next).linkBack();
    }

    function linkBack() public {
        require(LinkedBlock(msg.sender).next() == address(this));
        prev = msg.sender;
    }

    function run() public once {
        status = !status;
        if (next != address(0)) {
            LinkedBlock(next).run();
        }
        if (prev != address(0)) {
            LinkedBlock(prev).run();
        }
    }

}