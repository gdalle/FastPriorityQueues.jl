"""
    SortedVectorPriorityQueue{K,V}

Priority queue with keys of type `K` and priority values of type `V`, stored as a sorted vector of couples.

# Fields
- `data::Vector{Pair{K,V}}`: vector of key-value pairs `k => v` sorted by increasing value of `v`.
"""
struct SortedVectorPriorityQueue{K,V}
    data::Vector{Pair{K,V}}
end

SortedVectorPriorityQueue{K,V}() where {K,V} = SortedVectorPriorityQueue{K,V}(Pair{K,V}[])

Base.keys(pq::SortedVectorPriorityQueue) = map(first, pq.data)
Base.values(pq::SortedVectorPriorityQueue) = map(last, pq.data)
Base.pairs(pq::SortedVectorPriorityQueue) = pq.data

## Vector behavior

Base.length(pq::SortedVectorPriorityQueue) = length(pq.data)
Base.isempty(pq::SortedVectorPriorityQueue) = isempty(pq.data)
Base.first(pq::SortedVectorPriorityQueue) = first(pq.data)

## Queue behavior

"""
    enqueue!(pq::SortedVectorPriorityQueue, k, v)

Insert `k => v` into the queue `pq`. Amortized complexity `O(log n)`.
"""
function DataStructures.enqueue!(pq::SortedVectorPriorityQueue{K,V}, k::K, v::V) where {K,V}
    i = searchsortedfirst(pq.data, v; by=last)
    insert!(pq.data, i, k => v)
    return nothing
end

"""
    dequeue!(pq::SortedVectorPriorityQueue)

Remove and return the key `k` with lowest priority value `v`. Amortized complexity `O(1)`.
"""
function DataStructures.dequeue!(pq::SortedVectorPriorityQueue)
    k, _ = popfirst!(pq.data)
    return k
end
