utils = {}



function utils:getSign(number)
    return (number > 0 and 1) or (number < 0 and -1) or 0
end

function utils:round(number)
    if number then
        return math.floor(number*1000 + 0.5)/1000
    end
    return "nil"
end

function utils:getKeyByValue(tbl, value)
    for k,v in pairs(tbl) do 
        if v == value then
            return k
        end
    end
    return nil -- Return nil if the value is not found
end

function utils:generateKeyList(tbl)
    local keys = {}
    for k, v in pairs(tbl) do
        keys[#keys+1] = k
    end
    return keys
end

function utils:getAllKeysOf(tbl)
    keylist = {}
    inc = 0
    for k,v in pairs(tbl) do 
        table.insert(keylist, inc, k)
        inc = inc + 1
    end
    return keylist -- Return nil if the value is not found
end

function utils:indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function utils:splitTableEachN(tbl, n)
    local result = {}  -- Table to hold the split sub-tables
    local subTable = {}  -- Temporary sub-table
    
    for i, value in ipairs(tbl) do
        table.insert(subTable, value)  -- Add current value to the temporary sub-table
        
        -- If the current index is divisible by n or it's the last element
        if i % n == 0 or i == #tbl then
            table.insert(result, subTable)  -- Add the sub-table to the result
            subTable = {}  -- Reset the sub-table for the next iteration
        end
    end
    
    return result
end

function utils:endsWith(str, ending)
    if ending ~= nil then
        return ending == "" or str:sub(-#ending) == ending
    end
    
end


function utils:tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end
  

return utils