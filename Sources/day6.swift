enum Day6 {
  enum Facing: Character {
    case up = "^"
    case down = "v"
    case left = "<"
    case right = ">"

    var dir: Coordinate {
      switch self {
        case .up: [0, -1]
        case .down: [0, 1]
        case .left: [-1, 0]
        case .right: [1, 0]
      }
    }

    var right: Facing {
      switch self {
        case .up: .right
        case .down: .left
        case .left: .up
        case .right: .down
      }
    }

    var travel: Character {
      switch self {
        case .up, .down: "|"
        case .left, .right: "-"
      }
    }
  }

  enum Result {
    case outside
    case loop
    case next(Coordinate)
  }

  static func part1(input: String) -> Int {
    var grid = input.grid

    var p = Coordinate.origin.cartesian(width: grid.width, height: grid.height).first { grid[$0] == Facing.up.rawValue }
    var f = Facing.up

    func nextP(_ p: Coordinate) -> Coordinate? {
      let next = p + f.dir
      let c = grid[next, default: "x"] 
      guard c != "x" else {
        return nil
      }
      if c != "#" {
        return next
      }
      f = f.right
      return nextP(p)
    }

    while let c = p {
      grid[c] = "X"
      p = nextP(c)
    }

    return grid.display.filter { $0 == "X" }.count
  }

  static func part2(input: String) -> Int {
    let grid = input.grid

    let startP = Coordinate.origin.cartesian(width: grid.width, height: grid.height).first { grid[$0] == Facing.up.rawValue }
    var f = Facing.up

    func nextP(_ grid: inout [[Character]], _ p: Coordinate) -> Result {
      let pc = grid[p]
      let next = p + f.dir
      let c = grid[next, default: "x"] 
      guard c != "x" else {
        return .outside
      }
      if c != "#" && c != "0" {
        if pc == "." {
          grid[p] = f.travel
        } else {
          grid[p] = "+"
        }
        return .next(next)
      }
      if pc == "+" {
        // Loop detected if we are turning on a +
        return .loop
      } else if pc == "." {
        grid[p] = f.travel
      } else {
        grid[p] = "+"
      }
      f = f.right
      return nextP(&grid, p)
    }

    func runGrid(_ grid: inout [[Character]]) -> Bool {
      f = Facing.up
      var r = Result.next(startP!)
      while case let .next(c) = r {
        r = nextP(&grid, c)
        if case .loop = r {
          return true
        }
      }
      return false
    }

    return grid
      .coords
      .filter { grid[$0] == "." }
      .filter {
        var tmp = grid
        tmp[$0] = "0"
        return runGrid(&tmp)
      }.count
  }
}
