# Finish folding the transparent paper according to the instructions. The
# manual says the code is always eight capital letters.
#
# What code do you use to activate the infrared thermal imaging camera system?

# read data
iter = eachline("input.txt")
values = map(l -> parse.(Int, split(l, ',')), Iterators.takewhile(l -> l != "", iter))
folds = map(iter) do l
  (f, i) = split(l, '=')
  (f[end], parse(Int, i))
end

# build sheet - I really hate 1-based indexing
width = maximum(first, values) + 1
height = maximum(last, values) + 1
sheet = falses(width, height)
foreach(((x,y),) -> sheet[x+1,y+1] = true, values)

# fold
for (fold_dir,fold_along) in folds
  if fold_dir == 'x'
    global sheet = sheet[1:fold_along,:] .| sheet[end:-1:(fold_along+2),:]
  else
    global sheet = sheet[:,1:fold_along] .| sheet[:,end:-1:(fold_along+2)]
  end
end

# output - because the code treats sheet as being stored in x,y coordinates and
# julia stores data in column-major form, we can iterate over sheet linearly.
width = size(sheet, 1)
for (i,v) in enumerate(sheet)
  print(v ? '#' : ' ')
  i % width == 0 && print('\n')
end
