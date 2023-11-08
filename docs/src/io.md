## Format of instance files

A GCSPET instance-file is stored as a `.dat`-file. The instance data is stored in the format below.

```
10                              # number of jobs (njobs)
4                               # number of cranes (ncranes)
2,4,6,8                         # crane starting locations
1,1,3,4,4,5,7,9,9,9             # job locations
2,1,1,2,2,1,2,2,1,1             # job types (1 = train, 2 = truck)
10,7,7,8,4,7,10,7,4,7           # processing times
1,1,1,1,2,1,1,1,1,2             # move types (1 = unloading, 2 = loading)
15,0,0,3,7,0,14,2,0,0           # arrival times
```

```@example
using GCSPET, Plots

inst = GCSPET.read("../../assets/instance_examples/10_4_0.5_3.dat", Instance)
gcspetinstance(inst, size=(800,450))
```


## Format of solution files

A GCSPET solution files is stored as a `.dat`-file. The solution data is stored in the format below.  

```
10                              # number of jobs (njobs)
4                               # number of cranes (ncranes)
2,4,6,8                         # crane starting locations
9,3,0,7,8,1,6,5,2,4             # job-ids used in the trajectories (see below)
1,1,3,4,4,5,7,9,9,9             # job locations
2,1,1,2,2,1,2,2,1,1             # job types (1 = train, 2 = truck)
10,7,7,8,4,7,10,7,4,7           # job processing times
1,1,1,1,2,1,1,1,1,2             # move types (1 = unloading, 2 = loading)
15,0,0,3,7,0,14,2,0,0           # job arrival times
0                               # crane id (For each crane the full trajectory is shown as three lists)
x,2,1,1,1,1,1                   # Trajectory x coordinates
t,0,1,15,25,25,32               # Trajectory t-coordinates
j,-1,-1,9,9,3,3                 # Jobs executed in the trajectory (beginning and end, -1 indicates the crane halts without doing a job)
1
x,4,4,4,4,4,4,5,5,3,3
t,0,0,3,11,11,15,16,23,25,32
j,-1,-1,7,7,8,8,1,1,0,0
2
x,6,7,7,7
t,0,1,14,24
j,-1,-1,6,6
3
x,8,9,9,9,9,9,9,9
t,0,1,2,9,9,13,13,20
j,-1,-1,5,5,2,2,4,4
```

The data in this file represents the solution below.

```@example
using GCSPET, Plots

sol = GCSPET.read("../../assets/solution_examples/10_4_0.5_3.sched", Solution)
gcspetsolution(sol, size=(800,450))
```