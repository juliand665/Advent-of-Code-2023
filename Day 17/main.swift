import Foundation
import AoC_Helpers
import HandyOperators
import HeapModule

let blocks = Matrix(input().lines().nestedMap { Int(String($0))! })

let end = Vector2(blocks.width - 1, blocks.height - 1)

struct Inspection<Info>: Comparable {
	var minCost: Int
	var currentCost: Int = 0
	var info: Info
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.minCost == rhs.minCost
	}
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.minCost < rhs.minCost
		// tried to be smart and prioritize paths that are further along here, but it wasn't worth the extra performance cost
	}
}

// A* heuristic: lower bound on heat loss from any tile to goal no matter how long you can go straight for
let lowerBounds = blocks.map { _ in Int.max } <- { lowerBounds in
	lowerBounds[end] = 0
	var toInspect: Heap = [
		Inspection(minCost: blocks[end], info: end),
	]
	while let next = toInspect.popMin() {
		for neighbor in next.info.neighbors where blocks.isInMatrix(neighbor) {
			guard next.minCost < lowerBounds[neighbor] else { continue }
			lowerBounds[neighbor] = next.minCost
			toInspect.insert(.init(minCost: next.minCost + blocks[neighbor], info: neighbor))
		}
	}
}
//print(lowerBounds)

func minHeatLoss(minStraightLength: Int, maxStraightLength: Int) -> Int {
	struct Option: Hashable {
		var start: Vector2
		var direction: Direction?
		var timeSinceTurn: Int
	}
	
	var toInspect: Heap = [
		Inspection(minCost: blocks[.zero], info: Option(
			start: .zero, timeSinceTurn: .max
		))
	]
	var seen: Set<Option> = []
	
	// A* search
	
	var currentBest = Int.max
	while let next = toInspect.popMin() {
		let info = next.info
		
		guard next.currentCost + lowerBounds[info.start] < currentBest else { continue }
		guard info.start != end else {
			guard info.timeSinceTurn > minStraightLength - 1 else { continue }
			currentBest = next.currentCost
			continue
		}
		
		//print("exploring from \(info.direction.map(String.init) ?? "x") \(info.start) at \(next.currentCost)")
		
		for newDir in Direction.allCases where newDir != info.direction?.opposite {
			if newDir == info.direction {
				guard info.timeSinceTurn < maxStraightLength else { continue }
			} else {
				guard info.timeSinceTurn > minStraightLength - 1 else { continue }
			}
			
			let neighbor = info.start + newDir
			guard blocks.isInMatrix(neighbor) else { continue }
			
			let currentCost = next.currentCost + blocks[neighbor]
			let minCost = currentCost + lowerBounds[neighbor]
			
			//print("\(info.start): enqueuing \(newDir) for \(minCost), currently at \(currentCost)")
			
			guard minCost < currentBest else { continue }
			let hasTurned = newDir != info.direction
			let option = Option(
				start: neighbor,
				direction: newDir,
				timeSinceTurn: hasTurned ? 1 : info.timeSinceTurn + 1
			)
			
			// this is vital to performance! without it toInspect grows uncontrollably
			guard seen.insert(option).inserted else { continue }
			
			toInspect.insert(.init(minCost: minCost, currentCost: currentCost, info: option))
		}
	}
	
	return currentBest
}

measureTime {
	print(minHeatLoss(minStraightLength: 0, maxStraightLength: 3))
}

measureTime {
	print(minHeatLoss(minStraightLength: 4, maxStraightLength: 10))
}
