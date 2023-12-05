import Foundation
import AoC_Helpers

typealias Range = Swift.Range<Int>

struct MappingRange {
	var src, dst: Range
	var offset: Int
	
	init(dstStart: Int, srcStart: Int, count: Int) {
		self.src = srcStart ..< srcStart + count
		self.dst = dstStart ..< dstStart + count
		self.offset = dstStart - srcStart
	}
	
	init(identityRange: Range) {
		self.src = identityRange
		self.dst = identityRange
		self.offset = 0
	}
	
	func destination(for source: Int) -> Int? {
		src.contains(source) ? source + offset : nil
	}
	
	func destinations(for sources: Range) -> Range? {
		sources.intersection(with: src).map {
			$0.lowerBound + offset ..< $0.upperBound + offset
		}
	}
}

struct Mapping {
	var ranges: [MappingRange]
	
	init(explicitRanges: [MappingRange]) {
		self.ranges = []
		ranges.reserveCapacity(explicitRanges.count)
		var start = Int.min
		for explicitRange in explicitRanges.sorted(on: \.src.lowerBound) {
			let next = explicitRange.src.lowerBound
			if start < next {
				ranges.append(.init(identityRange: start..<next))
			}
			ranges.append(explicitRange)
			start = explicitRange.src.upperBound
		}
		ranges.append(.init(identityRange: start ..< .max))
	}
	
	func destination(for source: Int) -> Int {
		//ranges.lazy.compactMap { $0.destination(for: source) }.onlyElement()!
		// binary search because why not
		let rangeIndex = ranges.partitioningIndex { source < $0.src.upperBound }
		return source + ranges[rangeIndex].offset
	}
	
	func destinations(for sources: Range) -> some Collection<Range> {
		ranges.lazy.compactMap { $0.destinations(for: sources) }
	}
}

let (seedInput, mappingInputs) = input().lineGroups().chop()!
let seeds = seedInput.onlyElement()!.ints()
let mappings = mappingInputs.map {
	Mapping(explicitRanges: $0.dropFirst().map {
		$0.ints().splat(MappingRange.init)
	})
}

let locations = seeds.map { seed in
	mappings.reduce(seed) { $1.destination(for: $0) }
}

print(locations.min()!)

let seedRanges = seeds.chunks(ofCount: 2).map { $0.splat { $0 ..< $0 + $1 } }
let locationRanges = mappings.reduce(seedRanges) { ranges, mapping in
	ranges.flatMap { mapping.destinations(for: $0) }
}
print(locationRanges.lazy.map(\.lowerBound).min()!)
