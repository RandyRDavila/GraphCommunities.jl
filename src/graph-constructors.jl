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

    # Check if r is less than 2.
    r < 2 && throw(ArgumentError("The value of r must be 2 or greater."))

    # Check if k is less than 3.
    k < 3 && throw(ArgumentError("The value of k must be 3 or greater."))

    # Number of total vertices.
    n = r * k
    g = SimpleGraph(n)

    # Add edges within each clique.
    for i in 1:r
        start_idx = (i - 1) * k + 1
        end_idx = start_idx + k - 1
        for v in start_idx:end_idx
            for u in (v+1):end_idx
                add_edge!(g, v, u)
            end
        end
    end

    # Add edges between cliques.
    for i in 1:(r - 1)
        add_edge!(g, i*k, i*k + 1)
    end

    return g
end


"""
    planted_partition_graph(n_communities, nodes_per_community, pintra, pinter) -> AbstractGraph

Generate a graph based on the planted partition model.

# Arguments
- `n_communities`: Number of communities.
- `nodes_per_community`: Number of nodes per community.
- `pintra`: Probability of an edge within a community.
- `pinter`: Probability of an edge between communities.

# Returns
- `SimpleGraph`: A graph generated based on the planted partition model.
"""
function planted_partition_graph(
    n_communities::Int,
    nodes_per_community::Int,
    pintra::Float64,
    pinter::Float64
)::AbstractGraph

    g = SimpleGraph(n_communities * nodes_per_community)
    for i in 1:n_communities
        # Connect nodes within the same community.
        start, stop = (i-1) * nodes_per_community + 1, i * nodes_per_community
        for u in start:stop
            for v in (u+1):stop
                if rand() < pintra
                    add_edge!(g, u, v)
                end
            end
        end

        # Connect nodes from this community to other communities.
        for j in (i+1):n_communities
            for u in start:stop
                for v in ((j-1)*nodes_per_community + 1):(j*nodes_per_community)
                    if rand() < pinter
                        add_edge!(g, u, v)
                    end
                end
            end
        end
    end
    return g
end

"""
    karate_club_graph() -> AbstractGraph

Create the Zachary's Karate Club graph.

# Returns
- A `SimpleGraph` representing the Karate Club network.
"""
function karate_club_graph()::AbstractGraph
    # There are 34 members in the Karate Club.
    g = SimpleGraph(34)

    # Define the edges based on Zachary's study.
    edges = [
        (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 11),
        (1, 12), (1, 13), (1, 14), (1, 18), (1, 20), (1, 22), (1, 32),
        (2, 3), (2, 4), (2, 8), (2, 14), (2, 18), (2, 20), (2, 22), (2, 31),
        (3, 4), (3, 8), (3, 9), (3, 10), (3, 14), (3, 28), (3, 29), (3, 33),
        (4, 8), (4, 13), (4, 14),
        (5, 7), (5, 11),
        (6, 7), (6, 11), (6, 17),
        (7, 17),
        (9, 31), (9, 33), (9, 34),
        (10, 34),
        (14, 34),
        (15, 33), (15, 34),
        (16, 33), (16, 34),
        (19, 33), (19, 34),
        (20, 34),
        (21, 33), (21, 34),
        (23, 33), (23, 34),
        (24, 26), (24, 28), (24, 30), (24, 33), (24, 34),
        (25, 26), (25, 28), (25, 32),
        (26, 32),
        (27, 30), (27, 34),
        (28, 34),
        (29, 32), (29, 34),
        (30, 33), (30, 34),
        (31, 33), (31, 34),
        (32, 33), (32, 34),
        (33, 34)
    ]

    for (u, v) in edges
        add_edge!(g, u, v)
    end

    return g
end