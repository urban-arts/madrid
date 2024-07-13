--!strict
--[[
    Open Source 2023 - All Rights Reserved
    This module defines the server-side components of the framework.
]]

local EngineTypes = require(script.Parent.Shared.EngineTypes)
local ServerRunner = require(script.ServerRunner)

--- @class ServerFramework
--- @field ServerRunner ServerRunner
local ServerFramework = {
    ServerRunner = ServerRunner
} :: EngineTypes.ServerFramework

return ServerFramework