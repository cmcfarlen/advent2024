enum Day15 {
  static func direction(of c: Character) -> Coordinate {
    switch c {
      case "<": [-1, 0]
      case ">": [1, 0]
      case "^": [0, -1]
      case "v": [0, 1]
      default:
        fatalError("Invalid move '\(c)'")
    }
  }

  static func part1(input: String) -> Int {
    let parts = input.split(separator: "\n\n")
    var grid = String(parts[0]).grid
    let moves = String(parts[1]).lines.joined()
    var p = grid.coords.first { grid[$0] == "@" }!

    func update(grid: inout [[Character]], p: Coordinate, m: Coordinate) -> Coordinate {
      let next = p + m
      let nextItem = grid[next]!
      
      guard nextItem != "#" else {
        return p
      }

      if nextItem == "." {
        grid[p] = "."
        grid[next] = "@"
      } else if nextItem == "O" {
        var end = next + m
        while grid[end] == "O" {
          end = end + m
        }
        if grid[end] == "#" {
          // boxes to wall
          return p
        }
        grid[p] = "."
        grid[next] = "@"
        while end != next {
          grid[end] = "O"
          end = end - m
        }
      } else {
        fatalError("String item \(nextItem) at \(next)")
      }

      return next
    }

    for m in moves.map(direction) {
      p = update(grid: &grid, p: p, m: m)
    }

    return grid.coords
      .filter { grid[$0] == "O" }
      .map { 100 * $0.y + $0.x }
      .sum()
  }

  static func part2(input: String) -> Int {
    let parts = input.split(separator: "\n\n")
    let grid = String(parts[0]).grid
    let moves = String(parts[1]).lines.joined()

    func widen(grid: [[Character]]) -> [[Character]] {
      var result = Box(from: grid.coords).widen(scale: [2, 1]).grid(with: Character(" "))
      assert(result.width == 2*grid.width, "Box width wrong \(result.width) vs \(grid.width)")
      assert(result.height == grid.height, "Box height wrong \(result.height) vs \(grid.height)")

      for c in grid.coords {
        let old = grid[c]!
        let newC: Coordinate = [c.x*2, c.y]
        if old == "O" {
          result[newC] = "["
          result[newC+[1,0]] = "]"
        } else if old == "@" {
          result[newC] = "@"
          result[newC+[1,0]] = "."
        } else {
          result[newC] = old
          result[newC+[1,0]] = old
        }
      }
      return result
    }

    func update(grid: [[Character]], p: Coordinate, m: Coordinate, with ch: Character) -> (Coordinate, [[Character]])? {
      let next = p + m
      let nextItem = grid[next]!
      
      guard nextItem != "#" else {
        return nil
      }
      var result = grid

      if nextItem != "." {
        guard let (_, r) = update(grid: result, p: next, m: m, with: nextItem) else {
          return nil
        }
        result = r
        if m.x == 0 {
          let (sideP, sideCh) = nextItem == "[" ? (next + [1, 0], "]") : (next - [1, 0], "[")
          guard let (_, r) = update(grid: result, p: sideP, m: m, with: Character(sideCh)) else {
            return nil
          }
          result = r
        }
      }

      result[next] = ch
      result[p] = "."
      return (next, result)
    }

    let widegrid = widen(grid: grid)
    let p = widegrid.coords.first { widegrid[$0] == "@" }!

    let (_, fgrid) = moves.map(direction)
      .reduce((p, widegrid)) { old, mv in
        let (p, grid) = old
        return update(grid: grid, p: p, m: mv, with: "@") ?? old
      }

    return fgrid.coords
      .filter { fgrid[$0] == "[" }
      .map { 100 * $0.y + $0.x }
      .sum()
  }
}
