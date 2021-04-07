module Balloons

export deflate, inflate!, inflate

abstract type CompressionAlgorithm end

"""
    Packbits Compression

A simple byte-oriented run-length encoding as defined by the TIFF Spec 6.0
"""
struct Packbits <: CompressionAlgorithm end

inflate!(pb::Packbits, input, output) = inflate!(pb, reinterpret(UInt8, input), reinterpret(UInt8, output))

function inflate!(::Packbits, input::AbstractVector{UInt8}, output::AbstractVector{UInt8})
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

"""
    Lempel-Ziv-Welch Compression

A robust universal lossless compression algorithm. This implementation supports
variable-width compression codes.
"""
struct LZW <: CompressionAlgorithm
    initial_codewidth::Int
    initial_dictsize::Int

    clearcode::UInt32
    endcode::UInt32
end

LZW() = LZW(9, 256, 256, 257)

mask(t::Type{T}, p::Integer, l::Integer) where {T} = (typemax(T) << (sizeof(T)*8-l)) >> p

extract(packed::T, p::Integer, l::Integer) where {T} = (packed & mask(T, p, l)) >> (sizeof(T)*8 - p - l)

"""
    stuff(v, a, loc)

Stuff bits of `a` into 32-bit unsigned integer `v` at a given byte location `loc`

```jldoctest
julia> Balloons.stuff(zero(UInt32), 0xff, 1)
0xff000000

julia> Balloons.stuff(zero(UInt32), 0xff, 4)
0x000000ff
```
"""
function stuff(v::UInt32, a::UInt8, loc::T) where {T <: Integer}
    @assert 0 < loc <= 4
    v += (zero(UInt32) + a) << ((4-loc)*8)
end

function initdict!(lzw::LZW, dict)
    empty!(dict)

    for i in 0:(lzw.initial_dictsize - 1)
        dict[i] = UInt8[i]
    end
    dict[lzw.clearcode] = UInt8[0]
    dict[lzw.endcode] = UInt8[0]
end

function nextchar(input, ρ, bitwidth)
    i = ρ÷8+1
    v = stuff(zero(UInt32), input[i], 1)

    for j in 1:min(3, length(input)-i)
        v = stuff(v, input[i+j], j+1)
    end

    extract(v, mod(ρ, 8), bitwidth)
end

function inflate(lzw::LZW, input::Vector{UInt8})
    bitwidth = lzw.initial_codewidth

    ρ = 0 # position in bits

    output = IOBuffer()

    dict = Dict{UInt32, Array{UInt8}}()
    k = lzw.clearcode

    entry = UInt8[]
    prev_entry = UInt8[]

    while true
        # increase bitwidth if we're out of space
        if length(dict) >= 2^bitwidth - 1
            bitwidth += 1
        end

        k = nextchar(input, ρ, bitwidth)
        if k == lzw.endcode
            break
        end

        # reset dictionary and variables on detecting a clear code
        if k == lzw.clearcode
            ρ += bitwidth

            # reset everything back to baseline
            initdict!(lzw, dict)
            sz = length(dict)
            entry = UInt8[]
            prev_entry = UInt8[]
            bitwidth = lzw.initial_codewidth

            # get next character
            k = nextchar(input, ρ, bitwidth)
            (k == lzw.endcode) && break
            entry = dict[k]
            write(output, entry)
            prev_entry = entry
        else
            if haskey(dict, k)
                entry = dict[k]
            else
                entry = vcat(prev_entry, first(prev_entry))
            end

            write(output, entry)
            if length(prev_entry) != 0
                dict[length(dict)] = vcat(prev_entry, first(entry))
            end
            prev_entry = entry
        end

        ρ += bitwidth
    end

    seekstart(output)
    readavailable(output)
end

end
