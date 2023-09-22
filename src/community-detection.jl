"""
    graph_modularity(g::AbstractGraph, node_to_community::Dict{Int, Int}) -> Float64

Calculate the modularity of a graph `g` given a particular community assignment
given by `node_to_community`.

# Arguments
- `g::AbstractGraph`: The input graph.
- `node_to_community::Dict{Int, Int}`: A dictionary mapping each vertex to its community.

# Returns
- `Float64`: The modularity value.
"""
function graph_modularity(
    g::AbstractGraph,
    node_to_community::Dict{Int, Int}
)
    m = ne(g)  # Total number of edges
    Q = 0.0   # Modularity

    for i in vertices(g)
        ki = degree(g, i)
        for j in vertices(g)
            kj = degree(g, j)
            Aij = has_edge(g, i, j) ? 1 : 0

            # Check if nodes i and j are in the same community
            δ = node_to_community[i] == node_to_community[j] ? 1.0 : 0.0

            Q += (Aij - (ki * kj) / (2 * m)) * δ
        end
    end

    return Q / (2 * m)
end

"""
    community_detection(g::AbstractGraph, algo::Louvain) -> Dict{Int, Int}

Detect communities in a graph `g` using the Louvain algorithm, a method based on modularity optimization.

The algorithm consists of two phases that are repeated iteratively:
1. Local Phase: Each node is moved to the community that yields the highest modularity gain.
2. Aggregation Phase: A new graph is constructed where nodes represent communities from the previous phase.

These phases are repeated until the modularity ceases to increase significantly.

# Arguments
- `g::AbstractGraph`: The graph on which to detect communities.
- `algo::Louvain`: Indicates that the Louvain algorithm should be used for community detection.

# Returns
- A dictionary mapping node IDs in the original graph to their respective community IDs.

# Example
```julia
julia> using GraphCommunities
julia> g = karate_club_graph()
julia> community_detection(g, Louvain())
```

# Notes
The algorithm may not return the same community structure on different runs due to its
heuristic nature. However, the structures should be reasonably similar and of comparable quality.
"""
function community_detection(g::AbstractGraph, algo::Louvain)
    # Initialization
    node_to_community = Dict(v => v for v in vertices(g))
    community_hist = [deepcopy(node_to_community)]

    prev_modularity = -Inf
    current_modularity = graph_modularity(g, node_to_community)
    original_graph = deepcopy(g)

    while current_modularity - prev_modularity > 1e-3
        prev_modularity = current_modularity

        # Local Phase
        for v in vertices(g)
            best_community = node_to_community[v]
            max_delta_q = 0.0

            # Cache the current community and its modularity for node v
            orig_modularity = graph_modularity(g, node_to_community)

            for u in neighbors(g, v)
                # Move v to the community of u
                node_to_community[v] = node_to_community[u]
                new_mod = graph_modularity(g, node_to_community)
                delta_q = new_mod - orig_modularity

                if delta_q > max_delta_q
                    max_delta_q = delta_q
                    best_community = node_to_community[u]
                end
            end

            # Return v to the best community found
            node_to_community[v] = best_community
        end

        # Update current_modularity after the Local Phase
        current_modularity = graph_modularity(g, node_to_community)

        # Prepare for aggregation
        communities = unique(values(node_to_community))
        node_to_new_community = Dict(
                v => findfirst(==(node_to_community[v]), communities) for v in vertices(g)
            )

        # Aggregation Phase
        g_new = SimpleGraph(length(communities))
        for e in edges(g)
            src, dst = e.src, e.dst
            s_new, d_new = node_to_new_community[src], node_to_new_community[dst]
            if s_new != d_new && !has_edge(g_new, s_new, d_new)
                add_edge!(g_new, s_new, d_new)
            end
        end

        # Prepare for next iteration
        g = g_new
        node_to_community = Dict(v => v for v in vertices(g))
        push!(community_hist, node_to_new_community)
    end

    # Map original nodes to final communities
    final_mapping = Dict()
    for v in vertices(original_graph)
        community = v
        for hist in community_hist[2:end]
            community = hist[community]
        end
        final_mapping[v] = community
    end

    return final_mapping
end

"""
    find_triangles(graph::AbstractGraph) -> Set{Set{Int}}

Find all the triangles in the given graph.

# Arguments
- `graph::AbstractGraph`: The input graph to search for triangles.

# Returns
- A set containing all the triangles in the graph. Each triangle is represented as a set of 3 vertices.
"""
function find_triangles(graph::AbstractGraph)
    triangles = Set{Set{Int}}()

    for v in vertices(graph)
        neighbors_v = neighbors(graph, v)
        for w in neighbors_v
            if w > v
                common_neighbors = intersect(neighbors_v, neighbors(graph, w))
                for u in common_neighbors
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
    k_clique_graph(triangles::Set{Set{Int}})

Construct a graph where each node represents a triangle from the input set,
and edges are added between nodes if their respective triangles share two vertices.

# Arguments
- `triangles::Set{Set{Int}}`: A set of triangles, where each triangle is represented as a set of 3 vertices.

# Returns
- A graph with nodes representing triangles and edges based on shared vertices.
"""
function k_clique_graph(triangles::Set{Set{Int}})
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
    community_detection(g::AbstractGraph, algo::KClique) -> Dict{Int, Int}

Detect communities in a graph `g` using the K-Clique algorithm.

The function first finds triangles (or 3-cliques) in the graph. It then constructs a k-clique
graph where nodes represent triangles, and edges indicate overlap. The connected components
of this k-clique graph give the communities in the original graph.

# Arguments
- `g::AbstractGraph`: The graph on which to detect communities.
- `algo::KClique`: Indicates that the K-Clique algorithm should be used for community detection.

# Returns
- A dictionary mapping node IDs in the original graph to their respective community IDs.

# Example
```julia
julia> using GraphCommunities
julia> g = karate_club_graph()
julia> community_detection(g, KClique())
```

# Notes
Currently, the implementation is restricted to 3-cliques (triangles). Future versions might
support other clique sizes.
"""
function community_detection(g::AbstractGraph, algo::KClique)
    triangles = find_triangles(g)
    k_graph = k_clique_graph(triangles)

    # Get connected components of k-clique graph
    communities = connected_components(k_graph)

    # Convert community indices back to original graph vertex ids
    triangle_list = collect(triangles)
    communities_vertex = [union([triangle_list[idx] for idx in community]...) for community in communities]

    return labels_to_dict(communities_vertex)
end


function labels_to_dict(labels)
    d = Dict{Int, Int}()
    for (community_id, community) in enumerate(labels)
        for vertex in community
            d[vertex] = community_id
        end
    end
    return d
end
