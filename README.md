# GraphCommunities.jl

`GraphCommunities.jl` is a Julia package designed for detecting communities within *undirected* graphs. It employs various community detection algorithms and also provides functionality for generating graphs with community structure. Currently, the package includes the Louvain method and the k-clique percolation approach for community detection.

## Built on `Graphs.jl`

`GraphCommunities.jl` is designed to work seamlessly with the `Graphs.jl` package. All the graph structures, types, and utilities provided by `Graphs.jl` are the foundation of our package. This ensures compatibility, performance, and a familiar API for those already acquainted with `Graphs.jl`.

If you're new to Graphs.jl, it's recommended to check out their [documentation](https://github.com/JuliaGraphs/Graphs.jl) to get a deeper understanding of the graph structures and operations you can leverage.

## Installation

To add the `GraphCommunities` package to your Julia environment, you can use the Julia package manager. In the Julia REPL, enter the package manager by pressing `]`, then run:

```julia-repl
(@v1.x) pkg> add https://github.com/RandyRDavila/GraphCommunities.jl.git
```

After the package is added, you can use it in your Julia sessions with:

```julia
using GraphCommunities
```

## Usage

### Create a Community Graph

You can create a community graph using the `planted_partition_graph` function which can randomly create a graph with a predetermined number of communities. The following code creates a graph with 3 communities, 10 nodes per community, 0.8 intra-community edge probability, and 0.1 inter-community edge probability:
```julia
julia> using GraphCommunities
julia> using GraphPlot
julia> g = planted_partition_graph(3, 10, 0.8, 0.1);
julia> gplot(g)
```

Also try the `chained_cliques_graph(r, k)` function which returns a graph obtained by connecting `r` cliques one `k` nodes in a path like manor:
```julia
julia> using GraphCommunities
julia> using GraphPlot
julia> g = chained_cliques_graph(3, 4); # A 3-path of 4 cliques
julia> gplot(g)
```

### Run Louvain Community Detection

To detect communities using the louvain algorithm on a
graph loaded from a csv edge list:
```julia
julia> using GraphCommunities
julia> g = load_csv_graph("path_to_your_graph.csv");# Create a graph using Graphs.jl or load from a CSV
julia> communities = community_detection(g, Louvain()); # Find communities using the Louvain algorithm
julia> plot_communities(g, communities) # Plot the communities
```

### K-Clique Percolation Approach

To detect communities using the k-clique percolation approach on a
graph loaded from a csv edge list:
```julia
julia> using GraphCommunities
julia> g = load_csv_graph("path_to_your_graph.csv"); # Use the included load_csv_graph function
julia> community_detection(g, KClique()); # Currently, the algorithm is for k = 3 only
```

### Plot the Community Graph

After detecting the communities, you can visualize them using the plot_community_graph function:
```julia
julia> plot_community_graph(g, communities)
```

## Example Graph

The package also includes the well-known Karate Club graph as an example dataset. To load the Karate Club graph, use:

```julia
julia> using GraphCommunities
julia> g = karate_club_graph();
julia> communities = community_detection(g, Louvain());
julia> plot_community_graph(g, communities)
```

## Author

Randy R. Davila, PhD