"""
    draw_communities(g::AbstractGraph, communities::Dict)

Draw the graph `g` with nodes colored based on their community assignments.

# Arguments
- `g::AbstractGraph`: The input graph.
- `communities::Dict`: A dictionary mapping each vertex to its community.

# Returns
- A plot with nodes colored based on their community.

# Note
This function will only work if each node in the graph is assigned to a community.
"""
function draw_communities(g::AbstractGraph, communities::Dict)
    # Ensure every vertex has a community.
    for v in vertices(g)
        if !haskey(communities, v)
            throw(ArgumentError("Node $v doesn't have a community assignment!"))
        end
    end

    # Map each unique community to a color.
    unique_communities = unique(values(communities))
    colors = distinguishable_colors(length(unique_communities))

    community_to_color = Dict(
            unique_communities[i] => colors[i] for i in eachindex(unique_communities)
        )
    node_colors = [community_to_color[communities[v]] for v in vertices(g)]

    # Generate the plot.
    gplot(g, nodefillc=node_colors)
end
