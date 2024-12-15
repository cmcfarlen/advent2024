enum Day4 {
  static func part1(input: String) -> Int {
    let kernels = [
      """
      XMAS
      ****
      ****
      ****
      """,
      """
      SAMX
      ****
      ****
      ****
      """,
      """
      S***
      *A**
      **M*
      ***X
      """,
      """
      X***
      *M**
      **A*
      ***S
      """,
      """
      ***S
      **A*
      *M**
      X***
      """,
      """
      ***X
      **M*
      *A**
      S***
      """,
      """
      X***
      M***
      A***
      S***
      """,
      """
      S***
      A***
      M***
      X***
      """,

    ].map(\.grid)
    let puzzle = input.grid

    let m =  puzzle
     .coords
     .flatMap { pt in
        kernels.compactMap { kernel in
          puzzle.matches(kernel, offset: pt) ? 1 : nil
        }
     }

    return m.count
  }
  static func part2(input: String) -> Int {
    let kernels = [
      """
      M*S
      *A*
      M*S
      """,
      """
      S*M
      *A*
      S*M
      """,
      """
      S*S
      *A*
      M*M
      """,
      """
      M*M
      *A*
      S*S
      """
    ].map(\.grid)
    let puzzle = input.grid

    let m =  puzzle
     .coords
     .flatMap { pt in
        kernels.compactMap { kernel in
          puzzle.matches(kernel, offset: pt) ? 1 : nil
        }
     }

    return m.count
  }
}
