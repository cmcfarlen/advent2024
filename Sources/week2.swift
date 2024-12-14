import Foundation

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

enum Day9 {
  static func diskMap(input: String) -> [Int] {
    let zero = Character("0").asciiValue!
    return input.dropLast().map { Int($0.asciiValue! - zero) }
  }

  static func expanded(diskMap: [Int]) -> [Int] {
    return diskMap
      .chunks(ofCount: 2)
      .enumerated()
      .flatMap { id, bs in
        return Array(repeating: id, count: bs.first ?? 0) + 
               Array(repeating: -1, count: bs.second ?? 0)
      }
  }

  static func part1(input: String) -> Int {
    let diskMap = diskMap(input: input)
    let expanded = expanded(diskMap: diskMap)

    let emptyIndexes = diskMap
      .chunks(ofCount: 2)
      .reduce((0, [Int]())) { res, a in
        let (idx, acc) = res
        let (blocks, empty) = (a.first ?? 0, a.second ?? 0)
        let next = idx + blocks
        return (next + empty, acc + Array(next..<(next+empty)))
      }.1

    let backwardBlocks = expanded.enumerated().reversed().remove { $0.1 == -1 }

    let packed = zip(emptyIndexes, backwardBlocks)
     .reduce(expanded) { exp, zipped in
       let (idx, b) = zipped
       let (oldidx, v) = b
       if idx < oldidx {
         var tmp = exp
         tmp[oldidx] = -1
         tmp[idx] = v
         return tmp
       }
       return exp
     }
    
    return packed.remove { $0 == -1 }.enumerated().map { $0.offset * $0.element }.sum()
  }

  static func part2(input: String) -> Int {
    let diskMap = diskMap(input: input)

    var chunks = diskMap
      .chunks(ofCount: 2)
      .enumerated()
      .flatMap { id, bs in
        [(id: id, sz: bs.first ?? 0), (id: nil, sz: bs.second ?? 0)]
      }
    let files = chunks.filter { $0.id != nil }.reversed()

    func id(_ id: Int?) -> String {
      guard let id else {
        return "."
      }
      return String(id)
    }
    
    func chunksToPacked(_ cks: [(Int?, Int)]) -> [Int] {
      Array(cks.map { Array(repeating: $0.0 ?? -1, count: $0.1 ) }.joined())
    }
    
    func chunksString(_ cks: [(Int?, Int)]) -> String {
      cks.map { String(repeating: id($0.0), count: $0.1 ) }.joined()
    }

    chunks = files.reduce(into: chunks) { chunks, file in
      let fpos = chunks.firstIndex { $0 == file }!
      if let idx = chunks.firstIndex(where: { (val, sz) in val == nil && file.sz <= sz }), idx < fpos {
        chunks[idx].sz -= file.sz
        chunks[fpos] = (id: nil, sz: file.sz)
        chunks.insert(file, at: idx)
      }
    }
    let packed = chunksToPacked(chunks)

    return packed.enumerated().filter { $0.element != -1 }.map { $0.offset * $0.element }.sum()
  }
}

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

enum Day11 {
  @inlinable
  static func digits(_ x: Int) -> Int {
    Int(floor(log10(Double(x)))) + 1
  }

  @inlinable
  static func pow10(_ x: Int) -> Int {
    Int(pow(10, Double(x)))
  }

  static func blink(_ stones: ArraySlice<Int>) -> [Int] {
    var result = [Int]()
    result.reserveCapacity(stones.count*2)
    for s in stones {
      if s == 0 {
        result.append(1)
      } else {
        let d = digits(s)
        if d % 2 == 0 {
          let (a, b) = s.quotientAndRemainder(dividingBy: pow10(d / 2))
          result.append(a)
          result.append(b)
        } else {
          result.append(s * 2024)
        }
      }
    }
    return result
  }

  static func run(input: String, times t: Int) -> Int {
    var stones = input.lines.first!.splitInts(separator: " ")
    for x in 0..<t {
      let (s, m) = measure {
        stones = blink(stones[...])
        return stones.count
      }
      print("\(x): \(s) - \(m)")
    }
    return stones.count
  }

  static func part1(input: String) -> Int {
    run(input: input, times: 25)
  }

