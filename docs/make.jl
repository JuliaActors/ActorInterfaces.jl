using Documenter, ActorInterfaces

makedocs(
    modules = [ActorInterfaces],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Schäffer Krisztián",
    sitename = "ActorInterfaces.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/tisztamo/ActorInterfaces.jl.git",
    push_preview = true
)
