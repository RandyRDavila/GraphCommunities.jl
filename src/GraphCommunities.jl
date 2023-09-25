module GraphCommunities

using Graphs
using GraphPlot
using CSV
using Colors
using Random

"""
    CommunityDetectionAlgorithm

Abstract type representing a community detection algorithm. This serves as the base type
for various community detection algorithms implemented in the package.
"""
abstract type CommunityDetectionAlgorithm end

"""
    Louvain <: CommunityDetectionAlgorithm

Type representing the Louvain algorithm for community detection. Use this when you want
to perform community detection using the Louvain method.

# Usage

```julia
julia> community_detection(graph, Louvain())
```
"""
struct Louvain <: CommunityDetectionAlgorithm end

"""
KClique <: CommunityDetectionAlgorithm

Type representing the K-Clique algorithm for community detection. Use this when you
want to perform community detection based on cliques of size K.

# Usage

```julia
julia> community_detection(graph, KClique())
```
"""
struct KClique <: CommunityDetectionAlgorithm end

"""
    LabelPropagation <: CommunityDetectionAlgorithm

Type representing the Label Propagation algorithm for community detection. Use this when you want
to perform community detection using the Label Propagation method.

# Usage

```julia
julia> community_detection(graph, LabelPropagation())
```
"""
struct LabelPropagation <: CommunityDetectionAlgorithm
    synchronous::Bool
end

# Default constructor sets asynchronous as the default method.
LabelPropagation(;sync = false) = LabelPropagation(sync)

#... other algorithms in the future

"""
    CommunityGraph

An abstract type representing a graph with community structure.
"""
abstract type CommunityGraph end

# Subtypes for specific graph constructors

"""
    ChainedCliques <: CommunityGraph

A representation of a graph constructed by chaining together cliques.

# Fields
- `r::Int`: The number of cliques.
- `k::Int`: The number of nodes in each clique.

# Description
The graph is obtained by starting with `r` cliques each of `k` nodes,
and then chaining them together by attaching one node from each clique to the next.
"""
struct ChainedCliques <: CommunityGraph
    r::Int
    k::Int
end

# Default constructor sets asynchronous as the default method.
ChainedCliques(;r = 6, k = 3) = ChainedCliques(r, k)

"""
    PlantedPartition <: CommunityGraph

A representation of a graph based on the planted partition model.

# Fields
- `n_communities::Int`: Number of communities.
- `nodes_per_community::Int`: Number of nodes per community.
- `pintra::Float64`: Probability of an edge within a community.
- `pinter::Float64`: Probability of an edge between communities.

# Description
In the planted partition model, nodes within the same community are connected with a probability `pintra`,
while nodes from different communities are connected with a probability `pinter`.
"""
struct PlantedPartition <: CommunityGraph
    n_communities::Int
    nodes_per_community::Int
    pintra::Float64
    pinter::Float64
end

# Default constructor sets asynchronous as the default method.
PlantedPartition(
    ;n_communities = 4,
    nodes_per_community = 20,
    pintra = 0.75,
    pinter = 0.01
) = PlantedPartition(n_communities, nodes_per_community, pintra, pinter)

"""
    KarateClub <: CommunityGraph

A representation of Zachary's Karate Club graph.

# Description
This graph is based on a social network of friendships between 34 members of a karate club at a US university in the 1970s.
The dataset is commonly used in the study of community detection and graph algorithms.
"""
struct KarateClub <: CommunityGraph end

include("graph-io.jl")
include("community-detection.jl")
include("visualizations.jl")
include("graph-constructors.jl")

export load_csv_graph
export graph_modularity
export find_triangles
export community_detection
export draw_communities
export generate
export Louvain
export KClique
export LabelPropagation
export ChainedCliques
export PlantedPartition
export KarateClub

end # module