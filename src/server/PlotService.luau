--!strict
-- PlotService — owns stall assignment, shelf contents, and every client request
-- that changes them.
--
-- SECURITY POSTURE: every handler below assumes the client is lying. Indices
-- get range-checked, prices get clamped, item UIDs get verified against the
-- player's actual bag. A client that sends {shelfIndex = -1, price = math.huge}
-- should accomplish nothing. Exploiters will absolutely send exactly that.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local ItemDatabase = require(Shared:WaitForChild("ItemDatabase"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))

local PlotService = {}

local plotOwners: { [Model]: Player? } = {}
local playerPlots: { [Player]: Model } = {}

--------------------------------------------------------------------
-- Client state
--------------------------------------------------------------------

local function buildKnowledgeView(data: PlayerDataService.SaveData)
	local view = {}
	for itemId, entry in data.knowledge do
		local tier = PlayerDataService.KnowledgeTier(data, itemId)
		local item = ItemDatabase.Get(itemId)
		view[itemId] = {
			tier = tier,
			sales = entry.sales,
			last = entry.last,
			best = entry.best,
			average = if entry.sales > 0 then math.floor(entry.total / entry.sales) else 0,
			-- Base value is the reward for full appraisal. Sending it earlier
			-- would let a modified client read it straight off the wire and
			-- skip the entire progression system.
			baseValue = if tier == "appraised" and item then item.baseValue else nil,
		}
	end
	return view
end

function PlotService.BuildClientState(player: Player)
	local data = PlayerDataService.Get(player)
	if not data then
		return nil
	end

	local upgradeCosts = {}
	for id, def in Config.Upgrades do
		local level = data.upgrades[id] or 0
		upgradeCosts[id] = {
			level = level,
			maxLevel = def.maxLevel,
			cost = if level < def.maxLevel then def.cost(level) else nil,
			name = def.name,
			desc = def.desc,
		}
	end

	return {
		cash = data.cash,
		bag = data.bag,
		shelves = data.shelves,
		shelfCapacity = PlayerDataService.ShelfCapacity(data),
		bagCapacity = PlayerDataService.BagCapacity(data),
		upgrades = upgradeCosts,
		knowledge = buildKnowledgeView(data),
		stats = data.stats,
	}
end

function PlotService.Sync(player: Player)
	local state = PlotService.BuildClientState(player)
	if state then
		Remotes.Get("SyncData"):FireClient(player, state)
	end
end

local function notify(player: Player, text: string, kind: string?)
	Remotes.Get("Notify"):FireClient(player, text, kind or "info")
end

--------------------------------------------------------------------
-- Rendering
--------------------------------------------------------------------

local function clearShelf(shelf: BasePart)
	local existing = shelf:FindFirstChild("Display")
	if existing then
		existing:Destroy()
	end
end

local function renderShelf(shelf: BasePart, entry: PlayerDataService.ShelfEntry?)
	clearShelf(shelf)
	if not entry then
		return
	end

	local item = ItemDatabase.Get(entry.itemId)
	if not item then
		return
	end

	local display = Instance.new("Part")
	display.Name = "Display"
	display.Size = Vector3.new(1.4, 1.4, 1.4)
	display.CFrame = shelf.CFrame * CFrame.new(0, 0.9, 0)
	display.Anchored = true
	display.CanCollide = false
	display.Material = Enum.Material.SmoothPlastic
	display.Color = ItemDatabase.GetRarityColor(item.rarity)
	display.Parent = shelf

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(190, 58)
	billboard.StudsOffset = Vector3.new(0, 2.1, 0)
	billboard.AlwaysOnTop = false
	billboard.MaxDistance = 60
	billboard.Parent = display

	local name = Instance.new("TextLabel")
	name.Size = UDim2.fromScale(1, 0.55)
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.GothamBold
	name.TextScaled = true
	name.TextColor3 = Color3.new(1, 1, 1)
	name.TextStrokeTransparency = 0.4
	name.Text = item.name
	name.Parent = billboard

	local price = Instance.new("TextLabel")
	price.Position = UDim2.fromScale(0, 0.55)
	price.Size = UDim2.fromScale(1, 0.45)
	price.BackgroundTransparency = 1
	price.Font = Enum.Font.FredokaOne
	price.TextScaled = true
	price.TextColor3 = Color3.fromRGB(120, 255, 140)
	price.TextStrokeTransparency = 0.4
	price.Text = "$" .. entry.price
	price.Parent = billboard
