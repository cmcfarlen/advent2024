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
