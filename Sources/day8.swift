enum Day8 {
  static func part1(input: String) -> Int {
    let grid = input.grid
    let nodes = Dictionary(grouping: grid.coords) {
      grid[$0]
    }

    func resonantFrequencies(for f: [Coordinate]) -> Set<Coordinate> {
      return f.permutations(ofCount: 2)
       .map { pair in
         let d = pair[1] - pair[0]
         return [pair[1] + d, pair[0] - d]
       }
       .reduce([]) {
         $0.union($1)
       }
    }

    return nodes
      .remove { $0.key == "." }
      .map(\.value)
      .map(resonantFrequencies)
      .reduce(Set<Coordinate>()) { $0.union($1) }
      .filter(grid.contains)
      .count
  }

  static func part2(input: String) -> Int {
    let grid = input.grid
    let nodes = Dictionary(grouping: grid.coords) {
      grid[$0]
    }

    func resonantFrequencies(for f: [Coordinate]) -> Set<Coordinate> {
      return f.permutations(ofCount: 2)
       .map { pair in
         let d = pair[1] - pair[0]

         if abs(gcd(d.x, d.y)) != 1 {
           print("Not coprime: \(d) \(gcd(d.x, d.y))")
         }

         return iterate(pair[1]) {
           let n = $0 + d
           return grid.contains(coord: n) ? n : nil
         } + iterate(pair[0]) {
           let n = $0 - d
           return grid.contains(coord: n) ? n : nil
         }
       }
       .reduce([]) {
         $0.union($1)
       }
    }

    return nodes
      .remove { $0.key == "." }
      .map(\.value)
      .map(resonantFrequencies)
      .reduce(Set<Coordinate>()) { $0.union($1) }
      .count
  }
}
