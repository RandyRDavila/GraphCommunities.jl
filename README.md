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

You can create a community graph using the `planted_partition_graph` function which can randomly create a graph with a predetermined number of communities:
```julia
julia> using GraphCommunities
julia> using GraphPlot
julia> g = generate(PlantedPartition());
julia> gplot(g)
```

Also try the `chained_cliques_graph(r, k)` function which returns a graph obtained by connecting `r` cliques one `k` nodes in a path like manor:
```julia
julia> using GraphCommunities
julia> using GraphPlot
julia> g = generate(ChainedCliques());
julia> gplot(g)
```
The package also includes the well-known *Karate Club Graph* as an example dataset to test algorithms on. To load the Karate Club graph, use:

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
julia> plot_communities(g, communities) # Plot the communities
```

Detect communities using the **K-clique Percolation Algorithm** on a
graph loaded from a csv edge list:
```julia
julia> using GraphCommunities
julia> g = load_csv_graph("path_to_your_graph.csv");
julia> community_detection(g, KClique());
julia> plot_communities(g, communities)
```

Detect communities using the **Label Propagation Algorithm** on the famous Karate Club Graph using **asynchronous** label updates::
```julia
julia> using GraphCommunities
julia> g = ;
julia> community_detection(g, LabelPropagation())
```

Detect communities using the **Label Propagation Algorithm** on the famous Karate Club Graph using **synchronous** label updates:
```julia
julia> using GraphCommunities
julia> g = generate(KarateClub());
julia> community_detection(g, LabelPropagation(sync=true))
```

### Drawing Communities

After detecting the communities, you can visualize them using the `plot_community_graph` function:
```julia
julia> plot_community_graph(g, communities)
```

## Author

Randy R. Davila, PhD