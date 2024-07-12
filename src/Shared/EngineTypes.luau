--!strict
--[[
    Open Source 2023 - All Rights Reserved
    This module defines the types used throughout the engine.
]]

export type ClientFramework = {
    ClientRunner: ClientRunner
}

export type ServerFramework = {
    ServerRunner: ServerRunner
}

export type SharedFramework = {
    EngineTypes: any,
    -- Add other shared modules here
}

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

export type EngineCoreComponent = ComponentLifecycle & {
    IsEngineComponent: true,
}

export type GameComponent = ComponentLifecycle & {
    IsGameComponent: true,
}

export type ServerRunner = {
    Start: () -> (),
    __loadComponents: () -> (),
    __initializeComponents: () -> (),
    __startComponents: () -> (),
    __updateComponents: (dt: number) -> (),
    __stopComponents: () -> (),
}

export type ClientRunner = {
    Start: () -> (),
    __loadComponents: () -> (),
    __initializeComponents: () -> (),
    __startComponents: () -> (),
    __updateComponents: (dt: number) -> (),
    __stopComponents: () -> (),
}

export type EngineEnvironmentManager = {
    AddEngineComponent: (self: EngineEnvironmentManager, component: EngineCoreComponent) -> (),
    AddGameComponent: (self: EngineEnvironmentManager, component: GameComponent) -> (),
    GetEngineComponent: (self: EngineEnvironmentManager, componentName: string) -> EngineCoreComponent?,
    GetGameComponent: (self: EngineEnvironmentManager, componentName: string) -> GameComponent?,
    GetLoadedModules: (self: EngineEnvironmentManager) -> { [string]: ComponentLifecycle },
    GetStandardEnvironment: (self: EngineEnvironmentManager, runningOn: LuaSourceContainer) -> any,
    GetEngineGlobals: () -> EngineEnvironment
}

export type RBXEnvironment = {
    -- Define properties of the Roblox environment here
}

export type EngineEnvironment = RBXEnvironment & {
    -- Add custom properties for your engine environment
}

export type ComponentType = {
    Game: "Game",
    Engine: "Engine"
}

export type FrameworkEnvironment = {
    Client: "Client",
    Server: "Server",
    Shared: "Shared"
}

return {}