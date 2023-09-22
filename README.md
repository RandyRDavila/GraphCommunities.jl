# GraphCommunities.jl

`GraphCommunities.jl` is a Julia package designed for detecting communities within graphs. It employs various community detection algorithms. Currently, the package includes the Louvain method and the k-clique percolation approach for community detection.

## Built on `Graphs.jl`

`GraphCommunities.jl` is designed to work seamlessly with the `Graphs.jl` package. All the graph structures, types, and utilities provided by `Graphs.jl` are the foundation of our package. This ensures compatibility, performance, and a familiar API for those already acquainted with `Graphs.jl`.

If you're new to Graphs.jl, it's recommended to check out their [documentation](https://github.com/JuliaGraphs/Graphs.jl) to get a deeper understanding of the graph structures and operations you can leverage.

## Installation

Since this package is not registered, you'll need to clone it from GitHub and then activate it. Here's how:

1. Clone this repository:
```
git clone https://github.com/RandyRDavila/GraphCommunities.jl.git
```

2. Navigate to the cloned directory and start Julia:
```
cd GraphCommunities.jl
julia
```

3. In the Julia REPL, activate and instantiate the project to ensure you have all the required dependencies:
```julia
julia> using Pkg
julia> Pkg.activate(".")
julia> Pkg.instantiate()
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

Also try the `chained_cliques_graph` function:
```julia
julia> using GraphCommunities
julia> using GraphPlot
julia> g = chained_cliques_graph(3, 4); # A 3-path of 4 cliques
julia> gplot(g)
```

### Run Louvain Community Detection

To detect communities in the graph, use the louvain function:
```julia
julia> using GraphCommunities
julia> g = load_csv_graph("path_to_your_graph.csv");# Create a graph using Graphs.jl or load from a CSV
julia> communities = louvain(g); # Find communities using the Louvain algorithm
julia> plot_communities(g, communities) # Plot the communities
```

### K-Clique Percolation Approach

To detect communities using the k-clique percolation approach on a
graph loaded from a csv edge list:
```julia
julia> using GraphCommunities
julia> g = load_csv_graph("path_to_your_graph.csv"); # Use the included load_csv_graph function
julia> communities = k_clique_communities(g); # Currently, the algorithm is for k = 3 only
julia> plot_communities(g, communities)
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
julia> communities = louvain(g);
julia> plot_community_graph(g, communities)
```

## Author

Randy R. Davila, PhD