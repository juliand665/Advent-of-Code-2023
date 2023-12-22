import Foundation
import AoC_Helpers
import HandyOperators

enum Side: Character {
	case left = "L"
	case right = "R"
}

struct Node {
	var id: Int
	var left: Int
	var right: Int
	
	subscript(side: Side) -> Int {
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
		self = [id, l, r].map { getID($0) }.splat(Self.init)
	}
}

let (rawInstructions, rawNetwork) = input().lineGroups().extract()
let instructions = rawInstructions.onlyElement()!.map { Side(rawValue: $0)! }
let nodes = rawNetwork.lazy.map(Node.init).sorted(on: \.id)

func instruction(forStep step: Int) -> Side {
	instructions[step % instructions.count]
}

let isEndNode = rawIDs.map { $0.ends(with: "Z") }

func pathfind(from start: Int, offset: Int = 0) -> (end: Int, steps: Int) {
	sequence(first: (start, offset)) { node, step in
		(nodes[node][instruction(forStep: step)], step + 1)
	}
	.dropFirst()
	.first { isEndNode[$0.0] }!
}

print("from AAA:", pathfind(from: getID("AAA")))

let startNodes = nodes.lazy.map(\.id).filter { rawIDs[$0].hasSuffix("A") }
// incredibly, the network seems to be constructed such that the initial path from start to end is exactly the same length as the later paths from the end
let pathLengths: Array = measureTime {
	startNodes.map { pathfind(from: $0).steps }
}
print("path lengths:", pathLengths.sum() / pathLengths.count)

print(pathLengths.lowestCommonMultiple())
