--!strict
-- CustomerService — spawns customers, decides what they buy, and says why not.
--
-- IMPLEMENTATION CHOICE worth understanding: customers are Models moved by
-- lerping their pivot, not Humanoids using MoveTo or PathfindingService.
-- Humanoids bring physics, ragdolls, collision with players, and pathfinding
-- failures — none of which this game needs, all of which cost server time and
-- produce bugs. The rejected alternative (real Humanoid NPCs) would only be
-- correct if customers had to navigate obstacles. They walk in a straight line
-- to a counter, so they don't.
--
-- THE PRICING MODEL, which is the whole game:
--   perceived = item.baseValue * taste     (taste rolls 0.55 .. 1.75)
--   they buy if  price <= perceived  AND  price <= wallet
--   among affordable items they take the biggest surplus (perceived - price)
--
-- Price low and everyone buys but you earn little. Price high and you're
-- betting on a good taste roll. There is a real optimum and it is learnable.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local ItemDatabase = require(Shared:WaitForChild("ItemDatabase"))
local ReactionLines = require(Shared:WaitForChild("ReactionLines"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local CommunityService = require(script.Parent:WaitForChild("CommunityService"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local PlotService = require(script.Parent:WaitForChild("PlotService"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))

local CustomerService = {}

local rng = Random.new()
local customerFolder: Folder

local SHIRT_COLORS = {
	Color3.fromRGB(214, 92, 92),
	Color3.fromRGB(92, 148, 214),
	Color3.fromRGB(226, 186, 88),
	Color3.fromRGB(126, 196, 122),
	Color3.fromRGB(178, 122, 208),
	Color3.fromRGB(232, 148, 96),
}

--------------------------------------------------------------------
-- Customer rig
--------------------------------------------------------------------

local function buildCustomer(isWhale: boolean): Model
	local model = Instance.new("Model")
	model.Name = if isWhale then "Whale" else "Customer"

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2, 3, 1)
	body.Anchored = true
	body.CanCollide = false
	body.Material = Enum.Material.SmoothPlastic
	body.Color = if isWhale then Color3.fromRGB(226, 186, 88) else SHIRT_COLORS[rng:NextInteger(1, #SHIRT_COLORS)]
	body.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.3, 1.3, 1.3)
	head.Anchored = true
	head.CanCollide = false
	head.Material = Enum.Material.SmoothPlastic
	head.Color = Color3.fromRGB(234, 205, 170)
	head.Parent = model

	model.PrimaryPart = body

	if isWhale then
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Rate = 14
		sparkle.Lifetime = NumberRange.new(0.8, 1.4)
		sparkle.Speed = NumberRange.new(1, 2)
		sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 220, 120))
		sparkle.Size = NumberSequence.new(0.35)
		sparkle.Parent = body
	end

	return model
end

local function positionCustomer(model: Model, pivot: CFrame)
	local body = model.PrimaryPart :: BasePart
	body.CFrame = pivot
	local head = model:FindFirstChild("Head") :: BasePart?
	if head then
		head.CFrame = pivot * CFrame.new(0, 2.2, 0)
	end
end

local function speak(model: Model, text: string, color: Color3?)
	local body = model.PrimaryPart
	if not body then
		return
	end

	local existing = body:FindFirstChild("Speech")
	if existing then
		existing:Destroy()
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Speech"
	billboard.Size = UDim2.fromOffset(230, 52)
	billboard.StudsOffset = Vector3.new(0, 4.2, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 70
	billboard.Parent = body

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0.08
	frame.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.92, 0.86)
	label.Position = UDim2.fromScale(0.04, 0.07)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.TextScaled = true
	label.TextColor3 = color or Color3.fromRGB(40, 40, 45)
	label.Text = text
	label.Parent = frame
end

local function walk(model: Model, fromCF: CFrame, toCF: CFrame, duration: number)
	local start = os.clock()
	while true do
		local alpha = (os.clock() - start) / duration
		if alpha >= 1 then
			break
		end
		positionCustomer(model, fromCF:Lerp(toCF, alpha))
		task.wait()
	end
	positionCustomer(model, toCF)
end

--------------------------------------------------------------------
-- The decision
--------------------------------------------------------------------

type Decision = {
	kind: string, -- "buy" | "too_expensive" | "not_interested" | "cant_afford" | "empty"
	shelfIndex: number?,
	itemId: string?,
	price: number?,
	perceived: number?,
}

local function decide(data: PlayerDataService.SaveData, taste: number, wallet: number): Decision
	local bestBuy: Decision? = nil
	local bestSurplus = -math.huge

	-- Closest miss, for feedback when nothing sells.
	local closest: Decision? = nil
	local closestRatio = -math.huge

	local anyStock = false

	for key, entry in data.shelves do
		local item = ItemDatabase.Get(entry.itemId)
		if not item then
			continue
		end
		anyStock = true

		local shelfIndex = tonumber(key) or 0
		local perceived = item.baseValue * taste

		if entry.price <= perceived and entry.price <= wallet then
			local surplus = perceived - entry.price
			if surplus > bestSurplus then
				bestSurplus = surplus
				bestBuy = {
					kind = "buy",
					shelfIndex = shelfIndex,
					itemId = entry.itemId,
					price = entry.price,
					perceived = perceived,
				}
			end
		else
			local ratio = perceived / math.max(entry.price, 1)
			if ratio > closestRatio then
				closestRatio = ratio
				local kind: string
				if entry.price > wallet and entry.price <= perceived then
					kind = "cant_afford"
				elseif perceived < entry.price * 0.5 then
					kind = "not_interested"
				else
					kind = "too_expensive"
				end
				closest = {
					kind = kind,
					shelfIndex = shelfIndex,
					itemId = entry.itemId,
					price = entry.price,
					perceived = perceived,
				}
			end
		end
	end

	if bestBuy then
		return bestBuy
	end
	if not anyStock then
		return { kind = "empty" }
	end
	return closest or { kind = "empty" }
end

--------------------------------------------------------------------
-- One customer visit
--------------------------------------------------------------------

local function visit(plot: Model, player: Player)
	local data = PlayerDataService.Get(player)
	if not data then
		return
	end

	local approach = plot:FindFirstChild("CustomerApproach") :: BasePart?
	local stand = plot:FindFirstChild("CustomerStand") :: BasePart?
	if not approach or not stand then
		return
	end

	local isWhale = rng:NextNumber() < Config.WhaleChance

	local taste = rng:NextNumber(Config.TasteMin, Config.TasteMax)
	local wallet = rng:NextNumber(Config.WalletMin, Config.WalletMax)
		* Config.WalletMultiplier(data.upgrades.stallLevel or 0)

	if isWhale then
		taste += Config.WhaleTasteBonus
		wallet *= Config.WhaleWalletMult
	end

	local model = buildCustomer(isWhale)
	local startCF = CFrame.new(approach.Position) * CFrame.Angles(0, math.pi, 0)
	local endCF = CFrame.new(stand.Position) * CFrame.Angles(0, math.pi, 0)

	positionCustomer(model, startCF)
	model.Parent = customerFolder

	if isWhale then
		speak(model, ReactionLines.Pick("WhaleArrival"), Color3.fromRGB(150, 110, 20))
	end

	walk(model, startCF, endCF, Config.CustomerWalkTime)
	task.wait(Config.CustomerBrowseTime)

	-- Re-read state: the player may have re-priced everything while the
	-- customer was walking in, and they should get the benefit of that.
	local current = PlayerDataService.Get(player)
	if not current then
		model:Destroy()
		return
	end

	local decision = decide(current, taste, wallet)

	if decision.kind == "buy" and decision.shelfIndex and decision.itemId and decision.price then
		local key = tostring(decision.shelfIndex)
		local entry = current.shelves[key]

		-- Guard against the player having pulled the item off the shelf in the
		-- last few hundred milliseconds.
		if entry and entry.itemId == decision.itemId then
			current.shelves[key] = nil

			PlayerDataService.AddCash(player, decision.price)
			PlayerDataService.RecordSale(player, decision.itemId, decision.price)
			CommunityService.NoteSale(decision.itemId)

			speak(model, ReactionLines.Pick("HappyBuy"), Color3.fromRGB(30, 120, 50))

			Remotes.Get("Sale"):FireClient(player, {
				itemId = decision.itemId,
				price = decision.price,
				shelfIndex = decision.shelfIndex,
				isWhale = isWhale,
			})

			PlotService.RenderPlot(player)
			PlotService.Sync(player)
		end
	else
		local category = if decision.kind == "cant_afford"
			then "CantAfford"
			elseif decision.kind == "not_interested" then "NotInterested"
			elseif decision.kind == "empty" then "EmptyStall"
			else "TooExpensive"

		local line = ReactionLines.Pick(category)
		speak(model, line, Color3.fromRGB(150, 60, 60))

		-- The near-miss bubble is the game's teaching mechanism. Telling the
		-- player what this customer valued the item at is how they learn the
		-- distribution without a tutorial. See GAME-DESIGN.md §4.
		if decision.itemId and decision.perceived then
			Remotes.Get("NearMiss"):FireClient(player, {
				itemId = decision.itemId,
				perceived = math.floor(decision.perceived),
				price = decision.price,
				shelfIndex = decision.shelfIndex,
				line = line,
			})
		end
	end

	task.wait(1.4)
	walk(model, endCF, startCF, Config.CustomerWalkTime)
	model:Destroy()
end

-- Triggers the exact same `visit` a real customer runs, immediately, for
-- whichever plot the player owns. Used by DevCommands; decision logic here is
-- untouched — this only chooses *when* visit() runs, not what it decides.
function CustomerService.ForceVisit(player: Player): boolean
	local plot = PlotService.GetPlot(player)
	if not plot then
		return false
	end
	task.spawn(visit, plot, player)
	return true
end

--------------------------------------------------------------------

local function plotLoop(plot: Model)
	while true do
		local owner = PlotService.GetOwner(plot)

		if owner then
			local data = PlayerDataService.Get(owner)
			local interval = if data
				then Config.CustomerInterval(data.upgrades.customerRate or 0)
				else Config.BaseCustomerInterval

			task.wait(interval)

			-- Re-check: the owner may have left during the wait.
			if PlotService.GetOwner(plot) == owner and PlayerDataService.Get(owner) then
				task.spawn(visit, plot, owner)
			end
		else
			task.wait(2)
		end
	end
end

function CustomerService.Init()
	customerFolder = Instance.new("Folder")
	customerFolder.Name = "Customers"
	customerFolder.Parent = workspace

	for _, plot in WorldBuilder.GetPlots() do
		task.spawn(plotLoop, plot)
	end
end

return CustomerService
