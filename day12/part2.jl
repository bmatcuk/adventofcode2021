# After reviewing the available paths, you realize you might have time to visit
# a single small cave twice. Specifically, big caves can be visited any number
# of times, a single small cave can be visited at most twice, and the remaining
# small caves can be visited at most once. However, the caves named start and
# end can only be visited exactly once each: once you leave the start cave, you
# may not return to it, and once you reach the end cave, the path must end
# immediately.
#
# Now, the 36 possible paths through the first example above are:
#
# start,A,b,A,b,A,c,A,end
# start,A,b,A,b,A,end
# start,A,b,A,b,end
# start,A,b,A,c,A,b,A,end
# start,A,b,A,c,A,b,end
# start,A,b,A,c,A,c,A,end
# start,A,b,A,c,A,end
# start,A,b,A,end
# start,A,b,d,b,A,c,A,end
# start,A,b,d,b,A,end
# start,A,b,d,b,end
# start,A,b,end
# start,A,c,A,b,A,b,A,end
# start,A,c,A,b,A,b,end
# start,A,c,A,b,A,c,A,end
# start,A,c,A,b,A,end
# start,A,c,A,b,d,b,A,end
# start,A,c,A,b,d,b,end
# start,A,c,A,b,end
# start,A,c,A,c,A,b,A,end
# start,A,c,A,c,A,b,end
# start,A,c,A,c,A,end
# start,A,c,A,end
# start,A,end
# start,b,A,b,A,c,A,end
# start,b,A,b,A,end
# start,b,A,b,end
# start,b,A,c,A,b,A,end
# start,b,A,c,A,b,end
# start,b,A,c,A,c,A,end
# start,b,A,c,A,end
# start,b,A,end
# start,b,d,b,A,c,A,end
# start,b,d,b,A,end
# start,b,d,b,end
# start,b,end
#
# The slightly larger example above now has 103 paths through it, and the even
# larger example now has 3509 paths through it.
#
# Given these new rules, how many paths through this cave system are there?

# load data into a dictionary
caves = Dict{String, Vector{String}}()
foreach(eachline("input.txt")) do l
  (k, v) = split(l, '-')
  if haskey(caves, k)
    push!(caves[k], v)
  else
    caves[k] = [v]
  end
  if haskey(caves, v)
    push!(caves[v], k)
  else
    caves[v] = [k]
  end
end

# A dictionary of small caves names to an arbitrary index. Used to map small
# caves to a BitVector of visited caves.
small_cave_idxs = Dict([(k,i) for (i,k) in enumerate(filter(c -> all(islowercase, c), keys(caves)))])

# Implements a BFS of caves - returns the number of ways to reach end
function visit_cave(cave::String, visited::BitVector, has_double_visited::Bool)
  # have we reached end?
  if cave == "end"
    return 1
  end

  # if cave is a small cave, mark it visited
  if haskey(small_cave_idxs, cave)
    visited = copy(visited)
    visited[small_cave_idxs[cave]] = true
  end

  # recurse
  foldl(caves[cave]; init=0) do acc, adjacent_cave
    if haskey(small_cave_idxs, adjacent_cave)
      if (has_double_visited && visited[small_cave_idxs[adjacent_cave]]) || adjacent_cave == "start"
        # we've already visited this small cave, and already double visited a
        # small cave, so we can't go this way
        return acc
      else
        # if either condition is false, it's either our first time visiting
        # this cave, or we can use it as our one revisit
        return acc + visit_cave(adjacent_cave, visited, has_double_visited || visited[small_cave_idxs[adjacent_cave]])
      end
    else
      # can always go into a large cave
      return acc + visit_cave(adjacent_cave, visited, has_double_visited)
    end
  end
end

# Do eet!
cnt = visit_cave("start", falses(length(small_cave_idxs)), false)
println("Result: ", cnt)