  // ahahahahahah
  static func part2bruteforce(input: String) async -> Int {
    var stones = [input.lines.first!.splitInts(separator: " ")]

    return await withTaskGroup(of: [Int].self) { group in
      for x in 0..<75 {

        var chunks = 0
        for chunkGroup in stones {
          for chunk in chunkGroup.chunks(ofCount: 1_000_000_000) {
            let cid = chunks
            group.addTask {
              print("chunk \(cid) priority \(Task.currentPriority)")
              return blink(chunk)
            }
            chunks += 1
          }
        }

        let (s, m) = await measure {
            var tmp = [[Int]]()
            tmp.reserveCapacity(stones.count * 2)

            stones = await group.reduce(into: tmp) {
              $0.append($1)
            }
            return stones.map(\.count).sum()
        }

        print("\(x): \(s) - \(m) \(chunks) chunks")

      }

      return stones.count
    }
  }
  
  // blink a stone some number of times and return the number of stones
  static func blinkStone(cache: inout [Int:[Int:Int]], stone sin: Int, times: Int) -> Int {
    if let v = cache[times]?[sin] {
      return v
    }
    var s = sin
    var count = 1

    for t in 0..<times {
      if s == 0 {
        s = 1
      } else {
        let d = digits(s)
        if d % 2 == 0 {
          let (a, b) = s.quotientAndRemainder(dividingBy: pow10(d / 2))
          s = a
          count += blinkStone(cache: &cache, stone: b, times: times - t - 1)
        } else {
          s *= 2024
        }
      }
    }
    cache[times, default: [:]][sin] = count
    return count
  }

  static func part2smart(input: String) -> Int {
    let stones = input.lines.first!.splitInts(separator: " ")

    var cache = [Int:[Int:Int]]()
    return stones.map { blinkStone(cache: &cache, stone: $0, times: 75) }.sum()
  }

  static func part2smartasync(input: String) async -> Int {
    let stones = input.lines.first!.splitInts(separator: " ")

    return await withTaskGroup(of: Int.self) { group in
      for s in stones {
        group.addTask {
          var cache = [Int:[Int:Int]]()
          return blinkStone(cache: &cache, stone: s, times: 75)
        }
      }
      return await group.reduce(0) { $0 + $1 }
    }
  }
}

enum Day12 {
  struct Region {
    let plant: Character
    var coords: Set<Coordinate>

    var area: Int {
      coords.count
    }
    var perimeter: Int {
      func adjCnt(_ c: Coordinate) -> Int {
        coords.remove { $0 == c }.filter { $0.adjacent(to: c) }.count
      }
      return coords.map(adjCnt).map { 4 - $0 }.sum()
    }
    var cost: Int {
      area * perimeter
    }
  }

  static func dumpRegion(into grid: inout [[Character]], _ r: Region) -> [[Character]] {
    for c in r.coords {
      grid[c] = r.plant
    }

    return grid
  }

  static func createRegions(for grid: [[Character]]) -> [Region] {
    return grid.coords.reduce(into: []) { regions, coord in
      let plant = grid[coord]!
      let idxs = regions.indices.filter { idx in
        regions[idx].plant == plant && regions[idx].coords.contains { x in x.adjacent(to: coord) }
      }
      if idxs.count == 0 {
        regions.append(Region(plant: plant, coords: [coord]))
      } else if idxs.count == 1 {
        regions[idxs[0]].coords.insert(coord)
      } else {
        regions[idxs[0]] = idxs.dropFirst().reduce(into: regions[idxs[0]]) { r, idx in
          r.coords = r.coords.union(regions[idx].coords)
        }
        regions[idxs[0]].coords.insert(coord)
        for idx in idxs.dropFirst() {
          regions.remove(at: idx)
        }
      }
    }
  }

  static func part1(input: String) -> Int {
    let grid = input.grid
    let regions = createRegions(for: grid)

/*
    var t = grid.cleared()
    for r in regions {
      print("plant \(r.plant) area \(r.area) * \(r.perimeter) = \(r.cost) ")
      _ = dumpRegion(into: &t, r)
    }

    print(t.display)
    assert(t == grid)
    */

    return regions.map(\.cost).sum()
  }
}

