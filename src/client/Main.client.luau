--!strict
-- Main (client) — the entire UI, built in code.
--
-- The client holds NO game logic. It renders whatever the last SyncData said
-- and sends requests. Every number displayed here was computed on the server.
-- If you ever find yourself calculating a price or a total in this file, stop:
-- that's the bug that lets someone hand themselves a million dollars.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local ItemDatabase = require(Shared:WaitForChild("ItemDatabase"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local state: any = nil
local selectedBagUid: string? = nil

--------------------------------------------------------------------
-- Style
--------------------------------------------------------------------

local INK = Color3.fromRGB(28, 28, 34)
local PANEL = Color3.fromRGB(248, 245, 238)
local ACCENT = Color3.fromRGB(64, 168, 96)
local WARN = Color3.fromRGB(206, 84, 76)

local function corner(parent: Instance, radius: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function label(text: string, size: UDim2, position: UDim2, parent: Instance): TextLabel
	local l = Instance.new("TextLabel")
	l.Text = text
	l.Size = size
	l.Position = position
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.GothamMedium
	l.TextColor3 = INK
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextSize = 14
	l.Parent = parent
	return l
end

local function button(text: string, size: UDim2, position: UDim2, color: Color3, parent: Instance): TextButton
	local b = Instance.new("TextButton")
	b.Text = text
	b.Size = size
	b.Position = position
	b.BackgroundColor3 = color
	b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamBold
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextSize = 14
	b.AutoButtonColor = true
	b.Parent = parent
	corner(b, 8)
	return b
end

--------------------------------------------------------------------
-- Root
--------------------------------------------------------------------

local screen = Instance.new("ScreenGui")
screen.Name = "SellMyJunkUI"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = playerGui

-- Cash header
local cashFrame = Instance.new("Frame")
cashFrame.Size = UDim2.fromOffset(220, 52)
cashFrame.Position = UDim2.new(0.5, -110, 0, 12)
cashFrame.BackgroundColor3 = PANEL
cashFrame.BorderSizePixel = 0
cashFrame.Parent = screen
corner(cashFrame, 12)

local cashLabel = Instance.new("TextLabel")
cashLabel.Size = UDim2.fromScale(1, 1)
cashLabel.BackgroundTransparency = 1
cashLabel.Font = Enum.Font.FredokaOne
cashLabel.TextSize = 26
cashLabel.TextColor3 = ACCENT
cashLabel.Text = "$0"
cashLabel.Parent = cashFrame

--------------------------------------------------------------------
-- Bag panel (left)
--------------------------------------------------------------------

local bagPanel = Instance.new("Frame")
bagPanel.Size = UDim2.fromOffset(250, 340)
bagPanel.Position = UDim2.new(0, 16, 0.5, -170)
bagPanel.BackgroundColor3 = PANEL
bagPanel.BorderSizePixel = 0
bagPanel.Parent = screen
corner(bagPanel, 12)

local bagTitle = label("BAG", UDim2.new(1, -20, 0, 24), UDim2.fromOffset(12, 8), bagPanel)
bagTitle.Font = Enum.Font.FredokaOne
bagTitle.TextSize = 18

local bagList = Instance.new("ScrollingFrame")
bagList.Size = UDim2.new(1, -16, 1, -46)
bagList.Position = UDim2.fromOffset(8, 38)
bagList.BackgroundTransparency = 1
bagList.BorderSizePixel = 0
bagList.ScrollBarThickness = 4
bagList.CanvasSize = UDim2.new()
bagList.AutomaticCanvasSize = Enum.AutomaticSize.Y
bagList.Parent = bagPanel

local bagLayout = Instance.new("UIListLayout")
bagLayout.Padding = UDim.new(0, 4)
bagLayout.SortOrder = Enum.SortOrder.LayoutOrder
bagLayout.Parent = bagList

--------------------------------------------------------------------
-- Shelves panel (right)
--------------------------------------------------------------------

local shelfPanel = Instance.new("Frame")
shelfPanel.Size = UDim2.fromOffset(300, 380)
shelfPanel.Position = UDim2.new(1, -316, 0.5, -190)
shelfPanel.BackgroundColor3 = PANEL
shelfPanel.BorderSizePixel = 0
shelfPanel.Parent = screen
corner(shelfPanel, 12)

local shelfTitle = label("SHELVES", UDim2.new(1, -20, 0, 24), UDim2.fromOffset(12, 8), shelfPanel)
shelfTitle.Font = Enum.Font.FredokaOne
shelfTitle.TextSize = 18

local shelfList = Instance.new("ScrollingFrame")
shelfList.Size = UDim2.new(1, -16, 1, -46)
shelfList.Position = UDim2.fromOffset(8, 38)
shelfList.BackgroundTransparency = 1
shelfList.BorderSizePixel = 0
shelfList.ScrollBarThickness = 4
shelfList.CanvasSize = UDim2.new()
shelfList.AutomaticCanvasSize = Enum.AutomaticSize.Y
shelfList.Parent = shelfPanel

local shelfLayout = Instance.new("UIListLayout")
shelfLayout.Padding = UDim.new(0, 6)
shelfLayout.SortOrder = Enum.SortOrder.LayoutOrder
shelfLayout.Parent = shelfList

--------------------------------------------------------------------
-- Upgrades panel (toggled)
--------------------------------------------------------------------

local upgradeToggle = button("UPGRADES", UDim2.fromOffset(150, 40), UDim2.new(0.5, -75, 1, -56), INK, screen)

local upgradePanel = Instance.new("Frame")
upgradePanel.Size = UDim2.fromOffset(340, 300)
upgradePanel.Position = UDim2.new(0.5, -170, 0.5, -150)
upgradePanel.BackgroundColor3 = PANEL
upgradePanel.BorderSizePixel = 0
upgradePanel.Visible = false
upgradePanel.Parent = screen
corner(upgradePanel, 12)

local upgradeTitle = label("UPGRADES", UDim2.new(1, -20, 0, 26), UDim2.fromOffset(14, 10), upgradePanel)
upgradeTitle.Font = Enum.Font.FredokaOne
upgradeTitle.TextSize = 20

local upgradeClose = button("X", UDim2.fromOffset(30, 30), UDim2.new(1, -40, 0, 10), WARN, upgradePanel)

local upgradeList = Instance.new("Frame")
upgradeList.Size = UDim2.new(1, -24, 1, -56)
upgradeList.Position = UDim2.fromOffset(12, 46)
upgradeList.BackgroundTransparency = 1
upgradeList.Parent = upgradePanel

local upgradeLayout = Instance.new("UIListLayout")
upgradeLayout.Padding = UDim.new(0, 6)
upgradeLayout.SortOrder = Enum.SortOrder.LayoutOrder
upgradeLayout.Parent = upgradeList

upgradeToggle.MouseButton1Click:Connect(function()
	upgradePanel.Visible = not upgradePanel.Visible
end)
upgradeClose.MouseButton1Click:Connect(function()
	upgradePanel.Visible = false
end)

--------------------------------------------------------------------
-- Heat meter (raids)
--------------------------------------------------------------------

local heatFrame = Instance.new("Frame")
heatFrame.Name = "HeatMeter"
heatFrame.Size = UDim2.fromOffset(260, 46)
heatFrame.Position = UDim2.new(0.5, -130, 0, 76)
heatFrame.BackgroundColor3 = PANEL
heatFrame.BorderSizePixel = 0
heatFrame.Visible = false
heatFrame.Parent = screen
corner(heatFrame, 10)

local heatLabel = Instance.new("TextLabel")
heatLabel.Size = UDim2.new(1, -16, 0, 16)
heatLabel.Position = UDim2.fromOffset(8, 5)
heatLabel.BackgroundTransparency = 1
heatLabel.Font = Enum.Font.GothamBold
heatLabel.TextSize = 12
heatLabel.TextColor3 = INK
heatLabel.TextXAlignment = Enum.TextXAlignment.Left
heatLabel.Text = "HIDDEN"
heatLabel.Parent = heatFrame

local heatTrack = Instance.new("Frame")
heatTrack.Size = UDim2.new(1, -16, 0, 14)
heatTrack.Position = UDim2.fromOffset(8, 24)
heatTrack.BackgroundColor3 = Color3.fromRGB(222, 216, 205)
heatTrack.BorderSizePixel = 0
heatTrack.Parent = heatFrame
corner(heatTrack, 6)

local heatFill = Instance.new("Frame")
heatFill.Size = UDim2.fromScale(0, 1)
heatFill.BackgroundColor3 = ACCENT
heatFill.BorderSizePixel = 0
heatFill.Parent = heatTrack
corner(heatFill, 6)

--------------------------------------------------------------------
-- Toasts
--------------------------------------------------------------------

local toastHolder = Instance.new("Frame")
toastHolder.Size = UDim2.fromOffset(300, 200)
toastHolder.Position = UDim2.new(0.5, -150, 0, 76)
toastHolder.BackgroundTransparency = 1
toastHolder.Parent = screen

local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0, 4)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.Parent = toastHolder

