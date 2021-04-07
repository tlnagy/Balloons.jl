@testset "inflate" begin
    test_sequence = UInt8.([128,0,0,4,151,144,57,244,6,125,10,27,2,133,176,29,1,1])

    inflated = inflate(Balloons.LZW(), test_sequence)

    @test inflated == [0,0,73,242,14,250,6,250,40,216,40,182,7,128]
end