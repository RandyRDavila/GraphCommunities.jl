"""
    graph_modularity(g::AbstractGraph, node_to_community::Dict{Int, Int}) -> Float64

Calculate the modularity of a graph given a particular community assignment.

# Arguments
- `g::AbstractGraph`: The input graph.
- `node_to_community::Dict{Int, Int}`: A dictionary mapping each vertex to its community.

# Returns
- `Float64`: The modularity value.
"""
function graph_modularity(g::AbstractGraph, node_to_community::Dict{Int, Int})
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
    louvain(g::AbstractGraph) -> Dict

Apply the Louvain method for community detection to the graph `g`.

# Arguments
- `g::AbstractGraph`: The input graph.

# Returns
- `Dict`: A dictionary mapping each vertex to its detected community.
"""
function louvain(g::AbstractGraph)
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