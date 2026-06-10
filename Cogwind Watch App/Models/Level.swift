import Foundation

struct Level: Identifiable {
    let id: Int
    let ringCount: Int
    let segmentsPerRing: Int
    let targetGlyph: Segment.Glyph
    let timeLimit: TimeInterval?
    let title: String
    let world: World

    enum World: String, CaseIterable {
        case dawn = "Dawn"
        case bloom = "Bloom"
        case storm = "Storm"
        case ember = "Ember"
        case cosmos = "Cosmos"
        case abyss = "Abyss"
    }

    func generateRings() -> [Ring] {
        (0..<ringCount).map { ringIndex in
            let scramble = Int.random(in: 1..<segmentsPerRing)
            return Ring.generate(
                id: ringIndex,
                segmentCount: segmentsPerRing,
                targetIndex: 0,
                targetGlyph: targetGlyph,
                scrambleAmount: scramble
            )
        }
    }
}

enum LevelGenerator {
    static let levels: [Level] = [
        Level(id: 1, ringCount: 2, segmentsPerRing: 4, targetGlyph: .circle,
              timeLimit: nil, title: "First Spin", world: .dawn),
        Level(id: 2, ringCount: 2, segmentsPerRing: 4, targetGlyph: .heart,
              timeLimit: nil, title: "Heartbeat", world: .dawn),
        Level(id: 3, ringCount: 2, segmentsPerRing: 6, targetGlyph: .diamond,
              timeLimit: nil, title: "Six Sides", world: .dawn),
        Level(id: 4, ringCount: 2, segmentsPerRing: 6, targetGlyph: .star,
              timeLimit: 90, title: "Star Light", world: .dawn),
        Level(id: 5, ringCount: 2, segmentsPerRing: 8, targetGlyph: .sparkle,
              timeLimit: 80, title: "Glimmer", world: .dawn),

        Level(id: 6, ringCount: 3, segmentsPerRing: 4, targetGlyph: .circle,
              timeLimit: 70, title: "Triple Ring", world: .bloom),
        Level(id: 7, ringCount: 3, segmentsPerRing: 6, targetGlyph: .triangle,
              timeLimit: 65, title: "Sharp Bloom", world: .bloom),
        Level(id: 8, ringCount: 3, segmentsPerRing: 6, targetGlyph: .moon,
              timeLimit: 60, title: "Moonrise", world: .bloom),
        Level(id: 9, ringCount: 3, segmentsPerRing: 8, targetGlyph: .heart,
              timeLimit: 55, title: "Heartwood", world: .bloom),
        Level(id: 10, ringCount: 3, segmentsPerRing: 8, targetGlyph: .hexagon,
              timeLimit: 50, title: "Hex Garden", world: .bloom),

        Level(id: 11, ringCount: 4, segmentsPerRing: 4, targetGlyph: .bolt,
              timeLimit: 55, title: "Lightning", world: .storm),
        Level(id: 12, ringCount: 4, segmentsPerRing: 6, targetGlyph: .drop,
              timeLimit: 50, title: "Downpour", world: .storm),
        Level(id: 13, ringCount: 4, segmentsPerRing: 6, targetGlyph: .star,
              timeLimit: 45, title: "Star Storm", world: .storm),
        Level(id: 14, ringCount: 4, segmentsPerRing: 8, targetGlyph: .diamond,
              timeLimit: 40, title: "Hailstone", world: .storm),
        Level(id: 15, ringCount: 4, segmentsPerRing: 8, targetGlyph: .sparkle,
              timeLimit: 35, title: "Thunder", world: .storm),

        Level(id: 16, ringCount: 5, segmentsPerRing: 4, targetGlyph: .flame,
              timeLimit: 45, title: "Kindle", world: .ember),
        Level(id: 17, ringCount: 5, segmentsPerRing: 6, targetGlyph: .sun,
              timeLimit: 40, title: "Sunflare", world: .ember),
        Level(id: 18, ringCount: 5, segmentsPerRing: 6, targetGlyph: .heart,
              timeLimit: 35, title: "Heartfire", world: .ember),
        Level(id: 19, ringCount: 5, segmentsPerRing: 8, targetGlyph: .bolt,
              timeLimit: 30, title: "Inferno", world: .ember),
        Level(id: 20, ringCount: 5, segmentsPerRing: 8, targetGlyph: .flame,
              timeLimit: 28, title: "Wildfire", world: .ember),

        Level(id: 21, ringCount: 5, segmentsPerRing: 10, targetGlyph: .star,
              timeLimit: 35, title: "Starfield", world: .cosmos),
        Level(id: 22, ringCount: 6, segmentsPerRing: 6, targetGlyph: .moon,
              timeLimit: 32, title: "Orbit", world: .cosmos),
        Level(id: 23, ringCount: 6, segmentsPerRing: 8, targetGlyph: .sparkle,
              timeLimit: 30, title: "Nebula", world: .cosmos),
        Level(id: 24, ringCount: 6, segmentsPerRing: 8, targetGlyph: .sun,
              timeLimit: 28, title: "Supernova", world: .cosmos),
        Level(id: 25, ringCount: 6, segmentsPerRing: 10, targetGlyph: .diamond,
              timeLimit: 25, title: "Galaxy", world: .cosmos),

        Level(id: 26, ringCount: 6, segmentsPerRing: 10, targetGlyph: .hexagon,
              timeLimit: 25, title: "Deep Dive", world: .abyss),
        Level(id: 27, ringCount: 7, segmentsPerRing: 8, targetGlyph: .drop,
              timeLimit: 25, title: "Trench", world: .abyss),
        Level(id: 28, ringCount: 7, segmentsPerRing: 10, targetGlyph: .heart,
              timeLimit: 22, title: "Abyss Heart", world: .abyss),
        Level(id: 29, ringCount: 7, segmentsPerRing: 10, targetGlyph: .flame,
              timeLimit: 20, title: "Void Flame", world: .abyss),
        Level(id: 30, ringCount: 8, segmentsPerRing: 10, targetGlyph: .star,
              timeLimit: 20, title: "Final Wind", world: .abyss),
    ]

    static func infiniteLevel(number: Int) -> Level {
        let rings = min(2 + number / 3, 8)
        let segments = min(4 + (number / 2) * 2, 16)
        let time = max(60.0 - Double(number) * 2.0, 12.0)
        let glyph = Segment.Glyph.allCases[number % Segment.Glyph.allCases.count]
        return Level(
            id: number,
            ringCount: rings,
            segmentsPerRing: segments,
            targetGlyph: glyph,
            timeLimit: time,
            title: "Wind \(number)",
            world: .abyss
        )
    }
}
