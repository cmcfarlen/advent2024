
enum Day1 {
  static func part1(input: String) -> Int {
    let r = input.lines
      .flatMap(\.whitespace)
      .map { Int($0)! }
      .groupByIndexed { idx, _ in
        idx % 2
      }
      .mapValues { $0.sorted() }

    let sum = zip(r[0]!, r[1]!)
     .map {
       abs($1 - $0)
     }
     .sum()


    return sum
  }

  static func part2(input: String) -> Int {
    let r = input.lines
      .flatMap(\.whitespace)
      .map { Int($0)! }
      .groupByIndexed { idx, _ in
        idx % 2
      }

    let left = r[0]!
    let right = r[1]!.frequencies()

    let sum = left.map {
      $0 * right[$0, default: 0]
    }.sum()

    return sum
  }

}

enum Day2 {
  static func allIncreasing(_ v: [Int]) -> Bool {
    v.adjacentPairs().allSatisfy { (a, b) in
      a > b
    }
  }
  static func allDecreasing(_ v: [Int]) -> Bool {
    v.adjacentPairs().allSatisfy { (a, b) in
      a < b
    }
  }
  static func allInRange(_ v: [Int]) -> Bool {
    v.adjacentPairs().allSatisfy { (a, b) in
    1...3 ~= diff(a, b)
    }
  }
  static func safe(_ v: [Int]) -> Bool {
    (allIncreasing(v) || allDecreasing(v))
    && allInRange(v)
  }
  static func safeDroppingOne(_ v: [Int]) -> Bool {
    safe(v) ||
    !(0..<v.count).map {
      v.dropNth($0)
    }.filter(safe)
    .isEmpty
  }

  static func part1(input: String) -> Int {
    let lines = input.lines
    let result = lines
      .map(\.whitespace)
      .map {
        $0.map { Int($0)! }
      }
      .map(safe)
      .filter { $0 }
      .count

      return result
  }
  static func part2(input: String) -> Int {
    let lines = input.lines
    let result = lines
      .map(\.whitespace)
      .map {
        $0.map { Int($0)! }
      }
      .map(safeDroppingOne)
      .filter { $0 }
      .count

      return result
  }
}

enum Day3 {
  static func part1(input: String) -> Int {
    let regex = /mul\((\d+),(\d+)\)/

    return input
      .matches(of: regex)
      .map { m in
        m.1.int * m.2.int
      }
      .sum()
  }

  static func part2(input: String) -> Int {
    return input
      .split(separator: "do")
      .reductions((true, "")) { last, next in
        (next.starts(with: "n't()") ? false : next.starts(with: "()") ? true : last.0,
         next)
      }
      .compactMap { x in
        x.0 ? x.1 : nil
      }
      .map(String.init)
      .map(part1)
      .sum()
  }

  static func part2take2(input: String) -> Int {
    return input
      .split(separator: "do()")
      .map { $0.split(separator: "don't()").first! }
      .map(String.init)
      .map(part1)
      .sum()
  }
}

enum Day4 {
  static func part1(input: String) -> Int {
    let kernels = [
      """
      XMAS
      ****
      ****
      ****
      """,
      """
      SAMX
      ****
      ****
      ****
      """,
      """
      S***
      *A**
      **M*
      ***X
      """,
      """
      X***
      *M**
      **A*
      ***S
      """,
      """
      ***S
      **A*
      *M**
      X***
      """,
      """
      ***X
      **M*
      *A**
      S***
      """,
      """
      X***
      M***
      A***
      S***
      """,
      """
      S***
      A***
      M***
      X***
      """,

    ].map(\.grid)
    let puzzle = input.grid

    let m =  puzzle
     .coords
     .flatMap { pt in
        kernels.compactMap { kernel in
          puzzle.matches(kernel, offset: pt) ? 1 : nil
        }
     }

    return m.count
  }
  static func part2(input: String) -> Int {
    let kernels = [
      """
      M*S
      *A*
      M*S
      """,
      """
      S*M
      *A*
      S*M
      """,
      """
      S*S
      *A*
      M*M
      """,
      """
      M*M
      *A*
      S*S
      """
    ].map(\.grid)
    let puzzle = input.grid

    let m =  puzzle
     .coords
     .flatMap { pt in
        kernels.compactMap { kernel in
          puzzle.matches(kernel, offset: pt) ? 1 : nil
        }
     }

    return m.count
  }
}

