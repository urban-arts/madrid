--!strict
--[[
    Open Source 2023 - All Rights Reserved
    This module provides utility functions for the engine.
]]

local module = {}

--- Performs a deep clone of a table
--- @param t table The table to clone
--- @return table A deep clone of the input table
function module.DeepClone(t: { any }): { any }
    if typeof(t) ~= "table" then
        return {}
    end

    local nTable = {}

    for idx, member in t do
        if typeof(member) == "table" then
            nTable[idx] = module.DeepClone(member)
        else
            nTable[idx] = member
        end
    end

    return nTable
end

return module