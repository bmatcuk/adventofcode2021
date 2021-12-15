# You've almost reached the exit of the cave, but the walls are getting closer
# together. Your submarine can barely still fit, though; the main problem is
# that the walls of the cave are covered in chitons, and it would be best not
# to bump any of them.
#
# The cavern is large, but has a very low ceiling, restricting your motion to
# two dimensions. The shape of the cavern resembles a square; a quick scan of
# chiton density produces a map of risk level throughout the cave (your puzzle
# input). For example:
#
# 1163751742
# 1381373672
# 2136511328
# 3694931569
# 7463417111
# 1319128137
# 1359912421
# 3125421639
# 1293138521
# 2311944581
#
# You start in the top left position, your destination is the bottom right
# position, and you cannot move diagonally. The number at each position is its
# risk level; to determine the total risk of an entire path, add up the risk
# levels of each position you enter (that is, don't count the risk level of
# your starting position unless you enter it; leaving it adds no risk to your
# total).
#
# Your goal is to find a path with the lowest total risk. In this example, a
# path with the lowest total risk is highlighted here:
#
# 1163751742
# 1381373672
# 2136511328
# 3694931569
# 7463417111
# 1319128137
# 1359912421
# 3125421639
# 1293138521
# 2311944581
#
# The total risk of this path is 40 (the starting position is never entered, so
# its risk is not counted).
#
# What is the lowest total risk of any path from the top left to the bottom
# right?

# load risk map
riskmap = hcat(map(l -> parse.(Int8, split(l, "")), eachline("input.txt"))...)
(width, height) = size(riskmap)

# some data structures to track things
cost = zeros(Int, size(riskmap))
queue = [(1,1)]
function update_cost(x, y, c)
  c += riskmap[x,y]
  if cost[x,y] == 0
    # first time setting a cost on this node - add to queue
    push!(queue, (x,y))
  elseif cost[x,y] <= c
    # we found a cheaper route to this node already
    return
  end
  cost[x,y] = c
end

# Dijkstra's
visited = falses(size(riskmap))
while !visited[width, height]
  # find the next node with the smallest tentative cost
  sort!(queue; by=((x,y),) -> cost[x,y], rev=true)
  (x,y) = pop!(queue)
  visited[x,y] = true

  # update cost of neighbors
  c = cost[x,y]
  x > 1 && !visited[x-1, y] && update_cost(x-1, y, c)
  y > 1 && !visited[x, y-1] && update_cost(x, y-1, c)
  x < width && !visited[x+1, y] && update_cost(x+1, y, c)
  y < height && !visited[x, y+1] && update_cost(x, y+1, c)
end

println("Result: ", cost[width, height])
