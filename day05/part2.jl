# Unfortunately, considering only horizontal and vertical lines doesn't give
# you the full picture; you need to also consider diagonal lines.
#
# Because of the limits of the hydrothermal vent mapping system, the lines in
# your list will only ever be horizontal, vertical, or a diagonal line at
# exactly 45 degrees. In other words:
#
# An entry like 1,1 -> 3,3 covers points 1,1, 2,2, and 3,3.
# An entry like 9,7 -> 7,9 covers points 9,7, 8,8, and 7,9.
#
# Considering all lines from the above example would now produce the following
# diagram:
#
# 1.1....11.
# .111...2..
# ..2.1.111.
# ...1.2.2..
# .112313211
# ...1.2....
# ..1...1...
# .1.....1..
# 1.......1.
# 222111....
#
# You still need to determine the number of points where at least two lines
# overlap. In the above example, this is still anywhere in the diagram with a 2
# or larger - now a total of 12 points.
#
# Consider all of the lines. At how many points do at least two lines overlap?

map = zeros(1000, 1000)
for l in eachline("input.txt")
  # parse the line
  (x1, y1, x2, y2) = parse.(Int, split(l, r",| -> "))

  # add one to each point
  if x1 == x2 || y1 == y2
    # make sure x1<x2, and y1<y2 - it simplifies the loop below
    x1 > x2 && ((x1,x2) = (x2,x1))
    y1 > y2 && ((y1,y2) = (y2,y1))

    for x in x1:x2, y in y1:y2
      map[x, y] += 1
    end
  else
    # diagonal
    for i in 0:abs(x2-x1)
      map[x1+copysign(i, x2-x1), y1+copysign(i, y2-y1)] += 1
    end
  end
end

# count points where at least two lines overlap
println("Result: ", count(>(1), map))
