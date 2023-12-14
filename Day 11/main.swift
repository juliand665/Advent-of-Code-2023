import Foundation
import AoC_Helpers

let space = Matrix(input().lines())
let galaxies: Array = space.indexed()
	.lazy
	.filter { $0.element == "#" }
	.map(\.index)

// prefix sums
let emptyRows: Array = space.rows
	.lazy
	.map { $0.contains("#") ? 0 : 1 }
	.reductions(0, +)
let emptyCols: Array = space.columns
	.lazy
	.map { $0.contains("#") ? 0 : 1 }
	.reductions(0, +)

func printDistances(atAge age: Int) {
	func distanceBetween(_ a: Vector2, _ b: Vector2) -> Int {
		let rowStretch = emptyRows[max(a.y, b.y)] - emptyRows[min(a.y, b.y)]
		let colStretch = emptyCols[max(a.x, b.x)] - emptyCols[min(a.x, b.x)]
		return a.distance(to: b) + (rowStretch + colStretch) * (age - 1)
	}
	
	let distances = galaxies.pairwiseCombinations().lazy.map(distanceBetween)
	print(distances.sum() / 2)
}

printDistances(atAge: 2)
printDistances(atAge: 1_000_000)
