--!strict
--[[
    Open Source 2023 - All Rights Reserved
    This module provides utility functions for the engine.
]]

local EngineUtilities = {}

--- Performs a deep clone of a table
--- @param t table The table to clone
--- @return table A deep clone of the input table
function EngineUtilities.DeepClone(t: {[any]: any}): {[any]: any}
    if type(t) ~= "table" then
        return {}
    end

    local nTable = {}

    for idx, member in t do
        if type(member) == "table" then
            nTable[idx] = EngineUtilities.DeepClone(member)
        else
            nTable[idx] = member
        end
    end

    return nTable
end

return EngineUtilities