# Now that you have the structure of your transmission decoded, you can
# calculate the value of the expression it represents.
#
# Literal values (type ID 4) represent a single number as described above. The
# remaining type IDs are more interesting:
#
# - Packets with type ID 0 are sum packets - their value is the sum of the
#   values of their sub-packets. If they only have a single sub-packet, their
#   value is the value of the sub-packet.
# - Packets with type ID 1 are product packets - their value is the result of
#   multiplying together the values of their sub-packets. If they only have a
#   single sub-packet, their value is the value of the sub-packet.
# - Packets with type ID 2 are minimum packets - their value is the minimum of
#   the values of their sub-packets.
# - Packets with type ID 3 are maximum packets - their value is the maximum of
#   the values of their sub-packets.
# - Packets with type ID 5 are greater than packets - their value is 1 if the
#   value of the first sub-packet is greater than the value of the second
#   sub-packet; otherwise, their value is 0. These packets always have exactly
#   two sub-packets.
# - Packets with type ID 6 are less than packets - their value is 1 if the
#   value of the first sub-packet is less than the value of the second
#   sub-packet; otherwise, their value is 0. These packets always have exactly
#   two sub-packets.
# - Packets with type ID 7 are equal to packets - their value is 1 if the value
#   of the first sub-packet is equal to the value of the second sub-packet;
#   otherwise, their value is 0. These packets always have exactly two
#   sub-packets.
#
# Using these rules, you can now work out the value of the outermost packet in
# your BITS transmission.
#
# For example:
#
# C200B40A82 finds the sum of 1 and 2, resulting in the value 3.
# 04005AC33890 finds the product of 6 and 9, resulting in the value 54.
# 880086C3E88112 finds the minimum of 7, 8, and 9, resulting in the value 7.
# CE00C43D881120 finds the maximum of 7, 8, and 9, resulting in the value 9.
# D8005AC2A8F0 produces 1, because 5 is less than 15.
# F600BC2D8F produces 0, because 5 is not greater than 15.
# 9C005AC2F8F0 produces 0, because 5 is not equal to 15.
# 9C0141080250320F1802104A08 produces 1, because 1 + 3 = 2 * 2.
#
# What do you get if you evaluate the expression represented by your
# hexadecimal-encoded BITS transmission?

# read input
line = readline("input.txt")
bits = parse(BigInt, line; base=16)
pos = ndigits(bits; base=2)

# utility function to read n bits
function read_bits(n)
  global pos -= n
  pos < 0 && throw("pos is less than zero")
  mask = (1 << n) - 1
  (bits >> pos) & mask
end

# utility function - returns true if we're done reading bits
function iseob()
  # ensure 1 << pos will fit in an int (assuming 64-bit) - most likely, if
  # there are at least 63 bits remaining, we probably aren't done anyway
  pos > 63 && return false
  mask = (1 << pos) - 1
  iszero(bits & mask)
end

# do eet
function get_packet_value()
  start_pos = pos
  read_bits(3) # version - unneeded
  id = read_bits(3)
  if id == 4
    # literal number
    f = read_bits(1)
    v = BigInt(read_bits(4))
    while f > 0
      f = read_bits(1)
      v = (v << 4) | read_bits(4)
    end
    return (v, start_pos - pos)
  end

  # process subpackets
  stack = BigInt[]
  lentype = read_bits(1)
  if lentype == 0
    # len is total bits of all subpackets
    len = read_bits(15)
    while len > 0
      (v, nread) = get_packet_value()
      push!(stack, v)
      len -= nread
    end
  else
    # len is total number of subpackets
    len = read_bits(11)
    for _ in 1:len
      (v, _) = get_packet_value()
      push!(stack, v)
    end
  end

  # compute result
  result = 0
  if id == 0
    result = sum(stack)
  elseif id == 1
    result = prod(stack)
  elseif id == 2
    result = minimum(stack)
  elseif id == 3
    result = maximum(stack)
  elseif id == 5
    result = BigInt(stack[1] > stack[2])
  elseif id == 6
    result = BigInt(stack[1] < stack[2])
  elseif id == 7
    result = BigInt(stack[1] == stack[2])
  end
  return (result, start_pos - pos)
end

(result, _) = get_packet_value()
println("Result: ", result)
