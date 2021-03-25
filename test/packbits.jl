@testset "inflate" begin
    input = Int8[-3, 3, 2, 4, 5]
    output = fill(0x00, 5)

    inflate!(Balloons.Packbits(), input, output)

    @test all(output .== [0x03, 0x03, 0x03, 0x04, 0x05])
end