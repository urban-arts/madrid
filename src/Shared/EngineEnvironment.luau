local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Framework = script.Parent.Parent
local EngineTypes = require(Framework.Shared.EngineTypes)
local EngineUtilities = require(Framework.Shared.EngineUtilities)

local EngineEnvironmentManager = {} :: EngineTypes.EngineEnvironmentManager
local LoadedEngineComponents: {[string]: EngineTypes.EngineCoreComponent} = {}
local LoadedGameComponents: {[string]: EngineTypes.GameComponent} = {}

function EngineEnvironmentManager:AddEngineComponent(engineComponent: EngineTypes.EngineCoreComponent)
    LoadedEngineComponents[engineComponent.ComponentName] = engineComponent
    print(string.format("Added engine component: %s. Initialize: %s, Start: %s", 
        engineComponent.ComponentName,
        tostring(type(engineComponent.initialize) == "function"),
        tostring(type(engineComponent.start) == "function")
    ))
end

function EngineEnvironmentManager:AddGameComponent(gameComponent: EngineTypes.GameComponent)
    LoadedGameComponents[gameComponent.ComponentName] = gameComponent
    print(string.format("Added game component: %s. Initialize: %s, Start: %s", 
        gameComponent.ComponentName,
        tostring(type(gameComponent.initialize) == "function"),
        tostring(type(gameComponent.start) == "function")
    ))
end

function EngineEnvironmentManager:GetEngineComponent(componentName: string): EngineTypes.EngineCoreComponent?
    local component = LoadedEngineComponents[componentName]
    if not component then
        warn(`[ENGINE::EngineEnvironmentManager/GetEngineComponent] Engine component ${componentName} not found`)
        return nil
    end
    return component
end

function EngineEnvironmentManager:GetGameComponent(componentName: string): EngineTypes.GameComponent?
    local component = LoadedGameComponents[componentName]
    if not component then
        warn(`[ENGINE::EngineEnvironmentManager/GetGameComponent] Game component ${componentName} not found`)
        return nil
    end
    return component
end

function EngineEnvironmentManager:GetLoadedModules(): { [string]: EngineTypes.ComponentLifecycle }
    local allComponents = table.clone(LoadedEngineComponents)
    for k, v in pairs(LoadedGameComponents) do
        allComponents[k] = v
    end
    return allComponents
end

function EngineEnvironmentManager:GetStandardEnvironment(runningOn: LuaSourceContainer): any
    local isStudio = RunService:IsStudio()
    local env
    env = {
        Enum = Enum,
        game = game,
        workspace = workspace,
        script = runningOn,
        require = function(...)
			env.task.synchronize() -- Use hooked task.synchronize
			if isStudio then
				print(
					string.format(
						"[Engine::Hooks::require] Requiring Instance -> '%s' | Issuer: '%s'; Called By: %s:%d",
						typeof(select(1, ...)) == "Instance" and select(1, ...):GetFullName(),
						RunService:IsClient() and "Roblox Client" or "Roblox Server",
						debug.info(2, "sl")
					)
				)
			end
			local m = require(...)

			if typeof(m) == "table" and typeof(m.ComponentName) == "string" then
				error(
					string.format(
						"WARNING! You are requiring a component whilist it being a Engine component. This is not intended behaviour. You should use the EngineEnvironmentManager to get the module instead!; Caller: %s:%d",
						debug.info(2, "sl")
					),
					4
				)
				return nil
			end
			return m
		end,
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
		task = {
			cancel = task.cancel,
			spawn = function(f: thread | () -> (), ...)
				local t = task.spawn(f, ...)
				if isStudio then
					print(
						string.format(
							"[Engine::Hook::task_spawn] Initializing new thread from '%s'. Running @ '%s'; Called By: %s:%d",
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
							"[Engine::Hooks::task_desynchronize] Desynchronizing '%s' into the next parallel cycle.; Called By: %s:%d",
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
							"[Engine::Hooks::task_synchronize] Synchronizing '%s' into the next serial cycle.; Called By: %s:%d",
							tostring(coroutine.running()),
							debug.info(2, "sl")
						)
					)
				end
				task.synchronize()
			end,
		},
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
		-- Deprecated
		-- _G = _G,
		_VERSION = _VERSION,

		-- Additional API tables.
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
	}

    return env
end

local function ConstructEngineEnvironment(baseEnvironment: {})
    local engineEnvironment = EngineUtilities.DeepClone(baseEnvironment) :: EngineTypes.RBXEnvironment

    for i, v in pairs(EngineEnvironmentManager:GetStandardEnvironment(script)) do
        engineEnvironment[i] = v
    end

    -- Load external packages
    local packages = {
        RedNetworking = 'Red',
        Signal = 'Signal',
        Promise = 'Promise',
        Bin = 'Bin'
    }

    for key, packageName in pairs(packages) do
        local success, result = pcall(function()
            return require(ReplicatedStorage.Packages:WaitForChild(packageName))
        end)
        if success then
            engineEnvironment[key] = result
            print(string.format("Loaded package: %s. Type: %s", packageName, type(result)))
        else
            warn("Failed to load package: " .. packageName .. ". Error: " .. tostring(result))
        end
    end
    
    return engineEnvironment
end

function EngineEnvironmentManager.GetEngineGlobals(): EngineTypes.EngineEnvironment
    local environment = ConstructEngineEnvironment({})
    return (table.freeze(environment) :: any) :: EngineTypes.EngineEnvironment
end

return (table.freeze(EngineEnvironmentManager) :: any) :: EngineTypes.EngineEnvironmentManager