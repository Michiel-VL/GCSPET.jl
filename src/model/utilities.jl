"""
    precedence_graph(jobs)
Construct a SimpleDiGraph with as vertices job-ids and an edge between vertice v_i and v_j if a precedence i ≺ j exists.
"""
function precedence_graph(jobs)
    location_dict = group(location, jobs)
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
assignment_matrix(jobs, cranes) = map( x -> location(x[1]) ∈ zone(x[2]), Iterators.product(jobs, cranes))

"""
    compare(jobs, property)
Perform a pairwise comparison of `property` on the `jobs`.
"""
compare(jobs, property) = map(J -> property(J...), Iterators.product(jobs, jobs))