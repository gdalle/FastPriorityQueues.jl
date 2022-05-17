"""
    VectorPriorityQueue{K,V}

Priority queue stored with keys of type `K` and priority values of type `V`, stored as a couple of sorted vectors.

# Fields
- `keys::Vector{K}`
- `values::Vector{V}`
"""
struct VectorPriorityQueue{K,V}
    keys::Vector{K}
    values::Vector{V}
end

VectorPriorityQueue{K,V}() where {K,V} = VectorPriorityQueue{K,V}(K[], V[])

Base.keys(pq::VectorPriorityQueue) = pq.keys
Base.values(pq::VectorPriorityQueue) = pq.values

Base.length(pq::VectorPriorityQueue) = length(keys(pq))
Base.isempty(pq::VectorPriorityQueue) = isempty(keys(pq))

Base.first(pq::VectorPriorityQueue) = first(keys(pq))
Base.peek(pq::VectorPriorityQueue) = first(keys(pq))

Base.haskey(pq::VectorPriorityQueue{K}, k::K) where {K} = insorted(k, keys(pq))

Base.pairs(pq::VectorPriorityQueue) = (k => v for (k, v) in zip(keys(pq), values(pq)))

function Base.deleteat!(pq::VectorPriorityQueue, args...)
    deleteat!(pq.keys, args...)
    deleteat!(pq.values, args...)
    return nothing
end

function enqueue!(pq::VectorPriorityQueue{K,V}, k::K, v::V) where {K,V}
    j = searchsortedfirst(pq.values, v)
    insert!(pq.keys, j, k)
    insert!(pq.values, j, v)
    return nothing
end

function dequeue!(pq::VectorPriorityQueue)
    k = popfirst!(pq.keys)
    popfirst!(pq.values)
    return k
end
