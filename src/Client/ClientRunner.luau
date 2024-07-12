--!strict
--[[
    ClientRunner.lua
    Manages the initialization, execution, and cleanup of client-side components.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local Framework = ReplicatedStorage.Framework
local EngineTypes = require(Framework.Shared.EngineTypes)
local EngineEnvironmentManager = require(Framework.Shared.EngineEnvironment)

local ClientRunner = {}

--- Array of engine components
ClientRunner.__engineComponents = {} :: {EngineTypes.EngineCoreComponent}

--- Array of game components
ClientRunner.__gameComponents = {} :: {EngineTypes.GameComponent}

--- Loads a component from a ModuleScript
--- @param component ModuleScript The ModuleScript to load
--- @return EngineTypes.ComponentLifecycle? The loaded component or nil if loading failed
function ClientRunner.__loadComponent(component: ModuleScript): EngineTypes.ComponentLifecycle?
    local success, result = pcall(require, component)
    
    if not success then
        warn(string.format("Failed to load component %s: %s", component.Name, tostring(result)))
        return nil
    end
    
    return result
end

--- Loads all engine and game components
function ClientRunner.__loadComponents()
    -- Load engine components
    local engineComponents = Framework:FindFirstChild("EngineComponents")
    if engineComponents then
        for _, component in ipairs(engineComponents:GetChildren()) do
            if component:IsA("ModuleScript") then
                local result = ClientRunner.__loadComponent(component)
                if result and result.IsEngineComponent then
                    table.insert(ClientRunner.__engineComponents, result :: EngineTypes.EngineCoreComponent)
                    EngineEnvironmentManager:AddEngineComponent(result :: EngineTypes.EngineCoreComponent)
                end
            end
        end
    end

    -- Load game components
    local clientComponents = StarterPlayer.StarterPlayerScripts:FindFirstChild("ClientComponents")
    if clientComponents then
        for _, component in ipairs(clientComponents:GetChildren()) do
            if component:IsA("ModuleScript") then
                local result = ClientRunner.__loadComponent(component)
                if result and result.IsGameComponent then
                    table.insert(ClientRunner.__gameComponents, result :: EngineTypes.GameComponent)
                    EngineEnvironmentManager:AddGameComponent(result :: EngineTypes.GameComponent)
                end
            end
        end
    end

    -- Sort components by LoadOrder
    local function sortByLoadOrder(a: EngineTypes.ComponentLifecycle, b: EngineTypes.ComponentLifecycle)
        return (a.LoadOrder or 0) < (b.LoadOrder or 0)
    end
    table.sort(ClientRunner.__engineComponents, sortByLoadOrder)
    table.sort(ClientRunner.__gameComponents, sortByLoadOrder)
end

--- Initializes all loaded components
function ClientRunner.__initializeComponents()
    for _, component in ipairs(ClientRunner.__engineComponents) do
        if type(component.initialize) == "function" then
            component:initialize(EngineEnvironmentManager)
        end
    end
    for _, component in ipairs(ClientRunner.__gameComponents) do
        if type(component.initialize) == "function" then
            component:initialize(EngineEnvironmentManager)
        end
    end
end

--- Starts all loaded components
function ClientRunner.__startComponents()
    for _, component in ipairs(ClientRunner.__engineComponents) do
        if type(component.start) == "function" then
            task.spawn(function()
                component:start(EngineEnvironmentManager)
            end)
        end
    end
    for _, component in ipairs(ClientRunner.__gameComponents) do
        if type(component.start) == "function" then
            task.spawn(function()
                component:start(EngineEnvironmentManager)
            end)
        end
    end
end

--- Updates all loaded components
--- @param dt number Delta time
function ClientRunner.__updateComponents(dt: number)
    for _, component in ipairs(ClientRunner.__engineComponents) do
        if type(component.update) == "function" then
            task.spawn(function()
                (component.update :: (EngineTypes.ComponentLifecycle, number) -> ())(component, dt)
            end)
        end
    end
    for _, component in ipairs(ClientRunner.__gameComponents) do
        if type(component.update) == "function" then
            task.spawn(function()
                (component.update :: (EngineTypes.ComponentLifecycle, number) -> ())(component, dt)
            end)
        end
    end
end

--- Stops all loaded components
function ClientRunner.__stopComponents()
    for _, component in ipairs(ClientRunner.__engineComponents) do
        if type(component.stop) == "function" then
            (component.stop :: (EngineTypes.ComponentLifecycle) -> ())(component)
        end
    end
    for _, component in ipairs(ClientRunner.__gameComponents) do
        if type(component.stop) == "function" then
            (component.stop :: (EngineTypes.ComponentLifecycle) -> ())(component)
        end
    end
end

--- Starts the ClientRunner
function ClientRunner.Start()
    print("Initializing Client Components...")

    local _engineEnv = EngineEnvironmentManager.GetEngineGlobals()

    ClientRunner.__loadComponents()
    ClientRunner.__initializeComponents()
    ClientRunner.__startComponents()

    RunService.Heartbeat:Connect(function(dt)
        ClientRunner.__updateComponents(dt)
    end)

    game:BindToClose(function()
        ClientRunner.__stopComponents()
    end)

    print("Client initialization complete!")
end

return ClientRunner