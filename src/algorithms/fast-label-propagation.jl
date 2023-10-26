# Among the set of n_seen_labels in seen_labels, with corresponding counts in
# seen_label_counts[seen_labels[k]] for k in 1:n_seen_labels, find the maximum label
# with maximal counts (max of argmax of seen_label_counts[seen_labels[1:n_seen_labels]]).
"""
    _max_argmax_in_seen(
        seen_label_counts::Vector{Int},
        seen_labels::Vector{Int},
        n_seen_labels::Int
    )::Int

Finds the maximum label with the highest count among seen labels.

This function is used in the label propagation algorithm to determine the most popular
label among a node's neighbors.

# Arguments
- `seen_label_counts::Vector{Int}`: A vector containing counts of each label seen.
- `seen_labels::Vector{Int}`: The labels that have been seen in the current context.
- `n_seen_labels::Int`: The number of seen labels to consider.

# Returns
- The label with the highest count among the seen labels. In case of a tie, the highest label is chosen.

# Notes
- This function is part of the internal mechanics of label propagation and operates on a subset of labels.
"""
function _max_argmax_in_seen(
    seen_label_counts::Vector{Int},
    seen_labels::Vector{Int},
    n_seen_labels::Int,
)
    # Initialize variables to identify the most frequent label.
    maximal_count = 0
    max_maximal_label = 0
    for count_label in @view seen_labels[1:n_seen_labels]
        label_count = seen_label_counts[count_label]

        # Update the maximal count and corresponding label.
        if label_count > maximal_count
            maximal_count = label_count
            max_maximal_label = count_label
        elseif label_count == maximal_count
            # In case of a tie, choose the larger label.
            max_maximal_label = max(count_label, max_maximal_label)
        end
    end
    return max_maximal_label
end

"""
    _label_propagation_sweep!(
        pres_labels::Vector{Int},
        next_labels::Vector{Int},
        seen_labels::Vector{Int},
        seen_label_counts::Vector{Int},
        edge_list::Vector{Tuple{Int,Int}}
    )::Bool

Performs a single sweep of label propagation on a graph.

This function updates the labels of vertices based on the most frequent labels among their
neighbors, using a provided edge list.

# Arguments
- `pres_labels::Vector{Int}`: The current labels of the vertices.
- `next_labels::Vector{Int}`: The vector to store the updated labels.
- `seen_labels::Vector{Int}`: A buffer vector to store observed neighbor labels.
- `seen_label_counts::Vector{Int}`: A vector to count occurrences of each label.
- `edge_list::Vector{Tuple{Int,Int}}`: The list of edges in the graph.

# Returns
- `true` if the labeling has reached a stationary state (no changes), `false` otherwise.

# Notes
- Assumes the edge list is lexicographically ordered.
- Edges are processed sequentially, and labels are updated based on the most frequent neighbor labels.
"""
function _label_propagation_sweep!(
    pres_labels::Vector{Int},
    next_labels::Vector{Int},
    seen_labels::Vector{Int},
    seen_label_counts::Vector{Int},
    edge_list::Vector{Tuple{Int,Int}},
)
    edge_list_readpos = 1
    edge_list_exhausted = false
    node, neighbor = edge_list[edge_list_readpos]

    # Scan through all edges in the edge list.
    while !edge_list_exhausted # Expect valid `node` and `neighbor` on entry.

        # Scan through all edges originating from a give node,
        # accumulating neighbor label counts in the process.
        # (Edge list is lexicographically ordered.)

        # To detect when we hit a new node in the edge list,
        # we keep track of the last node we've processed.
        local prev_node

        # Tracks the number of neighbor labels (neighbors) we've recorded
        # in the seen_labels buffer. Note that the latter may contain duplicates,
        # and the former counts those duplicates.
        n_seen_labels = 0

        while true # Expect valid `node` and `neighbor` on entry.
            neighbor_label = pres_labels[neighbor]

            n_seen_labels += 1
            seen_labels[n_seen_labels] = neighbor_label
            seen_label_counts[neighbor_label] += 1

            # Look up next node and neighbor, if safe.
            edge_list_readpos += 1
            edge_list_readpos > length(edge_list) &&
                (edge_list_exhausted = true; break)

            prev_node = node
            node, neighbor = edge_list[edge_list_readpos]

            # If we've encountered a new node, break from counting neighbor labels
            # for the now-previous node, and process those counts.
            node != prev_node && break
        end

        # Decide the next label for the node based on neighbor counts.
        max_maximal_label = _max_argmax_in_seen(seen_label_counts, seen_labels, n_seen_labels)
        next_labels[prev_node] = max_maximal_label

        # Reset the seen label counts touched in this iteration.
        for seen_label in @view seen_labels[1:n_seen_labels]
            seen_label_counts[seen_label] = 0
        end
        prev_node = node
    end

    # Check whether the algorithm has hit a stationary point,
    # and migrate the next labels into the present labels.
    # TODO: We could consolidate these operations into a single pass
    #   for better performance.

    # Determine if the labels have changed and update for the next iteration.
    stationary = pres_labels == next_labels
    pres_labels .= next_labels
    return stationary
