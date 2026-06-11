import SwiftUI
import Combine

struct UndoState {
    let ringIndex: Int
    let previousOffset: Int
}

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
    @Published var starRating: Int = 0
    @Published var canUndo: Bool = false
    @Published var usedUndoThisLevel: Bool = false
    @Published var proximityValues: [Double] = []
    @Published var comboTimeRemaining: Double = 0
    @Published var isDailyChallenge: Bool = false
    @Published var dailyCompleted: Bool = false

    private var timer: AnyCancellable?
    private var comboTimer: AnyCancellable?
    private var crownAccumulator: Double = 0
    private var lastCrownValue: Double = 0
    private let haptics = HapticEngine.shared
    private let crownStepThreshold: Double = 2.0
    private var undoStack: [UndoState] = []
    private var lastRingSolveTime: Date?
    private var comboCount: Int = 0

    init() {
        self.stats = StatsStore.load()
    }

    // MARK: - Level Management

    func startLevel(_ level: Level) {
        currentLevel = level
        isDailyChallenge = false
        let effectiveLevel = applyDifficulty(level)
        rings = effectiveLevel.generateRings()
        resetPlayState(timeLimit: effectiveLevel.timeLimit)
        phase = .playing
        startTimer()
        haptics.ringSnap()
    }

    func startDailyChallenge() {
        let today = todayString()
        dailyCompleted = stats.lastDailyChallengeDate == today

        let seed = dailySeed()
        let ringCount = 3 + (seed % 3)
        let segments = 4 + ((seed / 7) % 4) * 2
        let glyphIndex = seed % Segment.Glyph.allCases.count
        let glyph = Segment.Glyph.allCases[glyphIndex]

        let level = Level(
            id: 9999,
            ringCount: ringCount,
            segmentsPerRing: segments,
            targetGlyph: glyph,
            timeLimit: 45,
            title: "Daily Challenge",
            world: .cosmos
        )

        currentLevel = level
        isDailyChallenge = true

        var seededRNG = SeededRNG(seed: UInt64(seed))
        rings = (0..<ringCount).map { ringIndex in
            let scramble = 1 + Int(seededRNG.next() % UInt64(segments - 1))
            return Ring.generate(
                id: ringIndex,
                segmentCount: segments,
                targetIndex: 0,
                targetGlyph: glyph,
                scrambleAmount: scramble
            )
        }

        resetPlayState(timeLimit: 45)
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

        resetPlayState(timeLimit: nil)
        isDailyChallenge = false
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
        crownAccumulator += delta

        while crownAccumulator >= crownStepThreshold {
            crownAccumulator -= crownStepThreshold
            pushUndo()
            rings[selectedRingIndex].rotate(by: 1)
            moveCount += 1
            haptics.notch()
        }
        while crownAccumulator <= -crownStepThreshold {
            crownAccumulator += crownStepThreshold
            pushUndo()
            rings[selectedRingIndex].rotate(by: -1)
            moveCount += 1
            haptics.notch()
        }

        updateProximity()
        updateSolvedCount()
        checkRingSolved()
        checkWin()
    }

    // MARK: - Ring Selection

    func selectNextRing() {
        guard !rings.isEmpty else { return }
        selectedRingIndex = (selectedRingIndex + 1) % rings.count
        crownAccumulator = 0
        haptics.selectionTick()
    }

    func selectPreviousRing() {
        guard !rings.isEmpty else { return }
        selectedRingIndex = (selectedRingIndex - 1 + rings.count) % rings.count
        crownAccumulator = 0
        haptics.selectionTick()
    }

    // MARK: - Undo

    func undo() {
        guard let last = undoStack.popLast() else { return }
        rings[last.ringIndex].currentOffset = last.previousOffset
        moveCount = max(0, moveCount - 1)
        usedUndoThisLevel = true
        stats.totalUndosUsed += 1
        canUndo = !undoStack.isEmpty
        updateProximity()
        updateSolvedCount()
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
            haptics.hintPulse()
            StatsStore.save(stats)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.showHint = false
                self?.hintRingIndex = -1
            }
        }
    }

    // MARK: - Difficulty

    func setDifficulty(_ mode: DifficultyMode) {
        stats.difficulty = mode
        StatsStore.save(stats)
    }

    // MARK: - Game Flow

    func pauseGame() {
        phase = .paused
        timer?.cancel()
        comboTimer?.cancel()
    }

    func resumeGame() {
        phase = .playing
        startTimer()
    }

    func returnToMenu() {
        phase = .menu
        timer?.cancel()
        comboTimer?.cancel()
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
        if isDailyChallenge {
            startDailyChallenge()
        } else if let level = currentLevel {
            startLevel(level)
        }
    }

    // MARK: - Private Helpers

    private func resetPlayState(timeLimit: TimeInterval?) {
        selectedRingIndex = 0
        moveCount = 0
        elapsedTime = 0
        remainingTime = timeLimit ?? 0
        score = 0
        comboMultiplier = 1
        comboCount = 0
        crownValue = 0
        lastCrownValue = 0
        showHint = false
        hintRingIndex = -1
        usedHintThisLevel = false
        usedUndoThisLevel = false
        solvedRingsCount = 0
        starRating = 0
        undoStack = []
        canUndo = false
        lastRingSolveTime = nil
        comboTimeRemaining = 0
        updateProximity()
    }

    private func pushUndo() {
        let state = UndoState(
            ringIndex: selectedRingIndex,
            previousOffset: rings[selectedRingIndex].currentOffset
        )
        undoStack.append(state)
        if undoStack.count > 50 { undoStack.removeFirst() }
        canUndo = true
    }

    private func updateProximity() {
        proximityValues = rings.map { ring in
            let steps = ring.hintStepsRemaining
            let total = ring.segmentCount
            if total == 0 { return 1.0 }
            return 1.0 - (Double(steps) / Double(total / 2))
        }
    }

    private func checkRingSolved() {
        let justSolved = rings.enumerated().first { _, ring in
            ring.isSolved
        }

        if justSolved != nil {
            let now = Date()
            if let lastTime = lastRingSolveTime, now.timeIntervalSince(lastTime) < 3.0 {
                comboCount += 1
                comboMultiplier = min(comboCount + 1, 8)
                stats.maxCombo = max(stats.maxCombo, comboMultiplier)
                startComboTimer()
            } else {
                comboCount = 0
                comboMultiplier = 1
            }
            lastRingSolveTime = now
        }
    }

    private func startComboTimer() {
        comboTimer?.cancel()
        comboTimeRemaining = 3.0

        comboTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.comboTimeRemaining -= 0.1
                if self.comboTimeRemaining <= 0 {
                    self.comboTimer?.cancel()
                    self.comboTimeRemaining = 0
                    self.comboCount = 0
                    self.comboMultiplier = 1
                }
            }
    }

    private func updateSolvedCount() {
        solvedRingsCount = rings.filter(\.isSolved).count
    }

    private func checkWin() {
        guard rings.allSatisfy(\.isSolved) else { return }
        solvePuzzle()
    }

    private func applyDifficulty(_ level: Level) -> Level {
        let mult = stats.difficulty.timeMultiplier
        if mult == 0 {
            return Level(
                id: level.id, ringCount: level.ringCount,
                segmentsPerRing: level.segmentsPerRing,
                targetGlyph: level.targetGlyph,
                timeLimit: nil,
                title: level.title, world: level.world
            )
        }
        guard let original = level.timeLimit else { return level }
        return Level(
            id: level.id, ringCount: level.ringCount,
            segmentsPerRing: level.segmentsPerRing,
            targetGlyph: level.targetGlyph,
            timeLimit: original * mult,
            title: level.title, world: level.world
        )
    }

    private func calculateStars() -> Int {
        guard let level = currentLevel else { return 1 }
        var stars = 1

        let minMoves = rings.count
        if moveCount <= minMoves * 2 { stars = 3 }
        else if moveCount <= minMoves * 4 { stars = 2 }

        if let limit = level.timeLimit, elapsedTime < limit * 0.4 {
            stars = max(stars, 3)
        } else if let limit = level.timeLimit, elapsedTime < limit * 0.7 {
            stars = max(stars, 2)
        }

        if usedHintThisLevel { stars = min(stars, 2) }

        return stars
    }

    private func solvePuzzle() {
        timer?.cancel()
        comboTimer?.cancel()
        phase = .solved

        starRating = calculateStars()

        let diffMult = stats.difficulty.scoreMultiplier
        let timeBonus = currentLevel?.timeLimit != nil ? Int(max(0, remainingTime) * 15) : 50
        let totalSegments = rings.reduce(0) { $0 + $1.segmentCount }
        let minMoves = totalSegments > 0 ? rings.count : 1
        let moveEfficiency = max(1, 150 - max(0, moveCount - minMoves) * 5)
        let levelBonus = (currentLevel?.id ?? 1) * 100
        let streakBonus = stats.currentStreak * 25

        score = Int(Double(timeBonus + moveEfficiency + levelBonus + streakBonus) * Double(max(1, comboMultiplier)) * diffMult)

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

            if !usedUndoThisLevel {
                stats.noUndoStreak += 1
            } else {
                stats.noUndoStreak = 0
            }

            if level.id <= 30 {
                let prev = stats.starRatings[level.id] ?? 0
                stats.starRatings[level.id] = max(prev, starRating)
                stats.totalStars = stats.starRatings.values.reduce(0, +)
            }

            stats.hintsRemaining += 1
        }

        if isDailyChallenge {
            stats.dailyChallengesCompleted += 1
            stats.lastDailyChallengeDate = todayString()
            stats.dailyChallengeBestScore = max(stats.dailyChallengeBestScore, score)
            dailyCompleted = true
        }

        stats.totalPlayTime += elapsedTime
        StatsStore.save(stats)

        checkAchievements()
        haptics.solvedCelebration()
    }

    private func checkAchievements() {
        var newlyEarned: Achievement?

        let allThreeStarred = (1...30).allSatisfy { (stats.starRatings[$0] ?? 0) >= 3 }

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
            (.starCollector, stats.totalStars >= 30),
            (.threeStarPerfect, stats.starRatings.values.contains(3)),
            (.dailyDevotee, stats.dailyChallengesCompleted >= 7),
            (.comboKing, stats.maxCombo >= 5),
            (.undoFree, stats.noUndoStreak >= 5),
            (.allStars, allThreeStarred),
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
                        self.comboTimer?.cancel()
                        self.phase = .timeUp
                        self.stats.currentStreak = 0
                        StatsStore.save(self.stats)
                        self.haptics.failure()
                    }
                }
            }
    }

    // MARK: - Daily Challenge Helpers

    private func todayString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Date())
    }

    private func dailySeed() -> Int {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let str = df.string(from: Date())
        return (Int(str) ?? 20260610) ^ 0xC06E1D
    }
}

struct SeededRNG {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
