"""
    struct Instance{J,C,T}
An instance to the GCSPET problem is defined by:
- set of jobs of type `J`
- set of crane starting positions of type `T`
- crane speed of type `T`
- safety distance of type `T`
An instance can be generated through parameters:
- number of jobs
- number of cranes
- load factor
- crane speed      (default = 1)
- safety distance  (default = 1)
"""
struct Instance
    name::String
    Ω::Vector{Job}
    Q::Vector{Crane}
end

name(i::Instance) = i.name
jobs(i::Instance) = i.Ω
cranes(i::Instance) = i.Q
crane_starting_pos(i::Instance) = starting_position.(cranes(i))

"""
    parameters(i::Instance)

Returns a `Dict` containing the names and values of all instance-parameters.
"""
parameters(i::Instance) = Dict(["njobs" => njobs(i), "ncranes" => ncranes(i), "load" => loadfactor(i)])

njobs(i::Instance) = length(jobs(i))
ncranes(i::Instance) = length(cranes(i))
loadfactor(i::Instance) = count(istruck,jobs(i))

xmin(c, safety) = (c-1)*(safety+1)+1
xmax(c, n, njobs, safety) = njobs - (n-c)*(safety+1)
zone(c, ncranes, njobs, safety) = xmin(c, safety):xmax(c, ncranes, njobs, safety)


function Base.show(io::IO, ::MIME"text/plain", i::Instance)
    println(io, "Instance of GCSPET: $(name(i))")
    println(io, "Jobs")
    for j in jobs(i)
        println(io, j)
    end
    for c in cranes(i)
        println(io, c)
    end
end