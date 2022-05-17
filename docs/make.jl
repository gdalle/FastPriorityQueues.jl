using FastPriorityQueues
using Documenter
using Literate

DocMeta.setdocmeta!(
    FastPriorityQueues, :DocTestSetup, :(using FastPriorityQueues); recursive=true
)

Literate.markdown(
    joinpath(dirname(@__DIR__), "test", "benchmarks.jl"),
    joinpath(@__DIR__, "src");
    documenter=true,
    execute=false,
)

makedocs(;
    modules=[FastPriorityQueues],
    authors="Guillaume Dalle <22795598+gdalle@users.noreply.github.com> and contributors",
    repo="https://github.com/gdalle/FastPriorityQueues.jl/blob/{commit}{path}#{line}",
    sitename="FastPriorityQueues.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://gdalle.github.io/FastPriorityQueues.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md", "Benchmarks" => "benchmarks.md", "API reference" => "api.md"
    ],
)

deploydocs(; repo="github.com/gdalle/FastPriorityQueues.jl", devbranch="main")
