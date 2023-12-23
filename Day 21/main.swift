import Foundation
import AoC_Helpers
import HandyOperators

let map = Matrix(input().lines())
let start = map.onlyIndex(of: "S")!
let isPlot = map.map { $0 != "#" }

func distances(from start: Vector2, in isPlot: Matrix<Bool> = isPlot) -> Matrix<Int?> {
	isPlot.map { _ in nil } <- { distances in
		var next = [start]
		for distance in 0... {
			next = next
				.filter { pos in
					guard
						distances.isInMatrix(pos),
						distances[pos] == nil,
						isPlot[pos]
					else { return false }
					distances[pos] = distance
					return true
				}
				.flatMap { $0.neighbors }
			guard !next.isEmpty else { break }
		}
	}
}

let distancesFromStart = distances(from: start).compacted()
print(distancesFromStart.count { $0.isMultiple(of: 2) && $0 <= 64 })

let evens = distancesFromStart.count { $0.isMultiple(of: 2) }
let odds = distancesFromStart.count { !$0.isMultiple(of: 2) }

// the input has the nice property that the paths from the center to each edge are all clear, as well as the path all around, which simplifies part 2 enormously
let steps = 26_501_365
//for steps in stride(from: 1, through: 999, by: 2) {
// max distance of tiles that can be reached at all
let maxTileDistance = steps.ceilOfDivision(by: map.width)
// any tiles at distance 2 less than this are fully reachable (thanks to the way the input is designed), so we can handle them mathematically:
// since our step count is odd, we can reach all odd distances in the first tile, then all even distances in any neighboring ones, etc.
// the number of tiles at each distance from the center is 1, 4, 8, 12, 16, …
// for odd tiles, summing up every other number gives 1, 9, 25, 49, …—the odd squares
// for even tiles, summing up the remaining numbers gives 4, 16, 36, 64, …—the even squares
// we'll subtract 2 from the max distance to only handle completely covered tiles
let coveredOddDistance = maxTileDistance / 2 * 2 - 1 // _, _, 1, 1, 3, 3, 5, …
let coveredEvenDistance = (maxTileDistance - 1) / 2 * 2 // _, _, _, 2, 2, 4, 4, …
let countFromCovered = 0
+ odds * coveredOddDistance * coveredOddDistance
+ evens * coveredEvenDistance * coveredEvenDistance

// for the outer 2 layers, we can treat it as 8 distinct cases: entering from each corner and the middle of each edge
// for the latter, there's just 1 outermost tile each and 1 on the penultimate layer
// of the former, there's maxTileDistance - 1 outermost tiles per side, and maxTileDistance - 2 on the penultimate layer
let corners = [
	Vector2(0, 0),
	Vector2(0, map.height - 1),
	Vector2(map.width - 1, 0),
	Vector2(map.width - 1, map.height - 1),
]
let edgeCenters = [
	Vector2(0, start.y),
	Vector2(start.x, 0),
	Vector2(map.width - 1, start.y),
	Vector2(start.x, map.height - 1),
]

func reachableCount(among distances: some Collection<Int>, within max: Int) -> Int {
	let parity = max.isMultiple(of: 2)
	return distances.count { $0.isMultiple(of: 2) != parity && $0 < max }
}

// how much further we can reach starting from the corner of each outer corner tile
let reach = steps - (maxTileDistance - 1) * map.width

let distancesFromCorners = corners.flatMap { distances(from: $0).compacted() }
let countFromOuterCorners = reachableCount(among: distancesFromCorners, within: reach)
let countFromInnerCorners = reachableCount(among: distancesFromCorners, within: reach + map.width)

let radius = map.width / 2

let distancesFromEdges = edgeCenters.flatMap { distances(from: $0).compacted() }
let countFromOuterEdges = reachableCount(among: distancesFromEdges, within: reach - radius)
let countFromInnerEdges = reachableCount(among: distancesFromEdges, within: reach - radius + map.width)

let total = [
	countFromCovered,
	(maxTileDistance - 1) * countFromOuterCorners,
	(maxTileDistance - 2) * countFromInnerCorners,
	countFromOuterEdges,
	countFromInnerEdges,
].sum()
print(total)
