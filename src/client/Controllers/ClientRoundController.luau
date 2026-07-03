local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Utils.Network)

local ClientRoundController = {}

function ClientRoundController.Init()
    Network
end

return ClientRoundController