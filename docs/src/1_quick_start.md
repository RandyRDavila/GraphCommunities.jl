# Quick Start Guide
Start by importing the required modules:
```julia
julia> using GraphCommunities

julia> using GraphPlot # For visualizing the generated graphs
```
## Creating Graphs with Community Structure

A **planted partition graph** (also known as a **stochastic block model**) is a probabilistic graph model often used to generate synthetic networks with community structures for testing algorithms, especially community detection methods:
```julia
julia> g = generate(PlantedPartition());

julia> gplot(g)
```

Another graph with community structure can be obtained by connecting `num_cliques` cliques, each with `clique_size` nodes, in a path like manor:
```julia
julia> g = generate(ChainedCliques(;num_cliques=8, clique_size=5));

julia> gplot(g)
```

This package also includes the well-known **Karate Club Graph** as an example dataset to test algorithms on:
```julia
julia> g = generate(KarateClub());

julia> gplot(g)
```

## Community Detection Algorithms

Detect communities using the **Louvain Algorithm** on a
graph loaded from a csv edge list:
```julia
julia> g = load_csv_graph("path_to_your_graph.csv");

julia> communities = compute(Louvain(), g); # Find communities using the Louvain algorithm

julia> draw_communities(g, communities) # Draw the communities
```

Detect communities using the **K-clique Percolation Algorithm** on a
graph loaded from a csv edge list:
```julia
julia> g = load_csv_graph("path_to_your_graph.csv");

julia> compute(KClique(), g);

julia> draw_communities(g, communities) # Draw the communities
```

Detect communities using the **Label Propagation Algorithm** on the famous Karate Club Graph using **asynchronous** label updates::
```julia
julia> g = generate(KarateClub());

julia> compute(LabelPropagation(), g)

julia> draw_communities(g, communities) # Draw the communities
```

Detect communities using the **Label Propagation Algorithm** on the famous Karate Club Graph using **synchronous** label updates:
```julia
julia> g = generate(KarateClub());

julia> compute(LabelPropagation(sync=true), g)

julia> draw_communities(g, communities) # Draw the communities
```

We can also compute the **Page Rank** of each vertex (node) in the graph:
```julia
julia> g = generate(KarateClub());

julia> compute(PageRank(), g)
```
### Drawing Communities

After detecting the communities, you can visualize them using the `draw_communities` function:
```julia
julia> draw_communities(g, communities) # Draw the communities
```

## Saving Graphs and Loading Graphs

You can also save your graphs in various formats by using the `GraphIO` submodule:
```julia
julia> using GraphCommunities.GraphIO: write_edgelist

julia> g = generate(ChainedCliques(;num_cliques=2, clique_size=6))

julia> write_edgelist(g, "test-edgelist.csv") # write to a .csv file

julia> write_edgelist(g, "test-edgelist.txt") # write to a text file
```

Similarily, you can use this submodule to load graphs:
```julia
julia> using GraphCommunities.GraphIO: load_edgelist

julia> g1 = load_edgelist("test-edgelist.csv")

julia> g2 = load_edgelist("test-edgelist.txt")
```