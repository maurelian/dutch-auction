pragma solidity 0.4.11;
import "Events/Event.sol";


contract ScalarEvent is Event {

    /*
     *  Constants
     */
    uint8 constant public SHORT = 0;
    uint8 constant public LONG = 1;
    uint16 constant public OUTCOME_RANGE = 10000;

    /*
     *  Storage
     */
    int public lowerBound;
    int public upperBound;

    /*
     *  Public functions
     */
    /// @dev Contract constructor validates and sets basic event properties.
    /// @param _collateralToken Tokens used as collateral in exchange for outcome tokens.
    /// @param _oracle Oracle contract used to resolve the event.
    /// @param _oracleEventIdentifier Optional identifier to identify a specific oracle event.
    /// @param outcomeCount Number of event outcomes.
    /// @param _lowerBound Lower bound for event outcome.
    /// @param _upperBound Lower bound for event outcome.
    function ScalarEvent(
        address _collateralToken,
        address _oracle,
        bytes32 _oracleEventIdentifier,
        uint outcomeCount,
        int _lowerBound,
        int _upperBound
    )
        public
        Event(_collateralToken, _oracle, _oracleEventIdentifier, outcomeCount)
    {
        if (outcomeCount > 2 || upperBound <= lowerBound)
            // Outcome count is too high or bounds are invalid
            throw;
        lowerBound = _lowerBound;
        upperBound = _upperBound;
    }

    /// @dev Exchanges user's winning outcome tokens for collateral tokens.
    function redeemWinnings()
        public
        returns (uint winnings)
    {
        if (!isWinningOutcomeSet)
            // Winning outcome is not set yet
            throw;
        // Calculate winnings
        uint16 convertedWinningOutcome;
        // Outcome is lower than defined lower bound
        if (winningOutcome < lowerBound)
            convertedWinningOutcome = 0;
        // Outcome is higher than defined upper bound
        else if (winningOutcome > upperBound)
            convertedWinningOutcome = OUTCOME_RANGE;
        // Map outcome to outcome range
        else
            convertedWinningOutcome = uint16(OUTCOME_RANGE * (winningOutcome - lowerBound) / (upperBound - lowerBound));
        uint factorShort = OUTCOME_RANGE - convertedWinningOutcome;
        uint factorLong = OUTCOME_RANGE - factorShort;
        uint shortOutcomeTokenCount = outcomeTokens[SHORT].balanceOf(msg.sender);
        uint longOutcomeTokenCount = outcomeTokens[LONG].balanceOf(msg.sender);
        winnings = (shortOutcomeTokenCount * factorShort + longOutcomeTokenCount * factorLong) / OUTCOME_RANGE;
        // Revoke all tokens of all outcomes
        outcomeTokens[SHORT].revokeTokens(msg.sender, shortOutcomeTokenCount);
        outcomeTokens[LONG].revokeTokens(msg.sender, longOutcomeTokenCount);
        // Payout winnings
        if (!collateralToken.transfer(msg.sender, winnings))
            // Transfer failed
            throw;
    }
}