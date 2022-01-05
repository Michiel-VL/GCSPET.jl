read(iset, iname; speed = 1, safety = 1) = read(instancepath(iset, iname), Instance; speed = speed, safety = safety)

"""
    GCSPET.read(source, ::Type{Instance})
    
Read a file and instantiate it as as an `Instance` object. Since crane speed and safety are not given in the file-format, they can be passed as parameters to the read-function. See the package-documentation for more information on the instance file-format.
"""
function read(fpath, ::Type{Instance}; speed = 1, safety = 1)
    params, data = open(fpath, "r") do io
        params = readparams(io)
        data = readdata(io)
        lf = sum(data[5] / params.njobs)
        params = (params..., load = lf)
        return params, data
    end

    name = basename(fpath)
    lq = data[1]
    Ω = create_jobs(data)
    Q = create_cranes(data, speed, safety)

    return Instance(name, Ω, Q)
end

"""
    GCSPET.read(fpath, ::Type{Solution})

Read a `solution` from a solution-file. The solution-file is typically stored in a file with the extension `.sched`. See the package-documentation for more information on the solution file-format.
"""
function read(fpath::String, ::Type{Solution}; speed = 1, safety = 1, zeroindexed = false)
    if !endswith(fpath, ".sched") 
        @info "The provided file does not end with the typical `.sched`-extension. Are you sure this is a correct GCSPET-solution file? [Y/n]"
        lowercase(first(readline())) != "y" && return @info "No file read."
    end
    params, data, T = open(fpath, "r") do io
        params = readparams(io)
        data = readdata(io, 7)
        lf = sum(data[6] / params.njobs)
        params = (params..., load = lf)
        zeroindexed && (data[2] = data[2] .+ 1)
        T = Trajectory[]
        for _ in 1:params.ncranes
            id = parserl(Int, io)
            zeroindexed && (id = id + 1)
            xvals = parsesrl(Int, io, headskip = 2)
            tvals = parsesrl(Int, io, headskip = 2)
            jvals = parsesrl(Int, io, headskip = 2)
            zeroindexed && (jvals = map( x -> x == -1 ? x : x + 1, jvals))
            push!(T, Trajectory(id, xvals, tvals, jvals))
        end
        return params, data, T
    end
    name = basename(fpath)
    Ω = create_jobs(data)
    Q = create_cranes(data, speed, safety)
    return Solution(name, sort!(Ω, by=id), Q, T)
end


"""
    GCSPET.write(instance::Instance, fpath)

Write an instance of GCSPET to `fpath`
"""
function write(instance::Instance, fpath)
    open(fpath, "w") do io
        println(io, njobs(instance))
        println(io, ncranes(instance))
        println(io, join(crane_starting_pos(instance), ","))
        Ω = jobs(instance)
        write_jobdata(io, Ω)
    end
    @info "Wrote instance to $fpath."        
end

"""
    GCSPET.write(solution::Solution, fpath; zeroindexed = false)

Write a solution of GCSPET to `fpath`. Zero-based indexing can be chosen through keyword `zeroindexed`.
"""
function write(solution::Solution, fpath, zeroindexed = false)
    open(fpath, "w") do io
        println(io, njobs(solution))
        println(io, ncranes(solution))
        println(io, join(crane_starting_pos(solution), ","))
        writef = (f, elements) -> println(io, join(map(f, elements), ","))
        Ω = jobs(solution)
        write_jobdata(io, Ω, includeid = true, zeroindexed = zeroindexed)
        for t in trajectories(solution)
            if zeroindexed
                println(io, id(t)-1)
            else
                println(io, id(t))
            end
            writef(x -> x, t.X)
            writef(x -> x, t.T)
            if zeroindexed
                writef(i -> i > 0 ? i - 1 : i, t.J)
            else
                writef(x -> x, t.J)
            end
        end
    end
end

readparams(io) = NamedTuple{(:njobs, :ncranes)}(map( _ -> parserl(Int, io), 1:2))
readdata(io, n = 6) = map( _ -> parsesrl(Int, io), 1:n)

function create_jobs(data)
    if size(data,1) == 6
        iter = Iterators.zip(1:length(data[2]), data[2:end]...)
    else
        iter = Iterators.zip(data[2:end]...)
    end
    tojob = (id, l, jt, p, mt, a) -> Job(id, l, a, p, !Bool(jt - 1), Bool(mt - 1))
    map(a -> tojob(a...), iter)
end

function create_cranes(data, speed, safety)
    lq = data[1]
    njobs = length(data[2])
    map( i -> Crane(i, lq[i], speed, zone(i, length(lq), njobs, safety), safety), eachindex(lq))
end

function write_jobdata(io, jobs; includeid = false, zeroindexed = false)
    writef = (f, elements) -> println(io, join(map(f, elements), ","))
    if includeid
        if zeroindexed
            writef(x-> id(x) - 1, jobs)
        else
            writef(id, jobs)
        end
    end
    writef(loc, jobs)
    writef(x -> (Int ∘ (!) ∘ jobtype)(x) + 1, jobs)
    writef(t_processing, jobs)
    writef(x -> (Int ∘ movetype)(x) + 1, jobs)
    writef(t_arrival, jobs)        
end