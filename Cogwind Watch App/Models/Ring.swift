import Foundation

struct Segment: Identifiable, Equatable {
    let id: Int
    var glyph: Glyph
    var isTarget: Bool

    enum Glyph: String, CaseIterable, Codable {
        case circle = "circle.fill"
        case diamond = "diamond.fill"
        case star = "star.fill"
        case triangle = "triangle.fill"
        case hexagon = "hexagon.fill"
        case bolt = "bolt.fill"
        case flame = "flame.fill"
        case drop = "drop.fill"
        case heart = "heart.fill"
        case moon = "moon.fill"
        case sparkle = "sparkles"
        case sun = "sun.max.fill"
    }
}

struct Ring: Identifiable, Equatable {
    let id: Int
    let segmentCount: Int
    var segments: [Segment]
    var currentOffset: Int
    let solutionOffset: Int

    var displaySegments: [Segment] {
        let n = segments.count
        return (0..<n).map { i in
            segments[((i - currentOffset) % n + n) % n]
        }
    }

    var isSolved: Bool {
        currentOffset == solutionOffset
    }

    var hintDirection: Int {
        let diff = (solutionOffset - currentOffset + segmentCount) % segmentCount
        if diff == 0 { return 0 }
        return diff <= segmentCount / 2 ? 1 : -1
    }

    var hintStepsRemaining: Int {
        let diff = (solutionOffset - currentOffset + segmentCount) % segmentCount
        return min(diff, segmentCount - diff)
    }

    mutating func rotate(by delta: Int) {
        let n = segmentCount
        currentOffset = ((currentOffset + delta) % n + n) % n
    }

    static func generate(
        id: Int,
        segmentCount: Int,
        targetIndex: Int,
        targetGlyph: Segment.Glyph,
        scrambleAmount: Int
    ) -> Ring {
        let decoyGlyphs = Segment.Glyph.allCases.filter { $0 != targetGlyph }
        let segments = (0..<segmentCount).map { i in
            if i == targetIndex {
                return Segment(id: i, glyph: targetGlyph, isTarget: true)
            } else {
                return Segment(id: i, glyph: decoyGlyphs.randomElement()!, isTarget: false)
            }
        }
        return Ring(
            id: id,
            segmentCount: segmentCount,
            segments: segments,
            currentOffset: scrambleAmount,
            solutionOffset: 0
        )
    }
}
