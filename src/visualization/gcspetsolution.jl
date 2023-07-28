#TODO: Fix bug in coloring of jobs. Aside from that issues are only minor and the plots look fairly okay. Maybe it would be better to split the plots in such a way that they are composable as well.
export gcspetsolution

"""
    gcspetplot()
    - Jobs
    - Cranes
    - starting times
    - crane ids
"""
@userplot GCSPETSolution

#= Includes: 
    - Crane trajectories
    - Crane positions
    - Job executions
    - Safety zones
    - Objective values
=# 

@recipe function f(p::GCSPETSolution; show_safety = true, show_ids = true, show_waiting=false, show_objective=true)
    sol = p.args[1] 
    Ω = jobs(sol)
    Q = cranes(sol)
    # Every job is plotted as a rectangle of width t_proc and height 1, with topleft corner (t_start, loc-0.5)

    xlim --> (0, 1.05*makespan(sol))
    ylim --> (0, njobs(sol)+1)
    xlabel --> "Time" 
    ylabel --> "Position"
    legend --> false
    #(w,h) = get(plotattributes, :size, (900,600))
    #ratio = length(Ω)/makespan(sol)
    #size --> (w, w*ratio)

    # Job Preprocessing
    t_compl = map(j -> t_completion(sol, id(j)), Ω)
    t_proc = map(j -> t_processing(j), Ω)
    t_start = t_compl .- t_proc
    x_start = map(j -> loc(j), Ω)
    mtype = map(j -> movetype(j), Ω)
    
    jobcoords(ts, tp, x) = ([ts,ts,ts+tp,ts+tp], [x-0.5, x+0.5, x+0.5, x-0.5])
    coords = map( a -> jobcoords(a...) ,zip(t_start, t_proc, x_start))
    colorset = map(j -> jobtype(j) ? :lightgreen : :lightblue, Ω)
    colorset = reshape(colorset, 1, length(colorset))

    # Plot the crane positions
    for (i,traj) in enumerate(trajectories(sol))
        σ = safety(Q[i])
        if show_safety
            @series begin
                seriestype := :path
                linealpha --> 0
                primary := false
                fillrange := traj.X .- σ
                fillalpha --> 0.3
                fillcolor --> :gray
                traj.T, traj.X .+ σ
            end
            @series begin
                seriestype := :path
                linestyle := :dash
                linewidth --> 0.5
                linecolor --> :black
                primary := false
                traj.T, traj.X .+ σ
            end

            @series begin
                seriestype := :path
                linestyle := :dash
                linewidth --> 0.5
                linecolor --> :black
                primary := :false
                traj.T, traj.X .- σ
            end

        end 
        @series begin
            seriestype := :path
            linecolor --> :black
            linewidth --> 2
            traj.T, traj.X
        end

        @series begin
            marker --> :circle
            markercolor --> :black
            primary := false
            traj.T[1:1], traj.X[1:1]
        end
    end 



    if show_waiting
        V = filter(istruck, Ω)
        t_arr = t_arrival.(V)
        x_startV = map(j -> loc(j), V)
        t_startV = map(j -> t_completion(sol,id(j)) - t_processing(j) ,V)
        waitcoords(ts, tp, x) = ([ts,ts,ts+tp,ts+tp], [x-0.25, x+0.25, x+0.25, x-0.25])
        wcoords = map( a -> waitcoords(a...), zip(t_arr, t_startV .- t_arr, x_startV))
        @series begin
            seriestype := :shape
            primary := false
            fillcolor := :red
            fillalpha := 0.3
            linealpha := 0
            annotationfontsize := 5
            annotationcolor := :red
            annotationhalign := :right
            annotation := (t_arr .- 0.5, x_startV .- 0.25,  t_startV .+ t_processing.(V) .- t_arr)#text((t_startV .- t_arr)))
            wcoords
        end

    end

    # split the jobs per jobtype and plot series separately

    job_coord_pairs = collect(zip(Ω, coords))

    Tset = last.(filter(t -> istrain(t[1]), job_coord_pairs))
    Vset = last.(filter(t -> istruck(t[1]), job_coord_pairs))    

    @series begin
        seriestype := :shape
        primary := false
        fillcolor := "lightblue"
        annotationfontsize := 5
        if show_ids
            annotation := (t_start+t_proc/2, x_start, id.(Ω))
        end
        #fillalpha := 0.5
        Tset
    end

    @series begin
        seriestype := :shape
        primary := false
        fillcolor := "lightgreen"
        annotationfontsize := 5
        if show_ids
            annotation := (t_start+t_proc/2, x_start, id.(Ω))
        end
        #fillalpha := 0.5
        Vset
    end

    if show_objective
        @series begin
            seriestype := :path
            color := :red
            annotation := (makespan(sol), njobs(sol)+ 0.25, makespan(sol))
            annotationcolor := :red
            annotationhalign := :left
            annotationfontsize := 10
            line_width := 2
            fill(makespan(sol), 2), [0, njobs(sol)]    
        end
    end
end