import Foundation
import AoC_Helpers
import HandyOperators

struct Line {
	var slots: [Slot]
	var groupSizes: [Int]
	
	func possibleArrangements() -> Int {
		// prefix (well, suffix) sums for minimum remaining space needed to fit groups past a certain index
		let remainingSizes = groupSizes
			.reversed()
			.lazy
			.reductions(-1) { $0 + 1 + $1 }
			.reversed()
		
		// recursive function
		func _arrangementCount(slots: ArraySlice<Slot>, sizes: ArraySlice<Int>) -> Int {
			guard let nextSize = sizes.first else {
				return slots.contains(.broken) ? 0 : 1
			}
			guard slots.count >= remainingSizes[sizes.startIndex] else { return 0 }
			
			let canStartHere = !slots.prefix(nextSize).contains(.working)
			&& slots.dropFirst(nextSize).first != .broken
			lazy var countIfUsed = arrangementCount(
				slots: slots.dropFirst(nextSize + 1),
				sizes: sizes.dropFirst()
			)
			
			let canSkip = slots.first != .broken
			lazy var countIfSkipped = arrangementCount(
				slots: slots.drop { $0 == .broken }.dropFirst(),
				sizes: sizes
			)
			
			//print(
			//	String(repeating: " ", count: slots.startIndex) + String(slots.map(\.rawValue)),
			//	canStartHere ? countIfUsed : "-", canSkip ? countIfSkipped : "-", sizes
			//)
			return (canStartHere ? countIfUsed : 0) + (canSkip ? countIfSkipped : 0)
		}
		
		// memoize
		struct MemoKey: Hashable { var slotStart, sizeStart: Int }
		var knownCounts: [MemoKey: Int] = [:]
		func arrangementCount(slots: ArraySlice<Slot>, sizes: ArraySlice<Int>) -> Int {
			let key = MemoKey(slotStart: slots.startIndex, sizeStart: sizes.startIndex)
			return knownCounts[key] ?? _arrangementCount(slots: slots, sizes: sizes) <- {
				knownCounts[key] = $0
			}
		}
		
		return arrangementCount(slots: slots[...], sizes: groupSizes[...])
	}
	
	func unfolded() -> Self {
		.init(
			slots: repeatElement(slots, count: 5).interspersed(with: [.unknown]).flatMap { $0 },
			groupSizes: repeatElement(groupSizes, count: 5).flatMap { $0 }
		)
	}
}

enum Slot: Character, Hashable, CustomStringConvertible {
	case working = "."
	case broken = "#"
	case unknown = "?"
	
	var description: String { "\(rawValue)" }
}

let lines = input().lines().map {
	$0.components(separatedBy: " ").splat {
		Line(
			slots: $0.map { Slot(rawValue: $0)! },
			groupSizes: $1.lazy.split(separator: ",").asInts()
		)
	}
}
let arrangementCounts = lines.map { $0.possibleArrangements() }
print(arrangementCounts.sum())

let p2arrangementCounts = lines
	.lazy
	.map { $0.unfolded() }
	.map { $0.possibleArrangements() }
print(p2arrangementCounts.sum())
