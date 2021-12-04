# On the other hand, it might be wise to try a different strategy: let the
# giant squid win.
#
# You aren't sure how many bingo boards a giant squid could play at once, so
# rather than waste time counting its arms, the safe thing to do is to figure
# out which board will win last and choose that one. That way, no matter which
# boards it picks, it will win for sure.
#
# In the above example, the second board is the last to win, which happens
# after 13 is eventually called and its middle column is completely marked. If
# you were to keep playing until this point, the second board would have a sum
# of unmarked numbers equal to 148 for a final score of 148 * 13 = 1924.
#
# Figure out which board will win last. Once it wins, what would its final
# score be?

# read input
open("input.txt", "r") do io
  # read numbers
  global numbers = parse.(Int, split(readline(io), ','))

  # read boards
  global boards = []
  while !eof(io)
    # blank line
    readline(io)

    board = Array{Int, 2}(undef, 5, 5)
    @inbounds for x in 1:5
      board[x, :] = parse.(Int, split(strip(readline(io)), r"\s+"))
    end
    push!(boards, board)
  end
end

# `results` keeps track of how many rows have matched, and how many columns
# have matched, per board. When either of those counts reach 5, bingo! We also
# keep track of the sum of matched numbers per board. Finally, keep track of
# which boards have won, what the last winning board was, and the last winning
# number.
numboards = length(boards)
results = zeros(UInt8, numboards, 10)
sums = zeros(Int, numboards)
done = falses(numboards)
numdone = 0
lastwin = 0
lastwinnum = 0
for num in numbers, b in 1:numboards
  done[b] && continue
  idx = findfirst(isequal(num), boards[b])
  if !isnothing(idx)
    sums[b] += num
    if (results[b, idx[1]] += 1) == 5 || (results[b, idx[2] + 5] += 1) == 5
      done[b] = true
      global numdone += 1
      global lastwin = b
      global lastwinnum = num
      numdone == numboards && break
    end
  end
end

unmarkedsum = sum(boards[lastwin])
println("Bingo!: ", (unmarkedsum - sums[lastwin]) * lastwinnum)
