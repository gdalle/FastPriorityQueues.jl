"""
    HeapPriorityQueue{K,V}

Min priority queue with keys of type `K` and priority values of type `V`, stored using a binary heap from DataStructures.jl.

# Fields
- `heap::BinaryHeap{K,V}`: heap of key-value pairs `k => v` ordered by increasing `v`
"""
struct HeapPriorityQueue{K,V}
    pairs::BinaryHeap{Pair{K,V},Base.Order.By{typeof(last),Base.Order.ForwardOrdering}}
end

function HeapPriorityQueue{K,V}() where {K,V}
    pairs = BinaryHeap(Base.By(last), Pair{K,V}[])
    return HeapPriorityQueue{K,V}(pairs)
end

## Vector behavior

Base.length(pq::HeapPriorityQueue) = length(pq.pairs)
Base.isempty(pq::HeapPriorityQueue) = isempty(pq.pairs)
Base.first(pq::HeapPriorityQueue) = first(pq.pairs)
Base.peek(pq::HeapPriorityQueue) = first(pq)


## Queue behavior

"""
    enqueue!(pq::HeapPriorityQueue, k, v)

Insert `k => v` into the queue `pq`.
Amortized complexity `O(log n)`.
"""
function DataStructures.enqueue!(pq::HeapPriorityQueue{K,V}, k::K, v::V) where {K,V}
    push!(pq.pairs, k => v)
    return nothing
end

"""
    dequeue!(pq::HeapPriorityQueue)

Remove and return the key `k` with lowest priority value `v`.
Amortized complexity `O(1)`.
"""
function DataStructures.dequeue!(pq::HeapPriorityQueue)
    k, _ = pop!(pq.pairs)
    return k
end

"""
    dequeue_pair!(pq::HeapPriorityQueue)

Remove and return the pair `k => v` with lowest priority value `v`.
Amortized complexity `O(1)`.
"""
function DataStructures.dequeue_pair!(pq::HeapPriorityQueue)
    return pop!(pq.pairs)
end
