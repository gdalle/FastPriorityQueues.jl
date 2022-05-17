```@meta
CurrentModule = FastPriorityQueues
```

# FastPriorityQueues.jl

Welcome to the documentation for [FastPriorityQueues.jl](https://github.com/gdalle/FastPriorityQueues.jl), which contains possibly faster alternatives to the priority queue from [DataStructures.jl](https://github.com/JuliaCollections/DataStructures.jl)

## Why this package?

The [`PriorityQueue`](https://juliacollections.github.io/DataStructures.jl/latest/priority-queue/) provided by DataStructures.jl relies on a dictionary, which can be inefficient for small queues.
There have been a number of Discourse topics on this issue ([2020/07](https://discourse.julialang.org/t/priority-queue-choice/42783), [2021/01](https://discourse.julialang.org/t/faster-updates-in-a-priority-queue/53346), [2021/09](https://discourse.julialang.org/t/fastest-data-structure-for-a-priority-queue/68472/16)), but sofar it looks like alternative implementations are scattered through specific packages.
The goal of FastPriorityQueues.jl is to make my own version available under an easily discoverable name.

## Benchmarks

As of right now, my `VectorPriorityQueue` is not as efficient as `PriorityQueue`. Work in progress...