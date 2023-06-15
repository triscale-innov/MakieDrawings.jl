push!(LOAD_PATH,joinpath(@__DIR__, ".."))
using Documenter, MakieDrawings

makedocs(
    modules = [MakieDrawings],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Laurent Plagne",
    sitename = "MakieDrawings.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com//MakieDrawings.jl.git",
)
