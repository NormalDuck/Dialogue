--!native
local DialogueClient = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local components = script.Parent:WaitForChild("components")
local Dialogue = require(components.Dialogue)

local New = Fusion.New
local Children = Fusion.Children

local Main = New("ScreenGui")({
	Parent = Players.LocalPlayer.PlayerGui,
})
return DialogueClient
