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

extension Key: Comparable {
  static func < (lhs: Key, rhs: Key) -> Bool {
    if lhs.day == rhs.day {
      return lhs.part < rhs.part
    }
    return lhs.day < rhs.day
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

  var trimmed: String {
    self.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

public struct Coordinate: Hashable, Sendable {
  public let x: Int
  public let y: Int
}

extension Coordinate {
  public init(fromArray: [Int]) {
    x = fromArray[0]
    y = fromArray[1]
  }
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

  public static func *(a: Coordinate, b: Int) -> Coordinate {
    .init(x: a.x * b, y: a.y * b)
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

  @inlinable
  public func adjacent(to a: Coordinate) -> Bool {
    let dx = diff(a.x, x)
    let dy = diff(a.y, y)
    return (dx == 0 && dy == 1) || (dy == 0 && dx == 1)
  }

  public func distanceSquared(to: Coordinate) -> Int {
    let d = to - self
    return d.x*d.x+d.y*d.y
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

  var display: String {
    map {
      $0.map { "\($0)" }.joined()
    }.joined(separator: "\n")
  }
}

extension Coordinate: Comparable {
  public static func < (lhs: Coordinate, rhs: Coordinate) -> Bool {
    if lhs.x == rhs.x {
      return lhs.y < rhs.y
    }
    return lhs.x < rhs.x
  }
}

struct Box {
  let upperLeft: Coordinate
  let lowerRight: Coordinate

  init(from: some Collection<Coordinate>) {
    let s = from.sorted { a, b in a < b }
    self.upperLeft = s.first!
    self.lowerRight = s.last!
  }
  init(upperLeft: Coordinate, lowerRight: Coordinate) {
    self.upperLeft = upperLeft
    self.lowerRight = lowerRight
  }
  init(x: Int = 0, y: Int = 0, width: Int, height: Int) {
    self.upperLeft = [x, y]
    self.lowerRight = [x + width - 1, y + height - 1]
  }

  var upperRight: Coordinate {
    [lowerRight.x, upperLeft.y]
  }
  var lowerLeft: Coordinate {
    [upperLeft.x, lowerRight.y]
  }

  var left: Int {
    upperLeft.x
  }
  var right: Int {
    lowerRight.x
  }
  var top: Int {
    upperLeft.y
  }
  var bottom: Int {
    lowerRight.y
  }
  var width: Int {
    lowerRight.x - upperLeft.x + 1
  }
  var height: Int {
   lowerRight.y - upperLeft.y + 1
  }

  var coords: [Coordinate] {
    upperLeft.cartesian(width: width, height: height)
  }

  func wrap(_ c: Coordinate) -> Coordinate {
    func h(_ v: Int, _ b: Int) -> Int {
      //v < 0 ? b+v : v > b ? v % b : v
      if v < 0 {
        b+v
      } else if v >= b {
        v % b
      } else {
        v
      }
    }
    return [h(c.x, width), h(c.y, height)]
  }

  func contains(_ c: Coordinate) -> Bool {
    return c.x >= left && c.x <= right &&
           c.y >= top && c.y <= bottom
  }

  func grid<T>(with v: T) -> [[T]] {
    let row: [T] = .init(repeating: v, count: width)
    return Array(repeating: row, count: height)
  }

  func divide(by v: Int = 2) -> [Box] {
    let w = width / 2
    let h = height / 2

    print("Width \(w) height \(h)")

    return [.init(x: 0,   y: 0,   width: w, height: h),
            .init(x: 0,   y: h+1, width: w, height: h),
            .init(x: w+1, y: 0,   width: w, height: h),
            .init(x: w+1, y: h+1, width: w, height: h)]
  }

  func widen(scale: Coordinate) -> Box {
    Box(x: upperLeft.x, y: upperLeft.y, width: width*scale.x, height: height*scale.y)
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

  func cleared(with c: Character = ".") -> [[Character]] {
    let row: [Character] = .init(repeating: c, count: width)
    let g: [[Character]] = .init(repeating: row, count: height)
    return g
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

public func diff(_ a: Int, _ b: Int) -> Int {
  abs(a - b)
}

func slurpInput(day: Int) throws -> String {
    let cwd = FileManager.default.currentDirectoryPath
    let path = "\(cwd)/input/day\(day).txt"

    return try String(contentsOfFile: path, encoding: .utf8)
}

func spit(_ v: String, to: String) {
  let cwd = FileManager.default.currentDirectoryPath
  let path = "\(cwd)/\(to)"

  do {
    try v.write(toFile: path, atomically: true, encoding: .utf8)
  } catch {
    fatalError("Failed to spit to file \(to): \(error)")
  }
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
