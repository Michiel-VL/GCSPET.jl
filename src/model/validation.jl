"""
    validate(instance, solution)

Check if the given solution fits the instance

"""
function validate(instance::Instance, L, T, J)
end


# Checking the feasibility of a solution equates Checking
# - presence of all jobs, with starting times after the earliest arrival times
# - respect for precedence constraints
# - no intersections (nor invali)

function check_jobdata(solution)
    J = jobs(solution)
    PG = precedence_graph(J)
    ts = zeros(Int, length(J))
    td = zeros(Int, length(J))
    ispresent = zeros(Int, length(J))
    for T in trajectories(solution)
        S = starttimes(T)
        for (j, t_s) in pairs(S)
            @test t_arrival(J[j]) <= t_s
            ts[j] = t_s
            ispresent[j] += 1
        end
        D = durations(T)
        for (j, t_d) in pairs(D)
            @test t_processing(J[j]) == t_d
            td[j] = t_d
        end
    end
    tc = ts .+ td
    for (s,d) in edges(PG)
        tc[s] < ts[d]
    end

end