guo_instances = DataDep("GCSPET_Guo", 
            "This package is tyring to automatically install the original instances of the GCSPET. The files will be installed to the folder: ",
            "https://www.researchgate.net/profile/Peng_Guo9/publication/322538542_2017GCSPET_Instances/data/5a5ef5b0aca272d4a3e02dd4/2017GCSPET-Instances.rar")

getinstancedir(key) = @datadep_str key


function getinstance(key, name)
    dir = getinstancedir(key)
    if key == "GCSPET_Guo"
        if parse(Int, first(split(name, "_"))) < 30
            ifile = joinpath(dir, "SGCSPET_Instances", name)
        else
            ifile = joinpath(dir, "LGCSPET_Instances", name)
        end
    else
        ifile = joinpath(dir, name)
    end

    return ifile
end

const small_guo = "SGCSPET"
const large_guo = "LGCSPET"