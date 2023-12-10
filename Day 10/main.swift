import Foundation
import AoC_Helpers
import HandyOperators

let inputDirections: [Character: [Direction]] = [
	"|": [.up, .down],
	"-": [.left, .right],
	"L": [.up, .right],
	"J": [.up, .left],
	"7": [.down, .left],
	"F": [.down, .right],
]

let rawTiles = Matrix(input().lines())

func connections(from position: Vector2) -> [Direction] {
	rawTiles.element(at: position).flatMap { inputDirections[$0] } ?? []
}

let start = rawTiles.firstIndex(of: "S")!
let startNeighbors = Direction.allCases.filter { direction in
	connections(from: start + direction).contains(direction.opposite)
}

let boundary: [Vector2: Direction] = [:] <- { boundary in
	var direction = startNeighbors.first!
	var position = start
	while true {
		boundary[position] = direction
		position += direction.offset
		guard position != start else { break }
		direction = connections(from: position).onlyElement { $0 != direction.opposite }!
	}
	print(boundary.count / 2) // part 1: max distance is half the number of tiles in the loop
}

let sides = rawTiles.map { _ in nil as Bool? } <- { sides in
	func fill(from start: Vector2, as side: Bool) {
		guard sides.isInMatrix(start) else { return }
		if let currentSide = sides[start] {
			assert(currentSide == side)
		}
		
		guard sides[start] == nil else { return }
		guard !boundary.keys.contains(start) else { return }
		sides[start] = side
		for neighbor in start.neighbors {
			fill(from: neighbor, as: side)
		}
	}
	for (position, direction) in boundary {
		fill(from: position + direction.clockwise, as: true)
		fill(from: position + direction.counterclockwise, as: false)
		let oppositeSide = connections(from: position).contains(direction.counterclockwise)
		fill(from: position + direction.opposite, as: oppositeSide)
	}
}
let interior = !sides[.zero]! // this would break if the loop went through this corner, in which case we'd need to find other methods, but it works for my input lol
print(sides.count(of: interior))
