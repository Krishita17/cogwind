import SwiftUI

struct SolvedView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showConfetti = false
    @State private var starPulse = false

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                confettiOverlay

                ZStack {
                    Circle()
                        .fill(CogwindTheme.gold.opacity(0.15))
                        .frame(width: 44, height: 44)
                        .scaleEffect(starPulse ? 1.3 : 0.8)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: starPulse)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(CogwindTheme.solvedGradient)
                        .scaleEffect(showConfetti ? 1.0 : 0.3)
                        .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showConfetti)
                }

                Text("SOLVED!")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(CogwindTheme.solvedGradient)

                starRatingView

                VStack(spacing: 3) {
                    scoreRow("Score", "\(viewModel.score)", CogwindTheme.gold)
                    scoreRow("Moves", "\(viewModel.moveCount)", CogwindTheme.blue)
                    scoreRow("Time", String(format: "%.1fs", viewModel.elapsedTime), CogwindTheme.purple)
                    if viewModel.stats.currentStreak > 1 {
                        scoreRow("Streak", "\(viewModel.stats.currentStreak)x", CogwindTheme.orange)
                    }
                    if viewModel.comboMultiplier > 1 {
                        scoreRow("Combo", "\(viewModel.comboMultiplier)x", CogwindTheme.hotPink)
                    }
                }

                if viewModel.isDailyChallenge {
                    Text("Daily Best: \(viewModel.stats.dailyChallengeBestScore)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(CogwindTheme.gold.opacity(0.6))
                }

                HStack(spacing: 16) {
                    if !viewModel.isDailyChallenge {
                        Button(action: viewModel.nextLevel) {
                            VStack(spacing: 2) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 18))
                                Text("Next")
                                    .font(.system(size: 8, weight: .medium))
                            }
                            .foregroundStyle(CogwindTheme.pink)
                        }
                        .buttonStyle(.plain)
                    }

                    Button(action: viewModel.retryLevel) {
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16))
                            Text("Retry")
                                .font(.system(size: 8, weight: .medium))
                        }
                        .foregroundStyle(CogwindTheme.blue)
                    }
                    .buttonStyle(.plain)

                    Button(action: viewModel.returnToMenu) {
                        VStack(spacing: 2) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 16))
                            Text("Menu")
                                .font(.system(size: 8, weight: .medium))
                        }
                        .foregroundStyle(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
            .padding(.top, 4)
        }
        .onAppear {
            showConfetti = true
            starPulse = true
        }
    }

    private var starRatingView: some View {
        HStack(spacing: 4) {
            ForEach(1...3, id: \.self) { i in
                Image(systemName: i <= viewModel.starRating ? "star.fill" : "star")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(i <= viewModel.starRating ? CogwindTheme.gold : .gray.opacity(0.3))
                    .scaleEffect(showConfetti && i <= viewModel.starRating ? 1.0 : 0.5)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.5)
                            .delay(Double(i) * 0.2),
                        value: showConfetti
                    )
            }
        }
    }

    private func scoreRow(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 16)
    }

    private var confettiOverlay: some View {
        GeometryReader { geo in
            ForEach(0..<16, id: \.self) { i in
                Circle()
                    .fill([CogwindTheme.pink, CogwindTheme.purple, CogwindTheme.blue, CogwindTheme.orange, CogwindTheme.gold][i % 5])
                    .frame(width: 4, height: 4)
                    .offset(
                        x: showConfetti ? CGFloat.random(in: -geo.size.width/2...geo.size.width/2) : 0,
                        y: showConfetti ? CGFloat.random(in: -geo.size.height/2...geo.size.height/2) : 0
                    )
                    .opacity(showConfetti ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.8).delay(Double(i) * 0.04),
                        value: showConfetti
                    )
            }
        }
        .frame(height: 0)
    }
}
