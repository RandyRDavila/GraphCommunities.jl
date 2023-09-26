
@testset "Community Detection Tests" begin

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
