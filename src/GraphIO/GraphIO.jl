"""
    GraphIO

A module for reading and writing graphs from/to various file formats including `.csv` and `.txt`.

Provides functionality to:
- Load a graph from an edge list file (`load_edgelist`)
- Write a graph to an edge list file (`write_edgelist`)
"""
module GraphIO

using CSV
using DataFrames
using Graphs

abstract type EdgeListFormat end

struct CSVFormat <: EdgeListFormat end

struct TXTFormat <: EdgeListFormat end

"""
    determine_format(path::String) -> EdgeListFormat

Determine the file format based on the file extension.

# Arguments
- `path::String`: The file path.

# Returns
- An instance of a subtype of `EdgeListFormat` indicating the file format.
"""
function determine_format(path::String)
    endswith(path, ".csv") && return CSVFormat()
    endswith(path, ".txt") && return TXTFormat()
    return throw(ArgumentError("Unsupported file type: $(splitext(path)[2])"))
end


function validate_node(value, column::String)
    value isa Int && value > 0 || throw(ArgumentError(
        "Invalid node in $column column: $value. Needs positive integer."
    ))
end

"""
    load_edgelist(path::String, format::CSVFormat) -> SimpleGraph

Load a graph from a `.csv` edge list file.

# Arguments
- `path::String`: The path to the `.csv` file.

# Returns
- A `SimpleGraph` object constructed from the edge list.
"""
function load_edgelist(path::String, format::CSVFormat)::SimpleGraph
    # Check if file exists.
    isfile(path) || throw(ArgumentError("File path does not exist: $path"))

    # Read the file and handle potential format issues.
    edgelist = CSV.File(path)

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

"""
    load_edgelist(path::String, format::TXTFormat) -> SimpleGraph

Load a graph from a `.txt` edge list file.

# Arguments
- `path::String`: The path to the `.txt` file.

# Returns
- A `SimpleGraph` object constructed from the edge list.
"""
function load_edgelist(path::String, format::TXTFormat)::SimpleGraph
    # Check if file exists.
    isfile(path) || throw(ArgumentError("File path does not exist: $path"))

    # Initialize an array to hold the edges.
    edges = Vector{Tuple{Int, Int}}()

    # Open the file and read line by line.
    open(path, "r") do io
        for line in eachline(io)
            # Split the line by spaces or tabs.
            nodes = split(line, r"\s+")
            length(nodes) == 2 || throw(ArgumentError(
                "TXT rows need exactly two columns for source and destination."
            ))

            # Convert to integers and check for validity.
            src = parse(Int, nodes[1])
            dst = parse(Int, nodes[2])

            validate_node(src, "first")
            validate_node(dst, "second")

            push!(edges, (src, dst))
        end
    end

    return SimpleGraph(Edge.(edges))
end

"""
    load_edgelist(path::String) -> SimpleGraph

Load a graph from an edge list file (either `.csv` or `.txt`).

# Arguments
- `path::String`: The path to the edge list file.

# Returns
- A `SimpleGraph` object constructed from the edge list.
"""
function load_edgelist(path::String)::SimpleGraph
    format = determine_format(path)
    return load_edgelist(path, format)
end

"""
    write_edgelist(g::SimpleGraph, path::String, format::TXTFormat)

Write a graph to a `.txt` edge list file.

# Arguments
- `g::SimpleGraph`: The graph object.
- `path::String`: The path to save the `.txt` file.
"""
function write_edgelist(g::SimpleGraph, path::String, format::TXTFormat)
    # Extract edge list from the graph
    temp_edges = [(src(e), dst(e)) for e in edges(g)]

    # Write to TXT
    open(path, "w") do io
        for (s, d) in temp_edges
            write(io, "$s $d\n")
        end
    end
end

"""
    write_edgelist(g::SimpleGraph, path::String, format::CSVFormat)

Write a graph to a `.csv` edge list file.

# Arguments
- `g::SimpleGraph`: The graph object.
- `path::String`: The path to save the `.csv` file.
"""
function write_edgelist(g::SimpleGraph, path::String, format::CSVFormat)
    # Extract edge list from the graph
    temp_edges = [(src(e), dst(e)) for e in edges(g)]

    # Write to CSV
    CSV.write(path, DataFrame(temp_edges, [:source, :destination]))
end

"""
    write_edgelist(g::SimpleGraph, path::String)

Write a graph to an edge list file (either `.csv` or `.txt`).

# Arguments
- `g::SimpleGraph`: The graph object.
- `path::String`: The path to save the edge list file.
"""
function write_edgelist(g::SimpleGraph, path::String)
    format = determine_format(path)
    return write_edgelist(g, path, format)
end

export load_edgelist
export write_edgelist

end # module
