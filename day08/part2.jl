# Through a little deduction, you should now be able to determine the remaining
# digits. Consider again the first example above:
#
# acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab |
# cdfeb fcadb cdfeb cdbaf
#
# After some careful analysis, the mapping between signal wires and segments
# only make sense in the following configuration:
#
#  dddd
# e    a
# e    a
#  ffff
# g    b
# g    b
#  cccc
#
# So, the unique signal patterns would correspond to the following digits:
#
# acedgfb: 8
# cdfbe: 5
# gcdfa: 2
# fbcad: 3
# dab: 7
# cefabd: 9
# cdfgeb: 6
# eafb: 4
# cagedb: 0
# ab: 1
#
# Then, the four digits of the output value can be decoded:
#
# cdfeb: 5
# fcadb: 3
# cdfeb: 5
# cdbaf: 3
#
# Therefore, the output value for this entry is 5353.
#
# Following this same process for each entry in the second, larger example
# above, the output value of each entry can be determined:
#
# fdgacbe cefdb cefbgd gcbe: 8394
# fcgedb cgb dgebacf gc: 9781
# cg cg fdcagb cbg: 1197
# efabcd cedba gadfec cb: 9361
# gecf egdcabf bgf bfgea: 4873
# gebdcfa ecba ca fadegcb: 8418
# cefg dcbef fcge gbcadfe: 4548
# ed bcgafe cdgba cbgef: 1625
# gbdfcae bgc cg cgb: 8717
# fgae cfgab fg bagce: 4315
#
# Adding all of the output values in this larger example produces 61229.
#
# For each entry, determine all of the wire/segment connections and decode the
# four-digit output values. What do you get if you add up all of the output
# values?

digits = Array{String}(undef, 10)
cnt = sum(eachline("input.txt")) do l
  (input, output) = split.(split(l, " | "))
  inputlens = length.(input)

  # find the unique digits - idxs is a vector of indexes that would sort the
  # inputlens. Since all 10 digits must be in the input, we know exactly where
  # to find 1, 4, 7, and 8 because inputlens[idxs] will always be
  # [2, 3, 4, 5, 5, 5, 6, 6, 6, 7]
  idxs = sortperm(inputlens)
  digits[2] = input[idxs[1]]
  digits[5] = input[idxs[3]]
  digits[8] = input[idxs[2]]
  digits[9] = input[idxs[10]]

  fivesegments = input[idxs[4:6]]
  sixsegments = input[idxs[7:9]]

  # of the 5-segment digits, only 3 shares all segments in common with 7
  threeidx = findfirst(x -> issubset(digits[8], x), fivesegments)
  digits[4] = fivesegments[threeidx]
  deleteat!(fivesegments, threeidx)

  # of the 6-segment digits, 6 is the only one that does NOT share all segments
  # in common with 1
  sixidx = findfirst(x -> !issubset(digits[2], x), sixsegments)
  digits[7] = sixsegments[sixidx]
  deleteat!(sixsegments, sixidx)

  # of the remaining 5-segment digits, only 5 will share all segments with 6
  fiveidx = findfirst(x -> issubset(x, digits[7]), fivesegments)
  digits[6] = fivesegments[fiveidx]
  deleteat!(fivesegments, fiveidx)

  # the remaining 5-segment number must be 2
  digits[3] = fivesegments[1]

  # of the remaining 6-segment numbers, only 9 shares all segments with 4
  nineidx = findfirst(x -> issubset(digits[5], x), sixsegments)
  digits[10] = sixsegments[nineidx]
  deleteat!(sixsegments, nineidx)

  # the remaining 6-segment number is 0
  digits[1] = sixsegments[1]

  # now decode output
  mapfoldl((a,x) -> a*10+x, output) do x
    # digit is the index of the entry in digits, minus 1
    findfirst(y -> issetequal(x, y), digits) - 1
  end
end

println("Result: ", cnt)
