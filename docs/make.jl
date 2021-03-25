using Balloons
using Documenter

DocMeta.setdocmeta!(Balloons, :DocTestSetup, :(using Balloons); recursive=true)

makedocs(;
    modules=[Balloons],
    authors="Tamas Nagy",
    repo="https://github.com/tlnagy/Balloons.jl/blob/{commit}{path}#{line}",
    sitename="Balloons.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://tlnagy.github.io/Balloons.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/tlnagy/Balloons.jl",
)
