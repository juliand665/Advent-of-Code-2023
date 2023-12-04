import Foundation
import AoC_Helpers
import SimpleParser

struct Card {
	var winningNumbers: Set<Int>
	var numbers: [Int]
	
	var matchCount: Int {
		numbers.count(where: winningNumbers.contains(_:))
	}
}

func score(forCount count: Int) -> Int {
	count == 0 ? 0 : 1 << (count - 1)
}

extension Card: Parseable {
	init(from parser: inout Parser) {
		parser.consume(through: ":")
		winningNumbers = Set(parser.consume(through: "|")!.ints())
		numbers = parser.ints()
	}
}

let cards = input().lines().map(Card.init)

let counts = cards.map(\.matchCount)
print(counts.lazy.map(score(forCount:)).sum())

var copyCounts = Array(repeating: 1, count: cards.count)
for (index, count) in counts.enumerated() {
	let copies = copyCounts[index]
	for i in index + 1 ..< index + 1 + count {
		copyCounts[i] += copies
	}
}
print(copyCounts.sum())
