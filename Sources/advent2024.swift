// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct advent2024: AsyncParsableCommand {
  @Argument
  var day: Int = 0
  @Argument
  var part: Int = 0

  mutating func run() async throws {

    let registry: [Key: DayFunction] = [
      [1, 1]: Day1.part1,
      [1, 2]: Day1.part2,
      [2, 1]: Day2.part1,
      [2, 2]: Day2.part2,
      [3, 1]: Day3.part1,
      [3, 2]: Day3.part2take2,
      [4, 1]: Day4.part1,
      [4, 2]: Day4.part2,
      [5, 1]: Day5.part1,
      [5, 2]: Day5.part2,
      [6, 1]: Day6.part1,
      [6, 2]: Day6.part2,
      [7, 1]: Day7.part1,
      [8, 1]: Day8.part1,
      [8, 2]: Day8.part2,
      [9, 1]: Day9.part1,
      [9, 2]: Day9.part2,
      [10, 1]: Day10.part1,
      [10, 2]: Day10.part2,
      [11, 1]: Day11.part1,
      [11, 2]: Day11.part2smart,
      [12, 1]: Day12.part1,
      [12, 2]: Day12.part2,
      [13, 1]: Day13.part1,
      [14, 1]: Day14.part1,
      [14, 2]: Day14.part2,
      [15, 1]: Day15.part1,
      [15, 2]: Day15.part2,
      [16, 1]: Day16.part1,
      [16, 2]: Day16.part2,
      [17, 1]: Day17.part1,
      [17, 2]: Day17.part2,
      [18, 1]: Day18.part1,
      [18, 2]: Day18.part2,
      [19, 1]: Day19.part1,
      [19, 2]: Day19.part2,
      [20, 1]: Day20.part1,
    ]

    let registryAsync: [Key: DayFunctionAsync] = [
      [11, 2]: Day11.part2smartasync,
    ]

    if day == 0 {
      var summaries = [String]()
      for (key, dayf) in registry.sorted(by: { $0.0 < $1.0 }) {
        guard let input = try? slurpInput(day: key.day) else {
          print("Failed to read input for day \(key.day)")
          return
        }

        let (result, duration) = measure { dayf(input) }

        summaries.append("day \(key.day) part \(key.part): \(result) in \(duration)")
      }
      print("Summaries:")
      for s in summaries {
        print("  \(s)")
      }
      return
    }

    guard let input = try? slurpInput(day: day) else {
      print("Failed to read input for day \(day)")
      return
    }

    let key: Key = [day, part]
    if let dayf = registry[key] {
      let (result, duration) = measure { dayf(input) }

      print("day \(day) part \(part): \(result) in \(duration)")
      return
    }

    if let dayf = registryAsync[key] {
      let (result, duration) = 
          await Task(priority: .high) { [dayf] in
            await measure {
              await dayf(input)
            }
          }.value

      print("day \(day) part \(part): \(result) in \(duration)")
      return
    }

    print("Unimplemented day \(day) \(part)")
  }
}
