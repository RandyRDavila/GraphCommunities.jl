"""
    generate(structure::ChainedCliques)::SimpleGraph

Create a graph consisting of `structure.r` cliques, each of size `structure.k`, chained together.
- `structure.r` represents the number of cliques.
- `structure.k` represents the size of each clique.

Returns a `SimpleGraph` with the chained cliques.
"""
function generate(structure::ChainedCliques)::SimpleGraph

    # Error checks.
    structure.r < 2 && throw(ArgumentError("The value of r must be 2 or greater."))
    structure.k < 3 && throw(ArgumentError("The value of k must be 3 or greater."))

    # Memory safety checks.
    isinteger(structure.r) || throw(ArgumentError("The value of r must be an integer."))
    isinteger(structure.k) || throw(ArgumentError("The value of k must be an integer."))
    structure.r > 1e6 && throw(ArgumentError("The value of r is too large, which may cause memory issues."))
    structure.k > 1e6 && throw(ArgumentError("The value of k is too large, which may cause memory issues."))

    # Number of total vertices.
    n = structure.r * structure.k
    g = SimpleGraph(n)

    # Add edges within each clique.
    for i in 1:structure.r
        start_idx = (i - 1) * structure.k + 1
        end_idx = start_idx + structure.k - 1
        for v in start_idx:end_idx
            for u in (v+1):end_idx
                add_edge!(g, v, u)
            end
        end
    end

    # Add edges between cliques.
    for i in 1:(structure.r - 1)
        add_edge!(g, i*structure.k, i*structure.k + 1)
    end

    return g
end

"""
    generate(structure::PlantedPartition)::SimpleGraph

Generate a graph based on the planted partition model.
- `structure.n_communities` is the number of communities.
- `structure.nodes_per_community` denotes the number of nodes per community.
- `structure.pintra` is the probability of an edge within a community.
- `structure.pinter` is the probability of an edge between communities.

Returns a `SimpleGraph` constructed based on the planted partition model.
"""
function generate(structure::PlantedPartition)::SimpleGraph

    g = SimpleGraph(structure.n_communities * structure.nodes_per_community)
    for i in 1:structure.n_communities
        # Connect nodes within the same community.
        start, stop = (i-1) * structure.nodes_per_community + 1, i * structure.nodes_per_community
        for u in start:stop
            for v in (u+1):stop
                if rand() < structure.pintra
                    add_edge!(g, u, v)
                end
            end
        end

        # Connect nodes from this community to other communities.
        for j in (i+1):structure.n_communities
            for u in start:stop
                for v in ((j-1)*structure.nodes_per_community + 1):(j*structure.nodes_per_community)
                    if rand() < structure.pinter
                        add_edge!(g, u, v)
                    end
                end
            end
        end
    end
    return g
end

"""
    generate(structure::KarateClub)::SimpleGraph

Construct the famous Zachary's Karate Club graph. This graph represents the friendships
between the 34 members of a karate club studied by Wayne W. Zachary in 1977.

Returns a `SimpleGraph` representing the Karate Club network.
"""
function generate(structure::KarateClub)::SimpleGraph
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