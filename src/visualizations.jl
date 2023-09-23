"""
    plot_community_graph(g::AbstractGraph, communities::Dict)

Plot a graph with nodes colored based on their community assignments.

# Arguments
- `g::AbstractGraph`: The input graph.
- `communities::Dict`: A dictionary mapping each vertex to its community.

# Returns
- A plot with nodes colored based on their community.

# Note
This function will only work if each node in the graph is assigned to a community.
"""
function plot_community_graph(g::AbstractGraph, communities::Dict)
    # Map each unique community to a color
    unique_communities = unique(values(communities))
    colors = distinguishable_colors(length(unique_communities))

    community_to_color = Dict(
            unique_communities[i] => colors[i] for i in eachindex(unique_communities)
        )
    node_colors = [community_to_color[communities[v]] for v in vertices(g)]

    # Plot
    gplot(g, nodefillc=node_colors)
end

"""
    generate_js_code(g::AbstractGraph)

Generate an HTML string embedding a visual representation of the graph `g` using the Cytoscape JS library.
"""
function generate_js_code(g::AbstractGraph)
    nodes = [Dict("data" => Dict("id" => v)) for v in Graphs.vertices(g)]
    edges = [Dict("data" => Dict("source" => e.src, "target" => e.dst)) for e in Graphs.edges(g)]

    nodes_js = JSON.json(nodes)
    edges_js = JSON.json(edges)

    return """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Interactive Network</title>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.18.1/cytoscape.min.js"></script>
    </head>
    <body>
        <div id="cy" style="width: 100%; height: 800px;"></div>
        <script>
            var cy = cytoscape({
                container: document.getElementById('cy'),
                elements: {
                    nodes: $nodes_js,
                    edges: $edges_js
                },
                style: [{
                    selector: 'node',
                    style: {
                        'background-color': 'blue',
                        'label': 'data(id)'
                    }
                }, {
                    selector: 'edge',
                    style: {
                        'width': 3,
                        'line-color': '#ccc',
                        'target-arrow-color': '#ccc',
                        'target-arrow-shape': 'triangle'
                    }
                }],
                layout: {
                    name: 'cose'
                }
            });
        </script>
    </body>
    </html>
    """
end

"""
    interactive_graph(g::AbstractGraph)

Draw the graph `g` in a Blink window.
"""
function interactive_graph(g::AbstractGraph)
    # Generate the JS code for the graph
    js_code = generate_js_code(g)

    # Create a temporary file
    temp_filename = "temp_graph_$(randstring(8)).html"

    # Write the JS code to the temporary file
    open(temp_filename, "w") do f
        write(f, js_code)
    end

    # Open the temporary file in a Blink window
    w = Window()
    loadurl(w, "file://$(pwd())/$(temp_filename)")

    # Optionally, delete the temporary file after a small delay
    @async begin
        sleep(5)  # wait for 5 seconds
        rm(temp_filename)
    end

    return w
end
