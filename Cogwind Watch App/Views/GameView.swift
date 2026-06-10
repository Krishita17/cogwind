import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            CogwindTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 2) {
                headerBar
                puzzleArea
                bottomBar
            }
            .padding(.horizontal, 2)

            if viewModel.phase == .paused {
                pauseOverlay
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var headerBar: some View {
        HStack {
            if let level = viewModel.currentLevel {
                Text("L\(level.id)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(CogwindTheme.pink)

                Spacer()

                if level.timeLimit != nil {
                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.system(size: 8))
                        Text(timeString)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                    }
                    .foregroundStyle(timerColor)
                }

                Spacer()

                HStack(spacing: 2) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 8))
                    Text("\(viewModel.moveCount)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                }
                .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 2)
    }

    private var puzzleArea: some View {
        ZStack {
            // Solved ring count indicator
            if viewModel.rings.count > 1 {
                VStack {
                    Spacer()
                    HStack(spacing: 3) {
                        ForEach(0..<viewModel.rings.count, id: \.self) { i in
                            Circle()
                                .fill(viewModel.rings[i].isSolved ? CogwindTheme.pink : Color.white.opacity(0.15))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }

            ForEach(Array(viewModel.rings.enumerated()), id: \.element.id) { index, ring in
                RingView(
                    ring: ring,
                    ringIndex: index,
                    totalRings: viewModel.rings.count,
                    isSelected: index == viewModel.selectedRingIndex,
                    targetGlyph: viewModel.currentLevel?.targetGlyph ?? .circle,
                    showHint: viewModel.showHint && viewModel.hintRingIndex == index,
                    hintDirection: ring.hintDirection
                )
            }

            centerIndicator
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .focusable()
        .digitalCrownRotation($viewModel.crownValue, from: -10000, through: 10000, sensitivity: .low, isContinuous: true, isHapticFeedbackEnabled: false)
        .onChange(of: viewModel.crownValue) { _, newValue in
            viewModel.handleCrownChange(newValue)
        }
    }

    private var centerIndicator: some View {
        Group {
            if let level = viewModel.currentLevel {
                VStack(spacing: 1) {
                    Image(systemName: level.targetGlyph.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(CogwindTheme.purple.opacity(0.5))

                    Image(systemName: "arrow.up")
                        .font(.system(size: 6, weight: .bold))
                        .foregroundStyle(CogwindTheme.pink.opacity(0.3))
                }
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 8) {
            Button(action: viewModel.selectPreviousRing) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(CogwindTheme.purple)
            }
            .buttonStyle(.plain)

            Button(action: viewModel.useHint) {
                HStack(spacing: 2) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                    Text("\(viewModel.stats.hintsRemaining)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                }
                .foregroundStyle(viewModel.stats.hintsRemaining > 0 ? CogwindTheme.gold : .gray.opacity(0.4))
            }
            .buttonStyle(.plain)

            Button(action: viewModel.pauseGame) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .buttonStyle(.plain)

            Button(action: viewModel.selectNextRing) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(CogwindTheme.purple)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 2)
    }

    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()

            VStack(spacing: 12) {
                Text("PAUSED")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(CogwindTheme.purple)

                Button(action: viewModel.resumeGame) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Resume")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(CogwindTheme.buttonGradient)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button(action: viewModel.returnToMenu) {
                    Text("Quit")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var timeString: String {
        let t = Int(viewModel.remainingTime)
        return String(format: "%d:%02d", t / 60, t % 60)
    }

    private var timerColor: Color {
        if viewModel.remainingTime <= 5 { return .red }
        if viewModel.remainingTime <= 15 { return CogwindTheme.orange }
        return .white.opacity(0.6)
    }
}
