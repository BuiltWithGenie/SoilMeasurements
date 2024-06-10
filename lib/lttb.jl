using Statistics: mean

"""
    x, y = lttb(v::AbstractVector, n = length(v)÷10)
 
The largest triangle, three-buckets reduction of the vector `v` over points `1:N` to a
new, shorter vector `y` at `x` with `length(x) == n`.
 
See https://skemman.is/bitstream/1946/15343/3/SS_MSthesis.pdf

#### Acknowledgement
This implementation is taken from https://gist.github.com/jmert/4e1061bb42be80a4e517fc815b83f1bc
"""
function lttb(v::AbstractVector, n = length(v)÷10)
    N = length(v)
    N == 0 && return similar(v)
 
    w = similar(v, n)
    z = similar(w, Int)
 
    # always take the first and last data point
    @inbounds begin
        w[1] = y₀ = v[1]
        w[n] = v[N]
        z[1] = x₀ = 1
        z[n] = N
    end
 
    # split original vector into buckets of equal length (excluding two endpoints)
    #   - s[ii] is the inclusive lower edge of the bin
    s = range(2, N, length = n-1)
    @inline lower(k) = round(Int, s[k])
    @inline upper(k) = k+1 < n ? round(Int, s[k+1]) : N-1
    @inline binrange(k) = lower(k):upper(k)
 
    # then for each bin
    @inbounds for ii in 1:n-2
        # calculate the mean of the next bin to use as a fixed end of the triangle
        r = binrange(ii+1)
        x₂ = mean(r)
        y₂ = sum(@view v[r]) / length(r)
 
        # then for each point in this bin, calculate the area of the triangle, keeping
        # track of the maximum
        r = binrange(ii)

        x̂, ŷ, Â = first(r), v[first(r)], typemin(y₀)
        for jj in r
            x₁, y₁ = jj, v[jj]
            # triangle area:
            A = abs(x₀*(y₁-y₂) + x₁*(y₂-y₀) + x₂*(y₀-y₁)) / 2
            # update coordinate if area is larger
            if A > Â
                x̂, ŷ, Â = x₁, y₁, A
            end
            x₀, y₀ = x₁, y₁
        end
        z[ii+1] = x̂
        w[ii+1] = ŷ
    end
 
    return (z, w)
end
