
"""
    number_of_communities(communities::Vector{Int64})::Int

Calculate the number of unique communities in a graph.

This function takes a vector where each element represents the community
assignment of a node in the graph and returns the total count of unique
communities identified.

# Arguments
- `communities::Vector{Int64}`: A vector with each element representing the community
  ID assigned to a node in the graph.

# Returns
- `Int`: The number of unique communities found in the graph.

# Example
```julia
julia> community_assignments = [1, 2, 1, 3, 2, 3, 3]

julia> number_of_communities(community_assignments)
3
```
"""
function number_of_communities(communities::Vector{Int64})
    unique_communities = unique(communities)
    return length(unique_communities)
end