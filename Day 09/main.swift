import Foundation
import AoC_Helpers

func diff(of sequence: some Collection<Int>) -> [Int] {
	sequence.windows(ofCount: 2).map { -$0.splat(-) }
}

let histories = input().lines().map { $0.ints(allowSigns: true) }
let diffs = histories.map { history in
	sequence(first: history, next: diff(of:))
		.prefix { !$0.allSatisfy { $0 == 0 } }
}

let nexts = diffs.map {
	$0.lazy.map(\.last!).sum()
}
print(nexts.sum())

let prevs = diffs.map {
	$0.lazy.map(\.first!).reversed().reduce(0) { $1 - $0 }
}
print(prevs.sum())
