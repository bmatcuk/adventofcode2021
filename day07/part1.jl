# A giant whale has decided your submarine is its next meal, and it's much
# faster than you are. There's nowhere to run!
#
# Suddenly, a swarm of crabs (each in its own tiny submarine - it's too deep
# for them otherwise) zooms in to rescue you! They seem to be preparing to
# blast a hole in the ocean floor; sensors indicate a massive underground cave
# system just beyond where they're aiming!
#
# The crab submarines all need to be aligned before they'll have enough power
# to blast a large enough hole for your submarine to get through. However, it
# doesn't look like they'll be aligned before the whale catches you! Maybe you
# can help?
#
# There's one major catch - crab submarines can only move horizontally.
#
# You quickly make a list of the horizontal position of each crab (your puzzle
# input). Crab submarines have limited fuel, so you need to find a way to make
# all of their horizontal positions match while requiring them to spend as
# little fuel as possible.
#
# For example, consider the following horizontal positions:
#
# 16,1,2,0,4,2,7,1,2,14
#
# This means there's a crab with horizontal position 16, a crab with horizontal
# position 1, and so on.
#
# Each change of 1 step in horizontal position of a single crab costs 1 fuel.
# You could choose any horizontal position to align them all on, but the one
# that costs the least fuel is horizontal position 2:
#
# Move from 16 to 2: 14 fuel
# Move from 1 to 2: 1 fuel
# Move from 2 to 2: 0 fuel
# Move from 0 to 2: 2 fuel
# Move from 4 to 2: 2 fuel
# Move from 2 to 2: 0 fuel
# Move from 7 to 2: 5 fuel
# Move from 1 to 2: 1 fuel
# Move from 2 to 2: 0 fuel
# Move from 14 to 2: 12 fuel
#
# This costs a total of 37 fuel. This is the cheapest possible outcome; more
# expensive outcomes include aligning at position 1 (41 fuel), position 3 (39
# fuel), or position 10 (71 fuel).
#
# Determine the horizontal position that the crabs can align to using the least
# fuel possible. How much fuel must they spend to align to that position?

# read input and sort it
positions = sort!(parse.(UInt16, split(readline("input.txt"), ',')))

# Observation: if I pick a point and make all the crabs move there, it'll cost
# some amount of fuel. If I move that point one position to the left, all crabs
# to the left of the original point will spend 1 less fuel, and all crabs to
# the right will spend one more. Vice versa if I move one position to the
# right. So, if I keep track of how many crabs are left and right of my chosen
# point, and the total fuel cost of the crabs to the left and right, I could
# loop through all positions fairly quickly. Starting at position 0 (there are
# no negative positions in the input), there are no crabs to the left, but
# there may be some crabs already at position 0.
fuel_left = 0
fuel_right = sum(positions)
next_break = findfirst(>(0), positions)
num_left = 0
num_centered = next_break - 1
num_right = length(positions) - num_centered
cheapest = fuel_right
for position in 1:positions[end]
  # calculate new fuels
  global (fuel_left, fuel_right) = (fuel_left + num_left + num_centered, fuel_right - num_right)
  if fuel_left + fuel_right < cheapest
    global cheapest = fuel_left + fuel_right
  end

  # calculate how many crabs are already at this position (ie, fuel 0)
  new_num_centered = 0
  if position == positions[next_break]
    new_next_break = findnext(>(position), positions, next_break)
    if isnothing(new_next_break)
      # honestly, when this happens, we can break - continuing to move to the
      # right will only increase fuel cost because all crabs are to the left
      break
    end

    new_num_centered = new_next_break - next_break
    global next_break = new_next_break
  end

  # update crab counts
  global (num_left, num_centered, num_right) = (num_left + num_centered, new_num_centered, num_right - new_num_centered)
end

println("Cheapest fuel cost: ", cheapest)
