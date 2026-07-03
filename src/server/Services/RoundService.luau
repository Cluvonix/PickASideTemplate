local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TeamService = require(script.Parent.TeamService)
local GameConfig = require(ReplicatedStorage.Shared.Configs.GameConfig)

local states = {
    Intermission = "Intermission",
    Active = "Active",
    Finished = "Finished",
    ChooseSide = "ChooseSide",
}

local roundConfig = GameConfig.RoundConfig
local state = "Intermission"
local redPad = workspace:WaitForChild("RedPad")
local bluePad = workspace:WaitForChild("BluePad")

local RoundService = {}

--[[METHODS]]
local function bindPadTouch(pad, teamName)
    pad.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            TeamService.SetPlayersTeam(player, teamName)
        end
    end)
end

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

--[[ROUND FLOW]]
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

--[[INIT]]
function RoundService.Init()
    bindPadTouch(redPad, "Red")
    bindPadTouch(bluePad, "Blue")

    task.spawn(function()
        RoundService.Intermission()
    end)
end

return RoundService