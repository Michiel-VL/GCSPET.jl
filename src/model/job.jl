"""
struct Job

Struct representing a single job in the GCSPET. Consists of a transshipment to be executed on a particular location on the non-crossing axis of the gantry cranes. A job takes `t_processing` time units and can only be started as soon as `t_arrival`. Each job has a `jobtype` and `movetype`, which determine precedences between jobs and contribution to the objective function.

"""
struct Job
id::Int
l::Int
a::Int
p::Int
jt::Bool  # 0 = truck
mt::Bool  # 0 = unload
end

id(j::Job) = j.id
loc(j::Job) = j.l
t_arrival(j::Job) = j.a
t_processing(j::Job) = j.p
jobtype(j::Job) = j.jt
movetype(j::Job) = j.mt

istruck(j::Job) = !j.jt
istrain(j::Job) = j.jt

isunload(j::Job) = !j.mt
isload(j::Job) = j.mt

"""
    t_waiting(j::Job, t_compl)

Computes the time Job `j` spent waiting before being processed if it is completed at time `t_compl`.
"""
t_waiting(j::Job, t_compl) = t_compl - t_processing(j) - t_arrival(j)

"""
    t_truckwaiting(j::Job, t_compl)

Compute the time the (potential) truck related to Job `j` spent waiting in the terminal, if `j` is completed at time `t_compl`. This is equal to `jobtype(j) * (t_compl - t_arrival(j)`, or `jobtype(j)*(t_waiting(j, t_compl) + t_processing(j))`. 
"""
t_truckwaiting(j::Job, t_compl) = istruck(j) * (t_compl - t_arrival(j))


function Base.show(io::IO, ::MIME"text/plain", j::Job)
    if istruck(j)
        a = 'V'
    else
        a = 'T'
    end
    if isload(j)
        b = 'L'
    else
        b = 'U'
    end

    pstr = join([loc(j),t_arrival(j), t_processing(j)],",")

    jstring = "$(id(j)): $pstr [$(a*b)]" 
    println(io, jstring)
end

function Base.show(io::IO, ::MIME"text/plain", v::Vector{Job})
    println(io, "$(length(v))-element $(typeof(v)):")
    for j in v
        println(io, j)
    end
end

function Base.isless(j1::Job, j2::Job)
    istruck(j1) && istrain(j2) && return true
    istruck(j2) && istrain(j1) && return false
    isunload(j1) && isload(j2) && return true
    isunload(j2) && isload(j1) && return false
end

"""
    precedes(j1::Job, j2::Job)

Check if `j1` must precede `j2`. Use `≺` for short (infix) notation.
"""
function precedes(j1::Job, j2::Job)
    loc(j1) != loc(j2) && return false
    istruck(j1) && istrain(j2) && return true
    istruck(j2) && istrain(j1) && return false
    isunload(j1) && isload(j2) && return true
    isunload(j2) && isload(j1) && return false
end

"""
    ≺(j1, j2)

Shorthand for `precedes(j1,j2)`
"""
≺(j1, j2) = precedes(j1, j2)