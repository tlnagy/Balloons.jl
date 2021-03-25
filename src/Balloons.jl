module Balloons

export deflate, inflate!

abstract type CompressionAlgorithm end

"""
    Packbits Compression

A simple byte-oriented run-length encoding as defined by the TIFF Spec 6.0
"""
struct Packbits <: CompressionAlgorithm end

inflate!(pb::Packbits, input, output) = inflate!(pb, reinterpret(UInt8, input), reinterpret(UInt8, output))

function inflate!(::Packbits, input::Vector{UInt8}, output::Vector{UInt8})
    ipos, opos = 1, 1

    while opos <= length(output)
        n = reinterpret(Int8, input[ipos])
        ipos += 1
        if 0 <= n <= 127
            output[opos:opos+n-1] = view(input, ipos:ipos+n-1)
            ipos += n
            opos += n
        elseif -127 <= n <= -1
            nxt = input[ipos]
            output[opos:(opos-n-1)] .= nxt
            opos += -n
            ipos += 1
        end
    end
end

end
