```@meta
EditURL = "<unknown>/test/benchmarks.jl"
```

# Benchmarks

````@example benchmarks
using BenchmarkTools
using DataStructures
using FastPriorityQueues
using Graphs
using Test
````

## Setup

An interesting way to benchmark priority queues is to use them inside [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm), for which they play a key role in performance.

According to [this technical report](https://www3.cs.stonybrook.edu/~rezaul/papers/TR-07-54.pdf), there are two possible implementations:
- one that updates the priority values of vertices inside the queue
- one that reinserts them with new priority values, potentially creating duplicates

We reproduce both of them below.

````@example benchmarks
function dijkstra_priority_updates!(
    q::Q, g::AbstractGraph{T}, s::Integer, w=weights(g)
) where {Q,T}
    d = fill(Inf, nv(g))
    d[s] = 0.
    enqueue!(q, s, 0.)
    while !isempty(q)
        u, k = first(q)
        dequeue!(q)
        d[u] = k
        for v in outneighbors(g, u)
            if d[u] + w[u, v] < d[v]
                d[v] = d[u] + w[u, v]
                d[v] == Inf ? enqueue!(q, v, d[v]) : q[v] = d[v]
            end
        end
    end
    return d
end
````

````@example benchmarks
function dijkstra_no_priority_updates!(
    q::Q, g::AbstractGraph{T}, s::Integer, w=weights(g)
) where {Q,T}
    d = fill(Inf, nv(g))
    d[s] = 0.
    enqueue!(q, s, 0.)
    while !isempty(q)
        u, k = first(q)
        dequeue!(q)
        if k <= d[u]
            d[u] = k
            for v in outneighbors(g, u)
                if d[u] + w[u, v] < d[v]
                    d[v] = d[u] + w[u, v]
                    enqueue!(q, v, d[v])
                end
            end
        end
    end
    return d
end
````

Our types [`VectorPriorityQueue`](@ref) and [`SortedVectorPriorityQueue`](@ref) do not support priority updates, but on the other hand they have fast enqueueing and dequeueing routines.
We hope it will be sufficient to outperform `DataStructures.PriorityQueue` on the following test example.

````@example benchmarks
function test_dijkstra(n, qtype; priority_updates)
    g = Graphs.grid([n, n])
    q = qtype()
    if priority_updates
        return dijkstra_priority_updates!(q, g, 1)
    else
        return dijkstra_no_priority_updates!(q, g, 1)
    end
end;
nothing #hide
````

## Results

Let us first verify that the outputs are coherent with one another.

````@example benchmarks
d1 = test_dijkstra(10, PriorityQueue{Int,Float64}; priority_updates=true)[end];
d2 = test_dijkstra(10, PriorityQueue{Int,Float64}; priority_updates=false)[end];
d3 = test_dijkstra(10, VectorPriorityQueue{Int,Float64}; priority_updates=false)[end];
d4 = test_dijkstra(10, SortedVectorPriorityQueue{Int,Float64}; priority_updates=false)[end];
@test d1 ≈ d2 ≈ d3 ≈ d4
````

Now we measure execution time and memory allocations for each of the variants.

````@example benchmarks
@benchmark test_dijkstra(100, PriorityQueue{Int,Float64}; priority_updates=true)
````

````@example benchmarks
@benchmark test_dijkstra(100, PriorityQueue{Int,Float64}; priority_updates=false)
````

Disabling priority updates does not change the performance when using the standard queue, because insertion is almost as costly as updating. However, the story is very different with our custom queues.

````@example benchmarks
@benchmark test_dijkstra(100, VectorPriorityQueue{Int,Float64}; priority_updates=false)
````

````@example benchmarks
@benchmark test_dijkstra(100, SortedVectorPriorityQueue{Int,Float64}; priority_updates=false)
````

!!! warning "TODO"
    Benchmark other containers from DataStructures.jl (heaps and dicts).

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