local function toast(text: string, kind: string?)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 34)
	frame.BackgroundColor3 = if kind == "good" then ACCENT elseif kind == "bad" then WARN else INK
	frame.BorderSizePixel = 0
	frame.Parent = toastHolder
	corner(frame, 8)

	local l = Instance.new("TextLabel")
	l.Size = UDim2.fromScale(1, 1)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.GothamBold
	l.TextSize = 14
	l.TextColor3 = Color3.new(1, 1, 1)
	l.Text = text
	l.Parent = frame

	task.delay(2.6, function()
		TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(l, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		task.wait(0.32)
		frame:Destroy()
	end)
end

--------------------------------------------------------------------
-- Knowledge helper — what does the player know about this item?
--------------------------------------------------------------------

local function knowledgeText(itemId: string): string
	if not state or not state.knowledge then
		return "Value: ???"
	end

	local k = state.knowledge[itemId]
	if not k then
		return "Value: ???"
	end

	if k.tier == "appraised" and k.baseValue then
		local low = math.floor(k.baseValue * 0.9)
		local high = math.floor(k.baseValue * 1.6)
		return ("APPRAISED  •  best price %d-%d"):format(low, high)
	elseif k.tier == "range" then
		return ("Range seen: %d-%d  (%d sold)"):format(k.average, k.best, k.sales)
	elseif k.tier == "average" then
		return ("Average sale: %d  (%d sold)"):format(k.average, k.sales)
	elseif k.tier == "last" then
		return ("Last sold for %d"):format(k.last)
	end

	return "Value: ???"
end

--------------------------------------------------------------------
-- Rendering
--------------------------------------------------------------------

local function renderBag()
	for _, child in bagList:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	if not state then
		return
	end

	bagTitle.Text = ("BAG  %d/%d"):format(#state.bag, state.bagCapacity)

	for index, entry in state.bag do
		local item = ItemDatabase.Get(entry.itemId)
		if not item then
			continue
		end

		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, -8, 0, 44)
		row.LayoutOrder = index
		row.BackgroundColor3 = if selectedBagUid == entry.uid
			then Color3.fromRGB(224, 236, 226)
			else Color3.fromRGB(238, 235, 228)
		row.BorderSizePixel = 0
		row.Text = ""
		row.AutoButtonColor = true
		row.Parent = bagList
		corner(row, 8)

		local stripe = Instance.new("Frame")
		stripe.Size = UDim2.new(0, 5, 1, 0)
		stripe.BackgroundColor3 = ItemDatabase.GetRarityColor(item.rarity)
		stripe.BorderSizePixel = 0
		stripe.Parent = row

		local name = label(item.name, UDim2.new(1, -18, 0, 18), UDim2.fromOffset(12, 4), row)
		name.Font = Enum.Font.GothamBold
		name.TextSize = 13
		name.TextTruncate = Enum.TextTruncate.AtEnd

		local sub = label(knowledgeText(item.id), UDim2.new(1, -18, 0, 16), UDim2.fromOffset(12, 22), row)
		sub.TextSize = 11
		sub.TextColor3 = Color3.fromRGB(120, 118, 112)

		row.MouseButton1Click:Connect(function()
			selectedBagUid = if selectedBagUid == entry.uid then nil else entry.uid
			renderBag()
		end)
	end
end

local function renderShelves()
	for _, child in shelfList:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	if not state then
		return
	end

	shelfTitle.Text = ("SHELVES  (%d)"):format(state.shelfCapacity)

	for i = 1, state.shelfCapacity do
		local entry = state.shelves[tostring(i)]

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -8, 0, if entry then 74 else 38)
		row.LayoutOrder = i
		row.BackgroundColor3 = Color3.fromRGB(238, 235, 228)
		row.BorderSizePixel = 0
		row.Parent = shelfList
		corner(row, 8)

		if not entry then
			local place = button(
				if selectedBagUid then ("Place here  (slot %d)"):format(i) else ("Empty slot %d"):format(i),
				UDim2.new(1, -12, 1, -10),
				UDim2.fromOffset(6, 5),
				if selectedBagUid then ACCENT else Color3.fromRGB(205, 202, 195),
				row
			)
			place.TextSize = 13
			place.MouseButton1Click:Connect(function()
				if selectedBagUid then
					Remotes.Get("PlaceItem"):FireServer(selectedBagUid, i)
					selectedBagUid = nil
				end
			end)
			continue
		end

		local item = ItemDatabase.Get(entry.itemId)
		if not item then
			continue
		end

		local stripe = Instance.new("Frame")
		stripe.Size = UDim2.new(0, 5, 1, 0)
		stripe.BackgroundColor3 = ItemDatabase.GetRarityColor(item.rarity)
		stripe.BorderSizePixel = 0
		stripe.Parent = row

		local name = label(item.name, UDim2.new(1, -18, 0, 18), UDim2.fromOffset(12, 4), row)
		name.Font = Enum.Font.GothamBold
		name.TextSize = 13
		name.TextTruncate = Enum.TextTruncate.AtEnd

		local hint = label(knowledgeText(item.id), UDim2.new(1, -18, 0, 14), UDim2.fromOffset(12, 21), row)
		hint.TextSize = 10
		hint.TextColor3 = Color3.fromRGB(120, 118, 112)

		local priceBox = Instance.new("TextBox")
		priceBox.Size = UDim2.fromOffset(86, 26)
		priceBox.Position = UDim2.fromOffset(12, 40)
		priceBox.BackgroundColor3 = Color3.new(1, 1, 1)
		priceBox.BorderSizePixel = 0
		priceBox.Font = Enum.Font.GothamBold
		priceBox.TextSize = 14
		priceBox.TextColor3 = INK
		priceBox.Text = tostring(entry.price)
		priceBox.ClearTextOnFocus = false
		priceBox.Parent = row
		corner(priceBox, 6)

		priceBox.FocusLost:Connect(function(enter)
			if not enter then
				priceBox.Text = tostring(entry.price)
				return
			end
			local value = tonumber(priceBox.Text)
			if value then
				Remotes.Get("SetPrice"):FireServer(i, math.floor(value))
			else
				priceBox.Text = tostring(entry.price)
			end
		end)

		local down =
			button("-10%", UDim2.fromOffset(52, 26), UDim2.fromOffset(104, 40), Color3.fromRGB(150, 150, 155), row)
		down.TextSize = 12
		down.MouseButton1Click:Connect(function()
			Remotes.Get("SetPrice"):FireServer(i, math.max(Config.MinPrice, math.floor(entry.price * 0.9)))
		end)

		local up =
			button("+10%", UDim2.fromOffset(52, 26), UDim2.fromOffset(160, 40), Color3.fromRGB(150, 150, 155), row)
		up.TextSize = 12
		up.MouseButton1Click:Connect(function()
			Remotes.Get("SetPrice"):FireServer(i, math.floor(entry.price * 1.1) + 1)
		end)

		local take = button("Take", UDim2.fromOffset(52, 26), UDim2.fromOffset(216, 40), WARN, row)
		take.TextSize = 12
		take.MouseButton1Click:Connect(function()
			Remotes.Get("TakeItem"):FireServer(i)
		end)
	end
