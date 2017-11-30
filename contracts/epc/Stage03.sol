pragma solidity ^0.4.16;

contract EPC {
    enum Status { New, InTransit, Sold, Recalled}

    struct ProductStatus {
        Status name;
        uint timestamp;
        address owner;
    }

    string _name;
    string _description;
    address public owner;
    mapping(uint256 => address) ownership;
    uint256 lastIndex = 0;
    ProductStatus currentStatus;
    mapping(uint256 => ProductStatus) statuses;
    uint256 historyIndex = 0;   

    function EPC(string name, string description) public {
        owner = msg.sender;
        ownership[0] = owner;
        currentStatus = ProductStatus(Status.New, now, owner);
        statuses[0] = currentStatus;
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
        require(to - from <= 9);
        require(to <= lastIndex);
        address[] memory result = new address[](to-from+1);
        for (uint256 i = 0; i < result.length; i++) {
            result[i] = ownership[from + i];
        }
        return result;
    }

    function changeStatus(Status status) public onlyOwner {
        currentStatus = ProductStatus(status, now, owner);
        statuses[historyIndex+1] = currentStatus;
        historyIndex += 1;
        if (status == Status.Recalled) {
            Recalled(currentStatus.timestamp, owner);
        }
    }

    function recall() public {
        require(msg.sender == ownership[0]);
        currentStatus = ProductStatus(Status.Recalled, now, msg.sender);
        statuses[historyIndex+1] = currentStatus;
        historyIndex += 1;
        Recalled(currentStatus.timestamp, owner);
    }

    function getStatusesLength() public constant returns (uint256) {
        return historyIndex + 1;
    }

    function getStatuses(uint256 from, uint256 to) public constant returns (ProductStatus[]) {
        require(from >= 0);
        require(from <= to);
        require(to - from >= 0);
        require(to - from <= 9);
        require(to <= historyIndex);
        ProductStatus[] memory result = new ProductStatus[](to-from+1);
        for (uint256 i = 0; i < result.length; i++) {
            result[i] = statuses[from + i];
        }
        return result;
    }

    event Recalled(uint indexed timestamp, address indexed owner);
}