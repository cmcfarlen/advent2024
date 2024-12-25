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

    func swapInputs() -> Gate {
      Gate(a: b, b: a, out: out, op: op)
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
      wireValue(wire: "z")
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

    func gate(withOutput: String) -> Gate? {
      gates.first { $0.out.name == withOutput }
    }
    func gate(withInput: String) -> Gate? {
      gates.first { $0.a.name == withInput || $0.b.name == withInput }
    }

    mutating func swapOutputs(a: String, b: String) {
      let aIdx = gates.firstIndex { $0.out.name == a }!
      let bIdx = gates.firstIndex { $0.out.name == b }!

      let newA = Gate(a: gates[aIdx].a, b: gates[aIdx].b, out: gates[bIdx].out, op: gates[aIdx].op)
      let newB = Gate(a: gates[bIdx].a, b: gates[bIdx].b, out: gates[aIdx].out, op: gates[bIdx].op)
      gates[aIdx] = newA
      gates[bIdx] = newB
    }

    mutating func step() -> Int {
      var fireCount = 0
      for g in gates {
        if g.isReady {
          _ = g.fire()
          fireCount += 1
        }
      }
      return fireCount
    }

    mutating func run() -> Int {
      var iter = 0
      while !isComplete {
        if step() == 0 {
          /*
          print("No progress after \(iter)")
          for g in gates {
            if !g.isFired {
              print("Gate \(g) did not fire")
            }
          }
          */
          return 0
        }
        iter += 1
      }
      return value
    }

    func wireValue(wire: String) -> Int {
      let ws = wires.values.filter { $0.name.starts(with: wire) }
      let bits = ws.sorted { $0.name > $1.name }.map(\.value)
      return bits.reduce(0) { v, bit in
        (v << 1) | bit!
      }
    }

    func node(forOutput: String) -> GateNode {
      GateNode(
        circuit: self,
        gate: gate(withOutput: forOutput)!
      )
    }
  }

  struct GateNode {
    let circuit: Circuit
    let gate: Gate

    var parent: GateNode {
      GateNode(
        circuit: circuit,
        gate: circuit.gate(withInput: gate.out.name)!
      )
    }
    var children: [GateNode]? {
      guard let a = circuit.gate(withOutput: gate.a.name),
            let b = circuit.gate(withOutput: gate.b.name) else {
        return nil
      }
      return [
        GateNode(
          circuit: circuit,
          gate: a
        ),
        GateNode(
          circuit: circuit,
          gate: b
        )
      ]
    }

    var allNodes: [GateNode] {
      guard let kids = children else {
        return [self]
      }
      return kids[0].allNodes + [self] + kids[1].allNodes
    }
  }

  static func buildCircuit(input: String) -> Circuit {
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

    return circuit
  }

  static func part1(input: String) -> Int {
    var circuit = buildCircuit(input: input)
    return circuit.run()
  }

  static func bin(_ x: Int) -> String {
    let s = String(x, radix: 2)
    let pad = String(repeating: "0", count: 64-s.count)
    return pad + s
  }

  static func incorrectBits(a: Int, b: Int) -> [Int] {
    var result: [Int] = []
    for i in 0..<64 {
      let m = 1 << i
      if (a & m) != (b & m) {
        result.append(i)
      }
    }
    return result
  }

  static func incorrectMask(bits: [Int]) -> Int {
    var x = 0
    for b in bits {
      x |= 1 << b
    }
    return x
  }

  static func commonBits(_ a: Int, _ b: Int) -> Int {
    var result = 0
    for i in 0..<64 {
      let m = 1 << i
      if (a & m) == (b & m) {
        result += 1
      } else {
        break
      }
    }
    return result
  }

  static func part2(input: String) -> String {
    let circuit = buildCircuit(input: input)

    func test(swapping: [Set<String>] = []) -> Int {
      var t = buildCircuit(input: input)

      for s in swapping {
        t.swapOutputs(a: s.first!, b: s.second!)
      }

      return t.run()
    }

    let x = circuit.wireValue(wire: "x")
    let y = circuit.wireValue(wire: "y")
    let ogZ = test()
    let ngZ = test(swapping: [["z00","z01"]])

    assert(ogZ != ngZ, "\(ogZ) != \(ngZ)")

    let verify = test(swapping: [["cpr", "grr"], ["ccw", "tjk"]])
    assert(verify == (x + y))

    //let calcZ = x + y

    func fixBits() {
      var verified: [Set<String>] = []
      var badPairs: Set<Set<String>> = []
      let correctZ = x + y
      var lastZ = test()
      var lastCommon = commonBits(lastZ, correctZ)
      while lastZ != correctZ {
        print("Recalculating incorrectBits")
        let badbits = incorrectBits(a: lastZ, b: correctZ)
        outer: for bit in badbits {
          let outputs = circuit
            .node(forOutput: "z\(bit)")
            .allNodes
            .map(\.gate.out.name)
            .reduce(into: Set<String>()) { $0.insert($1) }
          let pairs = Array(
            Array(outputs)
              .combinations(ofCount: 2)
              .map { [$0[0], $0[1]] as Set<String> }
          )

          print("Fixing bit \(bit) \(pairs.count) pairs")
          for i in 1...(4-verified.count) {
            print("Trying \(i) size combinations")
            print("corrZ: \(bin(correctZ))")
            print("lastZ: \(bin(lastZ))")
            print("maskZ: \(bin(incorrectMask(bits: badbits)))")
            for combo in pairs.combinations(ofCount: i) {
              let testZ = test(swapping: combo + verified)
              if testZ != 0 {
                let newBits = incorrectBits(a: testZ, b: lastZ)
                //print("corrZ: \(bin(correctZ))")
                //print("lastZ: \(bin(lastZ))")
                print("testZ: \(bin(testZ))", terminator: "\r")
                let newCommon = commonBits(testZ, correctZ)
                if newCommon > lastCommon {
                  verified.append(contentsOf: combo)
                  print("combo \(combo) fixes bit \(bit) \(verified)!")
                  lastZ = testZ
                  lastCommon = newCommon
                  break outer
                }
              } else {
                //print("Combo failed \(combo)")
              }
            }
          }
        }
      }
      let badbits = incorrectBits(a: lastZ, b: correctZ)
      print("Finished correcting with \(verified): \(bin(incorrectMask(bits: badbits)))")
    }

    fixBits()

/*
    let correctZ = x + y
    let failZ = test()

    print("x=\(bin(x)) y=\(bin(y))")
    print("corrZ=\(bin(correctZ))")
    print("failZ=\(bin(failZ))")

    let badbits = incorrectBits(a: failZ, b: correctZ)
    let commonNodes = badbits.map {
      circuit.node(forOutput: "z\($0)")
    }
    .flatMap(\.allNodes)
    .map(\.gate.out.name)
    .reduce(into: Set<String>()) { s, a in
      s.insert(a)
    }
    let pairs = Array(Array(commonNodes).combinations(ofCount: 2).map { ($0[0], $0[1]) })


    print("Common nodes for bad bits: \(commonNodes.count)")
    print("Number of pairs: \(pairs.count)")

    let perms = pairs
      .combinations(ofCount: 4)
    print("number of permutations: \(perms.count)")

    let permCount = perms.count
    let answer = perms
      .enumerated()
      .first { idx, v in
        if idx % 1000 == 0 {
          print("\(Double(idx)/Double(permCount))% done                           ", terminator: "\r")
        }
        let newZ = test(swapping: v)
        let bb = incorrectBits(a: newZ, b: correctZ)
        if !bb.isEmpty {
          if bb.first! > badbits.first! {
            print("\(v) fixed the first bit!")
          }
        }
        if bb.count < badbits.count {
          print("\(v) did better \(bb.count) vs \(badbits.count) \(correctZ) \(newZ)")
        }

        return newZ == correctZ
      }
    guard let answer else {
      fatalError("Failed to find answer")
    }
    print("Answer is \(answer) ")
    */
    
    return ""
  }
}

extension Day24.Gate: CustomStringConvertible {
  var description: String {
    "(\(a.name) \(op.rawValue) \(b.name))"
  }
}

extension Day24.GateNode: CustomStringConvertible {
  var description: String {
    guard let kids = children else {
      return gate.description
    }
    return "(\(kids[0]) \(gate.op.rawValue) \(kids[1]))"
  }
}
