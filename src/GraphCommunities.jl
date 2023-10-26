module GraphCommunities

# ============================
# IMPORTS
# ============================

# This package builds on top of the following two packages
using Graphs
using SimpleWeightedGraphs

# Other functions from packages used in this package
using Colors: distinguishable_colors
using GraphPlot: gplot
using Random: shuffle, shuffle!
using DataStructures

# ============================
# ABSTRACT TYPES
# ============================

"""
    CommunityDetectionAlgorithm

Abstract type representing a community detection algorithm. This serves as the base type
for various community detection algorithms implemented in the package.

# Notes
All custom community detection algorithms in the package should subtype this abstract type.
See [`Louvain`](@ref), [`KClique`](@ref), etc. for concrete implementations.
"""
abstract type CommunityDetectionAlgorithm end

"""
    CommunityGraph

An abstract type representing a graph with community structure.
"""
abstract type CommunityGraph end

# ============================
# DETECTION ALGORITHMS
# ============================

# Louvain
"""
    Louvain <: CommunityDetectionAlgorithm

The Louvain algorithm for community detection in networks.

This method optimizes the modularity of partitions of the graph. It follows a greedy
optimization approach that generally operates in time \\(O(n \\log n)\\)
, making it efficient
for large-scale networks.

# Usage

```julia
communities = compute(Louvain(), graph)
```

# References

* Blondel, V. D., Guillaume, J. L., Lambiotte, R., & Lefebvre, E. (2008). Fast unfolding
of communities in large networks. Journal of Statistical Mechanics: Theory and Experiment,
2008(10), P10008.
"""
struct Louvain <: CommunityDetectionAlgorithm end

# K-Clique
"""
    KClique <: CommunityDetectionAlgorithm

The K-Clique Percolation algorithm for community detection in networks.

This method identifies communities based on the presence of `K`-clique (with `K = 3`) structures
within the graph, where a `K`-clique is a fully connected subgraph of `K` nodes. Two `K`-cliques
are adjacent if they share `K-1` nodes, and a community is defined as the union of `K`-cliques
that can be reached from each other through a series of adjacent `K`-cliques.

# Usage

```julia
communities = compute(KClique(), graph)
```

# References

* Palla, G., Derényi, I., Farkas, I., & Vicsek, T. (2005). Uncovering the overlapping community structure of complex networks in nature and society. Nature, 435(7043), 814-818.
"""
struct KClique <: CommunityDetectionAlgorithm end

# Label Propagation
"""
    LabelPropagation <: CommunityDetectionAlgorithm

The Label Propagation algorithm for community detection in networks.

The Label Propagation algorithm identifies communities based on the diffusion of labels
throughout the graph. Nodes adopt the label that is most common among their neighbors.
This process iteratively refines labels until a consensus or stable state is reached,
where nodes have predominantly the same label as their neighbors.

The algorithm can be run in either synchronous or asynchronous mode:

- **Synchronous**: All nodes update their labels simultaneously in each iteration.
- **Asynchronous**: Nodes update their labels in a random order.

# Arguments
- `synchronous::Bool`: If `true`, updates labels in synchronous mode; if `false` (default),
updates labels in asynchronous mode.
- `max_iter::Int`: Maximum number of iterations (default is 100). If the algorithm doesn't
converge within this number of iterations, it will halt and return the current vector.

# Usage

```julia
communities = compute(LabelPropagation(), graph)            # Asynchronous (default)
communities = compute(LabelPropagation(sync=true), graph)   # Synchronous
```

# References

* Raghavan, U. N., Albert, R., & Kumara, S. (2007). Near linear time algorithm to detect
community structures in large-scale networks. Physical review E, 76(3), 036106.
"""
struct LabelPropagation{SyncT <: Bool, IterT <: Int64} <: CommunityDetectionAlgorithm
    synchronous::SyncT
    max_iter::IterT
end
# Default constructor
LabelPropagation(;
    sync = false,
    max_iter = 100,
) = LabelPropagation(sync, max_iter)

# Label Propagation
"""
    FastLabelPropagation <: CommunityDetectionAlgorithm

The (Fast) Label Propagation algorithm for community detection in networks.

The Label Propagation algorithm identifies communities based on the diffusion of labels
throughout the graph. Nodes adopt the label that is most common among their neighbors.
This process iteratively refines labels until a consensus or stable state is reached,
where nodes have predominantly the same label as their neighbors.

The algorithm can be run in either synchronous or asynchronous mode:

- **Synchronous**: All nodes update their labels simultaneously in each iteration.
- **Asynchronous**: Nodes update their labels in a random order.

# Arguments
- `synchronous::Bool`: If `true`, updates labels in synchronous mode; if `false` (default),
updates labels in asynchronous mode.
- `max_iter::Int`: Maximum number of iterations (default is 100). If the algorithm doesn't
converge within this number of iterations, it will halt and return the current vector.

# Usage

```julia
communities = compute(LabelPropagation(), graph)            # Asynchronous (default)
communities = compute(LabelPropagation(sync=true), graph)   # Synchronous
```

# References

* Raghavan, U. N., Albert, R., & Kumara, S. (2007). Near linear time algorithm to detect
community structures in large-scale networks. Physical review E, 76(3), 036106.
"""
struct FastLabelPropagation{SyncT <: Bool, IterT <: Int64} <: CommunityDetectionAlgorithm
    synchronous::SyncT
    max_iter::IterT
