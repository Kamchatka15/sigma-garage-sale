--!strict
-- Remotes — the client/server messaging boundary, defined in one place.
--
-- WHY a module instead of dragging RemoteEvents into Studio by hand:
-- the remote list becomes code, which means it's in git, reviewable in a diff,
-- and impossible to typo into a silent failure.
--
-- SECURITY: every one of these carries data from the client, which is to say
-- from a machine you do not control. Server handlers validate everything.
-- See CLAUDE.md — "Never trust the client."

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

-- Server -> Client
local DOWNSTREAM = {
	"SyncData", -- full player state after any change
	"Notify", -- transient toast message
	"NearMiss", -- a customer declined; here's why
	"Sale", -- a customer bought; celebrate
}

-- Client -> Server
local UPSTREAM = {
	"PlaceItem", -- (bagUid: string, shelfIndex: number)
	"TakeItem", -- (shelfIndex: number)
	"SetPrice", -- (shelfIndex: number, price: number)
	"BuyUpgrade", -- (upgradeId: string)
}

local folder: Instance

if RunService:IsServer() then
	local existing = ReplicatedStorage:FindFirstChild("Remotes")
	if existing then
		folder = existing
	else
		local created = Instance.new("Folder")
		created.Name = "Remotes"
		created.Parent = ReplicatedStorage
		folder = created
	end

	for _, name in DOWNSTREAM do
		if not folder:FindFirstChild(name) then
			local event = Instance.new("RemoteEvent")
			event.Name = name
			event.Parent = folder
		end
	end
	for _, name in UPSTREAM do
		if not folder:FindFirstChild(name) then
			local event = Instance.new("RemoteEvent")
			event.Name = name
			event.Parent = folder
		end
	end
else
	folder = ReplicatedStorage:WaitForChild("Remotes")
end

function Remotes.Get(name: string): RemoteEvent
	return folder:WaitForChild(name, 10) :: RemoteEvent
end

return Remotes
