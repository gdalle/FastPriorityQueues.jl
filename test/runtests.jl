using Test

@testset verbose = true "FastPriorityQueues.jl" begin
    @testset verbose = true "Correctness" begin
        include("correctness.jl")
    end
end
