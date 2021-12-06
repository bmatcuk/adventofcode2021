# Suppose the lanternfish live forever and have unlimited food and space. Would
# they take over the entire ocean?
#
# After 256 days in the example above, there would be a total of 26984457539
# lanternfish!
#
# How many lanternfish would there be after 256 days?

# read input - we're using a vector where the index represents the number of
# days until a fish replicates, and the value is how many fish have that
# internal state. Since Julia has 1-based indexing, we need to add one to our
# inputs. We also ned to make sure our array is large enough to handle the fact
# that new fish need extra time before they can replicate: one element
# representing today, and 9 more elements to represent the 9 days a new fish
# needs before replication.
fish = zeros(UInt64, 10)
foreach(split(readline("input.txt"), ',')) do d
  fish[d[1] - '0' + 1] += 1
end

# Rather than rotating the array around, just keep an index representing
# "today". On each day, the fish at the current index replicate and the index
# moves one spot.
for dayidx in 0:255
  # 1-based indexing is kind of a pain in the ass
  idx = dayidx % 10 + 1

  # replicate today's fish
  fish[(idx + 8) % 10 + 1] += fish[idx]

  # move today's fish ahead 7 days
  fish[(idx + 6) % 10 + 1] += fish[idx]

  # clear today's fish
  fish[idx] = 0
end

println("Number of fish: ", sum(fish))
