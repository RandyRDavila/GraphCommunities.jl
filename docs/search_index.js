var documenterSearchIndex = {"docs":
[{"location":"3_graph_communities/#Community-Detection-Algorithms","page":"Community Detection Algorithms","title":"Community Detection Algorithms","text":"","category":"section"},{"location":"3_graph_communities/","page":"Community Detection Algorithms","title":"Community Detection Algorithms","text":"The primary function that this package includes is the compute function which implements different algorithms as methods using Julia's multiple dispatch.","category":"page"},{"location":"3_graph_communities/","page":"Community Detection Algorithms","title":"Community Detection Algorithms","text":"compute","category":"page"},{"location":"3_graph_communities/#GraphCommunities.compute","page":"Community Detection Algorithms","title":"GraphCommunities.compute","text":"compute(algo::Louvain, g::SimpleGraph)\n\nDetect communities in a graph g using the Louvain algorithm, a method based on modularity optimization.\n\nThe algorithm consists of two phases that are repeated iteratively:\n\nLocal Phase: Each node is moved to the community that yields the highest modularity gain.\nAggregation Phase: A new graph is constructed where nodes represent communities from the previous phase.\n\nThese phases are repeated until the modularity ceases to increase significantly.\n\nArguments\n\nalgo::Louvain: Indicates that the Louvain algorithm should be used for community detection.\ng::SimpleGraph: The graph on which to detect communities.\n\nReturns\n\nA dictionary mapping node IDs in the original graph to their respective community IDs.\n\nExample\n\njulia> using GraphCommunities\n\njulia> g = generate(PlantedPartition())\n\njulia> compute(Louvain(), g)\n\nNotes\n\nThe algorithm may not return the same community structure on different runs due to its heuristic nature. However, the structures should be reasonably similar and of comparable quality.\n\n\n\n\n\ncompute(algo::KClique, g::SimpleGraph)::Dict{Int, Int}\n\nDetect communities in a graph g using the K-Clique algorithm.\n\nThe function first finds triangles (or 3-cliques) in the graph. It then constructs a k-clique graph where nodes represent triangles, and edges indicate overlap. The connected components of this k-clique graph give the communities in the original graph.\n\nArguments\n\nalgo::KClique: Indicates that the K-Clique algorithm should be used for community detection.\ng::SimpleGraph: The graph on which to detect communities.\n\nReturns\n\nA dictionary mapping node IDs in the original graph to their respective community IDs.\n\nExample\n\njulia> using GraphCommunities\n\njulia> g = generate(KarateClub())\n\njulia> compute(KClique(), g)\n\nNotes\n\nCurrently, the implementation is restricted to 3-cliques (triangles). Future versions might support other clique sizes.\n\n\n\n\n\ncompute(algo::LabelPropagation, g::SimpleGraph)::Dict{Int, Int}\n\nDetect communities in a graph g using the Label Propagation algorithm.\n\nThe algorithm works by assigning each node a unique label. Then, in each iteration, each node adopts the label that is most frequent among its neighbors. The algorithm terminates when no node changes its label.\n\nArguments\n\nalgo::LabelPropagation: Indicates that the Label Propagation algorithm should be used for community detection.\ng::SimpleGraph: The graph on which to detect communities.\n\nReturns\n\nA dictionary mapping node IDs in the original graph to their respective community IDs.\n\nExample\n\njulia> using GraphCommunities\n\njulia> g = generate(KarateClub())\n\njulia> compute(LabelPropagation(), g)\n\nNotes\n\nThe algorithm may not return the same community structure on different runs due to its heuristic nature. However, the structures should be reasonably similar and of comparable quality.\n\n\n\n\n\ncompute(algo::PageRank, g::AbstractGraph)::Vector{Float64}\n\nCompute the PageRank values of the nodes in graph g using the PageRank algorithm.\n\nArguments\n\nalgo::PageRank: The PageRank algorithm configuration object. This should contain properties like damping factor (d), maximum number of iterations (max_iter), and tolerance (tol).\ng::AbstractGraph: The graph for which to compute the PageRank. This can be a simple graph, directed graph, or a weighted version of these.\n\nReturns\n\nA vector of Float64 where each entry represents the PageRank value of the corresponding node in the graph.\n\nDetails\n\nThe function uses the power iteration method to compute the PageRank values. If the graph is weighted, the weights of the edges are taken into account while calculating the rank.\n\nThe algorithm iteratively refines the PageRank values until either the maximum number of iterations is reached or the values converge within the specified tolerance.\n\nExample\n\njulia> g = generate(PlantedPartition())\n\njulia> algo = PageRank(d=0.85, max_iter=100, tol=1e-6)\n\njulia> compute(algo, g)\n\n\n\n\n\n","category":"function"},{"location":"2_graph_generators/#Graph-Generators","page":"Graph Generators","title":"Graph Generators","text":"","category":"section"},{"location":"2_graph_generators/","page":"Graph Generators","title":"Graph Generators","text":"The primary function for creating graphs to test community detection algorithms on is the generate function which implements different constructions as methods using Julia's multiple dispatch.","category":"page"},{"location":"2_graph_generators/","page":"Graph Generators","title":"Graph Generators","text":"generate\ndraw_communities","category":"page"},{"location":"2_graph_generators/#GraphCommunities.generate","page":"Graph Generators","title":"GraphCommunities.generate","text":"generate(structure::ChainedCliques)::SimpleGraph\n\nCreate a graph consisting of structure.r cliques, each of size structure.k, chained together.\n\nstructure.r represents the number of cliques.\nstructure.k represents the size of each clique.\n\nReturns a SimpleGraph with the chained cliques.\n\n\n\n\n\ngenerate(structure::PlantedPartition)::SimpleGraph\n\nGenerate a graph based on the planted partition model.\n\nstructure.n_communities is the number of communities.\nstructure.nodes_per_community denotes the number of nodes per community.\nstructure.pintra is the probability of an edge within a community.\nstructure.pinter is the probability of an edge between communities.\n\nReturns a SimpleGraph constructed based on the planted partition model.\n\n\n\n\n\ngenerate(structure::KarateClub)::SimpleGraph\n\nConstruct the famous Zachary's Karate Club graph. This graph represents the friendships between the 34 members of a karate club studied by Wayne W. Zachary in 1977.\n\nReturns a SimpleGraph representing the Karate Club network.\n\n\n\n\n\n","category":"function"},{"location":"2_graph_generators/#GraphCommunities.draw_communities","page":"Graph Generators","title":"GraphCommunities.draw_communities","text":"draw_communities(g::AbstractGraph, communities::Dict)\n\nDraw the graph g with nodes colored based on their community assignments.\n\nArguments\n\ng::AbstractGraph: The input graph.\ncommunities::Dict: A dictionary mapping each vertex to its community.\n\nReturns\n\nA plot with nodes colored based on their community.\n\nNote\n\nThis function will only work if each node in the graph is assigned to a community.\n\n\n\n\n\n","category":"function"},{"location":"4_experimental_algorithms/#The-Experimental-Submodule","page":"The Experimental Submodule","title":"The Experimental Submodule","text":"","category":"section"},{"location":"4_experimental_algorithms/","page":"The Experimental Submodule","title":"The Experimental Submodule","text":"GraphCommunities.jl also includes a submodule for experimental graph algorithms designed by the author.","category":"page"},{"location":"4_experimental_algorithms/#The-enhanced_graph_kmeans-Algorithm","page":"The Experimental Submodule","title":"The enhanced_graph_kmeans Algorithm","text":"","category":"section"},{"location":"4_experimental_algorithms/","page":"The Experimental Submodule","title":"The Experimental Submodule","text":"The graph_kmeans algorithm is an adaptation of the traditional K-means clustering, tailored specifically for graphs. Instead of clustering based on the distances between data points in a Euclidean space (as in traditional K-means), graph_kmeans clusters vertices based on their structural roles and positions in a graph. When the parameter k is not given, both k and the initialization centroids are chosen by a custom method elaborated on below.","category":"page"},{"location":"4_experimental_algorithms/","page":"The Experimental Submodule","title":"The Experimental Submodule","text":"The enhanced_graph_kmeans algorithm builds upon the foundational graphkmeans method by incorporating additional stages designed to enhance the quality of clustering. Specifically, it utilizes triangle detection to densify the graph, aiding in the centroid initialization. After the graphkmeans clustering is done, it further refines the clusters using a label propagation method.","category":"page"},{"location":"4_experimental_algorithms/#Rationale:","page":"The Experimental Submodule","title":"Rationale:","text":"","category":"section"},{"location":"4_experimental_algorithms/","page":"The Experimental Submodule","title":"The Experimental Submodule","text":"Triangle Detection & Graph Densification: Triangles (subgraphs of 3 interconnected nodes) in a graph are indicative of tight-knit communities. By identifying these triangles, we can produce a denser graph representation that encapsulates stronger communal ties. This densified graph aids in centroid initialization by biasing it towards genuine community structures.","category":"page"},{"location":"4_experimental_algorithms/","page":"The Experimental Submodule","title":"The Experimental Submodule","text":"Label Propagation Refinement: After initial clustering with graph_kmeans, there might be nodes that are better suited for a neighboring cluster due to local community structure. Label propagation leverages the majority label among a node's neighbors to iteratively refine and update the cluster assignments, leading to more coherent communities.","category":"page"},{"location":"4_experimental_algorithms/#Algorithm-Description:","page":"The Experimental Submodule","title":"Algorithm Description:","text":"","category":"section"},{"location":"4_experimental_algorithms/","page":"The Experimental Submodule","title":"The Experimental Submodule","text":"Triangle Detection: Identify triangles within the graph to determine tightly-knit subgraphs.\nGraph Densification: Create a densified graph representation based on detected triangles.\nCentroid Initialization: Use the densified graph to initialize centroids for the K-means clustering.\nGraph K-means Clustering: Employ the graph_kmeans method to partition the graph into clusters.\nLabel Propagation: Refine the clusters from the previous step using a label propagation method to ensure nodes align with their local community structure.\nResult: Output refined clusters that are more representative of genuine community structures in the graph.","category":"page"},{"location":"4_experimental_algorithms/#Example","page":"The Experimental Submodule","title":"Example","text":"","category":"section"},{"location":"4_experimental_algorithms/","page":"The Experimental Submodule","title":"The Experimental Submodule","text":"julia> using GraphCommunities\n\njulia> using GraphCommunities.Experimental: graph_kmeans\n\njulia> using GraphCommunities.Experimental: enhanced_graph_kmeans\n\njulia> g = generate(KarateClub())\n\njulia> communities = enhanced_graph_kmeans(g)\n\njulia> draw_communities(g, communities)","category":"page"},{"location":"1_quick_start/#Quick-Start-Guide","page":"Quick Start Guide","title":"Quick Start Guide","text":"","category":"section"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"Start by importing the required modules:","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> using GraphCommunities\n\njulia> using GraphPlot: gplot # For visualizing the generated graphs","category":"page"},{"location":"1_quick_start/#Creating-Graphs-with-Community-Structure","page":"Quick Start Guide","title":"Creating Graphs with Community Structure","text":"","category":"section"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"A planted partition graph (also known as a stochastic block model) is a probabilistic graph model often used to generate synthetic networks with community structures for testing algorithms, especially community detection methods:","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> g = generate(PlantedPartition());\n\njulia> gplot(g)","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"Another graph with community structure can be obtained by connecting num_cliques cliques, each with clique_size nodes, in a path like manor:","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> g = generate(ChainedCliques(;num_cliques=8, clique_size=5));\n\njulia> gplot(g)","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"This package also includes the well-known Karate Club Graph as an example dataset to test algorithms on:","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> g = generate(KarateClub());\n\njulia> gplot(g)","category":"page"},{"location":"1_quick_start/#Community-Detection-Algorithms","page":"Quick Start Guide","title":"Community Detection Algorithms","text":"","category":"section"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"Detect communities using the Louvain Algorithm on a graph loaded from a csv edge list:","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> g = load_csv_graph(\"path_to_your_graph.csv\");\n\njulia> communities = compute(Louvain(), g); # Find communities using the Louvain algorithm\n\njulia> draw_communities(g, communities) # Draw the communities","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"Detect communities using the K-clique Percolation Algorithm on a graph loaded from a csv edge list:","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> g = load_csv_graph(\"path_to_your_graph.csv\");\n\njulia> compute(KClique(), g);\n\njulia> draw_communities(g, communities) # Draw the communities","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"Detect communities using the Label Propagation Algorithm on the famous Karate Club Graph using asynchronous label updates::","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> g = generate(KarateClub());\n\njulia> compute(LabelPropagation(), g)\n\njulia> draw_communities(g, communities) # Draw the communities","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"Detect communities using the Label Propagation Algorithm on the famous Karate Club Graph using synchronous label updates:","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> g = generate(KarateClub());\n\njulia> compute(LabelPropagation(sync=true), g)\n\njulia> draw_communities(g, communities) # Draw the communities","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"We can also compute the Page Rank of each vertex (node) in the graph:","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> g = generate(KarateClub());\n\njulia> compute(PageRank(), g)","category":"page"},{"location":"1_quick_start/#Drawing-Communities","page":"Quick Start Guide","title":"Drawing Communities","text":"","category":"section"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"After detecting the communities, you can visualize them using the draw_communities function:","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> draw_communities(g, communities) # Draw the communities","category":"page"},{"location":"1_quick_start/#Saving-Graphs-and-Loading-Graphs","page":"Quick Start Guide","title":"Saving Graphs and Loading Graphs","text":"","category":"section"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"You can also save your graphs in various formats by using the GraphIO submodule:","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> using GraphCommunities.GraphIO: write_edgelist\n\njulia> g = generate(ChainedCliques(;num_cliques=2, clique_size=6))\n\njulia> write_edgelist(g, \"test-edgelist.csv\") # write to a .csv file\n\njulia> write_edgelist(g, \"test-edgelist.txt\") # write to a text file","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"Similarily, you can use this submodule to load graphs:","category":"page"},{"location":"1_quick_start/","page":"Quick Start Guide","title":"Quick Start Guide","text":"julia> using GraphCommunities.GraphIO: load_edgelist\n\njulia> g1 = load_edgelist(\"test-edgelist.csv\")\n\njulia> g2 = load_edgelist(\"test-edgelist.txt\")","category":"page"},{"location":"#Welcome-to-GraphCommunities.jl","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"","category":"section"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"GraphCommunities.jl is a Julia package that implements community detection algorithms on AbstractGraph types from Graphs.jl and SimpleWeightedGraphs.jl. It employs various community detection algorithms and also provides functionality for generating graphs with community structure. Currently, the package includes the following community detection algorithms:","category":"page"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"The Louvain Algorithm\nThe K-Clique Percolation Algorithm with K = 3\nThe Label Propagation Algorithm","category":"page"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"GraphCommunities.jl is designed to work seamlessly with the Graphs.jl package. All the graph structures, types, and utilities provided by Graphs.jl are the foundation of our package. This ensures compatibility, performance, and a familiar API for those already acquainted with Graphs.jl.","category":"page"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"If you're new to Graphs.jl, it's recommended to check out their documentation to get a deeper understanding of the graph structures and operations you can leverage.","category":"page"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"Finally, GraphCommunities.jl also has built in functionality for generating graphs with community like structure.","category":"page"},{"location":"#Installation","page":"Welcome to GraphCommunities.jl","title":"Installation","text":"","category":"section"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"To add the GraphCommunities package to your Julia environment, you can use the Julia package manager. In the Julia REPL, enter the package manager by pressing ], then run:","category":"page"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"(@v1.x) pkg> add https://github.com/RandyRDavila/GraphCommunities.jl.git","category":"page"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"After the package is added, you can use it in your Julia sessions with:","category":"page"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"using GraphCommunities","category":"page"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"Author","category":"page"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"Randy R. Davila, PhD","category":"page"},{"location":"","page":"Welcome to GraphCommunities.jl","title":"Welcome to GraphCommunities.jl","text":"Lecturer of Computational Applied Mathematics & Operations Research at Rice University.\nSoftware Engineer at RelationalAI.","category":"page"}]
}
