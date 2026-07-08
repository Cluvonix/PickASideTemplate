local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TeamService = require(script.Parent.TeamService)
local GameConfig = require(ReplicatedStorage.Shared.Configs.GameConfig)
local Network = require(ReplicatedStorage.Shared.Utils.Network)

local states = {
	WaitingForPlayers = "WaitingForPlayers",
	Intermission = "Intermission",
	Active = "Active",
	Finished = "Finished",
	ChooseSide = "ChooseSide",
}

local roundConfig = GameConfig.RoundConfig
local state = "Intermission"
local redPad = workspace:WaitForChild("RedPad")
local bluePad = workspace:WaitForChild("BluePad")
local redSpawnPad = workspace:WaitForChild("RedSpawnPad")
local blueSpawnPad = workspace:WaitForChild("BlueSpawnPad")
local spawnLocation = workspace:WaitForChild("SpawnLocation")
local teamNames = { "Red", "Blue" }
local teamSpawns = {
	Red = redSpawnPad,
	Blue = blueSpawnPad,
}

local RoundService = {}

--[[METHODS]]
local function forEachTeamPlayer(callback)
	for _, teamName in ipairs(teamNames) do
		for _, player in ipairs(TeamService.GetPlayersOnTeam(teamName)) do
			callback(player, teamName)
		end
	end
end

local function bindPadTouch(pad, teamName)
	pad.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player and RoundService.IsState(states.ChooseSide) then
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
		print("State changed to:", newState)
	else
		warn("Invalid state: " .. tostring(newState))
	end
end

function RoundService.IsState(checkState)
	return state == checkState
end

local function startStateCountdown()
	local countDownTime = roundConfig[state .. "Time"]

	while countDownTime > 0 do
		local amountOfPlayers = #Players:GetPlayers()
		if amountOfPlayers < 2 then
			print("Not enough players to continue the round. Ending round early.")
			return false
		end


		task.wait(1)
		countDownTime -= 1
	end

	return true
end

--[[ROUND FLOW]]
function RoundService.WaitingForPlayers()
	RoundService.SetState(states.WaitingForPlayers)

	while #Players:GetPlayers() < 2 do
		task.wait(1)
	end

	return true
end

function RoundService.Intermission()
	RoundService.SetState(states.Intermission)

	task.wait(roundConfig.IntermissionTime)

	return true
end

function RoundService.ChooseSide()
	RoundService.SetState(states.ChooseSide)

	Network:FireAllClients("InvisPlayer", Players:GetChildren(), true)
	task.wait(roundConfig.ChooseSideTime)

	Network:FireAllClients("InvisPlayer", Players:GetChildren(), false)

	return true
end

function RoundService.StartRound()
	RoundService.SetState(states.Active)

	forEachTeamPlayer(function(player, teamName)
		local character = player.Character
		local spawnPad = teamSpawns[teamName]
		if character and spawnPad then
			character:PivotTo(spawnPad.CFrame + Vector3.new(0, 5, 0))
		end
	end)

	local completed = startStateCountdown()

	return completed
end

function RoundService.EndRound()
	RoundService.SetState(states.Finished)

	forEachTeamPlayer(function(player)
		TeamService.SetPlayersTeam(player, "Neutral")

		local character = player.Character
		if character then
			character:PivotTo(spawnLocation.CFrame + Vector3.new(0, 5, 0))
		end
	end)

	return true
end


function RoundService.Run()
	local completed = RoundService.WaitingForPlayers()
	if not completed then 
		warn("Not enough players to start the round.")
		return
	end

	completed = RoundService.Intermission()
	if not completed then
		warn("Intermission did not complete.")
		return
	end

	completed = RoundService.ChooseSide()
	if not completed then
		warn("Choose-side phase did not complete.")
		return
	end

	completed = RoundService.StartRound()
	if not completed then
		warn("Round did not complete.")
		return
	end

	completed = RoundService.EndRound()
	if not completed then
		warn("End-round cleanup did not complete.")
		return
	end
end

--[[INIT]]
function RoundService.Init()
	bindPadTouch(redPad, "Red")
	bindPadTouch(bluePad, "Blue")

	task.spawn(function()
		while true do
			RoundService.Run()
		end
	end)
end

return RoundService
