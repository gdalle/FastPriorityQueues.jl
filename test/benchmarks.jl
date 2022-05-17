# # Benchmarks

using BenchmarkTools
using DataStructures
using FastPriorityQueues
using GridGraphs
using Random
using Test

# ## Setup

#=
An interesting way to benchmark priority queues is to use them inside [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm), where they play a key role in performance.
According to [this technical report](https://www3.cs.stonybrook.edu/~rezaul/papers/TR-07-54.pdf), sizeable speedups can be achieved by inserting vertices several times into the queue instead of looking them up to update their priority values.

The internal `grid_dijkstra!(queue, g, s; naive)` function from [GridGraphs.jl](https://github.com/gdalle/GridGraphs.jl) has two useful features for our test case:
- it allows us to plug in any type of priority queue
- its keyword argument `naive` controls whether priority updates are enabled or not
=#

function test_dijkstra(n, pqtype; naive)
    Random.seed!(63)
    w = rand(n, n);
    g = GridGraph(w)
    pq = pqtype()
    return GridGraphs.grid_dijkstra!(pq, g, 1; naive=naive)
end;

#=
Our [`VectorPriorityQueue`](@ref) doesn't support priority updates, but it has very fast enqueueing and dequeueing routines.
We hope it will be sufficient to outperform `DataStructures.PriorityQueue` on this example.
=#

# ## Results

# Let us first verify that the outputs are coherent with one another.

d1 = test_dijkstra(100, PriorityQueue{Int,Float64}; naive=false).dists[end];
d2 = test_dijkstra(100, PriorityQueue{Int,Float64}; naive=true).dists[end];
d3 = test_dijkstra(100, VectorPriorityQueue{Int,Float64}; naive=true).dists[end];
@test d1 ≈ d2 ≈ d3

# Now we measure execution time and memory allocations for each of the three variants.

@btime test_dijkstra(100, PriorityQueue{Int,Float64}; naive=false);

#-

@btime test_dijkstra(100, PriorityQueue{Int,Float64}; naive=true);

#-

@btime test_dijkstra(100, VectorPriorityQueue{Int,Float64}; naive=true);

# As we can see, the `VectorPriorityQueue` reduced both of these measures by a significant amount.
