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
            Solution,
            name,
            jobs,
            cranes,
            crane_starting_pos,
            parameters,
            njobs,
            ncranes,
            loadfactor,
            instancepath,
            instancelist,
            instancedir,
            generate_instance,
            precedence_graph,
            precedence_matrix,
            assignment_matrix,
            assignment_ranges

    using Reexport
    using SplitApplyCombine: group # model
    @reexport using LightGraphs       # model
    using DataDeps          # io
    using RecipesBase
    using Luxor             # visualization
    using Colors            # visualization
    using Test              # validation

    include("model/job.jl")
    include("model/crane.jl")
    include("model/instance.jl")
    include("model/solution.jl")
    include("model/bounds.jl")
    include("model/utilities.jl")
    include("model/generator.jl")
    include("io/utilities.jl")
    include("io/dependencies.jl")
    include("io/io.jl")
    
    
    include("visualization/base.jl")
    include("visualization/gcspetsolution.jl")
    include("visualization/gcspetinstance.jl")
    include("visualization/gcspetobjective.jl")
    include("formulation/guo_formulation.jl")

    function __init__()
        DataDeps.register(guo_instances)
    end
end
