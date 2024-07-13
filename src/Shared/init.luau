--!strict
--[[
    Open Source 2023 - All Rights Reserved
    This module defines the shared components of the framework.
]]

local EngineTypes = require(script.EngineTypes)

--- @class SharedFramework
--- @field EngineTypes table The engine types module
local SharedFramework = {
    EngineTypes = EngineTypes,
} :: EngineTypes.SharedFramework

return SharedFramework