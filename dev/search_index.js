var documenterSearchIndex = {"docs":
[{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"EditURL = \"https://github.com/gdalle/FastPriorityQueues.jl/blob/main/test/benchmarks.jl\"","category":"page"},{"location":"benchmarks/#Benchmarks","page":"Benchmarks","title":"Benchmarks","text":"","category":"section"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"using DataStructures\nusing FastPriorityQueues\nusing Graphs\nusing LinearAlgebra\nusing Plots\nusing SparseArrays\nusing Test","category":"page"},{"location":"benchmarks/#Setup","page":"Benchmarks","title":"Setup","text":"","category":"section"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"An interesting way to benchmark priority queues is to use them inside Dijkstra's algorithm, for which they play a key role in performance.","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"According to this technical report, there are two main implementations:","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"one that updates the priority values of vertices inside the queue\none that reinserts them with new priority values, potentially creating duplicates","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"function dijkstra_updates!(\n    q::Q, g::AbstractGraph{T}, s::Integer, w=weights(g)\n) where {Q,T}\n    d = fill(Inf, nv(g))\n    q[s] = 0.\n    d[s] = 0.\n    while !isempty(q)\n        u, d_u = dequeue_pair!(q)\n        d[u] = d_u\n        for v in outneighbors(g, u)\n            d_v = d[u] + w[u, v]\n            if d_v < d[v]\n                q[v] = d_v\n                d[v] = d_v\n            end\n        end\n    end\n    return d\nend;\nnothing #hide","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"function dijkstra_no_updates!(\n    q::Q, g::AbstractGraph{T}, s::Integer, w=weights(g)\n) where {Q,T}\n    d = fill(Inf, nv(g))\n    enqueue!(q, s, 0.0)\n    d[s] = 0.0\n    while !isempty(q)\n        u, d_u = dequeue_pair!(q)\n        if d_u <= d[u]\n            d[u] = d_u\n            for v in outneighbors(g, u)\n                d_v = d[u] + w[u, v]\n                if d_v < d[v]\n                    enqueue!(q, v, d_v)\n                    d[v] = d_v\n                end\n            end\n        end\n    end\n    return d\nend;\nnothing #hide","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"Note that Graphs.jl uses option 1 with a DataStructures.PriorityQueue (which does not accept duplicate keys) for its Dijkstra implementation. Thus, it basically boils down to dijkstra_updates!. Meanwhile, our custom queue types do not support priority updates, but they have fast enqueueing and dequeueing routines. Therefore, we can hope to get the best out of them with dijkstra_no_updates!.","category":"page"},{"location":"benchmarks/#Results","page":"Benchmarks","title":"Results","text":"","category":"section"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"Our goal is to see in which cases we can be faster than Graphs.jl.","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"function random_weights(g)\n    srcs = src.(edges(g))\n    dsts = dst.(edges(g))\n    w = sparse(srcs, dsts, rand(ne(g)), ne(g), ne(g))\n    return Symmetric((w + w') / 2)\nend;\nnothing #hide","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"test_dijkstra_no_updates(g, w, qtype) = dijkstra_no_updates!(qtype(), g, 1, w)[end];\ntest_dijkstra_updates(g, w, qtype) = dijkstra_updates!(qtype(), g, 1, w)[end];\ntest_dijkstra_default(g, w) = Graphs.dijkstra_shortest_paths(g, 1, w).dists[end];\nnothing #hide","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"Let us first verify that the outputs of both implementations are coherent.","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"g_small = Graphs.grid([10, 10])\nw_small = random_weights(g_small);\nnothing #hide","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"d0 = test_dijkstra_default(g_small, w_small);\nd0_bis = test_dijkstra_updates(g_small, w_small, PriorityQueue{Int,Float64});\nd1 = test_dijkstra_no_updates(g_small, w_small, VectorPriorityQueue{Int,Float64});\nd2 = test_dijkstra_no_updates(g_small, w_small, SortedVectorPriorityQueue{Int,Float64});\nd3 = test_dijkstra_no_updates(g_small, w_small, HeapPriorityQueue{Int,Float64});\n@test d0 ≈ d0_bis ≈ d1 ≈ d2 ≈ d3","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"Now we measure execution time and memory allocations for each of the queue types.","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"function compare_dijkstra_versions(n_values; n_samples=3)\n    speed_gains = Dict(\n        \"PriorityQueue\" => Float64[],\n        \"VectorPriorityQueue\" => Float64[],\n        \"SortedVectorPriorityQueue\" => Float64[],\n        \"HeapPriorityQueue\" => Float64[],\n    )\n    memory_gains = Dict(\n        \"PriorityQueue\" => Float64[],\n        \"VectorPriorityQueue\" => Float64[],\n        \"SortedVectorPriorityQueue\" => Float64[],\n        \"HeapPriorityQueue\" => Float64[],\n    )\n    for n in n_values\n        @info \"Testing grids of side length $n\"\n        g = Graphs.grid([n, n])\n        w = random_weights(g)\n        _, t0, m0, _, _ = @timed for _ in 1:n_samples\n            test_dijkstra_default(g, w)\n        end\n        _, t0_bis, m0_bis, _, _ = @timed for _ in 1:n_samples\n            test_dijkstra_updates(g, w, PriorityQueue{Int,Float64})\n        end\n        _, t1, m1, _, _ = @timed for _ in 1:n_samples\n            test_dijkstra_no_updates(g, w, VectorPriorityQueue{Int,Float64})\n        end\n        _, t2, m2, _, _ = @timed for _ in 1:n_samples\n            test_dijkstra_no_updates(g, w, SortedVectorPriorityQueue{Int,Float64})\n        end\n        _, t3, m3, _, _ = @timed for _ in 1:n_samples\n            test_dijkstra_no_updates(g, w, HeapPriorityQueue{Int,Float64})\n        end\n\n        push!(speed_gains[\"PriorityQueue\"], t0 / t0_bis)\n        push!(speed_gains[\"VectorPriorityQueue\"], t0 / t1)\n        push!(speed_gains[\"SortedVectorPriorityQueue\"], t0 / t2)\n        push!(speed_gains[\"HeapPriorityQueue\"], t0 / t3)\n\n        push!(memory_gains[\"PriorityQueue\"], m0 / m0_bis)\n        push!(memory_gains[\"VectorPriorityQueue\"], m0 / m1)\n        push!(memory_gains[\"SortedVectorPriorityQueue\"], m0 / m2)\n        push!(memory_gains[\"HeapPriorityQueue\"], m0 / m3)\n    end\n    return speed_gains, memory_gains\nend;\nnothing #hide","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"To gain precision, we could replace the built-in @elapsed with @belapsed from BenchmarkTools.jl.","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"n_values = [10, 30, 100, 300, 1000]\nspeed_gains, memory_gains = compare_dijkstra_versions(n_values)","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"Finally, let us plot the results.","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"settings = [\"PriorityQueue\", \"VectorPriorityQueue\", \"SortedVectorPriorityQueue\", \"HeapPriorityQueue\"]\nS, N = length(settings), length(n_values);\nnothing #hide","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"First we compare execution time","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"plt = plot(;\n    title=\"Performance of Dijkstra without priority updates\",\n    xlabel=\"Grid side length\",\n    ylabel=\"Speed gain wrt. Graphs.jl\",\n    ylim=(0, Inf),\n    xticks=(1:N, string.(n_values)),\n    margin=10Plots.mm,\n    legend_position=:topright,\n)\nfor (k, setting) in enumerate(settings)\n    bar!(\n        plt,\n        (1:N) .+ 0.7 * (k - (S + 1) / 2) / S,\n        speed_gains[setting];\n        label=setting,\n        bar_width=0.7 / S,\n    )\nend\nplt","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"And we follow up with memory use","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"plt = plot(;\n    title=\"Performance of Dijkstra without priority updates\",\n    xlabel=\"Grid side length\",\n    ylabel=\"Memory gain wrt. Graphs.jl\",\n    ylim=(0, Inf),\n    xticks=(1:N, string.(n_values)),\n    margin=10Plots.mm,\n    legend_position=:bottomright,\n)\nfor (k, setting) in enumerate(settings)\n    bar!(\n        plt,\n        (1:N) .+ 0.7 * (k - (S + 1) / 2) / S,\n        memory_gains[setting];\n        label=setting,\n        bar_width=0.7 / S,\n    )\nend\nplt","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"This page was generated using Literate.jl.","category":"page"},{"location":"api/#API-reference","page":"API reference","title":"API reference","text":"","category":"section"},{"location":"api/#Index","page":"API reference","title":"Index","text":"","category":"section"},{"location":"api/","page":"API reference","title":"API reference","text":"","category":"page"},{"location":"api/#Docstrings","page":"API reference","title":"Docstrings","text":"","category":"section"},{"location":"api/","page":"API reference","title":"API reference","text":"Modules = [FastPriorityQueues]","category":"page"},{"location":"api/#FastPriorityQueues.HeapPriorityQueue","page":"API reference","title":"FastPriorityQueues.HeapPriorityQueue","text":"HeapPriorityQueue{K,V}\n\nMin priority queue with keys of type K and priority values of type V, stored using a binary heap from DataStructures.jl.\n\nFields\n\nheap::BinaryHeap{K,V}: heap of key-value pairs k => v ordered by increasing v\n\n\n\n\n\n","category":"type"},{"location":"api/#FastPriorityQueues.SortedVectorPriorityQueue","page":"API reference","title":"FastPriorityQueues.SortedVectorPriorityQueue","text":"SortedVectorPriorityQueue{K,V}\n\nMin priority queue with keys of type K and priority values of type V, stored using a sorted vector of couples.\n\nFields\n\npairs::Vector{Pair{K,V}}: vector of key-value pairs k => v ordered by increasing v.\n\n\n\n\n\n","category":"type"},{"location":"api/#FastPriorityQueues.VectorPriorityQueue","page":"API reference","title":"FastPriorityQueues.VectorPriorityQueue","text":"VectorPriorityQueue{K,V}\n\nMin priority queue with keys of type K and priority values of type V, stored as a vector of couples.\n\nFields\n\npairs::Vector{Pair{K,V}}: vector of key-value pairs k => v in arbitrary order.\n\n\n\n\n\n","category":"type"},{"location":"api/#DataStructures.dequeue!-Tuple{HeapPriorityQueue}","page":"API reference","title":"DataStructures.dequeue!","text":"dequeue!(pq::HeapPriorityQueue)\n\nRemove and return the key k with lowest priority value v. Amortized complexity O(1).\n\n\n\n\n\n","category":"method"},{"location":"api/#DataStructures.dequeue!-Tuple{SortedVectorPriorityQueue}","page":"API reference","title":"DataStructures.dequeue!","text":"dequeue!(pq::SortedVectorPriorityQueue)\n\nRemove and return the key k with lowest priority value v. Amortized complexity O(1).\n\n\n\n\n\n","category":"method"},{"location":"api/#DataStructures.dequeue!-Tuple{VectorPriorityQueue}","page":"API reference","title":"DataStructures.dequeue!","text":"dequeue!(pq::VectorPriorityQueue)\n\nRemove and return the key k with lowest priority value v. Amortized complexity O(n).\n\n\n\n\n\n","category":"method"},{"location":"api/#DataStructures.dequeue_pair!-Tuple{HeapPriorityQueue}","page":"API reference","title":"DataStructures.dequeue_pair!","text":"dequeue_pair!(pq::HeapPriorityQueue)\n\nRemove and return the pair k => v with lowest priority value v. Amortized complexity O(1).\n\n\n\n\n\n","category":"method"},{"location":"api/#DataStructures.dequeue_pair!-Tuple{SortedVectorPriorityQueue}","page":"API reference","title":"DataStructures.dequeue_pair!","text":"dequeue_pair!(pq::SortedVectorPriorityQueue)\n\nRemove and return the pair k => v with lowest priority value v. Amortized complexity O(1).\n\n\n\n\n\n","category":"method"},{"location":"api/#DataStructures.dequeue_pair!-Tuple{VectorPriorityQueue}","page":"API reference","title":"DataStructures.dequeue_pair!","text":"dequeue_pair!(pq::VectorPriorityQueue)\n\nRemove and return the pair k => v with lowest priority value v. Amortized complexity O(n).\n\n\n\n\n\n","category":"method"},{"location":"api/#DataStructures.enqueue!-Union{Tuple{V}, Tuple{K}, Tuple{HeapPriorityQueue{K, V}, K, V}} where {K, V}","page":"API reference","title":"DataStructures.enqueue!","text":"enqueue!(pq::HeapPriorityQueue, k, v)\n\nInsert k => v into the queue pq. Amortized complexity O(log n).\n\n\n\n\n\n","category":"method"},{"location":"api/#DataStructures.enqueue!-Union{Tuple{V}, Tuple{K}, Tuple{SortedVectorPriorityQueue{K, V}, K, V}} where {K, V}","page":"API reference","title":"DataStructures.enqueue!","text":"enqueue!(pq::SortedVectorPriorityQueue, k, v)\n\nInsert k => v into the queue pq. Amortized complexity O(log n).\n\n\n\n\n\n","category":"method"},{"location":"api/#DataStructures.enqueue!-Union{Tuple{V}, Tuple{K}, Tuple{VectorPriorityQueue{K, V}, K, V}} where {K, V}","page":"API reference","title":"DataStructures.enqueue!","text":"enqueue!(pq::VectorPriorityQueue, k, v)\n\nInsert k => v into the queue pq. Amortized complexity O(1).\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = FastPriorityQueues","category":"page"},{"location":"#FastPriorityQueues.jl","page":"Home","title":"FastPriorityQueues.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Welcome to the documentation for FastPriorityQueues.jl.","category":"page"},{"location":"#Why-this-package?","page":"Home","title":"Why this package?","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The standard PriorityQueue provided by DataStructures.jl relies on a dictionary, which can be inefficient in some cases.","category":"page"},{"location":"","page":"Home","title":"Home","text":"There have been a number of Discourse topics on this issue (2020/07, 2021/01, 2021/09), but sofar it looks like alternative implementations are scattered through specific packages.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The goal of the present package is to make some of these alternatives available under a name that is easily discoverable.","category":"page"}]
}
