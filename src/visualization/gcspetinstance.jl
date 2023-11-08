using LaTeXStrings

export gcspetinstance

@userplot GCSPETInstance


@recipe function f(p::GCSPETInstance; show_ids = true)
    inst = p.args[1]
    Ω = jobs(inst)
    Q = cranes(inst)

    # We plot all the cranes



    # we plot all the jobs
    # 1. construct the graph
    x_start = loc.(Ω)
    t_start = earliest_start_times(Ω)
    t_proc = t_processing.(Ω)
    t_compl = t_start .+ t_proc
    jobtypes = jobtype.(Ω)
    jobcoords(ts, tp, x) = ([ts,ts,ts+tp,ts+tp], [x-0.5, x+0.5, x+0.5, x-0.5])
    coords = map(a -> jobcoords(a...), zip(t_start, t_proc, x_start))

    colorset = map(j -> jobtype(j) ? :lightblue : :lightgreen, Ω)

    @show colorset
    colorset = reshape(colorset, 1, length(colorset))
    
    N = namestr.(Ω)
    @show colorset
    xlabel --> "Time"
    ylabel --> "Location"
    xlims --> (0, maximum(t_compl)+3)

            
    qtstart = zeros(Int, length(Q))
    qxstart = starting_position.(Q)

        
    @series begin
        seriestype := :scatter
        primary := false
        color --> :black
        markersize --> 4
        qtstart, qxstart
    end


    
    @series begin
        seriestype := :shape
        primary := false
        fillcolor := :white
        annotationfontsize := 5
        if show_ids
            annotation:= (t_start + t_proc/2, x_start, latexstring.(latexnamestr.(Ω)))
        end
        foreach(a -> println.(a), zip(N, colorset, coords))
        coords
    end
end
