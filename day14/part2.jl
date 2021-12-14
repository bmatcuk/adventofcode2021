# The resulting polymer isn't nearly strong enough to reinforce the submarine.
# You'll need to run more steps of the pair insertion process; a total of 40
# steps should do it.
#
# In the above example, the most common element is B (occurring 2192039569602
# times) and the least common element is H (occurring 3849876073 times);
# subtracting these produces 2188189693529.
#
# Apply 40 steps of pair insertion to the polymer template and find the most
# and least common elements in the result. What do you get if you take the
# quantity of the most common element and subtract the quantity of the least
# common element?

const steps = 40

# read input
iter = eachline("input.txt")
(template, _) = iterate(iter)
iterate(iter) # blank line
rules = Dict([split(l, " -> ") for l in iter])

# Recursing will take forever. Instead, we're going to build from the bottom up
# - there are only 10 characters, so only 100 two letter combos. We can build a
# 100x10 matrix representing how many of each character will be added per two
# letter combo and build that up 40 times.
chars = unique(values(rules))
charidx = Dict([(c,i) for (i,c) in enumerate(chars)])
pairidx = Dict{String, Int}()
cnts = zeros(Int128, length(rules), length(chars))
for (i,(k,v)) in enumerate(rules)
  pairidx[k] = i
  cnts[i, charidx[v]] = 1
end

# for each step, take the two letter pair with the element it creates and find
# the sum of the characters from the two new pairs in the previous steps
temp = similar(cnts)
for _ in 2:steps
  global (cnts,temp) = (temp,cnts)
  for (k,v) in rules
    l = k[1] * v
    r = v * k[2]
    i = pairidx[k]
    cnts[i,:] = temp[pairidx[l],:] .+ temp[pairidx[r],:]
    cnts[i,charidx[v]] += 1
  end
end

# build final counts - iterate over (1,2), (2,3), ..., (len-1, len)
finalcnts = zeros(Int128, length(chars))
foreach(zip(1:(length(template)-1), 2:length(template))) do (i,j)
  finalcnts .+= cnts[pairidx[template[i:j]],:]
  finalcnts[charidx[template[i:i]]] += 1
end
finalcnts[charidx[template[end:end]]] += 1

println("Result: ", abs(-(extrema(finalcnts)...)))
