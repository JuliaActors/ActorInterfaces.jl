using Documenter, ActorInterfaces

makedocs(
    modules = [ActorInterfaces],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Schäffer Krisztián, Paul Bayer",
    sitename = "ActorInterfaces.jl",
    pages = Any["index.md", "reference.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/JuliaActors/ActorInterfaces.jl.git",
    devbranch = "main",
    push_preview = true
)
