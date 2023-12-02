import Foundation
import AoC_Helpers

struct Round {
	var r, g, b: Int
	
	var power: Int { r * g * b }
}

extension Round {
	init(_ description: some StringProtocol) {
		let counts = description.components(separatedBy: ", ")
		func component(named name: String) -> Int {
			counts.first { $0.ends(with: name) }.map { Int($0.split(separator: " ").first!)! } ?? 0
		}
		r = component(named: "red")
		g = component(named: "green")
		b = component(named: "blue")
	}
}

let games = input().lines().map {
	$0.components(separatedBy: ": ").last!.components(separatedBy: "; ").map(Round.init(_:))
}

let possibleGames = zip(1..., games)
	.lazy
	.compactMap { id, game in
		game.allSatisfy { $0.r <= 12 && $0.g <= 13 && $0.b <= 14 } ? id : nil
	}
	.reduce(0, +)
print(possibleGames)

func requirements(forGame game: [Round]) -> Round {
	game.reduce { .init(
		r: max($0.r, $1.r), 
		g: max($0.g, $1.g),
		b: max($0.b, $1.b)
	) }!
}

let reqPowers = games.lazy.map(requirements(forGame:)).map(\.power).reduce(0, +)
print(reqPowers)
