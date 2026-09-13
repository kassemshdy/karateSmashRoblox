-- Session-local Studio adapter. No production data is read or written.
local MemoryStore = {}
function MemoryStore.new()
    local values = {}
    return {
        UpdateAsync = function(_, key, transform)
            local nextValue = transform(values[key])
            if nextValue ~= nil then values[key] = nextValue end
            return nextValue
        end,
    }
end
return MemoryStore
