module FastPriorityQueues

using DataStructures

include("vector.jl")
include("sorted_vector.jl")
include("heap.jl")

export enqueue!, dequeue!, dequeue_pair!
export VectorPriorityQueue
export SortedVectorPriorityQueue
export HeapPriorityQueue

end
