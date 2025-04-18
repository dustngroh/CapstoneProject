# **Side-Scrolling Speedrun Game**

## **Overview**
This project is a competitive side-scrolling speedrun game inspired by classic runner games. Players navigate obstacles to complete levels as quickly as possible while competing for top spots on a global leaderboard. The game features smooth movement mechanics, challenging obstacles, and online multiplayer functionality.

We aimed to create a fun and accessible game that anyone can play directly in their browser.

▶️ **Play the game:** [https://run-game.xyz](https://run-game.xyz)  

## **Features**
- **Player Movement & Controls**
  - Move left and right using A/D or Left/Right arrow keys.
  - Jump using Spacebar.
  - Acceleration and deceleration mechanics for smooth platforming.

- **Level Progression & Competition**
  - Players race to complete levels in the shortest time possible.
  - Global leaderboard displays fastest times.
  - Encourages replayability and optimization.

- **Game Physics & Obstacles**
  - Precise movement and timing challenges.
  - Obstacles designed to test reflexes and timing.

- **User Accounts & Leaderboards**
  - Account creation and login system.
  - JWT-based authentication with persistent login via local storage.
  - Leaderboard tied to individual level completion times.

- **Multiplayer Mode**
  - Real-time multiplayer supports 20+ concurrent players.
  - Built using WebSocket protocol for full-duplex communication.
  - Server hosted on a Google Cloud Compute Engine VM.

## **System Architecture**
- **Frontend (Godot Web Export):** Handles all game logic, input, UI, and rendering. Deployed to GitHub Pages.
- **Authentication & Leaderboard Backend:** Node.js server hosted on Render, connected to a PostgreSQL database (via Neon).
- **Multiplayer Server:** Node.js WebSocket server hosted on a Google Cloud VM, using a custom domain (`run-game.xyz`).

## **Technology Stack**

### **Languages & Tools**
- **Game Engine:** Godot
- **Frontend Deployment:** GitHub Pages
- **Backend (Auth & Leaderboards):** Node.js + Express
- **Multiplayer Server:** Node.js + WebSocket
- **Database:** PostgreSQL (hosted via Neon)
- **Authentication:** JWT (saved to browser local storage)
- **Cloud Hosting:** Google Cloud Compute Engine (multiplayer), Render (backend)

### **Other Tools**
- **Version Control:** Git + GitHub

## **Contributors**
- **Thi Bui** – Game Designer / Artist  
- **Heidi Ganim** – Game Programmer / Software Developer  
- **Dustin Groh** – Game Programmer / Software Developer  
- **Georgia Wiggins** – Game Designer / Artist
