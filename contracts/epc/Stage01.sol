pragma solidity ^0.4.16;

contract EPC {
    string _name;
    string _description;

    function EPC(string name, string description) public {
        _name = name;
        _description = description;
    }

    function getName() public constant returns (string) {
        return _name;
    }

    function getDescription() public constant returns (string) {
        return _description;
    }
}