enum Day23 {
  static func part1(input: String) -> Int {
    let pairs = input.lines
      .map {
        $0.split(separator: "-").map(String.init)
      }
    let connectedTo = pairs.reduce(into: [String:Set<String>]()) { s, p in
      s[p[0], default: []].insert(p[1])
      s[p[1], default: []].insert(p[0])
    }
    func areConnected(_ a: String, _ b: String) -> Bool {
      connectedTo[a]?.contains(b) ?? false
    }

    let tnodes = connectedTo.keys.filter { $0.starts(with: "t") }
    var tlans: Set<Set<String>> = []
    for tn in tnodes {
      for otn in connectedTo[tn]! {
        for ootn in connectedTo[otn]! {
          if areConnected(ootn, tn) {
            tlans.insert([tn, otn, ootn])
          }
        }
      }
    }

    return tlans.count
  }
}
