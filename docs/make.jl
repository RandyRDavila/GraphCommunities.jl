using Documenter
using GraphCommunities

makedocs(
    sitename="GraphCommunities.jl",
    modules=[GraphCommunities],
    format=Documenter.HTML(),
    checkdocs=:none,
)