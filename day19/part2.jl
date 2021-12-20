# Sometimes, it's a good idea to appreciate just how big the ocean is. Using
# the Manhattan distance, how far apart do the scanners get?
#
# In the above example, scanners 2 (1105,-1205,1229) and 3 (-92,-2380,-20) are
# the largest Manhattan distance apart. In total, they are 1197 + 1175 + 1249 =
# 3621 units apart.
#
# What is the largest Manhattan distance between any two scanners?

# read data
iter = eachline("input.txt")
scanners = Vector{Tuple{Int32, Int32, Int32}}[]
while !isnothing(iterate(iter))
  # while condition will consume the "--- scanner X ---" lines
  beacons = map(l -> tuple(parse.(Int32, split(l, ','))...), Iterators.takewhile(l -> l != "", iter))
  push!(scanners, beacons)
end

# Utility iterator to compute all combinations of 2 indices
struct Permutations
  len::Int
end

function Base.iterate(P::Permutations, (i,j)=(1,1))
  j += 1
  if j > P.len
    i += 1
    j = i + 1
    j > P.len && return nothing
  end
  idxs = (i,j)
  return (idxs, idxs)
end

Base.length(P::Permutations) = binomial(P.len, 2)

Base.eltype(P::Permutations) = Tuple{Int, Int}

# Distance is the sqrt of the sum of squares of differences. I'm going to leave
# off the sqrt bit so I'm not beholden to floating point errors.
function distance(scanneridx, i, j)
  (x1,y1,z1) = scanners[scanneridx][i]
  (x2,y2,z2) = scanners[scanneridx][j]
  (widen(x2)-x1)^2 + (widen(y2)-y1)^2 + (widen(z2)-z1)^2
end

distance(scanneridx, (i,j)) = distance(scanneridx, i, j)

distance(scanneridx) = (p) -> distance(scanneridx, p)

# Utility thot finds the distance between all beacons in the a scanner. This is
# used to find points that potentially match between two scanners.
struct RefDistances
  idxs::Vector{Tuple{Int, Int}}
  dists::Vector{Int}
  function RefDistances(baseidx)
    base = scanners[baseidx]
    idxs = collect(Permutations(length(base)))
    dists = map(distance(1), idxs)
    sortedidx = sortperm(dists)
    permute!(idxs, sortedidx)
    permute!(dists, sortedidx)
    new(idxs, dists)
  end
end

Base.getindex(R::RefDistances, i::Int) = R.idxs[i]

function Base.findfirst(R::RefDistances, dist)
  distidx = searchsortedfirst(R.dists, dist)
  distidx <= length(R.dists) && R.dists[distidx] == dist ? distidx : nothing
end

# Functions to re-orient points
const reorientfuncs = [
  identity, ((x,y,z),) -> (-x,-y,z), ((x,y,z),) -> (-x,-z,-y),
  ((x,y,z),) -> (-x,y,-z), ((x,y,z),) -> (-x,z,y), ((x,y,z),) -> (-y,-x,-z),
  ((x,y,z),) -> (-y,-z,x), ((x,y,z),) -> (-y,x,z), ((x,y,z),) -> (-y,z,-x),
  ((x,y,z),) -> (-z,-x,y), ((x,y,z),) -> (-z,-y,-x), ((x,y,z),) -> (-z,x,-y),
  ((x,y,z),) -> (-z,y,x), ((x,y,z),) -> (x,-y,-z), ((x,y,z),) -> (x,-z,y),
  ((x,y,z),) -> (x,z,-y), ((x,y,z),) -> (y,-x,z), ((x,y,z),) -> (y,-z,-x),
  ((x,y,z),) -> (y,x,-z), ((x,y,z),) -> (y,z,x), ((x,y,z),) -> (z,-x,-y),
  ((x,y,z),) -> (z,-y,x), ((x,y,z),) -> (z,x,y), ((x,y,z),) -> (z,y,-x),
]

# Utility that re-orients points and moves them so they are relative to the
# base scanner
struct Positioner
  reorientfunc
  adj::Tuple{Int, Int, Int}
  matched::BitVector
