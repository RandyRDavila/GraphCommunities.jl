"""
    load_csv_graph(path_to_file::String) -> SimpleGraph

Load a graph from a CSV file. The CSV file should have two columns corresponding to
the source and destination of each edge.

# Arguments
- `path_to_file::String`: Path to the CSV file.

# Returns
- `SimpleGraph`: A graph constructed from the edgelist in the CSV.
"""
function load_csv_graph(path_to_file::String)::SimpleGraph
    # Check if file exists.
    isfile(path_to_file) || throw(ArgumentError("File path does not exist: $path_to_file"))

    # Try to read the file and handle potential format issues.
    try
        edgelist = CSV.File(path_to_file)
    catch e
        throw(ArgumentError("Failed reading CSV. Check format. Error: $e"))
    end

    # Check data issues.
    for row in edgelist
        # Ensure we have only two columns for each row.
        length(row) == 2 || throw(ArgumentError(
            "CSV rows need exactly two columns for source and destination."
        ))

        # Check positive integer values for node indices in columns.
        validate_node(row[1], "first")
        validate_node(row[2], "second")
    end

    return SimpleGraph(Edge.([(row[1], row[2]) for row in edgelist]))
end

function validate_node(value, column::String)
    value isa Int && value > 0 || throw(ArgumentError(
        "Invalid node in $column column: $value. Needs positive integer."
    ))
end
