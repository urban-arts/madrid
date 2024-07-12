--!strict
--[[
    ServerRunner.lua
    Manages the initialization, execution, and cleanup of server-side components.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Framework = ReplicatedStorage.Framework
local EngineTypes = require(Framework.Shared.EngineTypes)
local EngineEnvironmentManager = require(Framework.Shared.EngineEnvironment)

local ServerRunner = {}

--- Array of engine components
ServerRunner.__engineComponents = {} :: {EngineTypes.EngineCoreComponent}

--- Array of game components
ServerRunner.__gameComponents = {} :: {EngineTypes.GameComponent}

--- Loads a component from a ModuleScript
--- @param component ModuleScript The ModuleScript to load
--- @return EngineTypes.ComponentLifecycle? The loaded component or nil if loading failed
function ServerRunner.__loadComponent(component: ModuleScript): EngineTypes.ComponentLifecycle?
    local success, result = pcall(require, component)
    
    if not success then
        warn(string.format("Failed to load component %s: %s", component.Name, tostring(result)))
        return nil
    end
    
    return result
end

--- Loads all engine and game components
function ServerRunner.__loadComponents()
    -- Load engine components
    local engineComponents = Framework:FindFirstChild("EngineComponents")
    if engineComponents then
        for _, component in ipairs(engineComponents:GetChildren()) do
            if component:IsA("ModuleScript") then
                local result = ServerRunner.__loadComponent(component)
                if result and result.IsEngineComponent then
                    table.insert(ServerRunner.__engineComponents, result :: EngineTypes.EngineCoreComponent)
                    EngineEnvironmentManager:AddEngineComponent(result :: EngineTypes.EngineCoreComponent)
                end
            end
        end
    end

    -- Load game components
    local serverComponents = ServerScriptService:FindFirstChild("ServerComponents")
    if serverComponents then
        for _, component in ipairs(serverComponents:GetChildren()) do
            if component:IsA("ModuleScript") then
                local result = ServerRunner.__loadComponent(component)
                if result and result.IsGameComponent then
                    table.insert(ServerRunner.__gameComponents, result :: EngineTypes.GameComponent)
                    EngineEnvironmentManager:AddGameComponent(result :: EngineTypes.GameComponent)
                end
            end
        end
    end

    -- Sort components by LoadOrder
    local function sortByLoadOrder(a: EngineTypes.ComponentLifecycle, b: EngineTypes.ComponentLifecycle)
        return (a.LoadOrder or 0) < (b.LoadOrder or 0)
    end
    table.sort(ServerRunner.__engineComponents, sortByLoadOrder)
    table.sort(ServerRunner.__gameComponents, sortByLoadOrder)
end

--- Initializes all loaded components
function ServerRunner.__initializeComponents()
    for _, component in ipairs(ServerRunner.__engineComponents) do
        if type(component.initialize) == "function" then
            component:initialize(EngineEnvironmentManager)
        end
    end
    for _, component in ipairs(ServerRunner.__gameComponents) do
        if type(component.initialize) == "function" then
            component:initialize(EngineEnvironmentManager)
        end
    end
end

--- Starts all loaded components
function ServerRunner.__startComponents()
    for _, component in ipairs(ServerRunner.__engineComponents) do
        if type(component.start) == "function" then
            task.spawn(function()
                component:start(EngineEnvironmentManager)
            end)
        end
    end
    for _, component in ipairs(ServerRunner.__gameComponents) do
        if type(component.start) == "function" then
            task.spawn(function()
                component:start(EngineEnvironmentManager)
            end)
        end
    end
end

--- Updates all loaded components
--- @param dt number Delta time
function ServerRunner.__updateComponents(dt: number)
    for _, component in ipairs(ServerRunner.__engineComponents) do
        if type(component.update) == "function" then
            task.spawn(function()
                (component.update :: (EngineTypes.ComponentLifecycle, number) -> ())(component, dt)
            end)
        end
    end
    for _, component in ipairs(ServerRunner.__gameComponents) do
        if type(component.update) == "function" then
            task.spawn(function()
                (component.update :: (EngineTypes.ComponentLifecycle, number) -> ())(component, dt)
            end)
        end
    end
end

--- Stops all loaded components
function ServerRunner.__stopComponents()
    for _, component in ipairs(ServerRunner.__engineComponents) do
        if type(component.stop) == "function" then
            (component.stop :: (EngineTypes.ComponentLifecycle) -> ())(component)
        end
    end
    for _, component in ipairs(ServerRunner.__gameComponents) do
        if type(component.stop) == "function" then
            (component.stop :: (EngineTypes.ComponentLifecycle) -> ())(component)
        end
    end
end

--- Starts the ServerRunner
function ServerRunner.Start()
    print("Initializing Server Components...")

    local _engineEnv = EngineEnvironmentManager.GetEngineGlobals()

    ServerRunner.__loadComponents()
    ServerRunner.__initializeComponents()
    ServerRunner.__startComponents()

    RunService.Heartbeat:Connect(function(dt)
        ServerRunner.__updateComponents(dt)
    end)

    game:BindToClose(function()
        ServerRunner.__stopComponents()
    end)

    print("Server initialization complete!")
end

return ServerRunner