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
    max_iter = algo.max_iter

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