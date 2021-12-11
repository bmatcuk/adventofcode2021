# It seems like the individual flashes aren't bright enough to navigate.
# However, you might have a better option: the flashes seem to be
# synchronizing!
#
# In the example above, the first time all octopuses flash simultaneously is
# step 195:
#
# After step 193:
#
# 5877777777
# 8877777777
# 7777777777
# 7777777777
# 7777777777
# 7777777777
# 7777777777
# 7777777777
# 7777777777
# 7777777777
#
# After step 194:
# 6988888888
# 9988888888
# 8888888888
# 8888888888
# 8888888888
# 8888888888
# 8888888888
# 8888888888
# 8888888888
# 8888888888
#
# After step 195:
# 0000000000
# 0000000000
# 0000000000
# 0000000000
# 0000000000
# 0000000000
# 0000000000
# 0000000000
# 0000000000
# 0000000000
#
# If you can calculate the exact moments when the octopuses will all flash
# simultaneously, you should be able to navigate through the cavern. What is
# the first step during which all octopuses flash?

# load grid
grid = hcat(map(eachline("input.txt")) do l
  parse.(Int8, split(l, ""))
end...)

# simulate until they all flash
for i in Iterators.countfrom()
  # increment the energy of all octopuses
  grid .+= 1

  # find flashes
  all_flashes = falses(10, 10)
  flashes = grid .> 9
  while any(flashes)
    # increment the energy of the octopuses around flashing octopuses
    @views begin
      grid[1:9, 1:9] .+= flashes[2:10, 2:10]
      grid[1:10, 1:9] .+= flashes[1:10, 2:10]
      grid[2:10, 1:9] .+= flashes[1:9, 2:10]
      grid[2:10, 1:10] .+= flashes[1:9, 1:10]
      grid[2:10, 2:10] .+= flashes[1:9, 1:9]
      grid[1:10, 2:10] .+= flashes[1:10, 1:9]
      grid[1:9, 2:10] .+= flashes[2:10, 1:9]
      grid[1:9, 1:10] .+= flashes[2:10, 1:10]
    end

    # update all_flashes and see if there are any cascading flashes
    all_flashes = all_flashes .|| flashes
    flashes = grid .> 9 .&& .!all_flashes
  end

  # if they've all flashed, we're done
  if all(all_flashes)
    println("All flash at: ", i)
    break
  end

  # set any flashing octopuses back to zero
  grid[all_flashes] .= 0
end
