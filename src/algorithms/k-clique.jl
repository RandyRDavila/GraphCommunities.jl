"""
    labels_to_dict(labels::Vector{Set{Int}})::Dict{Int, Int}

Convert a vector of sets to a dictionary mapping each element to its index in the vector.
"""
function labels_to_dict(labels::Vector{Set{Int}})::Dict{Int, Int}
    d = Dict{Int, Int}()
    for (community_id, community) in enumerate(labels)
        for vertex in community
            d[vertex] = community_id
        end
    end
    return d
end

"""
    find_triangles(g::SimpleGraph)::Set{Set{Int}}

Find all the triangles in the given graph.

# Arguments
- `g::SimpleGraph`: The input graph to search for triangles.

# Returns
- A set containing all the triangles in the graph. Each triangle is represented as a set of 3 vertices.
"""
function find_triangles(g::SimpleGraph)::Set{Set{Int}}
    triangles = Set{Set{Int}}()

    for v in vertices(g)
        neighbors_v = neighbors(g, v)
        for w in neighbors_v
            if w > v
                _common_neighbors = common_neighbors(g, v, w)
                for u in _common_neighbors
                    if u > w
                        push!(triangles, Set([v, w, u]))
                    end
                end
            end
        end
    end

    return triangles
end

"""
    k_clique_graph(triangles::Set{Set{Int}})::SimpleGraph

Construct a graph where each node represents a triangle from the input set,
and edges are added between nodes if their respective triangles share two vertices.

# Arguments
- `triangles::Set{Set{Int}}`: A set of triangles, where each triangle is represented as a set of 3 vertices.

# Returns
- A graph with nodes representing triangles and edges based on shared vertices.
"""
function k_clique_graph(triangles::Set{Set{Int}})::SimpleGraph
    # Create a new graph for triangles
    k_graph = SimpleGraph(length(triangles))

    # Convert set of sets to an array of sets for indexing
    triangles_array = collect(triangles)

    # If two triangles share 2 nodes, add an edge between them in the k-clique graph
    for i in eachindex(triangles_array)
        for j = i+1:length(triangles_array)
            if length(intersect(triangles_array[i], triangles_array[j])) == 2
                add_edge!(k_graph, i, j)
            end
        end
    end

    return k_graph
end

"""
    compute(algo::KClique, g::SimpleGraph)::Dict{Int, Int}

Detect communities in a graph `g` using the K-Clique algorithm.

The function first finds triangles (or 3-cliques) in the graph. It then constructs a k-clique
graph where nodes represent triangles, and edges indicate overlap. The connected components
of this k-clique graph give the communities in the original graph.

# Arguments
- `algo::KClique`: Indicates that the K-Clique algorithm should be used for community detection.
- `g::SimpleGraph`: The graph on which to detect communities.


# Returns
- A dictionary mapping node IDs in the original graph to their respective community IDs.

# Example
```julia
julia> using GraphCommunities

julia> g = generate(KarateClub())

julia> compute(KClique(), g)
```

# Notes
Currently, the implementation is restricted to 3-cliques (triangles). Future versions might
support other clique sizes.
"""
function compute(algo::KClique, g::SimpleGraph)
    triangles = find_triangles(g)
    k_graph = k_clique_graph(triangles)

    # Get connected components of k-clique graph. Each component is a community.
    communities = connected_components(k_graph)

    # Convert community indices back to original graph vertex ids.
    triangle_list = collect(triangles)
    communities_vertex = [union([triangle_list[idx] for idx in community]...) for community in communities]

    return labels_to_dict(communities_vertex)
end