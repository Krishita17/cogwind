import SwiftUI
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published var rings: [Ring] = []
    @Published var selectedRingIndex: Int = 0
    @Published var phase: GamePhase = .menu
    @Published var currentLevel: Level?
    @Published var elapsedTime: TimeInterval = 0
    @Published var remainingTime: TimeInterval = 0
    @Published var moveCount: Int = 0
    @Published var stats: GameStats
    @Published var showHint: Bool = false
    @Published var hintRingIndex: Int = -1
    @Published var comboMultiplier: Int = 1
    @Published var score: Int = 0
    @Published var crownValue: Double = 0
    @Published var newAchievement: Achievement?
    @Published var usedHintThisLevel: Bool = false
    @Published var solvedRingsCount: Int = 0
    @Published var tutorialStep: Int = 0

    private var timer: AnyCancellable?
    private var lastCrownValue: Double = 0
    private let haptics = HapticEngine.shared
    private let notchSize: Double = 1.0

    init() {
        self.stats = StatsStore.load()
    }

    // MARK: - Level Management

    func startLevel(_ level: Level) {
        currentLevel = level
        rings = level.generateRings()
        selectedRingIndex = 0
        moveCount = 0
        elapsedTime = 0
        remainingTime = level.timeLimit ?? 0
        score = 0
        comboMultiplier = 1
        crownValue = 0
        lastCrownValue = 0
        showHint = false
        hintRingIndex = -1
        usedHintThisLevel = false
        solvedRingsCount = 0
        phase = .playing
        startTimer()
        haptics.ringSnap()
    }

    func startTutorial() {
        tutorialStep = 0
        let tutorialLevel = Level(
            id: 0,
            ringCount: 2,
            segmentsPerRing: 4,
            targetGlyph: .circle,
            timeLimit: nil,
            title: "Tutorial",
            world: .dawn
        )
        currentLevel = tutorialLevel

        var tutorialRings = tutorialLevel.generateRings()
        tutorialRings[0] = Ring.generate(id: 0, segmentCount: 4, targetIndex: 0, targetGlyph: .circle, scrambleAmount: 1)
        tutorialRings[1] = Ring.generate(id: 1, segmentCount: 4, targetIndex: 0, targetGlyph: .circle, scrambleAmount: 2)
        rings = tutorialRings

        selectedRingIndex = 0
        moveCount = 0
        elapsedTime = 0
        score = 0
        crownValue = 0
        lastCrownValue = 0
        showHint = false
        usedHintThisLevel = false
        solvedRingsCount = 0
        phase = .tutorial
    }

    func advanceTutorial() {
        tutorialStep += 1
        if tutorialStep >= 5 {
            stats.hasSeenTutorial = true
            StatsStore.save(stats)
            phase = .menu
        }
    }

    // MARK: - Crown Input

    func handleCrownChange(_ newValue: Double) {
        guard phase == .playing || phase == .tutorial else { return }
        guard !rings.isEmpty else { return }

        let delta = newValue - lastCrownValue
        lastCrownValue = newValue

        if delta > 0.3 {
            rings[selectedRingIndex].rotate(by: 1)
            moveCount += 1
            haptics.notch()
            updateSolvedCount()
            checkWin()
        } else if delta < -0.3 {
            rings[selectedRingIndex].rotate(by: -1)
            moveCount += 1
            haptics.notch()
            updateSolvedCount()
            checkWin()
        }
    }

    // MARK: - Ring Selection

    func selectNextRing() {
        guard !rings.isEmpty else { return }
        selectedRingIndex = (selectedRingIndex + 1) % rings.count
        haptics.selectionTick()
    }

    func selectPreviousRing() {
        guard !rings.isEmpty else { return }
        selectedRingIndex = (selectedRingIndex - 1 + rings.count) % rings.count
        haptics.selectionTick()
    }

    // MARK: - Hints

    func useHint() {
        guard stats.hintsRemaining > 0 else { return }
        guard phase == .playing || phase == .tutorial else { return }

        if let unsolved = rings.firstIndex(where: { !$0.isSolved }) {
            stats.hintsRemaining -= 1
            stats.totalHintsUsed += 1
            usedHintThisLevel = true
            hintRingIndex = unsolved
            selectedRingIndex = unsolved
            showHint = true
            haptics.selectionTick()
            StatsStore.save(stats)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.showHint = false
                self?.hintRingIndex = -1
            }
        }
    }

    // MARK: - Game Flow

    func pauseGame() {
        phase = .paused
        timer?.cancel()
    }

    func resumeGame() {
        phase = .playing
        startTimer()
    }

    func returnToMenu() {
        phase = .menu
        timer?.cancel()
        rings = []
    }

    func nextLevel() {
        guard let level = currentLevel else { return }
        let nextId = level.id + 1
        if nextId <= LevelGenerator.levels.count {
            startLevel(LevelGenerator.levels[nextId - 1])
        } else {
            startLevel(LevelGenerator.infiniteLevel(number: nextId))
        }
    }

    func retryLevel() {
        guard let level = currentLevel else { return }
        startLevel(level)
    }

    // MARK: - Private

    private func updateSolvedCount() {
        solvedRingsCount = rings.filter(\.isSolved).count
    }

    private func checkWin() {
        guard rings.allSatisfy(\.isSolved) else { return }
        solvePuzzle()
    }

    private func solvePuzzle() {
        timer?.cancel()
        phase = .solved

        let timeBonus = currentLevel?.timeLimit != nil ? Int(max(0, remainingTime) * 15) : 50
        let totalSegments = rings.reduce(0) { $0 + $1.segmentCount }
        let minMoves = totalSegments > 0 ? rings.count : 1
        let moveEfficiency = max(1, 150 - max(0, moveCount - minMoves) * 5)
        let levelBonus = (currentLevel?.id ?? 1) * 100
        let streakBonus = stats.currentStreak * 25

        score = (timeBonus + moveEfficiency + levelBonus + streakBonus) * max(1, comboMultiplier)

        if let level = currentLevel {
            stats.totalSolves += 1
            stats.highestLevel = max(stats.highestLevel, level.id)
            stats.currentStreak += 1
            stats.bestStreak = max(stats.bestStreak, stats.currentStreak)

            if let existing = stats.bestTimes[level.id] {
                stats.bestTimes[level.id] = min(existing, elapsedTime)
            } else {
                stats.bestTimes[level.id] = elapsedTime
            }

            if let existing = stats.bestScores[level.id] {
                stats.bestScores[level.id] = max(existing, score)
            } else {
                stats.bestScores[level.id] = score
            }

            if moveCount <= rings.count * 2 {
                stats.perfectSolves += 1
            }

            if elapsedTime < 5.0 {
                stats.fastSolves += 1
            }

            if !usedHintThisLevel {
                stats.noHintStreak += 1
            } else {
                stats.noHintStreak = 0
            }

            stats.hintsRemaining += 1
        }

        stats.totalPlayTime += elapsedTime
        StatsStore.save(stats)

        checkAchievements()
        haptics.solvedCelebration()
    }

    private func checkAchievements() {
        var newlyEarned: Achievement?

        let checks: [(Achievement, Bool)] = [
            (.firstWind, stats.totalSolves >= 1),
            (.fiveSolves, stats.totalSolves >= 5),
            (.tenSolves, stats.totalSolves >= 10),
            (.fiftySolves, stats.totalSolves >= 50),
            (.streak3, stats.currentStreak >= 3),
            (.streak5, stats.currentStreak >= 5),
            (.streak10, stats.currentStreak >= 10),
            (.perfectSolve, stats.perfectSolves >= 1),
            (.speedDemon, stats.fastSolves >= 1),
            (.worldDawn, stats.highestLevel >= 5),
            (.worldBloom, stats.highestLevel >= 10),
            (.worldStorm, stats.highestLevel >= 15),
            (.worldEmber, stats.highestLevel >= 20),
            (.worldCosmos, stats.highestLevel >= 25),
            (.worldAbyss, stats.highestLevel >= 30),
            (.hintMaster, stats.hintsRemaining >= 20),
            (.noHints, stats.noHintStreak >= 10),
            (.marathoner, stats.totalPlayTime >= 1800),
        ]

        for (achievement, condition) in checks {
            if condition && !stats.achievements.contains(achievement.rawValue) {
                stats.achievements.insert(achievement.rawValue)
                newlyEarned = achievement
            }
        }

        if let earned = newlyEarned {
            StatsStore.save(stats)
            newAchievement = earned
            haptics.levelUp()
        }
    }

    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.phase == .playing else { return }
                self.elapsedTime += 0.1

                if let limit = self.currentLevel?.timeLimit {
                    self.remainingTime = max(0, limit - self.elapsedTime)

                    if self.remainingTime <= 5 && self.remainingTime > 4.9 {
                        self.haptics.timeWarning()
                    }

                    if self.remainingTime <= 0 {
                        self.timer?.cancel()
                        self.phase = .timeUp
                        self.stats.currentStreak = 0
                        StatsStore.save(self.stats)
                        self.haptics.failure()
                    }
                }
            }
    }
}
