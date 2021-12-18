# You notice a second question on the back of the homework assignment:
#
# What is the largest magnitude you can get from adding only two of the
# snailfish numbers?
#
# Note that snailfish addition is not commutative - that is, x + y and y + x
# can produce different results.
#
# Again considering the last example homework assignment above:
#
# [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
# [[[5,[2,8]],4],[5,[[9,9],0]]]
# [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
# [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
# [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
# [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
# [[[[5,4],[7,7]],8],[[8,3],8]]
# [[9,3],[[9,9],[6,[4,9]]]]
# [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
# [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
#
# The largest magnitude of the sum of any two snailfish numbers in this list is
# 3993. This is the magnitude of [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]] +
# [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]], which reduces to
# [[[[7,8],[6,6]],[[6,0],[7,7]]],[[[7,8],[8,8]],[[7,9],[0,6]]]].
#
# What is the largest magnitude of any sum of two different snailfish numbers
# from the homework assignment?

# read input
lines = map(eachline("input.txt")) do l
  r = []
  stack = [r]

  # first character will always be an opening bracket - skip it
  for c in l[2:end]
    # skip commas - numbers are always 1 digit in input, so we don't need to do
    # anything special with commas
    c == ',' && continue
    if c == '['
      nextpair = []
      push!(stack[end], nextpair)
      push!(stack, nextpair)
    elseif c == ']'
      pop!(stack)
    else
      # must be a number
      push!(stack[end], c - '0')
    end
  end
  return r
end

# utility function to handle explosions
function do_explosion(l)
  last_number = nothing
  add_to_next = nothing
  has_explosion = false
  exploder = function (p, depth)
    has_explosion && isnothing(add_to_next) && return p
    if depth == 5 && !has_explosion
      if !isnothing(last_number)
        last_number[1][last_number[2]] += p[1]
      end
      add_to_next = p[2]
      has_explosion = true
      return 0
    end

    if isa(p[1], Int)
      if isnothing(add_to_next)
        last_number = (p, 1)
      else
        p[1] += add_to_next
        add_to_next = nothing
        return p
      end
    else
      p[1] = exploder(p[1], depth + 1)
    end
    if isa(p[2], Int)
      if isnothing(add_to_next)
        last_number = (p, 2)
      else
        p[2] += add_to_next
        add_to_next = nothing
        return p
      end
    else
      p[2] = exploder(p[2], depth + 1)
    end
    return p
  end
  exploder(l, 1)
  return has_explosion
end

# utility function for splits
function do_split(l)
  had_split = false
  splitter = function (p)
    had_split && return p
    if isa(p, Int)
      if p >= 10
        (d,r) = divrem(p, 2)
        had_split = true
        return Any[d, d+r]
      end
      return p
    end
    p[1] = splitter(p[1])
    p[2] = splitter(p[2])
    return p
  end
  splitter(l)
  return had_split
end

# sum
function addition(a, b)
  r = Any[deepcopy(a), deepcopy(b)]
  while true
    do_explosion(r) || do_split(r) || break
  end
  return r
end

# find magnitude
function magnitude(p)
  isa(p, Int) && return p
  3 * magnitude(p[1]) + 2 * magnitude(p[2])
end

# do eet
largest_magnitude = 0
for i in 1:length(lines), j in 1:length(lines)
  i == j && continue
  m = magnitude(addition(lines[i], lines[j]))
  if m > largest_magnitude
    global largest_magnitude = m
  end
end

println("Result: ", largest_magnitude)
