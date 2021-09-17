# GCSPET.jl

This Julia package provides functionality for the Gantry Crane Scheduling Problem with External Trucks. Available functions are:

- IO: reading in and writing out instances and solutions to the GCSPET
- generation: create new instances using the original distributions, or using your own model.
- validation: validate the correctness of a solution-file against an instance-file.
- visualization: create and export visualizations to SVG, PNG, ... (functionality provided through [Luxor](https://github.com/JuliaGraphics/Luxor.jl))


# IO
## Reading and writing files
Use following functions to read and write instances and solutions.

```julia
using GCSPET

julia> fpath = getinstance("GCSPET_Guo", "10_2_0.4_1.dat")
"datadepsdir/GCSPET_Guo/SGCSPET_Instances/10_2_0.4_1.dat"

julia> inst = GCSPET.read(fpath, Instance)
Instance("10_2_0.4_1.dat", Job)
```

## Generating instances
A simple script is provided to generate instances from a parameter-grid, using the original distributions as presented in:
[Peng Guo, Wenming Cheng, Yi Wang & Nils Boysen (2018) Gantry crane scheduling in intermodal rail-road container terminals, International Journal of Production Research, 56:16, 5419-5436, DOI: 10.1080/00207543.2018.1444812 ](https://www.tandfonline.com/doi/abs/10.1080/00207543.2018.1444812)

## File Formats
### Instance files
GCSPET instance files carry the extension `.dat` and have the following format (comments not present in file):

```
10                              # number of jobs (njobs)
2                               # number of cranes (ncranes)
1,6                             # crane starting positions along non-crossing axis
2,3,7,5,4,9,6,6,10,3            # job positions along non-crossing axis
1,1,1,1,1,1,1,1,1,2             # job types (1 = train, 2 = truck)
8,9,5,8,8,4,3,6,10,5            # processing times
2,2,1,2,1,1,2,1,2,1             # move types (1 = unloading 2 = loading)
0,0,0,0,0,0,0,0,0,12            # arrival times
```

### Solution files
GCSPET solution files carry the extension `.sched` and have the following format (comments not present in file): 
- repetition of all of the instance data (note: a line including the ids is added, to allow out-of-order data)
- crane trajectories for each crane, each consisting of sequences for:
    * id
    * position along the x-axis (non-crossing axis)
    * timestamp
    * job-ids (-1  = no job)

```
42
2
20,41
21,35,12,15,32,22,30,36,24,20,23,8,19,29,34,3,38,40,6,18,25,27,41,10,2,7,9,11,16,4,26,31,1,28,0,13,33,17,39,5,14,37
1,1,3,4,5,7,8,8,9,10,10,11,12,12,14,14,17,20,20,21,21,22,23,25,25,26,27,27,28,28,29,29,30,32,32,36,36,37,38,39,40,42
2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,1,1,2,2,2,1,2,2,1,2,1,2,2,2,2,1,2,2
8,6,5,8,3,10,7,6,7,5,5,7,5,5,8,8,10,7,3,7,5,10,8,9,3,7,7,9,6,7,5,5,8,7,5,9,10,9,6,6,5,5
1,2,1,1,1,1,1,2,1,1,2,1,1,2,1,1,1,1,1,1,2,1,1,1,1,1,1,2,1,1,1,2,1,1,1,1,2,1,1,1,1,1
2,82,1,76,69,69,60,112,24,30,45,33,80,100,16,0,17,118,0,36,96,5,91,117,0,0,40,136,83,0,87,4,0,138,0,52,80,43,52,0,52,11
0
x,20,3,3,1,1,9,9,10,10,10,10,11,11,14,14,17,17,12,12,12,12,8,8,8,8,5,5,4,4,1,1,7,7,20,20,21,21,26,26,20,20,14,14
t,0,17,22,24,32,40,47,48,53,53,58,59,66,69,77,80,90,95,100,100,105,109,116,116,122,125,128,129,137,140,146,152,162,175,182,183,188,193,200,206,209,215,223
j,-1,12,12,21,21,24,24,20,20,23,23,8,8,34,34,38,38,19,19,29,29,30,30,36,36,32,32,15,15,35,35,22,22,40,40,25,25,7,7,6,6,3,3
1
x,41,39,39,42,42,21,21,22,22,27,27,36,36,38,38,40,40,37,37,36,36,29,29,29,29,28,28,27,27,25,25,23,23,32,32,32,32,30,30,28,28,25,25
t,0,2,8,11,16,37,44,45,55,60,67,76,85,87,93,95,100,103,112,113,123,130,135,135,140,141,147,148,157,159,168,170,178,187,194,194,199,201,209,211,218,221,224
j,-1,5,5,37,37,18,18,27,27,9,9,13,13,39,39,14,14,17,17,33,33,26,26,31,31,16,16,11,11,10,10,41,41,28,28,0,0,1,1,4,4,2,2
```

## Visualization

```julia
julia> using GCSPET

julia> sol = GCSPET.read("42_2_0.8_2.sched", Solution)
julia> draw(sol, 1000, 800, "solution.png")
```

![Example of a solution](solution.png)


## Validation
