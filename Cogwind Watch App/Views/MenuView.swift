import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var animateTitle = false

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                titleSection
                playButton
                levelGrid
                bottomButtons
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }

    private var titleSection: some View {
        VStack(spacing: 2) {
            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(
                        colors: [CogwindTheme.pink, CogwindTheme.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(.degrees(animateTitle ? 360 : 0))
                .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: animateTitle)
                .onAppear { animateTitle = true }

            Text("COGWIND")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(CogwindTheme.titleGradient)

            Text("Crown Rotary Puzzle")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var playButton: some View {
        Button(action: {
            if !viewModel.stats.hasSeenTutorial {
                viewModel.startTutorial()
                return
            }
            let nextLevel = viewModel.stats.highestLevel + 1
            if nextLevel <= LevelGenerator.levels.count {
                viewModel.startLevel(LevelGenerator.levels[nextLevel - 1])
            } else {
                viewModel.startLevel(LevelGenerator.infiniteLevel(number: nextLevel))
            }
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text(viewModel.stats.highestLevel == 0 ? "Play" : "Continue")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(CogwindTheme.buttonGradient)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }

    private var levelGrid: some View {
        VStack(spacing: 6) {
            ForEach(Level.World.allCases, id: \.rawValue) { world in
                let worldLevels = LevelGenerator.levels.filter { $0.world == world }
                if !worldLevels.isEmpty {
                    VStack(spacing: 3) {
                        Text(world.rawValue)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(worldColor(world).opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 6)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 5), spacing: 4) {
                            ForEach(worldLevels) { level in
                                LevelButton(
                                    level: level,
                                    isUnlocked: level.id <= viewModel.stats.highestLevel + 1,
                                    isCompleted: level.id <= viewModel.stats.highestLevel,
                                    color: worldColor(world)
                                ) {
                                    viewModel.startLevel(level)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private var bottomButtons: some View {
        HStack(spacing: 16) {
            NavigationLink(destination: StatsView(stats: viewModel.stats)) {
                VStack(spacing: 2) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 14))
                    Text("Stats")
                        .font(.system(size: 8))
                }
                .foregroundStyle(CogwindTheme.blue)
            }

            NavigationLink(destination: AchievementsView(stats: viewModel.stats)) {
                VStack(spacing: 2) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 14))
                    Text("Awards")
                        .font(.system(size: 8))
                }
                .foregroundStyle(CogwindTheme.gold)
            }

            Button(action: { viewModel.startTutorial() }) {
                VStack(spacing: 2) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 14))
                    Text("How To")
                        .font(.system(size: 8))
                }
                .foregroundStyle(CogwindTheme.purple)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }

    private func worldColor(_ world: Level.World) -> Color {
        switch world {
        case .dawn: return CogwindTheme.pink
        case .bloom: return CogwindTheme.purple
        case .storm: return CogwindTheme.blue
        case .ember: return CogwindTheme.orange
        case .cosmos: return CogwindTheme.deepPurple
        case .abyss: return CogwindTheme.hotPink
        }
    }
}

struct LevelButton: View {
    let level: Level
    let isUnlocked: Bool
    let isCompleted: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: { if isUnlocked { action() } }) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isCompleted ? color.opacity(0.3) : (isUnlocked ? color.opacity(0.15) : Color.gray.opacity(0.08)))
                    .frame(height: 26)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isCompleted ? color.opacity(0.6) : Color.clear, lineWidth: 1)
                    )

                if isUnlocked {
                    Text("\(level.id)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(isCompleted ? color : color.opacity(0.7))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 7))
                        .foregroundStyle(.gray.opacity(0.4))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
