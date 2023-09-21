# GraphCommunities.jl

`GraphCommunities.jl`` is a Julia package designed for detecting communities within graphs. It employs various community detection algorithms. Currently, the package includes the Louvain method and the k-clique percolation approach for community detection.

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
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

## Usage

### Create a Community Graph

You can create a community graph using the `planted_partition_graph` function which can randomly create a graph with a predetermined number of communities:
```julia
using GraphCommunities
using GraphPlot

# Create a graph with 3 communities, 10 nodes per community,
# 0.8 intra-community edge probability, and 0.1 inter-community edge probability.
g = planted_partition_graph(3, 10, 0.8, 0.1)
gplot(g)
```

### Run Louvain Community Detection

To detect communities in the graph, use the louvain function:
```julia
using GraphCommunities

# Create a graph using Graphs.jl or load from a CSV
g = load_csv_graph("path_to_your_graph.csv")

# Find communities using the Louvain algorithm
communities = louvain(g)

# Plot the communities
plot_communities(g, communities)
```

### K-Clique Percolation Approach

To detect communities using the k-clique percolation approach on a
graph loaded from a csv edge list:
```julia
using GraphCommunities

# Use the included load_csv_graph function
g = load_csv_graph("path_to_your_graph.csv")

# Currently, the algorithm is for k = 3 only
communities = k_clique_communities(g)

plot_communities(g, communities)
```

### Plot the Community Graph

After detecting the communities, you can visualize them using the plot_community_graph function:
```julia
plot_community_graph(g, communities)
```

## Example Graph

The package also includes the well-known Karate Club graph as an example dataset. To load the Karate Club graph, use:

```julia
using GraphCommunities
g = karate_club_graph()
communities = louvain(g)
plot_community_graph(g, communities)
```

## Author

Randy R. Davila, PhD