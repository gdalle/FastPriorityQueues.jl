using DataStructures
using FastPriorityQueues
using Test

function test_compare(q1, q2)
    @test length(q1) == length(q2)
    @test first(q1) == first(q2)
end

all_queues = (
    VectorPriorityQueue{String,Int}(),
    SortedVectorPriorityQueue{String,Int}(),
    HeapPriorityQueue{String,Int}()
)

for q_test in all_queues
    testname = string(typeof(q_test))
    @testset verbose = true "$testname" begin
        q_ref = PriorityQueue{String,Int}()
        for q in (q_test, q_ref)
            enqueue!(q, "red", 4)
            enqueue!(q, "blue", 7)
            enqueue!(q, "green", 2)
        end
        test_compare(q_test, q_ref)
        @test dequeue_pair!(q_test) == dequeue_pair!(q_ref)
        test_compare(q_test, q_ref)
    end
end
