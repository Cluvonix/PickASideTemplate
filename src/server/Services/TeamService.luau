---!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage.Assets
local uiAssets = assets.UI

local RED_COLOR = Color3.fromRGB(255, 0, 0)
local BLUE_COLOR = Color3.fromRGB(0, 0, 255)

local TeamService = {}

export type TeamName = "Red" | "Blue" | "Neutral"

local VALID_TEAMS: { [TeamName]: true } = {
	Red = true,
	Blue = true,
	Neutral = true,
}

local playerTeams: { [number]: TeamName } = {}

local function changeTeamGui(player: Player, teamName: TeamName)
	local playerHead = player.Character and player.Character:FindFirstChild("Head")
	local teamGui = playerHead and playerHead:FindFirstChild("TeamGui")
    print("ur mama")
	if not teamGui then
		teamGui = uiAssets:FindFirstChild("TeamGui"):Clone()
		if playerHead then
			teamGui.Parent = playerHead
		else
			teamGui.Parent = player
		end
	end

	local teamFrame = teamGui:FindFirstChild("TeamFrame")
    if teamFrame then
        if teamName == "Red" then
            teamFrame.BackgroundColor3 = RED_COLOR
            teamFrame.Visible = true
        elseif teamName == "Blue" then
            teamFrame.BackgroundColor3 = BLUE_COLOR
            teamFrame.Visible = true
        else
            teamFrame.Visible = false
        end
    end
end

function TeamService.GetTeamFromPlayer(player): TeamName
	return playerTeams[player.UserId] or "Neutral"
end

function TeamService.GetPlayersOnTeam(teamName: TeamName): { Player }
	local playersOnTeam: { Player } = {}

	for _, player in Players:GetPlayers() do
		if TeamService.GetTeamFromPlayer(player) == teamName then
			table.insert(playersOnTeam, player)
		end
	end

	return playersOnTeam
end

function TeamService.SetPlayersTeam(player, teamName: TeamName)
	if not VALID_TEAMS[teamName] then
		warn("TeamService.SetPlayersTeam received invalid team: " .. tostring(teamName))
		return false
	end

	if TeamService.GetTeamFromPlayer(player) == teamName then
		return false
	end

	playerTeams[player.UserId] = teamName
	player.Team = nil

    changeTeamGui(player, teamName)

	print(player.Name .. " has been assigned to team " .. teamName)
	return true
end

function TeamService.Init()
	Players.PlayerAdded:Connect(function(player)
		TeamService.SetPlayersTeam(player, "Neutral")
	end)

	Players.PlayerRemoving:Connect(function(player)
		playerTeams[player.UserId] = nil
	end)

	for _, player in Players:GetPlayers() do
		TeamService.SetPlayersTeam(player, "Neutral")
	end
end

return TeamService
