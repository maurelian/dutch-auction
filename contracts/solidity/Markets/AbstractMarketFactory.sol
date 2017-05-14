pragma solidity 0.4.11;
import "Events/AbstractEvent.sol";
import "MarketMakers/AbstractMarketMaker.sol";
import "Markets/AbstractMarket.sol";


/// @title Abstract market factory contract - Functions to be implemented by market factories.
contract MarketFactory {

    function createMarket(Event eventContract, MarketMaker marketMaker, uint fee, uint funding) public returns (Market);
}
