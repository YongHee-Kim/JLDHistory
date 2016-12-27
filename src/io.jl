# HistoryData가 STORED_VECTOR_LENGTH만큼 찰때마다
# HardDisk에 저장하고 스스로를 초기화 시킴.
function writehistory!(x, data, tag; force_save=false)
    pos = store_position(x)
    x.data[pos] = data
    x.tag[pos] = tag
    if isfull(x) || force_save
        writehistory(x, force_save)
        reset!(x)
    else
        x.store_position += 1
    end
end
function writehistory(x::TempHistoryData, force_save=false)
    h = HistoryData(x, force_save)
    jldopen(joinpath(filepath(x), "$(x.filename)_$(x.nth).jld"), "w") do file
        write(file, "historydata", h)
    end
end

#= TODO: 메타는 JLD말고 일반 text로 저장하는 옵션 추가
        Historydata를 child로 연결시켜서
        meta 저장할때 남은거 다 저장하도록...
=#
function writemeta(x, fname)
    jldopen(joinpath(filepath(x), "$(fname).jld"), "w") do file
        write(file, "metadata", x)
    end
end

# 현재 defined된 부분만 저장
