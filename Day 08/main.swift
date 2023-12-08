import Foundation
import AoC_Helpers
import HandyOperators

enum Side: Character {
	case left = "L"
	case right = "R"
}

struct Node {
	var id: String
	var left: String
	var right: String
	
	subscript(side: Side) -> String {
		switch side {
		case .left: left
		case .right: right
		}
	}
}

extension Node {
	init(_ description: Substring) {
		let (_, id, l, r) = try! /(\w+) = \((\w+), (\w+)\)/
			.wholeMatch(in: description)!.output
		self.init(id: String(id), left: String(l), right: String(r))
	}
}

let (rawInstructions, rawNetwork) = input().lineGroups().extract()
let instructions = rawInstructions.onlyElement()!.map { Side(rawValue: $0)! }
let nodes = rawNetwork.lazy.map(Node.init)
let network = Dictionary(values: nodes, keyedBy: \.id)

func instruction(forStep step: Int) -> Side {
	instructions[step % instructions.count]
}

func pathfind(from start: String, offset: Int = 0) -> (end: String, steps: Int) {
	sequence(first: (start, offset)) { node, step in
		(network[node]![instruction(forStep: step)], step + 1)
	}
	.dropFirst()
	.first { $0.0.ends(with: "Z") }!
}

print("from AAA:", pathfind(from: "AAA"))

func primeFactors(of number: Int) -> [Int: Int] {
	[:] <- { factors in
		var rest = number
		var factor = 2
		while rest > 1 {
			let (quotient, remainder) = rest.quotientAndRemainder(dividingBy: factor)
			guard remainder == 0 else {
				factor += factor == 2 ? 1 : 2
				assert(factor <= rest)
				continue
			}
			rest = quotient
			factors[factor, default: 0] += 1
		}
	}
}

let startNodes = nodes.lazy.map(\.id).filter { $0.hasSuffix("A") }
// incredibly, the network seems to be constructed such that the initial path from start to end is exactly the same length as the later paths from the end
let pathLengths: Array = startNodes.map { pathfind(from: $0).steps }
//print("path lengths:", pathLengths)

let totalFactors = pathLengths
	.lazy
	.map { primeFactors(of: $0) }
	.reduce { $0.merging($1, uniquingKeysWith: max) }!
let total = totalFactors
	.lazy
	.flatMap { repeatElement($0, count: $1) }
	.product()
print(total)
