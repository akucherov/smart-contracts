pragma solidity ^0.4.16;

contract EPC {
    string _name;
    string _description;
    address public owner;
    mapping(uint256 => address) ownership;
    uint256 lastIndex = 0;   

    function EPC(string name, string description) public {
        owner = msg.sender;
        ownership[0] = owner;
        _name = name;
        _description = description;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getName() public constant returns (string) {
        return _name;
    }

    function getDescription() public constant returns (string) {
        return _description;
    }

    function changeOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        require(newOwner != owner);
        owner = newOwner;
        ownership[lastIndex+1] = owner;
        lastIndex += 1;
    }

    function getOwnershipLength() public constant returns (uint256) {
        return lastIndex + 1;
    }

    function getOwnership(uint256 from, uint256 to) public constant returns (address[]) {
        require(from >= 0);
        require(from <= to);
        require(to - from >= 0);
        require(to <= lastIndex);
        address[] memory result = new address[](to-from+1);
        for (uint256 i = 0; i < result.length; i++) {
            result[i] = ownership[from + i];
        }
        return result;
    }
}