local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Utils.Network)
local TeamService = require(script.Services.TeamService)
local RoundService = require(script.Services.RoundService)

Network.Init()
TeamService.Init()
RoundService.Init()