#  PactPool — Commitment Capital Protocol

> DECRYPTO Hackathon — Problem Statement 3: DeFi

Save with skin in the game — enforced by immutable code.

Lock ETH with a public savings goal. Break your pact early and pay a dynamic penalty. That penalty flows directly into a shared pool and gets redistributed to everyone who stayed committed.

---

##  Links

- Live Demo: https://github.com/harshvardhanxd/pactpool-decrypto
- Contract (Sepolia): 0xaC8BaaBFACdE6AeafA4456FD27f849E095828891
- Etherscan: https://sepolia.etherscan.io/address/PASTE_CONTRACT_ADDRESS_HERE
- GitHub: https://github.com/harshvardhanxd/pactpool-decrypto

---

##  The Core Idea

Most savings apps fail because quitting costs nothing. PactPool creates Commitment Capital — your ETH is locked by a smart contract, and breaking your pact directly funds the bonuses of those who didn't.

> Deposit ETH → choose your tier → set your goal publicly → reach the unlock date and earn a bonus, or exit early and fund someone else's success.

---

##  Features

###  Four Commitment Tiers

| Tier | Penalty Range | Reward Share |
|------|--------------|-------------|
|  Bronze | 10–20% | 1.0× |
|  Silver | 15–25% | 1.5× |
|  Gold | 20–28% | 2.0× |
|  Diamond | 22–30% | 3.0× |

Higher tier = more skin in the game, but a much larger slice of the penalty pool when you complete.

###  8 Goal Categories
Categorize your commitment for the public Goal Wall:

 Education ·  Travel ·  Business ·  Gadget ·  Health ·  Home ·  Invest ·  Other

###  Built-in Goal Wall (Tab)
A live on-chain commitment board showing every saver's goal, tier, category, progress bar, and status (Active / Completed / Broken) — all inside the same page. No separate file needed. Filter by status.

###  Dedicated Penalty Simulator (Tab)
A standalone tab with an interactive canvas chart. Adjust lock period, ETH amount, and withdrawal day with sliders to see exactly how much you'd lose vs. keep — before committing a single wei.

###  Live Countdown Timer
Your active pact card shows a real-time days/hours/minutes/seconds countdown to unlock, alongside the current penalty percentage if you exit right now.

###  Live Activity Ticker
A scrolling marquee shows live-style on-chain events — pacts locked, early exits with penalty amounts, and completed claims with bonus rewards.

###  Auto Wallet Reconnect
MetaMask auto-reconnects on page load if already authorized — no extra tap needed.

###  Demo Mode
The app works fully without a deployed contract. Mock stats and Goal Wall data are shown automatically so the UI is always presentable, even during integration.

###  Toast Notification System
Smooth animated toasts (not browser alerts) for all user actions — wallet connect, deposit submitted, error states.

---

##  User Flow

1. Open app → mock stats and Goal Wall load immediately (demo mode)
2. Connect MetaMask → wallet address shown in nav; live contract data loads
3. Select tier (Bronze → Diamond) based on your risk/reward preference
4. Pick a category to tag your goal publicly
5. Write your goal (up to 100 characters), enter ETH amount, set lock period (1–365 days)
6. Preview pact — see lock amount, unlock date, max/min penalty, and reward share multiplier
7. Lock ETH → MetaMask confirmation → pact created on Sepolia
8. Active pact card appears — live countdown, progress bar, current penalty
9. Two outcomes:
   - ✅ Hold until unlock → withdraw full ETH + bonus from penalty pool
   - 🚨 Exit early → pay 10–30% dynamic penalty, redistributed to other savers

---

##  Tech Stack

| Layer | Tech |
|---|---|
| Smart Contract | Solidity 0.8.20, Sepolia testnet |
| Frontend | Single-file HTML + Vanilla JS — zero npm, zero build step |
| Web3 | Ethers.js 5.7.2 via CDN |
| Wallet | MetaMask (auto-reconnect) |
| Charts | HTML5 Canvas (no charting library) |
| Fonts | Syne + JetBrains Mono (Google Fonts) |
| Hosting | GitHub Pages |

---

##  Project Structure

```
pactpool-decrypto/
├── index.html    # Full app — Dashboard, Goal Wall, Simulator (all in one file)
└── README.md
```

> This is a single-file app. The Goal Wall and Simulator are built-in tabs inside `index.html` — no separate `dashboard.html` needed.

---

##  Contract Interface

| Function | Description |
|---|---|
| `deposit(lockDays, goal)` | Payable — locks ETH with a public goal string |
| `withdraw()` | Withdraw savings with or without penalty depending on timing |
| `getPoolStats()` | Returns total ETH locked, penalty pool size, and active savers |
| `getSaverInfo(address)` | Returns amount, unlock time, goal, penalty now, progress % |
| `getAllSavers()` | Returns array of all saver addresses for the Goal Wall |

---

##  Security Notes

- Reentrancy protected — Checks-Effects-Interactions pattern; balance zeroed before any transfer
- Basis points math — 10,000 = 100% prevents integer division truncation in penalty calculation
- No admin keys — Fully permissionless; no owner can pause, drain, or change anything
- Overflow-safe — Solidity 0.8.20 built-in overflow protection

---

##  Run Locally

No install, no build step. Just open `index.html` in Chrome with MetaMask on **Sepolia testnet**.

To go live with a real contract:
1. Replace `PASTE_CONTRACT_ADDRESS_HERE` in the `CONTRACT_ADDRESS` constant
2. Replace the empty `ABI` array with the ABI copied from Remix
3. Push to GitHub — GitHub Pages deploys automatically

---

##  One-Line Pitch

> "A savings protocol where breaking your commitment funds someone else's victory."

---

##  Team

| Role | Responsibility |
|------|---------------|
| Vaibhav | Smart Contract — Solidity, Remix, Etherscan verification |
| Sai Samarth | Frontend — Deposit UI, wallet connect, active pact card |
| Yatin arora | Frontend — Goal Wall, Simulator tab, ticker |
| Harsh Vardhan | Integration — ABI wiring, GitHub Pages deployment, demo prep |

---

Built in 2 hours at DECRYPTO Hackathon · Problem Statement 3: DeFi · Sepolia Testnet
