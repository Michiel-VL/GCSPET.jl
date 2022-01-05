export LB1, LB2, LB3, LB4, LB5, LB6





"""
    LB1(jobs)

Calculate a lower bound on the truck waiting time:

The sum of the processing times of truck-related jobs
"""
LB1(jobs) = sum(t_processing, Iterators.filter(istruck, jobs))

LB1(i::Instance) = LB1(jobs(i))


"""
    LB2(jobs)

Calculate a lower bound on the makespan:

The maximum of the minimum completion times of all jobs.
"""
LB2(jobs) = maximum(j -> t_arrival(j) + t_processing(j), jobs)

LB2(i::Instance) = LB2(jobs(i))

"""
    LB3(jobs, ncranes)

Calculate a lower bound on the makespan:

Balancing total processing time over cranes
"""
LB3(jobs, ncranes) = Int(ceil(sum(t_processing, jobs) / ncranes ))

LB3(i::Instance) = LB3(jobs(i), ncranes(i))

"""  
    LB4(jobs, l0)

Calculate a lower bound on the makespan:

# TODO: Implement bound
"""

LB4(jobs, l0) = LB3 + minimaltravel(jobs, l0)

LB4(i::Instance) = LB4(jobs(i), crane_starting_pos(i))

"""
    LB5(jobs)

Calculate a lower bound on the truck waiting time:

Compute the total truck waiting time _after_ taking into account job precedences. Analogous to LB1, but with precedences.
"""
function LB5(jobs)
    Ecompl = compute_earliest_completion_times(jobs)
    V = Iterators.filter(istruck, jobs)
    mapreduce(j -> Ecompl[id(j)] - t_arrival(j), +,  V)    
end

LB5(i::Instance) = LB5(jobs(i))

"""
    LB6(jobs)

Calculate a lower bound on the makespan:

Compute the maximum earliest completion time of the jobs. 
"""
function LB6(jobs)
    Ecompl = compute_earliest_completion_times(jobs)
    return maximum(Ecompl)
end

LB6(i::Instance) = LB6(jobs(i))

"""
    interlocdist(jobs)

Returns the sorted distances between unique job-locations
"""
function interlocdist(jobs)
    locsorted = sort!(unique(loc.(jobs)))
    return sort!(map(l -> -(l...), Iterators.zip(locsorted[1:end-1], locsorted[2:end])))
end

"""
    minimaltravel(jobs, ncranes)

    Calculate the minimal travel distance for ncranes to visit all positions
"""
function minimaltravel(jobs, l0)
    Djobs = interlocdist(jobs)

end


function compute_earliest_completion_times(jobs)
    A = t_arrival.(jobs)
    P = t_processing.(jobs)
    C = A .+ P

    pg = precedence_graph(jobs)
    ids = topological_sort_by_dfs(pg)
    for id in ids
        I = map(inn -> C[inn] ,inneighbors(pg, id))
        if !isempty(I)
            C[id] = max(maximum(I), A[id]) + P[id]
        end
    end
    return C
end

makespan_bound_functions = [LB2, LB3, LB4, LB6]
t_truckwaiting_bound_functions = [LB1, LB5]