"""
    SortedVectorPriorityQueue{K,V}

Min priority queue with keys of type `K` and priority values of type `V`, stored using a sorted vector of couples.

# Fields
- `pairs::Vector{Pair{K,V}}`: vector of key-value pairs `k => v` ordered by increasing `v`.
"""
struct SortedVectorPriorityQueue{K,V}
    pairs::Vector{Pair{K,V}}
end

SortedVectorPriorityQueue{K,V}() where {K,V} = SortedVectorPriorityQueue{K,V}(Pair{K,V}[])

## Vector behavior

Base.length(pq::SortedVectorPriorityQueue) = length(pq.pairs)
Base.isempty(pq::SortedVectorPriorityQueue) = isempty(pq.pairs)
Base.first(pq::SortedVectorPriorityQueue) = first(pq.pairs)
Base.peek(pq::SortedVectorPriorityQueue) = first(pq)

## Queue behavior

"""
    enqueue!(pq::SortedVectorPriorityQueue, k, v)

Insert `k => v` into the queue `pq`.
Amortized complexity `O(log n)`.
"""
function DataStructures.enqueue!(pq::SortedVectorPriorityQueue{K,V}, k::K, v::V) where {K,V}
    i = searchsortedfirst(pq.pairs, v; by=last)
    insert!(pq.pairs, i, k => v)
    return nothing
end

"""
    dequeue!(pq::SortedVectorPriorityQueue)

Remove and return the key `k` with lowest priority value `v`.
Amortized complexity `O(1)`.
"""
function DataStructures.dequeue!(pq::SortedVectorPriorityQueue)
    k, _ = popfirst!(pq.pairs)
    return k
end

"""
    dequeue_pair!(pq::SortedVectorPriorityQueue)

Remove and return the pair `k => v` with lowest priority value `v`.
Amortized complexity `O(1)`.
"""
function DataStructures.dequeue_pair!(pq::SortedVectorPriorityQueue)
    return popfirst!(pq.pairs)
end
