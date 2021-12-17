// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../Helpers/TokenBasics/StandardToken.sol";
import "../../../Helpers/Modifiers/Ownable.sol";

/**
 * @title Configurable
 * @dev Configurable varriables of the contract
 **/
contract Configurable {
    uint256 public constant cap = 1000000*10**18;
    uint256 public constant basePrice = 100*10**18; // tokens per 1 ether
    uint256 public tokensSold = 0;
    
    uint256 public constant tokenReserve = 1000000*10**18;
    uint256 public remainingTokens = 0;
}

/**
 * @title CrowdsaleToken 
 * @dev Contract to preform crowd sale with token
 **/
contract CrowdsaleToken is StandardToken, Configurable, Ownable {
    /**
     * @dev enum of current crowd sale state
     **/
     enum Stages {
        none,
        icoStart, 
        icoEnd
    }
    
    Stages currentStage;
  
    /**
     * @dev constructor of CrowdsaleToken
     **/
    constructor() {
        currentStage = Stages.none;
        balances[owner] += tokenReserve;
        totalSupply_ += tokenReserve;
        remainingTokens = cap;
        emit Transfer(address(this), owner, tokenReserve);
    }
    
    /**
     * @dev receive ether function to send ether to for Crowd sale
     **/
    receive() external payable {
        require(currentStage == Stages.icoStart);
        require(msg.value > 0);
        require(remainingTokens > 0);
        
        
        uint256 weiAmount = msg.value; // Calculate tokens to sell
        uint256 tokens = (weiAmount * basePrice) / (1 ether);
        uint256 returnWei;
        
        if((tokensSold + tokens) > cap){
            uint256 newTokens = cap - tokensSold;
            uint256 newWei = (newTokens * 1 ether ) / (basePrice);
            returnWei = weiAmount- newWei;
            weiAmount = newWei;
            tokens = newTokens;
        }
        
        tokensSold += tokens; // Increment raised amount
        remainingTokens = cap - tokensSold;
        if(returnWei > 0){
            payable(msg.sender).transfer(returnWei);
            emit Transfer(address(this), msg.sender, returnWei);
        }
        
        balances[msg.sender] += tokens;
        emit Transfer(address(this), msg.sender, tokens);
        totalSupply_ += tokens;
        payable(owner).transfer(weiAmount);// Send money to owner
    }
    

    /**
     * @dev startIco starts the public ICO
     **/
    function startIco() public onlyOwner {
        require(currentStage != Stages.icoEnd);
        currentStage = Stages.icoStart;
    }
    

    /**
     * @dev endIco closes down the ICO 
     **/
    function endIco() internal {
        currentStage = Stages.icoEnd;
        // Transfer any remaining tokens
        if(remainingTokens > 0)
            balances[owner] += remainingTokens;
        // transfer any remaining ETH balance in the contract to the owner
        payable(owner).transfer(address(this).balance); 
    }

    /**
     * @dev finalizeIco closes down the ICO and sets needed varriables
     **/
    function finalizeIco() public onlyOwner {
        require(currentStage != Stages.icoEnd);
        endIco();
    }
    
}

/**
 * @title basicCrowdSaleToken 
 * @dev Contract to create the basicCrowdSaleToken Token
 **/
contract BasicCrowdSaleToken is CrowdsaleToken {
    string public constant name = "basicCrowdSaleToken";
    string public constant symbol = "BCST";
    uint32 public constant decimals = 18;
}
