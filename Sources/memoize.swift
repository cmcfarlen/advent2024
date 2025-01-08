private struct MemoizeCacheKey<each T: Hashable> {
  let keys: (repeat each T)

  init(_ args: repeat each T) {
    keys = (repeat each args)
  }
}

extension MemoizeCacheKey: Equatable where repeat each T: Equatable {
  static func == (
    lhs: MemoizeCacheKey<repeat each T>, rhs: MemoizeCacheKey<repeat each T>
  )
    -> Bool
  {
    for (l, r) in repeat (each lhs.keys, each rhs.keys) {
      guard l == r else {
        return false
      }
    }
    return true
  }
}

extension MemoizeCacheKey: Hashable where repeat each T: Hashable {
  func hash(into hasher: inout Hasher) {
    for e in repeat each keys {
      hasher.combine(e)
    }
  }
}

public struct MemoizedFunctionRecurse<each T: Hashable, U> {
  private var cache: [MemoizeCacheKey<repeat each T>: U] = [:]
  private let f: (inout Self, repeat each T) -> U

  init(_ f: @escaping (inout Self, repeat each T) -> U) {
    self.f = f
  }

  mutating func callAsFunction(_ args: repeat each T) -> U {
    let key = MemoizeCacheKey(repeat each args)
    if let v = cache[key] {
      return v
    }
    let v = f(&self, repeat each args)
    cache[key] = v
    return v
  }
}

public struct MemoizedFunction<each T: Hashable, U> {
  private var cache: [MemoizeCacheKey<repeat each T>: U] = [:]
  private let f: (repeat each T) -> U

  init(_ f: @escaping (repeat each T) -> U) {
    self.f = f
  }

  mutating func callAsFunction(_ args: repeat each T) -> U {
    let key = MemoizeCacheKey(repeat each args)
    if let v = cache[key] {
      return v
    }
    let v = f(repeat each args)
    cache[key] = v
    return v
  }
}

public func memoize<each T: Hashable, U>(
  _ f: @escaping (inout MemoizedFunctionRecurse<repeat each T, U>, repeat each T) -> U
) -> MemoizedFunctionRecurse<repeat each T, U> {
  MemoizedFunctionRecurse(f)
}

public func memoize<each T: Hashable, U>(
  _ f: @escaping (repeat each T) -> U
) -> MemoizedFunction<repeat each T, U> {
  MemoizedFunction(f)
}
