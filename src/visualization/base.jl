
"""
    VizData{C}

Struct storing a configuration of the visualization parameters.
"""
mutable struct VizData{C}
    trajdash::String
    jobdash::String
    safetydash::String

    trajlinewidth::Float64
    jobboxlinewidth::Float64
    safetylinewidth::Float64
    
    trajcolor::Vector{C}
    safetycolor::Vector{C}
    jobcolors::Matrix{C}
end

function VizData(ncranes::Int)
    trajdash = "solid"
    jobdash = "solid"
    safetydash = "longdashed"

    trajlinewidth = 1.0
    jobboxlinewidth = 1.0
    safetylinewidth = 1.0

    trajcolor = fill(RGBA(0,0,0, 1.0), ncranes)
    safetycolor = fill(RGBA(1,0,0, .4), ncranes)
    jobcolors = fill(RGBA(1,1,1, 1.0), 2,2)

    VizData(trajdash, jobdash, safetydash, trajlinewidth, jobboxlinewidth, safetylinewidth, trajcolor, safetycolor, jobcolors)
end

jobcolor(cfg::VizData, jt, mt) = cfg.jobcolors[jt,mt]

"""
    BaseLayer{C}

Defines a baselayer for the visualization, with colors of type `C`.
"""
mutable struct BaseLayer{C}
    axislines::Vector{Tuple{Point, Point}}
    gridlines::Vector{Tuple{Point, Point}}
    bgcolor::C
    
    axiscolor::C
    axiswidth::Float64
    axisdash::String

    gridcolor::C
    gridwidth::Float64
    griddash::String
end

function BaseLayer(axislines, gridlines)
    BaseLayer(  axislines, 
                gridlines, 
                RGBA(1,1,1, 1.0),
                
                RGBA(0,0, 0, 1.0), 
                1.5,
                "solid",
                
                RGBA(.8, .8, .8, 1.0),
                0.5, 
                "solid")
end

BaseLayer(axislines) = BaseLayer(axislines, Tuple{Point,Point}[])

drawaxis(b::BaseLayer) = drawarrows(b.axislines, b.axiscolor, b.axiswidth, b.axisdash)
drawgrid(b::BaseLayer) = drawlines(b.gridlines, b.gridcolor, b.gridwidth, b.griddash)


# Required functions
tmax(s::Solution) = makespan(s)
xmax(s::Solution) = njobs(s)

function trajpoints(s::Solution, i)
    tr = trajectories(s)[i]
    Point.(tr.T, tr.X)
end

"""
    trajjobs(s::Solution), i)

Returns tuples (t_start, j_id) for all jobs in the trajectory `i` of the solution.
"""
function trajjobs(s::Solution, i)
    tr = trajectories(s)[i]
    idxs = findall(j -> j > 0, tr.J)
    map(i -> (tr.T[i], tr.J[i]), idxs[1:2:end])
end

function jobdata(s::Solution, i)
    j = jobs(s)[i]
    (id(j), loc(j), !jobtype(j)+1, t_processing(j), movetype(j)+1, t_arrival(j)) # bool to integer conversion for job- and movetypes
end

## 
function draw(sol::Solution, w, h, fname, cfg = VizData(ncranes(sol)); showarrival=false)
    Drawing(w, h,fname)
    # Prepare environment
    xm = tmax(sol) + 1
    ym = xmax(sol) + 1
    prepare(w, h, xm, ym)
    # Configure background
    

    # Draw trajectories and jobs
    for i in 1:ncranes(sol)
        drawtrajectory(trajpoints(sol, i), 1, i, cfg)
        for (t, id) in trajjobs(sol, i)
            drawjob(jobdata(sol, id), t, cfg, showarrival = showarrival)
        end
    end
    finish()
    preview()
end


function drawlines(lines, color, width, dash)
    setcolor(color)
    setline(width)
    setdash(dash)
    for (s, d) in lines
        line(s,d, :stroke)
    end
end

function drawarrows(lines, color, width, dash)
    setcolor(color)
    for (s, d) in lines
        arrow(s,d, linewidth = width)
    end 
end



"""
    prepare(w, h, xmax, ymax)

Construct an initial image
"""
function prepare(w, h, xmax, ymax)
    margin = 0.05*h

    p0 = Point(margin, h-margin)


    origin(p0)

    xax  = Point(0,0), Point(w-2margin,0)
    yax = Point(0,0), Point(0, h-2margin)
    axislines = [xax, yax]
    
    b = BaseLayer(axislines)
    background(b.bgcolor)
    fontsize(32)
    label("x", :NW, -yax[2])
    label("t", :SE, xax[2])
    
    transform([1 0 0 -1 0 0])

    # Base BaseLayer
    drawaxis(b)
    xscaling = (w - 2 * margin) / (xmax)
    yscaling = (h - 2 * margin) / (ymax)
    
    scale(xscaling, yscaling)

    xgrid = [(Point(x, 0), Point(x, ymax)) for x in 5:5:xmax]
    ygrid = [(Point(0, y), Point(xmax, y)) for y in 5:5:ymax]

    gridlines = vcat(xgrid, ygrid)
    b.gridlines = gridlines
    drawgrid(b)
end





function drawtrajectory(pts, safety, cid, cfg)
    segments = Iterators.zip(pts[1:end-1], pts[2:end])
    σ = Point(0, safety)
    ptop = Point[]
    pbot = Point[]

    setcolor(cfg.trajcolor[cid])
    setline(cfg.trajlinewidth)
    setdash(cfg.trajdash)
    for (s,d) in segments
        line(s, d, :stroke)
        push!(pbot, s - σ, d - σ)
        push!(ptop, s + σ, d + σ)
    end
    
    setcolor(cfg.safetycolor[cid])
    setline(cfg.safetylinewidth)
    setdash(cfg.safetydash)
    poly(vcat(ptop, reverse(ptop)), :fill)

    n = length(ptop)

    for i in 1:n-1
        line(ptop[i], ptop[i+1], :stroke)
        line(pbot[i], pbot[i+1], :stroke)
    end
end

function drawjob(data, t, cfg; showarrival=false)
    id, l, jt, p, mt, a = data
    setcolor(jobcolor(cfg, jt, mt))
    setline(cfg.jobboxlinewidth)
    setdash(cfg.jobdash)
    center = Point(t + p/2, l)
    if a != 0 && showarrival
        setcolor("black")
        line(Point(a, l), center, :stroke)
        line(Point(a, l - 0.25), Point(a, l + 0.25), :stroke)
        setcolor(jobcolor(cfg, jt, mt))
    end
    box(center, p, 1, :fill)
    sethue("black")
    box(center, p, 1, :stroke)
end



