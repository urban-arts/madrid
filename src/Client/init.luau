--!strict
--[[
    Open Source 2023 - All Rights Reserved
    This module defines the client-side components of the framework.
]]

local EngineTypes = require(script.Parent.Shared.EngineTypes)
local ClientRunner = require(script.ClientRunner)

return {
    ClientRunner = ClientRunner
} :: EngineTypes.ClientFramework