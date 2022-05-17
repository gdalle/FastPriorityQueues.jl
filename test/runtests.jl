using Test

@testset verbose = true "FastPriorityQueues.jl" begin
    @testset verbose = true "VectorPriorityQueue" begin
        include("vector.jl")
    end
end
