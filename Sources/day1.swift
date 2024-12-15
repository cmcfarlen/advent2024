
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
