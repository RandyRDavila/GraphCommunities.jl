

"""
    _max_argmax_in_seen_weighted(
        seen_label_weights::Vector{Float64},
        seen_labels::Vector{Int},
        n_seen_labels::Int
    )::Int

Finds the maximum label with the highest accumulated weight among seen labels.

This function is used in the label propagation algorithm for weighted graphs to determine the most 'influential'
label among a node's neighbors, based on the weights of the edges connecting to those neighbors.

# Arguments
- `seen_label_weights::Vector{Float64}`: A vector containing the accumulated weights for each label seen.
- `seen_labels::Vector{Int}`: The labels that have been seen in the current context.
- `n_seen_labels::Int`: The number of seen labels to consider.

# Returns
- The label with the highest accumulated weight among the seen labels. In case of a tie, the highest label is chosen.

# Notes
- This function is part of the internal mechanics of label propagation for weighted graphs and operates on a subset of labels.
"""
function _max_argmax_in_seen_weighted(
    seen_label_weights::Vector{Float64},
    seen_labels::Vector{Int},
    n_seen_labels::Int,
)
    maximal_weight = 0.0
    max_maximal_label = 0
    for i in 1:n_seen_labels
        label = seen_labels[i]
        label_weight = seen_label_weights[label]

        # Update the maximal weight and corresponding label.
        if label_weight > maximal_weight
            maximal_weight = label_weight
            max_maximal_label = label
        elseif label_weight == maximal_weight
            # In case of a tie, choose the larger label.
            max_maximal_label = max(label, max_maximal_label)
        end
    end
    return max_maximal_label
end

function _label_propagation_sweep_weighted!(
    pres_labels::Vector{Int},
    next_labels::Vector{Int},
    seen_labels::Vector{Int},
    seen_label_weights::Vector{Float64},
    edge_list::Vector{Tuple{Int,Int,Float64}},
)
    edge_list_readpos = 1
    edge_list_exhausted = false
    node, neighbor, weight = edge_list[edge_list_readpos]

    while !edge_list_exhausted
        local prev_node = node
        n_seen_labels = 0

        while true
            neighbor_label = pres_labels[neighbor]

            n_seen_labels += 1
            seen_labels[n_seen_labels] = neighbor_label
            seen_label_weights[neighbor_label] += weight

            edge_list_readpos += 1
            if edge_list_readpos > length(edge_list)
                edge_list_exhausted = true
                break
            end

            prev_node = node
            node, neighbor, weight = edge_list[edge_list_readpos]
            node != prev_node && break
        end

        max_maximal_label = _max_argmax_in_seen_weighted(seen_label_weights, seen_labels, n_seen_labels)
        next_labels[prev_node] = max_maximal_label

        for seen_label in @view seen_labels[1:n_seen_labels]
            seen_label_weights[seen_label] = 0.0
        end
        prev_node = node
    end

    stationary = pres_labels == next_labels
    pres_labels .= next_labels
    return stationary
end

function _sync_label_propagation_weighted(
    edge_list::Vector{Tuple{Int, Int, Float64}},
    num_vertices::Int,
    max_iter::Int,
)
    # Assumptions: edge_list is lexicographically sorted.
    @assert !isempty(edge_list) "Edge list expected non-empty."

    pres_labels = collect(1:num_vertices)
    # next_labels = Vector{Int}(undef, num_vertices)
    seen_labels = Vector{Int}(undef, num_vertices)
    seen_label_weights = zeros(Float64, num_vertices)

    next_labels = collect(1:num_vertices)

    stationary, iteration = false, 0
    while !stationary && iteration < max_iter
        stationary = _label_propagation_sweep_weighted!(
                        pres_labels,
                        next_labels,
                        seen_labels,
                        seen_label_weights,
                        edge_list
                    )
        iteration += 1
    end

    return collect(enumerate(pres_labels))
end

function compute(
    algo::FastLPA,
    edge_list::Vector{Tuple{Int, Int, Float64}},
    num_vertices::Int,
)
    algo.synchronous && return _sync_label_propagation_weighted(edge_list, num_vertices, algo.max_iter)
    return nothing
end

function _preprocess_graph(g::SimpleWeightedGraph)
    edge_list = Vector{Tuple{Int, Int, Float64}}()
    for e in SimpleWeightedGraphs.edges(g)

        weight = SimpleWeightedGraphs.get_weight(g, SimpleWeightedGraphs.src(e), SimpleWeightedGraphs.dst(e))

        push!(edge_list, (SimpleWeightedGraphs.src(e), SimpleWeightedGraphs.dst(e), weight))
        push!(edge_list, (SimpleWeightedGraphs.dst(e), SimpleWeightedGraphs.src(e), weight))
    end
    return sort(edge_list), SimpleWeightedGraphs.nv(g), true
end

"""
    compute(algo::FastLPA, g::SimpleWeightedGraph)

Execute the Fast Label Propagation algorithm on a graph.

This function processes a `SimpleWeightedGraph` using the Fast Label Propagation algorithm to perform
community detection or labeling. It first preprocesses the graph to generate an edge list
and the number of vertices, then applies synchronous label propagation if enabled.

# Arguments
- `algo::FastLabelPropagation`: The Fast Label Propagation algorithm instance.
- `g::SimpleWeightedGraph`: The graph to be processed, represented as a SimpleWeightedGraph.

# Returns
- If `algo.synchronous` is `true`, it returns the result of synchronous label propagation;
  otherwise, it returns `nothing`.

# Notes
- The graph `g` is first converted into an edge list and the number of vertices is determined.
- This function delegates to `_sync_label_propagation` for the actual label propagation process.
- Currently, only synchronous label propagation is implemented. If `algo.synchronous` is `false`,
  the function will return `nothing`.

# Example

```julia
julia> compute(FastLPA(), g)
```
"""
function compute(
    algo::FastLPA,
    g::SimpleWeightedGraph,
)
    edge_list, num_vertices = _preprocess_graph(g)
    algo.synchronous && return _sync_label_propagation_weighted(edge_list, num_vertices, algo.max_iter)
    return nothing
end