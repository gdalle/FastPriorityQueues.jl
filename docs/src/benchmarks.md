```@meta
EditURL = "<unknown>/test/benchmarks.jl"
```

# Benchmarks

````@example benchmarks
using DataStructures
using FastPriorityQueues
using Graphs
using Plots
using Test
````

## Setup

An interesting way to benchmark priority queues is to use them inside [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm), for which they play a key role in performance.

According to [this technical report](https://www3.cs.stonybrook.edu/~rezaul/papers/TR-07-54.pdf), there are two main implementations:
1. one that updates the priority values of vertices inside the queue
2. one that reinserts them with new priority values, potentially creating duplicates

[Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) uses the first version with a `DataStructures.PriorityQueue`, so here we code the second one.

````@example benchmarks
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
nothing #hide
````

Our custom queue types do not support priority updates, but on the other hand they have fast enqueueing and dequeueing routines, which makes them well-suited for `dijkstra_no_priority_updates!`.

## Results

Our goal is to see in which cases we can be faster than Graphs.jl.

````@example benchmarks
test_dijkstra(g, qtype) = dijkstra_no_priority_updates!(qtype(), g, 1)[end];
test_dijkstra_default(g) = Graphs.dijkstra_shortest_paths(g, 1).dists[end];
nothing #hide
````

Let us first verify that the outputs of both implementations are coherent.

````@example benchmarks
g_small = Graphs.grid([10, 10])
````

````@example benchmarks
d1 = test_dijkstra_default(g_small);
d2 = test_dijkstra(g_small, PriorityQueue{Int,Float64});
d3 = test_dijkstra(g_small, VectorPriorityQueue{Int,Float64});
d4 = test_dijkstra(g_small, SortedVectorPriorityQueue{Int,Float64});
d5 = test_dijkstra(g_small, HeapPriorityQueue{Int,Float64});
@test d1 ≈ d2 ≈ d3 ≈ d4 ≈ d5
````

Now we measure execution time and memory allocations for each of the queue types.

````@example benchmarks
function compare_dijkstra_versions(n_values)
    speedups = Dict(
        "PriorityQueue" => Float64[],
        "VectorPriorityQueue" => Float64[],
        "SortedVectorPriorityQueue" => Float64[],
        "HeapPriorityQueue" => Float64[],
    )
    for n in n_values
        @info "Testing grids of side length $n"
        g = Graphs.grid([n, n])
        t0 = @elapsed for _ in 1:5
            test_dijkstra_default(g)
        end
        t1 = @elapsed for _ in 1:5
            test_dijkstra(g, PriorityQueue{Int,Float64})
        end
        t2 = @elapsed for _ in 1:5
            test_dijkstra(g, VectorPriorityQueue{Int,Float64})
        end
        t3 = @elapsed for _ in 1:5
            test_dijkstra(g, SortedVectorPriorityQueue{Int,Float64})
        end
        t4 = @elapsed for _ in 1:5
            test_dijkstra(g, HeapPriorityQueue{Int,Float64})
        end
        push!(speedups["PriorityQueue"], t0 / t1)
        push!(speedups["VectorPriorityQueue"], t0 / t2)
        push!(speedups["SortedVectorPriorityQueue"], t0 / t3)
        push!(speedups["HeapPriorityQueue"], t0 / t4)
    end
    return speedups
end
````

To gain precision, we could replace the built-in `@elapsed` with `@belapsed` from [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl).

````@example benchmarks
n_values = [10, 100, 1000]
speedups = compare_dijkstra_versions(n_values)
````

Now let us plot the results.

````@example benchmarks
settings = [
    "HeapPriorityQueue", "SortedVectorPriorityQueue", "VectorPriorityQueue", "PriorityQueue"
]
plt = plot(;
    title="Dijkstra with no priority updates",
    xlabel="Grid side length",
    ylabel="Speedup wrt. Graphs.jl",
    ylim=(0, Inf),
    xticks=(1:length(n_values), string.(n_values)),
    margin=5Plots.mm,
)
for (k, setting) in enumerate(settings)
    bar!(
        plt,
        (1:length(n_values)) .+ 0.7 * (k - (length(settings) + 1) / 2) / length(settings),
        speedups[setting];
        label=setting,
        bar_width=0.7 / length(settings),
    )
end
plt
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

