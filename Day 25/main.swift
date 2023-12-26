import Foundation
import AoC_Helpers

let edges: [(Int, Int)] = input().lines().flatMap { line in
	let (source, out) = line.split(separator: ": ").extract()
	let src = getID(source)
	return out.split(separator: " ").map { (src, getID($0)) }
}

struct DisjointSets {
	var parents: [Int]
	var sizes: [Int]
	var count: Int
	
	init(count: Int) {
		parents = Array(0..<count)
		sizes = Array(repeating: 1, count: count)
		self.count = count
	}
	
	mutating func find(_ x: Int) -> Int {
		guard parents[x] != x else { return x }
		parents[x] = find(parents[x])
		return parents[x]
	}
	
	mutating func merge(_ a: Int, _ b: Int) {
		let a = find(a)
		let b = find(b)
		
		guard a != b else { return }
		
		let (smaller, larger) = sizes[a] < sizes[b] ? (a, b) : (b, a)
		
		parents[smaller] = larger
		sizes[larger] += sizes[smaller]
		sizes[smaller] = 0
		count -= 1
	}
}

// we need to find the minimum cut in an unweighted graph, which can be done efficiently using Karger's algorithm.
// this works by repeatedly contracting nodes on either side of a randomly chosen edge until only two nodes remain, with their edges being the cut. repeatedly running through this process gives us a minimum cut with high probability, since any one edge is unlikely to be part of the min cut
// even better, we already know the minimum cut is 3 edges, so we can just iterate until we find that!
let nodes = DisjointSets(count: rawIDs.count)
while true {
	func performCut(nodes: DisjointSets) -> (count: Int, sizeProduct: Int) {
		var nodes = nodes
		
		let target = max(2, Int(sqrt(Double(nodes.count))))
		while nodes.count > target {
			let (a, b) = edges.randomElement()!
			nodes.merge(a, b)
		}
		
		if nodes.count == 2 {
			let count = edges.count { nodes.find($0) != nodes.find($1) }
			let sizes = nodes.sizes.filter { $0 > 0 }.product()
			return (count, sizes)
		} else {
			return (0..<1).lazy.map { _ in
				performCut(nodes: nodes)
			}.min { $0.count < $1.count }!
		}
	}
	
	let (count, product) = performCut(nodes: nodes)
	guard count > 3 else {
		print("\(count)-cut found! size product:", product)
		break
	}
}
