using Test
using GraphCommunities  # assuming you named your main module this way
using Graphs

@testset "GraphCommunities Tests" begin

    @testset "karate_club_graph" begin
        g = karate_club_graph()
        @test nv(g) == 33
    end

    @testset "louvain" begin
        g = SimpleGraph(3)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        add_edge!(g, 3, 1)
        communities = louvain(g)
        @test length(communities) == 3
    end

    @testset "planted_partition_graph" begin
        g = planted_partition_graph(2, 3, 0.5, 0.1)
        @test nv(g) == 6
    end

end