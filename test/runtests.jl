using Test
using GraphCommunities  # assuming you named your main module this way
using Graphs

@testset "GraphCommunities.jl Tests" begin

    @testset "generate: KarateClub()" begin
        g = generate(KarateClub())
        @test nv(g) == 34
    end

    @testset "generate: PlantedPartition()" begin
        g = generate(PlantedPartition(2, 3, 0.5, 0.1))
        @test nv(g) == 6
    end

    @testset "community_detection: Louvain()" begin
        g = SimpleGraph(3)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        add_edge!(g, 3, 1)
        communities = community_detection(g, Louvain())

        @test length(communities) == 3
        @test length(unique(values(communities))) == 1
    end

    @testset "community_detection: KClique()" begin
        g = generate(ChainedCliques(2, 6))
        communities = community_detection(g, KClique())
        @test length(unique(values(communities))) == 2
    end

    @testset "community_detection: LabelPropagation()" begin
        g = generate(ChainedCliques(2, 6))
        communities = community_detection(g, LabelPropagation())
        @test length(unique(values(communities))) == 2
    end
end