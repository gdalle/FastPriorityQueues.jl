# # Benchmarks

using BenchmarkTools  #src
using DataStructures
using FastPriorityQueues
using Graphs
using Plots
using Test

# ## Setup

#=
An interesting way to benchmark priority queues is to use them inside [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm), for which they play a key role in performance.

According to [this technical report](https://www3.cs.stonybrook.edu/~rezaul/papers/TR-07-54.pdf), there are two main implementations:
1. one that updates the priority values of vertices inside the queue
2. one that reinserts them with new priority values, potentially creating duplicates

[Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) uses the first version with a `DataStructures.PriorityQueue`, so here we code the second one.
=#

function dijkstra_no_priority_updates!(
    q::Q, g::AbstractGraph{T}, s::Integer, w=weights(g)
) where {Q,T}
    d = fill(Inf, nv(g))
    d[s] = 0.0
    enqueue!(q, s, 0.0)
    while !isempty(q)
        u, d_u = dequeue_pair!(q)
        if d_u <= d[u]
            d[u] = d_u
            for v in outneighbors(g, u)
                d_v = d[u] + w[u, v]
                if d_v < d[v]
                    enqueue!(q, v, d_v)
                    d[v] = d_v
                end
            end
        end
    end
    return d
end;

#=
Our custom queue types do not support priority updates, but on the other hand they have fast enqueueing and dequeueing routines, which makes them well-suited for `dijkstra_no_priority_updates!`.
=#

# ## Results

# Our goal is to see in which cases we can be faster than Graphs.jl.

test_dijkstra(g, qtype) = dijkstra_no_priority_updates!(qtype(), g, 1)[end];
test_dijkstra_default(g) = Graphs.dijkstra_shortest_paths(g, 1).dists[end];

# Let us first verify that the outputs of both implementations are coherent.

g_small = Graphs.grid([10, 10])

#-

d1 = test_dijkstra_default(g_small);
d2 = test_dijkstra(g_small, PriorityQueue{Int,Float64});
d3 = test_dijkstra(g_small, VectorPriorityQueue{Int,Float64});
d4 = test_dijkstra(g_small, SortedVectorPriorityQueue{Int,Float64});
d5 = test_dijkstra(g_small, HeapPriorityQueue{Int,Float64});
@test d1 ≈ d2 ≈ d3 ≈ d4 ≈ d5

# Now we measure execution time and memory allocations for each of the queue types.

function compare_dijkstra_versions(n_values)
    speed_gains = Dict(
        "PriorityQueue" => Float64[],
        "VectorPriorityQueue" => Float64[],
        "SortedVectorPriorityQueue" => Float64[],
        "HeapPriorityQueue" => Float64[],
    )
    memory_gains = Dict(
        "PriorityQueue" => Float64[],
        "VectorPriorityQueue" => Float64[],
        "SortedVectorPriorityQueue" => Float64[],
        "HeapPriorityQueue" => Float64[],
    )
    for n in n_values
        @info "Testing grids of side length $n"
        g = Graphs.grid([n, n])
        _, t0, m0, _, _ = @timed for _ in 1:5
            test_dijkstra_default(g)
        end
        _, t1, m1, _, _ = @timed for _ in 1:5
            test_dijkstra(g, PriorityQueue{Int,Float64})
        end
        _, t2, m2, _, _ = @timed for _ in 1:5
            test_dijkstra(g, VectorPriorityQueue{Int,Float64})
        end
        _, t3, m3, _, _ = @timed for _ in 1:5
            test_dijkstra(g, SortedVectorPriorityQueue{Int,Float64})
        end
        _, t4, m4, _, _ = @timed for _ in 1:5
            test_dijkstra(g, HeapPriorityQueue{Int,Float64})
        end
        push!(speed_gains["PriorityQueue"], t0 / t1)
        push!(speed_gains["VectorPriorityQueue"], t0 / t2)
        push!(speed_gains["SortedVectorPriorityQueue"], t0 / t3)
        push!(speed_gains["HeapPriorityQueue"], t0 / t4)
        push!(memory_gains["PriorityQueue"], m0 / m1)
        push!(memory_gains["VectorPriorityQueue"], m0 / m2)
        push!(memory_gains["SortedVectorPriorityQueue"], m0 / m3)
        push!(memory_gains["HeapPriorityQueue"], m0 / m4)

    end
    return speed_gains, memory_gains
end;

# To gain precision, we could replace the built-in `@elapsed` with `@belapsed` from [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl).

n_values = [10, 30, 100, 300, 1000]
speed_gains, memory_gains = compare_dijkstra_versions(n_values)

# Finally, let us plot the results.

settings = [
    "HeapPriorityQueue", "SortedVectorPriorityQueue", "VectorPriorityQueue", "PriorityQueue"
]
S = length(settings)
N = length(n_values)

# First we compare execution time

plt = plot(;
    title="Dijkstra with no priority updates",
    xlabel="Grid side length",
    ylabel="Speed gain wrt. Graphs.jl",
    ylim=(0, Inf),
    xticks=(1:N, string.(n_values)),
    margin=5Plots.mm,
    legend_position=:topright
)
for (k, setting) in enumerate(settings)
    bar!(
        plt,
        (1:N) .+ 0.7 * (k - (S + 1) / 2) / S,
        speed_gains[setting];
        label=setting,
        bar_width=0.7 / S,
    )
end
plt

# And we follow up with memory use

plt = plot(;
    title="Dijkstra with no priority updates",
    xlabel="Grid side length",
    ylabel="Memory gain wrt. Graphs.jl",
    ylim=(0, Inf),
    xticks=(1:N, string.(n_values)),
    margin=5Plots.mm,
    legend_position=:topleft
)
for (k, setting) in enumerate(settings)
    bar!(
        plt,
        (1:N) .+ 0.7 * (k - (S + 1) / 2) / S,
        memory_gains[setting];
        label=setting,
        bar_width=0.7 / S,
    )
end
plt
