using Compat

runtest(filename) = (println(filename); include(filename))

runtest("api.jl")
