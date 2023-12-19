import Foundation
import AoC_Helpers
import RegexBuilder
import HandyOperators

let rangeMin = 1
let rangeMax = 4001

enum Component: Character, CaseIterable {
	case x = "x"
	case m = "m"
	case a = "a"
	case s = "s"
}

struct Part {
	var components: [Component: Int]
	
	var sum: Int { 
		components.values.sum()
	}
}

struct PartRange {
	static let full = Self(components: .init(
		uniqueKeysWithValues: Component.allCases.map { ($0, rangeMin..<rangeMax) }
	))
	static let empty = Self(components: [:])
	
	var components: [Component: Range<Int>]
	
	var count: Int {
		components.values.lazy.map(\.count).product()
	}
	
	var isEmpty: Bool {
		components.isEmpty || components.values.contains(where: \.isEmpty)
	}
	
	func limiting(_ component: Component, to range: Range<Int>) -> Self {
		self <- {
			$0.components[component] = $0.components[component]!.intersection(with: range)
		}
	}
}

struct Workflow {
	var id: String
	var rules: [Rule]
}

struct Rule {
	var condition: Condition?
	var outcome: Outcome
	
	enum Outcome {
		case decision(Bool)
		case jump(String)
	}
	
	func applies(to part: Part) -> Bool {
		condition?.accepts(part) != false
	}
	
	struct Condition {
		var component: Component
		var acceptedRange: Range<Int>
		var rejectedRange: Range<Int>
		
		func accepts(_ part: Part) -> Bool {
			acceptedRange.contains(part.components[component]!)
		}
	}
}

// turns out regex building takes quite a lot of space, but i wanted to give it a try lol

extension Workflow {
	init(from description: Substring) {
		let regex = Regex {
			Capture(/\w+/) { String($0) }
			"{"
			Capture(/[^}]+/) {
				$0.split(separator: ",").map(Rule.init)
			}
			"}"
		}
		
		(_, id, rules) = try! regex.wholeMatch(in: description)!.output
	}
}

extension Rule {
	init(from description: Substring) {
		let regex = Regex {
			Optionally(.reluctant) {
				Capture(/[xmas<>0-9]+/, transform: Condition.init)
				":"
			}
			
			Capture(/\w+/) {
				switch $0 {
				case "A": Outcome.decision(true)
				case "R": Outcome.decision(false)
				case let next: Outcome.jump(String(next))
				}
			}
		}
		
		(_, condition, outcome) = try! regex.wholeMatch(in: description)!.output
	}
}

extension Rule.Condition {
	init(from description: Substring) {
		let regex = Regex {
			Capture(/[xmas]/) {
				Component(rawValue: $0.first!)!
			}
			
			Capture(/[<>]/) {
				$0 == ">"
			}
			
			Capture(/\d+/) {
				Int($0)!
			}
		}
		
		let (_, component, isGreaterThan, reference) = try! regex.wholeMatch(in: description)!.output
		
		self.component = component
		self.acceptedRange = isGreaterThan ? reference + 1 ..< rangeMax : rangeMin ..< reference
		self.rejectedRange = isGreaterThan ? rangeMin ..< reference + 1 : reference ..< rangeMax
	}
}

let (rawWorkflows, rawParts) = input().lineGroups().extract()
let parts = rawParts.map {
	Part(components: .init(
		uniqueKeysWithValues: zip(Component.allCases, $0.ints())
	))
}
let workflows = Dictionary(values: rawWorkflows.lazy.map(Workflow.init), keyedBy: \.id)

// part 1

extension Workflow {
	func accepts(_ part: Part) -> Bool {
		let outcome = rules.first { $0.applies(to: part) }!.outcome
		switch outcome {
		case .decision(let didAccept):
			return didAccept
		case .jump(let other):
			return workflows[other]!.accepts(part)
		}
	}
}

let inWorkflow = workflows["in"]!
print(parts.lazy.filter(inWorkflow.accepts(_:)).map(\.sum).sum())

// part 2

extension Rule.Outcome {
	func acceptedParts(from range: PartRange) -> Int {
		switch self {
		case .decision(let didAccept):
			didAccept ? range.count : 0
		case .jump(let workflow):
			workflows[workflow]!.acceptedParts(from: range)
		}
	}
}

extension Workflow {
	func acceptedParts(from range: PartRange) -> Int {
		var acceptedCount = 0
		var remaining = range
		for rule in rules {
			let accepted = rule.condition.map {
				remaining.limiting($0.component, to: $0.acceptedRange)
			} ?? remaining
			remaining = rule.condition.map {
				remaining.limiting($0.component, to: $0.rejectedRange)
			} ?? .empty
			
			acceptedCount += rule.outcome.acceptedParts(from: accepted)
			
			guard !remaining.isEmpty else { break }
		}
		assert(remaining.isEmpty)
		return acceptedCount
	}
}

print(inWorkflow.acceptedParts(from: .full))
