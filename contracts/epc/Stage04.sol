pragma solidity ^0.4.16;

contract EPC {
    enum Status { New, InTransit, Sold, Recalled}

    struct ProductStatus {
        Status name;
        uint timestamp;
        address owner;
    }

    struct ProductComponent {
        address product;
        uint value;
        string unit; 
    }

    string _name;
    string _description;
    address public owner;
    mapping(uint256 => address) ownership;
    uint256 ownershipIndex = 0;
    ProductStatus currentStatus;
    mapping(uint256 => ProductStatus) statuses;
    uint256 statusesIndex = 0;
    mapping(uint256 => ProductComponent) components; 
    uint256 public componentsLength = 0;  

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
        ownership[ownershipIndex+1] = owner;
        ownershipIndex += 1;
    }

    function getOwnershipLength() public constant returns (uint256) {
        return ownershipIndex + 1;
    }

    function getOwnership(uint256 from, uint256 to) public constant returns (address[]) {
        require(from >= 0);
        require(from <= to);
        require(to - from >= 0);
        require(to - from <= 9);
        require(to <= ownershipIndex);
        address[] memory result = new address[](to-from+1);
        for (uint256 i = 0; i < result.length; i++) {
            result[i] = ownership[from + i];
        }
        return result;
    }

    function changeStatus(Status status) public onlyOwner {
        currentStatus = ProductStatus(status, now, owner);
        statuses[statusesIndex+1] = currentStatus;
        statusesIndex += 1;
        if (status == Status.Recalled) {
            Recalled(currentStatus.timestamp, owner);
        }
    }

    function recall() public {
        require(msg.sender == ownership[0]);
        currentStatus = ProductStatus(Status.Recalled, now, msg.sender);
        statuses[statusesIndex+1] = currentStatus;
        statusesIndex += 1;
        Recalled(currentStatus.timestamp, owner);
    }

    function getStatusesLength() public constant returns (uint256) {
        return statusesIndex + 1;
    }

    function getStatuses(uint256 from, uint256 to) public constant returns (ProductStatus[]) {
        require(from >= 0);
        require(from <= to);
        require(to - from >= 0);
        require(to - from <= 9);
        require(to <= statusesIndex);
        ProductStatus[] memory result = new ProductStatus[](to-from+1);
        for (uint256 i = 0; i < result.length; i++) {
            result[i] = statuses[from + i];
        }
        return result;
    }

    function addComponent(address product, uint value, string unit) public {
        require(msg.sender == ownership[0]);
        require(product != address(0));
        require(value != 0);
        components[componentsLength] = ProductComponent(product, value, unit);
        componentsLength += 1;
    }

    function getComponents(uint256 from, uint256 to) public constant returns (ProductComponent[]) {
        require(from >= 0);
        require(from <= to);
        require(to - from >= 0);
        require(to - from <= 9);
        require(to < componentsLength);
        ProductComponent[] memory result = new ProductComponent[](to-from+1);
        for (uint256 i = 0; i < result.length; i++) {
            result[i] = components[from + i];
        }
        return result;
    }

    event Recalled(uint indexed timestamp, address indexed owner);
}