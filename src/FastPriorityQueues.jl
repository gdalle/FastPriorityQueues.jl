module FastPriorityQueues

using DataStructures

include("vector.jl")
include("sorted_vector.jl")

export enqueue!, dequeue!
export VectorPriorityQueue
export SortedVectorPriorityQueue

end
