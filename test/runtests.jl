using Balloons
using Test

@testset "Balloons.jl" begin
    @testset "Packbits" begin
        include("packbits.jl")
    end
end
