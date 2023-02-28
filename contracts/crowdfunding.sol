// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract CrowdFunding {
    address public owner;
    IERC20 public token;

    struct Campaign {  
        address creator;
        string title;
        uint goal;
        uint raised;
        bool claimed;

    }
    uint public count;

    mapping(uint => Campaign) public campaigns;

    event contributed(address from,uint amount);
    event withdrawn(uint amount);
    event created(  uint id,address indexed creator,uint goal,string title);

    constructor(IERC20 _token) {
        owner = msg.sender;
        token = _token;
    }
   modifier onlyOwner()
      {
          require(msg.sender==owner,"You are not owner");
          _;
      }
    function createCampaign(uint _goal,string memory _title) external{
        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            title:_title,
            goal: _goal,
            raised:0,
            claimed: false
        });

        emit created(count, msg.sender, _goal,_title);
    }

    function contribute(uint _id,uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(token.allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance");
        require(campaign.claimed==false,"Campaign is closed and fund have been transferred");
        campaign.raised += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
        emit contributed(msg.sender,_amount);
    }

    function withdraw(uint _id) external onlyOwner {
         Campaign storage campaign = campaigns[_id];
        require(campaign.raised >= campaign.goal, "The goal has not been reached");
        token.transfer(campaign.creator, campaign.raised);
        campaign.claimed=true;
        emit withdrawn(campaign.raised);
    }
}
