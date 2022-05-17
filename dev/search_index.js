var documenterSearchIndex = {"docs":
[{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"EditURL = \"https://github.com/gdalle/FastPriorityQueues.jl/blob/main/test/benchmarks.jl\"","category":"page"},{"location":"benchmarks/#Benchmarks","page":"Benchmarks","title":"Benchmarks","text":"","category":"section"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"using BenchmarkTools\nusing DataStructures\nusing FastPriorityQueues\nusing GridGraphs\nusing Random\nusing Test","category":"page"},{"location":"benchmarks/#Setup","page":"Benchmarks","title":"Setup","text":"","category":"section"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"An interesting way to benchmark priority queues is to use them inside Dijkstra's algorithm, where they play a key role in performance. According to this technical report, sizeable speedups can be achieved by inserting vertices several times into the queue instead of looking them up to update their priority values.","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"The internal grid_dijkstra!(queue, g, s; naive) function from GridGraphs.jl has two useful features for our test case:","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"it allows us to plug in any type of priority queue\nits keyword argument naive controls whether priority updates are enabled or not","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"function test_dijkstra(n, pqtype; naive)\n    Random.seed!(63)\n    w = rand(n, n);\n    g = GridGraph(w)\n    pq = pqtype()\n    return GridGraphs.grid_dijkstra!(pq, g, 1; naive=naive)\nend;\nnothing #hide","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"Our VectorPriorityQueue doesn't support priority updates, but it has very fast enqueueing and dequeueing routines. We hope it will be sufficient to outperform DataStructures.PriorityQueue on this example.","category":"page"},{"location":"benchmarks/#Results","page":"Benchmarks","title":"Results","text":"","category":"section"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"Let us first verify that the outputs are coherent with one another.","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"d1 = test_dijkstra(100, PriorityQueue{Int,Float64}; naive=false).dists[end];\nd2 = test_dijkstra(100, PriorityQueue{Int,Float64}; naive=true).dists[end];\nd3 = test_dijkstra(100, VectorPriorityQueue{Int,Float64}; naive=true).dists[end];\n@test d1 ≈ d2 ≈ d3","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"Now we measure execution time and memory allocations for each of the three variants.","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"@btime test_dijkstra(100, PriorityQueue{Int,Float64}; naive=false);\nnothing #hide","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"@btime test_dijkstra(100, PriorityQueue{Int,Float64}; naive=true);\nnothing #hide","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"@btime test_dijkstra(100, VectorPriorityQueue{Int,Float64}; naive=true);\nnothing #hide","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"As we can see, the VectorPriorityQueue reduced both of these measures by a significant amount.","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"","category":"page"},{"location":"benchmarks/","page":"Benchmarks","title":"Benchmarks","text":"This page was generated using Literate.jl.","category":"page"},{"location":"api/#API-reference","page":"API reference","title":"API reference","text":"","category":"section"},{"location":"api/#Index","page":"API reference","title":"Index","text":"","category":"section"},{"location":"api/","page":"API reference","title":"API reference","text":"","category":"page"},{"location":"api/#Docstrings","page":"API reference","title":"Docstrings","text":"","category":"section"},{"location":"api/","page":"API reference","title":"API reference","text":"Modules = [FastPriorityQueues]","category":"page"},{"location":"api/#FastPriorityQueues.VectorPriorityQueue","page":"API reference","title":"FastPriorityQueues.VectorPriorityQueue","text":"VectorPriorityQueue{K,V}\n\nPriority queue stored with keys of type K and priority values of type V, stored as a couple of vectors.\n\nFields\n\nkeys::Vector{K}: item keys, sorted according to their priority values\nvalues::Vector{V}: priority values, sorted by increasing order\n\n\n\n\n\n","category":"type"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = FastPriorityQueues","category":"page"},{"location":"#FastPriorityQueues.jl","page":"Home","title":"FastPriorityQueues.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Welcome to the documentation for FastPriorityQueues.jl.","category":"page"},{"location":"#Why-this-package?","page":"Home","title":"Why this package?","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The standard PriorityQueue provided by DataStructures.jl relies on a dictionary, which can be inefficient in some cases.","category":"page"},{"location":"","page":"Home","title":"Home","text":"There have been a number of Discourse topics on this issue (2020/07, 2021/01, 2021/09), but sofar it looks like alternative implementations are scattered through specific packages.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The goal of the present package is to make some of these alternatives available under a name that is easily discoverable.","category":"page"}]
}
