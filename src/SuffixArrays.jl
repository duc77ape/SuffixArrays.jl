module SuffixArrays

export suffixsort
#export findall

struct SuffixArray{S<:AbstractString,N<:Signed}
    string::S
    n::Int
    index::Array{N,1}
end

function SuffixArray(s::S) where S <: AbstractString
    n = length(s)
    size = sizeof(s)

    index = zeros(size <= typemax(Int8)  ? Int8  :
                  size <= typemax(Int16) ? Int16 :
                  size <= typemax(Int32) ? Int32 : Int64, n)

    return SuffixArray(s,n,index)
end

include("sais.jl")

function suffixsort(s)
    if isempty(s)
        return nothing
    elseif length(s) <= 1
        return SA(s, Int8(1), Int8[0])
    end

    SA = SuffixArray(s)

    if isascii(s)
        SuffixArrays.sais(s, SA.index, 0, SA.n, 256, false)
    else
        SuffixArrays.sais(collect(s), SA.index, 0, SA.n, 2^24, false)
        SA.index .= collect(keys(s))[SA.index .+ eltype(SA.index)(1)] .- 1
    end
    return SA
end


#=contains(haystack, needle)

matchall(substring, s::String)=#
const MAXCHAR = Char(255)

function lcp2(SA,s)
    inv = similar(SA)
    lcparr = similar(SA)
    n = length(SA)
    for i = 1:n
        inv[SA[i]+1] = i-1
    end
    m = 0
    for i = 1:n
        if inv[i] > 0
            j = SA[inv[i]]
            while s[m+i] == s[m+j+1]
                m += 1
            end
            lcparr[inv[i]+1] = m
            m > 0 && (m-=1)
        end
    end
    lcparr[1] = -1
    return lcparr
end

function findall(substring::AbstractString, sa::SuffixArray)
    len = length(typeof(sa.string)(substring))

    r = searchsorted(sa.index, substring, by=(elem)->(typeof(elem) <: AbstractString ? elem : SubString(sa.string, elem+1, min(nextind(sa.string, elem+1, len - 1), lastindex(sa.string)))))

    if first(r) > last(r)
         return Array{UnitRange{Int},1}()
    end

    len = lastindex(typeof(sa.string)(substring))
    return [sa.index[i]+1:sa.index[i]+len for i in r]
end

end # module
