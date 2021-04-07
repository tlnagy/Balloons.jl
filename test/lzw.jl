if VERSION >= v"1.6.0"
    using Downloads
    getfile(x) = Downloads.download(x)
else
    getfile(x) = download(x)
end

@testset "inflate" begin
    test_sequence = UInt8.([128,0,0,4,151,144,57,244,6,125,10,27,2,133,176,29,1,1])

    inflated = inflate(Balloons.LZW(), test_sequence)

    @test inflated == [0,0,73,242,14,250,6,250,40,216,40,182,7,128]

    bali_fp = getfile("https://github.com/tlnagy/exampletiffs/blob/master/bali.tif?raw=true")
    io = open(bali_fp)
    seek(io, 8)
    input = read(io, 3666)

    inflated = Balloons.inflate(Balloons.LZW(), input)

    @test length(inflated) == 7975
end