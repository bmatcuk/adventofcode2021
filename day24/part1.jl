# Magic smoke starts leaking from the submarine's arithmetic logic unit (ALU).
# Without the ability to perform basic arithmetic and logic functions, the
# submarine can't produce cool patterns with its Christmas lights!
#
# It also can't navigate. Or run the oxygen system.
#
# Don't worry, though - you probably have enough oxygen left to give you enough
# time to build a new ALU.
#
# The ALU is a four-dimensional processing unit: it has integer variables w, x,
# y, and z. These variables all start with the value 0. The ALU also supports
# six instructions:
#
# - inp a - Read an input value and write it to variable a.
# - add a b - Add the value of a to the value of b, then store the result in
#   variable a.
# - mul a b - Multiply the value of a by the value of b, then store the result
#   in variable a.
# - div a b - Divide the value of a by the value of b, truncate the result to
#   an integer, then store the result in variable a. (Here, "truncate" means to
#   round the value toward zero.)
# - mod a b - Divide the value of a by the value of b, then store the remainder
#   in variable a. (This is also called the modulo operation.)
# - eql a b - If the value of a and b are equal, then store the value 1 in
#   variable a. Otherwise, store the value 0 in variable a.
#
# In all of these instructions, a and b are placeholders; a will always be the
# variable where the result of the operation is stored (one of w, x, y, or z),
# while b can be either a variable or a number. Numbers can be positive or
# negative, but will always be integers.
#
# The ALU has no jump instructions; in an ALU program, every instruction is run
# exactly once in order from top to bottom. The program halts after the last
# instruction has finished executing.
#
# (Program authors should be especially cautious; attempting to execute div
# with b=0 or attempting to execute mod with a<0 or b<=0 will cause the program
# to crash and might even damage the ALU. These operations are never intended
# in any serious ALU program.)
#
# For example, here is an ALU program which takes an input number, negates it,
# and stores it in x:
#
# inp x
# mul x -1
#
# Here is an ALU program which takes two input numbers, then sets z to 1 if the
# second input number is three times larger than the first input number, or
# sets z to 0 otherwise:
#
# inp z
# inp x
# mul z 3
# eql z x
#
# Here is an ALU program which takes a non-negative integer as input, converts
# it into binary, and stores the lowest (1's) bit in z, the second-lowest (2's)
# bit in y, the third-lowest (4's) bit in x, and the fourth-lowest (8's) bit in
# w:
#
# inp w
# add z w
# mod z 2
# div w 2
# add y w
# mod y 2
# div w 2
# add x w
# mod x 2
# div w 2
# mod w 2
#
# Once you have built a replacement ALU, you can install it in the submarine,
# which will immediately resume what it was doing when the ALU failed:
# validating the submarine's model number. To do this, the ALU will run the
# MOdel Number Automatic Detector program (MONAD, your puzzle input).
#
# Submarine model numbers are always fourteen-digit numbers consisting only of
# digits 1 through 9. The digit 0 cannot appear in a model number.
#
# When MONAD checks a hypothetical fourteen-digit model number, it uses
# fourteen separate inp instructions, each expecting a single digit of the
# model number in order of most to least significant. (So, to check the model
# number 13579246899999, you would give 1 to the first inp instruction, 3 to
# the second inp instruction, 5 to the third inp instruction, and so on.) This
# means that when operating MONAD, each input instruction should only ever be
# given an integer value of at least 1 and at most 9.
#
# Then, after MONAD has finished running all of its instructions, it will
# indicate that the model number was valid by leaving a 0 in variable z.
# However, if the model number was invalid, it will leave some other non-zero
# value in z.
#
# MONAD imposes additional, mysterious restrictions on model numbers, and
# legend says the last copy of the MONAD documentation was eaten by a tanuki.
# You'll need to figure out what MONAD does some other way.
#
# To enable as many submarine features as possible, find the largest valid
# fourteen-digit model number that contains no 0 digits. What is the largest
# model number accepted by MONAD?

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

# You could brute force today's puzzle by writing code to run the program with
# all possible inputs, but it will take forever to run. Instead, today's puzzle
# is mostly about figuring out what the program does. If you inspect it, you'll
# see it has 14 blocks of code that are basically identical:
#
# inp w
# mul x 0
# add x z
# mod x 26
# div z AAA
# add x BBB
# eql x w
# eql x 0
# mul y 0
# add y 25
# mul y x
# add y 1
# mul z y
# mul y 0
# add y w
# add y CCC
# mul y x
# add z y
#
# If you work that out, it becomes:
#
# w = input
# x = int((z % 26 + BBB) != w)               # always 0 or 1
# z = (z / AAA) * (25x + 1) + (w + CCC)x
#
# When BBB is positive, it's always >= 10 and AAA is always 1, so:
# * int(z % 26 + BBB != w) will always be 1 since z % 26 is always
#   non-negative, BBB >= 10, and w < 10;
# * z reduces to z = 26z + w + CCC
#
# You can think of this operation as "pushing" a digit (namely w + CCC) onto
# the end of z in base 26.
#
# When BBB is negative, AAA is always 26. AAA is 1 seven times, and 26 seven
# times. So if we're "pushing" a digit when AAA is 1, we must be popping it
# when AAA is 26. For that to be true, we want the z equation to equal exactly
# z / 26 which happens when x is zero. x is zero when (z % 26 + BBB) == w.
#
# So, basically, matching pushes with pops gives us constraints such that:
# * wpush + CCCpush == wpop - BBBpop
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
    result[i] = min(9, 9 + delta) + '0'
    result[j] = min(9, 9 - delta) + '0'
  end
end

println("Model: ", String(result))
