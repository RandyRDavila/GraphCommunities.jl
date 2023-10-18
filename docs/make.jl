using Documenter
using GraphCommunities

makedocs(
    sitename="GraphCommunities.jl",
    modules=[GraphCommunities],
    format=Documenter.HTML(),
    checkdocs=:none,
)

# deploydocs(
#     root = "GraphCommunities",
#     target = "build",
#     dirname = "",
#     repo = "https://github.com/RandyRDavila/GraphCommunities.jl.git",
#     branch = "gh-pages",
#     deps = nothing,
#     make = nothing,
#     devbranch = nothing,
#     devurl = "dev",
#     versions = ["stable" => "v^", "v#.#", devurl => devurl],
#     forcepush = false,
#     deploy_config = auto_detect_deploy_system(),
#     push_preview = false,
#     repo_previews = repo,
#     branch_previews = branch,
#     tag_prefix = "",
# )