# GraphCommunities.jl

`GraphCommunities.jl` is a Julia package designed for detecting communities within *undirected* graphs. It employs various community detection algorithms and also provides functionality for generating graphs with community structure. Currently, the package includes the following community detection algorithms:

1. The Louvain Algorithm
2. The K-Clique Percolation Algorithm with `K = 3`
3. The Label Propagation Algorithm

## Built on `Graphs.jl`

`GraphCommunities.jl` is designed to work seamlessly with the `Graphs.jl` package. All the graph structures, types, and utilities provided by `Graphs.jl` are the foundation of our package. This ensures compatibility, performance, and a familiar API for those already acquainted with `Graphs.jl`.

If you're new to Graphs.jl, it's recommended to check out their [documentation](https://github.com/JuliaGraphs/Graphs.jl) to get a deeper understanding of the graph structures and operations you can leverage.

## Installation

To add the `GraphCommunities` package to your Julia environment, you can use the Julia package manager. In the Julia REPL, enter the package manager by pressing `]`, then run:

```julia
(@v1.x) pkg> add https://github.com/RandyRDavila/GraphCommunities.jl.git
```

After the package is added, you can use it in your Julia sessions with:

```julia
using GraphCommunities
```

## Usage

### Create a Community Graph

A **planted partition graph** (also known as a **stochastic block model**) is a probabilistic graph model often used to generate synthetic networks with community structures for testing algorithms, especially community detection methods:
```julia
julia> using GraphCommunities
julia> using GraphPlot
julia> g = generate(PlantedPartition());
julia> gplot(g)
```

Another graph with community structure can be obtained by connecting `r` cliques, each with `k` nodes, in a path like manor:
```julia
julia> using GraphCommunities
julia> using GraphPlot
julia> g = generate(ChainedCliques(;r=8, k=5));
julia> gplot(g)
```

This package also includes the well-known **Karate Club Graph** as an example dataset to test algorithms on:
```julia
julia> using GraphCommunities
julia> using GraphPlot
julia> g = generate(KarateClub());
julia> gplot(g)
```

### Community Detection Algorithms

Detect communities using the **Louvain Algorithm** on a
graph loaded from a csv edge list:
```julia
julia> using GraphCommunities
julia> g = load_csv_graph("path_to_your_graph.csv");
julia> communities = community_detection(g, Louvain()); # Find communities using the Louvain algorithm
julia> draw_communities(g, communities) # Draw the communities
```

Detect communities using the **K-clique Percolation Algorithm** on a
graph loaded from a csv edge list:
```julia
julia> using GraphCommunities
julia> g = load_csv_graph("path_to_your_graph.csv");
julia> community_detection(g, KClique());
julia> draw_communities(g, communities) # Draw the communities
```

Detect communities using the **Label Propagation Algorithm** on the famous Karate Club Graph using **asynchronous** label updates::
```julia
julia> using GraphCommunities
julia> g = ;
julia> community_detection(g, LabelPropagation())
julia> draw_communities(g, communities) # Draw the communities
```

Detect communities using the **Label Propagation Algorithm** on the famous Karate Club Graph using **synchronous** label updates:
```julia
julia> using GraphCommunities
julia> g = generate(KarateClub());
julia> community_detection(g, LabelPropagation(sync=true))
julia> draw_communities(g, communities) # Draw the communities
```

### Drawing Communities

After detecting the communities, you can visualize them using the `draw_communities` function:
```julia
julia> draw_communities(g, communities) # Draw the communities
```

### Saving Graphs and Loading Graphs

You can also save your graphs in various formats by using the `GraphIO` submodule:
```julia
julia> using GraphCommunities
julia> using GraphCommunities.GraphIO: write_edgelist
julia> g = generate(ChainedCliques(2, 6))
julia> write_edgelist(g, "test-edgelist.csv") # write to a .csv file
julia> write_edgelist(g, "test-edgelist.txt") # write to a text file
```

Similarily, you can use this submodule to load graphs:
```julia
julia> using GraphCommunities
julia> using GraphCommunities.GraphIO: load_edgelist
julia> g1 = load_edgelist("test-edgelist.csv")
julia> g2 = load_edgelist("test-edgelist.txt")
```

## Author

Randy R. Davila, PhD