import SwiftUI

struct StatsView: View {
    let stats: GameStats

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Statistics")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(CogwindTheme.titleGradient)

                statCard("Highest Level", "\(stats.highestLevel)", CogwindTheme.pink)
                statCard("Total Solves", "\(stats.totalSolves)", CogwindTheme.purple)
                statCard("Best Streak", "\(stats.bestStreak)", CogwindTheme.orange)
                statCard("Perfect Solves", "\(stats.perfectSolves)", CogwindTheme.gold)
                statCard("Speed Solves", "\(stats.fastSolves)", CogwindTheme.blue)
                statCard("Hints Left", "\(stats.hintsRemaining)", CogwindTheme.gold)
                statCard("Total Play", formatTime(stats.totalPlayTime), CogwindTheme.softBlue)
                statCard("Achievements", "\(stats.achievements.count)/\(Achievement.allCases.count)", CogwindTheme.gold)

                if !stats.bestScores.isEmpty {
                    Divider().background(Color.white.opacity(0.1))

                    Text("High Scores")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(CogwindTheme.orange)

                    ForEach(stats.bestScores.sorted(by: { $0.key < $1.key }).prefix(10), id: \.key) { level, score in
                        HStack {
                            Text("Level \(level)")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.5))
                            Spacer()
                            if let time = stats.bestTimes[level] {
                                Text(String(format: "%.1fs", time))
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(CogwindTheme.blue)
                            }
                            Text("\(score)pts")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(CogwindTheme.gold)
                        }
                        .padding(.horizontal, 10)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }

    private func statCard(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.06))
        )
        .padding(.horizontal, 6)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return "\(m)m \(s)s"
    }
}
