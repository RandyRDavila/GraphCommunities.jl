module GraphCommunities

# ============================
# IMPORTS
# ============================

using Colors
using CSV
using FilePathsBase
using Graphs
using SimpleWeightedGraphs
using GraphPlot
using Random
using DataFrames

# ============================
# ABSTRACT TYPES
# ============================

"""
    CommunityDetectionAlgorithm

Abstract type representing a community detection algorithm. This serves as the base type
for various community detection algorithms implemented in the package.
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
struct Louvain <: CommunityDetectionAlgorithm end

# K-Clique
struct KClique <: CommunityDetectionAlgorithm end

# Label Propagation
struct LabelPropagation <: CommunityDetectionAlgorithm
    synchronous::Bool
end
# Default constructor
LabelPropagation(;sync = false) = LabelPropagation(sync)

# PageRank
struct PageRank <: CommunityDetectionAlgorithm
    d::Float64
    tol::Float64
    max_iter::Int
end
# Default constructor
PageRank(;d = 0.85, tol = 1e-6, max_iter = 100) = PageRank(d, tol, max_iter)

#... other algorithms in the future

# ============================
# GRAPH STRUCTURES
# ============================

# ChainedCliques
struct ChainedCliques <: CommunityGraph
    num_cliques::Int
    clique_size::Int
end
# Default constructor
ChainedCliques(;num_cliques = 6, clique_size = 3) = ChainedCliques(num_cliques, clique_size)

# PlantedPartition
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
struct KarateClub <: CommunityGraph end

# ============================
# MODULE INCLUDES
# ============================

include("GraphIO.jl")
include("community-detection.jl")
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
export ChainedCliques
export PlantedPartition
export KarateClub

end # module