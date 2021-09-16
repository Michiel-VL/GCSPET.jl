"""
    parserl(T, io)

Reads a line from `io` and parses the result to type `T`. Typically used for single-value lines.
"""
parserl(T, io) = parse(T, readline(io))


"""
    parsesrl(T, io; sep = ",", headskip = 0, tailskip = 0)

Reads a line from `io`, splits the line over `sep`. Use keywords `headskip` and `tailskip` to optionally exclude the head and tail of the string before splitting.

#Usage
julia> parsesrl(Int, io) # read "1,0,1"

"""
function parsesrl(T, io; sep = ",", headskip = 0, tailskip = 0)
    l = readline(io)
    i = 1 + headskip
    j = length(l) - tailskip
    l = l[i:j]
    parse.(T, split(l, sep))
end