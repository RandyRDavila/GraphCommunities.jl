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
function draw_communities(g::AbstractGraph, communities::Dict{Int, Int})
    # Ensure every vertex has a community.
    for v in vertices(g)
        if !haskey(communities, v)
            throw(ArgumentError("Node $v doesn't have a community assignment!"))
        end
    end

    _draw_communities(g, communities)
end

function draw_communities(g::AbstractGraph, communities::Vector{Int})
    # Convert the Vector to Dict.
    community_dict = Dict{Int, Int}(v => communities[v] for v in vertices(g))
    _draw_communities(g, community_dict)
end

"""
    draw_communities(g::AbstractGraph, communities::Dict{Int, Int})

Internal function to draw the graph `g` with nodes colored based on their community assignments.

This function maps each unique community label to a distinct color and then generates a plot where each node in the graph `g` is colored according to its community label.

# Arguments
- `g::AbstractGraph`: The input graph.
- `communities::Dict{Int, Int}`: A dictionary mapping each vertex to its community label.

# Returns
- A plot object with nodes colored based on their community label. Each unique community is represented by a unique color.

# Notes
- This function is an internal helper and is typically not called directly by users. It is used by higher-level community drawing functions which prepare and pass the community mapping in the form of a dictionary.
- The function assumes that every vertex in the graph `g` is assigned a community label in the `communities` dictionary. If any vertex is missing a label, an error will be raised in the calling function.
- The colors are chosen to be as distinguishable as possible, but for graphs with a very large number of communities, some colors may be similar.

# Example

```julia
julia> g = generate(KarateClub())

julia> communities = compute(LabelPropagation(), g)

julia> draw_communities(g, communities)
```
"""
function _draw_communities(g::AbstractGraph, communities::Dict{Int, Int})
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

"""
    draw_communities(g::AbstractGraph, node_labels::Vector{Tuple{Int, Int}})

Draw the graph `g` with nodes colored based on their label assignments.

# Arguments

- `g::AbstractGraph`: The input graph.
- `node_labels::Vector{Tuple{Int, Int}}`: A vector of tuples, each containing a node and its label.

# Returns

- A plot with nodes colored based on their labels.

# Example

```julia
julia> g = generate(KarateClub())

julia> communities = compute(FastLPA(), g)

julia> draw_communities(g, communities)
```

# Note

This function will only work if each node in the graph is included in the `node_labels` vector.
"""
function draw_communities(g::AbstractGraph, node_labels::Vector{Tuple{Int, Int}})
    # Convert the Vector of tuples to a Dict.
    label_dict = Dict{Int, Int}(node_labels)

    # Ensure every vertex is in the label_dict.
    for v in vertices(g)
        if !haskey(label_dict, v)
            throw(ArgumentError("Node $v doesn't have a label assignment!"))
        end
    end

    _draw_communities(g, label_dict)
end