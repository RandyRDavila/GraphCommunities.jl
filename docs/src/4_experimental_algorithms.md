
# Experimental Algorithms
`GraphCommunities.jl` also includes a submodule for experimental graph algorithms designed by the author.

## The `enhanced_graph_kmeans` Algorithm

The `graph_kmeans` algorithm is an adaptation of the traditional K-means clustering, tailored specifically for graphs. Instead of clustering based on the distances between data points in a Euclidean space (as in traditional K-means), graph_kmeans clusters vertices based on their structural roles and positions in a graph. When the parameter `k` is not given, both `k` and the initialization **centroids** are chosen by a custom method elaborated on below.

The `enhanced_graph_kmeans` algorithm builds upon the foundational graph_kmeans method by incorporating additional stages designed to enhance the quality of clustering. Specifically, it utilizes triangle detection to densify the graph, aiding in the centroid initialization. After the graph_kmeans clustering is done, it further refines the clusters using a label propagation method.

## Rationale:

Triangle Detection & Graph Densification: Triangles (subgraphs of 3 interconnected nodes) in a graph are indicative of tight-knit communities. By identifying these triangles, we can produce a denser graph representation that encapsulates stronger communal ties. This densified graph aids in centroid initialization by biasing it towards genuine community structures.

Label Propagation Refinement: After initial clustering with graph_kmeans, there might be nodes that are better suited for a neighboring cluster due to local community structure. Label propagation leverages the majority label among a node's neighbors to iteratively refine and update the cluster assignments, leading to more coherent communities.

## Algorithm Description:

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