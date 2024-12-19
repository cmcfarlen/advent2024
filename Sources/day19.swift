import Collections

class TrieNode {
  var ch: Character
  var isEnd: Bool
  var children: [Character: TrieNode]

  init(ch: Character, isEnd: Bool = false) {
    self.ch = ch
    self.isEnd = isEnd
    self.children = [:]
  }
}

class Trie {
  var root: TrieNode

  init(with: [some StringProtocol]) {
    root = TrieNode(ch: "a")
    for w in with {
      insert(w)
    }
  }

  func insert(_ w: some StringProtocol) {
    var current = root
    for c in w {
      if let node = current.children[c] {
        current = node
      } else {
        let node = TrieNode(ch: c)
        current.children[c] = node
        current = node
      }
    }
    current.isEnd = true
  }

  // return all the words that are prefixes of the argument
  func findMatches<S: StringProtocol>(for w: S) -> [S.SubSequence] {
    var result: [S.SubSequence] = []
    var current = root
    for idx in w.indices {
      guard let node = current.children[w[idx]] else {
        break
      }
      if node.isEnd {
        let r = w.prefix(through: idx)
        result.append(r)
      }
      current = node
    }

    return result
  }

  func longestMatch<S: StringProtocol>(for w: S) -> S.SubSequence? {
    var current = root
    var lastEnd: String.Index? = nil
    for idx in w.indices {
      guard let node = current.children[w[idx]] else {
        break
      }
      if node.isEnd {
        lastEnd = idx
      }
      current = node
    }
    if let lastEnd {
      return w.prefix(through: lastEnd)
    }
    return nil
  }
}


enum Day19 {
  public static func part1(input: String) -> Int {
    let parts = input.split(separator: "\n\n")
    let towels = parts[0].split(separator: ", ")
    let patterns = String(parts[1]).lines

    func isPossible(pattern: some StringProtocol) -> Bool {
      if pattern.isEmpty {
        return true
      }
      return towels.first(where: {
        pattern.starts(with: $0) && isPossible(pattern: pattern.dropFirst($0.count))
      }) != nil
    }

    return patterns.filter(isPossible).count
  }

  public static func part2(input: String) -> Int {
    let parts = input.split(separator: "\n\n")
    let allTowels = parts[0].split(separator: ", ")
    let towels = Trie(with: allTowels)
    let patterns = String(parts[1]).lines

    var cache: [String: [[String]]] = [:]
    func combinations(pattern: String) -> [[String]] {
      if let c = cache[pattern] {
        return c
      }
      if pattern.isEmpty {
        return []
      }
      let v = towels.findMatches(for: pattern)
        .flatMap { t in
          let rest = pattern.dropFirst(t.count)
          let res = [String(t)]
          if rest.isEmpty {
            return [res]
          } else {
            return combinations(pattern: String(rest)).map { res + $0 }
          }
        }
      cache[pattern] = v
      return v
    }

    var countCache: [String.SubSequence: Int] = [:]
    func matchCount(pattern: String.SubSequence) -> Int {
      print("Matching \(pattern)")
      if let match = towels.longestMatch(for: pattern) {
        guard let cnt = countCache[match] else {
          print("Failed to find count for \(match)")
          return 0
        }
        print("Matchcount: \(pattern) \(match) \(cnt)")
        let next = pattern.dropFirst(match.count)
        return cnt * (next.isEmpty ? 1 : matchCount(pattern: pattern.dropFirst(match.count)))
      }
      print("Matchcount: \(pattern) is zero")
      return 0
    }

    // precompute
    for t in allTowels {
      let combos = combinations(pattern: String(t))
      countCache[t] = combos.count
      print(t, combos.count, combos)
    }

    print("Matchcount r", towels.longestMatch(for: "r") ?? "none")
    print(" trying \(patterns[3])")

    print(patterns[3], matchCount(pattern: patterns[3][...]))

    return patterns.map { matchCount(pattern: $0[...]) }.show(patterns).sum()
  }
}
