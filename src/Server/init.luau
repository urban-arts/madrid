--!strict
--[[
    Open Source 2023 - All Rights Reserved
    This module defines the server-side components of the framework.
]]

local EngineTypes = require(script.Parent.Shared.EngineTypes)
local ServerRunner = require(script.ServerRunner)

return {
    ServerRunner = ServerRunner
} :: EngineTypes.ServerFramework