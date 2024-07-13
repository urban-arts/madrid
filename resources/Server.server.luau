--!strict
--[[
    Open Source 2023 - All Rights Reserved
    This script initializes the server-side framework.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EngineEnvironmentManager = require(ReplicatedStorage.Framework.Shared.EngineEnvironment)

--- Initializes the server-side framework
--- @param none
--- @return none
local function initializeServerFramework()
    print("Initializing Server Framework...")

    -- Get the engine globals
    local _engineEnv = EngineEnvironmentManager.GetEngineGlobals()

    -- Load server-side components
    local serverComponents = ServerScriptService:FindFirstChild("ServerComponents")
    if serverComponents then
        for _, component in ipairs(serverComponents:GetChildren()) do
            if component:IsA("ModuleScript") then
                local success, result = pcall(require, component)
                
                if success and type(result) == "table" and result.initialize then
                    EngineEnvironmentManager:AddGameComponent(result)
                else
                    warn("Failed to load component:", component.Name, result)
                end
            end
        end
    end

    -- Initialize and start components in order
    local loadedModules = EngineEnvironmentManager:GetLoadedModules()
    for _, component in pairs(loadedModules) do
        if type(component.initialize) == "function" then
            component:initialize(EngineEnvironmentManager)
        end
    end

    for _, component in pairs(loadedModules) do
        if type(component.start) == "function" then
            component:start(EngineEnvironmentManager)
        end
    end

    print("Server Framework initialization complete!")
end

-- Initialize the server framework immediately
initializeServerFramework()