import SwiftUI

struct TutorialView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            CogwindTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 8) {
                switch viewModel.tutorialStep {
                case 0:
                    tutorialCard(
                        icon: "gearshape.2.fill",
                        title: "Welcome!",
                        text: "Align the target glyphs to the top of each ring.",
                        color: CogwindTheme.pink
                    )
                case 1:
                    tutorialCard(
                        icon: "digitalcrown.horizontal.arrow.clockwise.fill",
                        title: "Crown Control",
                        text: "Turn the Digital Crown to rotate the selected ring.",
                        color: CogwindTheme.purple
                    )
                case 2:
                    tutorialCard(
                        icon: "chevron.left.chevron.right",
                        title: "Switch Rings",
                        text: "Tap the arrows to select different rings.",
                        color: CogwindTheme.blue
                    )
                case 3:
                    tutorialCard(
                        icon: "lightbulb.fill",
                        title: "Need a Hint?",
                        text: "Tap the bulb to reveal which way to turn. You start with 3 hints and earn more by solving!",
                        color: CogwindTheme.gold
                    )
                default:
                    tutorialCard(
                        icon: "star.fill",
                        title: "You're Ready!",
                        text: "Solve puzzles, earn achievements, and climb through 30 levels across 6 worlds!",
                        color: CogwindTheme.orange
                    )
                }

                Button(action: viewModel.advanceTutorial) {
                    HStack {
                        Text(viewModel.tutorialStep >= 4 ? "Let's Go!" : "Next")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(CogwindTheme.buttonGradient)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .fill(i == viewModel.tutorialStep ? CogwindTheme.pink : Color.white.opacity(0.2))
                            .frame(width: 5, height: 5)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func tutorialCard(icon: String, title: String, text: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(colors: [color, color.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                )

            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(text)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }
}
