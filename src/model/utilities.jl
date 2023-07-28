"""
    precedence_graph(jobs)
Construct a SimpleDiGraph with as vertices job-ids and an edge between vertice v_i and v_j if a precedence i ≺ j exists.
"""
function precedence_graph(jobs)
    location_dict = group(loc, jobs)
    foreach( k -> sort!(location_dict[k]) , keys(location_dict))
    pg = SimpleDiGraph(length(jobs))
    for pjobs in values(location_dict)
        iter = Iterators.zip(pjobs[1:end-1],pjobs[2:end])
        for (s,d) in iter
            add_edge!(pg, id(s), id(d))
        end
    end
    return pg
end

"""
    precedence_matrix(jobs)
Construct a Matrix{Bool} containing entries for each pair of jobs, with 'true' entries signifying the presence of a precedence relation.
"""
precedence_matrix(jobs) = map(J -> ≺(J...), Iterators.product(jobs,jobs))

"""
    assignment_matrix(jobs, cranes)
Construct a Matrix{Bool} containing entries for each job-crane-pair, with 'true' entries signfifying the possibility of an assignment of the given job to the given crane.
"""
assignment_matrix(jobs, cranes) = map( x -> loc(x[1]) ∈ zone(x[2]), Iterators.product(jobs, cranes))

"""
    compare(jobs, property)
Perform a pairwise comparison of `property` on the `jobs`.
"""
compare(jobs, property) = map(J -> property(J...), Iterators.product(jobs, jobs))



function instance_to_lb_solution(instance)
    Ω = jobs(instance)
    Q = cranes(instance)
    L = jobs_by_loc(Ω)    
    jd = _jobdata(L)
    qd = _cranedata(Q)
    @show jd
    @show qd
    return jd, qd
end

"""
    jobs_by_loc(jobs)

Returns a vector of vectors of jobs, with on each index `i` in the top vector the _ordered_ list of jobs on location `i`
"""
function jobs_by_loc(jobs)
    pg = precedence_graph(jobs)
    L = [Job[] for _ in 1:length(jobs)]
    for v in topological_sort_by_dfs(pg)
        j = jobs[v]
        push!(L[loc(j)], j)
    end
    return L
end


"""
    loctojobdict
"""
function loctojobdict(jobs)
    L = jobs_by_loc(jobs)
    D = Dict{Int, Vector{Job}}()
    for (l,jobs) in enumerate(L)
        if !isempty(jobs)
            D[l] = jobs
        end
    end
    return D
end

function _jobdata(L)
    jd = Tuple{Int,Int}[]
    for l in L
        t = 0
        for j in l
            ts = max(t, t_arrival(j))
            push!(jd, (ts,id(j)))
            t = ts + t_processing(j)
        end
    end
    return jd
end

_cranedata(Q) = map(q -> (0,starting_position(q)), Q)


function lb_obj(jobs, jd)
    cmax = maximum(j -> first(j) + t_processing(jobs[last(j)]), jd)
    twt = 0
    for (ts, jid) in jd
        j = jobs[jid]
        if istruck(j)
            twt += t_processing(j) + ts - t_arrival(j)
        end
    end
    return cmax, twt
end
    
"""
    assignment_ranges(Ω, Q)

Return a vector of ranges designating which craens can be assigned to each job.
"""
function assignment_ranges(Ω, Q)
    R = UnitRange{Int}[]
    for j in Ω
        cmin = findfirst( c -> loc(j) ∈ zone(c), Q)
        cmax = findlast( c -> loc(j) ∈ zone(c), Q)
        push!(R, cmin:cmax)
    end
    return R
end
