--!strict
-- Main — server bootstrap. The only Script on the server; everything else is a
-- ModuleScript with an .Init().
--
-- Init order matters and is not arbitrary:
--   Remotes      creates the RemoteEvent folder clients are already waiting on
--   WorldBuilder must run before any service that looks up plots or the yard
--   PlayerData   must be ready before a player can be assigned a plot
--   House        after WorldBuilder, which builds the spots it wires prompts to
--   Customer     next, because its loops reference plots and player data
--   DevCommands  last; it only wires ServerStorage.SMJDev into the services above

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
require(Shared:WaitForChild("Remotes"))

local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local PlotService = require(script.Parent:WaitForChild("PlotService"))
local HouseService = require(script.Parent:WaitForChild("HouseService"))
local ScavengeService = require(script.Parent:WaitForChild("ScavengeService"))
local CustomerService = require(script.Parent:WaitForChild("CustomerService"))
local DevCommands = require(script.Parent:WaitForChild("DevCommands"))

WorldBuilder.Build()

PlayerDataService.Init()
PlotService.Init()
HouseService.Init()
ScavengeService.Init()
CustomerService.Init()
DevCommands.Init()

local function onPlayerAdded(player: Player)
	-- Load can fail (session locked by another server, DataStore down) and kicks
	-- the player when it does. Everything below assumes loaded data, so stop here.
	if not PlayerDataService.Load(player) then
		return
	end

	PlotService.AssignPlot(player)
	PlotService.RenderPlot(player)
	PlotService.Sync(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- In Studio the first player can join before this script finishes running.
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

print("[SellMyJunk] server ready")
