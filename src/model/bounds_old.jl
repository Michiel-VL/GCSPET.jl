
Σ(f::Function, Ω::Array{Job{T},1}) where {T} = sum(map(x->f(x), Ω))
twt(j::Job) = j.jtype ==2 ? t_compl(j) - t_arr(j) : 0
LB_twt(Ω::Array{Job{T},1}) where {T} = Σ(twt,Ω)
#Cmax definition
LB1_cmax(Ω::Array{Job{T},1}) where {T} = maximum(map(x->t_compl(x),Ω))

function LB2_cmax(Ω::Array{Job{T},1}, nCranes::Int64) where {T}
    t_occ = Σ(t_proc, Ω)
    return Int(ceil(t_occ / nCranes))
end

function LB3_cmax(Ω::Array{Job{T},1}, nCranes::Int64) where T
    t_occ = Σ(t_proc, Ω)
    s = Set{Int64}()
    #gather all unique locations
    for job in Ω
        push!(s,loc(job))
    end
    values = collect(s)
    sort!(values)
    dist = values[end] - values[1]
    to_remove = 0
    inter_loc_dist = Array{Int64,1}()
    for i in 1:length(values)-1
        push!(inter_loc_dist,values[i+1]-values[i])
    end
    sort!(inter_loc_dist)
    tot_occ = t_occ + sum(inter_loc_dist[1:end-(nCranes-1)]) # total processing time of the jobs, plus the sum of the travel times between all positions except n-1
    return Int(ceil(tot_occ/nCranes))
end

function LB_cmax(Ω::Array{Job{T},1}, nCranes::Int64) where {T}
    return max(LB1_cmax(Ω), LB3_cmax(Ω, nCranes))
end

function LB(Ω::Array{Job{T},1}, nCranes::Int64) where {T}
    return LB_cmax(Ω, nCranes) + LB_twt(Ω)
end


# Bounds

# We can calculate a bound to the problem by generating all precedence-feasible
# permutations for neighbor-sets. A neighbor-set is a set of jobs whose positions
# are close enough to eachother

function neighbouring(j1, j2, σ)
    d = abs(loc(j1) - loc(j2))
    int1 = t_alt_arr(j1):(t_alt_arr(j1)+t_proc(j1))
    int2 = t_alt_arr(j2):(t_alt_arr(j2)+t_proc(j2))
    return (d <= σ) && (d != 0) && (!isempty(int1 ∩ int2))
end


# # A lower bound of twt can be found as follows:
# # For every truck-related job that has no neighbours:
# # the contribution is only depending on its alt_arr_time
#
# p0 = Array{Int,1}()
# P = Array{Array{Int,1},1}()
# push!(P,p0)
# function generate_perms(J::Array{Int,1}, P::Array{Array{Int,1},1}=[Int[]]) where {T}
#     #println(typeof(P))
#     if isempty(J)
#         return P
#     end
#     P_ = Array{Array{Int,1},1}()
#     sizehint!(P_, length(P)*length(J))
#     Q = Array{Array{Int,1},1}()
#     for el in P
#         for j in eachindex(J)
#             push!(P_, [el ; J[j]] )
#             J_ = copy(J) # to be replaced with a precendence replacement
#             deleteat!(J_,j)
#             append!(Q,generate_perms(J_, P_))
#         end
#     end
#     return Q
# end
#
# generate_perms([1,2,3])
#
# J = [3,4]
# P_ = []
# for el in [[1,2],[2,1]]
#     for j in J
#         push!(P_, [el; j])
#     end
# end
#
# function all_perms(perms_L::Array{Array{Job{Int},1},1}, ellist::Array{Job{Int},1})
#     permsL1 = Array{Array{Job{Int},1},1}()
#     for p in perms_L
#         for i in 1:length(ellist)
#             new_p = [copy(p); [ellist[i]]]
#             if isnothing(next(ellist[i]))
#                 deleteat!(new_ellist, i)
#             else
#                 replace!(new_ellist, ellist[i] => next(ellist[i]))
#             end
#             new_start_perm = [copy(previous_p); [ellist[i]]]
#             new_p = all_perms(new_start_perm, new_ellist)
#             push!(startperms, new_p)
#         end
#     end
#     return startperms
# end
#
#
# inst = readinstance(instance_dir*"100_6_0.5_5.dat")
#
# ld = build_locdict(inst.J)
#
# j_set = Set{Job{Int}}()
# truck_jobs = filter(j->jtype(j)==2, inst.J)
# for i in truck_jobs, j in truck_jobs
#     if neighbouring(i,j,1)
#             push!(j_set, i)
#             push!(j_set, j)
#     end
# end
#
#
# sorted_J = sort!([j_set...], by=loc)
#
# function buildclusters(sorted_J, σ)
#     clusters = Array{Array{Job{Int},1},1}()
#     cluster = Array{Job{Int},1}()
#     push!(cluster, sorted_J[1])
#     for i in 2:length(sorted_J)
#         if loc(sorted_J[i]) - loc(sorted_J[i-1]) <= σ
#             push!(cluster, sorted_J[i])
#             if i==length(sorted_J)
#                 push!(clusters, cluster)
#             end
#         else
#             push!(clusters, cluster)
#             cluster = Array{Job{Int},1}()
#             push!(cluster,sorted_J[i])
#         end
#     end
#     return clusters
# end
#
# clusters = buildclusters(sorted_J,1)
#
# for cluster in clusters[1:1]
#     println(all_perms([Job{Int}[]], cluster))
# end
#
# copy(inst.J)
