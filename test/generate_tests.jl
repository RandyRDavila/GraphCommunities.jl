
@testset "Generate Community Tests" begin

    @testset "generate: KarateClub()" begin
        g = generate(KarateClub())
        @test nv(g) == 34
    end

    @testset "generate: PlantedPartition()" begin
        g = generate(PlantedPartition(2, 3, 0.5, 0.1))
        @test nv(g) == 6
    end

    @testset "generate: ChainedCliques()" begin
        g = generate(ChainedCliques(; num_cliques = 2, clique_size = 6))
        @test nv(g) == 12
    end
end
