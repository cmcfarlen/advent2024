enum Day21 {
  enum Dir {
    case left
    case up
    case right
    case down

    var offset: Coordinate {
      switch self {
        case .left: [-1,0]
        case .up: [0, -1]
        case .right: [1, 0]
        case .down: [0, 1]
      }
    }

    var symbol: String {
      switch self {
        case .left: "<"
        case .up: "^"
        case .right: ">"
        case .down: "v"
      }
    }

    static func dirFor(_ delta: Coordinate) -> Dir? {
      if delta.x < 0 {
        return .right
      } else if delta.x > 0 {
        return .left
      } else if delta.y < 0 {
        return .down
      } else if delta.y > 0 {
        return .up
      }
      return nil
    }
  }

  struct Robot {
    let keys: [[Character]]
    let gap: Coordinate
    var p: Coordinate 

    init(keys: [[Character]]) {
      self.keys = keys
      self.gap = keys.coords.first { keys[$0] == " " }!
      self.p = keys.coords.first { keys[$0] == "A" }!
    }

    func position(key: Character) -> Coordinate {
      keys.coords.first { keys[$0] == key }!
    }

    // mind the gap
    // if the destination's y is the gaps y and the source x is the gap's x
    // go the other direction first (up/down or left/right)
    func safeMoves(to dest: Coordinate) -> [Coordinate] {
      let delta = p - dest
      let (hor, vert): (Coordinate, Coordinate) = ([delta.x, 0], [0, delta.y])
      if dest.x == gap.x && p.y == gap.y {
        return [vert, hor]
      }
      return [hor, vert]
    }

    mutating func move(to key: Character) -> [Dir] {
      let dest = position(key: key)
      var result: [Dir] = []

      // hor then vert or vert then hor
      for var delta in safeMoves(to: dest) {
        while let d = Dir.dirFor(delta) {
          p = p + d.offset
          assert(p != gap, "Positioned over gap!")
          result.append(d)

          delta = delta + d.offset
        }
      }

      return result
    }

    mutating func output(sequence: String) -> [[Dir]] {
      var result: [[Dir]] = []
      for k in sequence {
        result.append(move(to: k))
      }
      return result
    }
  }

  static let numeric =
  """
  789
  456
  123
   0A
  """.grid
  static let directional = 
  """
   ^A
  <v>
  """.grid

  static func part1(input: String) -> Int {
    let codes = input.lines
    var bots = [
      numeric,
      directional,
      directional,
    ].map(Robot.init)

    func numericPart(of code: String) -> Int {
      Int(code.drop { $0 == "0" }.dropLast())!
    }

    func solve(for code: String) -> Int {
      var sequence = code
      for idx in bots.indices {
        sequence = String(bots[idx].output(sequence: sequence)
          .map {
            $0.map(\.symbol).joined()
          }
          .joined(by: "A"))
          .appending("A")
      }
      print("\(code): \(sequence) len \(sequence.count)")

      return sequence.count
    }

    func debug(for code: String) -> Int {
      var botSeq: [[(String, Character)]] = Array(repeatElement([], count: bots.count))
      for l in code {
        var sequence = String(l)
        for idx in bots.indices {
          sequence = String(bots[idx].output(sequence: sequence)
            .map {
              $0.map(\.symbol).joined()
            }
            .joined(by: "A"))
            .appending("A")
          botSeq[idx].append((sequence, bots[idx].keys[bots[idx].p]))
        }
      }

      for botOutput in botSeq {
        for out in botOutput {
          print(out.0.padding(toLength: 20, withPad: " ", startingAt: 0), out.1, terminator: ",")
        }
        print("")
      }

      return 0
    }

    func complexity(for code: String) -> Int {
      numericPart(of: code) * solve(for: code)
    }

    debug(for: "379A")

    return codes.map(complexity).sum()
  }
}
