import Collections

struct Scored<T: Equatable>: Equatable, Comparable {
  let wrapped: T
  let score: Int

  public static func <(_ lhs: Scored<T>, _ rhs: Scored<T>) -> Bool {
    lhs.score < rhs.score
  }

  public static func ==(_ lhs: Scored<T>, _ rhs: Scored<T>) -> Bool {
    lhs.score == rhs.score && lhs.wrapped == rhs.wrapped
  }

  init(_ t: T, _ score: Int) {
    wrapped = t
    self.score = score
  }
}

public protocol GridNavigable: Hashable {
  var position: Coordinate { get }
  var neighbors: [Self] { get }
}

extension Coordinate: GridNavigable {
  public var position: Coordinate { self }
  public var neighbors: [Self] { self.udlr }
}

public func dijkstra<T:GridNavigable>(startP: T, d: (T, T) -> Int) -> (scores: [T:Int], prev: [T:Set<T>]) {
  var open: Heap<Scored<T>> = []
  var gScore: [T:Int] = [:]
  var prev: [T:Set<T>] = [:]
  var visited: Set<T> = []

  gScore[startP] = 0
  open.insert(Scored(startP, 0))
  
  while !open.isEmpty {
    guard let currentMin = open.popMin() else {
      break
    }
    let current = currentMin.wrapped
    visited.insert(current)

    for nextP in current.neighbors {
      if !visited.contains(nextP) {
        let dScore = d(current, nextP)
        let testScore = dScore == Int.max ? Int.max : gScore[current]! + dScore
        if testScore != Int.max {
          open.insert(Scored(nextP, testScore))
        }
        let gs = gScore[nextP, default: Int.max]
        if testScore <= gs {
          if testScore == gs {
            prev[nextP, default: []].insert(current)
          } else {
            prev[nextP] = [current]
          }
          gScore[nextP] = testScore
        }
      }
    }
  }

  return (scores: gScore, prev: prev)
}

// astar from https://en.wikipedia.org/wiki/A*_search_algorithm
public func astar<T:GridNavigable>(startP: T, endP: Coordinate, h: (T)->Int, d: (T, T) -> Int) -> [T]? {
  var open: Heap<Scored<T>> = []
  var gScore: [T:Int] = [:]
  var cameFrom: [T:T] = [:]

  gScore[startP] = 0
  open.insert(Scored(startP, h(startP)))
  
  while !open.isEmpty {
    guard let currentMin = open.popMin() else {
      return nil
    }
    let current = currentMin.wrapped
    if current.position == endP {
      return reconstruct(cameFrom, current)
    }

    for nextP in current.neighbors {
      let dScore = d(current, nextP)
      let testScore = dScore == Int.max ? Int.max : gScore[current]! + dScore
      if testScore < gScore[nextP, default: Int.max] {
        cameFrom[nextP] = current
        gScore[nextP] = testScore
        open.insert(Scored(nextP, testScore + h(nextP)))
      }
    }
  }

  return nil
}

public func manhattanDistance(from: Coordinate, to: Coordinate) -> Int {
  let d = to - from
  return abs(d.x) + abs(d.y)
}

public func manhattanDistanceTo(from: Coordinate) -> (Coordinate)->Int {
  { to in
    let d = to - from
    return abs(d.x) + abs(d.y)
  }
}

public func reconstruct<T>(_ cameFrom: [T:T], _ to: T) -> [T] {
  var path: [T] = [to]
  var current = to
  while let n = cameFrom[current] {
    current = n
    path.append(n)
  }
  return path
}

public func reconstruct<T>(_ cameFrom: [T:Set<T>], _ to: T) -> [T] {
  var path: [T] = [to]
  var current = to
  while let nset = cameFrom[current] {
    let n = nset.first!
    current = n
    path.append(n)
  }
  return path
}

