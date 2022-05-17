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
Base.peek(pq::VectorPriorityQueue) = first(keys(pq)) => first(values(pq))

function Base.deleteat!(pq::VectorPriorityQueue, args...)
    deleteat!(pq.keys, args...)
    deleteat!(pq.values, args...)
    return pq
end

function Base.empty!(pq::VectorPriorityQueue)
    empty!(pq.keys)
    empey!(pq.values)
    return pq
end

## Dict behavior

Base.haskey(pq::VectorPriorityQueue{K}, k::K) where {K} = k in keys(pq)

function Base.getindex(pq::VectorPriorityQueue{K}, k::K) where {K}
    i = findfirst(isequal(k), pq.keys)
    if isnothing(i)
        throw(KeyError(k))
    else
        return pq.values[i]
    end
end

function Base.setindex!(pq::VectorPriorityQueue{K}, v::V, k::K) where {K,V}
    delete!(pq, k)
    enqueue!(pq, k, v)
    return v
end

function Base.delete!(pq::VectorPriorityQueue{K}, k::K) where {K}
    i = findfirst(isequal(k), pq.keys)
    if !isnothing(i)
        deleteat!(pq, i)
    end
    return pq
end

## Queue behavior

function DataStructures.enqueue!(pq::VectorPriorityQueue{K,V}, k::K, v::V) where {K,V}
    if haskey(pq, k)
        throw(ArgumentError("VectorPriorityQueue keys must be unique"))
    end
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
