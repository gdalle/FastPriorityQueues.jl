"""
    VectorPriorityQueue{K,V}

Priority queue stored with keys of type `K` and priority values of type `V`, stored as a couple of vectors.

# Fields
- `keys::Vector{K}`: item keys, sorted according to their priority values
- `values::Vector{V}`: priority values, sorted by increasing order
"""
struct VectorPriorityQueue{K,V}
    keys::Vector{K}
    values::Vector{V}
end

VectorPriorityQueue{K,V}() where {K,V} = VectorPriorityQueue{K,V}(K[], V[])

Base.keys(pq::VectorPriorityQueue) = pq.keys
Base.values(pq::VectorPriorityQueue) = pq.values
Base.pairs(pq::VectorPriorityQueue) = (k => v for (k, v) in zip(keys(pq), values(pq)))

## Vector behavior

Base.length(pq::VectorPriorityQueue) = length(keys(pq))
Base.isempty(pq::VectorPriorityQueue) = isempty(keys(pq))
Base.first(pq::VectorPriorityQueue) = first(keys(pq)) => first(values(pq))

## Queue behavior

function DataStructures.enqueue!(pq::VectorPriorityQueue{K,V}, k::K, v::V) where {K,V}
    j = searchsortedfirst(pq.values, v)
    insert!(pq.keys, j, k)
    insert!(pq.values, j, v)
    return nothing
end

function DataStructures.dequeue!(pq::VectorPriorityQueue)
    k = popfirst!(pq.keys)
    popfirst!(pq.values)
    return k
end
