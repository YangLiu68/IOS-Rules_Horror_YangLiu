
# 📱 Rules Horror — A rule-based interactive chatting horror novel

# CSC780 Final Project - Yang Liu 924438213

> **Rules Horror** is an interactive visual novel built with SwiftUI and Firebase. The player progresses through the story one line at a time in a **chat-style interface**, making choices that influence the timeline and ending. Along the way, they can **collect items**, **unlock hidden content**, and experience an **immersive narrative adventure**.

---

## 🎮 Key Features

- Built a complete visual novel engine
  - Automatically parses visual novel format files
  - **Automatically generates** timeline structure based on connections between different chapters
  - Automatically saves and restores progress
  - Multimedia support, including image/audio messages, background images/audio, and sound effects
  - Achievement mechanism that can be triggered by commands
- 🧾 Progress cached locally and in the cloud simultaneously, never lost
  - Progress saved synchronously locally and in the cloud (Firebase)
  - Automatic anonymous registration and progress synchronization with the cloud
- 🌐 Supports switching between Chinese and English
- 🗑️ One-click cleaning of cloud and local cached data to protect privacy

# 🧱 Tech Stack

- **Language/Framework**: SwiftUI, Combine

- **Visual Novel Format**: Multi-timeline multimedia single-file novel format based on JSON and Base64

- **Timeline Preview Generation Algorithm**: Based on BFS (Breadth-First Search), automatically generates tree-like preview diagrams according to timeline selection/jumps, rendered by canvas and interactive

- Backend Services

  : Firebase

  - `FirebaseAuth`: User login and authentication
  - `FirebaseFirestore`: Saves message records, items, and timeline progress
  - `FirebaseAppCheck`: Prevents request abuse

- **Localization Support**: Chinese-English bilingual switching

- **Audio Management**: Three-track audio manager, background music/sound effects/voice messages running simultaneously without conflicts/one-click mute

## Project Technical Challenges & Innovations

- **Custom Engine Development**: Built a complete visual novel engine from scratch rather than using existing frameworks, demonstrating strong system design capabilities
- **Complex Data Flow Management**: Utilized the Combine framework to implement reactive programming patterns, handling multiple asynchronous event streams and state management to ensure synchronized UI and data updates
- **Multi-threading & Performance Optimization**: Implemented efficient background processing mechanisms that maintain fluid UI responsiveness even when loading large multimedia files
- **Innovative Timeline Algorithm**: Designed an algorithm based on BFS (Breadth-First Search) that automatically generates interactive decision tree views, solving the visualization challenge of multi-branch narrative structures
- **Hybrid Storage Strategy**: Implemented dual caching mechanisms between local storage and Firebase cloud, addressing complex data persistence and synchronization challenges
- **Seamless Multimedia Management**: Designed a three-track parallel audio system enabling synchronized playback of background music, sound effects, and voice messages without conflicts, achieving professional-grade multimedia experience
- **Memory & Resource Management**: Implemented intelligent preloading and release mechanisms for multimedia resources, avoiding common issues of excessive memory usage
- **Security Architecture Design**: Integrated Firebase AppCheck to prevent API abuse and implemented anonymous authentication to protect user privacy, demonstrating professional consideration for application security

## Preview

![Preview Video](preview/preview.mp4)

## 🛠️ Installation

**1. Clone the Project:**

```
git clone https://github.com/YangLiu68/CSC780Rules_Horror.git
```

**2. Configure Firebase:**

- Open Firebase Console
- Create a project named `Rules Horror`
- Enable the following services:
  - Firestore
  - Firebase Authentication
  - App Check (optional)
- Download `GoogleService-Info.plist` and place it in your Xcode project

**3. Install Dependencies (if using CocoaPods):**

```
pod install
```

**4. Run the Project:**

- Open the `.xcworkspace` file with Xcode
- Select a simulator or physical device and click run (`Cmd + R`)

---

## ✨ Usage

- Click on the [Chat Interface] to start the game, advance the story line by line, and make choices
- Each choice will affect your timeline path and ending
- Items will be automatically collected and progress saved during your choices
- [Timeline Interface] allows you to view unlocked branches
- [Item Collection Interface] displays collected props/items
- [Settings Interface] allows you to:
  - Toggle background music
  - Clear progress/item records

## 🧪 TODO / Features In Development

- Add character affinity system
- Optimize JSON loading performance
- Publish to App Store and deploy official version
- Add more side quests and endings



