# Next, you need to find the largest basins so you know what areas are most
# important to avoid.
#
# A basin is all locations that eventually flow downward to a single low point.
# Therefore, every low point has a basin, although some basins are very small.
# Locations of height 9 do not count as being in any basin, and all other
# locations will always be part of exactly one basin.
#
# The size of a basin is the number of locations within the basin, including
# the low point. The example above has four basins.
#
# The top-left basin, size 3:
#
# 2199943210
# 3987894921
# 9856789892
# 8767896789
# 9899965678
#
# The top-right basin, size 9:
#
# 2199943210
# 3987894921
# 9856789892
# 8767896789
# 9899965678
#
# The middle basin, size 14:
#
# 2199943210
# 3987894921
# 9856789892
# 8767896789
# 9899965678
#
# The bottom-right basin, size 9:
#
# 2199943210
# 3987894921
# 9856789892
# 8767896789
# 9899965678
#
# Find the three largest basins and multiply their sizes together. In the above
# example, this is 9 * 14 * 9 = 1134.
#
# What do you get if you multiply together the sizes of the three largest
# basins?

# read input
const width = 100
const height = 100
field = Array{UInt16}(undef, height, width)
foreach(eachline("input.txt"), Iterators.countfrom()) do l,y
  field[y,:] = parse.(UInt16, split(l, ""))
end

# find the three largest basins
basins = Int[]
for x in 1:width, y in 1:height
  field[y, x] == 9 && continue

  if y > 1 && field[y-1, x] > 9
    if x > 1 && field[y, x-1] > 9 && field[y-1, x] != field[y, x-1]
      # merge two basins
      (consumed_basin, basinid) = (field[y-1, x], field[y, x-1])
      field[y, x] = basinid

      # set all elements from the consumed basin to the combined basin id -
      # because our loop is running in column-major order, we can iterate over
      # the linear indices of field to find our consumed basin
      foreach(1:LinearIndices(field)[y, x]) do i
        field[i] == consumed_basin && (field[i] = basinid)
      end

      # increase basinid's count and set consumed_basin to 0
      basins[basinid - 9] += basins[consumed_basin - 9]
      basins[consumed_basin - 9] = 0
    else
      field[y, x] = field[y-1, x]
    end
  elseif x > 1 && field[y, x-1] > 9
    field[y, x] = field[y, x-1]
  else
    # new basin - basin id is position in basins vector plus 9
    push!(basins, 0)
    field[y, x] = length(basins) + 9
  end

  # increase basin's size
  basins[field[y, x] - 9] += 1
end
sort!(basins; rev=true)

println("Result: ", prod(basins[1:3]))
