# You still can't quite make out the details in the image. Maybe you just
# didn't enhance it enough.
#
# If you enhance the starting input image in the above example a total of 50
# times, 3351 pixels are lit in the final output image.
#
# Start again with the original input image and apply the image enhancement
# algorithm 50 times. How many pixels are lit in the resulting image?

const passes = 50

# read input
iter = eachline("input.txt")
enhancementmap = BitVector(map(isequal('#'), collect(iterate(iter)[1])))
iterate(iter) # blank line
img = BitArray(vcat(map(l -> map(isequal('#'), collect(l))', iter)...))
(width, height) = size(img)

# pad the image with zeros around the edge - we'll pad by 2 in each direction
# because that'll make it easier to grab 9x9 squares, ignoring the edge
(width, height) = (width+4, height+4)
nextimg = falses(width, height)
nextimg[3:(width-2), 3:(height-2)] = img
img = nextimg

# this is used to calculate the numeric value of a 3x3 square of bits
bitvalue = reshape([1 << x for x in 8:-1:0], 3, :)'

# run the image enhancement algo
for _ in 1:passes
  # on each pass the image size increases by one pixel in every direction
  global (width, height) = (width+2, height+2)

  # The edge pixels extend infinitely - on each pass, the 9 pixels that make up
  # the input for the next edge will all have the same value. So, if the
  # current edge is made of falses, the next edge will be the first value from
  # the enhancement map. If the current edge is trues, the next edge will be
  # the last value from the enhancement map.
  edge = img[1,1] ? enhancementmap[end] : enhancementmap[1]
  global nextimg = edge ? trues(width, height) : falses(width, height)

  # enhance image
  for j in 3:(height-2), i in 3:(width-2)
    nextimg[j,i] = enhancementmap[sum(bitvalue .* img[(j-2):j, (i-2):i]) + 1]
  end

  # update img
  global img = nextimg
end

println("Result: ", count(img))
