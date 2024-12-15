import Foundation

enum Day13 {
  struct Game {
    let a: Coordinate
    let b: Coordinate
    let p: Coordinate
  }
  static func parseButton(_ line: String) -> Coordinate {
    do {
      let m = try /Button .: X\+(\d+), Y\+(\d+)/.wholeMatch(in: line)!
      let p: Coordinate = [Int(m.1) ?? -1, Int(m.2) ?? -1]
      return p
    } catch {
      print("error in parse: \(error)")
      return .origin
    }
  }
  static func parsePrize(_ line: String) -> Coordinate {
    do {
      let m = try /Prize: X=(\d+), Y=(\d+)/.wholeMatch(in: line)!
      let p: Coordinate = [Int(m.1) ?? -1, Int(m.2) ?? -1]
      return [p.x + 10000000000000, p.y + 10000000000000]
    } catch {
      print("error in parse: \(error)")
      return .origin
    }
  }
  static func solve(game: Game) -> Int {
    let Tx = Double(game.p.x)
    let Ty = Double(game.p.y)
    let Ax = Double(game.a.x)
    let Ay = Double(game.a.y)
    let Bx = Double(game.b.x)
    let By = Double(game.b.y)

    let b = (Ty*Ax - Tx*Ay) / (Ax*By - Bx*Ay)
    let a  = (Tx - b * Bx) / Ax
    
    //print("pressed a \(a) b \(b) = \(a*Ax + b*Bx), \(a*Ay+b*By)")

    let ai = Int(floor(a))
    let bi = Int(floor(b))
    if ai * game.a.x + bi * game.b.x == game.p.x &&
       ai * game.a.y + bi * game.b.y == game.p.y {
      return 3*ai + bi
    }
    return 0
  }
  static func part1(input: String) -> Int {
    return input
      .lines
      .chunks(ofCount: 3)
      .map { game in
        let game = Array(game) // Why do I need to do this? subscript of chunks element crashes
        let g = Game(a: parseButton(game[0]),
                    b: parseButton(game[1]),
                    p: parsePrize(game[2]))
        return g
      }
      .map(solve)
      .sum()
  }
}
