using GCSPET
using Test


fname = instancepath("GCSPET_Guo", "20_2_0.4_1.dat")

inst = GCSPET.read(fname, Instance)

GCSPET.draw(inst, 1000, 800, "test.png")
GCSPET.draw(Instance, fname, 1000, 800, "test2.png")
"""
    randsolution(inst)

Construct a random (infeasible!) solution for testing.
"""
function randsolution(inst)
    J = jobs(inst)
    Q = cranes(inst)
    trajs = [GCSPET.Trajectory(id(q), [starting_position(q)], [0], [-1]) for q in Q]
    for j in J
        i = rand(eachindex(trajs))
        traj = trajs[i]
        q = Q[i]
        t_start = last(trajs[i].T) + abs(last(trajs[i].X)-loc(j))*speed(q)

        push!(traj.X, loc(j))
        push!(traj.T, t_start)
        if t_arrival(j) > t_start
            push!(traj.J, -1)
            push!(traj.T, t_arrival(j))
            push!(traj.X, loc(j))
            push!(traj.J, id(j))
        else
            push!(traj.J, id(j))
        end
        push!(traj.X, loc(j))
        push!(traj.T, last(traj.T) + t_processing(j))
        push!(traj.J, id(j))
    end
    return GCSPET.Solution(name(inst), jobs(inst), cranes(inst), trajs)
end

s = randsolution(inst)

@testset "GCSPET.jl" begin
    @test typeof(precedence_graph(jobs(inst))) <: SimpleDiGraph
    @test typeof(precedence_matrix(jobs(inst))) <: Matrix
    @test typeof(assignment_matrix(jobs(inst), cranes(inst))) <: Matrix
    @test GCSPET.makespan(s) > 0
end



