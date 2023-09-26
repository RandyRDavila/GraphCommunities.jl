module GraphCommunities

# ============================
# IMPORTS
# ============================

using Colors
using CSV
using FilePathsBase
using Graphs
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
LabelPropagation(;sync = false) = LabelPropagation(sync)  # Default constructor

#... other algorithms in the future

# ============================
# GRAPH STRUCTURES
# ============================

# ChainedCliques
struct ChainedCliques <: CommunityGraph
    r::Int
    k::Int
end
ChainedCliques(;r = 6, k = 3) = ChainedCliques(r, k)  # Default constructor

# PlantedPartition
struct PlantedPartition <: CommunityGraph
    n_communities::Int
    nodes_per_community::Int
    pintra::Float64
    pinter::Float64
end
PlantedPartition(
    ;n_communities = 4,
    nodes_per_community = 20,
    pintra = 0.75,
    pinter = 0.01
) = PlantedPartition(n_communities, nodes_per_community, pintra, pinter)  # Default constructor

# KarateClub
struct KarateClub <: CommunityGraph end

# ============================
# MODULE INCLUDES
# ============================

include("GraphIO.jl")
include("community-detection.jl")
include("visualizations.jl")
include("graph-constructors.jl")

# ============================
# EXPORTS
# ============================

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