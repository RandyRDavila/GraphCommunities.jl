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
    label_propagation_sweep!(g::SimpleGraph, labels::Dict{Int, Int}, algo::LabelPropagation)

Perform a single iteration of the Label Propagation algorithm.

# Arguments
- `g::SimpleGraph`: The graph on which to detect communities.
- `labels::Dict{Int, Int}`: A dictionary mapping each vertex to its community.
- `algo::LabelPropagation`: Indicates that the Label Propagation algorithm should be used for community detection.

# Notes
This function is not intended to be called directly. Instead, use `community_detection`.
"""
function label_propagation_sweep!(
    g::SimpleGraph,
    labels::Dict{Int, Int},
    algo::LabelPropagation
)
    # Consider the vertices in a random order.
    X = shuffle(vertices(g))

    new_labels = Dict{Int, Int}()

    # For each node in this ordering apply the label update rule.
    for v in X
        neighbors_v = neighbors(g, v)
        # Only update the label if the node has neighbors.
        if length(neighbors_v) > 0
            label_counts = Dict()
            for w in neighbors_v
                label = labels[w]
                if haskey(label_counts, label)
                    label_counts[label] += 1
                else
                    label_counts[label] = 1
                end
            end

            # Find the label that is most frequent among the neighbors of v.
            max_label = findmax(label_counts)[2]

            # If synchronous, store new labels separately.
            if algo.synchronous
                new_labels[v] = max_label
            else
                labels[v] = max_label
            end
        end
    end

    # If synchronous, apply all updates simultaneously.
    if algo.synchronous
        for v in keys(new_labels)
            labels[v] = new_labels[v]
        end
    end
end


"""
    compute(algo::LabelPropagation, g::SimpleGraph)::Dict{Int, Int}

Detect communities in a graph `g` using the Label Propagation algorithm.

The algorithm works by assigning each node a unique label. Then, in each iteration,
each node adopts the label that is most frequent among its neighbors. The algorithm
terminates when no node changes its label.

# Arguments
- `algo::LabelPropagation`: Indicates that the Label Propagation algorithm should be used for community detection.
- `g::SimpleGraph`: The graph on which to detect communities.

# Returns
- A dictionary mapping node IDs in the original graph to their respective community IDs.

# Example
```julia
julia> using GraphCommunities

julia> g = generate(KarateClub())

julia> compute(LabelPropagation(), g)
```

# Notes
The algorithm may not return the same community structure on different runs due to its
heuristic nature. However, the structures should be reasonably similar and of comparable quality.
"""
function compute(algo::LabelPropagation, g::SimpleGraph)
    # Initialize each node with a unique label.
    labels = Dict(v => v for v in vertices(g))

    # Run label propagation until convergence.
    prev_labels = deepcopy(labels)

    # Max iteration limit to prevent infinite loops.
    max_iter = 10_000

    # Iteration variable.
    iter = 0

    # Run label propagation until convergence or max_iter is reached.
    label_propagation_sweep!(g, labels, algo)
    while labels != prev_labels && iter < max_iter
        prev_labels = deepcopy(labels)
        label_propagation_sweep!(g, labels, algo)
        iter += 1
    end

    return labels
end

"""
    compute(algo::PageRank, g::AbstractGraph)::Vector{Float64}

Compute the PageRank values of the nodes in graph `g` using the PageRank algorithm.

# Arguments

- `algo::PageRank`: The PageRank algorithm configuration object. This should contain properties like
  damping factor (`d`), maximum number of iterations (`max_iter`), and tolerance (`tol`).

- `g::AbstractGraph`: The graph for which to compute the PageRank. This can be a simple graph, directed
  graph, or a weighted version of these.

# Returns

- A vector of `Float64` where each entry represents the PageRank value of the corresponding node in the graph.

# Details

The function uses the power iteration method to compute the PageRank values. If the graph is weighted,
the weights of the edges are taken into account while calculating the rank.

The algorithm iteratively refines the PageRank values until either the maximum number of iterations
is reached or the values converge within the specified tolerance.

# Example

```julia
julia> g = generate(PlantedPartition())

julia> algo = PageRank(d=0.85, max_iter=100, tol=1e-6)

julia> compute(algo, g)
```
"""
function compute(algo::PageRank, g::AbstractGraph)

    N = nv(g)
    PR = fill(1.0 / N, N)  # Initial rank
    old_PR = copy(PR)
    is_weighted = isa(g, SimpleWeightedGraph) || isa(g, SimpleWeightedDiGraph)

    # Out-Degree Weights
    W = Vector{Float64}(undef, N)
    for i in 1:N
        if is_weighted
            W[i] = sum(outneighbors(g, i) .|> out_vertex -> get_weight(g, i, out_vertex))
        else
            W[i] = outdegree(g, i)
        end
    end

    for _ in 1:algo.max_iter
        for i in 1:N
            s = 0.0
            for j in inneighbors(g, i)
                wij = is_weighted ? get_weight(g, j, i) : 1.0
                s += wij * PR[j] / W[j]
            end
            PR[i] = (1 - algo.d) + algo.d * s
        end

        # Check for convergence
        if maximum(abs.(PR - old_PR)) < algo.tol
            break
        end
        old_PR = copy(PR)
    end

    # Normalize
    PR ./= sum(PR)

    return PR
end