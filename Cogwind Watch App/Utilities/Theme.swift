import SwiftUI

enum CogwindTheme {
    static let pink = Color(red: 1.0, green: 0.4, blue: 0.6)
    static let purple = Color(red: 0.7, green: 0.3, blue: 1.0)
    static let blue = Color(red: 0.3, green: 0.5, blue: 1.0)
    static let orange = Color(red: 1.0, green: 0.55, blue: 0.2)
    static let hotPink = Color(red: 1.0, green: 0.2, blue: 0.5)
    static let deepPurple = Color(red: 0.45, green: 0.15, blue: 0.8)
    static let softBlue = Color(red: 0.5, green: 0.7, blue: 1.0)
    static let gold = Color(red: 1.0, green: 0.85, blue: 0.3)

    static let ringColors: [Color] = [pink, purple, blue, orange, hotPink, deepPurple, softBlue, gold]

    static var titleGradient: LinearGradient {
        LinearGradient(
            colors: [pink, purple, blue],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [pink, orange],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [purple, blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var solvedGradient: LinearGradient {
        LinearGradient(
            colors: [gold, orange, pink],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func ringColor(for index: Int) -> Color {
        ringColors[index % ringColors.count]
    }

    static func ringGlow(for index: Int) -> Color {
        ringColor(for: index).opacity(0.6)
    }

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.02, blue: 0.1),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
