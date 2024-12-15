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
