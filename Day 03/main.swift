import Foundation
import AoC_Helpers

let schematic = Matrix(input().lines())
let numberStarts = schematic.positions()
	.filter { schematic[$0].isNumber && schematic.element(at: $0 - .unitX)?.isNumber != true }
//print(numberStarts)

func isPartLocation(_ char: Character) -> Bool {
	char != "." && char.isNumber == false
}

let numbers = numberStarts.map { start in
	let positions = sequence(first: start) { $0 + .unitX }
		.prefix { schematic.element(at: $0)?.isNumber == true }
	let number = Int(String(positions.lazy.map { schematic[$0] }))!
	return (positions: positions, number: number)
}

let partNumbers = numbers
	.lazy
	.filter {
		$0.positions.contains {
			schematic.neighborsWithDiagonals(of: $0).contains(where: isPartLocation(_:))
		}
	}
	.map(\.number)
print(partNumbers.sum())

do {
	let gearCandidates: [Vector2: [Int]] = numbers.reduce(into: [:]) { gearCandidates, number in
		let neighbors = Set(number.positions.flatMap(\.neighborsWithDiagonals))
		for position in neighbors {
			guard schematic.element(at: position) == "*" else { continue }
			gearCandidates[position, default: []].append(number.number)
		}
	}
	
	_ = gearCandidates
}

var gearCandidates: [Vector2: [Int]] = [:]
for (positions, number) in numbers {
	let neighbors = Set(positions.flatMap(\.neighborsWithDiagonals))
	for position in neighbors {
		guard schematic.element(at: position) == "*" else { continue }
		gearCandidates[position, default: []].append(number)
	}
}


let gearRatios = gearCandidates.values.filter { $0.count == 2 }.map { $0[0] * $0[1] }
print(gearRatios.sum())
