// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {ERC20} from "@solady/tokens/ERC20.sol";
import {IRegistry} from "../interfaces/IRegistry.sol";
import {IDisputeResolver} from "../interfaces/IDisputeResolver.sol";

/// @title Registry
/// @dev 
contract Registry is IRegistry {

    /// @notice The owner of the registry
    address public immutable owner;

    /// @notice The token that is used to stake and unstake
    ERC20 internal immutable token;

    /// @notice Maps wallet addresses to user
    mapping(address _wallet => User _user) public users;

    /// @notice Array of services
    Service[] public services;

    Deal[] public deals;

    /// @notice Maps service ids to an array of ratings
    mapping(uint40 _serviceId => Rating[] _ratings) public ratings;

    /// @notice Address of the dispute resolver
    address public disputeResolver;

    constructor(address _token) {
        owner = msg.sender;
        token = ERC20(_token);
    }

    /// @inheritdoc IRegistry
    function stake(uint256 _amount) external {
        if (_amount == 0) revert InvalidAmount();

        token.transferFrom(msg.sender, address(this), _amount);
        
        users[msg.sender].stake += _amount;
        
        emit Staked(msg.sender, _amount);
    }

    /// @inheritdoc IRegistry
    function unstake(uint256 _amount) external {
        if (_amount == 0) revert InvalidAmount();
        if (users[msg.sender].stake < _amount) revert InsufficientStake();
        
        users[msg.sender].stake -= _amount;
        
        token.transfer(msg.sender, _amount);
        
        emit Unstaked(msg.sender, _amount);
    }

    /// @inheritdoc IRegistry
    function setProfile(string calldata _profile) external {
        users[msg.sender].profile = _profile;
        
        emit ProfileSet(msg.sender);
    }

    /// @inheritdoc IRegistry
    function addService(string calldata _description) external {
        uint40 serviceId = uint40(services.length);

        services.push(Service({
            id: serviceId,
            status: Status.NEW,
            tasker: msg.sender,
            description: _description
        }));

        emit ServiceCreated(serviceId);
    }

    /// @inheritdoc IRegistry
    function updateService(uint40 _serviceId, string calldata _description) external {
        // todo: add onlyTasker
        if (services[_serviceId].tasker != msg.sender) revert Unauthorized();
        
        Service storage service = services[_serviceId];
        service.description = _description;

        emit ServiceUpdated(_serviceId, _description);
    }

    function createDeal(uint40 _serviceId, uint256 _price, address _beneficiary) external {

        if (services[_serviceId].tasker != msg.sender) revert Unauthorized();
        
        if (_beneficiary == address(0)) revert InvalidBeneficiary();

        uint40 nextDealId = uint40(deals.length);

        deals.push(Deal({
            id: nextDealId,
            serviceId: _serviceId,
            price: _price,
            beneficiary: _beneficiary
        }));

        emit DealCreated(nextDealId);
    }

    /// @inheritdoc IRegistry
    function rate(uint40 _dealId, uint8 _rating, string calldata _review) external {

        if (deals[_dealId].beneficiary != msg.sender) revert Unauthorized();
        // if (deals[_dealId].status != DealStatus.COMPLETED) revert DealNotCompleted();

        // add review to the service
        ratings[deals[_dealId].serviceId].push(Rating({
            reviewer: msg.sender,
            rating: _rating,
            review: _review
        }));

        emit Rated(_dealId, _rating);
    }

    /// @inheritdoc IRegistry
    function dispute(uint40 _serviceId) external {
        // you can't dispute unless the dispute resolveraddress is set
        if (disputeResolver == address(0)) revert DisputeResolverNotSet();

        IDisputeResolver(disputeResolver).dispute(_serviceId);

        emit Disputed(_serviceId);
    }

    /// @inheritdoc IRegistry
    function setDisputeResolver(address _disputeResolver) external {
        // todo: add onlyOwner
        if (owner != msg.sender) revert Unauthorized();

        disputeResolver = _disputeResolver;

        // todo: emit event?
    }

    
}
