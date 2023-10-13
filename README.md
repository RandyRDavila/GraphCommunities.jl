# GraphCommunities.jl

[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://randyrdavila.github.io/graphcommunities.jl/)



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

Another graph with community structure can be obtained by connecting `num_cliques` cliques, each with `clique_size` nodes, in a path like manor:
```julia
julia> using GraphCommunities
julia> using GraphPlot
julia> g = generate(ChainedCliques(;num_cliques=8, clique_size=5));
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
julia> communities = compute(Louvain(), g); # Find communities using the Louvain algorithm
julia> draw_communities(g, communities) # Draw the communities
```

Detect communities using the **K-clique Percolation Algorithm** on a
graph loaded from a csv edge list:
```julia
julia> using GraphCommunities
julia> g = load_csv_graph("path_to_your_graph.csv");
julia> compute(KClique(), g);
julia> draw_communities(g, communities) # Draw the communities
```

Detect communities using the **Label Propagation Algorithm** on the famous Karate Club Graph using **asynchronous** label updates::
```julia
julia> using GraphCommunities
julia> g = generate(KarateClub());
julia> compute(LabelPropagation(), g)
julia> draw_communities(g, communities) # Draw the communities
```

Detect communities using the **Label Propagation Algorithm** on the famous Karate Club Graph using **synchronous** label updates:
```julia
julia> using GraphCommunities
julia> g = generate(KarateClub());
julia> compute(LabelPropagation(sync=true), g)
julia> draw_communities(g, communities) # Draw the communities
```

We can also compute the **Page Rank** of each vertex (node) in the graph:
```julia
julia> using GraphCommunities
julia> g = generate(KarateClub());
julia> compute(PageRank(), g)
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
julia> g = generate(ChainedCliques(;num_cliques=2, clique_size=6))
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

## The `GraphCommunities.Experimental` Submodule
`GraphCommunities.jl` also includes a submodule for experimental graph algorithms designed by the author.

### The `enhanced_graph_kmeans` Algorithm

The `graph_kmeans` algorithm is an adaptation of the traditional K-means clustering, tailored specifically for graphs. Instead of clustering based on the distances between data points in a Euclidean space (as in traditional K-means), graph_kmeans clusters vertices based on their structural roles and positions in a graph. When the parameter `k` is not given, both `k` and the initialization **centroids** are chosen by a custom method elaborated on below.

The `enhanced_graph_kmeans` algorithm builds upon the foundational graph_kmeans method by incorporating additional stages designed to enhance the quality of clustering. Specifically, it utilizes triangle detection to densify the graph, aiding in the centroid initialization. After the graph_kmeans clustering is done, it further refines the clusters using a label propagation method.

### Rationale:

Triangle Detection & Graph Densification: Triangles (subgraphs of 3 interconnected nodes) in a graph are indicative of tight-knit communities. By identifying these triangles, we can produce a denser graph representation that encapsulates stronger communal ties. This densified graph aids in centroid initialization by biasing it towards genuine community structures.

Label Propagation Refinement: After initial clustering with graph_kmeans, there might be nodes that are better suited for a neighboring cluster due to local community structure. Label propagation leverages the majority label among a node's neighbors to iteratively refine and update the cluster assignments, leading to more coherent communities.

### Algorithm Description:

1. Triangle Detection: Identify triangles within the graph to determine tightly-knit subgraphs.
2. Graph Densification: Create a densified graph representation based on detected triangles.
3. Centroid Initialization: Use the densified graph to initialize centroids for the K-means clustering.
4. Graph K-means Clustering: Employ the graph_kmeans method to partition the graph into clusters.
5. Label Propagation: Refine the clusters from the previous step using a label propagation method to ensure nodes align with their local community structure.
6. Result: Output refined clusters that are more representative of genuine community structures in the graph.

### Example

```julia
julia> using GraphCommunities
julia> using GraphCommunities.Experimental: graph_kmeans
julia> using GraphCommunities.Experimental: enhanced_graph_kmeans
julia> g = generate(KarateClub())
julia> communities = enhanced_graph_kmeans(g)
julia> draw_communities(g, communities)
```

## Author

Randy R. Davila, PhD