using DataStructures
using FastPriorityQueues
using Test

function test_compare(q1, q2)
    @test length(q1) == length(q2)
    @test first(q1) == first(q2)
    @test peek(q1) == peek(q2)
    @test collect(keys(q1)) == collect(keys(q2))
    @test collect(values(q1)) == collect(values(q2))
    @test collect(pairs(q1)) == collect(pairs(q2))
    for k in union(keys(q1), keys(q2))
        @test haskey(q1, k) == haskey(q2, k)
        @test q1[k] == q2[k]
    end
end

q1 = VectorPriorityQueue{String,Int}()
q2 = PriorityQueue{String,Int}()

for q in (q1, q2)
    enqueue!(q, "red", 4)
    enqueue!(q, "blue", 7)
    enqueue!(q, "green", 2)
end

test_compare(q1, q2)

for q in (q1, q2)
    q["blue"] = 1
    q["orange"] = 8
end

test_compare(q1, q2)

for q in (q1, q2)
    dequeue!(q)
    dequeue!(q)
end

test_compare(q1, q2)
