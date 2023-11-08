# Solve all instances in the directory passed and save the solution files in the output-directory
using Pkg
Pkg.activate("")

idir = ARGS[1]
odir = ARGS[2]

for inst in readdir(idir)
    sol = solve_instance(inst)
    GCSPET.write(sol, odir * name(inst) * "_Cbc.dat")
end