end

function PlotService.RenderPlot(player: Player)
	local plot = playerPlots[player]
	local data = PlayerDataService.Get(player)
	if not plot or not data then
		return
	end

	local shelvesFolder = plot:FindFirstChild("Shelves")
	if not shelvesFolder then
		return
	end

	local capacity = PlayerDataService.ShelfCapacity(data)

	for _, shelf in shelvesFolder:GetChildren() do
		if shelf:IsA("BasePart") then
			local index = shelf:GetAttribute("ShelfIndex") :: number
			local unlocked = index <= capacity

			shelf.Transparency = if unlocked then 0 else 1
			shelf.CanCollide = unlocked

			if unlocked then
				renderShelf(shelf, data.shelves[tostring(index)])
			else
				clearShelf(shelf)
			end
		end
	end
end

local function setSign(plot: Model, text: string)
	local sign = plot:FindFirstChild("Sign")
	local gui = sign and sign:FindFirstChild("SignGui")
	local label = gui and gui:FindFirstChild("OwnerLabel")
	if label and label:IsA("TextLabel") then
		label.Text = text
	end
end

--------------------------------------------------------------------
-- Plot assignment
--------------------------------------------------------------------

function PlotService.AssignPlot(player: Player): Model?
	for _, plot in WorldBuilder.GetPlots() do
		if plotOwners[plot] == nil then
			plotOwners[plot] = player
			playerPlots[player] = plot
			setSign(plot, player.DisplayName .. "'S JUNK")
			return plot
		end
	end

	notify(player, "All stalls are taken right now. Try another server.", "bad")
	return nil
end

function PlotService.ReleasePlot(player: Player)
	local plot = playerPlots[player]
	if not plot then
		return
	end

	plotOwners[plot] = nil
	playerPlots[player] = nil
	setSign(plot, "VACANT")

	local shelvesFolder = plot:FindFirstChild("Shelves")
	if shelvesFolder then
		for _, shelf in shelvesFolder:GetChildren() do
			if shelf:IsA("BasePart") then
				clearShelf(shelf)
			end
		end
	end
end

function PlotService.GetPlot(player: Player): Model?
	return playerPlots[player]
end

function PlotService.GetOwner(plot: Model): Player?
	return plotOwners[plot]
end

--------------------------------------------------------------------
-- Bag helpers (used by ScavengeService too)
--------------------------------------------------------------------

function PlotService.AddToBag(player: Player, itemId: string): boolean
	local data = PlayerDataService.Get(player)
	if not data then
		return false
	end

	if #data.bag >= PlayerDataService.BagCapacity(data) then
		return false
	end

	table.insert(data.bag, { uid = PlayerDataService.NewUid(), itemId = itemId })
	PlotService.Sync(player)
	return true
end

local function findInBag(data: PlayerDataService.SaveData, uid: string): number?
	for index, entry in data.bag do
		if entry.uid == uid then
			return index
		end
	end
	return nil
end

--------------------------------------------------------------------
-- Remote handlers — validation lives here
--------------------------------------------------------------------

