using Balloons
using Test

@testset "Packbits" begin
    include("packbits.jl")
end

@testset "LZW" begin
    include("lzw.jl")
end
