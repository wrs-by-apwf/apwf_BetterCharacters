function appendFunction(original, toAppend)
    return function(...)
        original(...)
        toAppend(...)
    end
end