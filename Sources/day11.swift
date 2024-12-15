import Foundation

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
