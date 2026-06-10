import SwiftUI

struct TimeUpView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var shake = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.badge.xmark.fill")
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(colors: [.red, CogwindTheme.orange], startPoint: .top, endPoint: .bottom)
                )
                .rotationEffect(.degrees(shake ? -5 : 5))
                .animation(.easeInOut(duration: 0.15).repeatCount(5, autoreverses: true), value: shake)

            Text("TIME'S UP")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.red)

            if let level = viewModel.currentLevel {
                Text(level.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text("\(viewModel.solvedRingsCount)/\(viewModel.rings.count) rings aligned")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(CogwindTheme.orange.opacity(0.7))

            HStack(spacing: 16) {
                Button(action: viewModel.retryLevel) {
                    VStack(spacing: 2) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18))
                        Text("Retry")
                            .font(.system(size: 9, weight: .medium))
                    }
                    .foregroundStyle(CogwindTheme.orange)
                }
                .buttonStyle(.plain)

                Button(action: viewModel.returnToMenu) {
                    VStack(spacing: 2) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18))
                        Text("Menu")
                            .font(.system(size: 9, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .onAppear { shake = true }
    }
}
