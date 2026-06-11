import Foundation

enum GamePhase: Equatable {
    case menu
    case tutorial
    case playing
    case paused
    case solved
    case timeUp
    case dailyChallenge
}

enum DifficultyMode: String, Codable, CaseIterable {
    case casual = "Casual"
    case normal = "Normal"
    case expert = "Expert"

    var timeMultiplier: Double {
        switch self {
        case .casual: return 0
        case .normal: return 1.0
        case .expert: return 0.6
        }
    }

    var icon: String {
        switch self {
        case .casual: return "leaf.fill"
        case .normal: return "flame.fill"
        case .expert: return "bolt.fill"
        }
    }

    var scoreMultiplier: Double {
        switch self {
        case .casual: return 0.7
        case .normal: return 1.0
        case .expert: return 1.5
        }
    }
}

struct GameStats: Codable {
    var highestLevel: Int
    var totalSolves: Int
    var bestTimes: [Int: TimeInterval]
    var bestScores: [Int: Int]
    var totalPlayTime: TimeInterval
    var currentStreak: Int
    var bestStreak: Int
    var hintsRemaining: Int
    var totalHintsUsed: Int
    var perfectSolves: Int
    var fastSolves: Int
    var achievements: Set<String>
    var hasSeenTutorial: Bool
    var noHintStreak: Int
    var difficulty: DifficultyMode
    var starRatings: [Int: Int]
    var totalStars: Int
    var dailyChallengesCompleted: Int
    var lastDailyChallengeDate: String?
    var dailyChallengeBestScore: Int
    var totalUndosUsed: Int
    var maxCombo: Int
    var noUndoStreak: Int

    static var empty: GameStats {
        GameStats(
            highestLevel: 0,
            totalSolves: 0,
            bestTimes: [:],
            bestScores: [:],
            totalPlayTime: 0,
            currentStreak: 0,
            bestStreak: 0,
            hintsRemaining: 3,
            totalHintsUsed: 0,
            perfectSolves: 0,
            fastSolves: 0,
            achievements: [],
            hasSeenTutorial: false,
            noHintStreak: 0,
            difficulty: .normal,
            starRatings: [:],
            totalStars: 0,
            dailyChallengesCompleted: 0,
            lastDailyChallengeDate: nil,
            dailyChallengeBestScore: 0,
            totalUndosUsed: 0,
            maxCombo: 0,
            noUndoStreak: 0
        )
    }
}

