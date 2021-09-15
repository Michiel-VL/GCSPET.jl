"""
    read_instance(fpath; transform = nothing)

Reads in a GCSPET `.dat` file given by `fpath` and return a named tuple `(params = (njobs = ..., ncranes = ;.., load = ...), data = (cranedata = ..., jobdata = ...)` 

"""
function read_instance(fpath)
    inst = open(fpath, "r") do io
        njobs = parserl(Int, io)
        ncranes = parserl(Int, io)
        lq = parsesrl(Int,io)
        L = parsesrl(Int, io)
        JT = parsesrl(Int, io) .- 1 # truck or train
        P = parsesrl(Int,io)
        MT = parsesrl(Int, io) .- 1 # load or unload
        A = parsesrl(Int, io)

        loadfactor = sum(JT) / njobs
        params = (njobs = njobs, ncranes = ncranes, load = loadfactor)
        jobdata = (locations = L, arrivaltimes = A, processingtimes = P, jobtypes = JT, movetypes = MT)
        (params = params, data = (cranedata = lq, jobdata = jobdata))
    end
    return inst
end

readparams(io) = NamedTuple{(:njobs, :ncranes)}(map( _ -> parserl(Int, io), 1:2))
readdata(io, n=6) = map( _ -> parsesrl(Int, io), 1:n)

"""
    read(source, ::Type{Instance})
    
Read a file and instantiate it as as an `Instance` object. Since crane speed and safety are not given in the file-format, they can be passed as parameters to the read-function.
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

function create_jobs(data)
    iter = Iterators.zip(1:length(data[2]), data[2:end]...)
    tojob = (id, l, jt, p, mt, a) -> Job(id, l, a, p, !Bool(jt - 1), Bool(mt - 1))
    map(a -> tojob(a...), iter)
end

function create_cranes(data, speed, safety)
    lq = data[1]
    njobs = length(data[2])
    map( i -> Crane(i, lq[i], speed, zone(i, length(lq), njobs, safety), safety), eachindex(lq))
end


"""
    GCSPET.read(fpath, ::Type{})
"""
function read(fpath::String, ::Type{Solution})
    params, data = open(fpath, "r") do io
        params = readparams(io)
        data = readdata(io, 7)
        params = (params..., load = lf)
        return params, data
    end
end
"""
    parserl(T, io)

Reads a line from `io` and parses the result to type `T`. Typically used for single-value lines.
"""
parserl(T, io) = parse(T, readline(io))


"""
    parsesrl(T, io; sep = ",", headskip = 0, tailskip = 0)

Reads a line from `io`, splits the line over `sep`. Use keywords `headskip` and `tailskip` to optionally exclude the head and tail of the string before splitting.

#Usage
julia> parsesrl(Int, io) # read "1,0,1"

"""
function parsesrl(T, io; sep = ",", headskip = 0, tailskip = 0)
    l = readline(io)
    i = 1 + headskip
    j = length(l) - tailskip
    l = l[i:j]
    parse.(T, split(l, sep))
end


function write(instance::Instance, fpath)
    open(fpath, "w") do io
        println(io, njobs(instance))
        println(io, ncranes(instance))
        println(io, join(crane_starting_pos(instance), ","))
        writef = (f, elements) -> println(io, join(map(f, elements), ","))
        Ω = jobs(instance)
        writef(location, Ω)
        writef(jobtype, Ω)
        writef(t_processing, Ω)
        writef(move_type, Ω)
        writef(t_arrival, Ω)
    end
    @info "Wrote instance to $fpath."        
end

##

function write_instance(jobdata, startpos, fpath)
    open(fpath, "w") do io
        println(io, length(first(jobdata)))
        println(io, length(startpos))
        println(io, join(startpos, ","))
        writef = elements -> println(io, join(elements, ","))
        writef.(jobdata[2:end])
    end
    @info "Wrote instance to $fpath"
end




"""
    read_solution(fname)

Reads a `Solution` from a gcspet `.sched`-file.
"""
function read_solution(fname)
    params, data = open(fname, "r") do io
        njobs = parserl(Int, io)
        ncranes = parserl(Int, io)
        lq = parsesrl(Int,io)
        L = parsesrl(Int, io)
        MT = parsesrl(Int, io) .- 1
        P = parsesrl(Int,io)
        JT = parsesrl(Int, io) .- 1
        A = parsesrl(Int, io)

        loadfactor = sum(JT) / njobs
        params = (njobs = njobs, ncranes = ncranes, load = loadfactor)
        jobdata = (locations = L, arrivaltimes = A, processingtimes = P, jobtypes = JT, movetypes = MT)
        inst = (params = params, data = (cranedata = lq, jobdata = jobdata))
        
        T = Traj[]
        for _ in 1:ncranes
            id = parserl(Int, io)
            xvals = parsesrl(Int, io, headskip = 2)
            tvals = parsesrl(Int, io, headskip = 2)
            jvals = parsesrl(Int, io, headskip = 2)
            push!(T, Traj(id, xvals, tvals, jvals))
        end
        return inst, T
    end   
end


function write_solution(xvec, tvec, jvec)

end
