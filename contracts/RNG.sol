pragma solidity ^0.4.11;

contract RNG {
    mapping(uint256 => uint8) rng;
    uint256 public lastIndex = 0;
    mapping(uint256 => uint256) request;
    uint256 lastRequest = 0;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function RNG() {
        owner = msg.sender;
    }

    function updateRNG(uint8[] numbers) onlyOwner {
        for (uint i = 0; i < numbers.length; i++) {
            rng[lastIndex + i + 1] = numbers[i];
        }
        lastIndex += numbers.length;
    }

    function getNumbers(uint256 from, uint256 to) returns (uint8[]) {
        require(from >= 0);
        require(from <= to);
        require(to - from >= 0);
        require(to <= lastIndex);
        uint8[] memory numbers = new uint8[](to-from+1);
        for (uint i = 0; i < numbers.length; i++) {
            numbers[i] = rng[from + i];
        }
        return numbers;
    }

    function donate(uint256 count) returns (bool) {
        require(count > 0);
        request[lastRequest++] = count;
        Request(lastRequest, count);
        return true;
    }

    event Request(uint256 req, uint256 count);
}