module JLDHistory
    using JLD

    export HistoryMeta, TempHistoryData, HistoryData,
        writehistory!, writemeta

    include("io.jl")

    immutable HistoryMeta
        datalength::Int
        header::String
        path::String
        tags::Dict{String,Vector}
        # 5 is magic number or any fixed number will do? or it defends on T
        HistoryMeta() = new(5, "", "", Dict{String,Vector}())
        function HistoryMeta(header, path; datalength=5)
            new(datalength, header, path, Dict{String,Vector}())
        end
    end

    type TempHistoryData{T}
        meta::HistoryMeta
        nth::Int # filename을 몇번 저장했는가
        filename::String # uid 역활
        store_position::Int #position to store within data, tag vector
        data::Vector{T}
        tag::Vector{String}
        function TempHistoryData(meta, fname)
            l = datalength(meta)
            new(meta, 1, fname, 1, Array(T, l), Array(String, l))
        end
    end

    immutable HistoryData
        data::Vector
        tag::Vector{String}
        function HistoryData(x::TempHistoryData)
            new(x.data, x.tag)
        end
        function HistoryData(x::TempHistoryData, force_save=false)
            data, tag = if force_save
                (x.data, x.tag)
            else
                (x.data[1:store_position-1], x.tag[1:store_position-1])
            end
            new(data, tag)
        end
    end

    datalength(x::HistoryMeta) = x.datalength
    datalength(x::TempHistoryData) = datalength(x.meta)

    filepath(x::HistoryMeta) = x.path
    filepath(x::TempHistoryData) = filepath(x.meta)

    store_position(x::TempHistoryData) = x.store_position
    isfull(x::TempHistoryData) = store_position(x) >= datalength(x)

    function reset!(h::TempHistoryData)
        register!(h)
        l = datalength(h)
        h.nth += 1
        h.store_position = 1
        h.data = Array(eltype(h.data), l)
        h.tag = Array(String, l)
        h
    end

    function register!(h::TempHistoryData)
        d = h.meta.tags
        key = h.filename
        if h.nth == 1
            d[key] = [h.tag]
        else
            push!(d[key], h.tag)
        end
    end


end
