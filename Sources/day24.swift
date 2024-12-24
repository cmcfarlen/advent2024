enum Day24 {
  enum Op: String, CaseIterable {
    case and = "AND"
    case or = "OR"
    case xor = "XOR"

    func eval(a: Int, b: Int) -> Int {
      switch self {
        case .and:
          a & b != 0 ? 1 : 0
        case .or:
          a | b != 0 ? 1 : 0
        case .xor:
          a ^ b != 0 ? 1 : 0
      }
    }
  }

  class Wire {
    let name: String
    var value: Int?

    init(name: String, value: Int? = nil) {
      self.name = name
      self.value = value
    }

    var isSet: Bool {
      value != nil
    }
  }

  class Gate {
    let a: Wire
    let b: Wire
    let out: Wire
    let op: Op

    init(a: Wire, b: Wire, out: Wire, op: Op) {
      self.a = a
      self.b = b
      self.out = out
      self.op = op
    }

    var isFired: Bool {
      out.value != nil
    }
    var isReady: Bool {
      a.isSet && b.isSet && !isFired
    }

    func fire() -> Bool {
      guard isReady else {
        return false
      }
      out.value = op.eval(a: a.value!, b: b.value!)
      return true
    }
  }

  struct Circuit {
    var wires: [String: Wire] = [:]
    var gates: [Gate] = []

    var isComplete: Bool {
      zWires.allSatisfy(\.isSet)
    }

    var zWires: [Wire] {
      wires.values.filter { $0.name.starts(with: "z") }
    }

    var value: Int {
      let bits = zWires.sorted { $0.name > $1.name }.map(\.value)
      return bits.reduce(0) { v, bit in
        (v << 1) | bit!
      }
    }

    mutating func wire(_ name: String, value: Int? = nil) -> Wire {
      if let w = wires[name] {
        return w
      } else {
        let w = Wire(name: name, value: value)
        wires[name] = w
        return w
      }
    }

    mutating func addGate(from s: String) -> Gate {
      let parts = s.split(separator: " -> ")
      let expr = parts[0].split(separator: " ").map(String.init)

      let gate = Gate(a: wire(expr[0]), b: wire(expr[2]), out: wire(String(parts[1])), op: Op(rawValue: expr[1])!)
      gates.append(gate)
      return gate
    }

    mutating func step() {
      for g in gates {
        if g.isReady {
          _ = g.fire()
        }
      }
    }

    mutating func run() -> Int {
      while !isComplete {
        step()
      }
      return value
    }
  }

  static func part1(input: String) -> Int {
    let parts = input.split(separator: "\n\n").map(String.init)
    let inputs = parts[0]
      .lines
      .map { $0.split(separator: ": ") }
      .map { (String($0[0]), Int($0[1])!) }
    var circuit = Circuit()

    circuit = inputs.reduce(into: circuit) { c, parts in
      _ = c.wire(parts.0, value: parts.1)
    }
    circuit = parts[1].lines.reduce(into: circuit) { c, expr in
      _ = c.addGate(from: expr)
    }

    return circuit.run()
  }
}
