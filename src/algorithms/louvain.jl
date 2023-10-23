"""
    graph_modularity(g::SimpleGraph, node_to_community::Dict{Int, Int})::Number

Calculate the modularity of a graph `g` given a particular community assignment
given by `node_to_community`.

# Arguments
- `g::SimpleGraph`: The input graph.
- `node_to_community::Dict{Int, Int}`: A dictionary mapping each vertex to its community.

# Returns
- `Float64`: The modularity value.
"""
function graph_modularity(g::SimpleGraph, node_to_community::Dict{Int, Int})::Number

    m = ne(g)  # Total number of edges in the graph.
    Q = 0.0   # Modularity to be built up incrementally.

    # Precompute the degrees and adjacency information
    k = Dict(v => degree(g, v) for v in vertices(g))
    A = Dict(
        (i, j) => has_edge(g, i, j) ? 1 : 0
        for i in vertices(g)
        for j in neighbors(g, i)
    )

    for i in vertices(g)
        ki = k[i]
        for j in neighbors(g, i)
            kj = k[j]
            Aij = A[(i, j)]
            # Check if nodes i and j are in the same community.
            δ = node_to_community[i] == node_to_community[j] ? 1.0 : 0.0
            Q += (Aij - (ki * kj) / (2 * m)) * δ
        end
    end

    return Q / (2 * m)
end


"""
    compute(algo::Louvain, g::SimpleGraph)

Detect communities in a graph `g` using the Louvain algorithm, a method based on modularity optimization.

The algorithm consists of two phases that are repeated iteratively:
1. Local Phase: Each node is moved to the community that yields the highest modularity gain.
2. Aggregation Phase: A new graph is constructed where nodes represent communities from the previous phase.

These phases are repeated until the modularity ceases to increase significantly.

# Arguments
- `algo::Louvain`: Indicates that the Louvain algorithm should be used for community detection.
- `g::SimpleGraph`: The graph on which to detect communities.

# Returns
- A dictionary mapping node IDs in the original graph to their respective community IDs.

# Example
```julia
julia> using GraphCommunities

julia> g = generate(PlantedPartition())

julia> compute(Louvain(), g)
```

# Notes
The algorithm may not return the same community structure on different runs due to its
heuristic nature. However, the structures should be reasonably similar and of comparable quality.
"""
function compute(algo::Louvain, g::SimpleGraph)
    # Initialization.
    node_to_community = Dict(v => v for v in vertices(g))
    community_hist = [deepcopy(node_to_community)]

    prev_modularity = -Inf
    current_modularity = graph_modularity(g, node_to_community)
    original_graph = deepcopy(g)

    while current_modularity - prev_modularity > 1e-3
        prev_modularity = current_modularity

        # The Local Phase.
        for v in vertices(g)
            best_community = node_to_community[v]
            max_delta_q = 0.0

            # Cache the current community and its modularity for node v.
            orig_modularity = graph_modularity(g, node_to_community)

            for u in neighbors(g, v)
                # Move v to the community of u.
                node_to_community[v] = node_to_community[u]
                new_mod = graph_modularity(g, node_to_community)
                delta_q = new_mod - orig_modularity

                if delta_q > max_delta_q
                    max_delta_q = delta_q
                    best_community = node_to_community[u]
                end
            end

            # Return v to the best community found.
            node_to_community[v] = best_community
        end

        # Update current_modularity after the Local Phase.
        current_modularity = graph_modularity(g, node_to_community)

        # Prepare for aggregation.
        communities = unique(values(node_to_community))
        node_to_new_community = Dict(
                v => findfirst(==(node_to_community[v]), communities) for v in vertices(g)
            )

        # The Aggregation Phase.
        g_new = SimpleGraph(length(communities))
        for e in edges(g)
            src, dst = e.src, e.dst
            s_new, d_new = node_to_new_community[src], node_to_new_community[dst]
            if s_new != d_new && !has_edge(g_new, s_new, d_new)
                add_edge!(g_new, s_new, d_new)
            end
        end

        # Prepare for next iteration.
        g = g_new
        node_to_community = Dict(v => v for v in vertices(g))
        push!(community_hist, node_to_new_community)
    end

    # Map original nodes to final communities.
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