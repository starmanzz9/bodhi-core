pragma solidity ^0.4.15;

import "./IAddressManager.sol";
import "../libs/Ownable.sol";

contract AddressManager is IAddressManager, Ownable {
    uint16 public currentEventFactoryIndex = 0; // Index of the next upgraded EventFactory contract
    uint16 public currentOracleFactoryIndex = 0; // Index of the next upgraded OracleFactory contract
    address public bodhiTokenAddress;
    mapping(uint16 => address) public eventFactoryAddresses;
    mapping(uint16 => address) public oracleFactoryAddresses;

    // Events
    event BodhiTokenAddressChanged(address indexed _oldAddress, address indexed _newAddress);
    event EventFactoryAddressAdded(uint16 _index, address indexed _contractAddress);
    event OracleFactoryAddressAdded(uint16 _index, address indexed _contractAddress);

    function AddressManager() Ownable(msg.sender) public {
    }

    /// @dev Allows the owner to set the address of the Bodhi Token contract.
    /// @param _tokenAddress The address of the Bodhi Token contract.
    function setBodhiTokenAddress(address _tokenAddress) 
        public 
        onlyOwner 
        validAddress(_tokenAddress) 
    {
        BodhiTokenAddressChanged(bodhiTokenAddress, _tokenAddress);
        bodhiTokenAddress = _tokenAddress;
    }

    /// @dev Allows the owner to set the address of an EventFactory contract.
    /// @param _sender This should be the msg.sender of the EventFactory instantiation call.
    /// @param _contractAddress The address of the EventFactory contract.
    function setEventFactoryAddress(address _sender, address _contractAddress) 
        public 
        validAddress(_contractAddress) 
    {
        require(_sender == owner);
        eventFactoryAddresses[currentEventFactoryIndex] = _contractAddress;
        EventFactoryAddressAdded(currentEventFactoryIndex, _contractAddress);
        currentEventFactoryIndex++;
    }

    /// @dev Allows the owner to set the address of an Oracle contract.
    /// @param _sender This should be the msg.sender of the OracleFactory instantiation call.
    /// @param _contractAddress The address of the Oracle contract.
    function setOracleFactoryAddress(address _sender, address _contractAddress) 
        public 
        validAddress(_contractAddress) 
    {
        require(_sender == owner);
        oracleFactoryAddresses[currentOracleFactoryIndex] = _contractAddress;
        OracleFactoryAddressAdded(currentOracleFactoryIndex, _contractAddress);
        currentOracleFactoryIndex++;
    }

    /// @notice Gets the current address of the Bodhi Token contract.
    /// @return The address of Bodhi Token contract.
    function getBodhiTokenAddress() 
        public 
        view 
        returns (address) 
    {
        return bodhiTokenAddress;
    }

    /// @notice Gets the latest index of a deployed EventFactory contract.
    /// @return The index of the latest deployed EventFactory contract.
    function getLastEventFactoryIndex() 
        public 
        view 
        returns (uint16) 
    {
        if (currentEventFactoryIndex == 0) {
            return 0;
        } else {
            return currentEventFactoryIndex - 1;
        }
    }

    /// @notice Gets the address of the EventFactory contract.
    /// @param _indexOfAddress The index of the stored EventFactory contract address.
    /// @return The address of the EventFactory contract.
    function getEventFactoryAddress(uint16 _indexOfAddress) 
        public 
        view 
        returns (address) 
    {
        return eventFactoryAddresses[_indexOfAddress];
    }

    /// @notice Gets the latest index of a deployed OracleFactory contract.
    /// @return The index of the latest deployed OracleFactory contract.
    function getLastOracleFactoryIndex() 
        public 
        view 
        returns (uint16) 
    {
        if (currentOracleFactoryIndex == 0) {
            return 0;
        } else {
            return currentOracleFactoryIndex - 1;
        }
    }

    /// @notice Gets the address of the Oracle contract.
    /// @param _indexOfAddress The index of the stored Oracle contract address.
    /// @return The address of Oracle contract.
    function getOracleFactoryAddress(uint16 _indexOfAddress) 
        public 
        view 
        returns (address) 
    {
        return oracleFactoryAddresses[_indexOfAddress];
    }
}