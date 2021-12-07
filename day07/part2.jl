# The crabs don't seem interested in your proposed solution. Perhaps you
# misunderstand crab engineering?
#
# As it turns out, crab submarine engines don't burn fuel at a constant rate.
# Instead, each change of 1 step in horizontal position costs 1 more unit of
# fuel than the last: the first step costs 1, the second step costs 2, the
# third step costs 3, and so on.
#
# As each crab moves, moving further becomes more expensive. This changes the
# best horizontal position to align them all on; in the example above, this
# becomes 5:
#
# Move from 16 to 5: 66 fuel
# Move from 1 to 5: 10 fuel
# Move from 2 to 5: 6 fuel
# Move from 0 to 5: 15 fuel
# Move from 4 to 5: 1 fuel
# Move from 2 to 5: 6 fuel
# Move from 7 to 5: 3 fuel
# Move from 1 to 5: 10 fuel
# Move from 2 to 5: 6 fuel
# Move from 14 to 5: 45 fuel
#
# This costs a total of 168 fuel. This is the new cheapest possible outcome;
# the old alignment position (2) now costs 206 fuel instead.
#
# Determine the horizontal position that the crabs can align to using the least
# fuel possible so they can make you an escape route! How much fuel must they
# spend to align to that position?

# read input and sort it
positions = sort!(parse.(UInt16, split(readline("input.txt"), ',')))

# Similar to part 1 except that as the position moves right, the fuel cost to
# the left increases by the sum of the difference between the current position
# and the crab's starting position. The fuel to the right decreases by the sum
# of the difference between the crab's previous position and the previous
# "current" position.
fuel_left = 0
fuel_right = mapreduce(p -> (p * (p+1)) >> 1, +, positions)
right_idx = findfirst(>(0), positions)
cheapest = fuel_right
for position in 1:positions[end]
  # calculate new fuels
  left = @view positions[1:(right_idx - 1)]
  right = @view positions[right_idx:end]
  global (fuel_left, fuel_right) = (fuel_left + sum(position .- left), fuel_right - sum(right .- (position - 1)))
  if fuel_left + fuel_right < cheapest
    global cheapest = fuel_left + fuel_right
  end

  # potentially update right_idx
  if position == positions[right_idx]
    global right_idx = findnext(>(position), positions, right_idx)
    if isnothing(right_idx)
      # honestly, when this happens, we can break - continuing to move to the
      # right will only increase fuel cost because all crabs are to the left
      break
    end
  end
end

println("Cheapest fuel cost: ", cheapest)
