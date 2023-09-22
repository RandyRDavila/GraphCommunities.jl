"""
    chained_cliques_graph(r::Int, k::Int) -> AbstractGraph

Generate a graph obtained by starting with `r` cliques each of `k` nodes,
and then chaining them together by attaching one node from each clique to the next.

# Arguments
- `r`: Number of cliques.
- `k`: Nodes in each clique.

# Returns
- A `SimpleGraph` representing the chained cliques.
"""
function chained_cliques_graph(r::Int, k::Int)::AbstractGraph

    # Check if r is less than 2
    r < 2 && throw(ArgumentError("The value of r must be 2 or greater."))

    # Check if k is less than 3
    k < 3 && throw(ArgumentError("The value of k must be 3 or greater."))

    # Number of total vertices
    n = r * k
    g = SimpleGraph(n)

    # Add edges within each clique
    for i in 1:r
        start_idx = (i - 1) * k + 1
        end_idx = start_idx + k - 1
        for v in start_idx:end_idx
            for u in (v+1):end_idx
                add_edge!(g, v, u)
            end
        end
    end

    # Add edges between cliques
    for i in 1:(r - 1)
        add_edge!(g, i*k, i*k + 1)
    end

    return g
end