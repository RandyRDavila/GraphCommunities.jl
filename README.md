# GraphCommunities.jl

GraphCommunities.jl is a Julia package that offers utilities for graph-based community detection and visualization. It provides functions to load graphs, detect communities using the Louvain method, and visualize the detected communities.

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

1. Create a Community Graph
You can create a community graph using the planted_partition_graph function:
```julia
using GraphCommunities
using GraphPlot

# Create a graph with 3 communities, 10 nodes per community,
# 0.8 intra-community edge probability, and 0.1 inter-community edge probability.
g = planted_partition_graph(3, 10, 0.8, 0.1)
gplot(g)
```

2. Run Louvain Community Detection
To detect communities in the graph, use the louvain function:
```julia
communities = louvain(g)
```

3. Plot the Community Graph
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