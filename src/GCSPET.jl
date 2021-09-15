"""
    module GCSPET

Package providing IO, visualization and basic modelling components for the "Gantry Crane Scheduling Problem with External Trucks", as presented in:

Guo, Peng, et al. "Gantry crane scheduling in intermodal rail-road container terminals." **International Journal of Production Research** 56.16 (2018): 5419-5436.
"""
module GCSPET

    export  Job,                # Job
            id,
            loc,
            t_arrival,
            t_earliest_start,
            t_processing,
            jobtype,
            movetype,
            istruck,
            istrain,
            isload,
            isunload,
            t_waiting,
            t_truckwaiting,
            Crane,              # Crane
            speed,
            starting_position,
            zone,
            safety,
            Instance,           # Instance
            name,
            jobs,
            crane_starting_pos,
            parameters,
            njobs,
            ncranes,
            loadfactor,
            getinstance,
            generate_instance

    using LightGraphs
    using DataDeps
    using Luxor
    using Distributions
    using Test

    include("model/job.jl")
    include("model/crane.jl")
    include("model/instance.jl")
    include("model/solution.jl")

    include("io/dependencies.jl")
    include("io/io.jl")
    include("io/generator.jl")
    include("visualization/components.jl")
    include("visualization/schedule.jl")

    function __init__()
        register(guo_instances)
    end


end
