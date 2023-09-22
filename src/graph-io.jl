"""
    load_csv_graph(path_to_file::String) -> SimpleGraph

Load a graph from a CSV file. The CSV file should have two columns corresponding to the source
and destination of each edge.

# Arguments
- `path_to_file::String`: Path to the CSV file.

# Returns
- `SimpleGraph`: A graph constructed from the edgelist in the CSV.
"""
function load_csv_graph(path_to_file::String)
    edgelist = CSV.File(path_to_file)
    return SimpleGraph(Edge.([(row[1], row[2]) for row in edgelist]))
end

"""
    planted_partition_graph(n_communities, nodes_per_community, pintra, pinter) -> SimpleGraph

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
)
    g = SimpleGraph(n_communities * nodes_per_community)
    for i in 1:n_communities
        # Connect nodes within the same community
        start, stop = (i-1) * nodes_per_community + 1, i * nodes_per_community
        for u in start:stop
            for v in (u+1):stop
                if rand() < pintra
                    add_edge!(g, u, v)
                end
            end
        end

        # Connect nodes from this community to other communities
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
    karate_club_graph() -> SimpleGraph

Load the well-known Karate Club graph, which is included as an example dataset in the `GraphCommunities` package.

# Returns
- `SimpleGraph`: A graph representing the Karate Club network.
"""
function karate_club_graph()::SimpleGraph
    # Path to the included Karate Club Graph CSV file
    data_path = joinpath(dirname(@__DIR__), "data", "Karate-Club-Graph.csv")

    # Use the existing function to load the graph
    return load_csv_graph(data_path)
end