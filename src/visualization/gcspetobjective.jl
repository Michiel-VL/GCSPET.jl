export gcspetobjective

@userplot GCSPETObjective

@recipe function f(p::GCSPETObjective)
    sol = p.args[1]
    Ω = jobs(sol)
    layout := (length(trajectories(sol)),1)
    legend := :topleft
    println(length.(jobset.(trajectories(sol))))
    xmax = maximum(length.(jobset.(trajectories(sol))))
    ymax = truckwaitingtime(sol)
    
    
    for (i,t) in enumerate(reverse(trajectories(sol)))
        subplottitle --> "RMG $i"
        jset = jobset(t)
        Ωset = map(j -> Ω[j], jset)
        t_compl = map(j -> t_completion(sol, j), jset)
        V = filter(j -> istruck(j), Ωset)
        println(V)
        println(map(j -> t_truckwaiting(j, t_completion(sol, id(j))),V))
        twt = accumulate(+, map(j -> t_truckwaitingtostart(j[1], j[2]), zip(Ωset,t_compl)))
        println(twt)
        titlefontsize --> 8
        ylabel --> "TWT"
        xlim := (1,xmax)
        ylim := (0,ymax)
        xticks := 0:xmax
        yticks := 0:ymax ÷ 5:ymax
        ticklabelfontsize := 4
        labelfontsize := 8
        margin := 2Main.Plots.mm
        @series begin
            subplot := i
            primary := false
            seriestype := :step
            linecolor := :black
            fillcolor := :red
            fillalpha := 0.5
            fillrange := 0

            eachindex(twt), twt
        end

        @series begin
            subplot := i
            primary := false
            seriestype := :path
            linecolor := :black
            [length(twt),length(twt)], [0,last(twt)]
        end
        @series begin
            primary := false
            label := "waiting time"
            seriestype := :path
            subplot := i

        end
    end

end