


struct Traj
    id::Int
    X::Vector{Int}
    T::Vector{Int}
    J::Vector{Int}
end

id(t::Traj) = t.id

jobset(t::Traj) = unique(filter( x -> x > 0, t.J))

function starttimes(t::Traj)
    d = Dict{Int,Int}()
    for j in jobset(t)
        idx = findfirst(j, t.J)
        d[j] = t.T[idx]
    end
    return d
end

function endtimes(t::Traj)
    for j in jobset(t)
        idx = findlast(j, t.J)
        d[j] = t.T[idx]        
    end
    return d
end


function durations(t::Traj)
    d = Dict{Int,Int}
    S = starttimes(t)
    E = endtimes(t)
    for j in jobset(t)
        d[j] = E[j] - S[j]  
    end
    return d
end


struct Solution
    name::String
    schedule::Vector{Traj}
end