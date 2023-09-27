module Experimental

using Graphs
using Random
using CSV
using DataFrames

"""
    new_find_triangles(G::AbstractGraph)

Find all triangles (i.e., cycles of length 3) in graph `G` without relying on external libraries.

# Arguments
- `G::AbstractGraph`: The input graph.

# Returns
- A vector of vertex triplets, where each triplet represents the vertices of a triangle.
"""
function new_find_triangles(G::AbstractGraph)
    triangles = []

    for v in vertices(G)
        neighbors_v = neighbors(G, v)

        for w in neighbors_v
            if w > v  # This check ensures each triangle is found only once
                common_neighbors = intersect(neighbors_v, neighbors(G, w))

                for u in common_neighbors
                    if u > w  # This check ensures each triangle is found only once
                        push!(triangles, sort([v, w, u]))
                    end
                end
            end
        end
    end

    return triangles
end

"""
    dense_clique_graph(G::AbstractGraph, triangles::Vector{Set{Int}})

Create a dense-clique graph based on a given graph `G` and its triangles.
In the resulting graph, nodes correspond to the triangles of `G`,
and two nodes are adjacent if their corresponding triangles in `G` share at least one vertex.

# Arguments
- `G::AbstractGraph`: The input graph.
- `triangles::Vector{Set{Int}}`: A list of triangles from `G`.

# Returns
- A new graph representing the dense-clique graph.
"""
function dense_clique_graph(G::AbstractGraph, triangles)
    T = SimpleGraph(length(triangles))
    for i in eachindex(triangles)
        for j in (i+1):length(triangles)
            if length(intersect(triangles[i], triangles[j])) == 2
                add_edge!(T, i, j)
            end
        end
    end
    return T
end

"""
    get_k_and_centroids(G::AbstractGraph, T::AbstractGraph, triangles::Vector{Vector{Int}})

Determine the optimal number of clusters (k) and the initial centroids for the graph k-means based on the dense-clique graph.

# Arguments
- `G::AbstractGraph`: The original input graph.
- `T::AbstractGraph`: The dense-clique graph derived from `G`.
- `triangles::Vector{Vector{Int}}`: A list of triangles from `G`.

# Returns
- A tuple containing:
  * The number of clusters (k).
  * A list of initial centroids.
"""
function get_k_and_centroids(G::AbstractGraph, T::AbstractGraph, triangles)
    components = connected_components(T)
    k = length(components)
    centroids = [rand(triangles[comp[1]]) for comp in components]
    return k, centroids
end


"""
    graph_kmeans(G::AbstractGraph, k::Int, centroids::Vector{Set{Int}})

Perform the graph k-means clustering algorithm to find communities in the graph `G`.

# Arguments
- `G::AbstractGraph`: The input graph.
- `k::Int`: The number of desired clusters (communities).
- `centroids::Vector{Set{Int}}`: Initial centroids for the k-means clustering.

# Returns
- A list of clusters, where each cluster is represented by a set of vertices.
"""
function graph_kmeans(g::AbstractGraph, k::Int; max_iters=100, centroids=[])

    nv(g) < k && throw(ArgumentError("k must be less than the number of nodes in the graph"))

    if isempty(centroids)
        centroids = randperm(nv(g))[1:k]
    end

    previous_assignments = Dict{Int,Int}()
    assignments = Dict{Int,Int}()

    for _ in 1:max_iters
        # Step 2: Assign each node to the nearest centroid
        for v in vertices(g)
            distances = [dijkstra_shortest_paths(g, v).dists[centroid] for centroid in centroids]
            assignments[v] = centroids[argmin(distances)]
        end

        # Check for convergence
        if assignments == previous_assignments
            break
        end
        previous_assignments = copy(assignments)

        # Step 3: Compute new centroids (medoids)
        for centroid in centroids
            members = [v for (v, c) in pairs(assignments) if c == centroid]
            if isempty(members)
                continue
            end
            avg_dists = [sum(dijkstra_shortest_paths(g, v).dists[m] for m in members) for v in members]
            centroids[findfirst(x -> x == centroid, centroids)] = members[argmin(avg_dists)]
        end
    end

    return assignments
end

"""
    graph_kmeans(g::AbstractGraph; max_iters=100)

Perform the graph k-means clustering algorithm to find communities in the graph `g` using the dense-clique approach for initial cluster determination.

# Arguments
- `g::AbstractGraph`: The input graph.
- `max_iters::Int=1000`: The maximum number of iterations for the k-means algorithm.

# Returns
- A dictionary mapping each vertex in `g` to its respective cluster.
"""
function graph_kmeans(g::AbstractGraph; max_iters=1000)
    triangles = new_find_triangles(g)
    g2 = dense_clique_graph(g, triangles)
    (k, centroids) = get_k_and_centroids(g, g2, triangles)
    return graph_kmeans(g, k; max_iters=max_iters, centroids=centroids)
end

function label_propagation_update(
    G::AbstractGraph,
    initial_assignments::Dict{Int,Int},
    synchronous=false
)
    assignments = copy(initial_assignments)
    updated_assignments = copy(assignments)

    change = true
    while change
        change = false
        for v in vertices(G)
            neighbor_labels = [assignments[u] for u in neighbors(G, v)]

            # Count the occurrences of each label among the node's neighbors
            label_counts = Dict{Int,Int}()
            for label in neighbor_labels
                label_counts[label] = get(label_counts, label, 0) + 1
            end

            # Find the label(s) with the maximum count
            max_count = maximum(values(label_counts))
            max_labels = [label for label in keys(label_counts) if label_counts[label] == max_count]

            # If multiple labels are most common, choose one randomly
            new_label = rand(max_labels)

            if new_label != assignments[v]
                updated_assignments[v] = new_label
                change = true

                # If asynchronous, immediately update the assignments dictionary
                if !synchronous
                    assignments[v] = new_label
                end
            end
        end

        if synchronous
            assignments = copy(updated_assignments)
        end
    end

    return assignments
end

function enhanced_graph_kmeans(
    g::AbstractGraph;
    max_iters=100,
    synchronous=false
)
    triangles = new_find_triangles(g)
    g2 = dense_clique_graph(g, triangles)
    (k, centroids) = get_k_and_centroids(g, g2, triangles)
    assignments = graph_kmeans(g, k; max_iters=max_iters, centroids=centroids)

    # Apply the label propagation update (either synchronous or asynchronous)
    return label_propagation_update(g, assignments, synchronous)
end

function movies_graph()
    # Fetching and loading the data
    url = "https://raw.githubusercontent.com/katie-truong/Jupyter/master/movie_metadata.csv"
    data = DataFrame(CSV.File(download(url)))
    # Get a list of unique actors and directors
    actors = unique(vcat(data[:, :actor_1_name], data[:, :actor_2_name], data[:, :actor_3_name]))
    directors = unique(data[:, :director_name])
    all_people = vcat(directors, actors)

    people_to_index = Dict(all_people .=> 1:length(all_people))

    # Create a graph with a vertex for each person (actor/director)
    g = SimpleGraph(length(all_people))

    for i in 1:nrow(data)
        director = data[i, :director_name]
        actors_in_movie = [data[i, :actor_1_name], data[i, :actor_2_name], data[i, :actor_3_name]]

        for actor in actors_in_movie
            if !isnothing(people_to_index[director]) && !isnothing(people_to_index[actor])
                add_edge!(g, people_to_index[director], people_to_index[actor])
            end
        end
    end
    return g, all_people
end


export graph_kmeans
export enhanced_graph_kmeans
export movies_graph

end # module