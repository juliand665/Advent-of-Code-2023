import Foundation
import AoC_Helpers
import HandyOperators

struct Hailstone: Hashable {
	var position, velocity: Vector3
	
	func position(at time: Int) -> Vector3 {
		position + velocity * time
	}
	
	func xyIntersection(with other: Self) -> Intersection? {
		// vector geometry!
		// px1 + vx1 * t1 = px2 + vx2 * t2
		// py1 + vy1 * t1 = py2 + vy2 * t2
		// define dx = px2 - px1, dy = py2 - py1
		// vx1 * t1 = dx + vx2 * t2
		// vy1 * t1 = dy + vy2 * t2
		// solved via wolframalpha:
		let dx = other.position.x - position.x
		let dy = other.position.y - position.y
		let v1 = velocity
		let v2 = other.velocity
		let divisor = Double(v2.x * v1.y - v1.x * v2.y)
		guard divisor != 0 else { return nil } // TODO: maybe there are cases where they would still intersect?
		return .init(
			a: self, b: other,
			ta: Double(dy * v2.x - dx * v2.y) / divisor,
			tb: Double(dy * v1.x - dx * v1.y) / divisor
		)
	}
}

struct Intersection {
	var a, b: Hailstone
	var ta, tb: Double
	
	var isInPast: Bool {
		ta < 0 || tb < 0
	}
	
	func xy() -> (Double, Double) { (
		Double(a.position.x) + Double(a.velocity.x) * ta,
		Double(a.position.y) + Double(a.velocity.y) * ta
	) }
	
	func isWithinRange(_ range: ClosedRange<Double>) -> Bool {
		let (x, y) = xy()
		return range.contains(x) && range.contains(y)
	}
}

// gaussian elimination stuff (you see where this is going…)
extension Matrix where Element: FloatingPoint {
	mutating func divideRow(at y: Int, by divisor: Element, startX: Int = 0) {
		for x in startX..<width {
			self[x, y] /= divisor
		}
	}
	
	mutating func subtractRow(
		at source: Int, fromRowAt target: Int,
		multiplyingBy factor: Element = 1,
		startX: Int = 0
	) {
		for x in startX..<width {
			self[x, target] -= factor * self[x, source]
		}
	}
	
	mutating func performGaussianElimination() -> [Element]? {
		precondition(width - 1 == height) // biases as last column
		let biases = width - 1
		for i in 0..<height {
			if self[i, i] == 0 {
				// gotta substitute some rows
				let match = (i + 1 ..< height).first { self[i, $0] != 0 }
				guard let match else { return nil }
				swapRowsAt(i, match)
				assert(self[i, i] != 0)
			}
			
			// normalize
			let divisor = self[i, i]
			self.divideRow(at: i, by: divisor, startX: i)
			
			for other in i + 1 ..< height {
				let multiplier = self[i, other]
				subtractRow(at: i, fromRowAt: other, multiplyingBy: multiplier, startX: i)
				assert(self[i, other] == 0)
			}
		}
		
		//print("before backsubstitution:", self)
		
		// backsubstitute
		for i in (0..<height).dropLast().reversed() {
			for x in i + 1 ..< biases {
				let factor = self[x, i]
				guard factor != 0 else { continue } // already reduced
				subtractRow(at: x, fromRowAt: i, multiplyingBy: factor)
			}
		}
		
		return Array(columns.last!)
	}
}

let hailstones = input().lines().map { $0
	.split(separator: "@")
	.map { $0.ints(allowSigns: true).splat(Vector3.init) }
	.splat(Hailstone.init)
}

let testRange: ClosedRange<Double> = hailstones.count < 10 ? 7...27 : 200_000_000_000_000...400_000_000_000_000

let intersections = hailstones.combinations(ofCount: 2).lazy.compactMap {
	$0.splat { $0.xyIntersection(with: $1) }
}
let pathCrossings = intersections.count { !$0.isInPast && $0.isWithinRange(testRange) }
print(pathCrossings)

// in part 2, we get a system of equations with 3 equations for each hailstone (involving its pos/vel hp/hv and the thrown stone's sp/sv):
// hp + hv * t = sp + sv * t
// => hp - sp = (sv - hv) * t
// => (hp - sp) x (hv - sv) = (sv - hv) x (hv - sv) * t = -((sv - hv) x (sv - hv)) * t = -0 * t = 0
// then via distributivity of the cross product:
// hp x hv - hp x sv - sp x hv + sp x sv = 0
// hp x hv - hp x sv - sp x hv = -sp x sv
// note that the latter term is shared between all hailstones, so we can use it to relate two different stones' equations.
// note also that, by eliminating this bilinear term, we have created a linear system of equations!
// for any pair of hailstones with positions ap, bp and velocities av, bv, we can say:
// ap x av - ap x sv - sp x av = bp x bv - bp x sv - sp x bv
// => (bp - ap) x sv + sp x (bv - av) = bp x bv - ap x av
// let's define dp = bp - ap and dv = bv - av:
// => dp x sv + sp x dv = bp x bv - ap x av
// this gives 3 equations each:
// for x: dp.y sv.z - dp.z sv.y + sp.y dv.z - sp.z dv.y = bp x bv - ap x av
// for y: dp.z sv.x - dp.x sv.z + sp.z dv.x - sp.x dv.z = bp x bv - ap x av
// for z: dp.x sv.y - dp.y sv.x + sp.x dv.y - sp.y dv.x = bp x bv - ap x av
// in total we have 6 unknowns for the thrown stone (pos + vel), so looking at 2 pairs of hailstones is enough provided they're linearly independent—let's use (0, 1) and (0, 2)
// now let's construct that as a matrix & vector in the form Ax = b:
// we'll define x to be [sp.x, sp.y, sp.z, sv.x, sv.y, sv.z]

// build up matrix representing system of equations:

let encoding: Matrix<Int> = .init(width: 6 + 1, height: 6, repeating: 0) <- { encoding in
	// biases as last column
	let biases = encoding.width - 1
	
	let a = hailstones[0]
	let aPosVel = a.position.crossProduct(with: a.velocity)
	
	for i in 0..<2 {
		let b = hailstones[i + 1]
		let bPosVel = b.position.crossProduct(with: b.velocity)
		let bias = (bPosVel - aPosVel).components
		let dp = (b.position - a.position).components
		let dv = (b.velocity - a.velocity).components
		
		for c in 0..<3 {
			let equation = i * 3 + c
			let y = (c + 1) % 3
			let z = (c + 2) % 3
			let v = 3
			encoding[y, equation] = +dv[z]
			encoding[z, equation] = -dv[y]
			encoding[v + y, equation] = -dp[z]
			encoding[v + z, equation] = +dp[y]
			encoding[biases, equation] = bias[c]
		}
	}
}

//print(encoding)
var system = encoding.map { Double($0) }

// solve this system:

let results = system.performGaussianElimination()
//print(system)
//print(results!)

let thrownStone = results!
	.map { Int(round($0)) }
	.chunks(ofCount: 3)
	.map { $0.splat(Vector3.init) }
	.splat(Hailstone.init)
print(thrownStone.position.components.sum())

// verify
for hailstone in hailstones {
	let intersection = thrownStone.xyIntersection(with: hailstone)!
	assert(intersection.ta == intersection.tb)
}

