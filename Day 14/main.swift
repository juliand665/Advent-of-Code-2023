import Foundation
import AoC_Helpers
import HandyOperators

enum Rock: Character, Hashable, CustomStringConvertible {
	case cube = "#"
	case round = "O"
	
	var description: String { "\(rawValue)" }
}

struct Terrain: Hashable {
	var rocks: Matrix<Rock?>
	
	mutating func slideNorth() {
		slide(in: .up)
	}
	
	mutating func slide(in direction: Direction) {
		let width = rocks.width
		let height = rocks.height
		let lineStarts = switch direction {
		case .up:
			(0..<width).lazy.map { x in Vector2(x, 0) }
		case .left:
			(0..<height).lazy.map { y in Vector2(0, y) }
		case .down:
			(0..<width).lazy.map { x in Vector2(x, height - 1) }
		case .right:
			(0..<height).lazy.map { y in Vector2(width - 1, y) }
		}
		
		for start in lineStarts {
			var target = start
			var source = start
			while rocks.isInMatrix(source) {
				switch rocks[source] {
				case nil:
					break
				case .round:
					rocks[target] = rocks[source].take()
					target -= direction.offset
				case .cube:
					target = source - direction.offset
				}
				source -= direction.offset
			}
		}
	}
	
	func totalLoad() -> Int {
		zip((1...rocks.height), rocks.rows.reversed())
			.lazy
			.map { $0 * $1.count(of: .round) }
			.sum()
	}
	
	mutating func runCycle() {
		for direction in Direction.nwse {
			slide(in: direction)
		}
	}
}

let terrain = Terrain(rocks: Matrix(input().lines().nestedMap(Rock.init)))

let slidTerrain = terrain <- { $0.slideNorth() }
print(slidTerrain.totalLoad())

let cycledTerrain = terrain <- { terrain in
	var seen = [terrain: 0]
	let targetRounds = 1_000_000_000
	for round in 1...targetRounds {
		terrain.runCycle()
		
		if let last = seen[terrain] {
			let cycleLength = round - last
			print("found cycle of length", cycleLength)
			let missing = (targetRounds - round) % cycleLength
			terrain = seen.onlyElement { $0.value == last + missing }!.key
			return
		}
		
		seen[terrain] = round
	}
}
print(cycledTerrain.totalLoad())
