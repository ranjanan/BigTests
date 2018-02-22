module BigTests
    
    using Circuitscape
    using PyCall
    import Circuitscape: compute_single, compute_cholmod
    using BenchmarkTools
    @pyimport circuitscape as cs

    export runall
    include("script.jl")

end
