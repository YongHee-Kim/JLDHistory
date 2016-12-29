using FactCheck
include("C:\\Github\\julia\\JLDHistory\\src\\JLDHistory.jl")
using JLD, JLDHistory

PATH = dirname(@__FILE__)

# 쓰기
meta = HistoryMeta("test", PATH; datalength=100)

history = TempHistoryData{Int}(meta, "first")

@time for i in 1:200
    a = rand(1:1500)
    writehistory!(history, a, "$(i)_file$(history.nth)")
end
writemeta(meta, "test1")


# 읽기
meta_loaded = jldopen("$PATH\\test1.jld", "r") do file
    read(file, "metadata")
end
@fact meta.tags --> meta_loaded.tags


history_loaded = jldopen("$PATH\\first_1.jld", "r") do file
    read(file, "historydata")
end
@fact length(history_loaded.data) --> meta.datalength
