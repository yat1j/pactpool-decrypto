// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title PactPool — Savings Pool with Dynamic Penalty Redistribution
/// @notice DECRYPTO Hackathon — Problem Statement 3: DeFi
/// @dev Deploy on Sepolia testnet. Uses basis points math to avoid rounding bugs.
contract PactPool {

    // ─── CONSTANTS ───
    uint256 public constant BASE_PENALTY_BPS  = 1000; // 10% base penalty
    uint256 public constant EXTRA_PENALTY_BPS = 2000; // up to +20% extra = 30% max
    uint256 public constant BASIS             = 10000; // 100% in basis points

    // ─── STATE ───
    struct Saver {
        uint256 amount;
        uint256 depositTime;
        uint256 unlockTime;
        string  goal;
        bool    withdrawn;
        bool    penalized;
    }

    mapping(address => Saver) public savers;
    address[] public saverList;

    uint256 public totalLocked;
    uint256 public penaltyPool;

    // ─── EVENTS ───
    event Deposited(address indexed saver, uint256 amount, uint256 unlockTime, string goal);
    event Withdrawn(address indexed saver, uint256 payout, bool penalized, uint256 penaltyAmount);
    event PenaltyAdded(address indexed saver, uint256 penaltyAmount);

    // ─── DEPOSIT ───
    function deposit(uint256 lockDays, string calldata goal) external payable {
        require(msg.value > 0,                         "Must send ETH");
        require(savers[msg.sender].amount == 0,        "Already have a pact");
        require(lockDays >= 1 && lockDays <= 365,      "Lock period: 1-365 days");
        require(bytes(goal).length > 0,                "Goal cannot be empty");
        require(bytes(goal).length <= 100,             "Goal too long (max 100 chars)");

        // HACKATHON DEMO MODE: change "1 days" to "1 minutes" for demo
        // so you can show deposit + maturity in one session.
        // Tell judges: "In production this is days, shortened for demo."
        savers[msg.sender] = Saver({
            amount:      msg.value,
            depositTime: block.timestamp,
            unlockTime:  block.timestamp + (lockDays * 1 minutes), // DEMO: 1 minutes per "day"
            goal:        goal,
            withdrawn:   false,
            penalized:   false
        });

        saverList.push(msg.sender);
        totalLocked += msg.value;

        emit Deposited(msg.sender, msg.value, savers[msg.sender].unlockTime, goal);
    }

    // ─── WITHDRAW ───
    function withdraw() external {
        Saver storage s = savers[msg.sender];
        require(s.amount > 0,  "No active savings");
        require(!s.withdrawn,  "Already withdrawn");

        uint256 principal = s.amount;
        uint256 payout;
        uint256 penaltyAmount = 0;

        if (block.timestamp >= s.unlockTime) {
            // ✅ On time — reward with proportional penalty pool share
            uint256 share = _penaltyShare(msg.sender);
            payout = principal + share;
            penaltyPool -= share;
        } else {
            // ❌ Early — pay dynamic penalty
            penaltyAmount = _calcPenalty(msg.sender);
            payout = principal - penaltyAmount;
            penaltyPool += penaltyAmount;
            s.penalized = true;
            emit PenaltyAdded(msg.sender, penaltyAmount);
        }

        // CHECKS-EFFECTS-INTERACTIONS pattern (reentrancy safe)
        s.withdrawn = true;
        totalLocked -= principal;

        payable(msg.sender).transfer(payout);
        emit Withdrawn(msg.sender, payout, s.penalized, penaltyAmount);
    }

    // ─── INTERNAL: Calculate early withdrawal penalty (basis points) ───
    function _calcPenalty(address saver) internal view returns (uint256) {
        Saver storage s = savers[saver];
        uint256 totalDuration = s.unlockTime - s.depositTime;
        uint256 elapsed       = block.timestamp - s.depositTime;
        uint256 remaining     = totalDuration - elapsed;

        // Penalty scales with how much time is left (more time left = bigger penalty)
        uint256 extraBps = (remaining * EXTRA_PENALTY_BPS) / totalDuration;
        uint256 totalBps = BASE_PENALTY_BPS + extraBps;

        return (s.amount * totalBps) / BASIS;
    }

    // ─── INTERNAL: Calculate this saver's proportional share of penalty pool ───
    function _penaltyShare(address saver) internal view returns (uint256) {
        if (penaltyPool == 0) return 0;

        // Sum all active (non-withdrawn, non-penalized) savers' amounts
        uint256 activeLocked = 0;
        for (uint i = 0; i < saverList.length; i++) {
            address addr = saverList[i];
            Saver storage s = savers[addr];
            if (!s.withdrawn && !s.penalized) {
                activeLocked += s.amount;
            }
        }

        if (activeLocked == 0) return penaltyPool; // Last saver gets everything

        // Proportional share based on deposit size
        return (savers[saver].amount * penaltyPool) / activeLocked;
    }

    // ─── VIEW: Get all saver addresses (for Goal Wall) ───
    function getAllSavers() external view returns (address[] memory) {
        return saverList;
    }

    // ─── VIEW: Get detailed info for one saver ───
    function getSaverInfo(address addr) external view returns (
        uint256 amount,
        uint256 depositTime,
        uint256 unlockTime,
        string memory goal,
        bool withdrawn,
        bool penalized,
        uint256 penaltyNow,   // Penalty ETH if withdrawn right now
        uint256 progressPct   // 0-100 percentage of lock period elapsed
    ) {
        Saver storage s = savers[addr];
        amount      = s.amount;
        depositTime = s.depositTime;
        unlockTime  = s.unlockTime;
        goal        = s.goal;
        withdrawn   = s.withdrawn;
        penalized   = s.penalized;

        if (s.amount > 0 && block.timestamp < s.unlockTime) {
            penaltyNow = _calcPenalty(addr);
        }

        if (s.amount > 0 || s.withdrawn) {
            uint256 dur  = s.unlockTime - s.depositTime;
            uint256 done = block.timestamp > s.unlockTime
                            ? dur
                            : block.timestamp - s.depositTime;
            progressPct = (done * 100) / dur;
        }
    }

    // ─── VIEW: Contract-level summary stats ───
    function getPoolStats() external view returns (
        uint256 _totalLocked,
        uint256 _penaltyPool,
        uint256 _totalSavers
    ) {
        return (totalLocked, penaltyPool, saverList.length);
    }
}
