"""
GCSPETSolution

Data structure representing GCSPET Solution.
"""
struct GCSPETSolution
name::String
jobdata::Matrix{Int}
cranedata::Vector{Int}
trajectories::Vector{Matrix{Int}}
safety::Int
end

function GCSPETSolution(fname)
params, data = readfile(fname)
return GCSPETSolution(fname, data..., 1)
end


jobdata(sol::GCSPETSolution) = sol.jobdata
function jobdata(sol::GCSPETSolution, id)
i = findfirst(idx -> sol.jobdata[idx,1] == id, 1:size(sol.jobdata, 1))
return sol.jobdata[i,:]
end
cranedata(sol::GCSPETSolution) = sol.cranedata
trajectories(sol::GCSPETSolution) = sol.trajectories
njobs(sol::GCSPETSolution) = size(jobdata(sol),1)
ncranes(sol::GCSPETSolution) = length(cranedata(sol))
xmax(sol::GCSPETSolution) = njobs(sol)
tmax(sol::GCSPETSolution) = maximum(t -> t[end,2], trajectories(sol))

function trajpoints(sol::GCSPETSolution, i)
traj = sol.trajectories[i]
[Point(t, x) for (x,t) in Iterators.zip(traj[:,1], traj[:,2])]
end

"""
trajjobs(sol::GCSPETSolution, i)

Get the ids and starting times of all jobs executed in the trajectory
"""
function trajjobs(sol::GCSPETSolution, i)
t = sol.trajectories[i]
I = findall(x -> x != -1, t[:,3])
map(i -> (t[i,2],t[i,3]) ,I[1:2:end])
end
