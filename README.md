# Cogwind — Crown Rotary Puzzle

A mesmerizing Apple Watch puzzle game built entirely around the Digital Crown. Rotate concentric rings to align glyphs, feel every notch through haptic feedback, and progress through 30 handcrafted levels across 6 beautiful worlds.

<p align="center">
  <img src="Screenshots/gameplay-preview.png" alt="Cogwind Gameplay" width="200"/>
</p>

## Features

### Core Gameplay
- **Digital Crown as the controller** — turn the crown to rotate concentric rings, the watch's most unique input becomes the whole game
- **Haptic detent feedback** — feel every notch as you rotate, with distinct haptic patterns for snaps, solves, warnings, and celebrations
- **Align the glyphs** — each ring has a target glyph; rotate all rings until every target sits at the 12 o'clock position
- **Progressive difficulty** — puzzles escalate from 2 rings / 4 segments to 8 rings / 10 segments with tighter time limits

### 30 Levels Across 6 Worlds
| World | Levels | Theme |
|-------|--------|-------|
| Dawn | 1–5 | Gentle introduction, no time pressure on early levels |
| Bloom | 6–10 | Three rings, moderate time limits |
| Storm | 11–15 | Four rings, tighter windows |
| Ember | 16–20 | Five rings, the heat is on |
| Cosmos | 21–25 | Up to six rings with 10 segments each |
| Abyss | 26–30 | Seven to eight rings, ultimate challenge |

Plus **Infinite Mode** — procedurally generated levels that never end, scaling difficulty forever.

### Hint System
- Start with **3 free hints**
- Hints reveal which ring to focus on and which direction to rotate
- **Earn 1 hint per solved puzzle** — solve more, get more
- Hint counter displayed in-game so you always know your reserves

### Scoring & Combos
- **Time bonus** — faster solves earn more points
- **Move efficiency** — fewer rotations = higher score
- **Level multiplier** — harder levels are worth more
- **Streak bonus** — consecutive solves without failing boost your score
- **Per-level high scores** tracked and displayed in Stats

### 18 Achievements
Unlock badges for milestones like:
- First Wind (first solve), Puzzle Master (50 solves)
- Hat Trick / On Fire / Unstoppable (3 / 5 / 10 streaks)
- Flawless (minimum-move solve), Speed Demon (under 5 seconds)
- World completion badges for each of the 6 worlds
- No Help Needed (10 levels without hints), Marathoner (30 min total play)
- Achievement toast notifications pop up in-game when unlocked

### Beautiful Aesthetics
- **Pink, purple, blue, and orange** color palette throughout
- Each ring gets its own color from the palette, creating a vibrant mandala
- Gradient backgrounds with deep purple/black tones
- Glowing effects on aligned glyphs and solved rings
- Gold accents for achievements and hint system
- Smooth spring animations on every rotation
- Confetti particle burst on puzzle completion

### Stats Dashboard
- Highest level, total solves, best streak
- Perfect solves and speed solves counters
- Per-level best times and high scores
- Total play time tracking
- Achievement progress bar

### Interactive Tutorial
- 5-step onboarding that teaches crown control, ring switching, and hints
- Automatically shown on first launch
- Replayable anytime from the menu

### Technical Details
- **Pure SwiftUI** — no UIKit, no storyboards
- **watchOS 10+** native app, no iOS companion required
- **Digital Crown API** with `.digitalCrownRotation` for precise control
- **WKHapticEngine** integration for 7 distinct haptic patterns
- **UserDefaults** persistence for stats, scores, and achievements
- **MVVM architecture** with clean separation of concerns

## Project Structure

```
Cogwind Watch App/
├── CogwindApp.swift              # App entry point
├── Models/
│   ├── Ring.swift                # Ring & Segment data models
│   ├── Level.swift               # 30 levels + infinite generator
│   └── GameState.swift           # Stats, achievements, persistence
├── ViewModels/
│   └── GameViewModel.swift       # Game logic, crown input, scoring
├── Views/
│   ├── ContentView.swift         # Root view with phase routing
│   ├── MenuView.swift            # Main menu with level grid
│   ├── GameView.swift            # Gameplay screen with crown input
│   ├── RingView.swift            # Concentric ring rendering
│   ├── SolvedView.swift          # Victory screen with confetti
│   ├── TimeUpView.swift          # Time-out screen
│   ├── StatsView.swift           # Statistics dashboard
│   ├── TutorialView.swift        # 5-step interactive tutorial
│   └── AchievementsView.swift    # Achievement gallery
├── Haptics/
│   └── HapticEngine.swift        # Haptic feedback patterns
├── Utilities/
│   └── Theme.swift               # Pink/purple/blue/orange palette
└── Assets.xcassets/              # App icon and accent color
```

## Requirements

- watchOS 10.0+
- Xcode 15.0+
- Swift 5.9+
- Apple Watch Series 4 or later (Digital Crown required)

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Krishita17/cogwind.git
   ```

2. Open the project in Xcode:
   ```bash
   cd cogwind
   open Cogwind.xcodeproj
   ```

3. Select the **Cogwind Watch App** scheme and your Apple Watch simulator or device.

4. Build and run (`Cmd + R`).

> **Note:** If running on a physical Apple Watch, set your development team in the project's Signing & Capabilities tab.

## How to Play

1. **Launch** the app on your Apple Watch
2. **Follow the tutorial** on first launch (or tap "How To" anytime)
3. **Turn the Digital Crown** to rotate the currently selected ring
4. **Tap the arrow buttons** to switch between rings
5. **Align all target glyphs** to the top (12 o'clock position) to solve
6. **Use hints wisely** — tap the lightbulb to see which direction to rotate
7. **Beat the clock** on timed levels for bonus points
8. **Unlock achievements** and climb through all 6 worlds!

## License

MIT License — see [LICENSE](LICENSE) for details.
