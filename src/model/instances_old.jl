using Distributions, DelimitedFiles

generate_job(id, l_distr, jobtype, p_distr) = Job(id, rand(l_distr), 0, rand(p_distr), jobtype, 0)

function generate_jobs(njobs, ncranes, ϵ)
    l_distr = DiscreteUniform(1,njobs)
    p_distr = DiscreteUniform(3,10)

    ntruck = round(ϵ * njobs)
    ntrain = njobs - ntruck

    Ω = Array{Job,1}()
    V = Array{Job,1}()

    ## Keep track of the amount of jobs per position to introduce precedence relations if necessary
    jobs_per_pos = zeros(Int64,njobs)
    ##Generate train-jobs
	id = 1
    while length(Ω) < ntrain
        j = generate_job(0, l_distr, 1, p_distr)
        if(jobs_per_pos[j.l]<2)
            push!(Ω,j)
            jobs_per_pos[j.l] += 1
            j.mtype = jobs_per_pos[j.l]
			j.id = id
			id += 1
        end
    end

    truck_jobs_per_pos= zeros(Int64,njobs)
    ##Generate truck-jobs
    while length(V) < ntruck
        j = generate_job(0, l_distr, 2, p_distr)
        if(truck_jobs_per_pos[j.l]<2)
            push!(Ω,j)
            push!(V,j)
            truck_jobs_per_pos[j.l] += 1
            j.mtype = truck_jobs_per_pos[j.l]
			j.id = id
			id += 1
        end
    end

    ## Assign arrival times to truck-jobs
    ptot = calc_total_pTime(Ω)
    a_distr = DiscreteUniform(1, floor(ptot/ncranes))
    for j in V
        j.a_t = rand(a_distr)
    end
    return Ω
end


function generate_cranes(nJobs, nCranes)
    step = round(nJobs/nCranes)
    first = rand(1:step)
    return [Int(first+(c-1)*step) for c in 1:nCranes]
end


function generate_instance(njobs, ncranes, ϵ, s)
    params = (njobs = njobs, ncranes = ncranes, load = ϵ, sample = s)
    J = generate_jobs(njobs, ncranes, ϵ)
    l_0 = generate_cranes(njobs, ncranes)
	return (params = params, J = J, l_0 = l_0)
end

function generate_instances(njobs, ncranes, ϵ, s)
	instance_list = []
	for sample in 1:s
		push!(instance_list, generate_instance(njobs,ncranes,ϵ, sample))
	end
	return instance_list
end

##Get features of list of jobs

operating_positions(Ω) = map(j-> loc(j), Ω)
job_types(Ω) = map(j-> jtype(j), Ω)
processing_times(Ω) = map(j-> t_proc(j), Ω)
move_types(Ω) = map(j-> mtype(j), Ω)
arrival_times(Ω) = map(j-> t_arr(j), Ω)
identifier(inst)= join(inst.params, "_")
filename(inst) = string(identifier(inst), ".dat")

calc_total_pTime(Ω::Array{Job,1}) = sum([t_proc(j) for j in Ω])

function to_file(inst, dir, prefix)
    fn = dir*prefix*filename(inst)
    file = open(fn, "w")
    println(file,inst.params.njobs)
    println(file,inst.params.ncranes)
    writedlm(file,inst.l_0', ",")
    func_list = [operating_positions, job_types, processing_times, move_types, arrival_times]
    for func in func_list
        writedlm(file, func(inst.J)', ",")
    end
    close(file)
end
#=
function write_param_file(fileName::String,instances::Array{Instance,1}, time::Dict{Int64,Int64}, L::Array{Int64,1}, n_seeds::Int64, obj::Array{String,1})
	file = open(fileName, "w")
	for inst in instances
		for ll in L
			for s in 1:n_seeds
				for o in obj
					param_line = string("data/large/",identifier(inst),".dat ", ll+rand(-7:7), " ", time[Int64(floor(inst.nJobs/10)*10)], " ", rand(1:100000), " ", o,"\n")
					write(file,param_line)
				end
			end
		end
	end
	close(file)
end

function experiment_small(job_sizes=[nJobs for nJobs in 10:2:49],
						  crane_nrs = [nCranes for nCranes in 2:4],
						  loads = [load for load in 0.1:0.1:0.9],
						  samples = [s for s in 1:3],
						  L = [15, 80, 150],
						  nSeeds = 3,
						  obj = ["twt_cmax","twt_cmax_displ"]
						  )

	instance_list = generate_instances(job_sizes, crane_nrs, loads, samples)
	for inst in instance_list
		to_file("experiment/data/small/", inst)
	end

	dict_keys = [ Int64(floor(nJobs/10)*10) for nJobs in job_sizes]
	dict_values = [Int64(2^((key/10)-1)*1000) for key in dict_keys]
	times_dict = Dict(zip(dict_keys,dict_values))
	write_param_file("experiment/data/parameters_small_instances.csv", instance_list, times_dict, L, nSeeds,obj)
end


function experiment_large(job_sizes=[nJobs for nJobs in 50:2:80],
						  crane_nrs = [nCranes for nCranes in 4:6],
						  loads = [load for load in 0.1:0.1:0.9],
						  samples = [s for s in 1:3],
						  L = [15, 80, 150],
						  nSeeds = 3,
						  obj = ["twt_cmax","twt_cmax_displ"]
						  )
	instance_list = Array{Instance,1}()
	for nJobs in job_sizes
		for nCranes in crane_nrs
			for i in 1:10
				load = rand(loads)
				inst = generate_instance(nJobs,nCranes,load)
				inst.s = i
				push!(instance_list, inst)
			end
		end
	end

	for inst in instance_list
		to_file("experiment2/data/large/", inst)
	end

	dict_keys = [ Int64(floor(nJobs/10)*10) for nJobs in job_sizes]
	dict_values = [Int64(2^((key/10)-1)*1000) for key in dict_keys]
	times_dict = Dict(zip(dict_keys,dict_values))
	write_param_file("experiment2/data/parameters_large_instances.csv", instance_list, times_dict, L, nSeeds,obj)
end
=#
