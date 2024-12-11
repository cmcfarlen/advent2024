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
  func show<T>(_ input: [T]) -> Self {
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

@inlinable
func memoize<each T: Hashable, U>(_ f: @escaping (repeat each T)->U) -> (repeat each T) -> U {
  var cache: [Int: U] = [:]
  return { (args: repeat each T) in
    var h = Hasher()
    for arg in repeat each args {
      h.combine(arg)
    }
    let key = h.finalize()
    if let v = cache[key] {
      return v
    }
    let v = f(repeat each args)
    cache[key] = v
    return v
  }
}

// Too lazy to make this lazy
@inlinable
func iterate<T>(_ initial: T, _ f: (T) -> T?) -> [T] {
  var result = [initial]
  var x = initial
  while let n = f(x) {
    result.append(n)
    x = n
  }
  return result
}

@inlinable
func iterate<T>(_ initial: T, times t: Int, _ f: (T) -> T) -> [T] {
  var result = [T]()

  result.reserveCapacity(t+1)
  result.append(initial)
  return (1..<t).reduce(into: result) { $0.append(f($0[$1-1])) }
}

func gcd(_ m: Int, _ n: Int) -> Int {
  var a = 0
  var b = max(m, n)
  var r = min(m, n)

  while r != 0 {
    a = b
    b = r
    r = a % b
  }
  return b
}

extension Collection {
  @inlinable
  func remove(_ f: @escaping (Element) -> Bool) -> [Element] {
    filter(complement(f))
  }

  @inlinable
  func firstRest() -> (Element, SubSequence) {
    return (self.first!, self.dropFirst())
  }

  var second: Element? {
    dropFirst().first
  }
  
}

extension Array {
  @inlinable
  func firstRest() -> (Element, SubSequence) {
    return (self.first!, self.dropFirst())
  }

  @inlinable
  func restLast() -> (SubSequence, Element) {
    return (self.dropLast(), self.last!)
  }
}

extension ArraySlice {
  @inlinable
  func firstRest() -> (Element, SubSequence) {
    return (self.first!, self.dropFirst())
  }

  @inlinable
  func restLast() -> (SubSequence, Element) {
    return (self.dropLast(), self.last!)
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
  var intGrid: [[Int]] {
    let zero = Character("0").asciiValue!
    return self.lines.reduce(into: []) { $0.append($1.map { Int($0.asciiValue! - zero) }) }
  }


  @inlinable
  func splitInts(separator: Character) -> [Int] {
    split(separator: separator).map(String.init).map { Int($0)! }
  }
}

public struct Coordinate: Hashable, Sendable {
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

  public static func -(a: Coordinate, b: Coordinate) -> Coordinate {
    .init(x: a.x - b.x, y: a.y - b.y)
  }

  public var surrounding: [Coordinate] {
    [[-1,-1], [0,-1], [1,-1],
     [-1,0],          [1, 0],
     [-1, 1], [0, 1], [1, 1]].map { self + $0 }
  }

  public var udlr: [Coordinate] {
    [        [0,-1],
     [-1,0],        [1, 0],
             [0, 1]].map { self + $0 }
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

extension Coordinate: CustomStringConvertible {
  public var description: String {
    "[\(x),\(y)]"
  }
}

extension Collection where Element: Collection {
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

  var coords: [Coordinate] {
    Coordinate.origin.cartesian(width: width, height: height)
  }

  func subgrid(at coord: Coordinate, ofSize size: Int) -> [[Element.Element]] {
    coord
      .cartesian(ofSize: size)
      .map {
        self[$0]!
      }
      .chunks(ofCount: size)
      .reduce(into: []) { $0.append(Array($1)) }
  }

  subscript(_ p: Coordinate) -> Element.Element? {
    guard let ridx = index(startIndex, offsetBy: p.y, limitedBy: endIndex), ridx < endIndex, ridx >= startIndex else {
      return nil
    }
    
    let row = self[ridx]
    guard let cidx = row.index(row.startIndex, offsetBy: p.x, limitedBy: row.endIndex), cidx < row.endIndex, cidx >= row.startIndex else {
      return nil
    }
    return row[cidx]
  }

  subscript(_ p: Coordinate, default d: Element.Element) -> Element.Element {
    guard let ridx = index(startIndex, offsetBy: p.y, limitedBy: endIndex), ridx < endIndex, ridx >= startIndex else {
      return d
    }
    
    let row = self[ridx]
    guard let cidx = row.index(row.startIndex, offsetBy: p.x, limitedBy: row.endIndex), cidx < row.endIndex, cidx >= row.startIndex else {
      return d
    }
    return row[cidx]
  }


}

extension Collection where Element: Collection<Character> {
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

extension MutableCollection where Element: MutableCollection {
  @inlinable
  subscript(_ p: Coordinate) -> Element.Element? {
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
      self[ridx][cidx] = newValue!
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

enum Day8 {
  static func part1(input: String) -> Int {
    let grid = input.grid
    let nodes = Dictionary(grouping: grid.coords) {
      grid[$0]
    }

    func resonantFrequencies(for f: [Coordinate]) -> Set<Coordinate> {
      return f.permutations(ofCount: 2)
       .map { pair in
         let d = pair[1] - pair[0]
         return [pair[1] + d, pair[0] - d]
       }
       .reduce([]) {
         $0.union($1)
       }
    }

    return nodes
      .remove { $0.key == "." }
      .map(\.value)
      .map(resonantFrequencies)
      .reduce(Set<Coordinate>()) { $0.union($1) }
      .filter(grid.contains)
      .count
  }

  static func part2(input: String) -> Int {
    let grid = input.grid
    let nodes = Dictionary(grouping: grid.coords) {
      grid[$0]
    }

    func resonantFrequencies(for f: [Coordinate]) -> Set<Coordinate> {
      return f.permutations(ofCount: 2)
       .map { pair in
         let d = pair[1] - pair[0]

         if abs(gcd(d.x, d.y)) != 1 {
           print("Not coprime: \(d) \(gcd(d.x, d.y))")
         }

         return iterate(pair[1]) {
           let n = $0 + d
           return grid.contains(coord: n) ? n : nil
         } + iterate(pair[0]) {
           let n = $0 - d
           return grid.contains(coord: n) ? n : nil
         }
       }
       .reduce([]) {
         $0.union($1)
       }
    }

    return nodes
      .remove { $0.key == "." }
      .map(\.value)
      .map(resonantFrequencies)
      .reduce(Set<Coordinate>()) { $0.union($1) }
      .count
  }
}

enum Day9 {
  static func diskMap(input: String) -> [Int] {
    let zero = Character("0").asciiValue!
    return input.dropLast().map { Int($0.asciiValue! - zero) }
  }

  static func expanded(diskMap: [Int]) -> [Int] {
    return diskMap
      .chunks(ofCount: 2)
      .enumerated()
      .flatMap { id, bs in
        return Array(repeating: id, count: bs.first ?? 0) + 
               Array(repeating: -1, count: bs.second ?? 0)
      }
  }

  static func part1(input: String) -> Int {
    let diskMap = diskMap(input: input)
    let expanded = expanded(diskMap: diskMap)

    let emptyIndexes = diskMap
      .chunks(ofCount: 2)
      .reduce((0, [Int]())) { res, a in
        let (idx, acc) = res
        let (blocks, empty) = (a.first ?? 0, a.second ?? 0)
        let next = idx + blocks
        return (next + empty, acc + Array(next..<(next+empty)))
      }.1

    let backwardBlocks = expanded.enumerated().reversed().remove { $0.1 == -1 }

    let packed = zip(emptyIndexes, backwardBlocks)
     .reduce(expanded) { exp, zipped in
       let (idx, b) = zipped
       let (oldidx, v) = b
       if idx < oldidx {
         var tmp = exp
         tmp[oldidx] = -1
         tmp[idx] = v
         return tmp
       }
       return exp
     }
    //print("\(emptyIndexes) \(emptyIndexes.count)")
    //print("\(backwardBlocks) \(backwardBlocks.count)")
    //print(expanded)
    //print(packed)

    
    return packed.remove { $0 == -1 }.enumerated().map { $0.offset * $0.element }.sum()
  }

  static func part2(input: String) -> Int {
    let diskMap = diskMap(input: input)

    var chunks = diskMap
      .chunks(ofCount: 2)
      .enumerated()
      .flatMap { id, bs in
        [(id: id, sz: bs.first ?? 0), (id: nil, sz: bs.second ?? 0)]
      }
    let files = chunks.filter { $0.id != nil }.reversed()

    func id(_ id: Int?) -> String {
      guard let id else {
        return "."
      }
      return String(id)
    }
    
    func chunksToPacked(_ cks: [(Int?, Int)]) -> [Int] {
      Array(cks.map { Array(repeating: $0.0 ?? -1, count: $0.1 ) }.joined())
    }
    
    func chunksString(_ cks: [(Int?, Int)]) -> String {
      cks.map { String(repeating: id($0.0), count: $0.1 ) }.joined()
    }

    print(files)
    print(chunks)
    print(chunksString(chunks))
    chunks = files.reduce(into: chunks) { chunks, file in
      let fpos = chunks.firstIndex { $0 == file }!
      if let idx = chunks.firstIndex(where: { (val, sz) in val == nil && file.sz <= sz }), idx < fpos {
        chunks[idx].sz -= file.sz
        chunks[fpos] = (id: nil, sz: file.sz)
        chunks.insert(file, at: idx)
      }
    }
    print(chunksString(chunks))
    let packed = chunksToPacked(chunks)
    print(packed)

    return packed.enumerated().filter { $0.element != -1 }.map { $0.offset * $0.element }.sum()
  }
}

enum Day10 {
  static func part1(input: String) -> Int {
    let grid = input.intGrid
    let heads = grid.coords.filter { grid[$0] == 0 }
    
    func walkTrail(_ c: Coordinate) -> Set<Coordinate> {
      let v = grid[c]!
      if v == 9 {
        return [c]
      }
      return c.udlr
       .filter { grid[$0] == v + 1 }
       .map(walkTrail)
       .reduce([]) { $0.union($1) }
    }

    return heads.map(walkTrail).show(heads).map(\.count).sum()
  }

  static func part2(input: String) -> Int {
    let grid = input.intGrid
    let heads = grid.coords.filter { grid[$0] == 0 }
    
    func walkTrail(_ c: Coordinate) -> Int {
      let v = grid[c]!
      if v == 9 {
        return 1
      }
      return c.udlr
       .filter { grid[$0] == v + 1 }
       .map(walkTrail)
       .sum()
    }

    return heads.map(walkTrail).sum()
  }
}

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

func slurpInput(day: Int) throws -> String {
    let cwd = FileManager.default.currentDirectoryPath
    let path = "\(cwd)/input/day\(day).txt"

    return try String(contentsOfFile: path, encoding: .utf8)
}

typealias DayFunction = (String) -> any CustomStringConvertible
typealias DayFunctionAsync = (String) async -> Int

func measure<T>(_ f: () throws -> T) rethrows -> (T, ContinuousClock.Duration) {
  let c = ContinuousClock()


  let before = c.now
  let r = try f()
  return (r, c.now - before)
}

func measure<T>(_ f: () async throws -> T) async rethrows -> (T, ContinuousClock.Duration) {
  let c = ContinuousClock()


  let before = c.now
  let r = try await f()
  return (r, c.now - before)
}

@main
struct advent2024: AsyncParsableCommand {
  @Argument
  var day: Int
  @Argument
  var part: Int

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
    ]

    let registryAsync: [Key: DayFunctionAsync] = [
      [11, 2]: Day11.part2smartasync,
    ]

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
