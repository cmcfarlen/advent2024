import Foundation
enum Day22 {
  struct RNG: Sequence, IteratorProtocol {
    var n: Int

    mutating func next() -> Int? {
      n = (n ^ (n * 64)) % 16777216
      n = (n ^ Int(floor(Double(n) / 32.0))) % 16777216
      n = (n ^ (n * 2048)) % 16777216
      return n
    }
  }

  public static func part1(input: String) -> Int {
    let seeds = input.splitInts(separator: "\n")

    for x in RNG(n: 123).prefix(10) {
      print(x)
    }

    return seeds.map(RNG.init)
      .map { rng in
        Array(rng.dropFirst(1999).prefix(1)).first!
      }
      .show(seeds)
      .sum()
  }

  public static func part2(input: String) -> Int {
    let seeds = input.splitInts(separator: "\n")

    func rng(seed: Int) -> some Sequence<Int> {
      return sequence(first: seed) { p in
        var n = p
        n = (n ^ (n * 64)) % 16777216
        n = (n ^ Int(floor(Double(n) / 32.0))) % 16777216
        n = (n ^ (n * 2048)) % 16777216
        return n
      }
    }

    for s in seeds {
      print("Seed \(s)")
      let prices = rng(seed: s).prefix(2000).map { $0 % 10 }
      prices.windows(ofCount: 2).map {
        let a = Array($0)
        return (a[1] - a[0], a[1])
      }
      .windows(ofCount: 4)
      .map { w in
        let win = Array(w)
        let seq = win.map { $0.0 }
        let end = win.last!.1

        return (end, seq)
      }
      .filter { $0.1 == [-2, 1, -1, 3] }
      .show(Array(prices.dropFirst()))
    }


    return 0
  }
}

