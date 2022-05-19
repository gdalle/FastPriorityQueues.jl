"""
    VectorPriorityQueue{K,V}

Priority queue with keys of type `K` and priority values of type `V`, stored as a vector of couples.

# Fields
- `data::Vector{Pair{K,V}}`: vector of key-value pairs `k => v` sorted by increasing arrival time.
"""
struct VectorPriorityQueue{K,V}
    data::Vector{Pair{K,V}}
end

VectorPriorityQueue{K,V}() where {K,V} = VectorPriorityQueue{K,V}(Pair{K,V}[])

function Base.keys(pq::VectorPriorityQueue)
    p = sortperm(pq.data; by=last)
    return map(first, pq.data)[p]
end

function Base.values(pq::VectorPriorityQueue)
    p = sortperm(pq.data; by=last)
    return map(last, pq.data)[p]
end

function Base.pairs(pq::VectorPriorityQueue)
    return sort(pq.data; by=last)
end

## Vector behavior

Base.length(pq::VectorPriorityQueue) = length(pq.data)
Base.isempty(pq::VectorPriorityQueue) = isempty(pq.data)

function Base.first(pq::VectorPriorityQueue)
    _, i = findmin(last, pq.data)
    return pq.data[i]
end

## Queue behavior

"""
    enqueue!(pq::VectorPriorityQueue, k, v)

Insert `k => v` into the queue `pq`. Amortized complexity `O(1)`.
"""
function DataStructures.enqueue!(pq::VectorPriorityQueue{K,V}, k::K, v::V) where {K,V}
    push!(pq.data, k => v)
    return nothing
end

"""
    dequeue!(pq::VectorPriorityQueue)

Remove and return the key `k` with lowest priority value `v`. Amortized complexity `O(n)`.
"""
function DataStructures.dequeue!(pq::VectorPriorityQueue)
    _, i = findmin(last, pq.data)
    k, v = pq.data[i]
    deleteat!(pq.data, i)
    return k
end
