import Collections

enum Day16 {
  enum Facing: Hashable, CaseIterable {
    case north
    case east
    case south
    case west

    func turns(to f: Facing) -> Int {
      switch self {
        case .north:
          switch f {
            case .north: 0
            case .east: 1
            case .south: 2
            case .west: 1
          }
        case .east:
          switch f {
            case .north: 1
            case .east: 0
            case .south: 1
            case .west: 2
          }
        case .south:
          switch f {
            case .north: 2
            case .east: 1
            case .south: 0
            case .west: 1
          }
        case .west:
          switch f {
            case .north: 1
            case .east: 2
            case .south: 1
            case .west: 0
          }
      }
    }
    
    var left: Facing {
      switch self {
        case .north:
          .west
        case .west:
          .south
        case .south:
          .east
        case .east:
          .north
      }
    }

    var right: Facing {
      switch self {
        case .north:
          .east
        case .east:
          .south
        case .south:
          .west
        case .west:
          .north
      }
    }
    
    var step: Coordinate {
      switch self {
        case .north:
          [0, -1]
        case .east:
          [1, 0]
        case .south:
          [0, 1]
        case .west:
          [-1, 0]
      }
    }

    var symbol: Character {
      switch self {
        case .north:
          "^"
        case .east:
          ">"
        case .south:
          "v"
        case .west:
          "<"
      }
    }

    static func directions(from f: Coordinate, to t: Coordinate) -> (ew: Facing?,ns: Facing?) {
      directions(delta: t - f)
    }
    static func directions(delta dp: Coordinate) -> (ew: Facing?,ns: Facing?) {
      let ew: Facing? = dp.x == 0 ? nil : dp.x > 0 ? .east : .west
      let ns: Facing? = dp.y == 0 ? nil : dp.y > 0 ? .south : .north
      return (ew: ew, ns: ns)
    }
  }

  struct Position: Hashable, Comparable, GridNavigable {
    let p: Coordinate
    let f: Facing
    
    public static func <(_ lhs: Position, _ rhs: Position) -> Bool {
      lhs.p < rhs.p
    }

    var left: Position {
      let nf = f.left
      return Position(p: p + nf.step, f: nf)
    }

    var right: Position {
      let nf = f.right
      return Position(p: p + nf.step, f: nf)
    }

    var ahead: Position {
      return Position(p: p + f.step, f: f)
    }

    var position: Coordinate { p }
    var neighbors: [Position] {
      [ahead, left, right]
    }
  }
  
  public static func scorePath(_ path: [Position], d: (Position, Position) -> Int) -> Int {
    return path.windows(ofCount: 2)
       .map { w in
       let w = Array(w)
       return w.count == 2 ? d(w[0], w[1]) : 0 }
       .sum()
  }

  public static func part1(input: String) -> Int {
    let grid = input.grid
    let startP = grid.coords.first { grid[$0] == "S" }!
    let endP = grid.coords.first { grid[$0] == "E" }!
    let p = Position(p: startP, f: .east)
    
    // assum p1 is adjacent to p2
    func d(_ p1: Position, _ p2: Position) -> Int {
      if grid[p2.p] == "#" {
        return Int.max
      }
      return 1 + p1.f.turns(to: p2.f) * 1000
    }

    func h(_ p: Position) -> Int {
      // cheapest is to go straight or turn only once
      let dp = endP - p.p
      let (ew, ns) = Facing.directions(delta: dp)
      var cost = 0
      if dp != Coordinate.origin {
        if let ns {
          cost = cost + abs(dp.y) + p.f.turns(to: ns) * 1000
        }
        if let ew {
          cost = cost + abs(dp.x) + p.f.turns(to: ew) * 1000
        }
      }
      return cost
    }
    
    guard let path = astar(startP: p, endP: endP, h: h, d: d) else {
      print("Failed")
      return 0
    }
    var outgrid = grid
    for p in path {
      outgrid[p.p] = p.f.symbol
    }
    print(outgrid.display)

    return scorePath(path, d: d)
  }

  public static func part2(input: String) -> Int {
    let bestScore = part1(input: input)
    let grid = input.grid
    let startP = grid.coords.first { grid[$0] == "S" }!
    let endP = grid.coords.first { grid[$0] == "E" }!
    let p = Position(p: startP, f: .east)

    func d(_ p1: Position, _ p2: Position) -> Int {
      if grid[p2.p] == "#" {
        return Int.max
      }
      return 1 + p1.f.turns(to: p2.f) * 1000
    }

    let (_, prev) = dijkstra(startP: p, d: d)

    var followed: Set<Coordinate> = []

    // dfs to end
    func allPaths(to: [Position], _ f: ([Position])->Void) {
      if let s = prev[to.last!] {
        for p in s {
          allPaths(to: to + [p], f)
        }
      } else {
        f(to)
      }
    }

    let ends = Facing.allCases
      .map { Position(p: endP, f: $0) }

    for e in ends {
      allPaths(to: [e]) {
        let score = scorePath($0, d: d)
        if score == bestScore {
          print("path: \($0)")
          for p in $0 {
            followed.insert(p.p)
          }

        }
      }
    }

    
    var outgrid = grid
    for p in followed {
      outgrid[p] = "O"
    }
    print(outgrid.display)

    return followed.count
  }
}

extension Day16.Position: CustomStringConvertible {
  var description: String {
    "(\(p)\(f.symbol))"
  }
}
