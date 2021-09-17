 # Generate GCSPET instance according to Guo

 import Distributions: DiscreteUniform

 """
 generate_location_constrained_jobs(njob, D_l, maxperl)
Sample `njob` job locations from distribution D_l, with the constraint that at most `maxperl` jobs can occur at one location. Returns a jobs-per-location-dict of type `Dict{T,Vector{Int}}`, where `T` is the eltype of `D_l`.
"""
function generate_location_constrained_jobs(njob, Dₗ, maxperl; base_id = 1)
    id = 0
    posjobmap = Dict{eltype(Dₗ), Vector{Int}}()
    while id < njob
        l = rand(Dₗ)
        !haskey(posjobmap, l) && (posjobmap[l] = Int[])
        if length(posjobmap[l]) < maxperl
            push!(posjobmap[l], base_id + id)
            id += 1
        end
    end
    return posjobmap
end

"""
 generate_crane_starting_positions(njob, ncrane)
Generate `ncrane` starting positions at random locations but with fixed intervals between the positions. 
"""
function generate_crane_starting_positions(njob, ncrane)
    step = Int(round(njob/ncrane))
    lq_left = rand(1:step-1)
    return [lq_left + (c-1) * step for c in 1:ncrane]
end


"""
 generate_jobs(njobs, ncrane, load)
Generate the data for a set of jobs for the GCSPET, according tot the distributions presented by Guo et al.
"""
function generate_jobdata(njob, ncrane, load)
    ntruck = round(Int, load * njob)
    ntrain = njob - ntruck
    Dₚ= DiscreteUniform(3,10)                                       # Generate processing times
    P = rand(Dₚ, njob) 
    Dₐ = DiscreteUniform(1, sum(P) ÷ ncrane)                        # Generate arrival times
    A = vcat(zeros(Int, ntrain), rand(Dₐ, ntruck))
    Dₗ = DiscreteUniform(1,njob)                                    # Generate locations
    JT = vcat(zeros(Int, ntrain), ones(Int, ntruck))
    trainjobs = generate_location_constrained_jobs(ntrain, Dₗ, 2)
    truckjobs = generate_location_constrained_jobs(ntruck, Dₗ, 2; base_id = ntrain+1)
    L = zeros(Int, njob)
    MT = zeros(Int, njob)
    encode_jobtypes!(MT, L, trainjobs)
    encode_jobtypes!(MT, L, truckjobs)
    ID = 1:njob
    return (ID, L, JT, A, MT, P)
end


generate_jobs(njobs, ncranes, load) = map(Job, generate_jobdata(njobs, ncranes, load))

function generate_instance(njobs, ncranes, load; sample_id = 1, safety = 1, speed = 1)
    jobdata = generate_jobdata(njobs, ncranes, load)
    Ω = map(Job, jobdata...)
    lQ = generate_crane_starting_positions(njobs, ncranes)
    return Instance(name = toname(Ω, lQ), Ω = Ω, lQ = lQ, speed = speed, safety = safety)
end

function encode_jobtypes!(MT, L, posjobmap)
    for (l, jobs) in posjobmap
        for (i,j) in enumerate(jobs)
            L[j] = l
            MT[j] = i-1
        end
    end
end


toname(njobs::Int, ncranes::Int, load::Float64) = join((njobs, ncranes, load), "_") * ".dat"

toname(Ω, lQ; s_id = 1) = join((length(Ω), length(lQ), count(istruck, Ω)/length(Ω), s_id), "_")