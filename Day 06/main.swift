import Foundation
import AoC_Helpers

struct Race {
	var time: Int
	var distance: Int
	
	var waysToWin: Int {
		// distance traveled is just a quadratic formula over time spent winding up x:
		// x (t-x) = d
		// tx - x² = d
		// x² - tx + d = 0
		// x = (t ± √(t² - 4d)) / 2 = t/2 ± √((t/2)² - d)
		
		let halfTime = Double(time) / 2
		// offset from midpoint to either solution is half the discriminant
		let offset = sqrt(halfTime * halfTime - Double(distance + 1)) // distance + 1 so that equality means we _beat_ the target distance
		// rounding gets tricky here since we're reasoning about integers; this is the simplest way i've found to deal with it:
		// half span is the number of solutions to the left of the midpoint
		let halfSpan = halfTime - floor(halfTime - offset)
		return Int(halfSpan * 2) + 1 // plus 1 so that e.g. 2–4 is counted as 3 (2, 3, 4) instead of 2
	}
}

let races = input().lines()
	.map { $0.ints() }
	.splat(zip)
	.map(Race.init)
print(races.lazy.map(\.waysToWin).product())

let actualRace = input().lines()
	.map { Int($0.filter(\.isNumber))! }
	.splat(Race.init)
print(actualRace.waysToWin)
