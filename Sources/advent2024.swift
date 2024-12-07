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

  @inlinable
  func firstRest() -> (Element, [Element]) {
    let first = self.first!
    let rest = Array(self.dropFirst())

    return (first, rest)
  }
}

extension String {
  public var lines: [String] {
    self.split(separator: "\n").map { String($0) }
  }
  public var whitespace: [String] {
    self.split(separator: " ").map { String($0) }
  }

  @inlinable
  var int: Int {
    Int(self)!
  }

  @inlinable
  var grid: [[Character]] {
    self.lines.map(Array.init)
  }

  @inlinable
  func splitInts(separator: Character) -> [Int] {
    split(separator: separator).map(String.init).map { Int($0)! }
  }
}

public struct Coordinate: Sendable {
  public let x: Int
  public let y: Int
}

extension Coordinate {
  public func cartesian(ofSize s: Int) -> [Coordinate] {
    cartesian(width: s, height: s)
  }

  public func cartesian(width w: Int, height h: Int) -> [Coordinate] {
    product(0..<w, 0..<h).map { x, y in Coordinate.init(x: self.x + x, y: self.y + y) }
  }

  public static func +(a: Coordinate, b: Coordinate) -> Coordinate {
    .init(x: a.x + b.x, y: a.y + b.y)
  }

  public static let origin: Coordinate = .init(x: 0, y: 0)
}

extension Coordinate: ExpressibleByArrayLiteral {
  public typealias ArrayLiteralElement = Int
  public init(arrayLiteral elements: ArrayLiteralElement...) {
    self.x = elements[0]
    self.y = elements[1]
  }
}

extension Collection where Element: Collection<Character> {
  var width: Int {
    self[startIndex].count
  }

  var height: Int {
    self.count
  }

  @inlinable
  public func contains(coord: Coordinate) -> Bool {
    guard let ridx = index(startIndex, offsetBy: coord.y, limitedBy: endIndex), ridx < endIndex, ridx >= startIndex else {
      return false
    }
    
    let row = self[ridx]
    guard let cidx = row.index(row.startIndex, offsetBy: coord.x, limitedBy: row.endIndex), cidx < row.endIndex, cidx >= row.startIndex else {
      return false
    }
    return true
  }

  subscript(_ p: Coordinate, default d: Character = ".") -> Character {
    guard let ridx = index(startIndex, offsetBy: p.y, limitedBy: endIndex), ridx < endIndex, ridx >= startIndex else {
      return d
    }
    
    let row = self[ridx]
    guard let cidx = row.index(row.startIndex, offsetBy: p.x, limitedBy: row.endIndex), cidx < row.endIndex, cidx >= row.startIndex else {
      return d
    }
    return row[cidx]
  }

  var coords: [Coordinate] {
    Coordinate.origin.cartesian(width: width, height: height)
  }

  func subgrid(at coord: Coordinate, ofSize size: Int) -> [[Character]] {
    coord
      .cartesian(ofSize: size)
      .map {
        self[$0]
      }
      .chunks(ofCount: size)
      .reduce(into: []) { $0.append(Array($1)) }
  }

  func matches(_ other: [[Character]], offset: Coordinate = .origin) -> Bool {
    Coordinate.origin.cartesian(width: other.width, height: other.height).allSatisfy { pt in
      let o = other[pt, default: "."]
      if o == "*" {
        return true
      } else {
        return o == self[offset + pt, default: "."]
      }
    } 
  }

  var display: String {
    String(map(String.init).joined(by: "\n"))
  }
}

extension MutableCollection where Element: MutableCollection<Character> {
  @inlinable
  subscript(_ p: Coordinate) -> Character? {
    get {
      guard let ridx = index(startIndex, offsetBy: p.y, limitedBy: endIndex), ridx < endIndex, ridx >= startIndex else {
        return nil
      }

      let row = self[ridx]
      guard let cidx = row.index(row.startIndex, offsetBy: p.x, limitedBy: row.endIndex), cidx < row.endIndex, cidx >= row.startIndex else {
        return nil
      }
      return row[cidx]
    }
    set {
      assert(contains(coord: p))
      let ridx = index(startIndex, offsetBy: p.y)
      let row = self[ridx]
      let cidx = row.index(row.startIndex, offsetBy: p.x)
      self[ridx][cidx] = newValue ?? "0"
    }
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

  static func check(_ page: [Int], orders: [Int:Set<Int>]) -> Bool {
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
    print(grid.display)

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
          //print(tmp.display)
          //print("Loop detected at \(c)")
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
      [3, 2]: Day3.part2take2,
      [4, 1]: Day4.part1,
      [4, 2]: Day4.part2,
      [5, 1]: Day5.part1,
      [5, 2]: Day5.part2,
      [6, 1]: Day6.part1,
      [6, 2]: Day6.part2,
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
