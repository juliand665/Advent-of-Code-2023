import Foundation
import AoC_Helpers
import Algorithms

enum Part: Character {
	case hSplitter = "-"
	case vSplitter = "|"
	case neMirror = "\\"
	case seMirror = "/"
	
	func outputDirections(for inputs: DirectionSet) -> DirectionSet {
		switch self {
		case .hSplitter:
			!inputs.isDisjoint(with: .vertical) ? .horizontal : inputs.intersection(.horizontal)
		case .vSplitter:
			!inputs.isDisjoint(with: .horizontal) ? .vertical : inputs.intersection(.vertical)
		case .neMirror:
			[
				inputs.contains(.down) ? .right : .none,
				inputs.contains(.right) ? .down : .none,
				inputs.contains(.up) ? .left : .none,
				inputs.contains(.left) ? .up : .none,
			]
		case .seMirror:
			[
				inputs.contains(.up) ? .right : .none,
				inputs.contains(.right) ? .up : .none,
				inputs.contains(.down) ? .left : .none,
				inputs.contains(.left) ? .down : .none,
			]
		}
	}
}

extension DirectionSet {
	static let horizontal: Self = [.left, .right]
	static let vertical: Self = [.up, .down]
	static let none: Self = .init(rawValue: 0)
	
	func contains(_ direction: Direction) -> Bool {
		contains(.init(direction))
	}
}

let tiles = Matrix(input().lines().nestedMap(Part.init))

func tilesEnergized(entering start: Vector2, towards direction: Direction) -> Int {
	var outputs = tiles.map { _ in DirectionSet.none }
	func simulateBeam(entering position: Vector2, towards direction: DirectionSet) {
		guard tiles.isInMatrix(position) else { return }
		let out = tiles[position]?.outputDirections(for: direction) ?? direction
		let new = out.subtracting(outputs[position])
		guard !new.isEmpty else { return }
		
		outputs[position].formUnion(out)
		for direction in Direction.allCases where new.contains(direction) {
			//print("exploring \(direction) from \(position)")
			simulateBeam(entering: position + direction, towards: .init(direction))
		}
	}
	simulateBeam(entering: start, towards: .init(direction))
	return outputs.count { !$0.isEmpty }
}

print(tilesEnergized(entering: .zero, towards: .right))

let counts = chain(
	chain(
		(0..<tiles.width).lazy.map { x in
			tilesEnergized(entering: .init(x, 0), towards: .down)
		},
		(0..<tiles.width).lazy.map { x in
			tilesEnergized(entering: .init(x, tiles.height - 1), towards: .up)
		}
	),
	chain(
		(0..<tiles.height).lazy.map { y in
			tilesEnergized(entering: .init(0, y), towards: .right)
		},
		(0..<tiles.height).lazy.map { y in
			tilesEnergized(entering: .init(tiles.width - 1, y), towards: .left)
		}
	)
)
print(counts.max()!)
