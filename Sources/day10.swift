enum Day10 {
  static func part1(input: String) -> Int {
    let grid = input.intGrid
    let heads = grid.coords.filter { grid[$0] == 0 }
    
    func walkTrail(_ c: Coordinate) -> Set<Coordinate> {
      let v = grid[c]!
      if v == 9 {
        return [c]
      }
      return c.udlr
       .filter { grid[$0] == v + 1 }
       .map(walkTrail)
       .reduce([]) { $0.union($1) }
    }

    return heads.map(walkTrail).show(heads).map(\.count).sum()
  }

  static func part2(input: String) -> Int {
    let grid = input.intGrid
    let heads = grid.coords.filter { grid[$0] == 0 }
    
    func walkTrail(_ c: Coordinate) -> Int {
      let v = grid[c]!
      if v == 9 {
        return 1
      }
      return c.udlr
       .filter { grid[$0] == v + 1 }
       .map(walkTrail)
       .sum()
    }

    return heads.map(walkTrail).sum()
  }
}
