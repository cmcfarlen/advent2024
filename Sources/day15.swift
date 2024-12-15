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

    let boxCh: Set<Character> = ["[", "]"]

    func update(grid: [[Character]], p: Coordinate, m: Coordinate) -> (Coordinate, [[Character]]) {
      let next = p + m
      let nextItem = grid[next]!
      
      guard nextItem != "#" else {
        return (p, grid)
      }


      if nextItem != "." {
        var result = grid
        // horizonal is the same as part 1
        if m.y == 0 {
          if boxCh.contains(nextItem) {
            var end = next + m + m
            while boxCh.contains(grid[end]) {
              end = end + m + m
            }
            if grid[end] == "#" {
              // boxes to wall
              return (p, grid)
            }
            while end != next {
              let ne = end - m
              result[end] = grid[ne]
              end = ne
            }
            result[next] = "."
          } else {
            fatalError("String item \(nextItem) at \(next)")
          }
          return (next, result)
        // vertical can move wide
        } else {
          return (p, grid)
        }
      }

      return (next, grid)
    }

    var widegrid = widen(grid: grid)
    let p = widegrid.coords.first { widegrid[$0] == "@" }!
    widegrid[p] = "."

    print(widegrid.display)
    print("Player at \(p)")

    let (_, fgrid) = moves.map(direction)
      .reduce((p, widegrid)) { old, mv in
        let (p, grid) = old
        let new = update(grid: grid, p: p, m: mv)
        print("Move \(mv) p \(new.0)")
        var withp = new.1
        withp[new.0] = "@"
        print(withp.display)

        return new
      }

    return fgrid.coords
      .filter { grid[$0] == "[" }
      .map { 100 * $0.y + $0.x }
      .sum()
  }
}
