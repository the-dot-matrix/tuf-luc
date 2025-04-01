function randomlist(size,min,max)
    local list = {}
    for i = 1,size do
        local value = math.random(min,max)
        table.insert(list, value)
    end
    return list
end

function stringlist(list)
    local str = ""
    for i = 1,#list do str=str..list[i].."," end
    return str:sub(1,#str-1)
end

function mergesort(list,i,j)
    if j-i+1 < 3 then
        if j-i+1 == 2 and list[i]>list[j] then
            list[i],list[j]=list[j],list[i]
        end
    else
        local mid = math.floor((i+j)/2)
        mergesort(list,i,mid)
        mid = mid+1
        mergesort(list,mid,j)
        local last = j
        j = mid
        while i<=mid and j<=last do
            if list[i]>list[j] then
                local swap = list[j]
                local shift = j
                while shift~=i do
                    list[shift] = list[shift-1]
                    shift = shift-1
                end
                list[i] = swap
                mid = mid+1
                j = j+1
            end
            i=i+1
        end
    end
    return list
end

function validsort(list)
    local valid = true
    for i = 1,#list-1 do
        valid = valid and list[i]<=list[i+1]
    end
    return valid
end

function main()
    local timestart = os.time()
    local E = 4
    local L = 10000
    math.randomseed(timestart)
    local version = "unknown lua version"
    if jit then 
        version = jit.version
    else 
        version = _VERSION 
    end
    print(version)
    print("testing performance sorting O("..L..") lists")
    for e = 1,E do
        local s = 10^e
        local ls = math.floor(L/(10^(e-1)))
        print("sorting "..ls.." lists of size "..s)
        for l = 1,ls do
            if l%(ls/10) == 0 then print(l/ls*100 .. "%") end
            local list = randomlist(s,-s,s)
            --print("original:\t"..stringlist(list))
            mergesort(list,1,#list)
            --print("sorted:\t\t"..stringlist(list))
            --print("valid:\t\t"..)
            assert(validsort(list),"INVALID SORT")
        end
    end
    local timeend = os.time()
    local timeelapsed = os.difftime(timeend,timestart)
    print("test took "..timeelapsed.." seconds")
end
main()
