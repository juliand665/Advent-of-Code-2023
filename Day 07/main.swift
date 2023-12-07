import Foundation
import AoC_Helpers
import SimpleParser

enum Card: Comparable {
	case joker
	case n2, n3, n4, n5, n6, n7, n8, n9
	case ten, jack, queen, king, ace
	
	init(_ character: Character) {
		self = switch character {
		case "2": .n2
		case "3": .n3
		case "4": .n4
		case "5": .n5
		case "6": .n6
		case "7": .n7
		case "8": .n8
		case "9": .n9
		case "T": .ten
		case "J": .jack
		case "Q": .queen
		case "K": .king
		case "A": .ace
		default: fatalError()
		}
	}
}

enum HandType: Comparable {
	case highCard, onePair, twoPair, threeOAK, fullHouse, fourOAK, fiveOAK
	
	init(for cards: [Card]) {
		let counts = cards.occurrenceCounts().values.sorted()
		self = if counts.last == 5 {
			.fiveOAK
		} else if counts.last == 4 {
			.fourOAK
		} else if counts.ends(with: [2, 3]) {
			.fullHouse
		} else if counts.last == 3 {
			.threeOAK
		} else if counts.ends(with: [2, 2]) {
			.twoPair
		} else if counts.last == 2 {
			.onePair
		} else {
			.highCard
		}
	}
}

struct Hand: Comparable {
	var cards: [Card]
	var bid: Int
	var type: HandType
	
	func part2() -> Self {
		let counts = cards.lazy.filter { $0 != .jack }.occurrenceCounts()
		let mostCommon = counts.max(on: \.value)?.key ?? .jack
		return .init(
			cards: cards.replacing([.jack], with: [.joker]),
			bid: bid,
			type: .init(for: cards.replacing([.jack], with: [mostCommon]))
		)
	}
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		if lhs.type < rhs.type {
			true
		} else if lhs.type == rhs.type {
			lhs.cards.lexicographicallyPrecedes(rhs.cards)
		} else {
			false
		}
	}
}

extension Hand: Parseable {
	init(from parser: inout Parser) {
		let cards = parser.consume(through: " ")!.map(Card.init)
		self.init(
			cards: cards,
			bid: parser.readInt(),
			type: .init(for: cards)
		)
	}
}

func totalWinnings(of hands: some Collection<Hand>) -> Int {
	zip(1..., hands.sorted()).map { $0 * $1.bid }.sum()
}

let hands = input().lines().map(Hand.init)
print(totalWinnings(of: hands))

let part2Hands = hands.lazy.map { $0.part2() }
print(totalWinnings(of: part2Hands))