enum Day5 {

  static func parseInput(input: String) -> ([Int:Set<Int>], [[Int]]) {
    let parts = input.split(separator: "\n\n").map(String.init)

    let orders = parts[0]
                  .lines
                  .map {
                    $0.splitInts(separator: "|")
                  }
                  .reduce(into: [:]) { m, v in
                    m[v[0], default: Set<Int>()].insert(v[1])
                  }

    let pages = parts[1]
      .lines
      .map {
        $0.splitInts(separator: ",")
      }
    return (orders, pages)
  }

  static func comesBefore(_ a: Int, _ b: Int, orders: [Int:Set<Int>]) -> Bool {
    return orders[a]?.contains(b) ?? false
  }

  static func check(_ page: some Collection<Int>, orders: [Int:Set<Int>]) -> Bool {
    guard page.count > 1 else {
      return true
    }
    let (first, rest) = page.firstRest()
      if rest.allSatisfy({ p in
          orders[first]?.contains(p) ?? false
          }) {
        return check(rest, orders: orders)
      }
    return false
  }

  static func reorder(_ page: [Int], orders: [Int:Set<Int>]) -> [Int] {
    page.sorted { a, b in comesBefore(a, b, orders: orders) }
  }

  static func part1(input: String) -> Int {
    let (orders, pages) = parseInput(input: input)

    return pages
     .filter { check($0, orders: orders) }
     .map { $0[$0.count / 2] }
     .sum()
  }

  static func part2(input: String) -> Int {
    let (orders, pages) = parseInput(input: input)

    return pages
     .remove { check($0, orders: orders) }
     .map { reorder($0, orders: orders) }
     .map { $0[$0.count / 2] }
     .sum()
  }
}

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

enum Day7 {
  static func mag(_ a: Int) -> Int {
    var m = 10
      while a / m > 0 {
        m *= 10
      }
    return m
  }

  static func combine(_ a: Int, _ b: Int) -> Int {
    return a * mag(b) + b
  }

  static func possiblyTrue(_ answer: Int, _ numbers: [Int]) -> Int? {
    func rtest(_ a: Int, _ v: some Collection<Int>) -> Int? {
      if a > answer {
        return nil
      }
      if v.isEmpty {
        return a == answer ? a : nil
      }
      let (f, rest) = v.firstRest()
      return rtest(a + f, rest) ?? rtest(a * f, rest) ?? rtest(combine(a, f), rest)
    }

    let (f, rest) = numbers.firstRest()

    return rtest(f, rest)
  }

  static func possiblyBackFront(_ answer: Int, _ numbers: [Int]) -> Int? {
    func rtest(_ a: Int, _ numbers: ArraySlice<Int>) -> Bool {
      guard numbers.count > 1 else {
        return a == numbers.last!
      }

      let (rest, f) = numbers.restLast()

      let (quot, rem) = a.quotientAndRemainder(dividingBy: f)
      if rem == 0 && rtest(quot, rest) {
        return true
      }

      let m = mag(f)
      let (q, r) = a.quotientAndRemainder(dividingBy: m)
      if r == f && rtest(q, rest) {
        return true
      }

      return rtest(a - f, rest)
    }

    return rtest(answer, numbers[...]) ? answer : nil
  }

  static func part1(input: String) -> Int {
    return input.lines.map {
      $0.split(separator: ": ")
    }
    .compactMap { v in
      possiblyBackFront(Int(v[0])!, String(v[1]).splitInts(separator: " "))
    }
    .sum()
  }
}
