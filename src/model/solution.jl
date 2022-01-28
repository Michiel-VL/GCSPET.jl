"""
    struct Trajectory

Representation of a single crane trajectory as part of as solution to the GCSPET. The crane movements are modeled as a sequence of crane-positions through time. 
Positions relevant to the execution of a job are marked with the id of that particular job. Each job-id thus occurs twice: once for the starting point of the job and once more for finishing.
"""
struct Trajectory
    id::Int
    X::Vector{Int}
    T::Vector{Int}
    J::Vector{Int}
end

id(t::Trajectory) = t.id

jobset(t::Trajectory) = unique(filter( x -> x > 0, t.J))

function starttimes(t::Trajectory)
    d = Dict{Int,Int}()
    for j in jobset(t)
        idx = findfirst(j, t.J)
        d[j] = t.T[idx]
    end
    return d
end

function endtimes(t::Trajectory)
    for j in jobset(t)
        idx = findlast(j, t.J)
        d[j] = t.T[idx]        
    end
    return d
end

function durations(t::Trajectory)
    d = Dict{Int,Int}
    S = starttimes(t)
    E = endtimes(t)
    for j in jobset(t)
        d[j] = E[j] - S[j]  
    end
    return d
end

function Base.show(io::IO, ::MIME"text/plain", t::Trajectory)
    println(io, "Crane $(t.id)")
    println(io, "t\tx\tjob")
    for (x,y,z) in Iterators.zip(t.T, t.X, t.J)
        if z > 0
            println(io, "$x\t$y\t$z")
        else
            println(io, "$x\t$y\t")
        end
    end
end

##

"""
    struct Solution

Representation of a GCSPET-solution, consisting of all the crane trajectories and job executions.
"""
struct Solution
    name::String
    jobs::Vector{Job}
    cranes::Vector{Crane}
    trajectories::Vector{Trajectory}
end

name(s::Solution) = s.name
jobs(s::Solution) = s.jobs
cranes(s::Solution) = s.cranes
trajectories(s::Solution) = s.trajectories

njobs(s::Solution) = length(jobs(s))
ncranes(s::Solution) = length(cranes(s))
load(s::Solution) = mapreduce(istruck, +, jobs(s))/njobs(s)

crane_starting_pos(s::Solution) = map(starting_position, cranes(s))

objval(s::Solution) = makespan(s) + truckwaitingtime(s)

makespan(s::Solution) = maximum(t -> last(t.T) , trajectories(s))

function truckwaitingtime(s::Solution)
    twt = 0
    for j in Iterators.filter(istruck, jobs(s))
        tc = t_completion(s, id(j))
        twt += tc - t_arrival(j)
    end
    return twt
end

function t_completion(s::Solution, id)
    for t in trajectories(s)
        idx = findlast(x -> x == id ,t.J)
        !isnothing(idx) && return t.T[idx]
    end
    return error("The provided job-id is not in the schedule!")
end


 function Base.show(io::IO, ::MIME"text/plain", s::Solution)
    njobs = length(jobs(s))
    ncranes = length(cranes(s))
    cmax = makespan(s)
    twt = truckwaitingtime(s)
    println(io, "GCSPET-solution: $(name(s))")
    println(io, "njobs: $njobs, ncranes: $ncranes")
    println(io, "CMAX: $cmax, TWT: $twt")
    println(io, "--------------")
    for t in trajectories(s)
        println(io, t)
    end
 end
