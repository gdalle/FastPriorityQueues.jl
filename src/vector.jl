"""
    VectorPriorityQueue{K,V}

Min priority queue with keys of type `K` and priority values of type `V`, stored as a vector of couples.

# Fields
- `pairs::Vector{Pair{K,V}}`: vector of key-value pairs `k => v` in arbitrary order.
"""
struct VectorPriorityQueue{K,V}
    pairs::Vector{Pair{K,V}}
end

VectorPriorityQueue{K,V}() where {K,V} = VectorPriorityQueue{K,V}(Pair{K,V}[])

## Vector behavior

Base.length(pq::VectorPriorityQueue) = length(pq.pairs)
Base.isempty(pq::VectorPriorityQueue) = isempty(pq.pairs)

function Base.first(pq::VectorPriorityQueue)
    _, i = findmin(last, pq.pairs)
    return pq.pairs[i]
end

Base.peek(pq::VectorPriorityQueue) = first(pq)

## Queue behavior

"""
    enqueue!(pq::VectorPriorityQueue, k, v)

Insert `k => v` into the queue `pq`.
Amortized complexity `O(1)`.
"""
function DataStructures.enqueue!(pq::VectorPriorityQueue{K,V}, k::K, v::V) where {K,V}
    push!(pq.pairs, k => v)
    return nothing
end

"""
    dequeue!(pq::VectorPriorityQueue)

Remove and return the key `k` with lowest priority value `v`.
Amortized complexity `O(n)`.
"""
function DataStructures.dequeue!(pq::VectorPriorityQueue)
    _, i = findmin(last, pq.pairs)
    k, _ = pq.pairs[i]
    deleteat!(pq.pairs, i)
    return k
end

"""
    dequeue_pair!(pq::VectorPriorityQueue)

Remove and return the pair `k => v` with lowest priority value `v`.
Amortized complexity `O(n)`.
"""
function DataStructures.dequeue_pair!(pq::VectorPriorityQueue)
    _, i = findmin(last, pq.pairs)
    k, v = pq.pairs[i]
    deleteat!(pq.pairs, i)
    return k => v
end
