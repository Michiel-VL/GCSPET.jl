# Problem Description

## Introduction

## Problem definition

## Instance sets

### Instance sets by Guo et al.


```@eval
using GCSPET, Plots

Jsmall = (10,15,20,25)
Qsmall = (2,3,4)
Jlarge = (40,60,80,100)
Qlarge = (4,5,6)
l = [0.1*i for i in 1:5]

small = sort!(vec(collect(Iterators.product(Jsmall, Qsmall, l))))
large = sort!(vec(collect(Iterators.product(Jlarge, Qlarge, l))))

Ps = map(i-> getindex.(small, i), 1:3)
Pl = map(i-> getindex.(large, i), 1:3)

scatter3d(Ps...,label="Small instances")
xlabel!("njobs")
ylabel!("ncranes")
zlabel!("load")
scatter3d!(Pl...,label="Large instances")
savefig("guo_instance_parameters_3D.png")
nothing
```

![](guo_instance_parameters_3D.png)