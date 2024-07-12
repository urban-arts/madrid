--!strict
--[[
    Open Source 2023 - All Rights Reserved
    This script initializes the framework based on the current runtime environment.
]]

local RunService = game:GetService("RunService")

local SharedFramework = require(script.Shared)
local EngineTypes = require(script.Shared.EngineTypes)

--- Initializes the framework based on the current runtime environment
--- @return EngineTypes.SharedFramework & (EngineTypes.ServerFramework | EngineTypes.ClientFramework)
local function initializeFramework(): EngineTypes.SharedFramework & (EngineTypes.ServerFramework | EngineTypes.ClientFramework)
    local Framework = table.clone(SharedFramework) :: any  -- Use type assertion here

    if RunService:IsServer() then
        local ServerFramework = require(script.Server)
        local ServerRunner = require(script.Server.ServerRunner)
        
        Framework.ServerRunner = ServerRunner
        
        for key, value in pairs(ServerFramework) do
            Framework[key] = value
        end

        task.spawn(ServerRunner.Start)
    else
        local ClientFramework = require(script.Client)
        local ClientRunner = require(script.Client.ClientRunner)
        
        Framework.ClientRunner = ClientRunner
        
        for key, value in pairs(ClientFramework) do
            Framework[key] = value
        end

        task.spawn(ClientRunner.Start)
    end

    return Framework
end

local Framework = initializeFramework()

return Framework