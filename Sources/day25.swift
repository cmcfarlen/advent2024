enum Day25 {

  static func heights(_ g: [[Character]]) -> [Int] {
    var result: [Int] = []
    for x in 0..<g.width {
      var cnt = 0
      for y in 1..<(g.height-1) {
        let c: Coordinate = [x, y]
        if g[c] == "#" {
          cnt += 1
        }
      }
      result.append(cnt)
    }
    return result
  }

  static func fits(_ key: [Int], _ lock: [Int]) -> Bool {
    zip(key, lock).allSatisfy { $0 + $1 <= 5 }
  }

  public static func part1(input: String) -> Int {
    let grids = input.split(separator: "\n\n").map(String.init).map(\.grid)
    let (keyGrids, lockGrids) = grids.partitioned { $0[Coordinate.origin] == "#" }

    let keys = keyGrids.map(heights)
    let locks = lockGrids.map(heights)

    var count = 0
    for k in keys {
      for l in locks {
        if fits(k, l) {
          count += 1
        }
      }
    }

    return count
  }
}
