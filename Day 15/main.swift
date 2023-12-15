import Foundation
import AoC_Helpers

let products: [UInt8] = (0...255).map { $0 &* 17 }

let sequence = input().split(separator: ",")
func hash(of string: some StringProtocol) -> Int {
	Int(string.utf8.reduce(0) { products[Int($0 &+ UInt8($1))] })
}
print(sequence.lazy.map(hash(of:)).sum())

struct Lens {
	var label: String
	var focalLength: Int
}

var boxes: [[Lens]] = Array(repeating: [], count: 256)
for step in sequence {
	let (_, label, action, length) = step
		.wholeMatch(of: /([a-z]+)([-=])([0-9]*)/)!.output
	let hash = hash(of: label)
	let focalLength = Int(length)
	
	let existing = boxes[hash].firstIndex { $0.label == label }
	
	switch action {
	case "-":
		if let existing {
			boxes[hash].remove(at: existing)
		}
	case "=":
		if let existing {
			boxes[hash][existing].focalLength = focalLength!
		} else {
			boxes[hash].append(.init(label: .init(label), focalLength: focalLength!))
		}
	default:
		fatalError()
	}
}
let focusingPower = zip(1..., boxes).lazy.map {
	$0 * zip(1..., $1).lazy.map {
		$0 * $1.focalLength
	}.sum()
}.sum()
print(focusingPower)
