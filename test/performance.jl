using BenchmarkTools
using DataStructures
using FastPriorityQueues
using GridGraphs
using Test

w = rand(200, 200);

function dijkstra_priorityqueue(w)
    g = AcyclicGridGraph(w)
    q = PriorityQueue{Int,Float64}()
    return GridGraphs.grid_dijkstra!(q, g, 1)
end

function dijkstra_vectorpriorityqueue(w)
    g = AcyclicGridGraph(w)
    q = VectorPriorityQueue{Int,Float64}()
    return GridGraphs.grid_dijkstra!(q, g, 1)
end

@test dijkstra_priorityqueue(w).dists[length(w)] ==
    dijkstra_vectorpriorityqueue(w).dists[length(w)];

@btime dijkstra_priorityqueue($w);
@btime dijkstra_vectorpriorityqueue($w);

@profview dijkstra_vectorpriorityqueue(w)
