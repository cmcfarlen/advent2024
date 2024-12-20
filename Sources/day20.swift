enum Day20 {
  public static func part1(input: String) -> Int {
    let grid = input.grid
    let start = grid.coords.first { grid[$0] == "S" }!
    let end = grid.coords.first { grid[$0] == "E" }!

    let (scores, prev) = dijkstra(startP: start) { a, b in
      if grid[b] == "#" {
        return Int.max
      }
      return 1 
    }
    let path = reconstruct(prev, end)

    // move along the path finding  pairs where the next step is inf, but after is not
    let candidates = path[1...]
      .flatMap{ p in
        p.udlr.map { a in
          (p, a, a+(a-p))
        } // two steps along udlr
      }
      .map { pab in
        let (p, a, b) = pab
        return ((p, scores[p, default: Int.max]), (a, scores[a, default: Int.max]), (b, scores[b, default: Int.max]))
      }
      // possible candidates
      .filter { pab in
        let (_, a, b) = pab
        return a.1 == Int.max && b.1 < Int.max
      }
      // remove duplicates
      .remove { pab in
        let (p, _, b) = pab
        return b.1 - p.1 < 0
      }
      .reduce(into: [((Coordinate, Int), (Coordinate, Int), (Coordinate, Int))]()) { s, pab in
        s.append(pab)
      }

/*
    let pathLength = path.count
    func testCheat(_ cheatAt: Coordinate) -> Int {
      let (scores, prev) = dijkstra(startP: start) { a, b in
        if b == cheatAt {
          return 1
        }
        if grid[b] == "#" {
          return Int.max
        }
        return 1 
      }
      let path = reconstruct(prev, end)
      return pathLength - path.count
    }

    var byImp: [Int:Int] = [:]
    for candidate in candidates {
      let (p, a, b) = candidate
      let guessImprovement = b.1 - p.1 - 2
      let improvement = testCheat(a.0)
      print("Candidate \(candidate) improves by \(improvement) (\(guessImprovement) guessed)")
      byImp[improvement, default: 0] += 1
    }
    for (i, c) in byImp.sorted { $0.0 > $1.0 } {
      print("\(c) improve by \(i)")
    }
    */

    return candidates.map { $0.2.1 - $0.0.1 - 2 }.filter { $0 >= 100 }.count
  }

  public static func part2(input: String) -> Int {
    return 0  
  }
}
