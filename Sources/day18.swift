enum Day18 {
  static func part1(input: String) -> Int {
    let coords = input.lines.map { $0.splitInts(separator: ",") }.map(Coordinate.init)
    let (maxx, maxy) = coords.reduce((0, 0)) { (max($0.0, $1.x), max($0.1, $1.y)) }
    var grid = Box(width: maxx+1, height: maxy+1).grid(with: Character("."))

    for c in coords[0..<1024] {
      grid[c] = "#"
    }

    let endP: Coordinate = [maxx, maxy]
    let path = astar(startP: [0,0], endP: endP, h: manhattanDistanceTo(from: endP)) { a, b in
      guard let e = grid[b] else {
        return Int.max
      }
      return e == "#" ? Int.max : 1
    }
    guard let path else {
      print("Failed to find path to \(endP)")
      return 0
    }

    for c in path {
      grid[c] = "0"
    }

    return path.count-1
  }

  static func part2(input: String) -> String {
    let coords = input.lines.map { $0.splitInts(separator: ",") }.map(Coordinate.init)
    let (maxx, maxy) = coords.reduce((0, 0)) { (max($0.0, $1.x), max($0.1, $1.y)) }
    let endP: Coordinate = [maxx, maxy]
    let gridM = Box(width: maxx+1, height: maxy+1).grid(with: Character("."))
    var startCount = 1024 // known ok from part1
    var endCount = coords.count-1

    let h = manhattanDistanceTo(from: endP)
    var lastGood = Coordinate.origin
    var lastBad = Coordinate.origin
    while startCount <= endCount {
      let idx = (endCount + startCount) / 2
      var grid = gridM.cleared(with: ".")
      for c in coords[0...idx] {
        grid[c] = "#"
      }

      let path = astar(startP: [0,0], endP: endP, h: h) { a, b in
        guard let e = grid[b] else {
          return Int.max
        }
        return e == "#" ? Int.max : 1
      }
      // if path found, drop more
      if path != nil {
        startCount = idx+1
        lastGood = coords[idx]
      } else {
        endCount = idx-1
        lastBad = coords[idx]
      }
    }
    print("After loop: \(startCount) \(endCount) \(lastGood) \(lastBad)")

    return lastBad.description
  }
}
