using JuMP
using Cbc

export build_model, solve_instance

function preprocess_instance(instance, δ)
        # Earliest starting time per job per crane
        J = jobs(instance)
        K = cranes(instance)
        Ω = 1:length(J)
        Q = 1:length(K)
        r0 = zeros(Int, length(Q)) # Crane starting times
        t0 = [abs(loc(j) - starting_position(k)) * speed(k) for (j,k) in Iterators.product(J,K)] # travel times from crane starting pos to job for each job-crane pair
        p = t_processing.(J)
        a = t_arrival.(J)
        L = loc.(J)
        # Φ is the set of precendence pairs
        Φ = Tuple.(findall(precedence_matrix(J)))
        # Ψ is the set of job-pairs whose locations are too close to eachother to enable simultaneous execution
        Ψ = [(id(i), id(j)) for (i,j) ∈ Iterators.product(J,J) if abs(loc(i)-loc(j)) ≤ δ && id(i) < id(j)]
        # We need specific traveltimes to deal with the non-crossing constraints.
        Δ = calculate_conflict_dependent_travel_times(J, K, δ)
        # Θ is the set of tuples (i,j,u,w) for which the execution of job i by crane u and of job j by crane w leads to a conflict
        Θ = [(id(i),id(j),id(u),id(w)) for (i,j,u,w) ∈ Iterators.product(J,J,K,K) if id(i) < id(j) && Δ[id(i),id(j),id(u),id(w)] > 0 ]
        # V is the set of truck-related jobs
        V = map(j -> id(j), filter(istruck, J))

        #=
        println("Data Summary:")
        println("===============")
        println("Job ids: \t", Ω)
        println("Crane ids: \t", Q)
        println("Crane starting times: \t", r0)
        println("Crane earliest starting times per job: \t", t0)
        println("Arrival times: \t", a)
        println("Processing times: \t", p)
        println("Precedence pairs Φ: \t", Φ)
        println("Non-simultaneous execution Ψ: \t", Ψ)
        println("===============\n")
        =#
        return Ω, Q, r0, t0, p, a, Φ, Ψ, Δ, Θ, V
end

function build_model(instance; δ=1)
    Ω, Q, r0, t0, p, a, Φ, Ψ, Δ, Θ, V =  preprocess_instance(instance, δ)
    # Construction of model
    m = Model()
    M = 100000
    # Variables
    @variable(m, x[Ω, Q], Bin)
    @variable(m, y[Ω, Ω], Bin)
    @variable(m, c[Ω], Int)
    @variable(m, Cmax)

    # Constraints
    # The makespan is equal to or more than all completion times
    @constraint(m, [i=Ω], Cmax ≥ c[i])
    # Every job must be assigned to exactly one crane
    @constraint(m, [i=Ω], sum(x[i,k] for k in Q) == 1)
    # Every job 
    @constraint(m, [i=Ω], sum(x[i,k]*(r0[k] + t0[i,k]) for k in Q) + p[i] ≤ c[i])
    @constraint(m, [i=Ω], a[i] + p[i] ≤ c[i])
    for (i,j) in Iterators.product(Ω, Ω)
        @constraint(m, c[i] - c[j] + p[j] ≤ M*(1 - y[i,j]))
        @constraint(m, c[j] - p[j] - c[i] ≤ M*y[i,j])
    end
    for (i,j) ∈ Φ
        @constraint(m, c[i] - c[j] + p[j] ≤ 0)
    end
    for (i,j) ∈ Ψ
        @constraint(m, y[i,j] + y[j,i] == 1)
    end
    for (i,j,u,w) ∈ Θ
        @constraint(m, x[i,u] + x[j,w] ≤ 1 + y[i,j] + y[j,i])
        @constraint(m, c[i] + Δ[i,j,u,w] - c[j] + p[j] ≤ M*(3 - y[i,j] - x[i,u] - x[j,w]))
        @constraint(m, c[j] + Δ[i,j,u,w] - c[i] + p[i] ≤ M*(3 - y[j,i] - x[i,u] - x[j,w]))
    end

    @objective(m, Min, Cmax + sum(v -> c[v] - a[v], V))
    #print(m)
    return m
end

function calculate_conflict_dependent_travel_times(jobs, cranes, δ)
    Δ = zeros(Int, length(jobs), length(jobs), length(cranes), length(cranes))
    for (i,j,u,w) ∈ Iterators.product(jobs,jobs,cranes,cranes)
        I = (id(i),id(j),id(u),id(w))
        δuw = (δ+1)*abs(id(u)-id(w))
        Δ[I...] = ccdtt(I...,loc(i),loc(j), δuw, speed(u))
    end
    return Δ
end

"""
    ccdtt(i,j,u,w,li,lj, δ)

Literal translation to Julia from the if-clause at the top of page 5423 in Guo et al. (2018).
"""
function ccdtt(i, j, u, w, li, lj, δuw, t0)
    if u > w && i ≠ j && li < lj + δuw
        return (lj - li + δuw) * t0
    elseif u < w && i ≠ j && li > lj - δuw
        return (li - lj + δuw) * t0
    elseif u == w && i ≠ j
        return abs(li-lj)*t0
    else
        return 0     
    end
end


# Utility functions


function solve_instance(instance; optimizer = Cbc.Optimizer, δ=1)
    m = build_model(instance)
    set_optimizer(m, optimizer)
    #set_silent(m)
    optimize!(m)
    return extract_solution(m,instance)
end

"""
    extract_solution(model, instance)

Extract the solution from the solver and return it as a GCSPET.Solution.
"""
function extract_solution(model, instance)
    # Extract the assignment matrix (:x) from the model and round and convert all values to the nearest integer
    assignment_matrix = Int.(round.(Matrix(value.(model[:x]))))
    C = Vector(Int.(round.(value.(model[:c]))))
    L = loc.(jobs(instance))
    P = t_processing.(jobs(instance))

    assignments = map(i -> sort(findall(x -> x == 1, assignment_matrix[:,i]), by = j -> C[j]), 1:ncranes(instance))

    Tr = Trajectory[]
    for (i,q) in enumerate(assignments)
        X = [starting_position(cranes(instance)[i])]
        T = [0]
        J = [-1]
        t  = Trajectory(i, X, T, J)
        for j in q
            l = L[j]
            a = C[j] - P[j]
            c = C[j]
            push!(X, l)
            push!(X, l)
            push!(T, a)
            push!(T, c)
            push!(J, j)
            push!(J, j)
        end
        push!(Tr,t)
    end
    return Solution(name(instance), jobs(instance), cranes(instance), Tr) 
end
