import Foundation

enum Day17 {
  struct State: Equatable {
    let a: Int
    let b: Int
    let c: Int
    let ip: Int
    
    subscript(_ idx: Int) -> Int {
      switch idx {
        case 0: a
        case 1: b
        case 2: c
        default: ip
      }
    }
  }

  static func combo(_ s: State, _ c: Int) -> Int {
    if c > 6 {
      print("Bad combo value \(c)")
      return 0
    }
    if c < 4 {
      return c
    }
    return s[c - 4]
  }
  
  static func dv(_ reg: Int, _ cb: Int)-> Int {
    let num = Double(reg)
    let den = pow(2.0, Double(cb))
    return Int(trunc(num/den))
  }

  static func adv(_ s: State, _ op: Int) -> (State, Int?) {
    let r = dv(s.a, combo(s, op))
    return (State(a: r, b: s.b, c: s.c, ip: s.ip+2), nil)
  }
  
  static func bxl(_ s: State, _ op: Int) -> (State, Int?) {
    (State(a: s.a, b: s.b ^ op, c: s.c, ip: s.ip+2), nil)
  }

  static func bst(_ s: State, _ op: Int) -> (State, Int?) {
    (State(a: s.a, b: combo(s, op) % 8, c: s.c, ip: s.ip+2), nil)
  }

  static func jnz(_ s: State, _ op: Int) -> (State, Int?) {
    s.a == 0 ? (State(a: s.a, b: s.b, c: s.c, ip: s.ip+2), nil) :
    (State(a: s.a, b: s.b, c: s.c, ip: op), nil)
  }

  static func bxc(_ s: State, _ _: Int) -> (State, Int?) {
    (State(a: s.a, b: s.b ^ s.c, c: s.c, ip: s.ip+2), nil)
  }

  static func out(_ s: State, _ op: Int) -> (State, Int?) {
    (State(a: s.a, b: s.b, c: s.c, ip: s.ip+2), combo(s, op) % 8)
  }

  static func bdv(_ s: State, _ op: Int) -> (State, Int?) {
    let r = dv(s.a, combo(s, op))
    return (State(a: s.a, b: r, c: s.c, ip: s.ip+2), nil)
  }

  static func cdv(_ s: State, _ op: Int) -> (State, Int?) {
    let r = dv(s.a, combo(s, op))
    return (State(a: s.a, b: s.b, c: r, ip: s.ip+2), nil)
  }

  static let names = ["adv", "bxl","bst","jnz","bxc","out","bdv","cdv"]
  static func opname(_ op: Int)->String {
    return names[op]
  }
  
  static func runProgram(opcodes: [Int:(State, Int)->(State,Int?)], _ s: State, _ ins: [Int], _ out: (Int)->Void) -> State {
    var s = s
    while s.ip < ins.count {
      let opcode = ins[s.ip]
      let operand = ins[s.ip+1]
      guard let op = opcodes[opcode] else {
        fatalError("unknown op for \(opcode)")
      }
      let (ns, output) = op(s, operand)
      if let output {
        out(output)
      }
      //print("\(opname(opcode)):\(operand) \(s)->\(ns) \(output ?? -1)")
      if s == ns {
        fatalError("State didn't change")
      }
      s = ns
    }
    return s
  }


  static func disassemble(opcodes: [Int:(State, Int)->(State,Int?)], _ ins: [Int]) -> [String] {
    ins.chunks(ofCount: 2).map {
      let ins = Array($0)
      return "\(opname(ins[0])): \(ins[1])"
    }
  }

  public static func part1(input: String) -> String {
    let parts = input.split(separator: "\n\n")
    let registers = String(parts[0]).lines.map { $0.split(separator: ": ").last! }.map { Int($0)! }
    let program = String(parts[1]).trimmed
      .split(separator: ": ").last!
      .split(separator:  ",")
      .map { Int($0)! }
    let opcodes: [Int:(State, Int)->(State,Int?)] = [
      0: adv,
      1: bxl,
      2: bst,
      3: jnz,
      4: bxc,
      5: out,
      6: bdv,
      7: cdv
    ]
    

    print("registers \(registers)")
    print("program \(program)")
    for l in disassemble(opcodes:opcodes, program) {
      print(l)
    }

    var output: [Int] = []
    let initState = State(a: registers[0], b: registers[1], c: registers[2], ip: 0)
    let outState = runProgram(opcodes: opcodes, initState, program) { out in
      output.append(out)
    }
    print("final state: \(outState)")

    return output.map(String.init).joined(separator: ",")
  }

  public static func part2(input: String) -> Int {
    let parts = input.split(separator: "\n\n")
    let registers = String(parts[0]).lines.map { $0.split(separator: ": ").last! }.map { Int($0)! }
    let program = String(parts[1]).trimmed
      .split(separator: ": ").last!
      .split(separator:  ",")
      .map { Int($0)! }
    let opcodes: [Int:(State, Int)->(State,Int?)] = [
      0: adv,
      1: bxl,
      2: bst,
      3: jnz,
      4: bxc,
      5: out,
      6: bdv,
      7: cdv
    ]
    

    print("registers \(registers)")
    print("program \(program)")
    for l in disassemble(opcodes:opcodes, program) {
      print(l)
    }
    
    func testWith(_ a: Int) -> [Int] {
      var output: [Int] = []
      let initState = State(a: a, b: registers[1], c: registers[2], ip: 0)
      _ = runProgram(opcodes: opcodes, initState, program) { out in
        output.append(out)
      }
      return output
    }

    // inputs that produce the first output
    let tests = program.count
    for a in stride(from: 7230976000, to: 100000000000, by: 8) {
      var input = a
      for t in 1...tests {
          input = input * 8
          //print("trying with \(a) -> \(input)")
          let test = testWith(input)
          if test.suffix(t) == program.suffix(t) {
            if t > 2 {
              print("success \(t) at \(input)!", terminator: " ")
            }
            if t == program.count {
              print("found it!")
              return input
            }
          } else {
            if (t > 3) {
              print("fail")
            }
            break
          }
      }
      /*
      if testWith(a).suffix(1) == program.suffix(1) {
        let input = a * 8
        print("trying with \(a) -> \(input)")
        let test = testWith(input)
        if test.suffix(2) == program.suffix(2) {
          let input = a * 8
          print("trying with \(a) -> \(input)")
          let test = testWith(input)
          if test.suffix(3) == program.suffix(3) {
            print("Success!")
            return input
          }
        }
      }
      */
    }

    //let testProgram = Array(program.dropLast(2))
/*
    repeat {
      s = s + 1
      a = s
      repeat {
        a *= 8
        cnt += 1
        output = []
        let initState = State(a: a, b: registers[1], c: registers[2], ip: 0)
        _ = runProgram(opcodes: opcodes, initState, program) { out in
          output.append(out)
        }
        print(a, output)
        if output == expected {
          print("found it at \(a)")
        }
      } while output != expected && output.count < expected.count
    } while s < 1000000
    

    return a
    */
    return 0
  }
}
