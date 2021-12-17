# Maybe a fancy trick shot isn't the best idea; after all, you only have one
# probe, so you had better not miss.
#
# To get the best idea of what your options are for launching the probe, you
# need to find every initial velocity that causes the probe to eventually be
# within the target area after any step.
#
# In the above example, there are 112 different initial velocity values that
# meet these criteria:
#
# 23,-10  25,-9   27,-5   29,-6   22,-6   21,-7   9,0     27,-7   24,-5
# 25,-7   26,-6   25,-5   6,8     11,-2   20,-5   29,-10  6,3     28,-7
# 8,0     30,-6   29,-8   20,-10  6,7     6,4     6,1     14,-4   21,-6
# 26,-10  7,-1    7,7     8,-1    21,-9   6,2     20,-7   30,-10  14,-3
# 20,-8   13,-2   7,3     28,-8   29,-9   15,-3   22,-5   26,-8   25,-8
# 25,-6   15,-4   9,-2    15,-2   12,-2   28,-9   12,-3   24,-6   23,-7
# 25,-10  7,8     11,-3   26,-7   7,1     23,-9   6,0     22,-10  27,-6
# 8,1     22,-8   13,-4   7,6     28,-6   11,-4   12,-4   26,-9   7,4
# 24,-10  23,-8   30,-8   7,0     9,-1    10,-1   26,-5   22,-9   6,5
# 7,5     23,-6   28,-10  10,-2   11,-1   20,-9   14,-2   29,-7   13,-3
# 23,-5   24,-8   27,-9   30,-7   28,-5   21,-10  7,9     6,6     21,-5
# 27,-10  7,2     30,-9   21,-8   22,-7   24,-9   20,-6   6,9     29,-5
# 8,-2    27,-8   30,-5   24,-7
#
# How many distinct initial velocity values cause the probe to be within the
# target area after any step?

# read input
(targetx1, targetx2, targety1, targety2) = parse.(
  Int,
  match(
    r"x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)",
    readline("input.txt")
  )
)

# The sum of consecutive integers from 0 to n is n(n+1)/2. Using this, we can
# find the minimum possible starting x velocity by solving n(n+1)/2=targetx1-1.
# Anything equal to or less than that result will fall to a velocity of zero
# before reaching the target zone.
# n(n+1)/2=targetx1-1
# n^2 + n - 2*(targetx1-1) = 0
# n = (-b +- sqrt(b^2 - 4ac)) / 2a
minimum_xvel = floor(Int, sqrt(1 + 8 * (targetx1-1)) / 2)

# Our minimum starting y velocity is equal to the minimum target y because
# anything less than that will overshoot our target y on the very first step.
# See part 1 for an explanation of how to find the maximum starting y velocity.
#
# From a giving y velocity, we can determine how many steps it'll take to reach
# the target y. From that, we can find what x velocities will get us in the
# target x range. Then we increment our starting y velocity and do it again.
cnt = 0
for yvel in targety1:(abs(targety1)-1)
  inityvel = yvel

  # I feel like there's some mathematical way to calculate how many steps it'll
  # take to reach the target y zone with an initial y velocity, but I can't
  # brain it at the moment, so...
  steps = 0
  if yvel > 0
    # I did brain this little optimization: when our initial y velocity is
    # positive, it'll take 2*yvel+1 steps to get to a y position of 0, at which
    # point our velocity will be -yvel-1
    steps = 2 * yvel + 1
    yvel = -yvel - 1
  end

  # find the minimum number of steps required to reach the target y range
  # yvel is guaranteed non-positive at this point
  ypos = 0
  while ypos > targety2
    ypos += yvel
    yvel -= 1
    steps += 1
  end

  # a given initial y velocity may hit the target y range more than once - we
  # need to keep track of the x velocities we've already matched so we don't
  # count them again
  matched_x = Int[]
  while ypos >= targety1
    # Maximum x velocity is the point where steps(max+(max-steps+1))/2=targetx2
    # steps*max + steps*max - steps^2 + steps = 2*targetx2
    # 2*steps*max = 2*targetx2 + steps^2 - steps
    # max = targetx2/steps + steps/2 - 1/2
    # This isn't quite right, but my brain is done.
    for xvel in minimum_xvel:floor(Int, targetx2 / steps + steps / 2 - 0.5)
      initxvel = xvel
      xpos = 0
      for _ in 1:steps
        xpos += xvel
        xvel -= 1
        xvel == 0 && break
      end
      if targetx1 <= xpos <= targetx2 && !in(initxvel, matched_x)
        global cnt += 1
        println(initxvel, ",", inityvel, ": ", steps, " - ", xpos, ",", ypos)
        push!(matched_x, initxvel)
      end
    end

    ypos += yvel
    yvel -= 1
    steps += 1
  end
end

println("Result: ", cnt)
