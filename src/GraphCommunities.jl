module GraphCommunities

using Graphs
using GraphPlot
using CSV
using Colors

include("graph-io.jl")
include("community-detection.jl")
include("visualizations.jl")

export load_csv_graph, planted_partition_graph
export graph_modularity, louvain
export plot_community_graph
export karate_club_graph

end # module