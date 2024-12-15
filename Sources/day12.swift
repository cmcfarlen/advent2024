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

/*
    var t = grid.cleared()
    for r in regions {
      print("plant \(r.plant) area \(r.area) * \(r.perimeter) = \(r.cost) ")
      _ = dumpRegion(into: &t, r)
    }

    print(t.display)
    assert(t == grid)
    */

    return regions.map(\.cost).sum()
  }
}
