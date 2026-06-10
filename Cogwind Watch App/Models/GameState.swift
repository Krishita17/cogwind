import Foundation

enum GamePhase: Equatable {
    case menu
    case tutorial
    case playing
    case paused
    case solved
    case timeUp
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
            noHintStreak: 0
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
        }
    }
}

final class StatsStore {
    private static let key = "cogwind_stats_v2"

    static func load() -> GameStats {
        guard let data = UserDefaults.standard.data(forKey: key),
              let stats = try? JSONDecoder().decode(GameStats.self, from: data) else {
            return .empty
        }
        return stats
    }

    static func save(_ stats: GameStats) {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
