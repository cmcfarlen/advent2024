// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import Algorithms

struct Key: Hashable {
  let day: Int
  let part: Int
}

extension Key: ExpressibleByArrayLiteral {
  typealias ArrayLiteralElement = Int
  init(arrayLiteral elements: ArrayLiteralElement...) {
    self.day = elements[0]
    self.part = elements[1]
  }
}

extension Sequence {
  @inlinable
  func groupBy<T: Hashable>(_ f: (Element) throws -> T) rethrows -> [T: [Element]] { 
    try self.reduce(into: [T:[Element]]()) { r, e in
      r[try f(e), default: []].append(e)
    }
  }

  @inlinable
  func groupByIndexed<T: Hashable>(_ f: (Int, Element) throws -> T) rethrows -> [T: [Element]] { 
    try self.enumerated().reduce(into: [T:[Element]]()) { r, e in
      r[try f(e.offset, e.element), default: []].append(e.element)
    }
  }

  @inlinable
  func sum() -> Element where Element == Int {
    self.reduce(0) { $0 + $1 }
  }

  @inlinable
  func show() -> Self {
    for (line, x) in self.enumerated() {
      print("\(line): \(x)")
    }
    return self
  }

  @inlinable
  func show(_ input: [String]) -> Self {
    for (line, x) in self.enumerated() {
      print("\(line): \(input[line]) -> \(x)")
    }
    return self
  }

  @inlinable
  func frequencies() -> [Element: Int] where Element: Hashable {
    self.reduce(into: [Element:Int]()) { r, e in
      r[e, default: 0] += 1
    }
  }

  @inlinable
  func dropNth(_ i: Int) -> [Element] {
    self
    .enumerated()
    .compactMap { offset, x in
      offset == i ? nil : x
    }
  }

}

@inlinable
func complement<each T>(_ f: @escaping (repeat each T)->Bool) -> (repeat each T) -> Bool {
  { (args: repeat each T) in
    !f(repeat each args)
  }
}

extension Collection {
  @inlinable
  func remove(_ f: @escaping (Element) -> Bool) -> [Element] {
    filter(complement(f))
  }
}

extension String {
  var lines: [String] {
    self.split(separator: "\n").map { String($0) }
  }
  var whitespace: [String] {
    self.split(separator: " ").map { String($0) }
  }

  var int: Int {
    Int(self)!
  }
}

extension Substring {
  var int: Int {
    Int(self)!
  }
}

func diff(_ a: Int, _ b: Int) -> Int {
  abs(a - b)
}

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
}

func slurpInput(day: Int) throws -> String {
    let cwd = FileManager.default.currentDirectoryPath
    let path = "\(cwd)/input/day\(day).txt"

    return try String(contentsOfFile: path, encoding: .utf8)
}

typealias DayFunction = (String) -> any CustomStringConvertible

@main
struct advent2024: ParsableCommand {
  @Argument
  var day: Int
  @Argument
  var part: Int

  mutating func run() throws {

    let registry: [Key: DayFunction] = [
      [1, 1]: Day1.part1,
      [1, 2]: Day1.part2,
      [2, 1]: Day2.part1,
      [2, 2]: Day2.part2,
      [3, 1]: Day3.part1,
      [3, 2]: Day3.part2
    ]

    let key: Key = [day, part]
    guard let input = try? slurpInput(day: day) else {
      print("Failed to read input for day \(day)")
      return
    }

    guard let dayf = registry[key] else {
      print("Unimplemented day \(day) \(part)")
      return
    }

    print("day \(day) part \(part): \(dayf(input))")
  }
}
