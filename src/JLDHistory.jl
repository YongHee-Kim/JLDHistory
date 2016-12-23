# module JLDHistory
    using JLD

    ## MetaData for HistoryData search
    immutable HistoryMeta
        datalength::Int
        header::String
        path::String
        tags::Dict{String,Vector}
        # 5 is magic number or any fixed number will do? or it defends on T
        function HistoryMeta(header, path; datalength=5)
            new(datalength, header, path, Dict{String,Vector}())
        end
    end

    # filename 자체가 uid가 되니까 uid는 없어도...
    type TempHistoryData{T}
        meta::HistoryMeta
        nth::Int # filename을 몇번 저장했는가
        filename::String
        store_position::Int #position to store within data, tag vector
        data::Vector{T}
        tag::Vector{String}
        function TempHistoryData(meta, fname)
            l = datalength(meta)
            new(meta, 1, fname, 1, Array(T, l), Array(String, l))
        end
    end
    datalength(x::HistoryMeta) = x.datalength
    datalength(x::TempHistoryData) = datalength(x.meta)

    filepath(x::HistoryMeta) = x.path
    filepath(x::TempHistoryData) = filepath(x.meta)

    store_position(x::TempHistoryData) = x.store_position
    isfull(x::TempHistoryData) = store_position(x) >= datalength(x)

    function reset!{T}(h::TempHistoryData{T})
        register!(h)
        l = datalength(h)
        h.nth += 1
        h.store_position = 1
        h.data = Array(T, l)
        h.tag = Array(String, l)
        h
    end

    function register!(h::TempHistoryData)
        d = h.meta.tags
        key = h.filename
        if h.nth == 1
            d[key] = h.tag
        else
            push!(d[key], h.tag)
        end
    end

    type HistoryData{T}
        data::Vector{T}
        tag::Vector{String}
        function HistoryData(x::TempHistoryData{T})
            new{T}(x.data, x.tag)
        end
    end

    # HistoryData가 STORED_VECTOR_LENGTH만큼 찰때마다
    # HardDisk에 저장하고 스스로를 초기화 시킴.
    function writehistory(x, data, tag)
        pos = store_position(x)
        x.data[pos] = data
        x.tag[pos] = tag
        x.store_position += 1

        if isfull(x)
            writehistory(x)
            reset!(x)
        end
    end
    function writehistory(x)
        jldopen(joinpath(filepath(x), "$(x.filename).jld"), "w") do file
            write(file, "mydata", HistoryData(x))
        end
    end
    function writemeta(x, fname)
        jldopen(jldopen(filepath(x), "_meta.jld"), "w") do file
            write(file, "metadata", x)
        end
    end
# end
