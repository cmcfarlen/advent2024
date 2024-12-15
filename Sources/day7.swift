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
