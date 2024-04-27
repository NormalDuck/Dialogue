--!native
local DialogueClient = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local components = script.Parent:WaitForChild("components")
local Dialogue = require(components.Dialogue)

local New = Fusion.New

return DialogueClient
