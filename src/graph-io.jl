"""
    load_csv_graph(path_to_file::String) -> SimpleGraph

Load a graph from a CSV file. The CSV file should have two columns corresponding to the source
and destination of each edge.

# Arguments
- `path_to_file::String`: Path to the CSV file.

# Returns
- `SimpleGraph`: A graph constructed from the edgelist in the CSV.
"""
function load_csv_graph(path_to_file::String)
    edgelist = CSV.File(path_to_file)
    return SimpleGraph(Edge.([(row[1], row[2]) for row in edgelist]))
end