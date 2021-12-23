# As you prepare to give the amphipods your solution, you notice that the
# diagram they handed you was actually folded up. As you unfold it, you
# discover an extra part of the diagram.
#
# Between the first and second lines of text that contain amphipod starting
# positions, insert the following lines:
#
#   #D#C#B#A#
#   #D#B#A#C#
#
# So, the above example now becomes:
#
# #############
# #...........#
# ###B#C#B#D###
#   #D#C#B#A#
#   #D#B#A#C#
#   #A#D#C#A#
#   #########
#
# The amphipods still want to be organized into rooms similar to before:
#
# #############
# #...........#
# ###A#B#C#D###
#   #A#B#C#D#
#   #A#B#C#D#
#   #A#B#C#D#
#   #########
#
# In this updated example, the least energy required to organize these
# amphipods is 44169:
#
# #############
# #...........#
# ###B#C#B#D###
#   #D#C#B#A#
#   #D#B#A#C#
#   #A#D#C#A#
#   #########
#
# #############
# #..........D#
# ###B#C#B#.###
#   #D#C#B#A#
#   #D#B#A#C#
#   #A#D#C#A#
#   #########
#
# #############
# #A.........D#
# ###B#C#B#.###
#   #D#C#B#.#
#   #D#B#A#C#
#   #A#D#C#A#
#   #########
#
# #############
# #A........BD#
# ###B#C#.#.###
#   #D#C#B#.#
#   #D#B#A#C#
#   #A#D#C#A#
#   #########
#
# #############
# #A......B.BD#
# ###B#C#.#.###
#   #D#C#.#.#
#   #D#B#A#C#
#   #A#D#C#A#
#   #########
#
# #############
# #AA.....B.BD#
# ###B#C#.#.###
#   #D#C#.#.#
#   #D#B#.#C#
#   #A#D#C#A#
#   #########
#
# #############
# #AA.....B.BD#
# ###B#.#.#.###
#   #D#C#.#.#
#   #D#B#C#C#
#   #A#D#C#A#
#   #########
#
# #############
# #AA.....B.BD#
# ###B#.#.#.###
#   #D#.#C#.#
#   #D#B#C#C#
#   #A#D#C#A#
#   #########
#
# #############
# #AA...B.B.BD#
# ###B#.#.#.###
#   #D#.#C#.#
#   #D#.#C#C#
#   #A#D#C#A#
#   #########
#
# #############
# #AA.D.B.B.BD#
# ###B#.#.#.###
#   #D#.#C#.#
#   #D#.#C#C#
#   #A#.#C#A#
#   #########
#
# #############
# #AA.D...B.BD#
# ###B#.#.#.###
#   #D#.#C#.#
#   #D#.#C#C#
#   #A#B#C#A#
#   #########
#
# #############
# #AA.D.....BD#
# ###B#.#.#.###
#   #D#.#C#.#
#   #D#B#C#C#
#   #A#B#C#A#
#   #########
#
# #############
# #AA.D......D#
# ###B#.#.#.###
#   #D#B#C#.#
#   #D#B#C#C#
#   #A#B#C#A#
#   #########
#
# #############
# #AA.D......D#
# ###B#.#C#.###
#   #D#B#C#.#
#   #D#B#C#.#
#   #A#B#C#A#
#   #########
#
# #############
# #AA.D.....AD#
# ###B#.#C#.###
#   #D#B#C#.#
#   #D#B#C#.#
#   #A#B#C#.#
#   #########
#
# #############
# #AA.......AD#
# ###B#.#C#.###
#   #D#B#C#.#
#   #D#B#C#.#
#   #A#B#C#D#
#   #########
#
# #############
# #AA.......AD#
# ###.#B#C#.###
#   #D#B#C#.#
#   #D#B#C#.#
#   #A#B#C#D#
#   #########
#
# #############
# #AA.......AD#
# ###.#B#C#.###
#   #.#B#C#.#
#   #D#B#C#D#
#   #A#B#C#D#
#   #########
#
# #############
# #AA.D.....AD#
# ###.#B#C#.###
#   #.#B#C#.#
#   #.#B#C#D#
#   #A#B#C#D#
#   #########
#
# #############
# #A..D.....AD#
# ###.#B#C#.###
#   #.#B#C#.#
#   #A#B#C#D#
#   #A#B#C#D#
#   #########
#
# #############
# #...D.....AD#
# ###.#B#C#.###
#   #A#B#C#.#
#   #A#B#C#D#
#   #A#B#C#D#
#   #########
#
# #############
# #.........AD#
# ###.#B#C#.###
#   #A#B#C#D#
#   #A#B#C#D#
#   #A#B#C#D#
#   #########
#
# #############
# #..........D#
# ###A#B#C#.###
#   #A#B#C#D#
#   #A#B#C#D#
#   #A#B#C#D#
#   #########
#
# #############
# #...........#
# ###A#B#C#D###
#   #A#B#C#D#
#   #A#B#C#D#
#   #A#B#C#D#
#   #########
#
# Using the initial configuration from the full diagram, what is the least
# energy required to organize the amphipods?

