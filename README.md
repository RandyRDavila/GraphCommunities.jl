# GraphCommunities.jl

[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://randyrdavila.github.io/GraphCommunities.jl/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![code style: blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)


`GraphCommunities.jl` is a Julia package designed for detecting communities within *undirected* graphs. It employs various community detection algorithms and also provides functionality for generating graphs with community structure. Currently, the package includes the following community detection algorithms:

1. The Louvain Algorithm
2. The K-Clique Percolation Algorithm with `K = 3`
3. The Label Propagation Algorithm

## Built on `Graphs.jl`

`GraphCommunities.jl` is designed to work seamlessly with the `Graphs.jl` package. All the graph structures, types, and utilities provided by `Graphs.jl` are the foundation of our package. This ensures compatibility, performance, and a familiar API for those already acquainted with `Graphs.jl`.

If you're new to Graphs.jl, it's recommended to check out their [documentation](https://github.com/JuliaGraphs/Graphs.jl) to get a deeper understanding of the graph structures and operations you can leverage.

## Installation

To add the `GraphCommunities` package to your Julia environment, you can use the Julia package manager. In the Julia REPL, enter the package manager by pressing `]`, then run:

```julia
(@v1.x) pkg> add https://github.com/RandyRDavila/GraphCommunities.jl.git
```

After the package is added, you can use it in your Julia sessions with:

```julia
julia> using GraphCommunities
```

**Author**

Randy R. Davila, PhD

* Lecturer of Computational Applied Mathematics & Operations Research at Rice University.
* Software Engineer at RelationalAI.