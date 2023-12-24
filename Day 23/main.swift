import Foundation
import AoC_Helpers

enum Tile: Hashable {
	case wall
	case free
	case slope(Direction)
	
	func canTraverse(in direction: Direction, respectingSlopes: Bool) -> Bool {
		switch self {
		case .free:
			true
		case .slope(let dir):
			!respectingSlopes || dir == direction
		case .wall:
			false
		}
	}
}

let maze = Matrix(input().lines().nestedMap {
	switch $0 {
	case "#": Tile.wall
	case ".": Tile.free
	case let other: Tile.slope(Direction(other)!)
	}
})
let start = Vector2(1, 0)
let end = Vector2(maze.width - 2, maze.height - 1)

func findLongestHike(respectingSlopes: Bool) {
	// turn maze into a directed graph
	var edges: [Vector2: [(Vector2, Int)]] = [:]
	func explore(from start: Vector2, in direction: Direction) {
		var current = start
		func canGo(in direction: Direction) -> Bool {
			maze.element(at: current + direction)?
				.canTraverse(in: direction, respectingSlopes: respectingSlopes) == true
		}
		
		var distance = 0
		var direction = direction
		while true {
			current += direction.offset
			distance += 1
			let options = [direction.counterclockwise, direction, direction.clockwise]
			guard let next = options.onlyElement(where: canGo(in:)) else { break }
			direction = next
		}
		assert(distance > 0)
		edges[start, default: []].append((current, distance))
		
		guard edges[current] == nil else { return }
		edges[current] = []
		for direction in Direction.allCases where canGo(in: direction) {
			explore(from: current, in: direction)
		}
	}
	explore(from: start, in: .down)
	
	// TODO: use A* or max flow or something to optimize this if i care lol, it currently takes ~20 seconds
	func longestHike(from start: Vector2, seen: Set<Vector2> = []) -> Int? {
		guard start != end else { return 0 }
		let seen = seen.union([start])
		return edges[start]!.lazy.compactMap { (next, distance) -> Int? in
			guard !seen.contains(next) else { return nil }
			return longestHike(from: next, seen: seen).map { $0 + distance }
		}.max()
	}
	print(longestHike(from: start)!)
}

findLongestHike(respectingSlopes: true) // part 1
findLongestHike(respectingSlopes: false) // part 2