# using Pkg; Pkg.add("DataStructures")
using DataStructures

# cost of moving each amphipod
const amphipodcost = [1, 10, 100, 1000]

# position of the rooms from the hallway
const roomposl = 3:2:9

# win condition
const win = [1 1 1 1; 2 2 2 2; 3 3 3 3; 4 4 4 4]

# read input
rooms = zeros(Int8, 4, 4)
rooms[1:4, 2:3] = [4 4; 3 2; 2 1; 1 3]
roomposition = 1
foreach(eachline("input.txt")) do l
  m = match(r"([A-D])#([A-D])#([A-D])#([A-D])", l)
  isnothing(m) && return

  rooms[:, roomposition] = map(c -> c[1] - 'A' + 1, m)
  global roomposition += 3
end

# Attempt to move amphipods home - mutates rooms and hallway, returns cost
function movehome!(rooms, hallway)
  cost = 0

  # keep trying to move amphipods home until we can't
  while true
    progress = false

    # for each amphipod in the hallway, see if we can move them home
    for (i,c) in enumerate(hallway)
      # check for an amphipod, and see if their room is available
      c == 0 && continue
      any(r -> r != 0 && r != c, rooms[c,:]) && continue

      # assume amphipod is coming from the left of the room
      roompos = roomposl[c]
      hallwaypos = (i+1):roompos
      if i > roompos
        # amphipod is coming from the right
        hallwaypos = roompos:(i-1)
      end

      # check if the hallway is clear to move through
      any(!=(0), hallway[hallwaypos]) && continue

      # cost is the length of the hallway, plus 1 to represent moving into the
      # room, plus each space we need to move in the room, times the amphipod's
      # movement energy.
      roompos = findlast(isequal(0), rooms[c,:])
      cost += (length(hallwaypos) + roompos) * amphipodcost[c]

      # update hallway and room
      rooms[c,roompos] = c
      hallway[i] = 0

      # makin' progress
      progress = true
    end

    !progress && break
  end

  return cost
end

# adds a state to the queue, or, if such a state already exists, update the
# cost if the new cost is less
function enqueueorupdate!(queue, state, cost)
  if haskey(queue, state)
    if cost < queue[state]
      queue[state] = cost
    end
  else
    enqueue!(queue, state, cost)
  end
end

# Dijkstra's, sorta... if you consider each "neighbor" to be all possible moves
# from the current move.
State = Tuple{Matrix{Int8}, Vector{Int8}}
queue = PriorityQueue{State, Int}((rooms, zeros(Int8, 11)) => 0)
visited = Set{State}()
while length(queue) > 0
  total_cost = peek(queue).second
  state = dequeue!(queue)
  push!(visited, state)

  local (rooms,hallway) = copy.(state)

  # are we winning yet?
  if rooms == win
    println("Result: ", total_cost)
    break
  end

  # first try moving amphipods home
  total_cost += movehome!(rooms, hallway)

  # if we've reached a win condition, push it into the queue - there's nothing
  # more to do, but there may be other ways to win that are shorter
  if rooms == win
    enqueueorupdate!(queue, (rooms, hallway), total_cost)
    continue
  end

  # now find all possible moves from the current state
  for (i,room) in enumerate(eachrow(rooms))
    # if the room is empty or already has the right amphipods, skip it
    all(c -> c == 0 || c == i, room) && continue

    # find the amphipod that's moving
    newrooms = copy(rooms)
    roomidx = findfirst(!=(0), room)
    movingamphipod = room[roomidx]
    newrooms[i,roomidx] = 0
    movement = roomidx - 1

    # find where they can move to
    hallwayexit = roomposl[i]
    for pos in [1,2,4,6,8,10,11]
      # positions we move through in the hallway
      hallwaypos = pos <= hallwayexit ? (pos:hallwayexit) : (hallwayexit:pos)

      # check if hallway is empty
      any(!=(0), hallway[hallwaypos]) && continue

      # cost is number of moves to exit the room, plus number of hallway spaces
      cost = total_cost + (length(hallwaypos) + movement) * amphipodcost[movingamphipod]

      # update hallway
      newhallway = copy(hallway)
      newhallway[pos] = movingamphipod

      # update queue
      newstate = (newrooms, newhallway)
      !in(newstate, visited) && enqueueorupdate!(queue, newstate, cost)
    end
  end
end
