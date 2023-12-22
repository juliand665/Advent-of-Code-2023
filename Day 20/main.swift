import Foundation
import AoC_Helpers
import HandyOperators

enum Pulse: Int, Hashable, CustomStringConvertible {
	case low, high
	
	func toggled() -> Self {
		self == .low ? .high : .low
	}
	
	var description: String {
		self == .low ? "_" : "#"
	}
}

struct Module {
	var id: Int
	var kind: Kind
	var receivers: [Int]
	
	func reaction(to input: Pulse, lastPulse: [Pulse]) -> Pulse? {
		switch kind {
		case .broadcaster:
			input
		case .flipFlop:
			switch input {
			case .low:
				lastPulse[id].toggled()
			case .high:
				nil
			}
		case .conjunction:
			senders[id].allSatisfy { lastPulse[$0] == .high } ? .low : .high
		}
	}
	
	enum Kind: Hashable {
		case broadcaster
		case flipFlop
		case conjunction
	}
}

extension Module {
	init(_ description: some StringProtocol) {
		let (identity, receiverList) = description.split(separator: " -> ", omittingEmptySubsequences: false).extract()
		
		self.kind = switch identity.first! {
		case "%": .flipFlop
		case "&": .conjunction
		default: .broadcaster
		}
		
		self.id = getID(kind == .broadcaster ? identity : identity.dropFirst())
		self.receivers = receiverList.split(separator: ", ").map(getID)
	}
}

let broadcaster = getID("broadcaster")
let sendingModules = Dictionary(
	values: input().lines().lazy.map(Module.init),
	keyedBy: \.id
)
let modules: [Module] = rawIDs.indices.map {
	sendingModules[$0] ?? Module(id: $0, kind: .broadcaster, receivers: [])
}

let senders: [[Int]] = modules.reduce(
	into: Array(repeating: [], count: modules.count)
) { senders, module in
	for receiver in module.receivers {
		senders[receiver].append(module.id)
	}
}

struct State {
	var lastPulse: [Pulse] = modules.map { _ in .low }
	
	/// - returns: pulses sent by type
	@discardableResult
	mutating func pushButton() -> [Int] {
		var pulsesSent = [0, 0]
		var toSend: [(Int, Pulse)] = [(broadcaster, .low)]
		while !toSend.isEmpty {
			toSend = toSend.flatMap { receiver, pulse in
				pulsesSent[pulse.rawValue] += 1
				let module = modules[receiver]
				if let next = module.reaction(to: pulse, lastPulse: lastPulse) {
					lastPulse[receiver] = next
					return module.receivers.map { ($0, next) }
				} else {
					return []
				}
			}
		}
		return pulsesSent
	}
}

let pulsesSent = [0, 0] <- { pulsesSent in
	var state = State()
	for _ in 1...1000 {
		pulsesSent = zip(pulsesSent, state.pushButton()).map(+)
		//print(pulsesSent)
		//print(lastPulse.map(String.init).joined())
		//print(zip(rawIDs, lastPulse).lazy.map { "\($0): \($1)" }.joined(separator: " // "))
	}
}
print(pulsesSent.product())

func dependencies(of module: Int) -> Set<Int> {
	[] <- { dependencies in
		var candidates = senders[module]
		while let next = candidates.popLast() {
			guard dependencies.insert(next).inserted else { continue }
			candidates += senders[next]
		}
	}
}

// this computes the periods twice for each group due to the way the input is constructed, but ehh
let deps = modules.indices.map(dependencies(of:))
var periodSizes: [Int: Int] = [:]
for module in modules.indices.sorted(on: { deps[$0].count }) {
	guard periodSizes[module] == nil else { continue }
	
	let group = deps[module].sorted()
	// dirty but it works for the way this input is constructed
	guard group.count < 20 else { break }
	
	let states = sequence(state: State()) { state in
		state.pushButton()
		return group.map { state.lastPulse[$0] }
	}
	let rep = Cycled.representation(of: states)
	for member in group {
		periodSizes[member] = rep.period
	}
}

// this is just the right answer instantly because we're looking for when rx gets a low pulse, meaning it's gone through an entire period
print(Set(periodSizes.values).reduce(1, lcm))
