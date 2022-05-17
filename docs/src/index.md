```@meta
CurrentModule = FastPriorityQueues
```

# FastPriorityQueues.jl

Welcome to the documentation for [FastPriorityQueues.jl](https://github.com/gdalle/FastPriorityQueues.jl).

## Why this package?

The standard [`PriorityQueue`](https://juliacollections.github.io/DataStructures.jl/latest/priority-queue/) provided by [DataStructures.jl](https://github.com/JuliaCollections/DataStructures.jl) relies on a dictionary, which can be inefficient in some cases.

There have been a number of Discourse topics on this issue ([2020/07](https://discourse.julialang.org/t/priority-queue-choice/42783), [2021/01](https://discourse.julialang.org/t/faster-updates-in-a-priority-queue/53346), [2021/09](https://discourse.julialang.org/t/fastest-data-structure-for-a-priority-queue/68472/16)), but sofar it looks like alternative implementations are scattered through specific packages.

The goal of the present package is to make some of these alternatives available under a name that is easily discoverable.
