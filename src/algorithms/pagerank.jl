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
