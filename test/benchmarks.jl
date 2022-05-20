# # Benchmarks

using BenchmarkTools  #src
using DataStructures
using FastPriorityQueues
using Graphs
using LinearAlgebra
using Plots
using SparseArrays
using Test

# ## Setup

#=
An interesting way to benchmark priority queues is to use them inside [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm), for which they play a key role in performance.

According to [this technical report](https://www3.cs.stonybrook.edu/~rezaul/papers/TR-07-54.pdf), there are two main implementations:
1. one that updates the priority values of vertices inside the queue
2. one that reinserts them with new priority values, potentially creating duplicates
=#

function dijkstra_updates!(
    q::Q, g::AbstractGraph{T}, s::Integer, w=weights(g)
) where {Q,T}
    d = fill(Inf, nv(g))
    q[s] = 0.
    d[s] = 0.
    while !isempty(q)
        u, d_u = dequeue_pair!(q)
        d[u] = d_u
        for v in outneighbors(g, u)
            d_v = d[u] + w[u, v]
            if d_v < d[v]
                q[v] = d_v
                d[v] = d_v
            end
        end
    end
    return d
end;

#-

function dijkstra_no_updates!(
    q::Q, g::AbstractGraph{T}, s::Integer, w=weights(g)
) where {Q,T}
    d = fill(Inf, nv(g))
    enqueue!(q, s, 0.0)
    d[s] = 0.0
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
Note that [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) uses option 1 with a `DataStructures.PriorityQueue` (which does not accept duplicate keys) for its Dijkstra implementation. Thus, it basically boils down to `dijkstra_updates!`.
Meanwhile, our custom queue types do not support priority updates, but they have fast enqueueing and dequeueing routines. Therefore, we can hope to get the best out of them with `dijkstra_no_updates!`.
=#

# ## Results

# Our goal is to see in which cases we can be faster than Graphs.jl.

function random_weights(g)
    srcs = src.(edges(g))
    dsts = dst.(edges(g))
    w = sparse(srcs, dsts, rand(ne(g)), ne(g), ne(g))
    return Symmetric((w + w') / 2)
end;

#-

test_dijkstra_no_updates(g, w, qtype) = dijkstra_no_updates!(qtype(), g, 1, w)[end];
test_dijkstra_updates(g, w, qtype) = dijkstra_updates!(qtype(), g, 1, w)[end];
test_dijkstra_default(g, w) = Graphs.dijkstra_shortest_paths(g, 1, w).dists[end];

# Let us first verify that the outputs of both implementations are coherent.

g_small = Graphs.grid([10, 10])
w_small = random_weights(g_small);

#-

d0 = test_dijkstra_default(g_small, w_small);
d0_bis = test_dijkstra_updates(g_small, w_small, PriorityQueue{Int,Float64});
d1 = test_dijkstra_no_updates(g_small, w_small, VectorPriorityQueue{Int,Float64});
d2 = test_dijkstra_no_updates(g_small, w_small, SortedVectorPriorityQueue{Int,Float64});
d3 = test_dijkstra_no_updates(g_small, w_small, HeapPriorityQueue{Int,Float64});
@test d0 ≈ d0_bis ≈ d1 ≈ d2 ≈ d3

# Now we measure execution time and memory allocations for each of the queue types.

function compare_dijkstra_versions(n_values; n_samples=5)
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
        w = random_weights(g)
        _, t0, m0, _, _ = @timed for _ in 1:n_samples
            test_dijkstra_default(g, w)
        end
        _, t0_bis, m0_bis, _, _ = @timed for _ in 1:n_samples
            test_dijkstra_updates(g, w, PriorityQueue{Int,Float64})
        end
        _, t1, m1, _, _ = @timed for _ in 1:n_samples
            test_dijkstra_no_updates(g, w, VectorPriorityQueue{Int,Float64})
        end
        _, t2, m2, _, _ = @timed for _ in 1:n_samples
            test_dijkstra_no_updates(g, w, SortedVectorPriorityQueue{Int,Float64})
        end
        _, t3, m3, _, _ = @timed for _ in 1:n_samples
            test_dijkstra_no_updates(g, w, HeapPriorityQueue{Int,Float64})
        end

        push!(speed_gains["PriorityQueue"], t0 / t0_bis)
        push!(speed_gains["VectorPriorityQueue"], t0 / t1)
        push!(speed_gains["SortedVectorPriorityQueue"], t0 / t2)
        push!(speed_gains["HeapPriorityQueue"], t0 / t3)

        push!(memory_gains["PriorityQueue"], m0 / m0_bis)
        push!(memory_gains["VectorPriorityQueue"], m0 / m1)
        push!(memory_gains["SortedVectorPriorityQueue"], m0 / m2)
        push!(memory_gains["HeapPriorityQueue"], m0 / m3)
    end
    return speed_gains, memory_gains
end;

# To gain precision, we could replace the built-in `@elapsed` with `@belapsed` from [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl).

n_values = [10, 30, 100, 300, 1000]
speed_gains, memory_gains = compare_dijkstra_versions(n_values);

# Finally, let us plot the results.

settings = ["PriorityQueue", "VectorPriorityQueue", "SortedVectorPriorityQueue", "HeapPriorityQueue"]
S, N = length(settings), length(n_values);

# First we compare execution time

plt = plot(;
    title="Performance of Dijkstra depending on the queue",
    xlabel="Grid side length",
    ylabel="Speed gain wrt. Graphs.jl",
    ylim=(0, Inf),
    xticks=(1:N, string.(n_values)),
    margin=10Plots.mm,
    legend_position=:best,
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
    title="Performance of Dijkstra depending on the queue",
    xlabel="Grid side length",
    ylabel="Memory gain wrt. Graphs.jl",
    ylim=(0, Inf),
    xticks=(1:N, string.(n_values)),
    margin=10Plots.mm,
    legend_position=:bottomright,
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
