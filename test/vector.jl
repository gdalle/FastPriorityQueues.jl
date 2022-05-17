using FastPriorityQueues
using Test

q = VectorPriorityQueue{String,Int}()

enqueue!(q, "red", 4)
enqueue!(q, "blue", 7)
enqueue!(q, "green", 2)

@test length(q) == 3
@test values(q) == [2, 4, 7]
@test keys(q) == ["green", "red", "blue"]
@test haskey(q, "green")
@test !haskey(q, "yellow")

dequeue!(q)

@test length(q) == 2
@test values(q) == [4, 7]
@test keys(q) == ["red", "blue"]
