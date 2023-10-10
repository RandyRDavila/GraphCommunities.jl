"""
    compute(::BFS, graph::AbstractGraph, start_node::Int, end_node::Int; return_path::Bool=false)

Compute the shortest path or distance between `start_node` and `end_node` in a graph using
the Breadth-First Search (BFS) algorithm.

# Arguments:
- `::BFS`: An indicator for the BFS algorithm.
- `graph::AbstractGraph`: The graph in which to find the shortest path or distance.
- `start_node::Int`: The starting node index.
- `end_node::Int`: The ending node index.

# Keyword Arguments:
- `return_path::Bool`: If true, the function returns the shortest path as an array of node indices.
  If false (the default), the function returns the shortest distance as an integer.

# Returns:
- If `return_path` is true: An array of integers representing the shortest path from `start_node`
  to `end_node`. If there's no path, an empty array is returned.
- If `return_path` is false (or omitted): An integer representing the shortest distance from `start_node`
  to `end_node`. If the nodes aren't connected, `-1` is returned.

# Example:
```julia-repl
julia> using Graphs, GraphCommunities
julia> g = PathGraph(5)
julia> compute(BFS(), g, 1, 5)           # Returns 4
julia> compute(BFS(), g, 1, 5, return_path=true)  # Returns [1, 2, 3, 4, 5]
```
"""
function compute(
    ::BFS,
    graph::AbstractGraph,
    start_node::Int,
    end_node::Int;
    return_path::Bool=false
)
    # Number of vertices in the graph
    n = nv(graph)

    # Ensure the nodes are valid
    if start_node < 1 || start_node > n || end_node < 1 || end_node > n
        throw(ArgumentError("Invalid node indices"))
    end

    # If the start node is the same as the end node, return 0 or [start_node] based on `return_path`
    if start_node == end_node
        return return_path ? [start_node] : 0
    end

    # Initialize distances with a large value. Here, we use Int's maximum value.
    distances = fill(typemax(Int), n)
    distances[start_node] = 0

    # For path reconstruction
    parent = Dict{Int, Int}()

    # Create a queue for BFS and enqueue the start node
    queue = [start_node]

    while !isempty(queue)
        current_node = popfirst!(queue)
        for neighbor in neighbors(graph, current_node)
            # If this neighbor hasn't been visited
            if distances[neighbor] == typemax(Int)
                distances[neighbor] = distances[current_node] + 1
                parent[neighbor] = current_node
                push!(queue, neighbor)
            end
        end
    end

    # If `return_path` is true, reconstruct the path
    if return_path
        if !haskey(parent, end_node)
            return []  # Return empty array if there's no path
        end

        path = [end_node]
        while haskey(parent, path[end])
            push!(path, parent[path[end]])
        end
        return reverse(path)  # Reverse to get the path from start_node to end_node
    else
        # Return the distance or -1 if nodes aren't connected
        return distances[end_node] == typemax(Int) ? -1 : distances[end_node]
    end
end