end
# Default constructor
FastLabelPropagation(;
    sync = true,
    max_iter = 100,
) = FastLabelPropagation(sync, max_iter)

# PageRank
"""
    PageRank <: CommunityDetectionAlgorithm

PageRank is an algorithm originally designed for ranking web pages in search results.
However, it can also be used more broadly in networks to determine the importance of
nodes within a graph. The underlying principle is that more important nodes are likely
to receive more links from other nodes.

The algorithm computes a stationary distribution of a random walk on the graph where,
at each step, with probability `d`, the walker randomly chooses an outgoing link from
its current node and with probability `1 - d`, it jumps to a random node in the graph.

# Arguments
- `d::Float64`: Damping factor (default is 0.85). It represents the probability that the random walker follows an outgoing edge. Typically set between 0.85 and 0.9.
- `tol::Float64`: Tolerance for determining convergence (default is 1e-6). The algorithm stops iterating once the change between subsequent PageRank vectors is below this value.
- `max_iter::Int`: Maximum number of iterations (default is 100). If the algorithm doesn't converge within this number of iterations, it will halt and return the current vector.

# Usage

```julia
pageranks = compute(PageRank(), graph)  # Using default parameters
pageranks = compute(PageRank(d=0.9, tol=1e-7, max_iter=150), graph)
```

# References

* Page, L., Brin, S., Motwani, R., & Winograd, T. (1999). The PageRank citation ranking: Bringing order to the web. Stanford InfoLab.
"""
struct PageRank{DT <: Float64, TolT <: Float64, IterT <: Int64} <: CommunityDetectionAlgorithm
    d::DT
    tol::TolT
    max_iter::IterT
end
# Default constructor
PageRank(;d = 0.85, tol = 1e-6, max_iter = 100) = PageRank(d, tol, max_iter)

#... other algorithms in the future

# ============================
# GRAPH STRUCTURES
# ============================

# ChainedCliques
"""
    ChainedCliques <: CommunityGraph

A graph structure that represents a series of connected cliques.

# Fields
- `num_cliques::Int`: The number of cliques in the graph.
- `clique_size::Int`: The number of nodes in each clique.

# Examples
```julia
graph_info = ChainedCliques(num_cliques=5, clique_size=4)
graph = generate(graph_info)
```
"""
struct ChainedCliques <: CommunityGraph
    num_cliques::Int
    clique_size::Int
end
# Default constructor
ChainedCliques(;num_cliques = 6, clique_size = 3) = ChainedCliques(num_cliques, clique_size)

# PlantedPartition
"""
    PlantedPartition <: CommunityGraph

The `PlantedPartition` model, also known as the Stochastic Block Model (SBM),
is a probabilistic model commonly used for generating synthetic networks with
inherent community structures. This model creates a graph by partitioning nodes
into distinct communities and then adding edges between nodes based on intra-community
and inter-community probabilities.

# Arguments
- `n_communities::Int`: Number of communities or blocks in the graph.
- `nodes_per_community::Int`: Number of nodes within each community.
- `pintra::Float64`: Probability of creating an edge between two nodes within the same community. This defines the density of intra-community edges.
- `pinter::Float64`: Probability of creating an edge between two nodes from different communities. This defines the sparsity of inter-community edges.

Typically, `pintra` is set to be much larger than `pinter` to ensure dense intra-community connections and sparse inter-community connections, thereby creating discernible community structures.

# Usage

```julia
graph1 = generate(PlantedPartition())  # Using default parameters
graph2 = generate(PlantedPartition(n_communities=5, nodes_per_community=10, pintra=0.8, pinter=0.02))
```

# References

* Holland, P. W., Laskey, K. B., & Leinhardt, S. (1983). Stochastic blockmodels: First steps. Social networks, 5(2), 109-137.
"""
struct PlantedPartition <: CommunityGraph
    n_communities::Int
    nodes_per_community::Int
    pintra::Float64
    pinter::Float64
end
# Default constructor
PlantedPartition(
    ;n_communities = 4,
    nodes_per_community = 20,
    pintra = 0.75,
    pinter = 0.01
) = PlantedPartition(n_communities, nodes_per_community, pintra, pinter)

# KarateClub
"""
    KarateClub <: CommunityGraph

The `KarateClub` graph, often referred to as the "Zachary's Karate Club",
is a social network of friendships between 34 members of a karate club at
a US university in the 1970s. This dataset has become a standard benchmark
in community detection literature because of its well-documented community
structure.

The graph captures the observed friendships between the 34 members. During
the course of the study, the club split into two communities due to a conflict,
making it a valuable dataset for studying community detection algorithms.

# Usage

```julia
graph = generate(KarateClub())
```

# References

* Zachary, W. W. (1977). An information flow model for conflict and fission in small groups. Journal of anthropological research, 452-473.
"""
struct KarateClub <: CommunityGraph end

# ============================
# MODULE INCLUDES
# ============================

include("GraphIO.jl")
include("algorithms/label-propagation.jl")
include("algorithms/fast-label-propagation.jl")
include("algorithms/louvain.jl")
include("algorithms/k-clique.jl")
include("algorithms/pagerank.jl")
include("visualizations.jl")
include("graph-constructors.jl")
include("Experimental.jl")

# ============================
# EXPORTS
# ============================

export graph_modularity
export find_triangles
export compute
export draw_communities
export generate
export Louvain
export KClique
export PageRank
export LabelPropagation
export FastLabelPropagation
export ChainedCliques
export PlantedPartition
export KarateClub

end # module