end

(P::Positioner)(t) = P.reorientfunc(t) .+ P.adj

function findpositioner(base, scanner, matches)
  len = length(scanner)
  best = nothing
  bestcnt = 0

  # if there are more than 12 total matches, we can't assume the first match is
  # actually valid
  for tryidx in 1:(length(matches)-11)
    for reorientfunc in reorientfuncs
      # We'll try reorienting the first matched point, then calculate an
      # adjustment. We'll then try the same reorientation and adjustment on the
      # rest of the matches.
      (b2,b1) = matches[tryidx]
      adj = base[b1] .- reorientfunc(scanner[b2])
      matched = falses(len)
      matched[b2] = true
      for k in (tryidx+1):length(matches)
        (b2,b1) = matches[k]
        if isequal(base[b1], reorientfunc(scanner[b2]) .+ adj)
          matched[b2] = true
        end
      end

      cnt = count(matched)
      if cnt > bestcnt && cnt >= 12
        best = Positioner(reorientfunc, adj, matched)
        bestcnt = cnt
      end
    end
  end
  return best
end

# utility to sort a list of numbers by the frequency - also reduces the set to
# unique values
function findmostcommon(v)
  cnts = Dict{eltype(v), Int}()
  common = nothing
  commoncnt = 0
  for e in v
    cnts[e] = get(cnts, e, 0) + 1
    if cnts[e] > commoncnt
      common = e
      commoncnt = cnts[e]
    end
  end
  return common
end

# we need to find the position of all the scanners
scannerpositions = Vector{Tuple{Int,Int,Int}}(undef, length(scanners))
scannerpositions[1] = (0,0,0)

# loop over scanners until we've figured them all out - if the loop ever makes
# no progress, it tries to change the "base" and find other matches that way
finished = falses(length(scanners))
finished[1] = true
baseidx = 1
loopfinishedcnt = 1
refdist = RefDistances(baseidx)
while !all(finished)
  base = scanners[baseidx]
  progress = false
  for i in (baseidx+1):length(scanners)
    finished[i] && continue

    # find matching distances
    scanner = scanners[i]
    matches = Dict{Int, Vector{Int}}()
    for (j,k) in Permutations(length(scanner))
      dist = distance(i, j, k)
      distidx = findfirst(refdist, dist)
      isnothing(distidx) && continue
      (pot1, pot2) = refdist[distidx]
      if haskey(matches, j)
        push!(matches[j], pot1, pot2)
      else
        matches[j] = [pot1, pot2]
      end
      if haskey(matches, k)
        push!(matches[k], pot1, pot2)
      else
        matches[k] = [pot1, pot2]
      end
    end

    # do we have at least 12 matches?
    length(matches) < 12 && continue

    # figure out how this scanner is oriented relative to the first
    positioner = findpositioner(base, scanner, [(k,findmostcommon(v)) for (k,v) in matches])
    if isnothing(positioner)
      println("Had 12+ matches, but couldn't find a positioner for scanner ", i)
      continue
    end

    # add new points
    append!(base, map(positioner, scanner[.!positioner.matched]))
    println("Number of beacons after ", count(finished), " scanners: ", length(base))
    scannerpositions[i] = positioner((0,0,0))

    # rebuild distances and mark this scanner finished
    global refdist = RefDistances(baseidx)
    finished[i] = true
    progress = true
  end

  if !progress
    global baseidx = findnext(i -> !i, finished, baseidx+1)
    if isnothing(baseidx)
      global baseidx = 1
      cnt = count(finished)
      loopfinishedcnt == cnt && error("stuck")
      global loopfinishedcnt = cnt
    end
    println("Switching base to ", baseidx)
    global refdist = RefDistances(baseidx)
  end
end

# find largest Manhattan distance between all scanners
largestdistance = 0
for (i,j) in Permutations(length(scannerpositions))
  dist = sum(abs.(scannerpositions[i] .- scannerpositions[j]))
  if dist > largestdistance
    global largestdistance = dist
  end
end

println("Result: ", largestdistance)
