
# Type alias for an array of labels, with each label being an integer.
const LabelArray = Vector{Int}

# Type alias for a list of vertices, with each vertex represented as an integer.
const VertexList = Vector{Int}

"""
    update_label_counts!(label_counts::Vector{Int}, labels::LabelArray, neighbors::VertexList)

Update the count of labels based on the neighbors of a given vertex.

# Arguments
- `label_counts::LabelArray`: An array to store the count of each label.
- `labels::LabelArray`: An array where each index corresponds to a vertex and its value corresponds to its label.
- `neighbors::VertexList`: List of neighboring vertices for the vertex being considered.

# Notes
This function is used internally by `label_propagation_sweep!` to update the label counts for the vertices.
"""
function update_label_counts!(
    label_counts::LabelArray,
    labels::LabelArray,
    neighbors::VertexList,
)
    for w in neighbors
        label = labels[w]
        label_counts[label] += 1
    end
end

"""
    random_argmax(arr::AbstractArray)::Int

Find all indices corresponding to the maximum value of the array and randomly return one of them.

# Arguments
- `arr::AbstractArray`: An array of values.

# Returns
- An index corresponding to a randomly selected maximum value of the array.

# Notes
If multiple maxima exist in the array, one of them is chosen uniformly at random.
"""
function random_argmax(arr::AbstractArray)::Int
    length(arr) == 1 && return arr[1]
    max_val = maximum(arr)
    max_indices = findall(x -> x == max_val, arr)
    return rand(max_indices)
end

"""
    label_propagation_sweep!(g::SimpleGraph, labels::LabelArray, algo::LabelPropagation,
                             X::VertexList, new_labels::LabelArray, label_counts::Vector{Int})

Perform a single iteration of the Label Propagation algorithm on the provided graph.

# Arguments
- `g::SimpleGraph`: The graph on which to detect communities.
- `labels::LabelArray`: An array where each index corresponds to a vertex and its value to its community label.
- `algo::LabelPropagation`: An instance indicating the settings of the Label Propagation algorithm.
- `X::VertexList`: A list of vertices to be considered for the propagation in the given iteration.
- `new_labels::LabelArray`: An array to store new labels if the algorithm is running in synchronous mode.
- `label_counts::LabelArray`: An array to store counts of each label during propagation.

# Notes
The function modifies the given `labels` array in-place, reflecting the label changes during propagation.
"""
function label_propagation_sweep!(
    g::SimpleGraph,
    labels::LabelArray,
    algo::LabelPropagation,
    X::VertexList,
    new_labels::LabelArray,
    label_counts::LabelArray,
)
    # Randomly permute the vertices.
    shuffle!(X)

    # For each node we map to the label that is most frequent among its neighbors.
    for v in X
        neighbors_v = neighbors(g, v)
        if !isempty(neighbors_v)
            update_label_counts!(label_counts, labels, neighbors_v)
            max_label = random_argmax(label_counts)

            if algo.synchronous
                new_labels[v] = max_label
            else
                labels[v] = max_label
            end

            fill!(label_counts, 0)
        end
    end

    if algo.synchronous
        labels .= new_labels
    end
end

"""
    compute(algo::LabelPropagation, g::SimpleGraph)::LabelArray

Detect communities in a graph `g` using the Label Propagation algorithm.

The algorithm works by initially assigning each node a unique label. Then, in each iteration,
each node adopts the label that is most frequent among its neighbors. The algorithm
terminates when no node changes its label or after reaching a maximum number of iterations.

# Arguments
- `algo::LabelPropagation`: An instance indicating the settings of the Label Propagation algorithm.
- `g::SimpleGraph`: The graph on which to detect communities.

# Returns
- A `LabelArray` where each index corresponds to a vertex and its value indicates its community label.

# Example
```julia
julia> using GraphCommunities

julia> g = generate(KarateClub())

julia> communities = compute(LabelPropagation(), g)
```

# Notes
The algorithm may not return the same community structure on different runs due to its
heuristic nature. However, the structures should be reasonably similar and of comparable quality.
"""
function compute(
    algo::LabelPropagation,
    g::SimpleGraph
)::LabelArray

    # Get the number of vertices in the graph.
    n = nv(g)

    # These assignments are too repetitive. Can we do better?
    labels, X = collect(1:n), collect(1:n)
    new_labels, label_counts = zeros(Int, n), zeros(Int, n)

    # Run the algorithm.
    prev_hash = hash(labels)
    label_propagation_sweep!(g, labels, algo, X, new_labels, label_counts)
    iter = 1
    while hash(labels) != prev_hash && iter < algo.max_iter
        prev_hash = hash(labels)
        label_propagation_sweep!(g, labels, algo, X, new_labels, label_counts)
        iter += 1
    end

    return labels
end
