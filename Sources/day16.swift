import Collections

enum Day16 {
  enum Facing: Hashable {
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

  struct Position: Hashable, Comparable {
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

    var neighbors: [Position] {
      [ahead, left, right]
    }
  }
  
  public static func reconstruct(_ cameFrom: [Position:Position], _ to: Position) -> [Position] {
    var path: [Position] = [to]
    var current = to
    while let n = cameFrom[current] {
      current = n
      path.append(n)
    }
    return path
  }
  
  struct Scored<T: Equatable>: Equatable, Comparable {
    let wrapped: T
    let score: Int

    public static func <(_ lhs: Scored<T>, _ rhs: Scored<T>) -> Bool {
      lhs.score < rhs.score
    }

    public static func ==(_ lhs: Scored<T>, _ rhs: Scored<T>) -> Bool {
      lhs.score == rhs.score && lhs.wrapped == rhs.wrapped
    }

    init(_ t: T, _ score: Int) {
      wrapped = t
      self.score = score
    }
  }

  // astar from https://en.wikipedia.org/wiki/A*_search_algorithm
  public static func astar(startP: Position, endP: Coordinate, h: (Position)->Int, d: (Position, Position) -> Int) -> [Position]? {
    var open: Heap<Scored<Position>> = []
    var gScore: [Position:Int] = [:]
    var cameFrom: [Position:Position] = [:]

    gScore[startP] = 0
    open.insert(Scored(startP, h(startP)))
    
    while !open.isEmpty {
      guard let currentMin = open.popMin() else {
        print("Ran out of options before end")
        return nil
      }
      let current = currentMin.wrapped
      if current.p == endP {
        print("gScore: \(gScore)")
        print("cameFrom: \(cameFrom)")
        print("open: \(open)")
        return reconstruct(cameFrom, current)
      }

      for nextP in current.neighbors {
        let dScore = d(current, nextP)
        let testScore = dScore == Int.max ? Int.max : gScore[current]! + dScore
        if testScore < gScore[nextP, default: Int.max] {
          cameFrom[nextP] = current
          gScore[nextP] = testScore
          open.insert(Scored(nextP, testScore + h(nextP)))
        }
      }
    }

    print("Returning empty handed")
    return nil
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

  public static func allPaths(startP: Position, endP: Coordinate, d: (Position, Position) -> Int, score: Int, maxScore: Int) -> Set<Coordinate> {
    if startP.p == endP {
      print("found end with score \(score) of \(maxScore)")
      if score == maxScore {
        return [startP.p]
      }
      return []
    }
    var result: Set<Coordinate> = []
    for p in startP.neighbors {
      let dp = d(startP, p)
      if dp != Int.max && (score + dp) <= maxScore {
        for np in allPaths(startP: p, endP: endP, d: d, score: score + dp, maxScore: maxScore) {
          result.insert(np)
        }
      }
    }
    if !result.isEmpty {
      result.insert(startP.p)
    }
    return result
  }

  public static func part2(input: String) -> Int {
    //let maxScore = part1(input: input)
    let grid = input.grid
    let startP = grid.coords.first { grid[$0] == "S" }!
    let endP = grid.coords.first { grid[$0] == "E" }!
    let p = Position(p: startP, f: .east)

    // assum p1 is adjacent to p2
    func d(_ followed: Set<Coordinate>, _ additionalCost: Int) -> (Position,Position) -> Int {
      return  { (_ p1: Position, _ p2: Position) in
        if grid[p2.p] == "#" {
          return Int.max
        }
        let add = followed.contains(p2.p) ? additionalCost : 0
        if additionalCost > 0 {
          print("add \(additionalCost) \(add)")
        }
        return 1 + p1.f.turns(to: p2.f) * 1000 + add
      }
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
    
    /*
    let all = allPaths(startP: p, endP: endP, d: d, score: 0, maxScore: maxScore)
    */

    guard let firstPath = astar(startP: p, endP: endP, h: h, d: d([], 0)) else {
      print("Failed")
      return 0
    }
    let bestScore = scorePath(firstPath, d: d([], 0))
    var followed: Set<Coordinate> = []
    for p in firstPath {
      followed.insert(p.p)
    }
    
    /*
    var thisScore = 0
    var attempts = 0
    var additionalCost = 0
    repeat {
      additionalCost = attempts * 1000
      guard let thisPath = astar(startP: p, endP: endP, h: h, d: d(followed, additionalCost)) else {
        print("Didn't find followup")
        break
      }
      thisScore = scorePath(thisPath, d: d([], 0))
      print("score \(thisScore)")
      //let before = followed.count
      if thisScore == bestScore && thisPath != firstPath {
        print("Another best score")
        for p in firstPath {
          followed.insert(p.p)
        }
      }
      /*
      if followed.count == before {
        print("Done")
        break
      }
      */
      attempts += 1
    } while (attempts < 500)

*/
    var outgrid = grid
    for p in followed {
      outgrid[p] = "O"
    }
    print(outgrid.display)
    print(firstPath)

    return followed.count
  }
}

extension Day16.Position: CustomStringConvertible {
  var description: String {
    "(\(p)\(f.symbol))"
  }
}
