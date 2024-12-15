enum Day14 {
  static let bounds = Box(width: 101, height: 103)


  // all of this math stuff turned out to be not the right thing at all

  static func xyFuncs(_ p: Coordinate, _ v: Coordinate) -> (xofy: (_ y: Int)->Int, yofx: (_ x: Int)->Int) {
    (
    { y in
       //p.x - (v.x*p.y) / v.y - (v.x * y) / v.y
       (v.x*y)/v.y - v.x*p.y/v.y + p.x
    },
    { x in
       (v.y*x / v.x) + p.y - (v.y * p.x) / v.x
    }
    )
  }

  static func boxIntercepts(_ p: Coordinate, _ v: Coordinate) -> [Coordinate]
   {
   //let y0 = p.y - (v.y * p.x) / v.x
   //let x0 = p.x - (v.x*p.y) / v.y

   let (xofy, yofx) = xyFuncs(p, v)

   // vector will only intercect at two points
   return [[bounds.left, yofx(bounds.left)],
           [bounds.right, yofx(bounds.right)],
           [xofy(bounds.top), bounds.top],
           [xofy(bounds.bottom), bounds.bottom]]//.filter {bounds.contains($0)}
  }

    // x and y intercept
    //let intercepts = boxIntercepts(p, v)
    // length of the line segment
    //let endP = p + v * t
    //let traveled = endP - p
    // remaining distance
    // intercept + distance
    //return (intercepts, endP, traveled)

  // end of dumb maths

  static func moveBot(_ pin: Coordinate, _ v: Coordinate, _ t: Int) -> Coordinate {

    var p = pin
    for _ in 0..<t {
      p = bounds.wrap(p + v)
    }
    return p
  }

  static func parse(input: String) -> [(p: Coordinate, v: Coordinate)] {
    input.lines
      .map {
        $0.split(separator: " ")
          .map {
            Coordinate(fromArray: $0.split(separator: "=")
                .dropFirst()
                .flatMap {
                  $0.split(separator: ",")
                    .map {
                      Int($0)!
                    }
                }
            )
          }
      }
      .map {
        (p: $0[0], v: $0[1])
      }
  }

  static func part1(input: String) -> Int {
    let bots = parse(input: input)

    let answer = bots.map {
        moveBot($0.p, $0.v, 100)
    }

    var g: [[Int]] = bounds.grid(with: 0)
    for p in answer {
      g[p] = g[p, default: 0] + 1
    }
    print(g.display)

    return bounds.divide()
      .map { bx in
        answer.reduce(0) { bx.contains($1) ? $0 + 1 : $0 }
      }
      .show()
      .reduce(1) { $0 * $1 }
  }

  static func part2(input: String) -> Int {
    var bots = parse(input: input)
    var i = 0

    start: while true {
      var g: [[String]] = bounds.grid(with: " ")

      print("Second \(i)")
      bots = bots.map { b in
        (p: moveBot(b.p, b.v, 1), v: b.v)
      }
      i += 1

      for p in bots {
        if let x = g[p.p], x == "*" {
          continue start
        }
        g[p.p] = "*"
      }

      print(g.display)
      break
    }

    return 0
  }
}
