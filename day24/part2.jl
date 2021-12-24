# As the submarine starts booting up things like the Retro Encabulator, you
# realize that maybe you don't need all these submarine features after all.
#
# What is the smallest model number accepted by MONAD?

# read input
program = map(eachline("input.txt")) do l
  (opcode, operands...) = split(l, ' ')
  op1 = operands[1][1]
  op2 = nothing
  if length(operands) > 1
    op2 = operands[2]
    if '0' <= op2[1] <= '9' || op2[1] == '-'
      op2 = parse(Int, op2)
    else
      op2 = op2[1]
    end
  end
  (opcode, op1, op2)
end

# location of all inp instructions
inpip = accumulate((i,_) -> findnext(((o,_,_),) -> o == "inp", program, i+1), 1:14)

# look at part 1 for an explanation
result = Vector{Char}(undef, 14)
stack = Vector{NTuple{2,Int}}()
sizehint!(stack, 7)
for i in 1:14
  ip = inpip[i]
  (bbb,ccc) = (program[ip+5][3], program[ip+15][3])
  if bbb > 0
    push!(stack, (i, ccc))
  else
    (j,delta) = pop!(stack)
    delta += bbb
    result[i] = max(1, 1 + delta) + '0'
    result[j] = max(1, 1 - delta) + '0'
  end
end

println("Model: ", String(result))
