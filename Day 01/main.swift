import Foundation
import AoC_Helpers

let lines = input().lines()
let part1Value = lines
	.lazy
	.map { "\($0.first(where: \.isNumber)!)\($0.last(where: \.isNumber)!)" }
	.map { Int($0)! }
	.sum()
print(part1Value)

let spellings = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

func digits(of line: some StringProtocol) -> [Int] {
	var digits: [Int] = []
	for start in line.indices {
		let rest = line[start...]
		if rest.first!.isNumber {
			digits.append(.init(rest.prefix(1))!)
		} else {
			for (number, spelling) in spellings.enumerated() {
				if rest.hasPrefix(spelling) {
					digits.append(number)
					break
				}
			}
		}
	}
	return digits
}

let part2Value = lines
	.lazy
	.map(digits(of:))
	.map { $0.first! * 10 + $0.last! }
	.sum()
print(part2Value)
