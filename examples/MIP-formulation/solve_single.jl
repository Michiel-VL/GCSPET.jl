# Script to solve a single instance of the GCSPET using the formulation by Guo et al. Requires Cbc to be installed.
using Pkg
Pkg.activate("")
using GCSPET

include("formulation.jl")

ipath = ARGS[1]
opath = ARGS[2]

inst = GCSPET.read(ipath, Instance)

solution = solve_instance(inst, Cbc.Optimizer)

GCSPET.write(solution, opath*name(inst)*"_Cbc.dat")