end

local function renderUpgrades()
	for _, child in upgradeList:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	if not state then
		return
	end

	for order, id in Config.UpgradeOrder do
		local info = state.upgrades[id]
		if not info then
			continue
		end

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 56)
		row.LayoutOrder = order
		row.BackgroundColor3 = Color3.fromRGB(238, 235, 228)
		row.BorderSizePixel = 0
		row.Parent = upgradeList
		corner(row, 8)

		local name = label(
			("%s  (Lv %d)"):format(info.name, info.level),
			UDim2.new(1, -110, 0, 18),
			UDim2.fromOffset(10, 6),
			row
		)
		name.Font = Enum.Font.GothamBold
		name.TextSize = 13

		local desc = label(info.desc, UDim2.new(1, -110, 0, 16), UDim2.fromOffset(10, 26), row)
		desc.TextSize = 11
		desc.TextColor3 = Color3.fromRGB(120, 118, 112)

		if info.cost then
			local affordable = state.cash >= info.cost
			local buy = button(
				"$" .. info.cost,
				UDim2.fromOffset(88, 34),
				UDim2.new(1, -98, 0, 11),
				if affordable then ACCENT else Color3.fromRGB(180, 178, 172),
				row
			)
			buy.MouseButton1Click:Connect(function()
				Remotes.Get("BuyUpgrade"):FireServer(id)
			end)
		else
			local maxed = label("MAX", UDim2.fromOffset(88, 34), UDim2.new(1, -98, 0, 11), row)
			maxed.Font = Enum.Font.GothamBold
			maxed.TextXAlignment = Enum.TextXAlignment.Center
			maxed.TextColor3 = ACCENT
		end
	end
