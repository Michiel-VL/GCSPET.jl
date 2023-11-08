push!(LOAD_PATH, "../src/")
using Pkg
Pkg.activate("..")
ENV["GKSwstype"] = "100"
using Documenter, GCSPET

makedocs(   sitename = "GCSPET Documentation",
            pages = ["Problem description" => "problem_description.md",
            "IO" => "io.md",
            "Solution validation" => "validation.md",
            "Visualization" => "visualization.md", 
            "Results" => "results.md",
            "Other functionality" => "other.md"]
)