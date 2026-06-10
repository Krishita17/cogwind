import SwiftUI

struct AchievementsView: View {
    let stats: GameStats

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                Text("Achievements")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(CogwindTheme.solvedGradient)

                Text("\(stats.achievements.count) / \(Achievement.allCases.count)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))

                progressBar

                ForEach(Achievement.allCases) { achievement in
                    let isUnlocked = stats.achievements.contains(achievement.rawValue)
                    achievementRow(achievement, unlocked: isUnlocked)
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 16)
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 3)
                    .fill(CogwindTheme.buttonGradient)
                    .frame(
                        width: geo.size.width * CGFloat(stats.achievements.count) / CGFloat(max(1, Achievement.allCases.count)),
                        height: 6
                    )
            }
        }
        .frame(height: 6)
        .padding(.horizontal, 12)
    }

    private func achievementRow(_ achievement: Achievement, unlocked: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.system(size: 14))
                .foregroundStyle(unlocked ? CogwindTheme.gold : .gray.opacity(0.3))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 1) {
                Text(achievement.title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(unlocked ? .white : .white.opacity(0.3))

                Text(achievement.description)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(unlocked ? .white.opacity(0.5) : .white.opacity(0.15))
            }

            Spacer()

            if unlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(CogwindTheme.gold)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(unlocked ? CogwindTheme.gold.opacity(0.06) : Color.white.opacity(0.02))
        )
        .padding(.horizontal, 4)
    }
}