local function handlePlaceItem(player: Player, uid: unknown, shelfIndex: unknown)
	local data = PlayerDataService.Get(player)
	if not data then
		return
	end

	if type(uid) ~= "string" or type(shelfIndex) ~= "number" then
		return
	end
	if shelfIndex ~= math.floor(shelfIndex) or shelfIndex < 1 then
		return
	end
	if shelfIndex > PlayerDataService.ShelfCapacity(data) then
		return
	end

	local key = tostring(shelfIndex)
	if data.shelves[key] then
		notify(player, "That shelf is occupied.", "bad")
		return
	end

	local bagIndex = findInBag(data, uid)
	if not bagIndex then
		return
	end

	local bagEntry = data.bag[bagIndex]
	local item = ItemDatabase.Get(bagEntry.itemId)
	if not item then
		return
	end

	table.remove(data.bag, bagIndex)

	-- Default asking price must never be derived from the item's true baseValue
	-- unless the player has actually appraised it — otherwise the starting
	-- number IS the answer, and the knowledge progression is dead on arrival.
	local tier = PlayerDataService.KnowledgeTier(data, item.id)
	local known = data.knowledge[item.id]

	local seed: number
	if tier == "appraised" then
		seed = item.baseValue
	elseif known and known.sales > 0 then
		seed = math.floor(known.total / known.sales)
	else
		seed = ItemDatabase.RarityGuess[item.rarity] or 10
	end
	seed = math.max(Config.MinPrice, seed)

	data.shelves[key] = { uid = bagEntry.uid, itemId = bagEntry.itemId, price = seed }

	PlotService.RenderPlot(player)
	PlotService.Sync(player)
end

local function handleTakeItem(player: Player, shelfIndex: unknown)
	local data = PlayerDataService.Get(player)
	if not data then
		return
	end
	if type(shelfIndex) ~= "number" or shelfIndex ~= math.floor(shelfIndex) then
		return
	end

	local key = tostring(shelfIndex)
	local entry = data.shelves[key]
	if not entry then
		return
	end

	if #data.bag >= PlayerDataService.BagCapacity(data) then
		notify(player, "Your bag is full.", "bad")
		return
	end

	data.shelves[key] = nil
	table.insert(data.bag, { uid = entry.uid, itemId = entry.itemId })

	PlotService.RenderPlot(player)
	PlotService.Sync(player)
end

local function handleSetPrice(player: Player, shelfIndex: unknown, price: unknown)
	local data = PlayerDataService.Get(player)
	if not data then
		return
	end
	if type(shelfIndex) ~= "number" or type(price) ~= "number" then
		return
	end
	-- NaN and infinity both fail this comparison, which is the point.
	if price ~= price or price == math.huge or price == -math.huge then
		return
	end

	local key = tostring(shelfIndex)
	local entry = data.shelves[key]
	if not entry then
		return
	end

	local item = ItemDatabase.Get(entry.itemId)
	if not item then
		return
	end

	local ceiling = math.floor(item.baseValue * Config.MaxPriceMultiplier)
	entry.price = math.clamp(math.floor(price), Config.MinPrice, ceiling)

	PlotService.RenderPlot(player)
	PlotService.Sync(player)
end

local function handleBuyUpgrade(player: Player, upgradeId: unknown)
	local data = PlayerDataService.Get(player)
	if not data then
		return
	end
	if type(upgradeId) ~= "string" then
		return
	end

	local def = Config.Upgrades[upgradeId]
	if not def then
		return
	end

	local level = data.upgrades[upgradeId] or 0
	if level >= def.maxLevel then
		notify(player, def.name .. " is maxed out.", "info")
		return
	end

	local cost = def.cost(level)
	if data.cash < cost then
		notify(player, ("Need $%d for %s."):format(cost, def.name), "bad")
		return
	end

	data.cash -= cost
	data.upgrades[upgradeId] = level + 1

	notify(player, def.name .. " upgraded!", "good")
	PlotService.RenderPlot(player)
	PlotService.Sync(player)
end

--------------------------------------------------------------------

function PlotService.Init()
	Remotes.Get("PlaceItem").OnServerEvent:Connect(handlePlaceItem)
	Remotes.Get("TakeItem").OnServerEvent:Connect(handleTakeItem)
	Remotes.Get("SetPrice").OnServerEvent:Connect(handleSetPrice)
	Remotes.Get("BuyUpgrade").OnServerEvent:Connect(handleBuyUpgrade)

	Players.PlayerRemoving:Connect(function(player)
		PlotService.ReleasePlot(player)
	end)
end

return PlotService