end

"""
    _sync_label_propagation(
        edge_list::Vector{Tuple{Int,Int}},
        num_vertices::Int
    )::Array{Tuple{Int,Int}}

Perform synchronous label propagation on a graph.

The graph is represented by its edge list `edge_list` and the number of vertices `num_vertices`.
This function implements the Label Propagation algorithm for community detection, assuming that
each vertex initially has a unique label.

# Arguments
- `edge_list::Vector{Tuple{Int,Int}}`: An array of tuples, each representing an edge in the graph.
- `num_vertices::Int`: The number of vertices in the graph.

# Returns
- A vector of tuples, where each tuple contains a vertex index and its corresponding label.

# Notes
- The edge list should be lexicographically sorted.
- The edge list is expected to be non-empty.
- The algorithm iterates until either no label changes occur or a maximum number of iterations (`MAX_ITERATIONS`) is reached.
"""

function _sync_label_propagation(
    edge_list::Vector{Tuple{Int,Int}},
    num_vertices::Int,
    max_iter::Int,
)
    # This method assumes that edge_list is lexicographically sorted,
    # as should be the case for the edge list received from Rel in the FFI.

    # This method also expects a nonempty edge list.
    @assert !isempty(edge_list) "Edge list expected non-empty."

    # TODO: We might be able to achieve better performance by, instead of using
    #   seen_label_counts as a scatter-gather type buffer, sorting and counting
    #   seen_labels directly. Would also be better for parallelism, if we go there.
    pres_labels = collect(1:num_vertices)
    next_labels = Vector{Int}(undef, num_vertices)
    seen_labels = Vector{Int}(undef, num_vertices)
    seen_label_counts = zeros(Int, num_vertices)

    stationary, iteration = false, 0
    while !stationary && iteration < max_iter
        stationary = _label_propagation_sweep!(
                        pres_labels,
                        next_labels,
                        seen_labels,
                        seen_label_counts,
                        edge_list
                    )
        iteration += 1
    end

    return collect(enumerate(pres_labels))
end

function _preprocess_graph(g::SimpleGraph)
    edge_list = Vector{Tuple{Int,Int}}()
    for e in edges(g)
        push!(edge_list, (src(e), dst(e)))
        push!(edge_list, (dst(e), src(e)))
    end
    sort(edge_list), nv(g)
end

"""
    compute(algo::FastLPA, g::SimpleGraph)

Execute the Fast Label Propagation algorithm on a graph.

This function processes a SimpleGraph using the Fast Label Propagation algorithm to perform
community detection or labeling. It first preprocesses the graph to generate an edge list
and the number of vertices, then applies synchronous label propagation if enabled.

# Arguments
- `algo::FastLabelPropagation`: The Fast Label Propagation algorithm instance.
- `g::SimpleGraph`: The graph to be processed, represented as a SimpleGraph.

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
julia> g = generate(PlantedPartition())

julia> compute(FastLPA(), g)
```
"""
function compute(
    algo::FastLPA,
    g::SimpleGraph,
)
    edge_list, num_vertices = _preprocess_graph(g)
    algo.synchronous && return _sync_label_propagation(edge_list, num_vertices, algo.max_iter)
    return nothing
end

"""
    compute(algo::FastLPA, edge_list::Vector{Tuple{Int,Int}}, num_vertices::Int)

Execute the Fast Label Propagation algorithm using a precomputed edge list.

This variant of the `compute` function allows for direct input of a graph's edge list and number of vertices.
It's particularly useful when the edge list has been precomputed or when working with a graph representation
that doesn't conform to a SimpleGraph.

# Arguments
- `algo::FastLPA`: The Fast Label Propagation algorithm instance.
- `edge_list::Vector{Tuple{Int,Int}}`: The edge list of the graph, where each edge is represented as a tuple of vertex indices.
- `num_vertices::Int`: The number of vertices in the graph.

# Returns
- If `algo.synchronous` is `true`, it returns the result of synchronous label propagation;
  otherwise, it returns `nothing`.

# Notes
- The edge list should be lexicographically sorted and represent a valid graph.
- Only synchronous label propagation is currently implemented.
"""
function compute(
    algo::FastLPA,
    edge_list::Vector{Tuple{Int,Int}},
    num_vertices::Int,
)
    algo.synchronous && return _sync_label_propagation(edge_list, num_vertices, algo.max_iter)
    return nothing
end
