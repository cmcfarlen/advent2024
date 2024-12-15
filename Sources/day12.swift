enum Day12 {
  struct Region {
    let plant: Character
    var coords: Set<Coordinate>

    var area: Int {
      coords.count
    }
    var perimeter: Int {
      func adjCnt(_ c: Coordinate) -> Int {
        coords.remove { $0 == c }.filter { $0.adjacent(to: c) }.count
      }
      return coords.map(adjCnt).map { 4 - $0 }.sum()
    }
    var cost: Int {
      area * perimeter
    }
  }

  static func dumpRegion(into grid: inout [[Character]], _ r: Region) -> [[Character]] {
    for c in r.coords {
      grid[c] = r.plant
    }

    return grid
  }

  static func createRegions(for grid: [[Character]]) -> [Region] {
    return grid.coords.reduce(into: []) { regions, coord in
      let plant = grid[coord]!
      let idxs = regions.indices.filter { idx in
        regions[idx].plant == plant && regions[idx].coords.contains { x in x.adjacent(to: coord) }
      }
      if idxs.count == 0 {
        regions.append(Region(plant: plant, coords: [coord]))
      } else if idxs.count == 1 {
        regions[idxs[0]].coords.insert(coord)
      } else {
        regions[idxs[0]] = idxs.dropFirst().reduce(into: regions[idxs[0]]) { r, idx in
          r.coords = r.coords.union(regions[idx].coords)
        }
        regions[idxs[0]].coords.insert(coord)
        for idx in idxs.dropFirst() {
          regions.remove(at: idx)
        }
      }
    }
  }

  static func part1(input: String) -> Int {
    let grid = input.grid
    let regions = createRegions(for: grid)

    return regions.map(\.cost).sum()
  }

  static func part2(input: String) -> Int {
    let grid = input.grid
    let regions = createRegions(for: grid)

    let topLeft = "..\n.*".grid
    let topRight = "..\n*.".grid
    let top = "..\n**".grid
    let bottom = "**\n..".grid
    let bottomLeft = ".*\n..".grid
    let bottomRight = "*.\n..".grid
    
    let hChecks = [
      (1, [topLeft, top, topRight]),
      (2, [bottomLeft, bottom, bottomRight])
    ]
    
    func match(_ r: Region, kernel: [[Character]], at: Coordinate) -> Bool {
      let checks = Coordinate.origin.cartesian(ofSize: 2)
      return checks.allSatisfy { pt in
        let c = pt + at
        print("checking \(pt): c \(c) k \(kernel[pt]!) v \(r.coords.contains(c)) -> \(grid[c]!)")
        return switch kernel[pt]! {
          case "*": r.coords.contains(c)
          default: !r.coords.contains(c)
        }
      }
    }

    func matchRange(_ r: Region, bounds: Box, kStart: [[Character]], kEnd: [[Character]]) {
      let chunks = bb.upperLeft.cartesian(width: bb.width+1, height: bb.height+1)
        .chunks(ofCount: bounds.width)
        .map { row in
          print("row \(row)")
          return row.chunked { c in
            let pt = c + [-1, -1]
            for (v, chks) in hChecks {
              for k in chks {
                if match(r, kernel: k, at: pt) {
                  return v
                }
              }
            }
            return -1
          }
        }

      for ch in chunks {
        for (v, cds) in ch {
          print("v \(v) \(cds)")
        }
      }
    }

    let a = regions[1]
    var t = grid.cleared()
    _ = dumpRegion(into: &t, a)

    print(t.display)

    let bb = Box(from: a.coords)
    print("ul \(bb.upperLeft) ur \(bb.upperRight) ll \(bb.lowerLeft) lr \(bb.lowerRight) w \(bb.width) h \(bb.height)")

    let start = bb.upperLeft + [-1,-1]

    // find top edges
    let matches = match(a, kernel: topLeft, at: start)

    print("Matches \(start): \(matches)")

    matchRange(a, bounds: bb, kStart: topLeft, kEnd: topRight)

    return 0
  }
}