enum Achievement: String, CaseIterable, Identifiable {
    case firstWind = "first_wind"
    case fiveSolves = "five_solves"
    case tenSolves = "ten_solves"
    case fiftySolves = "fifty_solves"
    case streak3 = "streak_3"
    case streak5 = "streak_5"
    case streak10 = "streak_10"
    case perfectSolve = "perfect_solve"
    case speedDemon = "speed_demon"
    case worldDawn = "world_dawn"
    case worldBloom = "world_bloom"
    case worldStorm = "world_storm"
    case worldEmber = "world_ember"
    case worldCosmos = "world_cosmos"
    case worldAbyss = "world_abyss"
    case hintMaster = "hint_master"
    case noHints = "no_hints"
    case marathoner = "marathoner"
    case starCollector = "star_collector"
    case threeStarPerfect = "three_star_perfect"
    case dailyDevotee = "daily_devotee"
    case comboKing = "combo_king"
    case undoFree = "undo_free"
    case allStars = "all_stars"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstWind: return "First Wind"
        case .fiveSolves: return "Getting Started"
        case .tenSolves: return "Puzzle Adept"
        case .fiftySolves: return "Puzzle Master"
        case .streak3: return "Hat Trick"
        case .streak5: return "On Fire"
        case .streak10: return "Unstoppable"
        case .perfectSolve: return "Flawless"
        case .speedDemon: return "Speed Demon"
        case .worldDawn: return "Dawn Cleared"
        case .worldBloom: return "Bloom Cleared"
        case .worldStorm: return "Storm Cleared"
        case .worldEmber: return "Ember Cleared"
        case .worldCosmos: return "Cosmos Cleared"
        case .worldAbyss: return "Abyss Cleared"
        case .hintMaster: return "Hint Collector"
        case .noHints: return "No Help Needed"
        case .marathoner: return "Marathoner"
        case .starCollector: return "Star Gatherer"
        case .threeStarPerfect: return "Triple Star"
        case .dailyDevotee: return "Daily Devotee"
        case .comboKing: return "Combo King"
        case .undoFree: return "No Regrets"
        case .allStars: return "Stellar Master"
        }
    }

    var icon: String {
        switch self {
        case .firstWind: return "wind"
        case .fiveSolves: return "star.fill"
        case .tenSolves: return "star.circle.fill"
        case .fiftySolves: return "crown.fill"
        case .streak3: return "flame"
        case .streak5: return "flame.fill"
        case .streak10: return "bolt.fill"
        case .perfectSolve: return "sparkles"
        case .speedDemon: return "hare.fill"
        case .worldDawn: return "sunrise.fill"
        case .worldBloom: return "leaf.fill"
        case .worldStorm: return "cloud.bolt.fill"
        case .worldEmber: return "flame.circle.fill"
        case .worldCosmos: return "moon.stars.fill"
        case .worldAbyss: return "water.waves"
        case .hintMaster: return "lightbulb.fill"
        case .noHints: return "brain.head.profile"
        case .marathoner: return "figure.run"
        case .starCollector: return "star.leadinghalf.filled"
        case .threeStarPerfect: return "star.square.on.square.fill"
        case .dailyDevotee: return "calendar.badge.checkmark"
        case .comboKing: return "hurricane"
        case .undoFree: return "hand.thumbsup.fill"
        case .allStars: return "seal.fill"
        }
    }

    var description: String {
        switch self {
        case .firstWind: return "Solve your first puzzle"
        case .fiveSolves: return "Solve 5 puzzles"
        case .tenSolves: return "Solve 10 puzzles"
        case .fiftySolves: return "Solve 50 puzzles"
        case .streak3: return "3 solves in a row"
        case .streak5: return "5 solves in a row"
        case .streak10: return "10 solves in a row"
        case .perfectSolve: return "Solve with minimum moves"
        case .speedDemon: return "Solve in under 5 seconds"
        case .worldDawn: return "Complete all Dawn levels"
        case .worldBloom: return "Complete all Bloom levels"
        case .worldStorm: return "Complete all Storm levels"
        case .worldEmber: return "Complete all Ember levels"
        case .worldCosmos: return "Complete all Cosmos levels"
        case .worldAbyss: return "Complete all Abyss levels"
        case .hintMaster: return "Accumulate 20 hints"
        case .noHints: return "Clear 10 levels without hints"
        case .marathoner: return "Play for 30 minutes total"
        case .starCollector: return "Earn 30 total stars"
        case .threeStarPerfect: return "Get 3 stars on any level"
        case .dailyDevotee: return "Complete 7 daily challenges"
        case .comboKing: return "Reach a 5x combo multiplier"
        case .undoFree: return "Beat 5 levels without undo"
        case .allStars: return "3-star all 30 levels"
        }
    }
}

final class StatsStore {
    private static let key = "cogwind_stats_v3"
    private static let legacyKey = "cogwind_stats_v2"

    static func load() -> GameStats {
        if let data = UserDefaults.standard.data(forKey: key),
           let stats = try? JSONDecoder().decode(GameStats.self, from: data) {
            return stats
        }
        if let data = UserDefaults.standard.data(forKey: legacyKey),
           let old = try? JSONDecoder().decode(LegacyStats.self, from: data) {
            return migrate(old)
        }
        return .empty
    }

    static func save(_ stats: GameStats) {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private struct LegacyStats: Codable {
        var highestLevel: Int
        var totalSolves: Int
        var bestTimes: [Int: TimeInterval]
        var bestScores: [Int: Int]
        var totalPlayTime: TimeInterval
        var currentStreak: Int
        var bestStreak: Int
        var hintsRemaining: Int
        var totalHintsUsed: Int
        var perfectSolves: Int
        var fastSolves: Int
        var achievements: Set<String>
        var hasSeenTutorial: Bool
        var noHintStreak: Int
    }

    private static func migrate(_ old: LegacyStats) -> GameStats {
        var stats = GameStats.empty
        stats.highestLevel = old.highestLevel
        stats.totalSolves = old.totalSolves
        stats.bestTimes = old.bestTimes
        stats.bestScores = old.bestScores
        stats.totalPlayTime = old.totalPlayTime
        stats.currentStreak = old.currentStreak
        stats.bestStreak = old.bestStreak
        stats.hintsRemaining = old.hintsRemaining
        stats.totalHintsUsed = old.totalHintsUsed
        stats.perfectSolves = old.perfectSolves
        stats.fastSolves = old.fastSolves
        stats.achievements = old.achievements
        stats.hasSeenTutorial = old.hasSeenTutorial
        stats.noHintStreak = old.noHintStreak
        return stats
    }
}
