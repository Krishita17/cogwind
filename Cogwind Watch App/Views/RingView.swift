import SwiftUI

struct RingView: View {
    let ring: Ring
    let ringIndex: Int
    let totalRings: Int
    let isSelected: Bool
    let targetGlyph: Segment.Glyph
    let showHint: Bool
    let hintDirection: Int

    private var radius: CGFloat {
        let maxRadius: CGFloat = 72
        let minRadius: CGFloat = 18
        let spacing = totalRings > 1 ? (maxRadius - minRadius) / CGFloat(totalRings - 1) : 0
        return minRadius + CGFloat(ringIndex) * spacing
    }

    private var segmentAngle: Double {
        360.0 / Double(ring.segmentCount)
    }

    private var ringColor: Color {
        CogwindTheme.ringColor(for: ringIndex)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    isSelected ? ringColor : ringColor.opacity(0.2),
                    lineWidth: isSelected ? 2.5 : 1
                )
                .frame(width: radius * 2, height: radius * 2)

            if isSelected {
                Circle()
                    .stroke(ringColor.opacity(0.3), lineWidth: 5)
                    .frame(width: radius * 2, height: radius * 2)
                    .blur(radius: 3)
            }

            if ring.isSolved {
                Circle()
                    .stroke(CogwindTheme.gold.opacity(0.4), lineWidth: 2)
                    .frame(width: radius * 2, height: radius * 2)
            }

            ForEach(Array(ring.displaySegments.enumerated()), id: \.offset) { index, segment in
                SegmentView(
                    segment: segment,
                    angle: Double(index) * segmentAngle,
                    radius: radius,
                    isTarget: segment.isTarget,
                    isAligned: segment.isTarget && index == 0,
                    showHint: showHint && segment.isTarget,
                    segmentSize: segmentSize,
                    ringColor: ringColor
                )
            }

            if showHint && hintDirection != 0 {
                Image(systemName: hintDirection > 0 ? "arrow.clockwise" : "arrow.counterclockwise")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(CogwindTheme.gold)
                    .offset(y: -radius - 10)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: ring.currentOffset)
    }

    private var segmentSize: CGFloat {
        let base = max(8, min(14, 50 / CGFloat(ring.segmentCount) * 4))
        return totalRings > 5 ? base * 0.85 : base
    }
}

struct SegmentView: View {
    let segment: Segment
    let angle: Double
    let radius: CGFloat
    let isTarget: Bool
    let isAligned: Bool
    let showHint: Bool
    let segmentSize: CGFloat
    let ringColor: Color

    var body: some View {
        Image(systemName: segment.glyph.rawValue)
            .font(.system(size: segmentSize, weight: .bold))
            .foregroundStyle(segmentColor)
            .shadow(color: glowColor, radius: isAligned ? 5 : (isTarget ? 3 : 0))
            .offset(
                x: radius * cos(CGFloat(angle - 90) * .pi / 180),
                y: radius * sin(CGFloat(angle - 90) * .pi / 180)
            )
            .scaleEffect(showHint ? 1.4 : (isAligned ? 1.15 : 1.0))
            .animation(showHint ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: showHint)
    }

    private var segmentColor: Color {
        if showHint { return CogwindTheme.gold }
        if isAligned { return CogwindTheme.gold }
        if isTarget { return CogwindTheme.orange }
        return ringColor.opacity(0.4)
    }

    private var glowColor: Color {
        if isAligned { return CogwindTheme.gold.opacity(0.8) }
        if isTarget { return CogwindTheme.orange.opacity(0.5) }
        return .clear
    }
}
