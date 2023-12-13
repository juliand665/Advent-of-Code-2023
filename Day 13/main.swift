import Foundation
import AoC_Helpers

struct Grid {
	var rows: [Int]
	var columns: [Int]
}

extension Grid {
	init(_ rows: some Collection<Substring>) {
		let terrain = Matrix(rows.lazy.map { $0.map { $0 == "#" } })
		
		self.rows = terrain.rows.map {
			$0.reduce(0) { $0 << 1 | ($1 ? 1 : 0) }
		}
		self.columns = terrain.columns().map {
			$0.reduce(0) { $0 << 1 | ($1 ? 1 : 0) }
		}
	}
}

let patterns = input().lineGroups().map(Grid.init)

// part 1
do {
	func reflection(in values: [Int]) -> Int? {
		(1..<values.count).onlyElement { count in
			zip(
				values.prefix(count).reversed(),
				values.dropFirst(count)
			).allSatisfy(==)
		}
	}
	
	let indices = patterns.map {
		reflection(in: $0.columns) ?? 100 * reflection(in: $0.rows)!
	}
	print(indices.sum())
}

// part 2
do {
	func reflection(in values: [Int]) -> Int? {
		(1..<values.count).onlyElement { count in
			zip(
				values.prefix(count).reversed(),
				values.dropFirst(count)
			).lazy.map(^).map(\.nonzeroBitCount).sum() == 1
		}
	}
	
	let indices = patterns.map {
		reflection(in: $0.columns) ?? 100 * reflection(in: $0.rows)!
	}
	print(indices.sum())
}
