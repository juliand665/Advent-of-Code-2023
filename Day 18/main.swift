import Foundation
import AoC_Helpers
import HandyOperators

struct Instruction {
	var direction: Direction
	var count: Int
	
	var offset: Vector2 {
		direction.offset * count
	}
}

let instructions = input().lines().map { line in
	let (_, dir, count, hex) = line.wholeMatch(of: /(\w) (\d+) \(#([0-9a-f]{6})\)/)!.output
	let part1 = Instruction(
		direction: .init(dir.onlyElement()!)!,
		count: .init(count)!
	)
	let part2 = Instruction(
		direction: Direction.right.rotated(by: Int(hex.suffix(1))!),
		count: Int(hex.prefix(5), radix: 16)!
	)
	return (part1, part2)
}

func filledCount(after instructions: some Collection<Instruction>) -> Int {
	// in total, the instructions have to twist in some direction to form a closed loop, either showing 4 more cw than ccw turns or vice versa
	// this tells us which side of the trench is the interior to dig out
	let clockwiseCount = instructions
		.windows(ofCount: 2)
		.count { $0.splat { $0.direction.clockwise == $1.direction } }
	// if we were also looking at the last + first instruction, clockwise count would be guaranteed to be 4 different from ccw count, but either way one of them will be larger than half and the other not
	let isClockwise = clockwiseCount * 2 > instructions.count
	// always seems to be clockwise for the inputs we're given, but it's not technically specified so
	
	// figure out all the corner points we go through
	let vertices: [Vector2] = instructions.reductions(.zero) { $0 + $1.offset }
	
	// create a non-uniform grid subdivided on either side of each corner tile
	let xDivisions = Set(vertices.map(\.x).flatMap { [$0, $0 + 1] }).sorted()
	let yDivisions = Set(vertices.map(\.y).flatMap { [$0, $0 + 1] }).sorted()
	/// grid coord from original position
	func compress(_ position: Vector2) -> Vector2 {
		.init(
			xDivisions.partitioningIndex { $0 >= position.x },
			yDivisions.partitioningIndex { $0 >= position.y }
		)
	}
	/// original position represented by a grid coord
	func expand(_ position: Vector2) -> Vector2 {
		.init(xDivisions[position.x], yDivisions[position.y])
	}
	/// area of a single grid cell
	func area(of position: Vector2) -> Int {
		(expand(position + .init(1, 1)) - expand(position)).absolute.product
	}
	
	let lagoon: Set<Vector2> = [] <- { lagoon in
		var position = compress(.zero)
		for instruction in instructions {
			let end = compress(expand(position) + instruction.offset)
			while position != end {
				lagoon.insert(position)
				position += instruction.direction.offset
			}
		}
		assert(position == compress(.zero))
		
		func fill(from start: Vector2) {
			guard !lagoon.contains(start) else { return }
			lagoon.insert(start)
			for neighbor in start.neighbors {
				fill(from: neighbor)
			}
		}
		let firstDir = instructions.first!.direction
		fill(from: position + firstDir + firstDir.rotated(clockwise: isClockwise))
	}
	
	return lagoon.lazy.map(area(of:)).sum()
}

print(filledCount(after: instructions.lazy.map(\.0)))
print(filledCount(after: instructions.lazy.map(\.1)))
