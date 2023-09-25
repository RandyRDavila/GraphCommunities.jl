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
LabelPropagation(;sync=false) = LabelPropagation(sync)

#... other algorithms in the future

include("graph-io.jl")
include("community-detection.jl")
include("visualizations.jl")
include("graph-constructors.jl")

export load_csv_graph
export planted_partition_graph
export graph_modularity
export find_triangles
export community_detection
export plot_community_graph
export karate_club_graph
export chained_cliques_graph
export Louvain
export KClique
export LabelPropagation

end # module