end

local function renderAll()
	if not state then
		return
	end
	cashLabel.Text = "$" .. state.cash
	renderBag()
	renderShelves()
	renderUpgrades()
end

--------------------------------------------------------------------
-- Wire up
--------------------------------------------------------------------

Remotes.Get("SyncData").OnClientEvent:Connect(function(newState)
	state = newState
	renderAll()
end)

Remotes.Get("Notify").OnClientEvent:Connect(function(text, kind)
	toast(text, kind)
end)

Remotes.Get("Sale").OnClientEvent:Connect(function(info)
	local item = ItemDatabase.Get(info.itemId)
	local name = if item then item.name else "something"
	toast(("SOLD: %s for $%d%s"):format(name, info.price, if info.isWhale then "  ⭐" else ""), "good")
end)

Remotes.Get("NearMiss").OnClientEvent:Connect(function(info)
	local item = ItemDatabase.Get(info.itemId)
	local name = if item then item.name else "it"
	toast(("Walked away — valued %s at ~$%d"):format(name, info.perceived), "bad")
end)

-- Heat has to be visible or a catch reads as the game cheating rather than as a
-- consequence the player chose. Hidden entirely at zero so it doesn't clutter
-- the screen while you're nowhere near a house.
Remotes.Get("Heat").OnClientEvent:Connect(function(heat, max, heatState)
	local fraction = math.clamp(heat / math.max(max, 1), 0, 1)
	heatFrame.Visible = heat > 0

	heatFill.Size = UDim2.fromScale(fraction, 1)
	heatFill.BackgroundColor3 = if heatState == "chasing"
		then WARN
		elseif heatState == "suspicious" then Color3.fromRGB(226, 176, 66)
		else ACCENT

	heatLabel.Text = if heatState == "chasing"
		then "SEEN!"
		elseif heatState == "suspicious" then "HEARD SOMETHING"
		else "HIDDEN"
end)

Remotes.Get("Caught").OnClientEvent:Connect(function(lostCount)
	heatFrame.Visible = false
	if lostCount > 0 then
		toast(("CAUGHT — dropped %d item%s"):format(lostCount, if lostCount == 1 then "" else "s"), "bad")
	else
		toast("CAUGHT — but your hands were empty", "bad")
	end
end)

toast("Grab junk from the yard, then price it on your shelves.", "info")
