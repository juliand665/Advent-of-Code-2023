import Foundation
import AoC_Helpers
import HandyOperators
import SortedCollections

struct BrickEnds {
	var start, end: Vector3
	
	var positions: some Sequence<Vector3> {
		let delta = end - start
		let abs = delta.absolute
		let length = abs + 1
		let dir = abs == 0 ? .zero : delta / abs
		return sequence(first: start) { $0 + dir }.prefix(length)
	}
}

let bricks = input().lines().map {
	$0.split(separator: "~")
		.map { $0.ints().splat(Vector3.init) }
		.splat(BrickEnds.init)
}

let brickPositions = bricks.map { Array($0.positions) }
let byHeight = brickPositions.sorted { $0.lazy.map(\.z).min()! }

let supporters: [Int: Set<Int>] = [:] <- { supporters in
	var heightmap: [Vector2: Int] = [:]
	var brickIDs: [Vector3: Int] = [:]
	for (id, brick) in byHeight.enumerated() {
		let floor = brick.lazy.compactMap { heightmap[$0.xy] }.max() ?? 0
		let brickHeight = brick.last!.z - brick.first!.z + 1
		assert(brickHeight > 0)
		let newFloor = floor + brickHeight
		for position in brick {
			heightmap[position.xy] = newFloor
			brickIDs[position.with(z: newFloor)] = id
			if let brickBelow = brickIDs[position.with(z: floor)] {
				supporters[id, default: []].insert(brickBelow)
			}
		}
	}
}

let disintegratable = bricks.indices.count { id in
	supporters.values.allSatisfy { $0 != [id] }
}
print(disintegratable)

// counting the number of distinct pairs (x, y) where removing x will (indirectly) make y fall
let removables = 0 <- { removables in
	for id in bricks.indices {
		// this is actually slightly slower than heap + set but it just reads more clearly
		var slice: SortedSet<Int> = [id]
		while let next = slice.popLast() { // pop highest id (i.e. highest-placed brick, since they were sorted by fall order)
			guard let below = supporters[next] else { break } // on ground
			
			for supporter in below {
				slice.insert(supporter)
			}
			
			if slice.count == 1 {
				removables += 1
			}
		}
	}
}
print(removables)
