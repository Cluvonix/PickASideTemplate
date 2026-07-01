local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Configs.GameConfig)

local states = {
    Intermission = "Intermission",
    Active = "Active",
    Finished = "Finished",
    ChooseSide = "ChooseSide",
}

local roundConfig = GameConfig.RoundConfig
local state = "Intermission"

local RoundService = {}

function RoundService.GetState()
    return state
end

function RoundService.SetState(newState)
    if states[newState] then
        state = newState
    else
        warn("Invalid state: " .. tostring(newState))
    end
end

function RoundService.IsState(checkState)
    return state == checkState
end

function RoundService.Intermission()
    RoundService.SetState(states.Intermission)

    task.wait(roundConfig.IntermissionTime)

    RoundService.ChooseSide()
end

function RoundService.ChooseSide()
    RoundService.SetState(states.ChooseSide)

    task.wait(roundConfig.ChooseSideTime)

    RoundService.StartRound()
end

function RoundService.StartRound()
    RoundService.SetState(states.Active)

    task.wait(roundConfig.RoundTime)

    RoundService.CleanUp()
end

function RoundService.CleanUp()
    RoundService.SetState(states.Finished)

    task.wait(roundConfig.RoundEndDelay)

    RoundService.Intermission()
end

function RoundService.Init()
    task.spawn(function()
        RoundService.Intermission()
    end)
end

return RoundService