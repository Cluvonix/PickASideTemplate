local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Utils.Network)

local localPlayer = Players.LocalPlayer

local ClientRoundController = {}

function ClientRoundController.Init()
    Network:GetRemote("InvisPlayer").OnClientEvent:Connect(function(players, invis)
        for _, player in ipairs(players) do
            if player ~= localPlayer then
                if player and player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = invis and 1 or 0
                        end
                    end
                end
            end
        end
    end)
end

return ClientRoundController