enum Day13 {
  struct Game {
    let a: Coordinate
    let b: Coordinate
    let p: Coordinate
  }
  static func parseButton(_ line: String) -> Coordinate {
    do {
      let m = try /Button .: X\+(\d+), Y\+(\d+)/.wholeMatch(in: line)!
      let p: Coordinate = [Int(m.1) ?? -1, Int(m.2) ?? -1]
      return p
    } catch {
      print("error in parse: \(error)")
      return .origin
    }
  }
  static func parsePrize(_ line: String) -> Coordinate {
    do {
      let m = try /Prize: X=(\d+), Y=(\d+)/.wholeMatch(in: line)!
      let p: Coordinate = [Int(m.1) ?? -1, Int(m.2) ?? -1]
      return [p.x + 10000000000000, p.y + 10000000000000]
    } catch {
      print("error in parse: \(error)")
      return .origin
    }
  }
  static func solve(game: Game) -> Int {
    let Tx = Double(game.p.x)
    let Ty = Double(game.p.y)
    let Ax = Double(game.a.x)
    let Ay = Double(game.a.y)
    let Bx = Double(game.b.x)
    let By = Double(game.b.y)

    let b = (Ty*Ax - Tx*Ay) / (Ax*By - Bx*Ay)
    let a  = (Tx - b * Bx) / Ax
    
    //print("pressed a \(a) b \(b) = \(a*Ax + b*Bx), \(a*Ay+b*By)")

    let ai = Int(floor(a))
    let bi = Int(floor(b))
    if ai * game.a.x + bi * game.b.x == game.p.x &&
       ai * game.a.y + bi * game.b.y == game.p.y {
      return 3*ai + bi
    }
    return 0
  }
  static func part1(input: String) -> Int {
    return input
      .lines
      .chunks(ofCount: 3)
      .map { game in
        let game = Array(game) // Why do I need to do this? subscript of chunks element crashes
        let g = Game(a: parseButton(game[0]),
                    b: parseButton(game[1]),
                    p: parsePrize(game[2]))
        return g
      }
      .map(solve)
      .sum()
  }
}

enum Day14 {
  static let bounds = Box(width: 101, height: 103)


  // all of this math stuff turned out to be not the right thing at all

  static func xyFuncs(_ p: Coordinate, _ v: Coordinate) -> (xofy: (_ y: Int)->Int, yofx: (_ x: Int)->Int) {
    (
    { y in
       //p.x - (v.x*p.y) / v.y - (v.x * y) / v.y
       (v.x*y)/v.y - v.x*p.y/v.y + p.x
    },
    { x in
       (v.y*x / v.x) + p.y - (v.y * p.x) / v.x
    }
    )
  }

  static func boxIntercepts(_ p: Coordinate, _ v: Coordinate) -> [Coordinate]
   {
   //let y0 = p.y - (v.y * p.x) / v.x
   //let x0 = p.x - (v.x*p.y) / v.y

   let (xofy, yofx) = xyFuncs(p, v)

   // vector will only intercect at two points
   return [[bounds.left, yofx(bounds.left)],
           [bounds.right, yofx(bounds.right)],
           [xofy(bounds.top), bounds.top],
           [xofy(bounds.bottom), bounds.bottom]]//.filter {bounds.contains($0)}
  }

    // x and y intercept
    //let intercepts = boxIntercepts(p, v)
    // length of the line segment
    //let endP = p + v * t
    //let traveled = endP - p
    // remaining distance
    // intercept + distance
    //return (intercepts, endP, traveled)

  // end of dumb maths

  static func moveBot(_ pin: Coordinate, _ v: Coordinate, _ t: Int) -> Coordinate {

    var p = pin
    for _ in 0..<t {
      p = bounds.wrap(p + v)
    }
    return p
  }

  static func parse(input: String) -> [(p: Coordinate, v: Coordinate)] {
    input.lines
      .map {
        $0.split(separator: " ")
          .map {
            Coordinate(fromArray: $0.split(separator: "=")
                .dropFirst()
                .flatMap {
                  $0.split(separator: ",")
                    .map {
                      Int($0)!
                    }
                }
            )
          }
      }
      .map {
        (p: $0[0], v: $0[1])
      }
  }

  static func part1(input: String) -> Int {
    let bots = parse(input: input)

    let answer = bots.map {
        moveBot($0.p, $0.v, 100)
    }

    var g: [[Int]] = bounds.grid(with: 0)
    for p in answer {
      g[p] = g[p, default: 0] + 1
    }
    print(g.display)

    return bounds.divide()
      .map { bx in
        answer.reduce(0) { bx.contains($1) ? $0 + 1 : $0 }
      }
      .show()
      .reduce(1) { $0 * $1 }
  }

  static func part2(input: String) -> Int {
    var bots = parse(input: input)
    var i = 0

    start: while true {
      var g: [[String]] = bounds.grid(with: " ")

      print("Second \(i)")
      bots = bots.map { b in
        (p: moveBot(b.p, b.v, 1), v: b.v)
      }
      i += 1

      for p in bots {
        if let x = g[p.p], x == "*" {
          continue start
        }
        g[p.p] = "*"
      }

      print(g.display)
      break
    }

    return 0
  }
}
