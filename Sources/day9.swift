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

    chunks = files.reduce(into: chunks) { chunks, file in
      let fpos = chunks.firstIndex { $0 == file }!
      if let idx = chunks.firstIndex(where: { (val, sz) in val == nil && file.sz <= sz }), idx < fpos {
        chunks[idx].sz -= file.sz
        chunks[fpos] = (id: nil, sz: file.sz)
        chunks.insert(file, at: idx)
      }
    }
    let packed = chunksToPacked(chunks)

    return packed.enumerated().filter { $0.element != -1 }.map { $0.offset * $0.element }.sum()
  }
}
