---!strict

local Players = game:GetService("Players")

local TeamService = {}

export type TeamName = "Red" | "Blue" | "Neutral"

local VALID_TEAMS: {[TeamName]: true} = {
    Red = true,
    Blue = true,
    Neutral = true,
}

local playerTeams: {[number]: TeamName} = {}

function TeamService.GetTeamFromPlayer(player): TeamName
    return playerTeams[player.UserId] or "Neutral"
end

function TeamService.GetPlayersOnTeam(teamName: TeamName): {Player}
    local playersOnTeam: {Player} = {}

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
