import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                CogwindTheme.backgroundGradient.ignoresSafeArea()

                switch viewModel.phase {
                case .menu:
                    MenuView(viewModel: viewModel)
                case .tutorial:
                    TutorialView(viewModel: viewModel)
                case .playing, .paused, .dailyChallenge:
                    GameView(viewModel: viewModel)
                case .solved:
                    SolvedView(viewModel: viewModel)
                case .timeUp:
                    TimeUpView(viewModel: viewModel)
                }

                if let achievement = viewModel.newAchievement {
                    AchievementToast(achievement: achievement) {
                        viewModel.newAchievement = nil
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.phase)
    }
}

struct AchievementToast: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    @State private var visible = true

    var body: some View {
        if visible {
            VStack(spacing: 4) {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: achievement.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(CogwindTheme.gold)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Unlocked!")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(CogwindTheme.gold)
                        Text(achievement.title)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.85))
                        .overlay(Capsule().stroke(CogwindTheme.gold.opacity(0.5), lineWidth: 1))
                )
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { visible = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDismiss() }
                }
            }
        }
    }
}
