# A group of amphipods notice your fancy submarine and flag you down. "With
# such an impressive shell," one amphipod says, "surely you can help us with a
# question that has stumped our best scientists."
#
# They go on to explain that a group of timid, stubborn amphipods live in a
# nearby burrow. Four types of amphipods live there: Amber (A), Bronze (B),
# Copper (C), and Desert (D). They live in a burrow that consists of a hallway
# and four side rooms. The side rooms are initially full of amphipods, and the
# hallway is initially empty.
#
# They give you a diagram of the situation (your puzzle input), including
# locations of each amphipod (A, B, C, or D, each of which is occupying an
# otherwise open space), walls (#), and open space (.).
#
# For example:
#
# #############
# #...........#
# ###B#C#B#D###
#   #A#D#C#A#
#   #########
#
# The amphipods would like a method to organize every amphipod into side rooms
# so that each side room contains one type of amphipod and the types are sorted
# A-D going left to right, like this:
#
# #############
# #...........#
# ###A#B#C#D###
#   #A#B#C#D#
#   #########
#
# Amphipods can move up, down, left, or right so long as they are moving into
# an unoccupied open space. Each type of amphipod requires a different amount
# of energy to move one step: Amber amphipods require 1 energy per step, Bronze
# amphipods require 10 energy, Copper amphipods require 100, and Desert ones
# require 1000. The amphipods would like you to find a way to organize the
# amphipods that requires the least total energy.
#
# However, because they are timid and stubborn, the amphipods have some extra
# rules:
#
# - Amphipods will never stop on the space immediately outside any room. They
#   can move into that space so long as they immediately continue moving.
#   (Specifically, this refers to the four open spaces in the hallway that are
#   directly above an amphipod starting position.)
# - Amphipods will never move from the hallway into a room unless that room is
#   their destination room and that room contains no amphipods which do not
#   also have that room as their own destination. If an amphipod's starting
#   room is not its destination room, it can stay in that room until it leaves
#   the room.  (For example, an Amber amphipod will not move from the hallway
#   into the right three rooms, and will only move into the leftmost room if
#   that room is empty or if it only contains other Amber amphipods.)
# - Once an amphipod stops moving in the hallway, it will stay in that spot
#   until it can move into a room. (That is, once any amphipod starts moving,
#   any other amphipods currently in the hallway are locked in place and will
#   not move again until they can move fully into a room.)
#
# In the above example, the amphipods can be organized using a minimum of 12521
# energy. One way to do this is shown below.
#
# Starting configuration:
#
# #############
# #...........#
# ###B#C#B#D###
#   #A#D#C#A#
#   #########
#
# One Bronze amphipod moves into the hallway, taking 4 steps and using 40
# energy:
#
# #############
# #...B.......#
# ###B#C#.#D###
#   #A#D#C#A#
#   #########
#
# The only Copper amphipod not in its side room moves there, taking 4 steps and
# using 400 energy:
#
# #############
# #...B.......#
# ###B#.#C#D###
#   #A#D#C#A#
#   #########
#
# A Desert amphipod moves out of the way, taking 3 steps and using 3000 energy,
# and then the Bronze amphipod takes its place, taking 3 steps and using 30
# energy:
#
# #############
# #.....D.....#
# ###B#.#C#D###
#   #A#B#C#A#
#   #########
#
# The leftmost Bronze amphipod moves to its room using 40 energy:
#
# #############
# #.....D.....#
# ###.#B#C#D###
#   #A#B#C#A#
#   #########
#
# Both amphipods in the rightmost room move into the hallway, using 2003 energy
# in total:
#
# #############
# #.....D.D.A.#
# ###.#B#C#.###
#   #A#B#C#.#
#   #########
#
# Both Desert amphipods move into the rightmost room using 7000 energy:
#
# #############
# #.........A.#
# ###.#B#C#D###
#   #A#B#C#D#
#   #########
#
# Finally, the last Amber amphipod moves into its room, using 8 energy:
#
# #############
# #...........#
# ###A#B#C#D###
#   #A#B#C#D#
#   #########
#
# What is the least energy required to organize the amphipods?

# using Pkg; Pkg.add("DataStructures")
using DataStructures

# cost of moving each amphipod
const amphipodcost = [1, 10, 100, 1000]

# position of the rooms from the hallway
const roomposl = 3:2:9

# win condition
const win = [1 1; 2 2; 3 3; 4 4]

# read input
rooms = zeros(Int8, 4, 2)
roomposition = 1
foreach(eachline("input.txt")) do l
  m = match(r"([A-D])#([A-D])#([A-D])#([A-D])", l)
  isnothing(m) && return

  rooms[:, roomposition] = map(c -> c[1] - 'A' + 1, m)
  global roomposition += 1
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
      rooms[c,:] != [0,0] && rooms[c,:] != [0,c] && continue

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
      # room, times the amphipod's movement energy.
      cost += (length(hallwaypos) + 1) * amphipodcost[c]

      # update hallway and room
      hallway[i] = 0
      if rooms[c,2] == 0
        # room was empty so had to move one additional space
        rooms[c,2] = c
        cost += amphipodcost[c]
      else
        rooms[c,1] = c
      end

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
    (room == [0,0] || room == [0,i] || room == [i,i]) && continue

    # find the amphipod that's moving
    newrooms = copy(rooms)
    movingamphipod = room[1]
    movement = 0
    if movingamphipod == 0
      movingamphipod = room[2]
      movement += 1
      newrooms[i,2] = 0
    else
      newrooms[i,1] = 0
    end

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
