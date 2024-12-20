today := `date +%d`

run day=today part="1":
  swift run advent2024 {{day}} {{part}}

release day=today part="1":
  swift build -c release
  .build/release/advent2024 {{day}} {{part}}

ex day=today:
  vim input/day{{day}}ex.txt

real day=today:
  vim input/day{{day}}real.txt

useex day=today:
  cp input/day{{day}}ex.txt input/day{{day}}.txt

usereal day=today:
  cp input/day{{day}}real.txt input/day{{day}}.txt
