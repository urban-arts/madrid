--!nocheck
--!strict
--[[
    Open Source 2023 - All Rights Reserved
    This module manages the engine environment, including component loading and environment setup.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Framework = script.Parent.Parent
local EngineTypes = require(Framework.Shared.EngineTypes)
local EngineUtilities = require(Framework.Shared.EngineUtilities)

--- @class EngineEnvironmentManager
local EngineEnvironmentManager = {} :: EngineTypes.EngineEnvironmentManager
local LoadedEngineComponents: {[string]: EngineTypes.EngineCoreComponent} = {}
local LoadedGameComponents: {[string]: EngineTypes.GameComponent} = {}

--- Adds an engine component to the loaded components
--- @param engineComponent EngineTypes.EngineCoreComponent
function EngineEnvironmentManager:AddEngineComponent(engineComponent: EngineTypes.EngineCoreComponent)
    LoadedEngineComponents[engineComponent.ComponentName] = engineComponent
    print(string.format("Added engine component: %s. Initialize: %s, Start: %s", 
        engineComponent.ComponentName,
        tostring(type(engineComponent.initialize) == "function"),
        tostring(type(engineComponent.start) == "function")
    ))
end

--- Adds a game component to the loaded components
--- @param gameComponent EngineTypes.GameComponent
function EngineEnvironmentManager:AddGameComponent(gameComponent: EngineTypes.GameComponent)
    LoadedGameComponents[gameComponent.ComponentName] = gameComponent
    print(string.format("Added game component: %s. Initialize: %s, Start: %s", 
        gameComponent.ComponentName,
        tostring(type(gameComponent.initialize) == "function"),
        tostring(type(gameComponent.start) == "function")
    ))
end

--- Retrieves an engine component by name
--- @param componentName string
--- @return EngineTypes.EngineCoreComponent?
function EngineEnvironmentManager:GetEngineComponent(componentName: string): EngineTypes.EngineCoreComponent?
    local component = LoadedEngineComponents[componentName]
    if not component then
        warn(`[ENGINE::EngineEnvironmentManager/GetEngineComponent] Engine component ${componentName} not found`)
        return nil
    end
    return component
end

--- Retrieves a game component by name
--- @param componentName string
--- @return EngineTypes.GameComponent?
function EngineEnvironmentManager:GetGameComponent(componentName: string): EngineTypes.GameComponent?
    local component = LoadedGameComponents[componentName]
    if not component then
        warn(`[ENGINE::EngineEnvironmentManager/GetGameComponent] Game component ${componentName} not found`)
        return nil
    end
    return component
end

--- Retrieves all loaded modules (both engine and game components)
--- @return {[string]: EngineTypes.ComponentLifecycle}
function EngineEnvironmentManager:GetLoadedModules(): {[string]: EngineTypes.ComponentLifecycle}
    local allComponents = table.clone(LoadedEngineComponents) :: {[string]: EngineTypes.ComponentLifecycle}
    for k, v in pairs(LoadedGameComponents) do
        allComponents[k] = v
    end
    return allComponents
end

--- Gets the standard environment for the engine
--- @param runningOn LuaSourceContainer
--- @return {[string]: any}
function EngineEnvironmentManager:GetStandardEnvironment(runningOn: LuaSourceContainer): {[string]: any}
    local isStudio = RunService:IsStudio()
	local standardEnv: {[string]: any} 
    standardEnv = {
        Enum = Enum,
        game = game,
        workspace = workspace,
        script = runningOn,  -- Use runningOn here
        tick = tick,
        time = time,
        typeof = typeof,
        warn = warn,
        UserSettings = UserSettings,
        elapsedTime = elapsedTime,
        gcinfo = gcinfo,
        bit32 = bit32,
        debug = debug,
        math = math,
        SharedTable = SharedTable,
        OverlapParams = OverlapParams,
        table = table,
        os = os,
        string = string,
        utf8 = utf8,
        coroutine = coroutine,
        Instance = Instance,
        getfenv = getfenv,
        setfenv = setfenv,
        xpcall = xpcall,
        pcall = pcall,
        ipairs = ipairs,
        pairs = pairs,
        next = next,
        newproxy = newproxy,
        loadstring = loadstring,
        print = print,
        error = error,
        collectgarbage = collectgarbage,
        select = select,
        getmetatable = getmetatable,
        setmetatable = setmetatable,
        rawget = rawget,
        rawset = rawset,
        rawlen = rawlen,
        tonumber = tonumber,
        tostring = tostring,
        type = type,
        assert = assert,
        unpack = unpack,
        _VERSION = _VERSION,
        TweenInfo = TweenInfo,
        Ray = Ray,
        RaycastParams = RaycastParams,
        RotationCurveKey = RotationCurveKey,
        CFrame = CFrame,
        Vector3 = Vector3,
        Vector3int16 = Vector3int16,
        Vector2 = Vector2,
        Vector2int16 = Vector2int16,
        UDim = UDim,
        UDim2 = UDim2,
        Color3 = Color3,
        ColorSequence = ColorSequence,
        ColorSequenceKeypoint = ColorSequenceKeypoint,
        BrickColor = BrickColor,
        Font = Font,
        Random = Random,
		require = function(...)
			standardEnv.task.synchronize() -- Use hooked task.synchronize
			if isStudio then
				print(
					string.format(
						"[VEngine::Hooks::require] Requiring Instance -> '%s' | Issuer: '%s'; Called By: %s:%d",
						typeof(select(1, ...)) == "Instance" and select(1, ...):GetFullName(),
						RunService:IsClient() and "Roblox Client" or "Roblox Server",
						debug.info(2, "sl")
					)
				)
			end
			
			local m = require(...)

			if typeof(m) == "table" and typeof(m.ModuleName) == "string" then
				error(
					string.format(
						"WARNING! You are requiring a module whilist it being a VEngine module. This is not intended behaviour. You should use the EngineEnvironmentManager to get the module instead!; Caller: %s:%d",
						debug.info(2, "sl")
					),
					4
				)
				return nil
			end
			return m
		end,
		task = {
			cancel = task.cancel,
			spawn = function(f: thread | () -> (), ...)
				local t = task.spawn(f, ...)
				if isStudio then
					print(
						string.format(
							"[VEngine::Hook::task_spawn] Initializing new thread from '%s'. Running @ '%s'; Called By: %s:%d",
							tostring(f),
							tostring(t),
							debug.info(2, "sl")
						)
					)
				end
				return t
			end,
			defer = task.defer,
			wait = task.wait,
			delay = task.delay,
			desynchronize = function()
				if isStudio then
					print(
						string.format(
							"[VEngine::Hooks::task_desynchronize] Desynchronizing '%s' into the next parallel cycle.; Called By: %s:%d",
							tostring(coroutine.running()),
							debug.info(2, "sl")
						)
					)
				end
				task.desynchronize()
			end,
			synchronize = function()
				if isStudio then
					print(
						string.format(
							"[VEngine::Hooks::task_synchronize] Synchronizing '%s' into the next serial cycle.; Called By: %s:%d",
							tostring(coroutine.running()),
							debug.info(2, "sl")
						)
					)
				end
				task.synchronize()
			end,
		},
    }

    return standardEnv
end

--- Constructs the engine environment
--- @param baseEnvironment table
--- @return EngineTypes.EngineEnvironment
local function ConstructEngineEnvironment(baseEnvironment: {[string]: any}): EngineTypes.EngineEnvironment
    local engineEnvironment = EngineUtilities.DeepClone(baseEnvironment) :: EngineTypes.EngineEnvironment

    for i, v in pairs(EngineEnvironmentManager:GetStandardEnvironment(script)) do
        engineEnvironment[i] = v
    end

    -- Add individual EngineUtilities functions to the environment
    engineEnvironment.EngineUtilities = table.clone(EngineUtilities)

    -- Load external packages
    local packages = {
        RedNetworking = 'Red',
        Signal = 'Signal',
        Promise = 'Promise',
        Bin = 'Bin'
    }

    local packagesFolder = ReplicatedStorage:FindFirstChild("Packages")
    if packagesFolder and packagesFolder:IsA("Folder") then
        for key, packageName in pairs(packages) do
            local packageModule = packagesFolder:FindFirstChild(packageName)
            if packageModule and packageModule:IsA("ModuleScript") then
                local success, result = pcall(require, packageModule)
                if success then
                    engineEnvironment[key] = result
                    print(string.format("Loaded package: %s. Type: %s", packageName, type(result)))
                else
                    warn("Failed to load package: " .. packageName .. ". Error: " .. tostring(result))
                end
            else
                warn("Package not found: " .. packageName)
            end
        end
    else
        warn("Packages folder not found in ReplicatedStorage")
    end
    
    return engineEnvironment
end

--- Gets the engine globals
--- @return EngineTypes.EngineEnvironment
function EngineEnvironmentManager.GetEngineGlobals(): EngineTypes.EngineEnvironment
    local environment = ConstructEngineEnvironment({})
    return (table.freeze(environment) :: any) :: EngineTypes.EngineEnvironment
end

return (table.freeze(EngineEnvironmentManager) :: any) :: EngineTypes.EngineEnvironmentManager