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

    var cache: [Substring: Int] = [:]
    func combinations(pattern: Substring) -> Int {
      if pattern.isEmpty {
        return 1
      }
      if let c = cache[pattern] {
        return c
      }
      let v = towels.findMatches(for: pattern)
        .map { t in
          let rest = pattern.dropFirst(t.count)
          if rest.isEmpty {
            return 1
          } else {
            return combinations(pattern: rest)
          }
        }
        .sum()
      cache[pattern] = v
      return v
    }

    return patterns.map { combinations(pattern: $0[...]) }.sum()
  }
}
