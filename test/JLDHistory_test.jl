using JLDHistory


meta = HistoryMeta("test", "dirname(@__FILE__)")

history = TempHistoryData(Int, meta, "first")



foo{T}(::Type{T}, x)  = println(T, x)

foo{Int}(10)
