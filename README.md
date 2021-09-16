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
A simple script is provided to generate instances from a parameter-grid, using the original distributions as presented in [Guo](https://www.tandfonline.com/doi/abs/10.1080/00207543.2018.1444812)

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
GCSPET solution files carry the extension `.sched` and have the following format (comments not present in file): after a repetition of all of the instance data, the movements and execution of jobs through time are given for each crane. After the id is given, three vectors containing respectively the positional, temporal and job-ids are given.

```
10                              # number of jobs (njobs)
2                               # number of cranes (ncranes)
1,6                             # crane starting positions along non-crossing axis
2,3,7,5,4,9,6,6,10,3            # job positions along non-crossing axis
1,1,1,1,1,1,1,1,1,2             # job types (1 = train, 2 = truck)
8,9,5,8,8,4,3,6,10,5            # processing times
2,2,1,2,1,1,2,1,2,1             # move types (1 = unloading 2 = loading)
0,0,0,0,0,0,0,0,0,12            # arrival times
1                               # crane id
x,                              # crane positions throughout the schedule
t,                              # time at position x
j,                              # job at time t ( j = -1 if none, j = id if any. Every id occurs twice, for start and stop)
2                               # repeat for all cranes
x,
t,
j,
```


## Validation
TODO

## Visualization
TODO