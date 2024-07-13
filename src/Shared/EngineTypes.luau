--!strict
--[[
    Open Source 2023 - All Rights Reserved
    This module defines the types used throughout the engine.
]]

--- @class ClientFramework
--- @field ClientRunner ClientRunner
export type ClientFramework = {
    ClientRunner: ClientRunner
}

--- @class ServerFramework
--- @field ServerRunner ServerRunner
export type ServerFramework = {
    ServerRunner: ServerRunner
}

--- @class SharedFramework
--- @field EngineTypes table
export type SharedFramework = {
    EngineTypes: any,
    -- Add other shared modules here
}

--- @class ComponentLifecycle
--- @field initialize fun(self: ComponentLifecycle, envManager: EngineEnvironmentManager)
--- @field start fun(self: ComponentLifecycle, envManager: EngineEnvironmentManager)
--- @field update fun(self: ComponentLifecycle, dt: number)?
--- @field stop fun(self: ComponentLifecycle)?
--- @field ComponentName string
--- @field LoadOrder number
--- @field IsEngineComponent boolean?
--- @field IsGameComponent boolean?
export type ComponentLifecycle = {
    initialize: (self: ComponentLifecycle, envManager: EngineEnvironmentManager) -> (),
    start: (self: ComponentLifecycle, envManager: EngineEnvironmentManager) -> (),
    update: ((self: ComponentLifecycle, dt: number) -> ())?,
    stop: ((self: ComponentLifecycle) -> ())?,
    ComponentName: string,
    LoadOrder: number,
    IsEngineComponent: boolean?,
    IsGameComponent: boolean?,
}

--- @class EngineCoreComponent : ComponentLifecycle
--- @field IsEngineComponent true
export type EngineCoreComponent = ComponentLifecycle & {
    IsEngineComponent: true,
}

--- @class GameComponent : ComponentLifecycle
--- @field IsGameComponent true
export type GameComponent = ComponentLifecycle & {
    IsGameComponent: true,
}

--- @class ServerRunner
--- @field Start fun()
--- @field __loadComponents fun()
--- @field __initializeComponents fun()
--- @field __startComponents fun()
--- @field __updateComponents fun(dt: number)
--- @field __stopComponents fun()
export type ServerRunner = {
    Start: () -> (),
    __loadComponents: () -> (),
    __initializeComponents: () -> (),
    __startComponents: () -> (),
    __updateComponents: (dt: number) -> (),
    __stopComponents: () -> (),
}

--- @class ClientRunner
--- @field Start fun()
--- @field __loadComponents fun()
--- @field __initializeComponents fun()
--- @field __startComponents fun()
--- @field __updateComponents fun(dt: number)
--- @field __stopComponents fun()
export type ClientRunner = {
    Start: () -> (),
    __loadComponents: () -> (),
    __initializeComponents: () -> (),
    __startComponents: () -> (),
    __updateComponents: (dt: number) -> (),
    __stopComponents: () -> (),
}

--- @class EngineEnvironmentManager
--- @field AddEngineComponent fun(self: EngineEnvironmentManager, component: EngineCoreComponent)
--- @field AddGameComponent fun(self: EngineEnvironmentManager, component: GameComponent)
--- @field GetEngineComponent fun(self: EngineEnvironmentManager, componentName: string): EngineCoreComponent?
--- @field GetGameComponent fun(self: EngineEnvironmentManager, componentName: string): GameComponent?
--- @field GetLoadedModules fun(self: EngineEnvironmentManager): {[string]: ComponentLifecycle}
--- @field GetStandardEnvironment fun(self: EngineEnvironmentManager, runningOn: LuaSourceContainer): any
--- @field GetEngineGlobals fun(): EngineEnvironment
export type EngineEnvironmentManager = {
    AddEngineComponent: (self: EngineEnvironmentManager, component: EngineCoreComponent) -> (),
    AddGameComponent: (self: EngineEnvironmentManager, component: GameComponent) -> (),
    GetEngineComponent: (self: EngineEnvironmentManager, componentName: string) -> EngineCoreComponent?,
    GetGameComponent: (self: EngineEnvironmentManager, componentName: string) -> GameComponent?,
    GetLoadedModules: (self: EngineEnvironmentManager) -> { [string]: ComponentLifecycle },
    GetStandardEnvironment: (self: EngineEnvironmentManager, runningOn: LuaSourceContainer) -> any,
    GetEngineGlobals: () -> EngineEnvironment
}

--- @class RBXEnvironment
export type RBXEnvironment = {
	

}

--- @class EngineEnvironment : RBXEnvironment
export type EngineEnvironment = {
    -- ... other fields ...
    EngineUtilities: typeof(require(script.Parent.EngineUtilities))
}

--- @enum ComponentType
export type ComponentType = {
    Game: "Game",
    Engine: "Engine"
}

--- @enum FrameworkEnvironment
export type FrameworkEnvironment = {
    Client: "Client",
    Server: "Server",
    Shared: "Shared"
}

return {}